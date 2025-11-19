import 'package:flutter/material.dart';
import 'package:grocer/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = "Fakhar Zaman";
  String userEmail = "fakhar.zaman@schediazo.com";
  final String _userImage = "https://demo.schediazo.com/logo.jpg";

  final List<Map<String, dynamic>> _accountOptions = [
    {
      "title": "My Orders",
      "icon": Icons.shopping_bag_outlined,
      "onTap": () => {},
    },
    {
      "title": "My Wallet",
      "icon": Icons.account_balance_wallet_outlined,
      "onTap": () => {},
    },
    {
      "title": "Shipping Addresses",
      "icon": Icons.location_on_outlined,
      "onTap": () => {},
    },
    {
      "title": "Favorite Products",
      "icon": Icons.favorite_border,
      "onTap": () => {},
    },
    {
      "title": "Payment Methods",
      "icon": Icons.credit_card_outlined,
      "onTap": () => {},
    },
  ];

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? fetchedEmail = prefs.getString('user_email');
    String? fetchedUserName = prefs.getString('user_name');
    if (mounted) {
      setState(() {
        userEmail = fetchedEmail ?? '';
        userName = fetchedUserName ?? '';
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    await prefs.remove('user_favorites_ids');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have been logged out!'),
        backgroundColor: Colors.amber,
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => GroceryApp()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  final List<Map<String, dynamic>> _settingsOptions = [
    {
      "title": "Notifications",
      "icon": Icons.notifications_none,
      "onTap": () => {},
    },
    {"title": "Help & Support", "icon": Icons.help_outline, "onTap": () => {}},
    {"title": "Privacy Policy", "icon": Icons.security, "onTap": () => {}},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 25),
            _buildSectionTitle("Account"),
            const SizedBox(height: 10),
            ..._accountOptions
                .map(
                  (option) => _buildOptionTile(
                    option["title"].toString(),
                    option["icon"] as IconData,
                    option["onTap"] as VoidCallback,
                  ),
                )
                .toList(),
            const Divider(height: 30),

            _buildSectionTitle("Settings"),
            const SizedBox(height: 10),
            ..._settingsOptions
                .map(
                  (option) => _buildOptionTile(
                    option["title"].toString(),
                    option["icon"] as IconData,
                    option["onTap"] as VoidCallback,
                  ),
                )
                .toList(),
            const Divider(height: 30),

            // 4. Logout Button
            _buildLogoutButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(_userImage),
            onBackgroundImageError: (exception, stackTrace) {},
            child: _userImage.isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.amber,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.amber, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          logout();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Log Out",
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
