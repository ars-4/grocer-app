import 'package:flutter/material.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/closed_shop.dart';
import 'package:grocer/products_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grocer/class/product_category.dart';

class CategoryScreen extends StatefulWidget {
  final ApiCredentials apiCredentials;
  const CategoryScreen({super.key, required this.apiCredentials});

  @override
  State<CategoryScreen> createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchInput = TextEditingController();
  List<ProductCategory> _allCategories = [];
  List<ProductCategory> _filteredCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _searchInput.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchInput.dispose();
    super.dispose();
  }

  bool _hasError = false;
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final baseApiUrl = widget.apiCredentials.api;
    final url = Uri.parse(
      '$baseApiUrl/categories${widget.apiCredentials.odoo}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final categories = jsonList
            .where((json) => json != null)
            .map((json) {
              try {
                return ProductCategory.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .where((category) => category != null)
            .cast<ProductCategory>()
            .toList();

        setState(() {
          _allCategories = categories;
          _filteredCategories = _allCategories;
          _isLoading = false;
        });
      } else {
        debugPrint("API returned status code ${response.statusCode}");
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (error) {
      debugPrint("An Unexpected Error during fetch: ${error.toString()}");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterCategories() {
    final query = _searchInput.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories.where((category) {
          final categoryName = category.name.toLowerCase();
          return categoryName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _handleRefresh() async {
    _searchInput.clear();
    await _fetchCategories();
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
                  const Icon(Icons.search, size: 18, color: Colors.grey),
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
                        _filterCategories();
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
                  : _hasError
                  ? const ClosedShopView()
                  : _filteredCategories.isEmpty
                  ? Center(
                      child: _searchInput.text.isEmpty
                          ? const ClosedShopView()
                          : const Text(
                              'No categories match your search.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
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
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = _filteredCategories[index];

                          return ElevatedButton(
                            onPressed: () => {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProductsScreen(
                                      id: category.id,
                                      title: category.name,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    category.imageUrl.toString(),
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 140,
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
                                    category.name.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
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
