import 'package:flutter/material.dart';

import 'christmasTree/ChristmasTreePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ChristmasTreePage(),
      );
}

class TemplatePage extends StatefulWidget {
  const TemplatePage({Key? key}) : super(key: key);

  @override
  TemplatePageState createState() => TemplatePageState();
}

class TemplatePageState extends State<TemplatePage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('empty page'),
        ),
      );
}
