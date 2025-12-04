import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Futuristic Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E27),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF00F0FF),
            fontWeight: FontWeight.bold,
            fontSize: 28,
            shadows: [
              Shadow(
                color: Color(0xFF00F0FF),
                blurRadius: 10,
                offset: Offset(0, 0),
              ),
            ],
          ),
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
        ),
      ),
      home: const ProductStoreScreen(),
    );
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String? image;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown Product',
      description: json['description'] as String? ?? 'No description available',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String?,
    );
  }
}

class ProductStoreScreen extends StatefulWidget {
  const ProductStoreScreen({Key? key}) : super(key: key);

  @override
  State<ProductStoreScreen> createState() => _ProductStoreScreenState();
}

class _ProductStoreScreenState extends State<ProductStoreScreen> {
  late Future<List<Product>> futureProducts;
  Set<int> favorites = {};

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://fakestoreapi.com/products'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  void toggleFavorite(int productId) {
    setState(() {
      if (favorites.contains(productId)) {
        favorites.remove(productId);
      } else {
        favorites.add(productId);
      }
    });
  }

  void retryFetch() {
    setState(() {
      futureProducts = fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00F0FF), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'CYBER STORE',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF00F0FF),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          } else if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error.toString(), retryFetch);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyScreen();
          }

          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00F0FF), width: 3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 0.5 + (value * 0.5),
                    child: Transform.rotate(
                      angle: value * 6.28,
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Color(0xFF00F0FF),
                        size: 50,
                      ),
                    ),
                  );
                },
                onEnd: () {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'INITIALIZING CYBER STORE...',
            style: TextStyle(
              color: Color(0xFF00F0FF),
              fontSize: 14,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            height: 4,
            child: LinearProgressIndicator(
              backgroundColor: const Color(0xFF1A2F5F),
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF00F0FF).withOpacity(0.8),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error, VoidCallback onRetry) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF006E), width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF006E).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFFF006E),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SYSTEM ERROR',
                      style: TextStyle(
                        color: Color(0xFFFF006E),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      error.length > 100
                          ? '${error.substring(0, 100)}...'
                          : error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00F0FF),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F0FF).withOpacity(0.6),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text(
                    'RETRY CONNECTION',
                    style: TextStyle(
                      color: Color(0xFF00F0FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            color: Color(0xFF00F0FF),
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            'NO PRODUCTS AVAILABLE',
            style: TextStyle(
              color: Color(0xFF00F0FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isFavorite = favorites.contains(product.id);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isFavorite
              ? const Color(0xFFFF006E)
              : const Color(0xFF00F0FF).withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isFavorite
                ? const Color(0xFFFF006E).withOpacity(0.4)
                : const Color(0xFF00F0FF).withOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.9),
            const Color(0xFF0F1528).withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1528),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF00F0FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: product.image != null && product.image!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.network(
                        product.image!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Color(0xFF00F0FF),
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: Color(0xFF00F0FF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF00F0FF),
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No Image',
                            style: TextStyle(
                              color: Color(0xFF00F0FF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Content Container
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF00F0FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Expanded(
                    child: Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFB0B0B0).withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Buttons Row
                  Row(
                    children: [
                      // Buy Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added "${product.title}" to cart',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                backgroundColor: const Color(
                                  0xFF00F0FF,
                                ).withOpacity(0.8),
                                duration: const Duration(milliseconds: 1500),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF00F0FF),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00F0FF,
                                  ).withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'BUY',
                                style: TextStyle(
                                  color: Color(0xFF00F0FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Favorite Button
                      GestureDetector(
                        onTap: () => toggleFavorite(product.id),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isFavorite
                                  ? const Color(0xFFFF006E)
                                  : const Color(0xFF00F0FF).withOpacity(0.5),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: isFavorite
                                    ? const Color(0xFFFF006E).withOpacity(0.4)
                                    : const Color(0xFF00F0FF).withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFFFF006E)
                                : const Color(0xFF00F0FF),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
