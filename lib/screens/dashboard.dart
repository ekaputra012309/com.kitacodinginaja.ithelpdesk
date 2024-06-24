import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constans.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (!userDataProvider.isLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8.0),
              // Text('Users'),
            ],
          ),
          backgroundColor: CustomColors.putih,
          foregroundColor: CustomColors.second,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8.0),
              // Text('Users'),
            ],
          ),
          backgroundColor: CustomColors.putih,
          foregroundColor: CustomColors.second,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Token: ${userDataProvider.accessToken}'),
              Text('ID: ${userDataProvider.id}'),
              Text('Name: ${userDataProvider.name}'),
              Text('Email: ${userDataProvider.email}'),
              Text('Role: ${userDataProvider.role}'),
            ],
          ),
        ),
      );
    }
  }
}
