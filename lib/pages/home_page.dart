import 'package:flutter/material.dart';
import 'package:praktikum4/pages/product_page.dart';
import 'package:praktikum4/models/product.dart';
import 'package:praktikum4/Services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime tanggalSekarang = DateTime(2026, 5, 13);
  final ApiService _apiService = ApiService();
  
  List<Product> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts(); 
  }

  // Mengambil data produk dari API
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? tanggalDipilih = await showDatePicker(
      context: context,
      firstDate: DateTime(2006, 1, 1),
      lastDate: DateTime(2045, 1, 1),
    );
    if (tanggalDipilih != null) {
      setState(() {
        tanggalSekarang = tanggalDipilih;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Welcome, ${widget.username}!',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Tanggal: ${tanggalSekarang.toLocal()}'.split(' ')[0]),
                ElevatedButton(
                  onPressed: () => _pilihTanggal(context),
                  child: const Text("Pilih Tanggal"),
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),
          
          // Daftar Produk
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : _products.isEmpty
                        ? const Center(child: Text('Belum ada draft produk.'))
                        : ListView.builder(
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Rp ${product.price.toStringAsFixed(0)}'),
                                      Text(
                                        product.description, 
                                        maxLines: 2, 
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  // Fitur soft delete
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _products.removeAt(index);
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Produk dihapus')),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah/Submit Produk',
      ),
    );
  }
}