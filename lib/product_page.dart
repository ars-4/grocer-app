import 'package:flutter/material.dart';
import 'package:grocer/suggested_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'class/api_credentials.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grocer/class/product.dart';
import 'package:grocer/grocer_app.dart';

class ProductScreen extends StatefulWidget {
  final int id;
  final ApiCredentials apiCredentials;
  const ProductScreen({
    super.key,
    required this.id,
    required this.apiCredentials,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<Product> futureProduct;
  Product? product;
  int _currentCartQuantity = 0;
  final String _imageMainDefault = "https://i.imgur.com/z5SYyv9.jpeg";
  late String _currentImage;
  final String productWeight = " ";
  static const String _cartKey = 'user_cart_items';

  @override
  void initState() {
    super.initState();
    _currentImage = _imageMainDefault;
    futureProduct = _fetchProduct(widget.id);
    _loadInitialQuantity();
  }

  Future<Product> _fetchProduct(int productId) async {
    final url = Uri.parse(
      '${widget.apiCredentials.api}/product/$productId${widget.apiCredentials.odoo}',
    );
    final response = await http.get(url);
    final Product fetchedProduct = Product.fromJson(jsonDecode(response.body));

    setState(() {
      product = fetchedProduct;
      if (fetchedProduct.images.isNotEmpty) {
        _currentImage = fetchedProduct.images.first;
      }
    });
    return fetchedProduct;
  }

  Future<void> _loadInitialQuantity() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartString = prefs.getString(_cartKey);
    if (cartString != null && cartString.isNotEmpty) {
      try {
        final List<dynamic> decodedList = jsonDecode(cartString);
        final cartItems = decodedList.cast<Map<String, dynamic>>();
        final currentItem = cartItems.firstWhere(
          (item) => item['id'] == widget.id,
          orElse: () => {"qty": 0},
        );
        setState(() {
          _currentCartQuantity = currentItem['qty'] as int? ?? 0;
        });
      } catch (e) {
        debugPrint("Error loading initial cart quantity: $e");
      }
    }
  }

  Future<void> addToCart() async {
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product details are still loading.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? cartString = prefs.getString(_cartKey);

    List<Map<String, dynamic>> cartList = [];
    if (cartString != null && cartString.isNotEmpty) {
      try {
        cartList = List<Map<String, dynamic>>.from(jsonDecode(cartString));
      } catch (e) {
        debugPrint("Error decoding cart data: $e");
        cartList = [];
      }
    }
    int existingIndex = cartList.indexWhere(
      (item) => item['id'] == product!.id,
    );
    int newQuantity;

    if (existingIndex != -1) {
      final currentQty = cartList[existingIndex]['qty'] as int? ?? 0;
      newQuantity = currentQty + 1;
      cartList[existingIndex]['qty'] = newQuantity;
    } else {
      newQuantity = 1;
      cartList.add({
        "id": product!.id,
        "name": product!.name,
        "qty": newQuantity,
      });
    }

    await prefs.setString(_cartKey, jsonEncode(cartList));
    setState(() {
      _currentCartQuantity = newQuantity;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product!.name} added! Total in bag: $_currentCartQuantity',
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.amber.shade700,
      ),
    );
  }

  void navigateToProductScreen(BuildContext context, int productId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProductScreen(id: productId, apiCredentials: widget.apiCredentials),
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl) {
    bool isSelected = _currentImage == imageUrl;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentImage = imageUrl;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey.shade300,
            width: isSelected ? 3.0 : 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Product Details",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Color.fromARGB(13, 249, 215, 3),
        elevation: 2.0,
      ),
      body: FutureBuilder<Product>(
        future: futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final product = snapshot.data!;
            return _buildProductContent(context, product);
          } else {
            return const Center(
              child: Text(
                'No data found.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  GroceryScreen(credentials: widget.apiCredentials),
            ),
          );
        },
        backgroundColor: Colors.amber,
        child: Icon(Icons.shopping_cart_outlined, color: Colors.black),
      ),
    );
  }

  Widget _buildProductContent(BuildContext context, Product product) {
    final String categoryText = product.categories.isNotEmpty
        ? product.categories.first
        : 'Uncategorized';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _currentImage,
                  fit: BoxFit.cover,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text(
                          "Image Failed to Load",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                ...product.images.map(
                  (imgUrl) => _buildThumbnail(imgUrl),
                ), //.toList()
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      productWeight.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      'PKR ${product.price}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    const Icon(Icons.menu, size: 20, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      categoryText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: addToCart,
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black87,
                    ),
                    label: Text(
                      _currentCartQuantity > 0
                          ? 'Add More (In Bag: $_currentCartQuantity)'
                          : 'Add to Bag',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                      shadowColor: Colors.amber.shade200,
                    ),
                  ),
                ),

                SizedBox(height: 10.0),

                Text(
                  product.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          SuggestedProducts(
            apiCredentials: widget.apiCredentials,
            products: product.optionalProductIds,
            onProductTap: navigateToProductScreen,
          ),
        ],
      ),
    );
  }
}
