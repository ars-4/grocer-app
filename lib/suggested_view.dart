import 'package:flutter/material.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/class/product.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SuggestedProducts extends StatefulWidget {
  final ApiCredentials apiCredentials;
  final List<int> products;
  final Function(BuildContext context, int productId) onProductTap;

  const SuggestedProducts({
    super.key,
    required this.apiCredentials,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<SuggestedProducts> createState() => SuggestedProductsState();
}

class SuggestedProductsState extends State<SuggestedProducts> {
  late Future<List<Product>> _futureProducts;
  final String _placeholderImage = "https://demo.schediazo.com/logo.jpg";

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchSuggestedProducts();
  }

  Future<List<Product>> _fetchSuggestedProducts() async {
    if (widget.products.isEmpty) {
      return [];
    }

    final baseApiUrl = widget.apiCredentials.api;
    final odooParams = widget.apiCredentials.odoo;
    List<Future<Product?>> fetchFutures = widget.products.map((productId) {
      final url = Uri.parse('$baseApiUrl/product/$productId?$odooParams');

      return http
          .get(url)
          .then((response) {
            if (response.statusCode == 200) {
              try {
                final json = jsonDecode(response.body);
                return Product.fromJson(json);
              } catch (e) {
                return null;
              }
            } else {
              return null;
            }
          })
          .catchError((error) {
            return null;
          });
    }).toList();
    List<Product?> results = await Future.wait(fetchFutures);
    return results.where((product) => product != null).cast<Product>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final List<Product> suggestedProducts = snapshot.data!;
        return Container(
          color: const Color.fromRGBO(249, 215, 3, 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                child: Text(
                  "Suggested for you",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: suggestedProducts.length,
                itemBuilder: (context, index) {
                  final product = suggestedProducts[index];
                  final imageUrl = product.images.isNotEmpty
                      ? product.images.first
                      : _placeholderImage;

                  return ElevatedButton(
                    onPressed: () {
                      widget.onProductTap(context, product.id);
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) {
                      //       return ProductScreen(
                      //         id: product.id,
                      //         apiCredentials: widget.apiCredentials,
                      //       );
                      //     },
                      //   ),
                      // );
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 120,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  "Rs. ${product.price.toStringAsFixed(2)}",
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
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "NEW",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
