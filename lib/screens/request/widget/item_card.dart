import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../constans.dart';
import '../request_model.dart';

class ItemCard extends StatelessWidget {
  final DataItem item;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final VoidCallback onDelete;

  const ItemCard({
    super.key, 
    required this.item, 
    required this.scaffoldMessengerKey,
    required this.onDelete
    });

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'On Proses':
        return Colors.blue;
      case 'Selesai':
        return CustomColors.first;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, {required int id}) {
    final ApiService apiService = ApiService();

    Future<void> delete(BuildContext context) async {
      try {
        Response response = await apiService.deleteRequest('/permintaan/$id');
        if (response.statusCode == 204) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Permintaan deleted successfully'),
            ),
          );
          onDelete();
        } else {
          final String message = response.data['message'];
          scaffoldMessengerKey.currentState?.showSnackBar(
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
              delete(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.putih,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('by ${item.pelapor}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  margin: EdgeInsets.zero,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: CustomColors.putih,
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.redAccent),
                                title: const Text('Delete'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _showDeleteConfirmationDialog(context, id: item.id);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.edit, color: Colors.lightBlueAccent),
                                title: const Text('Edit'),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const Divider(height: 1.0),
                              ListTile(
                                leading: const Icon(Icons.rotate_right_rounded, color: Colors.blueAccent),
                                title: const Text('Proses'),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent),
                                title: const Text('Pending'),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.check_circle_rounded, color: Colors.teal),
                                title: const Text('Selesai'),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.more_vert),
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
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.blueGrey),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    minimumSize: WidgetStateProperty.all<Size>(const Size(40, 28)),
                    padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 8.0)),
                  ),
                  icon: const Icon(Icons.tag, size: 12),
                  label: Text(
                    item.kategori!.categoryName,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8.0),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.blueGrey),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    minimumSize: WidgetStateProperty.all<Size>(const Size(40, 28)),
                    padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 8.0)),
                  ),
                  icon: const Icon(Icons.location_pin, size: 12),
                  label: Text(
                    item.lokasi!.locationName,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Divider(height: 1.0, color: CustomColors.abu.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
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
                    padding: EdgeInsets.all(8.0),
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
                    padding: EdgeInsets.all(8.0),
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
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(getStatusColor(item.status)),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    minimumSize: WidgetStateProperty.all<Size>(const Size(36, 30)),
                    padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 8.0)),
                  ),
                  label: Text(
                    item.status,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                  onPressed: () {},
                ),
                Text('PIC: ${item.userName ?? ''}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
