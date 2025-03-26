import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_cart_app/view_classes/constant_variables/constant_colors.dart';
import 'package:shopping_cart_app/view_classes/constant_variables/constant_integers.dart';
import 'package:shopping_cart_app/view_classes/constant_variables/constant_variables.dart';
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
      title: ConstantVariables.productCatalogueText,
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
              image:
                  product.images.isNotEmpty
                      ? product.images[ConstantIntegers.addToCartImageValue]
                      : '',
              quantity: ConstantIntegers.addToCartQuantity,
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            '${product.title} ${ConstantVariables.addToCartMessage}',
          ),
          duration: Duration(
            seconds: ConstantIntegers.addToCartMessageSecondsValue,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstantColors.appBarColor,
        title: Text(ConstantVariables.catalogueText),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.black),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: ConstantIntegers.shoppingCartPositionRight,
                    top: ConstantIntegers.shoppingCartPositionTop,
                    child: CircleAvatar(
                      radius: ConstantIntegers.shoppingCartCircularAvatarRadius,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cartItems.length}',
                        style: TextStyle(
                          fontSize:
                              ConstantIntegers.shoppingCartCircularFontSize,
                          color: Colors.white,
                        ),
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
            padding: const EdgeInsets.all(ConstantIntegers.gridViewEdge),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ConstantIntegers.gridViewCrossAxisCount,
              childAspectRatio: ConstantIntegers.gridChildAspectRatio,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                name: product.title,
                brand: product.brand ?? 'Unknown',
                price: '₹${product.price}',
                discount:
                    '${((product.price - (product.price * (product.discountPercentage / ConstantIntegers.productCardCount))) / product.price * ConstantIntegers.productCardPriceCount).toStringAsFixed(ConstantIntegers.stringFixedValue)} % OFF',
                image: product.images.isNotEmpty ? product.images[0] : '',
                onAdd: () => onAddToCart(product),
              );
            },
          );
        }
        return Center(child: Text(ConstantVariables.noProductAvailableText));
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
      margin: const EdgeInsets.all(ConstantIntegers.productContainerEdge),
      child: Card(
        elevation: ConstantIntegers.productContainerElevation,
        color: ConstantColors.productContainerColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: ConstantIntegers.containerProductContainerHeight,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(ConstantIntegers.productCardRadius),
                    ),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  right: ConstantIntegers.productCardPositionRight,
                  bottom: ConstantIntegers.productCardPositionBottom,
                  child: ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ConstantIntegers.addElevatedButtonBorderRadius,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ConstantIntegers.addElevatedButtonHorizontal,
                        vertical: ConstantIntegers.addElevatedButtonVertical,
                      ),
                    ),
                    child: Text(ConstantVariables.addButtonText),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(ConstantIntegers.nameEdgePadding),
              child: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ConstantIntegers.brandPaddingHorizontal,
              ),
              child: Text(brand, style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: ConstantIntegers.pricePaddingVertical,
                horizontal: ConstantIntegers.pricePaddingHorizontal,
              ),
              child: Text(price, style: TextStyle(color: Colors.green)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ConstantIntegers.discountPaddingHorizontal,
              ),
              child: Text(discount, style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
