import 'package:flutter/material.dart';

class PaymentMethodItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String cardImagePath;

  const PaymentMethodItem({
    Key? key,
    required this.isSelected,
    required this.onTap,
    required this.cardImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 260, // 여기!
          height: 160,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                cardImagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
