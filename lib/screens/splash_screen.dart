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
          uri.queryParameters['amount'] != null &&
          uri.queryParameters['callbackUrl'] != null) {
        final txn = uri.queryParameters['txn']!;
        final merchantName = uri.queryParameters['merchant']!;
        final amount = uri.queryParameters['amount']!;
        final callbackUrl = uri.queryParameters['callbackUrl']!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              txnId: txn,
              merchantName: merchantName,
              amount: amount,
              callbackUrl: callbackUrl,
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(), // 상단 여백

            // 중앙 아이콘 + 원큐PAY 텍스트

            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, 70),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/app_icon.png',
                      width: 80,
                      height: 80,
                    ),
                    const Text(
                      '원큐PAY',
                      style: TextStyle(
                        fontFamily: 'WooridaumB',
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(), // 중앙과 하단 사이 여백
            Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: const Offset(0, 35),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Image.asset(
                      'assets/images/woori_card_splash.png',
                      width: MediaQuery.of(context).size.width * 0.85,
                      fit: BoxFit.contain,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
