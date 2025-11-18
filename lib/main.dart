import 'package:flutter/material.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/creds.dart';
import 'package:grocer/auth_page.dart';

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schediazo\'s Grocery App',
      theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: true),
      home: GrocerAuthPage(
        apiCredentials: ApiCredentials(
          api: api,
          odoo: '?ODOO_DB=$odooDBName&ODOO_USER=$odooUser&ODOO_PASS=$odooPass',
        ),
      ),
    );
  }
}
