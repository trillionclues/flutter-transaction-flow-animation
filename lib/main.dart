import 'package:elastice_cubic_payment_confirmation_screen/pages/animated_transaction_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transaction Animation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: const AnimatedTransactionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
