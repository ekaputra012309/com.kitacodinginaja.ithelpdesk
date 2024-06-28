import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../kategori/kategori_edit.dart';
import '../kategori/kategori_create.dart';
import '../../constans.dart';

class KategoriIndex extends StatefulWidget {
  const KategoriIndex({super.key});

  @override
  State<KategoriIndex> createState() => _KategoriIndexState();
}

class _KategoriIndexState extends State<KategoriIndex> {
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

  Future<List<Map<String, dynamic>>> fetchkategori() async {
    try {
      Response response = await _apiService.getRequest('/kategori');

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
      debugPrint('Error during fetchkategori: $e');
      throw Exception('Error during fetchkategori: $e');
    }
  }

  Future<void> _delete(BuildContext context, {required idValue}) async {
    try {
      final int id = idValue;
      Response response = await _apiService.deleteRequest('/kategori/$id');
      if (response.statusCode == 204) {
        setState(() {
          fetchkategori();
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Kategori deleted successfully'),
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
          title: const Text('Kategori'),
          backgroundColor: CustomColors.second,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await fetchkategori();
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchkategori(),
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
                final datakategori = snapshot.data!;
                return ListView.separated(
                  itemCount: datakategori.length,
                  itemBuilder: (context, index) {
                    final kategori = datakategori[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        leading: Text(kategori['categoryname']),
                        onLongPress: () {
                          _showDeleteConfirmationDialog(context,
                              id: kategori['id']);
                        },
                        title: Text(kategori['hashtag']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KategoriEdit(
                                scaffoldMessengerKey: _scaffoldMessengerKey,
                                data: kategori,
                                onKategoriEdited: () {
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
                builder: (context) => KategoriCreate(
                  scaffoldMessengerKey: _scaffoldMessengerKey,
                  onKategoriAdded: () {
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
