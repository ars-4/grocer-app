import 'package:flutter/material.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/product_page.dart';
import 'package:grocer/class/favourites_manager.dart';
import 'package:grocer/class/product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FavouritesScreen extends StatefulWidget {
  final ApiCredentials apiCredentials;
  const FavouritesScreen({super.key, required this.apiCredentials});

  @override
  State<FavouritesScreen> createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> {
  final TextEditingController _searchInput = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoritesAndProducts();
    _searchInput.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchInput.dispose();
    super.dispose();
  }

  Future<void> _fetchFavoritesAndProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _favoriteIds = await FavoritesManager.loadFavorites();

      if (_favoriteIds.isEmpty) {
        setState(() {
          _allProducts = [];
          _filteredProducts = [];
          _isLoading = false;
        });
        return;
      }

      final List<Product> fetchedProducts = [];
      final baseApiUrl = widget.apiCredentials.api;
      final odooParams = widget.apiCredentials.odoo;

      final fetchFutures = _favoriteIds.map((id) {
        final url = Uri.parse('$baseApiUrl/product/$id$odooParams');
        return http.get(url);
      }).toList();

      final responses = await Future.wait(fetchFutures);

      for (var response in responses) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(response.body);
          final product = Product.fromJson(json);
          fetchedProducts.add(product);
        }
      }

      setState(() {
        _allProducts = fetchedProducts;
        _filteredProducts = _allProducts;
        _isLoading = false;
      });

      _filterProducts();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load favorites: $error')),
        );
        setState(() {
          _isLoading = false;
        });
      }
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
    await _fetchFavoritesAndProducts();
  }

  bool isFavourite(int productID) {
    return _favoriteIds.contains(productID);
  }

  void _toggleFavorite(int productID) async {
    final bool currentlyFavorite = _favoriteIds.contains(productID);
    setState(() {
      if (currentlyFavorite) {
        _favoriteIds.remove(productID);
      } else {
        _favoriteIds.add(productID);
      }
    });

    if (currentlyFavorite) {
      await FavoritesManager.unfavourited(productID);
    } else {
      await FavoritesManager.favourited(productID);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlyFavorite
                ? 'Removed product $productID from your favorites!'
                : 'Added product $productID to your favorites!',
          ),
          duration: const Duration(milliseconds: 800),
        ),
      );

      _fetchFavoritesAndProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        hintText: "Search your favorites",
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
                  : _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No favorites found, Go find something to wishlist.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
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
                                          product.images.first.toString(),
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
                                      icon: Icon(
                                        isFavourite(product.id)
                                            ? Icons.favorite
                                            : Icons.favorite_outline,
                                        size: 30,
                                        color: Colors.amber,
                                      ),
                                      onPressed: () {
                                        _toggleFavorite(product.id);
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
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
