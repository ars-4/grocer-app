import 'package:flutter/material.dart';
import 'package:grocer/class/product.dart';
import 'package:grocer/closed_shop.dart';
import 'package:grocer/product_page.dart';
import 'class/api_credentials.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductsScreen extends StatefulWidget {
  final int id;
  final String title;
  final ApiCredentials apiCredentials;
  const ProductsScreen({
    super.key,
    required this.title,
    required this.id,
    required this.apiCredentials,
  });

  @override
  State<ProductsScreen> createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchInput = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchInput.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchInput.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    final baseApiUrl = widget.apiCredentials.api;
    final url = Uri.parse(
      '$baseApiUrl/products${widget.apiCredentials.odoo}&category_id=${widget.id}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final products = jsonList
            .map((json) => Product.fromJson(json))
            .toList();

        setState(() {
          _allProducts = products;
          _filteredProducts = _allProducts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    final query = _searchInput.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final productName = product.name.toLowerCase();
          return productName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _handleRefresh() async {
    _searchInput.clear();
    await _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color.fromARGB(13, 249, 215, 3),
        elevation: 2.0,
      ),
      body: Container(
        alignment: Alignment.center,
        color: const Color.fromRGBO(249, 215, 3, 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchInput,
                      style: const TextStyle(fontSize: 12),
                      cursorColor: Colors.amber,
                      decoration: const InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black38,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchInput.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchInput.clear();
                        _filterProducts();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty && _searchInput.text.isEmpty
                  ? const ClosedShopView()
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.95,
                            ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];

                          return ElevatedButton(
                            onPressed: () => {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProductScreen(
                                      id: product.id,
                                      apiCredentials: widget.apiCredentials,
                                    );
                                  },
                                ),
                              ),
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.black12,
                            ),
                            child: SizedBox.expand(
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          product.image.toString(),
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          product.name.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          "Rs. ${product.price}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Positioned(
                                    top: 0,
                                    right: 4,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.favorite_outline,
                                        size: 30,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {},
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),

                                  // Positioned(
                                  //   top: 10,
                                  //   left: 10,
                                  //   child: Container(
                                  //     padding: const EdgeInsets.symmetric(
                                  //       horizontal: 6,
                                  //       vertical: 2,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors
                                  //           .amber, // Your desired yellow circle background
                                  //       borderRadius: BorderRadius.circular(10),
                                  //     ),
                                  //     child: const Text(
                                  //       "NEW", // The text you wanted
                                  //       style: TextStyle(
                                  //         color: Colors.black,
                                  //         fontSize: 12,
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
