import 'dart:convert';

import 'package:app_card_front/utils/KeyManager.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/secure_storage_util.dart';
import '../widgets/jumping_dots.dart';

import 'payment_success_page.dart';

class PaymentPage extends StatefulWidget {
  final String txnId;
  final String merchantName;
  final String amount;
  final String callbackUrl;

  const PaymentPage({
    Key? key,
    required this.txnId,
    required this.merchantName,
    required this.amount,
    required this.callbackUrl,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  final _keyMgr = KeyManager();
  static const _baseUrl = 'http://192.168.0.168:8084';

  bool _showDots = false;
  int selectedIndex = 0;
  final PageController _controller = PageController(viewportFraction: 0.6);

  final List<Map<String, String>> methods = [
    {
      'cardId': 'APP_CARD_001',
      'cardType': 'CREDIT',
      'cardImage': 'assets/images/woori_card_vip.png',
      'cardName': '카드의정석 EVERY POINT',
      'cardNumber': '1234567890123456',
    },
    {
      'cardId': 'APP_CARD_002',
      'cardType': 'DEBIT',
      'cardImage': 'assets/images/woori_card_general.png',
      'cardName': 'D4카드의정석Ⅱ',
      'cardNumber': '9490941540594021',
    },
    {
      'cardId': 'APP_CARD_003',
      'cardType': 'DEBIT',
      'cardImage': 'assets/images/woori_card_kpass.png',
      'cardName': 'K-패스 우리카드',
      'cardNumber': '1010010309659217',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAllKeysOnce();
  }

  Future<void> _initializeAllKeysOnce() async {
    await SecureStorageUtil.clear();
    for (final m in methods) {
      await _keyMgr.generateAndStoreKeyPair(m['cardId']!);
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
      final challengeRes = await http.get(
        Uri.parse('$_baseUrl/authentications/${widget.txnId}/challenge'),
      );
      if (challengeRes.statusCode != 200) throw Exception('챌린지 요청 실패');

      final challengeJson = jsonDecode(challengeRes.body);
      final challenge = challengeJson['challenge'] as String;

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
      setState(() {
        _showDots = true;
      });

      final cardId = methods[selectedIndex]['cardId']!;
      final signature = await signChallenge(challenge, cardId);

      final body = jsonEncode({
        'signature': signature,
        'cardType': methods[selectedIndex]['cardType']!,
        'cardNumber': methods[selectedIndex]['cardNumber']!,
        'cardId': cardId,
      });

      final verifyRes = await http.post(
        Uri.parse('$_baseUrl/authentications/${widget.txnId}/verify'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (verifyRes.statusCode != 200) throw Exception('서명 검증 실패');

      final verifyJson = jsonDecode(verifyRes.body);
      final verified = verifyJson['verified'] as bool;

      if (verified) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
              txnId: widget.txnId,
              callbackUrl: widget.callbackUrl,
              cardImage: methods[selectedIndex]['cardImage']!,
              amount: widget.amount,
              merchantName: widget.merchantName,
            ),
          ),
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
    } finally {
      setState(() {
        _showDots = false;
      });
    }
  }

  String _maskCardNumber(String number) {
    if (number.length < 8) return number;
    final first = number.substring(0, 4);
    final last = number.substring(number.length - 4);
    final middle = List.filled(number.length - 8, '*').join();
    return '$first$middle$last'.replaceAllMapped(
      RegExp(r'.{4}'),
      (m) => '${m.group(0)} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayNumber =
        _maskCardNumber(methods[selectedIndex]['cardNumber']!);
    final formattedAmount =
        NumberFormat('#,###').format(int.parse(widget.amount));

    const bgColor = Color(0xFFDCEAF6);
    const primaryColor = Color(0xFF0083CA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '원큐PAY',
          style: TextStyle(
            fontFamily: 'WooridaumB',
            color: Colors.black,
            //fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
              right: 160,
              bottom: 25,
              child: Image.asset(
                'assets/images/woori_wibe.png',
                width: 80,
              )),
          Column(
            children: [
              const SizedBox(height: 30),
              // 카드명·번호
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      methods[selectedIndex]['cardName']!,
                      style: const TextStyle(
                          fontFamily: 'WooridaumB',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayNumber,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 카드 리스트
              SizedBox(
                width: 550,
                height: 180,
                child: PageView.builder(
                  controller: _controller,
                  clipBehavior: Clip.none,
                  itemCount: methods.length,
                  onPageChanged: (i) => setState(() => selectedIndex = i),
                  itemBuilder: (ctx, i) {
                    final isSel = i == selectedIndex;
                    final cardImg = methods[i]['cardImage']!;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Transform.scale(
                          scale: isSel ? 1.1 : 0.9,
                          child: Opacity(
                            opacity: isSel ? 1 : 0.5,
                            child: GestureDetector(
                              onTap: () => _controller.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              child: Container(
                                width: 265,
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                      spreadRadius: -6,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    cardImg,
                                    //fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
              // 총 결제 금액
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      // 상단-좌측 하이라이트
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        offset: const Offset(-4, -4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      // 하단-우측 그림자
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '결제 가맹점',
                        style: TextStyle(
                            fontFamily: 'WooridaumB',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.merchantName}',
                        style: const TextStyle(
                            fontFamily: 'WooridaumR',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 총 결제 금액
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      // 상단-좌측 하이라이트
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        offset: const Offset(-4, -4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      // 하단-우측 그림자
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 결제 금액',
                        style: TextStyle(
                            fontFamily: 'WooridaumB',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${formattedAmount} 원',
                        style: const TextStyle(
                            fontFamily: 'WooridaumR',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
              // 결제 버튼
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 25, top: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onPayPressed,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(primaryColor),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    child: _showDots
                        ? const JumpingDots(size: 8, dots: 4)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8), // 모서리 반경 8px
                                child: Image.asset(
                                  'assets/icons/app_icon.png',
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                '원큐PAY',
                                style: TextStyle(
                                    fontFamily: 'WooridaumB',
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '|',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '결제하기',
                                style: TextStyle(
                                  fontFamily: 'WooridaumB',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
