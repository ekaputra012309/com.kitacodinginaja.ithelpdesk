import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final ReceivePort _port = ReceivePort();

  DownloadService() {
    _initialize();
  }

  Future<void> _initialize() async {
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((message) {
      final String id = message[0];
      final DownloadTaskStatus status = DownloadTaskStatus.values[message[1]];
      final int progress = message[2];
      // No need to handle notifications here since FlutterDownloader takes care of it
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<void> startDownload(String url, String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception("Failed to get external storage directory");
    }
    final saveDir = directory.path;

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: saveDir,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
}
