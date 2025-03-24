import 'package:flutter/material.dart';
import 'package:tracking_practice/core/init/app_init.dart';
import 'package:tracking_practice/core/init/state_initializer.dart';
import 'package:tracking_practice/screens/main_page.dart';

Future<void> main() async {
  ApplicationInitializer().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateInitializer(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Location Tracking',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MainPage(),
      ),
    );
  }
}
