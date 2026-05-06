import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

class ProductService {
  static final ProductService instance = ProductService._();
  ProductService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Categories ──────────────────────────────────────────────────────────
  Stream<List<CategoryModel>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // ── Products ─────────────────────────────────────────────────────────────
  Stream<List<ProductModel>> getPopularProducts() {
    return _firestore
        .collection('products')
        .where('isPopular', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<ProductModel>> getProducts(ProductKind kind) {
    return _firestore
        .collection('products')
        .where('kind', isEqualTo: kind.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Helper to add dummy data for testing (optional)
  Future<void> seedDummyData() async {
    // Add categories
    final categories = [
      {'title': 'Fast Food', 'image': '🍔', 'color': 0xFFE53935},
      {'title': 'Tiffin', 'image': '🍱', 'color': 0xFFFF9800},
      {'title': 'Spices', 'image': '🌶️', 'color': 0xFF795548},
    ];

    for (var cat in categories) {
      await _firestore.collection('categories').add(cat);
    }

    // Add popular products
    final products = [
      {
        'name': 'Paneer Burger',
        'emoji': '🍔',
        'kind': 'fastFood',
        'price': 250.0,
        'rating': 4.8,
        'tag': 'Best Seller',
        'subtitle': 'Creamy paneer with spicy mayo',
        'isPopular': true,
      },
      {
        'name': 'Special Dal Tiffin',
        'emoji': '🍱',
        'kind': 'tiffinMeal',
        'price': 120.0,
        'rating': 4.9,
        'tag': 'Top Rated',
        'subtitle': 'Homestyle dal with rotis',
        'isPopular': true,
      },
    ];

    for (var prod in products) {
      await _firestore.collection('products').add(prod);
    }
  }

  // ── Admin CRUD ──────────────────────────────────────────────────────────
  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toFirestore());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}
