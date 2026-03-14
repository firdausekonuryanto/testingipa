import 'package:flutter/material.dart';

class SlidePageRoute extends StatelessWidget {
  const SlidePageRoute();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/index-dynamic-forms');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
