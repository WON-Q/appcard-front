import 'dart:convert';

import 'package:app_card_front/utils/KeyManager.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:local_auth/local_auth.dart';
import '../widgets/payment_method_item.dart';
import 'payment_success_page.dart';
import 'package:app_card_front/utils/secure_storage_util.dart';

class PaymentPage extends StatefulWidget {
  final String txnId;
  final String merchantName;
  final String amount;
  const PaymentPage({
    Key? key,
    required this.txnId,
    required this.merchantName,
    required this.amount,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  final _keyMgr = KeyManager();
  static const _baseUrl = 'http://192.168.0.168:8080'; // 앱카드 서버 url

  bool isChecked = false;
  int selectedIndex = 0;
  final PageController _controller = PageController(viewportFraction: 0.8);

  final List<Map<String, String>> methods = [
    {
      'cardId': 'APP_CARD_001',
      'cardType': 'CREDIT',
      'image': 'assets/images/wooribank_logo.jpeg',
      'cardImage': 'assets/images/woori_card_vip.png',
      'cardName': '우리은행 신용카드',
      'cardNumber': '2029-1118-****-**',
    },
    {
      'cardId': 'APP_CARD_002',
      'cardType': 'CHECK',
      'image': 'assets/images/wooribank_logo.jpeg',
      'cardImage': 'assets/images/woori_card_general.png',
      'cardName': '우리은행 체크카드',
      'cardNumber': '3429-1018-****-**',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAllKeysOnce();
  }

  final storage = const FlutterSecureStorage();

  Future<void> _initializeAllKeysOnce() async {
    // (1) 디버그용: 우선 비우고 시작
    await SecureStorageUtil.clear();

    for (final m in methods) {
      final cardId = m['cardId']!;
      // 무조건 생성+등록
      await _keyMgr.generateAndStoreKeyPair(cardId);
    }
  }

  Future<String> signChallenge(String challenge, String cardId) async {
    final keyPair = await _keyMgr.getKeyPair(cardId);
    final sig = await Ed25519().sign(
      utf8.encode(challenge),
      keyPair: keyPair,
    );
    return base64UrlEncode(sig.bytes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPayPressed() async {
    try {
      // [1]. localhost:8080/authentications/{txnId}/challenge 로 챌린지 요청
      final challengeRes = await http.get(
          Uri.parse('$_baseUrl/authentications/${widget.txnId}/challenge'));
      if (challengeRes.statusCode != 200) throw Exception('챌린지 요청 실패');

      // [2]. public record ChallengeResponse(String challenge) {}에서 반환된 ChallengeResponse객체로 챌린지 받음.
      final Map<String, dynamic> challengeJson = jsonDecode(challengeRes.body);
      final String challenge = challengeJson['challenge'];

      // [3]. _auth.authenticate(얼굴인식,지문,핀 등)으로 개인 인증
      final didAuthenticate = await _auth.authenticate(
        localizedReason: '결제 진행을 위해 인증이 필요합니다.',
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (!didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증에 실패했습니다.')),
        );
        return;
      }
      final cardId = methods[selectedIndex]['cardId'];
      final signature = await signChallenge(challenge, cardId!);

      // [4]. localhost:8080/authentications/{txnId}/verify 로 시그니처검증 요청
      final cardType = methods[selectedIndex]['cardType']!;
      final cardNumber = methods[selectedIndex]['cardNumber']!;

      final body = jsonEncode({
        'signature': signature,
        'cardType': cardType,
        'cardNumber': cardNumber,
        'cardId': cardId
      });

      final verifyRes = await http.post(
        Uri.parse('$_baseUrl/authentications/${widget.txnId}/verify'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (verifyRes.statusCode != 200) throw Exception('서명 검증 실패');
      final Map<String, dynamic> verifyJson = jsonDecode(verifyRes.body);
      final bool verified = verifyJson['verified'];

      // 결과에 따른 처리 로직
      if (verified) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PaymentSuccessPage(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제 인증이 거부되었습니다.')),
        );
      }
    } catch (e) {
      debugPrint('결제 흐름 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('결제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(int.parse(widget.amount));

    const bgColor = Color(0xFFDCEAF6);
    const primaryColor = Color(0xFF0083CA);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '결제',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 23,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500, // 기본 weight
                ),
                children: [
                  TextSpan(
                    text: widget.merchantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // merchantName만 bold
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _controller,
              itemCount: methods.length,
              onPageChanged: (i) => setState(() => selectedIndex = i),
              itemBuilder: (ctx, i) {
                final m = methods[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Opacity(
                    opacity: i == selectedIndex ? 1.0 : 0.5,
                    child: PaymentMethodItem(
                      isSelected: i == selectedIndex,
                      backgroundColor: Colors.white,
                      onTap: () => _controller.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      imagePath: m['image']!,
                      cardImagePath: m['cardImage']!,
                      cardName: m['cardName']!,
                      cardNumber: m['cardNumber']!,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (v) => setState(() => isChecked = v ?? false),
                    fillColor: WidgetStateProperty.all(Colors.white),
                    checkColor: Colors.black,
                    side: WidgetStateBorderSide.resolveWith(
                        (_) => BorderSide(color: primaryColor, width: 2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '필수 결제 정보 확인 및 동의',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 결제 금액',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '₩$formattedAmount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0083CA),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.white;
                    }
                    return primaryColor;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return primaryColor;
                    }
                    return Colors.white;
                  }),
                  side: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return BorderSide(color: primaryColor, width: 2);
                    }
                    return null;
                  }),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: isChecked ? _onPayPressed : null,
                child: const Text(
                  '결제하기',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
