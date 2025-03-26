import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/cart_item.dart';
import 'cart_screen.dart';
import '../controller_class/fetched_product_api.dart';
import '../Model/product.dart';
import '../Model/cart_provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalogue',
      theme: ThemeData(primarySwatch: Colors.pink),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    void addToCart(Product product) {
      ref
          .read(cartProvider.notifier)
          .addToCart(
            CartItem(
              id: product.id,
              title: product.title,
              price: product.price,
              image: product.images.isNotEmpty ? product.images[0] : '',
              quantity: 1,
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('${product.title} added to cart!'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC9AB1F),
        title: Text('Catalogue'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.black),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cartItems.length}',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: ProductGrid(onAddToCart: addToCart),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final Function(Product) onAddToCart;

  const ProductGrid({super.key, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductResponse>(
      future: fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.products.isNotEmpty) {
          final products = snapshot.data!.products;
          return GridView.builder(
            padding: const EdgeInsets.all(4.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                name: product.title,
                brand: product.brand ?? 'Unknown',
                price: '₹${product.price}',
                discount:
                    '${((product.price - (product.price * (product.discountPercentage / 100))) / product.price * 100).toStringAsFixed(2)} % OFF',
                image: product.images.isNotEmpty ? product.images[0] : '',
                onAdd: () => onAddToCart(product),
              );
            },
          );
        }
        return Center(child: Text('No products available'));
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String brand;
  final String price;
  final String discount;
  final String image;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.name,
    required this.brand,
    required this.price,
    required this.discount,
    required this.image,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        color: Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4.0),
                    ),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    child: Text('Add'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(brand, style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 7),
              child: Text(price, style: TextStyle(color: Colors.green)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(discount, style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
