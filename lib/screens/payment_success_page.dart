import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String txnId;
  final String callbackUrl;
  const PaymentSuccessPage({
    Key? key,
    required this.txnId,
    required this.callbackUrl,
  }) : super(key: key);

  Future<void> _launchCallback() async {
    final uri = Uri.parse(callbackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;

    return SafeArea(
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: Color(0xFFDCEAF6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // 상단 헤더: leading 버튼 + 타이틀
            Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 40),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: _launchCallback,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'App Card',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '결제 진행',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 64), // leading 만큼 공간 확보
              ],
            ),
            const Divider(height: 1),
            const Spacer(),
            // 진행중 아이콘
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                color: Color(0xFF0083CA),
              ),
            ),
            const SizedBox(height: 24),
            // 안내 메시지
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '이전 사이트에서 결제를 이어주세요.',
                style: TextStyle(color: Colors.black, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            // 홈으로 돌아가기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '홈으로 돌아가기',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
