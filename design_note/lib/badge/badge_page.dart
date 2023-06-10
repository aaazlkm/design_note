import 'package:flutter/material.dart';

class BadgePage extends StatefulWidget {
  const BadgePage({Key? key}) : super(key: key);

  @override
  BadgePageState createState() => BadgePageState();
}

class BadgePageState extends State<BadgePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Badge(
            child: Text(
              'Pro',
              style: TextStyle().copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
}

class Badge extends StatelessWidget {
  const Badge({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              shadowColor: Colors.purple.shade900,
              elevation: 4,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.purple.withOpacity(0.9),
                    Colors.purple.withOpacity(0.8),
                    Colors.purple.withOpacity(0.5),
                    Colors.purple.withOpacity(0.8),
                    Colors.purple.withOpacity(0.9),
                  ],
                  stops: [
                    0,
                    0.1,
                    0.5,
                    0.9,
                    1.0,
                  ],
                  tileMode: TileMode.repeated,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: child,
          ),
        ],
      );
}
