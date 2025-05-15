// lib/utils/secure_storage_util.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtil {
  static final _storage = const FlutterSecureStorage();

  /// 저장된 모든 키·값을 콘솔에 출력합니다.
  static Future<void> dump() async {
    final all = await _storage.readAll();
    if (all.isEmpty) {
      print('SecureStorage is empty');
    } else {
      all.forEach((key, value) {
        print('🔑 $key: $value');
      });
    }
  }

  /// 저장된 모든 값을 삭제합니다.
  static Future<void> clear() async {
    await _storage.deleteAll();
    print('SecureStorage cleared');
  }
}
