import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/payment_page.dart';

// 백그라운드 메시지 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('[bg] message: ${message.messageId}, data: ${message.data}');
}

final _fln = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await registerFcmToken();

  Uri? initialUri;
  try {
    initialUri = await getInitialUri();
    print('▶️ 앱 실행 시 initialUri: $initialUri');
  } catch (e) {
    debugPrint('getInitialUri error: $e');
  }

  runApp(AppCardFront(initialUri: initialUri));
}

Future<void> registerFcmToken() async {
  const _baseUrl = 'http://192.168.0.168:8084';
  final token = await FirebaseMessaging.instance.getToken();
  print("token : ${token}");
  if (token != null) {
    await http.post(
      Uri.parse('$_baseUrl/notifications/registerToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
  }
}

class AppCardFront extends StatefulWidget {
  final Uri? initialUri;
  const AppCardFront({Key? key, this.initialUri}) : super(key: key);

  @override
  State<AppCardFront> createState() => _AppCardFrontState();
}

class _AppCardFrontState extends State<AppCardFront> {
  final _navKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();

    // 1) iOS용 로컬 알림 초기 설정
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    _fln.initialize(
      const InitializationSettings(
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse resp) {
        if (resp.payload != null) {
          final data = jsonDecode(resp.payload!);
          _navigateFromData(data as Map<String, dynamic>);
        }
      },
    );

    // 2) 포그라운드 메시지 → 로컬 알림으로 띄우기
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        _fln.show(
          n.hashCode,
          n.title,
          n.body,
          const NotificationDetails(
            iOS: DarwinNotificationDetails(),
          ),
          payload: jsonEncode(msg.data),
        );
      }
    });

    // 3) 완전 종료 상태에서 푸시 → 앱 실행
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((msg) => msg != null ? _navigateFromData(msg.data) : null);

    // 4) 백그라운드에서 알림 탭 → 앱 포그라운드
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _navigateFromData(msg.data);
    });

    // 딥링크 처리
    _sub = uriLinkStream.listen((uri) {
      print('▶️ onUriLinkStream: $uri');
      if (uri != null) {
        print('   • queryParameters: ${uri.queryParameters}');
        _navigateFromData(uri.queryParameters);
      }
    });
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final txn = data['txn'] as String?;
    final m = data['merchant'] as String?;
    final amt = data['amount'] as String?;
    final cb = data['callbackUrl'] as String?;
    print('▶️ _navigateFromData cb: $cb');
    if (txn != null && m != null && amt != null && cb != null) {
      _navKey.currentState?.push(MaterialPageRoute(
        builder: (_) => PaymentPage(
          txnId: txn,
          merchantName: m,
          amount: amt,
          callbackUrl: cb,
        ),
      ));
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      home: SplashScreen(initialUri: widget.initialUri),
    );
  }
}
// import 'package:app_card_front/screens/payment_success_page.dart';
// import 'package:flutter/material.dart';

// final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

// class MyApp extends StatefulWidget {
//   // final Uri initialUri; // 원래 있던 값
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: _navKey,
//       // SplashScreen(initialUri: widget.initialUri),
//       home: PaymentSuccessPage(
//         txnId: 'DUMMY_TXN_1234',
//         callbackUrl: 'https://example.com/callback',
//         cardImage: 'assets/images/woori_card_vip.png',
//         amount: '10000',
//         merchantName: '테스트 상점',
//       ),
//     );
//   }
// }

// void main() {
//   runApp(const MyApp());
// }
