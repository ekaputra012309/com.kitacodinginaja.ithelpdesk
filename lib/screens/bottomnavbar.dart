import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/request/request_index.dart';
import '../constans.dart';
import '../screens/menu.dart';
import '../screens/other.dart';
import 'berita/berita_index.dart';
import 'surat/surat_index.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBottomNavigationBarItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),  // Correctly passing the index
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isSelected ? 16.0 : 24.0, // Adjust sizes
            color: isSelected ? CustomColors.second : CustomColors.hitam,
          ),
          const SizedBox(height: 4.0),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: isSelected ? CustomColors.second : CustomColors.hitam,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // Allow label to wrap into two lines if necessary
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    List<Widget> pages;
    List<Widget> items;

    if (userDataProvider.role == 'User') {
      pages = [
        const RequestIndex(),
        const Other(),
      ];
      items = [
        _buildBottomNavigationBarItem(
          index: 0,
          icon: Icons.edit_attributes_rounded,
          label: 'Request',
          isSelected: _selectedIndex == 0,
        ),
        _buildBottomNavigationBarItem(
          index: 1,
          icon: Icons.more_horiz_rounded,
          label: 'More',
          isSelected: _selectedIndex == 1,
        ),
      ];
    } else {
      pages = [
        // const Dashboard(),
        const Menu(),
        const RequestIndex(),
        const BeritaIndex(),
        const SuratIndex(),
        const Other(),
      ];
      items = [
        _buildBottomNavigationBarItem(
          index: 0,
          icon: Icons.home_filled,
          label: 'Home',
          isSelected: _selectedIndex == 0,
        ),
        _buildBottomNavigationBarItem(
          index: 1,
          icon: Icons.edit_attributes_rounded,
          label: 'Request',
          isSelected: _selectedIndex == 1,
        ),
        _buildBottomNavigationBarItem(
          index: 2,
          icon: Icons.newspaper_rounded,
          label: 'News',
          isSelected: _selectedIndex == 2,
        ),
        _buildBottomNavigationBarItem(
          index: 3,
          icon: Icons.receipt_long_rounded,
          label: 'Receipt',
          isSelected: _selectedIndex == 3,
        ),
        _buildBottomNavigationBarItem(
          index: 4,
          icon: Icons.more_horiz_rounded,
          label: 'More',
          isSelected: _selectedIndex == 4,
        ),
      ];
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: CustomColors.putih,
        height: 90.0, // Adjust height if needed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items,
        ),
      ),
    );
  }
}
