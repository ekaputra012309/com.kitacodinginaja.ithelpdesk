import '../constans.dart';
import 'package:flutter/material.dart';
import 'kategori/kategori_index.dart';
import 'lantai/lantai_index.dart';
import 'lokasi/lokasi_index.dart';
import 'user/user_index.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
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
        icon: Icons.edit_attributes_rounded, label: 'Request User', count: 8),
    ListMenuItem(
        icon: Icons.newspaper_rounded, label: 'Berita Acara', count: 3),
    ListMenuItem(
        icon: Icons.file_copy_rounded, label: 'Surat Tanda Terima', count: 1),
  ];

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
  final int count;

  ListMenuItem({required this.icon, required this.label, required this.count});
}

class MenuItem {
  final IconData icon;
  final String label;
  final Widget page;

  MenuItem({required this.icon, required this.label, required this.page});
}
