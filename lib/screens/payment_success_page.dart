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

  @override
  void initState() {
    super.initState();
    // 1초마다 카운트다운
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter == 1) {
        timer.cancel();
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
            // 닫기(X) 버튼
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  _timer?.cancel();
                  _launchCallback();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                child: const Icon(Icons.close, size: 28, color: Colors.black87),
              ),
            ),

            // 메인 컨텐츠
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목
                    const Text(
                      '결제완료',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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

                    const SizedBox(height: 32),

                    // 안내 문구 (줄바꿈 포함)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.merchantName} $formattedAmount',
                          style: const TextStyle(
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
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '[확인] 버튼을 누르신 후,',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '이전 화면으로 돌아가야 결제가 완료됩니다.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
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

            // 확인 버튼
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _timer?.cancel();
                    _launchCallback();
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
