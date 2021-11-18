import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './product.dart';

/*  ChangeNotifier: kind of related to the inherited widget that the provider package uses,
 *                  and allows us to establish behind the scene communication turnel with the
 *                  help of context object in every widget.
 *  - The class will be used as a Provider package which uses inherited widget behind the scene
 *    to establish a communication channel between this class and widgets that are interested for us.
 *  - It also needs to be provided to the widget at a highest point leading to child widgets which are 
 *    interested in data provided by this class.
 */
class Products with ChangeNotifier {
  final List<Product> _items = [
    // A list which can be changed over time and not final
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  List<Product> get items {
    return [
      ..._items
    ]; // Return a copy of "_items" to ensure it can't be changed directly from outside
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id.toString() == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  /* Add a new product into the current list of products */
  void addProduct(Product product) {
    final url = Uri.https(
        "flutter-cart-1-default-rtdb.firebaseio.com", "/products.json");
    http
        .post(
      url,
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'isFavorite': product.isFavorite,
      }),
    )
        .then((response) {
      print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners(); // Notify widget classes listening to this class about changes in "_items" to be rebuilt
    });
  }

  /* Edit and update the information about the selected product */
  void updateProduct(String id, Product newProduct) {
    final prodIndex = _items.indexWhere((prod) => prod.id.toString() == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  /* Delete a specific product based on an product-id provided by someone */
  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id.toString() == id);
    notifyListeners();
  }
}
