class Product {
  final int id; 
  final String name;
  final double price;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()), 
      name: json['name'].toString(), 
      price: double.parse(json['price'].toString()), 
      description: json['description']?.toString() ?? 'Tidak ada deskripsi',
    );
  }
}