import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import '../../../constans.dart';
import '../request_model.dart';
import 'delete_widget.dart';

class TimelineWidget extends StatelessWidget {
  final List<dynamic> items;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final Future<List<DataItem>> refreshData;

  TimelineWidget({super.key, required this.items, required, required this.refreshData });

  void _showDeleteConfirmationDialog(BuildContext context, {required int id}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return DeleteConfirmationDialog(
        id: id,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        refreshData: refreshData,
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FixedTimeline.tileBuilder(
          builder: TimelineTileBuilder.connected(
            contentsAlign:
                ContentsAlign.basic, // Align the contents to the left
            nodePositionBuilder: (context, index) =>
                0.0, // Align the node (line) to the left
            connectorBuilder: (context, index, type) {
              return const SolidLineConnector(
                color: CustomColors.first,
              );
            },
            indicatorBuilder: (context, index) {
              return const DotIndicator(
                color: CustomColors.second,
              );
            },
            itemCount: items.length,
            contentsBuilder: (context, index) {
              final item = items[index];
              if (item is String) {
                // Date header
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              } else if (item is DataItem) {
                // Data card
                return Card(
                  color: CustomColors.putih,
                  margin: const EdgeInsets.all(8.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('by ${item.pelapor}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
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
                                            leading: const Icon(Icons.delete, color: Colors.redAccent,),
                                            title: const Text('Delete'),
                                            trailing: Text('${item.id}'),
                                            onTap: () {
                                               Navigator.of(context).pop();
                                              _showDeleteConfirmationDialog(context, id: item.id);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.edit, color: Colors.lightBlueAccent,),
                                            title: const Text('Edit'),
                                            trailing: Text('${item.id}'),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          const Divider(height: 1.0,),
                                          ListTile(
                                            leading: const Icon(Icons.rotate_right_rounded, color: Colors.blueAccent,),
                                            title: const Text('Proses'),
                                            trailing: Text('${item.id}'),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent,),
                                            title: const Text('Pending'),
                                            trailing: Text('${item.id}'),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.check_circle_rounded, color: Colors.teal,),
                                            title: const Text('Selesai'),
                                            trailing: Text('${item.id}'),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    });
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
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.blueGrey),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.white),
                                minimumSize: WidgetStateProperty.all<Size>(
                                    const Size(40, 28)),
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 8.0)),
                              ),
                              icon: const Icon(Icons.tag, size: 12),
                              label: Text(
                                item.kategori?.hashtag ?? 'No hashtags',
                                style: const TextStyle(fontSize: 12.0),
                              ),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8.0),
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.blueGrey),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.white),
                                minimumSize: WidgetStateProperty.all<Size>(
                                    const Size(40, 28)),
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 8.0)),
                              ),
                              icon: const Icon(Icons.location_pin, size: 12),
                              label: Text(
                                item.lokasi?.locationName ?? 'Unknown location',
                                style: const TextStyle(fontSize: 12.0),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      Divider(
                          height: 1.0,
                          color: CustomColors.abu.withOpacity(0.2)),
                      // Body
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item.kendala,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            if (item.keterangan !=
                                '') // Conditionally display keterangan if it exists
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Hold:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (item.keterangan !=
                                '') // Conditionally display keterangan if it exists
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  item.solusi ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    getStatusColor(item.status)),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.white),
                                minimumSize: WidgetStateProperty.all<Size>(
                                    const Size(36,
                                        30)), // Set the desired width and height
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(
                                        horizontal:
                                            8.0)), // Optional: Adjust padding for the button
                              ), // Check icon
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
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

// This function returns the color based on the status of the item.
Color getStatusColor(String status) {
  switch (status) {
    case 'Selesai':
      return Colors.teal;
    case 'On Proses':
      return Colors.blueAccent;
    case 'Pending':
      return Colors.redAccent;
    case 'Belum Proses':
      return Colors.grey;
    default:
      return Colors.grey; // Default color for unknown status
  }
}