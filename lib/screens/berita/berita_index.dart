import 'package:flutter/material.dart';

class BeritaIndex extends StatelessWidget {
  const BeritaIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Acara'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('berita acara page'),
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