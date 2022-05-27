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
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: _FacePile(
              users: [
                User(
                  useId: "id",
                  name: "name",
                  avatarUrl: "https://randomuser.me/api/portraits/women/31.jpg",
                ),
                User(
                  useId: "id",
                  name: "name",
                  avatarUrl: "https://randomuser.me/api/portraits/women/31.jpg",
                ),
                User(
                  useId: "id",
                  name: "name",
                  avatarUrl: "https://randomuser.me/api/portraits/women/31.jpg",
                ),
                User(
                  useId: "id",
                  name: "name",
                  avatarUrl: "https://randomuser.me/api/portraits/women/31.jpg",
                ),
              ],
            ),
          ),
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
  Widget build(BuildContext context) => SizedBox(
        height: faceSize,
        child: Stack(
          children: [
            ...users.mapIndexed(
              (index, element) => Positioned(
                left: index * (1 - overlapPercent) * faceSize,
                top: 0,
                height: faceSize,
                width: faceSize,
                child: AvatarCircle(
                  user: element,
                  nameLabelColor: const Color(0xFF222222),
                  backgroundColor: const Color(0xFF888888),
                ),
              ),
            )
          ],
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
