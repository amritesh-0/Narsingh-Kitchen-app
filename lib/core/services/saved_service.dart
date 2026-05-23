import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedService extends ChangeNotifier {
  SavedService._() {
    _load();
  }

  static final SavedService instance = SavedService._();

  static const _savedIdsKey = 'saved_product_ids';

  final Set<String> _savedIds = <String>{};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<String> get savedIds => _savedIds.toList(growable: false);

  bool isSaved(String productId) => _savedIds.contains(productId);

  Future<void> toggle(String productId) async {
    if (_savedIds.contains(productId)) {
      _savedIds.remove(productId);
    } else {
      _savedIds.add(productId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String productId) async {
    if (_savedIds.remove(productId)) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIds
      ..clear()
      ..addAll(prefs.getStringList(_savedIdsKey) ?? const <String>[]);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedIdsKey, savedIds);
  }
}
