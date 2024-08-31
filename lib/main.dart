import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'constans.dart';
import 'screens/auth/about.dart';
import 'screens/auth/login.dart';
import 'screens/berita/berita_index.dart';
import 'screens/home.dart';
import 'screens/request/request_index.dart';
import 'screens/routenavbar.dart';
import 'screens/splashscreen.dart';
import 'screens/surat/surat_index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userData');
  await _initializeFlutterDownloader();
  await _requestPermissions();

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserDataProvider()..loadUserData(),
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeFlutterDownloader() async {
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );
}

Future<void> _requestPermissions() async {
  // Request notification permission
  PermissionStatus notificationStatus = await Permission.notification.request();
  if (notificationStatus != PermissionStatus.granted) {
    _showSettingsDialog('Notification');
  }

  // Determine the appropriate storage permission based on the Android version
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  int sdkInt = androidInfo.version.sdkInt;

  if (sdkInt >= 33) { // Android 13 and above
    PermissionStatus storageStatus = await Permission.manageExternalStorage.request();
    if (storageStatus != PermissionStatus.granted) {
      _showSettingsDialog('Manage External Storage');
    }
  } else {
    PermissionStatus storageStatus = await Permission.storage.request();
    if (storageStatus != PermissionStatus.granted) {
      _showSettingsDialog('Storage');
    }
  }
}

void _showSettingsDialog(String permission) async {
  // Show dialog to guide user to settings
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Permission Required')),
      body: Center(
        child: AlertDialog(
          title: Text('$permission Permission Required'),
          content: Text(
              'This app needs $permission permission to function properly. Please grant the permission in the app settings.'),
          actions: [
            TextButton(
              onPressed: () async {
                // Open app settings
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/dash': (context) => const Routenavbar(),
        '/about': (context) => const About(),
        '/request': (context) => const RequestIndex(),
        '/news': (context) => const BeritaIndex(),
        '/letter': (context) => const SuratIndex(),
        '/home': (context) => const Home(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
