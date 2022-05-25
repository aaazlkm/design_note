import 'package:flutter/material.dart';

class FacePilePage extends StatefulWidget {
  const FacePilePage({Key? key}) : super(key: key);

  @override
  FacePilePageState createState() => FacePilePageState();
}

class FacePilePageState extends State<FacePilePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: AvatarCircle(
            user: User(
              useId: "id",
              name: "name",
              avatarUrl: "",
            ),
            nameLabelColor: Color(0xFF222222),
            backgroundColor: Color(0xFF888888),
          ),
        ),
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
