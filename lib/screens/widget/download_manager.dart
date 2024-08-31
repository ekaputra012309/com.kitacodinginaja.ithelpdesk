import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:install_plugin/install_plugin.dart';
import 'dart:isolate';

class DownloadManager {
  DownloadManager() {
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      DownloadTaskStatus status = DownloadTaskStatus.values[data[1]];
      // Handle download completion and progress updates
      if (status == DownloadTaskStatus.complete) {
        _installApk(data[0]);
      }
    });

    FlutterDownloader.registerCallback(DownloadManager.downloadCallback);
  }

  static final ReceivePort _port = ReceivePort();

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<void> startDownload(String url, String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      // Handle the error if the directory is null
      debugPrint('Failed to get external storage directory');
      return;
    }

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory.path,
      fileName: fileName,
      showNotification: true, // Show download progress in status bar
      openFileFromNotification: true, // Click on notification to open downloaded file
    );
  }

  Future<void> _installApk(String taskId) async {
    final tasks = await FlutterDownloader.loadTasks();
    final task = tasks?.firstWhere((t) => t.taskId == taskId);
    if (task != null && task.status == DownloadTaskStatus.complete) {
      await InstallPlugin.installApk('${task.savedDir}/${task.filename!}', appId: 'com.kitacodinginaja.ithelpdesk');
    } else {
      throw Exception('Download task not found or not complete');
    }
  }

  Future<void> cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
  }

  Future<void> cancelAllDownloads() async {
    await FlutterDownloader.cancelAll();
  }

  Future<void> pauseDownload(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
  }

  Future<String?> resumeDownload(String taskId) async {
    return await FlutterDownloader.resume(taskId: taskId);
  }

  Future<String?> retryDownload(String taskId) async {
    return await FlutterDownloader.retry(taskId: taskId);
  }

  Future<void> removeDownload(String taskId, {bool shouldDeleteContent = false}) async {
    await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: shouldDeleteContent);
  }

  Future<void> openDownload(String taskId) async {
    await FlutterDownloader.open(taskId: taskId);
  }

  Future<List<DownloadTask>?> loadAllTasks() async {
    return await FlutterDownloader.loadTasks();
  }
}
