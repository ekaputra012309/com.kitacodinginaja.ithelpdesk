import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/request/request_index.dart';
import '../constans.dart';
import '../screens/menu.dart';
import '../screens/other.dart';
import 'dashboard.dart';

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

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: CustomColors.second,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Icon(
          icon,
          size: 24.0, // Adjust size if needed
          color: CustomColors.putih,
        ),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    List<Widget> pages;
    List<BottomNavigationBarItem> items;

    if (userDataProvider.role == 'User') {
      pages = [
        const RequestIndex(),
        const Other(),
      ];
      items = [
        _buildBottomNavigationBarItem(
          icon: Icons.edit_attributes_rounded,
          label: 'Request',
          isSelected: _selectedIndex == 0,
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.more_horiz_rounded,
          label: 'More',
          isSelected: _selectedIndex == 1,
        ),
      ];
    } else {
      pages = [
        const Dashboard(),
        const Menu(),
        const RequestIndex(),
        const Other(),
      ];
      items = [
        _buildBottomNavigationBarItem(
          icon: Icons.dashboard_customize_rounded,
          label: 'Dashboard',
          isSelected: _selectedIndex == 0,
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.list_rounded,
          label: 'Menu',
          isSelected: _selectedIndex == 1,
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.edit_attributes_rounded,
          label: 'Request',
          isSelected: _selectedIndex == 2,
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.more_horiz_rounded,
          label: 'More',
          isSelected: _selectedIndex == 3,
        ),
      ];
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 90.0, // Adjust height if needed
        child: BottomNavigationBar(
          items: items,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: CustomColors.putih,
          selectedItemColor: CustomColors.hitam,
          unselectedItemColor: CustomColors.hitam,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed, // Ensure all labels are shown
        ),
      ),
    );
  }
}
