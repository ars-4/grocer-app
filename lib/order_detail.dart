import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/class/order.dart';

class OrderDetailScreen extends StatefulWidget {
  final ApiCredentials apiCredentials;
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.apiCredentials,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
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

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final baseApiUrl = widget.apiCredentials.api;
    final odooParams = widget.apiCredentials.odoo;

    final url = Uri.parse('$baseApiUrl/order/${widget.orderId}$odooParams');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;
      final Map<String, dynamic> orderJson = jsonDecode(response.body);

      setState(() {
        _order = Order.fromJson(orderJson);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Failed to load order details: ${e.toString().split(':')[0].trim()}';
        _isLoading = false;
      });
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
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 15),
              Text(
                'A little hiccup, dear! $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _fetchOrderDetail,
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order: ${order.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: Color(0xFF1E272E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStateColor(order.state).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getStateColor(order.state),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getStateLabel(order.state),
                          style: TextStyle(
                            color: _getStateColor(order.state),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 25),
                  _buildDetailRow(
                    label: 'Date Placed',
                    value:
                        '${order.dateOrder.day.toString().padLeft(2, '0')}/${order.dateOrder.month.toString().padLeft(2, '0')}/${order.dateOrder.year}',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    label: 'Customer',
                    value: order.partnerName,
                    icon: Icons.person_outline,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Items (${order.products.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E272E),
            ),
          ),
          const SizedBox(height: 10),

          // List of Order Lines
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.products.length,
            itemBuilder: (context, index) {
              final line = order.products[index];
              return _buildOrderLineTile(line);
            },
          ),

          const SizedBox(height: 20),

          // Totals Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.lightGreen.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildTotalRow(
                    label: 'Subtotal',
                    amount: order.products.fold(
                      0,
                      (sum, line) => sum + line.amount,
                    ),
                    isBold: false,
                  ),
                  const Divider(height: 20),
                  _buildTotalRow(
                    label: 'Grand Total',
                    amount: order.amountTotal,
                    isBold: true,
                    fontSize: 24,
                    color: Colors.green.shade700,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderLineTile(OrderLine line) {
    final unitPrice = line.qty > 0 ? (line.amount / line.qty) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${line.qty}x',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.amber.shade700,
              ),
            ),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Rs. ${unitPrice.toStringAsFixed(2)} / unit',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            'Rs. ${line.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1E272E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow({
    required String label,
    required int amount,
    bool isBold = false,
    double fontSize = 18,
    Color color = const Color(0xFF1E272E),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          'Rs. ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _order?.name != null
              ? 'Order Details: #${_order!.name}'
              : 'Order Details',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: _buildBody(),
    );
  }
}
