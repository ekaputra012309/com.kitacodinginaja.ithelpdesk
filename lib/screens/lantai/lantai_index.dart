import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../screens/lantai/lantai_edit.dart';
import '../../screens/lantai/lantai_create.dart';
import '../../constans.dart';

class Lantaiindex extends StatefulWidget {
  const Lantaiindex({super.key});

  @override
  State<Lantaiindex> createState() => _LantaiindexState();
}

class _LantaiindexState extends State<Lantaiindex> {
  final ApiService _apiService = ApiService();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _setStatusBarColor();
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: CustomColors.second,
    ));
  }

  Future<List<Map<String, dynamic>>> fetchLantai() async {
    try {
      Response response = await _apiService.getRequest('/lantai');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['success'] == true &&
            responseData.containsKey('data')) {
          final List<dynamic> items = responseData['data'];
          return items.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Failed to load data: Invalid response format');
        }
      } else {
        debugPrint(
            'Failed to load data. Status code: ${response.statusCode}, Body: ${response.data}');
        throw Exception('Failed to load data. Please try again later.');
      }
    } catch (e) {
      debugPrint('Error during fetchLantai: $e');
      throw Exception('Error during fetchLantai: $e');
    }
  }

  Future<void> _delete(BuildContext context, {required idValue}) async {
    try {
      final int id = idValue;
      Response response = await _apiService.deleteRequest('/lantai/$id');
      if (response.statusCode == 204) {
        setState(() {
          fetchLantai();
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Lantai deleted successfully'),
            ),
          );
        });
      } else {
        final String message = response.data['message'];
        _scaffoldMessengerKey.currentState?.showSnackBar(
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

  Future<void> _showDeleteConfirmationDialog(BuildContext context,
      {required id}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                _delete(context, idValue: id);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lantai'),
          backgroundColor: CustomColors.second,
          foregroundColor: Colors.white,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await fetchLantai();
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchLantai(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Tidak ada data'),
                );
              } else {
                final datalantai = snapshot.data!;
                return ListView.separated(
                  itemCount: datalantai.length,
                  itemBuilder: (context, index) {
                    final lantai = datalantai[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        leading: const Text(''),
                        onLongPress: () {
                          _showDeleteConfirmationDialog(context,
                              id: lantai['id']);
                        },
                        title: Text(lantai['floorname']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LantaiEdit(
                                scaffoldMessengerKey: _scaffoldMessengerKey,
                                data: lantai,
                                onLantaiEdited: () {
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                );
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LantaiCreate(
                  scaffoldMessengerKey: _scaffoldMessengerKey,
                  onLantaiAdded: () {
                    setState(() {});
                  },
                ),
              ),
            );
          },
          backgroundColor: CustomColors.first,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
