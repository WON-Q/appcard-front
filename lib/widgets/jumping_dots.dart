import 'package:flutter/material.dart';

class JumpingDots extends StatefulWidget {
  const JumpingDots({
    super.key,
    required this.size,
    required this.dots,
  });

  final double size; // 점 크기
  final int dots; // 점 갯수

  @override
  State<JumpingDots> createState() => _JumpingDotsState();
}

class _JumpingDotsState extends State<JumpingDots>
    with TickerProviderStateMixin {
  // 각 점마다 애니메이션을 주기 위해 List로 선언했다.
  // 위젯이 생성될 때 애니메이션을 적용하기 위함.
  late List<AnimationController> animationControllers;
  late List<Animation<double>> animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void dispose() {
    // 위젯이 페이지에서 사라질 때, 모든 점들의 애니메이션도 dispsoe해줘야 한다.
    for (var controller in animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initAnimations() {
    // 리스트 생성으로 애니메이션 컨트롤러 등록.
    animationControllers = List.generate(
      widget.dots,
      (index) {
        return AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        );
      },
    );

    // 생성된 컨트롤러에 애니메이션 적용.
    animations = List.generate(
      widget.dots,
      (index) {
        // begin, end가 변할 범위이다.
        return Tween<double>(begin: 0, end: 5).animate(
          CurvedAnimation(
            parent: animationControllers[index],
            curve: Curves.easeInOut,
          ),
        );
      },
    );

    // 애니메이션에 딜레이를 줘서 차례대로? 움직이게 하기.
    for (int i = 0; i < animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i)).then((_) {
        animationControllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(animationControllers.length, (index) {
        // 애니메이션 빌더를 이용해야 한다.
        return AnimatedBuilder(
          animation: animations[index],
          builder: (context, child) {
            // Transform 위젯으로 y 값을 변화시킨다.
            return Transform.translate(
              offset: Offset(0, animations[index].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: widget.size,
                width: widget.size,
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
