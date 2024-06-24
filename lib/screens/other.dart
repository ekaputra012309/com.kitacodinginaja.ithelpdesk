import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../constans.dart';
import '../screens/auth/profile.dart';
import 'auth/changepassword.dart';

class Other extends StatefulWidget {
  const Other({super.key});

  @override
  State<Other> createState() => _OtherState();
}

class _OtherState extends State<Other> {
  final ApiService _apiService = ApiService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late int idUser;
  String namaUser = '';
  String emailUser = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      Response response = await _apiService.getRequest('/profile');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        setState(() {
          idUser = data['id'];
          namaUser = data['name'];
          emailUser = data['email'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
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
          toolbarHeight: 90.0,
          title: isLoading
              ? const CircularProgressIndicator(color: CustomColors.second)
              : ListTile(
                  textColor: CustomColors.second,
                  iconColor: CustomColors.second,
                  title: Text(
                    namaUser,
                    style: const TextStyle(fontSize: 24.0),
                  ),
                  subtitle: Text(emailUser),
                  trailing: const Icon(
                    Icons.account_circle_rounded,
                    size: 48.0,
                  ),
                ),
          backgroundColor: CustomColors.putih,
          foregroundColor: CustomColors.second,
        ),
        body: ListView(
          children: [
            sectionHeader('My Account Information'),
            const SizedBox(
              height: 8.0,
            ),
            buildListTile(
                icon: Icons.lock_clock_rounded,
                title: 'Change Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Changepassword(
                        scaffoldMessengerKey: _scaffoldMessengerKey,
                        id: idUser,
                        nama: namaUser,
                        email: emailUser,
                        onUserEdited: () {
                          setState(() {
                            fetchUserData();
                          });
                        },
                      ),
                    ),
                  );
                }),
            const SizedBox(
              height: 8.0,
            ),
            sectionHeader('Settings'),
            const SizedBox(
              height: 8.0,
            ),
            buildListTile(
              icon: Icons.person_search_rounded,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      scaffoldMessengerKey: _scaffoldMessengerKey,
                      id: idUser,
                      nama: namaUser,
                      email: emailUser,
                      onUserEdited: () {
                        setState(() {
                          fetchUserData();
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            // const Divider(height: 1.0),
            buildListTile(
              icon: Icons.question_mark_rounded,
              title: 'About',
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
            // const Divider(height: 1.0),
            buildListTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F4F8),
        boxShadow: [
          BoxShadow(
            blurRadius: 0,
            color: Color(0xFFE5E7EB),
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(32, 12, 0, 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        // elevation: 2.0,
        color: CustomColors.putih,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          leading: Icon(icon, color: CustomColors.hitam),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: Color(0xFF606A85), size: 20),
          onTap: onTap,
        ),
      ),
    );
  }
}
