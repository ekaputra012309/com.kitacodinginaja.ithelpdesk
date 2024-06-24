import 'package:flutter/material.dart';

class SuratIndex extends StatelessWidget {
  const SuratIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanda Terima Barang'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('tanda terima barang page'),
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