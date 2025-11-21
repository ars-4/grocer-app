import 'package:flutter/material.dart';
import 'package:grocer/category_page.dart';
import 'package:grocer/cart_page.dart';
import 'package:grocer/account_page.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/favourites_page.dart';
import 'package:grocer/orders_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroceryScreen extends StatefulWidget {
  final ApiCredentials credentials;
  const GroceryScreen({super.key, required this.credentials});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  int _selectedIndex = 0;
  int userId = 0;
  late PageController _pageController;
  late List<Widget> _pages;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    int? fetchedUserId = prefs.getInt('user_id');

    if (mounted) {
      setState(() {
        userId = fetchedUserId ?? 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    _pageController = PageController();
    _pages = <Widget>[
      CategoryScreen(apiCredentials: widget.credentials),
      FavouritesScreen(apiCredentials: widget.credentials),
      CartScreen(apiCredentials: widget.credentials),
      AccountScreen(apiCredentials: widget.credentials),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<String> _titles = [
    'Your Address',
    'Favourites',
    'Cart',
    'Account',
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedIndex == 0)
              Text(
                "Delivery To",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                  color: Colors.black,
                ),
              ),
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(13, 249, 215, 3),
        elevation: 2.0,

        // actions: <Widget>[
        // IconButton(
        //   icon: const Icon(Icons.notifications_none, color: Colors.black),
        //   tooltip: 'Notifications',
        //   onPressed: () {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Notifications Button Tapped!')),
        //     );
        //   },
        // ),
        // IconButton(
        //   icon: const Icon(Icons.search, color: Colors.black),
        //   tooltip: 'Search',
        //   onPressed: () {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Search Button Tapped!')),
        //     );
        //   },
        // ),
        // ],
      ),

      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.amber.shade700),
                    child: const Text(
                      'Grocery App Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings Tapped!')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('Order History'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrdersScreen(
                            apiCredentials: widget.credentials,
                            customerId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('About Tapped!')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
              child: Text(
                'Built with ❤️ by Schediazo',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 8),
              ),
            ),
          ],
        ),
      ),

      // body: Center(child: _pages.elementAt(_selectedIndex)),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      /*
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return CategoryScreen();
              },
            ),
          ),
        },
        shape: const CircleBorder(),
        child: Icon(Icons.home, color: Colors.grey.shade600),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      */
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(13, 249, 215, 3),
          border: Border(
            top: BorderSide(color: Colors.amber.shade700, width: 0.4),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          // backgroundColor: Color.fromARGB(13, 249, 215, 3),
          selectedItemColor: Colors.amber.shade700,
          unselectedItemColor: Colors.grey.shade600,
          iconSize: 24.0,
          elevation: 0.0,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],

          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
