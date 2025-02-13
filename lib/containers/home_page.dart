import 'dart:io';
import 'package:crud_sqlite_flutter/containers/items/detail_product.dart';
import 'package:crud_sqlite_flutter/helpers/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  final _formKey = GlobalKey<FormState>(); // Kunci untuk Form
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imgController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  // **Mengambil Data dari Database**
  void _refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  // **Pilih Gambar dari Galeri**
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imgController.text =
            pickedFile.path; // Simpan path gambar ke controller
      });
    }
  }

  // **Menampilkan Form Tambah/Edit Data**
  void _showForm(int? id) async {
    if (id != null) {
      final existingItem = _items.firstWhere((element) => element['id'] == id);
      _productNameController.text = existingItem['nama_produk'];
      _descriptionController.text = existingItem['description'];
      _imgController.text = existingItem['img'];
      _priceController.text = existingItem['price'].toString();
    } else {
      _productNameController.clear();
      _descriptionController.clear();
      _imgController.clear();
      _priceController.clear();
      _image = null;
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    floatingLabelBehavior: FloatingLabelBehavior.always),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imgController,
                readOnly: true,
                onTap: _pickImage,
                decoration: InputDecoration(
                    labelText: 'Gambar Produk',
                    hintText: 'Tekan untuk upload',
                    suffixIcon: Icon(Icons.image),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
              ),
              SizedBox(
                height: 10,
              ),
              _image != null
                  ? Image.file(_image!, height: 100)
                  : _imgController.text.isNotEmpty
                      ? Image.file(File(_imgController.text), height: 100)
                      : Container(),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Harga',
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (id == null) {
                      await SQLHelper.createItem(
                          _productNameController.text,
                          _descriptionController.text,
                          _imgController.text,
                          int.parse(_priceController.text));
                    } else {
                      await SQLHelper.updateItem(
                          id,
                          _productNameController.text,
                          _descriptionController.text,
                          _imgController.text,
                          int.parse(_priceController.text));
                    }
                    _productNameController.clear();
                    _descriptionController.clear();
                    _imgController.clear();
                    _priceController.clear();
                    _image = null;
                    Navigator.of(context).pop();
                    _refreshItems();
                  }
                },
                child: Text(id == null ? 'Tambah Item' : 'Perbarui Item'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // **Menghapus Data dari Database**
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tokline',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => _showForm(null),
                      child: Text('Tambah Produk'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.cyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Ubah angka sesuai kebutuhan
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(_items[index]['nama_produk']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_items[index]['description']),
                      Text(
                        'Rp' + _items[index]['price'].toString(),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  leading: _items[index]['img'] != null &&
                          _items[index]['img'].isNotEmpty
                      ? Image.file(File(_items[index]['img']),
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showForm(_items[index]['id'])),
                      IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteItem(_items[index]['id'])),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(product: _items[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
