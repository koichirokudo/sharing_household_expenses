import 'package:flutter/material.dart';

class EmailEditPage extends StatefulWidget {
  const EmailEditPage({super.key});

  @override
  EmailEditPageState createState() => EmailEditPageState();
}

class EmailEditPageState extends State<EmailEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('メールアドレス変更'),
      ),
      body: Center(),
    );
  }
}
