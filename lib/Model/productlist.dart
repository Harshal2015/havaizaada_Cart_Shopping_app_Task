import 'package:flutter/material.dart';
import 'package:shopping_cart_app/Model/product.dart';
import 'fetchprodect.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  late Future<ProductResponse> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductResponse>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
          return Center(child: Text('No products available.'));
        }

        List<Product> products = snapshot.data!.products;
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.title),
              subtitle: Text(product.brand ?? ''),
              trailing: Text('₹${product.price.toString()}'),
            );
          },
        );
      },
    );
  }
}
