import 'package:flutter/material.dart';
import 'package:grocer/order_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grocer/class/order.dart';
import 'package:grocer/class/api_credentials.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final String Function(String) getStateLabel;
  final Color Function(String) getStateColor;
  final ApiCredentials apiCredentials;

  const OrderTile({
    super.key,
    required this.order,
    required this.getStateLabel,
    required this.getStateColor,
    required this.apiCredentials,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: #${order.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${order.dateOrder.day}/${order.dateOrder.month}/${order.dateOrder.year}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    // 🚨 Manual currency formatting (No more 'intl')
                    Text(
                      'Rs. ${order.amountTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStateColor(order.state).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: getStateColor(order.state),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    getStateLabel(order.state),
                    style: TextStyle(
                      color: getStateColor(order.state),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  color: Colors.amber,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(
                          apiCredentials: apiCredentials,
                          orderId: order.id,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersScreen extends StatefulWidget {
  final ApiCredentials apiCredentials;
  final int customerId;

  const OrdersScreen({
    super.key,
    required this.apiCredentials,
    required this.customerId,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _showSnackBar(String message, String type) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: type == "error" ? Colors.red : Colors.amber,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getStateLabel(String state) {
    switch (state) {
      case 'sale':
        return 'Confirmed';
      case 'draft':
        return 'Pending';
      case 'cancel':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'sale':
        return Colors.green.shade700;
      case 'draft':
        return Colors.amber.shade700;
      case 'cancel':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final baseApiUrl = widget.apiCredentials.api;
    final odooParams = widget.apiCredentials.odoo;
    final url = Uri.parse(
      '$baseApiUrl/orders$odooParams&customer_id=${widget.customerId}',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (!mounted) return;
      final List<dynamic> ordersJson = jsonDecode(response.body);
      setState(() {
        _orders = ordersJson.map((json) => Order.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Network error occurred. Please try again.';
        _isLoading = false;
      });
      _showSnackBar('An unexpected error occurred', "error");
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.red.shade700,
              ),
              const SizedBox(height: 10),
              Text(
                'Oops! $_errorMessage',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Refresh Orders',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              "You haven't placed any orders yet, dear.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return OrderTile(
          order: order,
          getStateLabel: _getStateLabel,
          getStateColor: _getStateColor,
          apiCredentials: widget.apiCredentials,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => {Navigator.of(context).pop()},
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isLoading ? null : _fetchOrders,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
