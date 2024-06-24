import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import '../../constans.dart';
import 'request_model.dart';

class RequestIndex extends StatefulWidget {
  const RequestIndex({super.key});

  @override
  State<RequestIndex> createState() => _RequestIndexState();
}

class _RequestIndexState extends State<RequestIndex>
    with SingleTickerProviderStateMixin {
      final ApiService _apiService = ApiService();
      
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late TabController _tabController;
  late Future<List<DataItem>> _futureData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _futureData = fetchpermintaan();
  }

  Future<List<DataItem>> fetchpermintaan() async {
    try {
      Response response = await _apiService.getRequest('/permintaan');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Check if responseData is a Map and contains the 'data' key
        if (responseData is Map<String, dynamic> && responseData['success'] == true && responseData.containsKey('data')) {
          final List<dynamic> items = responseData['data'];

          // Check if 'items' is a List and contains valid data          
            List<DataItem> dataItems = items.map((item) => DataItem.fromJson(item)).toList();
            return dataItems;
        } else {
          throw Exception('Invalid response format or missing data key');
        }
      } else {
        debugPrint('Failed to load data. Status code: ${response.statusCode}, Body: ${response.data}');
        throw Exception('Failed to load data. Please try again later.');
      }
    } catch (e) {
      debugPrint('Error during fetchpermintaan: $e');
      throw Exception('Error during fetchpermintaan: $e');
    }
  }

   Future<void> _refreshData() async {
    setState(() {
      _futureData = fetchpermintaan();
    });
    await _futureData;
  }

  List<dynamic> _groupItemsByDate(List<DataItem> items) {
    // Group items by date
    Map<String, List<DataItem>> groupedItems = {};
    for (var item in items) {
      if (!groupedItems.containsKey(item.createdAt.substring(0, 10))) {
        groupedItems[item.createdAt.substring(0, 10)] = [];
      }
      groupedItems[item.createdAt.substring(0, 10)]!.add(item);
    }

    // Flatten the grouped items into a single list with date headers
    List<dynamic> timelineItems = [];
    groupedItems.forEach((date, items) {
      timelineItems.add(date);
      timelineItems.addAll(items);
    });

    return timelineItems;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Request User'),
        backgroundColor: CustomColors.putih,
        foregroundColor: CustomColors.second,
        bottom: TabBar(
          controller: _tabController,
          labelColor: CustomColors.second,
          unselectedLabelColor: CustomColors.hitam,
          tabs: const [
            Tab(icon: Icon(Icons.work), text: 'Proses'),
            Tab(icon: Icon(Icons.pending), text: 'Hold'),
            Tab(icon: Icon(Icons.check_circle), text: 'Finish'),
          ],
        ),
      ),
      body: FutureBuilder<List<DataItem>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            List<DataItem> items = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: TimelineWidget(
                    items: _groupItemsByDate(
                      items.where((item) =>
                          item.status == 'On Proses' ||
                          item.status == 'Belum Proses').toList()),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: TimelineWidget(
                    items: _groupItemsByDate(
                      items.where((item) => item.status == 'Pending').toList()),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: TimelineWidget(
                    items: _groupItemsByDate(
                      items.where((item) => item.status == 'Selesai').toList()),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                // Add action for FloatingActionButton
              },
              foregroundColor: CustomColors.putih,
              backgroundColor: CustomColors.second,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class TimelineWidget extends StatelessWidget {
  final List<dynamic> items;

  const TimelineWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FixedTimeline.tileBuilder(
          builder: TimelineTileBuilder.connected(
            contentsAlign: ContentsAlign.basic, // Align the contents to the left
            nodePositionBuilder: (context, index) => 0.0, // Align the node (line) to the left
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
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('by ${item.pelapor}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.zero,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {},
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
                                item.kategori?.hashtag ?? 'No hashtags',
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
                                item.lokasi?.locationName ?? 'Unknown location',
                                style: const TextStyle(fontSize: 12.0),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1.0, color: CustomColors.abu.withOpacity(0.2)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item.kendala,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            if (item.keterangan != '') // Conditionally display keterangan if it exists
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Hold:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (item.keterangan != '') // Conditionally display keterangan if it exists
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

                      // Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(getStatusColor(item.status)),
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                minimumSize: WidgetStateProperty.all<Size>(const Size(36, 30)), // Set the desired width and height
                                padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 8.0)), // Optional: Adjust padding for the button
                              ),
                              icon: const Icon(Icons.check, size: 16), // Check icon
                              label: Text(
                                item.status,
                                style: const TextStyle(fontSize: 12.0),
                              ),
                              onPressed: () {},
                            ),
                            Text('PIC: ${item.user.name}'),
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
