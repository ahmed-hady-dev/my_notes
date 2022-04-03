import 'package:flutter/material.dart';

class NewNoteView extends StatelessWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('New Note')),
        body: Center(
          child: Text('NewNoteView'),
        ),
      ),
    );
  }
}
