import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import '../../constans.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> fetchRelease() async {
    try {
      Response response = await _apiService.getRequest('/release');

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
      debugPrint('Error during fetchRelease: $e');
      throw Exception('Error during fetchRelease: $e');
    }
  }

  String formatDateTime(String dateTime) {
    final DateTime parsedDate = DateTime.parse(dateTime);
    final DateFormat formatter = DateFormat('dd MMM yyy HH:mm');
    return formatter.format(parsedDate);
  }

  void _showChangelogModal(BuildContext context, String changelog) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Changelog',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Html(data: changelog),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: CustomColors.first,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: screenHeight * 0.10,
                child: Image.asset("assets/splash_image.png"),
              ),
            ),
            Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Stable 1.0.0',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Changelog',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchRelease(),
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
                    final dataRelease = snapshot.data!;
                    return ListView.separated(
                      itemCount: dataRelease.length,
                      itemBuilder: (context, index) {
                        final dataR = dataRelease[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Versi ${dataR['version']}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(formatDateTime(dataR['created_At'])),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              GestureDetector(
                                onTap: () {
                                  _showChangelogModal(context, dataR['changelog']);
                                },
                                child: const Text(
                                  'Lihat Changelog',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.only(left: 36.0),
                          child: Divider(),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
