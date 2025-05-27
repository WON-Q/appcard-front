// key_manager.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

class KeyManager {
  final _storage = const FlutterSecureStorage();
  static const _baseUrl = 'http://192.168.0.168:8080';
  //192.168.0.168
  /// 카드 하나당 한 번만 호출: Ed25519 키페어 생성 → 비밀키만 로컬에, 공개키는 서버에 전송
  Future<void> generateAndStoreKeyPair(String cardId) async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();

    // 비밀키
    final privBytes = await keyPair.extractPrivateKeyBytes();
    final privHex = hex.encode(privBytes);
    await _storage.write(key: 'ed25519_${cardId}_priv', value: privHex);

    // 공개키
    final pub = await keyPair.extractPublicKey();
    final pubBytes = pub.bytes;
    final pubB64 = base64Encode(pubBytes);

    final registerBody = jsonEncode({
      'cardId': cardId,
      'publicKey': pubB64,
    });

    print('🚀 registerKey 호출: $registerBody');
    final res = await http.post(
      Uri.parse('$_baseUrl/authentications/registerKey'),
      headers: {'Content-Type': 'application/json'},
      body: registerBody,
    );
    if (res.statusCode != 200) {
      throw Exception('공개키 등록 실패: ${res.statusCode} / ${res.body}');
    }
  }

  /// 이미 저장된 비밀키(hex)를 읽어서 Ed25519 키페어로 복원
  Future<KeyPair> getKeyPair(String cardId) async {
    final privHex = await _storage.read(key: 'ed25519_${cardId}_priv');

    if (privHex == null) {
      throw StateError('비밀키가 없습니다. generateAndStoreKeyPair 호출 필요');
    }
    final privBytes = hex.decode(privHex);
    // seed 기반 복원 지원
    return Ed25519().newKeyPairFromSeed(privBytes);
  }
}
