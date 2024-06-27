import 'package:flutter/material.dart';

import '../../constans.dart';

class SuratIndex extends StatelessWidget {
  const SuratIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanda Terima Barang'),
        backgroundColor: CustomColors.putih,
        foregroundColor: CustomColors.second,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('coming soon'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){

      }, child: const Icon(
        Icons.add,
      ),),
    );
  }
}