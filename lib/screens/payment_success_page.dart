import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String txnId;
  final String callbackUrl;
  final String cardImage;
  final String amount;
  final String merchantName;

  const PaymentSuccessPage({
    Key? key,
    required this.txnId,
    required this.callbackUrl,
    required this.cardImage,
    required this.amount,
    required this.merchantName,
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  int _counter = 3;
  Timer? _timer;

  /// GIF 보임 여부
  bool _showGif = true;

  @override
  void initState() {
    super.initState();

    // 1) 3초 뒤에 GIF 숨기기
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _showGif = false);
    });

    // 2) 원래 카운트다운 로직
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_counter == 1) {
        t.cancel();
        _launchCallback();
        Navigator.of(context).popUntil((r) => r.isFirst);
      } else {
        setState(() => _counter--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _launchCallback() async {
    final uri = Uri.parse(widget.callbackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###원');
    final formattedAmount = formatter.format(int.tryParse(widget.amount) ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFFDCEAF6),
      body: SafeArea(
        child: Stack(
          children: [
            // 캐릭터 이미지
            Positioned(
              right: 160,
              bottom: 25,
              child: Image.asset(
                'assets/images/woori_wibe_hi.png',
                width: 80,
              ),
            ),

            // 메인 컨텐츠
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, -60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1) 3초간 보일 GIF
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: _showGif ? 1 : 0,
                        child: Image.asset(
                          'assets/animations/payment_check.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // 2) 제목
                      const Text(
                        '결제완료',
                        style: TextStyle(
                          fontFamily: 'WooridaumL',
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 카드 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.cardImage,
                          width: 300,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 안내 문구
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.merchantName} $formattedAmount',
                            style: const TextStyle(
                              fontFamily: 'WooridaumB',
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '결제요청이 안전하게 처리되었습니다.',
                            style: TextStyle(
                              fontFamily: 'WooridaumB',
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            '아래 [확인] 버튼을 누르신 후,',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '이전 화면으로 돌아가야 결제가 완료됩니다.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          // 카운트다운 표시
                          Text(
                            '$_counter',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 확인 버튼 (PaymentPage ‘동의 후 결제’와 같은 위치/스타일)
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: const Offset(0, 30),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        _launchCallback();
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0083CA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontFamily: 'WooridaumB',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
