import 'package:flutter/material.dart';

import 'common/showcase_config.dart';
import 'common/showcase_scaffold.dart';

class ShowcaseTweenSequence extends StatelessWidget {
  const ShowcaseTweenSequence({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ShowcaseConfig.of(context);

    return ShowcaseScaffold(
      onRun: null,
      child: LovedWords(
        duration: config.duration,
      ),
    );
  }
}

class LovedWords extends StatefulWidget {
  final Duration duration;

  const LovedWords({Key? key, required this.duration}) : super(key: key);

  @override
  State<LovedWords> createState() => _LovedWordsState();
}

class _LovedWordsState extends State<LovedWords>
    with SingleTickerProviderStateMixin {
  final strings = <String>['Будь счастлив!', 'Улыбайся!', '❤️'];

  /// index отображаемой строки
  int stringIndex = 0;

  /// служит для того, чтобы переключать на следующий текст,
  /// если анимация выполняется заново
  double max = 0.0;

  late final AnimationController controller;
  late final Animation<Offset> animationSlide;
  late final Animation<double> animationFade;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);

    /// Здесь следим за значением контроллера
    /// Если начался новый цикл, то мы просто переключаемся на другое слово
    controller.addListener(() {
      if (controller.value >= max) {
        max = controller.value;
      } else {
        stringIndex = (stringIndex + 1) % strings.length;
        max = 0.0;
        setState(() {});
      }
    });

    animationSlide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(const Offset(0.0, 0.0)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0.0, 0.0),
          end: const Offset(-1.0, 0.0),
        ),
        weight: 20,
      ),
    ]).animate(controller);

    animationFade = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ),
        weight: 20,
      ),
    ]).animate(controller);

    setDuration(widget.duration);
  }

  @override
  void didUpdateWidget(covariant LovedWords oldWidget) {
    super.didUpdateWidget(oldWidget);
    setDuration(widget.duration);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: animationFade,
        child: SlideTransition(
          position: animationSlide,
          child: Text(
            strings[stringIndex],
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void setDuration(Duration duration) {
    if (controller.duration != duration) {
      controller.duration = duration;
      if (duration > Duration.zero) {
        controller.repeat();
      } else {
        controller.reset();
      }
    }
  }
}
