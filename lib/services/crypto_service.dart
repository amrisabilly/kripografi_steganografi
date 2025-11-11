import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;
import 'package:pointycastle/asn1.dart';
import 'package:image/image.dart' as img;

class CryptoService {
  // --- Kunci RSA ---

  Future<Map<String, String>> generateRsaKeyPair() async {
    final keyGen = pc.RSAKeyGenerator();
    keyGen.init(
      pc.ParametersWithRandom(
        pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        _getSecureRandom(),
      ),
    );

    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey as pc.RSAPublicKey;
    final privateKey = pair.privateKey as pc.RSAPrivateKey;

    return {
      'publicKey': _encodePublicKeyToPem(publicKey),
      'privateKey': _encodePrivateKeyToPem(privateKey),
    };
  }

  pc.RSAPublicKey _parsePublicKeyFromPem(String pem) {
    final lines = pem
        .split('\n')
        .where(
          (line) =>
              !line.startsWith('-----BEGIN') && !line.startsWith('-----END'),
        )
        .join('');
    final bytes = base64Decode(lines);
    final asn1Parser = ASN1Parser(bytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final bitString = topLevelSeq.elements![1] as ASN1BitString;
    final innerParser = ASN1Parser(bitString.stringValues as Uint8List?);
    final sequence = innerParser.nextObject() as ASN1Sequence;
    final modulus = (sequence.elements![0] as ASN1Integer).integer;
    final exponent = (sequence.elements![1] as ASN1Integer).integer;
    return pc.RSAPublicKey(modulus!, exponent!);
  }

  pc.RSAPrivateKey _parsePrivateKeyFromPem(String pem) {
    final lines = pem
        .split('\n')
        .where(
          (line) =>
              !line.startsWith('-----BEGIN') && !line.startsWith('-----END'),
        )
        .join('');
    final bytes = base64Decode(lines);
    final asn1Parser = ASN1Parser(bytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final privateKeyOctet = topLevelSeq.elements![2] as ASN1OctetString;
    final innerParser = ASN1Parser(privateKeyOctet.octets);
    final sequence = innerParser.nextObject() as ASN1Sequence;
    final modulus = (sequence.elements![1] as ASN1Integer).integer;
    final privateExponent = (sequence.elements![3] as ASN1Integer).integer;
    final p = (sequence.elements![4] as ASN1Integer).integer;
    final q = (sequence.elements![5] as ASN1Integer).integer;
    return pc.RSAPrivateKey(modulus!, privateExponent!, p, q);
  }

  String _encodePublicKeyToPem(pc.RSAPublicKey key) {
    var algorithmSeq = ASN1Sequence();
    algorithmSeq.add(
      ASN1ObjectIdentifier.fromIdentifierString('1.2.840.113549.1.1.1'),
    ); // RSA
    algorithmSeq.add(ASN1Null());

    var keySeq = ASN1Sequence();
    keySeq.add(ASN1Integer(key.modulus));
    keySeq.add(ASN1Integer(key.exponent));
    var bitString = ASN1BitString(stringValues: keySeq.encode());

    var topLevelSeq = ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(bitString);

    var dataBase64 = base64Encode(topLevelSeq.encode());
    return "-----BEGIN PUBLIC KEY-----\n$dataBase64\n-----END PUBLIC KEY-----";
  }

  String _encodePrivateKeyToPem(pc.RSAPrivateKey key) {
    var version = ASN1Integer(BigInt.from(0));
    var algorithmSeq = ASN1Sequence();
    algorithmSeq.add(
      ASN1ObjectIdentifier.fromIdentifierString('1.2.840.113549.1.1.1'),
    ); // RSA
    algorithmSeq.add(ASN1Null());

    var keySeq = ASN1Sequence();
    keySeq.add(version);
    keySeq.add(ASN1Integer(key.modulus));
    keySeq.add(ASN1Integer(key.publicExponent)); // publicExponent
    keySeq.add(ASN1Integer(key.privateExponent));
    keySeq.add(ASN1Integer(key.p));
    keySeq.add(ASN1Integer(key.q));
    keySeq.add(
      ASN1Integer(key.privateExponent! % (key.p! - BigInt.one)),
    ); // dmp1
    keySeq.add(
      ASN1Integer(key.privateExponent! % (key.q! - BigInt.one)),
    ); // dmq1
    keySeq.add(ASN1Integer(key.q!.modInverse(key.p!))); // iqmp

    var octetString = ASN1OctetString(octets: keySeq.encode());
    var topLevelSeq = ASN1Sequence();
    topLevelSeq.add(version);
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(octetString);

    var dataBase64 = base64Encode(topLevelSeq.encode());
    return "-----BEGIN PRIVATE KEY-----\n$dataBase64\n-----END PRIVATE KEY-----";
  }

  pc.SecureRandom _getSecureRandom() {
    final secureRandom = pc.FortunaRandom();
    final random = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  // --- Hybrid Encryption (AES-GCM + RSA) ---

  Uint8List _generateRandomBytes(int length) {
    return _getSecureRandom().nextBytes(length);
  }

  String encryptHybrid(Uint8List data, String pemPublicKey) {
    // 1. Generate AES key and IV
    final aesKey = _generateRandomBytes(32); // 256-bit
    final iv = _generateRandomBytes(12); // 96-bit for GCM

    // 2. Encrypt data with AES-GCM
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    cipher.init(true, pc.ParametersWithIV(pc.KeyParameter(aesKey), iv));
    final encryptedData = cipher.process(data);

    // 3. Encrypt AES key with RSA
    final rsaPublicKey = _parsePublicKeyFromPem(pemPublicKey);
    final rsaCipher = pc.PKCS1Encoding(pc.RSAEngine());
    rsaCipher.init(
      true,
      pc.PublicKeyParameter<pc.RSAPublicKey>(rsaPublicKey),
    ); // <-- perbaiki di sini

    final encryptedAesKey = rsaCipher.process(aesKey);

    // 4. Combine and encode
    return '${base64Encode(encryptedAesKey)}.${base64Encode(iv)}.${base64Encode(encryptedData)}';
  }

  Uint8List? decryptHybrid(String payload, String pemPrivateKey) {
    try {
      // 1. Decode and split
      final parts = payload.split('.');
      if (parts.length != 3) return null;

      final encryptedAesKey = base64Decode(parts[0]);
      final iv = base64Decode(parts[1]);
      final encryptedData = base64Decode(parts[2]);

      // 2. Decrypt AES key with RSA
      final rsaPrivateKey = _parsePrivateKeyFromPem(pemPrivateKey);
      final rsaCipher = pc.PKCS1Encoding(pc.RSAEngine());
      rsaCipher.init(
        false,
        pc.PrivateKeyParameter<pc.RSAPrivateKey>(rsaPrivateKey),
      );
      final aesKey = rsaCipher.process(encryptedAesKey);

      // 3. Decrypt data with AES-GCM
      final cipher = pc.GCMBlockCipher(pc.AESEngine());
      cipher.init(false, pc.ParametersWithIV(pc.KeyParameter(aesKey), iv));
      final decryptedData = cipher.process(encryptedData);

      return decryptedData;
    } catch (e) {
      print('Dekripsi gagal (kemungkinan korup): $e');
      return null;
    }
  }

  // --- Kriteria 3: Super Enkripsi (Vigenere) ---
  String vigenereEncrypt(String text, String key) {
    if (key.isEmpty) return text;
    String out = '';
    int keyIndex = 0;
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      int keyCharCode = key.codeUnitAt(keyIndex % key.length);
      int encryptedCharCode =
          (charCode + keyCharCode) % 256; // Simple byte shift
      out += String.fromCharCode(encryptedCharCode);
      keyIndex++;
    }
    return out;
  }

  String vigenereDecrypt(String text, String key) {
    if (key.isEmpty) return text;
    String out = '';
    int keyIndex = 0;
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      int keyCharCode = key.codeUnitAt(keyIndex % key.length);
      int decryptedCharCode = (charCode - keyCharCode + 256) % 256; // Reverse
      out += String.fromCharCode(decryptedCharCode);
      keyIndex++;
    }
    return out;
  }

  // --- Kriteria 4: Steganografi (LSB) ---
  // Penanda akhir pesan (terminator)
  final List<int> _terminator = utf8.encode('<<EOM>>');

  Uint8List? lsbEmbed(Uint8List imageBytes, String message) {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return null;

      List<int> messageBytes = [...utf8.encode(message), ..._terminator];
      int messageBitIndex = 0;
      int messageByteIndex = 0;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          if (messageByteIndex >= messageBytes.length) {
            return img.encodePng(image); // Selesai menyisipkan
          }

          final pixel = image.getPixel(x, y);
          int r = pixel.r.toInt();
          int g = pixel.g.toInt();
          int b = pixel.b.toInt();

          int currentByte = messageBytes[messageByteIndex];

          // Sisipkan bit ke LSB Red
          if (messageBitIndex < 8) {
            bool bit = ((currentByte >> (7 - messageBitIndex)) & 1) == 1;
            r = bit ? (r | 1) : (r & 254);
            messageBitIndex++;
          }
          // Sisipkan bit ke LSB Green
          if (messageBitIndex < 8) {
            bool bit = ((currentByte >> (7 - messageBitIndex)) & 1) == 1;
            g = bit ? (g | 1) : (g & 254);
            messageBitIndex++;
          }
          // Sisipkan bit ke LSB Blue
          if (messageBitIndex < 8) {
            bool bit = ((currentByte >> (7 - messageBitIndex)) & 1) == 1;
            b = bit ? (b | 1) : (b & 254);
            messageBitIndex++;
          }

          image.setPixelRgb(x, y, r, g, b);

          if (messageBitIndex == 8) {
            messageBitIndex = 0;
            messageByteIndex++;
          }
        }
      }
      return img.encodePng(image);
    } catch (e) {
      print('Error embedding LSB: $e');
      return null;
    }
  }

  String? lsbExtract(Uint8List imageBytes) {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return null;

      List<int> messageBytes = [];
      int currentByte = 0;
      int bitIndex = 0;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // Baca LSB Red
          if (bitIndex < 8) {
            currentByte = (currentByte << 1) | (pixel.r.toInt() & 1);
            bitIndex++;
          }
          // Baca LSB Green
          if (bitIndex < 8) {
            currentByte = (currentByte << 1) | (pixel.g.toInt() & 1);
            bitIndex++;
          }
          // Baca LSB Blue
          if (bitIndex < 8) {
            currentByte = (currentByte << 1) | (pixel.b.toInt() & 1);
            bitIndex++;
          }

          if (bitIndex == 8) {
            messageBytes.add(currentByte);
            // Cek terminator
            if (messageBytes.length >= _terminator.length &&
                messageBytes
                        .sublist(messageBytes.length - _terminator.length)
                        .join() ==
                    _terminator.join()) {
              // Hapus terminator dan decode
              return utf8.decode(
                messageBytes.sublist(
                  0,
                  messageBytes.length - _terminator.length,
                ),
              );
            }
            currentByte = 0;
            bitIndex = 0;
          }
        }
      }
      return null; // Tidak ditemukan terminator
    } catch (e) {
      print('Error extracting LSB: $e');
      return null;
    }
  }
}
