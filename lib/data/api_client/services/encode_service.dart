import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as package_encrypt;

class EncodeService {

  String encryptData(String fcid, String payload) {
    String newID = fcid.replaceAll('-', '');
    String reversed = newID.split('').reversed.join();
    String ivDecrypt = newID.substring(0, 16);

    final key = package_encrypt.Key.fromUtf8(reversed);
    final iv = package_encrypt.IV.fromUtf8(ivDecrypt);
    final encrypter = package_encrypt.Encrypter(package_encrypt.AES(key, mode: package_encrypt.AESMode.cbc, padding: 'PKCS7'));
    final enc = encrypter.encrypt(payload, iv: iv);

    return enc.base64;
  }

  Uint8List decodeData(String fcid, String data) {
    String newID = fcid.replaceAll('-', '');
    String reversed = newID.split('').reversed.join();
    String ivDecrypt = newID.substring(0, 16);

    final key = package_encrypt.Key.fromUtf8(reversed);
    final iv = package_encrypt.IV.fromUtf8(ivDecrypt);
    final encrypter = package_encrypt.Encrypter(package_encrypt.AES(key, mode: package_encrypt.AESMode.cbc, padding: 'PKCS7'));
    final encryptedKey = package_encrypt.Encrypted.fromBase64(data);
    final decrypted = encrypter.decryptBytes(encryptedKey, iv: iv);
    final result = utf8.decode(decrypted);
    log('EncodeService -> decodeData:\n $result');
    return utf8.encode(result);
  }

}