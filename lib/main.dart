import 'package:crud_sqlite_flutter/containers/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        primarySwatch: Colors.cyan
      ),
      debugShowCheckedModeBanner: false,
      title: 'Flutter SQLite Demo',
      home: const HomePage(),
    );
  }
}


