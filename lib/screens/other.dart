import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../constans.dart';
import '../screens/auth/profile.dart';
import 'auth/changepassword.dart';
// import 'widget/download_manager.dart';
import 'widget/download_service.dart';

class Other extends StatefulWidget {
  const Other({super.key});

  @override
  State<Other> createState() => _OtherState();
}

class _OtherState extends State<Other> {
  final ApiService _apiService = ApiService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // final DownloadManager _downloadManager = DownloadManager();
  final downloadService = DownloadService();

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

  Future<void> _showCheckVersionDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;

    Response response = await _apiService.getRequest('/releases/latest');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;

      // Extract specific fields directly
      final String versiNumber =
          responseData['data']['version_number'] ?? 'Unknown';
      final String versi = responseData['data']['version'] ?? 'Unknown';
      final String linkarm64V8a = responseData['data']['arm64_v8a'] ?? '';
      final String linkrelease = responseData['data']['release'] ?? '';
      if (version != versiNumber) {
        if (!context.mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Update Available'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('New Version: $versi v$versiNumber'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // _downloadManager.startDownload(
                    //     linkarm64V8a, 'v$versiNumber-arm64_v8a.apk');
                    downloadService.startDownload(
                        linkarm64V8a, 'v$versiNumber-arm64_v8a.apk');
                  },
                  child: const Text('Download arm64_v8a'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // _downloadManager.startDownload(
                    //     linkrelease, 'v$versiNumber.apk');
                    downloadService.startDownload(
                        linkrelease, 'v$versiNumber.apk');
                  },
                  child: const Text('Download release'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();                    
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App is up to date'),
            backgroundColor: CustomColors.first,
          ),
        );
      }
    } else {
      throw Exception('Failed to load version data');
    }
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.white,
            child: ListView(
              children: [
                const SizedBox(height: 8.0),
                sectionHeader('My Account Information'),
                const SizedBox(height: 8.0),
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
                  },
                ),
                const SizedBox(height: 8.0),
                sectionHeader('Settings'),
                const SizedBox(height: 8.0),
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
                const Divider(height: 1.0),
                buildListTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                const Divider(height: 1.0),
                buildListTile(
                  icon: Icons.android_rounded,
                  title: 'Check for Updates',
                  onTap: () {
                    _showCheckVersionDialog(context);
                  },
                ),
                const Divider(height: 1.0),
                buildListTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: () {
                    _showLogoutConfirmationDialog(context);
                  },
                ),
                const Divider(height: 1.0),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error loading version info'));
                    } else {
                      String version = snapshot.data?.version ?? 'Unknown';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text('App Version: $version')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ListTile(
        leading: Icon(icon, color: CustomColors.hitam),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        onTap: onTap,
      ),
    );
  }
}
