import 'package:dio/dio.dart';
import 'package:flutter_4/models/game.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseurl = "https://pets.sirok.space";

  Future<List<Game>> getProducts() async {
    try {
      final response = await _dio.get('${baseurl}/products');
      if (response.statusCode == 200) {
        List<Game> games =
            (response.data as List).map((game) => Game.fromJson(game)).toList();
        return games;
      } else {
        throw Exception('Failed to load games');
      }
    } catch (e) {
      throw Exception('Error fetching games: $e');
    }
  }

  Future<Game> addGame(Game game) async {
    try {
      final response =
          await _dio.post('${baseurl}/products/create', data: game.toJson());
      if (response.statusCode == 200) {
        Game newGame = Game.fromJson(response.data);
        return newGame;
      } else {
        throw Exception('Faild to create game');
      }
    } catch (e) {
      throw Exception('Error adding game: $e');
    }
  }

  Future<Game> updateGame(Game game) async {
    try {
      final response = await _dio.put('${baseurl}/products/update/${game.id}',
          data: game.toJson());
      if (response.statusCode == 200) {
        Game updatedGame = Game.fromJson(response.data);
        return updatedGame;
      } else {
        throw Exception('Faild to update game');
      }
    } catch (e) {
      throw Exception('Error updating game $e');
    }
  }

  Future<void> deleteGame(Game game) async {
    try {
      final response = await _dio.delete('$baseurl/products/delete/${game.id}');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete game');
      }
    } catch (e) {
      throw Exception('Error deleting game: $e');
    }
  }
}
