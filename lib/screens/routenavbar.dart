import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:provider/provider.dart';
import '../constans.dart';
import 'berita/berita_index.dart';
import 'home.dart';
import 'other.dart';
import 'request/request_index.dart';
import 'surat/surat_index.dart';

class Routenavbar extends StatefulWidget {
  const Routenavbar({super.key});

  @override
  RoutenavbarState createState() => RoutenavbarState();
}

class RoutenavbarState extends State<Routenavbar> {
  int _selectedIndex = 0;

  final List<TabItem> userItems = [
    const TabItem(
      icon: Icons.edit_attributes_rounded,
      title: 'Request',
    ),
    const TabItem(
      icon: Icons.more_horiz_rounded,
      title: 'More',
    ),
  ];

  final List<TabItem> adminItems = [
    const TabItem(
      icon: Icons.add_home_rounded,
      title: 'Home',
    ),
    const TabItem(
      icon: Icons.edit_attributes_rounded,
      title: 'Request',
    ),
    const TabItem(
      icon: Icons.newspaper_rounded,
      title: 'News',
    ),
    const TabItem(
      icon: Icons.receipt_long,
      title: 'Receipt',
    ),
    const TabItem(
      icon: Icons.more_rounded,
      title: 'More',
    ),
  ];

  final List<Widget> userPages = [
    const RequestIndex(),
    const Other(),
  ];

  final List<Widget> adminPages = [
    const Home(),
    const RequestIndex(),
    const BeritaIndex(),
    const SuratIndex(),
    const Other(),
  ];

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final isUser = userDataProvider.role == 'User';

    final items = isUser ? userItems : adminItems;
    final pages = isUser ? userPages : adminPages;

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding:const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: BottomBarFloating(        
          color: CustomColors.hitam,
          colorSelected: CustomColors.second,
          items: items,
          indexSelected : _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: CustomColors.putih,
          animated: true,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
