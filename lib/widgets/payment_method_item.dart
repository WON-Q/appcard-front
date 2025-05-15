import 'package:flutter/material.dart';

class PaymentMethodItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String imagePath;
  final String cardImagePath;
  final String cardName;
  final String cardNumber;
  final Color backgroundColor;

  const PaymentMethodItem({
    Key? key,
    required this.isSelected,
    required this.onTap,
    required this.imagePath,
    required this.cardImagePath,
    required this.cardName,
    required this.cardNumber,
    this.backgroundColor = const Color(0xFF212121),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. 은행로고 + 카드명 + 번호 (상단 중앙 정렬)
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(imagePath),
                    radius: 24,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(
                        cardName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. 카드 이미지
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 카드 이미지 (중앙 확대)
                  Expanded(
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          cardImagePath,
                          width: 250,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 3. 체크 아이콘 (우측 상단)
              if (isSelected)
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
