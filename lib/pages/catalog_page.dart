import 'package:flutter/material.dart';
import 'package:flutter_4/services/api_service.dart';
import 'package:flutter_4/components/game_item.dart';
import 'package:flutter_4/models/cart_item.dart';
import 'package:flutter_4/models/game.dart';

class CatalogPage extends StatefulWidget {
  final Function(Game) onFavoriteToggle;
  final List<Game> favoriteGames;
  final List<CartItem> cart;
  final Function(Game) addToCart;
  final Function(Game) removeFromCart;

  const CatalogPage(
      {super.key,
      required this.onFavoriteToggle,
      required this.favoriteGames,
      required this.cart,
      required this.addToCart,
      required this.removeFromCart});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<Game>> _games;
  String _searchQuery = '';

  void _showAddGameDialog() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новую игру'),
          content: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Артикул'),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'URL изображения'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Цена'),
              ),
            ],
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                final newGame = Game(
                  idController.text,
                  titleController.text,
                  descriptionController.text,
                  imageUrlController.text,
                  int.parse(priceController.text),
                );

                final gameFromApi = await ApiService().addGame(newGame);
                final currentGames = await _games;

                setState(() {
                  _games = Future.value([...currentGames, gameFromApi]);
                });

                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _removeFromGames(Game game) async {
    await ApiService().deleteGame(game);
    setState(() {
      _games = Future.value(_games.then((gameList) {
        gameList.remove(game);
        return gameList;
      }));
    });
  }

  @override
  void initState() {
    super.initState();
    _games = _loadGames();
  }

  Future<List<Game>> _loadGames() async {
    List<Game> games = await ApiService().getProducts();
    if (_searchQuery.isNotEmpty) {
      games = games.where((game) => game.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return games;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _games = _loadGames();
    });
  }

  Future<void> _refreshGames() async {
    setState(() {
      _games = _loadGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Каталог игр",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  showCursor: false,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
            onRefresh: _refreshGames,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<Game>>(
                future: _games,
                builder:
                    (BuildContext context, AsyncSnapshot<List<Game>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Нет игр в каталоге.'));
                  }

                  final games = snapshot.data!;

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 6 / 12,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: games.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return Dismissible(
                        key: Key(games[index].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Подтверждение удаления'),
                              content: const Text(
                                  'Вы уверены, что хотите удалить этот элемент из каталога?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Удалить'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "${games[index].name} удален из каталога"),
                            ),
                          );
                          _removeFromGames(games[index]);
                        },
                        child: GameItem(
                          game: games[index],
                          liked: widget.favoriteGames.contains(games[index]),
                          onFavoriteToggle: () =>
                              widget.onFavoriteToggle(games[index]),
                          quantityInCart: widget.cart
                              .firstWhere(
                                (position) => position.id == games[index].id,
                                orElse: () =>
                                    CartItem(games[index].id, 0, games[index]),
                              )
                              .quantity,
                          addToCart: () => widget.addToCart(games[index]),
                          removeFromCart: () =>
                              widget.removeFromCart(games[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            )),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 40,
              right: 0,
              child: SizedBox(
                height: 70,
                width: 70,
                child: FloatingActionButton(
                  onPressed: () => _showAddGameDialog(),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  enableFeedback: true,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        ));
  }
}
