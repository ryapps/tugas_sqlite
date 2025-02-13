import 'dart:io';

import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Detail Produk',style: TextStyle(fontWeight: FontWeight.bold),),backgroundColor: Colors.cyan,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product['img'] != null && product['img'].isNotEmpty
                ? Image.file(
                    File(product['img']),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(product['nama_produk'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Harga: Rp ${product['price']}",
                style: const TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(height: 10),
            Text(product['description'], style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
