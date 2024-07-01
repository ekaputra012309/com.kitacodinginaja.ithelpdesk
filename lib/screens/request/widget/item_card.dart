import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../constans.dart';
import '../request_edit.dart';
import 'request_model.dart';

class ItemCard extends StatelessWidget {
  final DataItem item;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.scaffoldMessengerKey,
    required this.onDelete,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.redAccent;
      case 'On Proses':
        return Colors.blue;
      case 'Selesai':
        return CustomColors.first;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(dateTime);
  }

  String formatTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat timeFormatter = DateFormat('HH:mm');
    return timeFormatter.format(dateTime);
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    final ApiService apiService = ApiService();
    final String id = item.id.toString();

    if (status == 'proses') {
      try {
        final response = await apiService.putRequest('/permintaan/$id/status/$status', {});

        if (response.statusCode == 200) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Status updated successfully'),
            ),
          );
          onDelete();
        } else {
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Failed to update status'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error updating status: $e');
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error updating status'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      String? inputText;
      String hintText = '';
      String label = '';

      if (status == 'pending') {
        hintText = 'Enter keterangan';
        label = 'Keterangan';
      } else if (status == 'selesai') {
        hintText = 'Enter solusi';
        label = 'Solusi';
      }

      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      TextEditingController textController = TextEditingController();

      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: CustomColors.putih,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  const SizedBox(height: 4.0),
                  TextFormField(
                    controller: textController,
                    onChanged: (text) {
                      inputText = text;
                    },
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(CustomColors.second),
                      foregroundColor: WidgetStateProperty.all<Color>(CustomColors.putih),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        final response = await apiService.putRequest('/permintaan/$id/status/$status', {
                          if (status == 'pending') 'keterangan': inputText,
                          if (status == 'selesai') 'solusi': inputText,
                        });

                        if (response.statusCode == 200) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text('Status updated successfully'),
                            ),
                          );
                          onDelete();
                        } else {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update status'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error updating status: $e');
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text('Error updating status'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }


  void _showDeleteConfirmationDialog(BuildContext context) {

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
              _deleteRequest(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRequest(BuildContext context) async {
    final ApiService apiService = ApiService();
    final String id = item.id.toString();

    try {
      final response = await apiService.deleteRequest('/permintaan/$id');

      if (response.statusCode == 204) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Permintaan deleted successfully'),
            backgroundColor: Colors.redAccent,
          ),
        );
        onDelete();
      } else {
        final String message = response.data['message'];
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during delete: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Error deleting permintaan'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildActionTiles(String currentStatus, BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userRole = userDataProvider.role;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (userRole == 'User') ...[
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.lightBlueAccent),
              title: const Text('Edit'),
              onTap: () async {
                await Navigator.push(
                  context,
                   MaterialPageRoute(
                    builder: (context) => RequestEdit(
                      item: item, // Pass the required item data
                      scaffoldMessengerKey: scaffoldMessengerKey, // Pass the scaffoldMessengerKey if needed
                      onRequestUpdated: () {
                        onDelete();
                      },
                    ),
                   ),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context); // Implement _showDeleteConfirmationDialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.lightBlueAccent),
              title: const Text('Edit'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestEdit(
                      item: item, // Pass the required item data
                      scaffoldMessengerKey: scaffoldMessengerKey, // Pass the scaffoldMessengerKey if needed
                      onRequestUpdated: () {
                        onDelete();
                      },
                    ),
                   ),
                );
              },
            ),
            const Divider(height: 1.0),
            ListTile(
              leading: const Icon(Icons.rotate_right_rounded, color: Colors.blueAccent),
              title: const Text('Proses'),
              onTap: currentStatus != 'Pending' && currentStatus != 'Selesai' && currentStatus != 'On Proses'
                  ? () {
                      Navigator.pop(context);
                      _updateStatus(context, 'proses'); // Implement _updateStatus
                    }
                  : null,
              enabled: currentStatus != 'Pending' && currentStatus != 'Selesai' && currentStatus != 'On Proses',
            ),
            ListTile(
              leading: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent),
              title: const Text('Pending'),
              onTap: currentStatus != 'Pending' && currentStatus != 'Selesai'
                  ? () {
                      Navigator.pop(context);
                      _updateStatus(context, 'pending'); // Implement _updateStatus
                    }
                  : null,
              enabled: currentStatus != 'Pending' && currentStatus != 'Selesai',
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_rounded, color: Colors.teal),
              title: const Text('Selesai'),
              onTap: currentStatus != 'Selesai'
                  ? () {
                      Navigator.pop(context);
                      _updateStatus(context, 'selesai'); // Implement _updateStatus
                    }
                  : null,
              enabled: currentStatus != 'Selesai',
            ),
          ],
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: CustomColors.putih,
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('by ${item.pelapor}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: _buildActionTiles(item.status, context),                          
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(formatDate(item.createdAtFormated), style: const TextStyle(fontSize: 12.0),),
                                const SizedBox(width: 4.0),
                                const Icon(Icons.calendar_month_rounded, size: 12.0),
                              ],
                            ),
                            Row(
                              children: [
                                Text(formatTime(item.createdAtFormated), style: const TextStyle(fontSize: 12.0),),
                                const SizedBox(width: 4.0),
                                const Icon(Icons.access_time_filled_rounded, size: 12.0),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.more_vert, size: 28.0,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.tag, size: 10, color: Colors.white),
                        const SizedBox(width: 4.0),
                        Text(
                          item.kategori!.hashtag,
                          style: const TextStyle(fontSize: 10.0, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_pin, size: 10, color: Colors.white),
                        const SizedBox(width: 4.0),
                        Text(
                          item.lokasi!.locationName,
                          style: const TextStyle(fontSize: 10.0, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 1.0, color: CustomColors.hitam.withOpacity(0.2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text(
                      'Problem:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      item.kendala,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (item.keterangan != '')
                    const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Text(
                        'Hold:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (item.keterangan != '')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        item.keterangan ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  if (item.solusi != '')
                    const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Text(
                        'Solved:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (item.solusi != '')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        item.solusi ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: getStatusColor(item.status),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      item.status,
                      style: const TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      const Text('PIC: ', style: TextStyle(fontSize: 12.0),),
                      Text(item.userName ?? '', style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
