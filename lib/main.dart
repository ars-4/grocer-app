import 'package:flutter/material.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/creds.dart';
import 'package:grocer/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocer/grocer_app.dart';

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatefulWidget {
  const GroceryApp({super.key});

  @override
  State<GroceryApp> createState() => _GroceryAppState();
}

class _GroceryAppState extends State<GroceryApp> {
  bool isLoggedIn = false;

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final userEmail = await getUserEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schediazo\'s Grocery App',
      theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: true),
      home: isLoggedIn
          ? GroceryScreen(
              credentials: ApiCredentials(
                api: api,
                odoo:
                    '?ODOO_DB=$odooDBName&ODOO_USER=$odooUser&ODOO_PASS=$odooPass',
              ),
            )
          : GrocerAuthPage(
              apiCredentials: ApiCredentials(
                api: api,
                odoo:
                    '?ODOO_DB=$odooDBName&ODOO_USER=$odooUser&ODOO_PASS=$odooPass',
              ),
            ),
    );
  }
}
