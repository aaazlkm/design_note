import 'package:flutter/material.dart';

class ProcessingPage extends StatefulWidget {
  const ProcessingPage({Key? key}) : super(key: key);

  @override
  ProcessingPageState createState() => ProcessingPageState();
}

class ProcessingPageState extends State<ProcessingPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('empty page'),
        ),
      );
}
