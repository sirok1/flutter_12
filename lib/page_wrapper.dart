import 'package:flutter/material.dart';
import 'package:flutter_4/components/auth_gate.dart';
import 'package:flutter_4/components/cart_icon.dart';
import 'package:flutter_4/models/cart_item.dart';
import 'package:flutter_4/models/game.dart';
import 'package:flutter_4/pages/cart_page.dart';
import 'package:flutter_4/pages/catalog_page.dart';
import 'package:flutter_4/pages/favorites_page.dart';
import 'package:logger/logger.dart';

class PageWrapper extends StatefulWidget {
  final int selectedPageIndex;

  const PageWrapper({super.key, this.selectedPageIndex = 0});

  @override
  PageWrapperState createState() => PageWrapperState();
}

class PageWrapperState extends State<PageWrapper> {
  int _selectedPageIndex = 0;
  final Logger _logger = Logger();
  List<Game> _favoriteGames = [];
  List<CartItem> _cart = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _toggleFavorite(Game game) {
    setState(() {
      if (_favoriteGames.contains(game)) {
        _favoriteGames.remove(game);
      } else {
        _favoriteGames.add(game);
      }
    });
  }

  void _addToCart(Game game) {
    setState(() {
      try {
        final existingPosition =
            _cart.firstWhere((position) => position.data.id == game.id);
        existingPosition.quantity++;
      } catch (e) {
        _cart.add(CartItem(game.id, 1, game));
      }
    });
  }

  void _removeFromCart(Game game) {
    setState(() {
      try {
        final existingPosition =
            _cart.firstWhere((position) => position.data.id == game.id);
        if (existingPosition.quantity > 1) {
          existingPosition.quantity--;
        } else {
          _cart.remove(existingPosition);
        }
      } catch (e) {
        _logger.e("Ошибка при добавлении в корзину: $e");
      }
    });
  }

  void updateSelectedPageIndex(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      CatalogPage(
          favoriteGames: _favoriteGames,
          onFavoriteToggle: _toggleFavorite,
          addToCart: _addToCart,
          removeFromCart: _removeFromCart,
          cart: _cart),
      FavoritesPage(
          onFavoriteToggle: _toggleFavorite,
          favoriteGames: _favoriteGames,
          addToCart: _addToCart,
          removeFromCart: _removeFromCart,
          cart: _cart),
      CartPage(
        cart: _cart,
        addToCart: _addToCart,
        removeFromCart: _removeFromCart,
      ),
      AuthGate()
    ];
    return Scaffold(
      body: _pages.elementAt(_selectedPageIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Главная"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Отложенное"),
          BottomNavigationBarItem(
              icon: CartIcon(
                  itemCount: _cart.isNotEmpty? _cart
                      .map((position) => position.quantity)
                      .reduce((a, b) => a + b) : 0),
              label: "Корзина"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Профиль")
        ],
        currentIndex: _selectedPageIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
