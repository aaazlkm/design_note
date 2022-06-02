import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class FacePilePage extends StatefulWidget {
  const FacePilePage({Key? key}) : super(key: key);

  @override
  FacePilePageState createState() => FacePilePageState();
}

class FacePilePageState extends State<FacePilePage> {
  final List<User> users = [];

  void onAddTapped() {
    setState(() {
      users.add(generateUser());
    });
  }

  void onDeleteTapped() {
    setState(() {
      if (users.isEmpty) {
        return;
      }
      final randomIndex = Random().nextInt(users.length);
      users.removeAt(randomIndex);
    });
  }

  User generateUser() => User(
        useId: "${Random().nextInt(100000)}",
        name: "name",
        avatarUrl: "https://randomuser.me/api/portraits/women/31.jpg",
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: _FacePile(
              users: users,
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: onDeleteTapped,
              child: const Icon(Icons.close),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: onAddTapped,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      );
}

class _FacePile extends StatelessWidget {
  const _FacePile({
    required this.users,
    this.faceSize = 48.0,
    this.overlapPercent = 0.1,
    Key? key,
  }) : super(key: key);

  final List<User> users;
  final double faceSize;
  final double overlapPercent;

  /// TODO clip系の処理
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        var faceVisiblePercent = 1 - overlapPercent;
        var intrinsicWidth = users.length == 1 ? faceSize : (faceVisiblePercent * (users.length - 1) + 1) * faceSize;
        if (constraints.maxWidth < intrinsicWidth) {
          // (faceVisible * faceSize) * (length - 1) + faceSize = maxWidth
          faceVisiblePercent = (constraints.maxWidth - faceSize) / ((users.length - 1) * faceSize);
          intrinsicWidth = constraints.maxWidth;
        }

        late final double leftOffset;
        if (intrinsicWidth > constraints.maxWidth) {
          leftOffset = 0;
        } else {
          leftOffset = (constraints.maxWidth - intrinsicWidth) / 2;
        }

        return SizedBox(
          height: faceSize,
          child: Stack(
            children: [
              ...users.mapIndexed(
                (index, element) => AnimatedPositioned(
                  key: ValueKey(element.useId),
                  left: index * faceVisiblePercent * faceSize + leftOffset,
                  top: 0,
                  height: faceSize,
                  width: faceSize,
                  duration: const Duration(milliseconds: 100),
                  child: AnimatedScaleInOut(
                    show: true,
                    onDismissed: () {},
                    child: AvatarCircle(
                      user: element,
                      nameLabelColor: const Color(0xFF222222),
                      backgroundColor: const Color(0xFF888888),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      });
}

class AnimatedScaleInOut extends StatefulWidget {
  const AnimatedScaleInOut({
    required this.show,
    required this.onDismissed,
    required this.child,
    Key? key,
  }) : super(key: key);

  final bool show;
  final VoidCallback onDismissed;
  final Widget child;

  @override
  State<AnimatedScaleInOut> createState() => _AnimatedScaleInOutState();
}

class _AnimatedScaleInOutState extends State<AnimatedScaleInOut> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 100))
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          widget.onDismissed();
        }
      });
    scaleAnimation = CurvedAnimation(parent: animationController, curve: Curves.elasticOut);
    syncScaleAnimationWithWidget();
  }

  @override
  void didUpdateWidget(AnimatedScaleInOut oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncScaleAnimationWithWidget();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void syncScaleAnimationWithWidget() {
    if (widget.show && !animationController.isAnimating) {
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animationController,
        builder: (context, child) => Transform.scale(
          scale: scaleAnimation.value,
        ),
        child: widget.child,
      );
}

class AvatarCircle extends StatefulWidget {
  const AvatarCircle({
    required this.user,
    required this.nameLabelColor,
    required this.backgroundColor,
    this.size = 48.0,
    Key? key,
  }) : super(key: key);

  final User user;
  final double size;
  final Color nameLabelColor;
  final Color backgroundColor;

  @override
  State<AvatarCircle> createState() => _AvatarCircleState();
}

class _AvatarCircleState extends State<AvatarCircle> {
  @override
  Widget build(BuildContext context) => Container(
        width: widget.size,
        height: widget.size,
        // TODO antiAlias何？
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 3,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Text(
              widget.user.name,
              style: const TextStyle().copyWith(
                color: widget.nameLabelColor,
              ),
            ),
            FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: widget.user.avatarUrl,
            ),
          ],
        ),
      );
}

class User {
  User({
    required this.useId,
    required this.name,
    required this.avatarUrl,
  });

  final String useId;
  final String name;
  final String avatarUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          useId == other.useId &&
          name == other.name &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => useId.hashCode ^ name.hashCode ^ avatarUrl.hashCode;

  @override
  String toString() => 'User{useId: $useId, name: $name, avatorUrl: $avatarUrl}';
}
