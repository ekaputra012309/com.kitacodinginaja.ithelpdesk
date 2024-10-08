import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../constans.dart';
import 'request_create.dart';
import 'widget/request_model.dart';
import 'widget/item_card.dart'; // Import your ItemCard widget

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
    _tabController.addListener(() {
      setState(() {});
    });
    _futureData = fetchpermintaan();
  }

  Future<List<DataItem>> fetchpermintaan() async {
    try {
      Response response = await _apiService.getRequest('/permintaan');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData.containsKey('data')) {
          final List<dynamic> items = responseData['data'];
          List<DataItem> dataItems = items
              .map((item) => DataItem.fromJson(item))
              .toList();
          return dataItems;
        } else {
          throw Exception(
              'Invalid response format or missing data key');
        }
      } else {
        debugPrint(
            'Failed to load data. Status code: ${response.statusCode}, Body: ${response.data}');
        throw Exception(
            'Failed to load data. Please try again later.');
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

  List<DataItem> filterItemsByMultipleStatuses(List<DataItem> items, List<String> statuses) {
    return items.where((item) => statuses.contains(item.status)).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView(
                        children: filterItemsByMultipleStatuses(items, ['Belum Proses', 'On Proses'])
                            .map((item) => ItemCard(
                                  key: ValueKey(item.id),
                                  item: item,
                                  scaffoldMessengerKey: _scaffoldMessengerKey,
                                  onDelete: _refreshData,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView(
                        children: filterItemsByMultipleStatuses(items, ['Pending'])
                            .map((item) => ItemCard(
                                  key: ValueKey(item.id),
                                  item: item,
                                  scaffoldMessengerKey: _scaffoldMessengerKey,
                                  onDelete: _refreshData,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView(
                        children: filterItemsByMultipleStatuses(items, ['Selesai'])
                            .map((item) => ItemCard(
                                  key: ValueKey(item.id),
                                  item: item,
                                  scaffoldMessengerKey: _scaffoldMessengerKey,
                                  onDelete: _refreshData,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
        
            }
          },
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestCreate(
                        scaffoldMessengerKey: _scaffoldMessengerKey,
                        onRequestAdded: () {
                          _refreshData();
                        },
                      ),
                    ),
                  );
                  setState(() {
                    _refreshData();
                  });
                },
                foregroundColor: CustomColors.putih,
                backgroundColor: CustomColors.second,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
