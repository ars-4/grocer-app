import 'package:flutter/material.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/closed_shop.dart';
import 'package:grocer/product_page.dart';

class FavouritesScreen extends StatefulWidget {
  final ApiCredentials apiCredentials;
  const FavouritesScreen({super.key, required this.apiCredentials});

  @override
  State<FavouritesScreen> createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> {
  final TextEditingController _searchInput = TextEditingController();
  bool productsLoaded = true;

  final List _allProducts = [
    {
      "name": "Iced Tea",
      "price": 100.00,
      "image": "https://placehold.co/400x200/000000/fff.png",
    },
    {
      "name": "Coffee",
      "price": 150.00,
      "image": "https://placehold.co/200x200/000000/fff.png",
    },
    {
      "name": "Milk",
      "price": 200.00,
      "image": "https://placehold.co/200x200/000000/fff.png",
    },
    {
      "name": "Bread",
      "price": 250.00,
      "image": "https://placehold.co/200x200/000000/fff.png",
    },
    {
      "name": "Eggs",
      "price": 300.00,
      "image": "https://placehold.co/200x200/000000/fff.png",
    },
    {
      "name": "Bananas",
      "price": 350.00,
      "image": "https://placehold.co/200x200/000000/fff.png",
    },
    {
      "name": "Apples",
      "price": 400.00,
      "image": "https://placehold.co/200x200/000000/fff.png",
    },
    {
      "name": "Oranges",
      "price": 450.00,
      "image": "https://placehold.co/200x200/000000/fff.png",
    },
    {
      "name": "Grapes",
      "price": 500.00,
      "image": "https://placehold.co/200x200/000000/fff.png",
    },
  ];

  List _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
    _searchInput.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchInput.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchInput.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final productName = product["name"].toString().toLowerCase();
          return productName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _searchInput.clear();
    _filterProducts();
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
                ],
              ),
            ),

            Expanded(
              child: productsLoaded
                  ? RefreshIndicator(
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
                                      id: 1,
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
                              // Ensures the content fills the button area
                              child: Stack(
                                children: [
                                  // 1. The main content (Image, Name, Price)
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
                                          product["image"].toString(),
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
                                          product["name"].toString(),
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
                                          "Rs. ${product["price"]}",
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
                                        Icons.favorite,
                                        color: Colors.amber,
                                        size: 30,
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
                                        color: Colors
                                            .amber, // Your desired yellow circle background
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "NEW", // The text you wanted
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
                    )
                  : const ClosedShopView(),
            ),
          ],
        ),
      ),
    );
  }
}
