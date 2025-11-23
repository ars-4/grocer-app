class CartService {
  static final Map<int, int> _cartItems = {};

  static void addToCart(int productId) {
    _cartItems.update(productId, (value) => value + 1, ifAbsent: () => 1);
  }

  static int getItemQuantity(int productId) {
    return _cartItems[productId] ?? 0;
  }

  static Map<int, int> get cart => _cartItems;
}
