// splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'payment_page.dart';

class SplashScreen extends StatefulWidget {
  final Uri? initialUri;
  const SplashScreen({Key? key, this.initialUri}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      // Cold-start 시 전달된 deep link 처리
      final uri = widget.initialUri;
      if (uri != null &&
          uri.scheme == 'appcard' &&
          uri.host == 'auth' &&
          uri.queryParameters['txn'] != null &&
          uri.queryParameters['merchant'] != null &&
          uri.queryParameters['amount'] != null) {
        final txn = uri.queryParameters['txn']!;
        final merchantName = uri.queryParameters['merchant']!;
        final amount = uri.queryParameters['amount']!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              txnId: txn,
              merchantName: merchantName,
              amount: amount,
            ),
          ),
        );

        // } else {
        //   // 딥링크 없으면 기본 페이지로 (예: 빈 화면이나 로그인 화면)
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(
        //       builder: (_) => const HomePage(), // 필요하다면 구현
        //     ),
        //   );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B4453),
      body: Center(
        child: Image.asset(
          'assets/images/woori_card_splash.jpg',
          width: MediaQuery.of(context).size.width * 0.7,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
