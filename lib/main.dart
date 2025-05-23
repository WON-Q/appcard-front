import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import 'screens/splash_screen.dart';
import 'screens/payment_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ① cold-start 시 딥링크 한 번 캡처
  Uri? initialUri;
  try {
    initialUri = await getInitialUri();
  } catch (e) {
    debugPrint('getInitialUri error: $e');
  }
  runApp(AppCardFront(initialUri: initialUri));
}

class AppCardFront extends StatefulWidget {
  final Uri? initialUri;
  const AppCardFront({Key? key, this.initialUri}) : super(key: key);

  @override
  State<AppCardFront> createState() => _AppCardFrontState();
}

class _AppCardFrontState extends State<AppCardFront> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    // ② 앱 실행 중에 들어오는 딥링크
    _sub = uriLinkStream.listen((uri) {
      if (uri != null) _handleUri(uri);
    }, onError: (err) {
      debugPrint('uriLinkStream error: $err');
    });
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'appcard' && uri.host == 'auth') {
      final txn = uri.queryParameters['txn'];
      final merchant = uri.queryParameters['merchant'];
      final amount = uri.queryParameters['amount'];
      final callbackUrl = uri.queryParameters['callbackUrl'];
      if (txn != null &&
          merchant != null &&
          amount != null &&
          callbackUrl != null) {
        _navKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              txnId: txn,
              merchantName: merchant,
              amount: amount,
              callbackUrl: callbackUrl,
            ),
          ),
        );
      }
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
      home: SplashScreen(
        initialUri: widget.initialUri, // ③ cold-start 파라미터 전달
      ),
    );
  }
}
