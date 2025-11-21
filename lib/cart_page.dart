import 'package:flutter/material.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/grocer_app.dart';
import 'package:grocer/suggested_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:grocer/class/cart_item.dart';
import 'package:grocer/class/product.dart';
import 'package:grocer/product_page.dart';

class CartScreen extends StatefulWidget {
  final ApiCredentials apiCredentials;
  const CartScreen({super.key, required this.apiCredentials});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  final Map<int, Product> _detailedProducts = {};
  String? userId;
  bool _isLoading = true;
  bool isPlacingOrder = false;
  static const String _cartKey = 'user_cart_items';
  final String _placeholderImage = "https://demo.schediazo.com/logo.jpg";

  @override
  void initState() {
    super.initState();
    _initCart();
  }

  Future<void> _initCart() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id').toString();
    final String? cartString = prefs.getString(_cartKey);

    if (cartString != null && cartString.isNotEmpty) {
      try {
        final List<dynamic> decodedList = jsonDecode(cartString);
        _cartItems = decodedList
            .map((json) => CartItem.fromJson(json))
            .toList();
      } catch (e) {
        _cartItems = [];
      }
    }

    await _fetchCartDetails();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchCartDetails() async {
    if (_cartItems.isEmpty) return;

    final baseApiUrl = widget.apiCredentials.api;
    final odooParams = widget.apiCredentials.odoo;

    final uniqueProductIds = _cartItems.map((item) => item.id).toSet();

    List<Future<Product?>> fetchFutures = uniqueProductIds.map((productId) {
      final url = Uri.parse('$baseApiUrl/product/$productId?$odooParams');

      return http
          .get(url)
          .then((response) {
            if (response.statusCode == 200) {
              try {
                return Product.fromJson(jsonDecode(response.body));
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
    _detailedProducts.clear();
    for (var product in results.where((p) => p != null).cast<Product>()) {
      _detailedProducts[product.id] = product;
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = _cartItems
        .map((item) => item.toJson())
        .toList();
    final String cartString = jsonEncode(jsonList);
    await prefs.setString(_cartKey, cartString);
  }

  void navigateToProductScreen(BuildContext context, int productId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProductScreen(id: productId, apiCredentials: widget.apiCredentials),
      ),
    );
    _initCart();
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Error') ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> createOrder() async {
    if (_cartItems.isEmpty) {
      _showSnackbar('Your cart is empty!');
      return;
    }
    final int? customerId = int.tryParse(userId ?? '');

    if (customerId == null || userId == null) {
      _showSnackbar('Error: Authentication failed. Please re-login.');
      return;
    }
    final productsPayload = _cartItems
        .map((item) => {"id": item.id, "qty": item.qty})
        .toList();
    final orderPayload = {
      "customer_id": customerId,
      "products": productsPayload,
    };

    final body = jsonEncode(orderPayload);
    final baseApiUrl = widget.apiCredentials.api;
    final odooParams = widget.apiCredentials.odoo;
    final url = Uri.parse('$baseApiUrl/create-order$odooParams');
    setState(() {
      isPlacingOrder = true;
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackbar(
          'Order placed successfully! Order ID: ${jsonDecode(response.body)['order_id']}',
        );
        await _clearCartAndNavigate();
      } else {
        _showSnackbar(
          'Error: Failed to place order. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _showSnackbar('Please check you internet connection');
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }

  Future<void> _clearCartAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
    setState(() {
      _cartItems.clear();
      _detailedProducts.clear();
    });
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => GroceryScreen(credentials: widget.apiCredentials),
      ),
      (Route<dynamic> route) => false,
    );
  }

  double _getItemTotal(double price, int quantity) {
    return price * quantity;
  }

  void _incrementQuantity(int index) {
    setState(() {
      final oldItem = _cartItems[index];
      _cartItems[index] = CartItem(
        id: oldItem.id,
        name: oldItem.name,
        qty: oldItem.qty + 1,
      );
    });
    _saveCart();
  }

  void _decrementQuantity(int index) {
    setState(() {
      final currentItem = _cartItems[index];
      if (currentItem.qty > 1) {
        _cartItems[index] = CartItem(
          id: currentItem.id,
          name: currentItem.name,
          qty: currentItem.qty - 1,
        );
      } else {
        _cartItems.removeAt(index);
      }
    });
    _saveCart();
  }

  double _calculateSubtotal() {
    double subtotal = 0.0;
    for (var item in _cartItems) {
      final productDetail = _detailedProducts[item.id];
      if (productDetail != null) {
        subtotal += _getItemTotal(productDetail.price.toDouble(), item.qty);
      }
    }
    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = _calculateSubtotal();
    const double deliveryFee = 50.0;
    const double tax = 0.0;
    final double grandTotal = subtotal + deliveryFee + tax;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),

                  _cartItems.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Text(
                              "Your cart is empty! Go grab some goodies.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final cartItem = _cartItems[index];
                            final productDetail =
                                _detailedProducts[cartItem.id];

                            if (productDetail == null) {
                              return _buildLoadingCartItem(
                                cartItem.name,
                                cartItem.qty,
                              );
                            }

                            final double itemTotal = _getItemTotal(
                              productDetail.price.toDouble(),
                              cartItem.qty,
                            );
                            final imageUrl = productDetail.images.isNotEmpty
                                ? productDetail.images.first
                                : _placeholderImage;

                            return _buildCartItem(
                              context,
                              productDetail.name,
                              imageUrl,
                              productDetail.price.toDouble(),
                              itemTotal,
                              cartItem.qty,
                              () => _incrementQuantity(index),
                              () => _decrementQuantity(index),
                            );
                          },
                        ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => GroceryScreen(
                                credentials: widget.apiCredentials,
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Add More Product",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  _buildTotalsSummary(subtotal, deliveryFee, tax, grandTotal),

                  SuggestedProducts(
                    apiCredentials: widget.apiCredentials,
                    products: const [8, 7, 5, 9],
                    onProductTap: navigateToProductScreen,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
      bottomNavigationBar: _buildCheckoutButton(grandTotal),
    );
  }

  Widget _buildLoadingCartItem(String name, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(width: 50, height: 50, color: Colors.grey[200]),
        title: Text(name),
        subtitle: const Text('Loading details...'),
        trailing: Text('Qty: $quantity'),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    String name,
    String imageUrl,
    double unitPrice,
    double itemTotal,
    int quantity,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90,
                height: 90,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  'PKR ${unitPrice.toStringAsFixed(0)} / unit',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  'PKR ${itemTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: ElevatedButton(
                  onPressed: onDecrement,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: ElevatedButton(
                  onPressed: onIncrement,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.amber.withValues(alpha: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSummary(
    double subtotal,
    double deliveryFee,
    double tax,
    double grandTotal,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          _buildSummaryRow("Subtotal", subtotal),
          _buildSummaryRow("Delivery Fee", deliveryFee),
          _buildSummaryRow("Tax", tax),
          const Divider(height: 20, thickness: 2),
          _buildSummaryRow("Grand Total", grandTotal, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            'PKR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.amber : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(double grandTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            createOrder();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.withValues(alpha: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            "Checkout (PKR ${grandTotal.toStringAsFixed(2)})",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
