import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../constans.dart';
import '../request_model.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  final int id;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Future<List<DataItem>> refreshData;

  const DeleteConfirmationDialog({super.key, 
    required this.id,
    required this.scaffoldMessengerKey,
    required this.refreshData,
  });

  @override
  _DeleteConfirmationDialogState createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  final ApiService _apiService = ApiService();
  
  Future<void> _delete(BuildContext context) async {
    try {
      final int id = widget.id;
      Response response = await _apiService.deleteRequest('/permintaan/$id');
      if (response.statusCode == 204) {
        setState(() {
          widget.refreshData;
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Permintaan deleted successfully'),
            ),
          );
        });
      } else {
        final String message = response.data['message'];
        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _delete(context);
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
