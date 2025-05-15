import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({Key? key}) : super(key: key);

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
            // 상단 제목 영역
            Container(
              height: 56,
              alignment: Alignment.center,
              child: const Text(
                '결제완료',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(height: 1),
            const Spacer(),
            // 성공 아이콘
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF0083CA),
              size: 100,
            ),
            const SizedBox(height: 24),
            // 성공 메시지
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '결제가 성공적으로 완료되었습니다!',
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
                    style: TextStyle(
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
