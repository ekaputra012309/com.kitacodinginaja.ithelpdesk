import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/screens/request/request_index.dart';
import 'package:provider/provider.dart';

import 'constans.dart';
import 'screens/auth/about.dart';
import 'screens/bottomnavbar.dart';
import 'screens/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userData');

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserDataProvider()..loadUserData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IT HELP DESK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColors.first),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Splashscreen(),
        '/dash': (context) => const Bottomnavbar(),
        '/about': (context) => const About(),
        '/request': (context) => const RequestIndex(),
      },
    );
  }
}
