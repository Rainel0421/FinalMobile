import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> get favorites => _favoriteIds;

  FavoriteProvider() {
    _loadFavorites(); // Load favorites on provider initialization
  }

  // Toggle favorite status
  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;

    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId); // Remove from Firestore
    } else {
      _favoriteIds.add(productId);
      await _addFavorite(productId); // Add to Firestore
    }

    notifyListeners();
  }

  // Check if a product is favorited
  bool isExist(DocumentSnapshot product) {
    return _favoriteIds.contains(product.id);
  }

  // Add favorite to Firestore
  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection('favorites').doc(productId).set({
        'isFavorite': true, // Add item as favorite in Firestore
      });
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  // Remove favorite from Firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection('favorites').doc(productId).delete();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  // Load favorites from Firestore
  Future<void> _loadFavorites() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('favorites').get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error loading favorites: $e');
    }
    notifyListeners();
  }

  // Static method to access the provider from any context
  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
