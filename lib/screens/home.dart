import 'package:dio/dio.dart';

import '../constans.dart';
import 'package:flutter/material.dart';
import 'kategori/kategori_index.dart';
import 'lantai/lantai_index.dart';
import 'lokasi/lokasi_index.dart';
import 'request/widget/request_model.dart';
import 'user/user_index.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int touchedIndex = -1;

  final List<MenuItem> menuItems = [
    MenuItem(
        icon: Icons.line_style_rounded,
        label: 'Lantai',
        page: const Lantaiindex()),
    MenuItem(
        icon: Icons.location_pin, label: 'Lokasi', page: const Lokasiindex()),
    MenuItem(
        icon: Icons.category_rounded,
        label: 'Kategori',
        page: const KategoriIndex()),
    MenuItem(
        icon: Icons.person_2_rounded, label: 'User', page: const UserIndex()),
  ];

  final List<ListMenuItem> listMenuItems = [
    ListMenuItem(
        icon: Icons.edit_attributes_rounded, label: 'Request User', count: 0),
    ListMenuItem(
        icon: Icons.newspaper_rounded, label: 'Berita Acara', count: 0),
    ListMenuItem(
        icon: Icons.file_copy_rounded, label: 'Surat Tanda Terima', count: 0),
  ];

  Future<List<DataItem>> fetchpermintaan() async {
    final ApiService apiService = ApiService();
    try {
      Response response = await apiService.getRequest('/permintaan');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData.containsKey('data')) {
          final List<dynamic> items = responseData['data'];
          List<DataItem> dataItems =
              items.map((item) => DataItem.fromJson(item)).toList();
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

 @override
  void initState() {
    super.initState();
    fetchAndCountData();
  }

  Future<void> fetchAndCountData() async {
    try {
      List<DataItem> dataItems = await fetchpermintaan();
      setState(() {
        listMenuItems[0].count = dataItems.length; // Assuming 'Request User' corresponds to the first item
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('IT', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8.0),
            Text('Helpdesk'),
          ],
        ),
        backgroundColor: CustomColors.putih,
        foregroundColor: CustomColors.second,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 8.0),
              buildSectionTitle('Master Data'),
              const SizedBox(height: 8.0),
              buildGridMenu(),
              const SizedBox(height: 16.0),
              buildSectionTitle('Transaction'),
              const SizedBox(height: 8.0),
              buildListMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Card(
      color: CustomColors.putih,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16.0)),
          ),
        ],
      ),
    );
  }

  Widget buildGridMenu() {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width / 4; // 4 is the crossAxisCount
    final height = width / 0.8; // Adjust this ratio as needed
    final iconSize = width / 3; // Adjust this ratio as needed

    return Card(
      color: CustomColors.putih,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: menuItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 0.8,
            mainAxisSpacing: 0.8,
            childAspectRatio: width / height,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item.page),
                );
              },
              child: Column(
                children: [
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(item.icon,
                          size: iconSize, color: CustomColors.second),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(item.label),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildListMenu() {
    return Card(
      color: CustomColors.putih,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            ListView.builder(
              itemBuilder: (context, index) {
                final item = listMenuItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      leading: Icon(item.icon, color: CustomColors.second),
                      title: Text(item.label,
                          style: const TextStyle(color: CustomColors.second)),
                      trailing: Text(item.count.toString(),
                          style: const TextStyle(color: CustomColors.second)),
                    ),
                  ),
                );
              },
              itemCount: listMenuItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            )
          ],
        ),
      ),
    );
  }
}

class ListMenuItem {
  final IconData icon;
  final String label;
  int count;

  ListMenuItem({required this.icon, required this.label, required this.count});
}

class MenuItem {
  final IconData icon;
  final String label;
  final Widget page;

  MenuItem({required this.icon, required this.label, required this.page});
}
