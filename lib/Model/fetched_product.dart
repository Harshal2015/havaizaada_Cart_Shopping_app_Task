import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_cart_app/Model/product.dart';

Future<ProductResponse> fetchProducts() async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return ProductResponse(
      products:
          (jsonResponse['products'] as List).map((product) {
            Category category;
            try {
              category = Category.values.firstWhere(
                (e) => e.toString() == 'Category.${product['category']}',
              );
            } catch (e) {
              category = Category.BEAUTY; // Default category
            }

            AvailabilityStatus availabilityStatus;
            try {
              availabilityStatus = AvailabilityStatus.values.firstWhere(
                (e) =>
                    e.toString() ==
                    'AvailabilityStatus.${product['availabilityStatus']}',
              );
            } catch (e) {
              availabilityStatus = AvailabilityStatus.IN_STOCK;
            }

            ReturnPolicy returnPolicy;
            try {
              returnPolicy = ReturnPolicy.values.firstWhere(
                (e) =>
                    e.toString() == 'ReturnPolicy.${product['returnPolicy']}',
              );
            } catch (e) {
              returnPolicy = ReturnPolicy.NO_RETURN_POLICY;
            }

            return Product(
              id: product['id'],
              title: product['title'],
              description: product['description'],
              category: category,
              price:
                  (product['price'] is int)
                      ? (product['price'] as int).toDouble()
                      : product['price'],
              discountPercentage:
                  (product['discountPercentage'] is int)
                      ? (product['discountPercentage'] as int).toDouble()
                      : product['discountPercentage'],
              rating:
                  (product['rating'] is int)
                      ? (product['rating'] as int).toDouble()
                      : product['rating'],
              stock: product['stock'],
              tags: List<String>.from(product['tags']),
              brand: product['brand'],
              sku: product['sku'],
              weight: product['weight'],
              dimensions: Dimensions(
                width:
                    (product['dimensions']['width'] is int)
                        ? (product['dimensions']['width'] as int).toDouble()
                        : product['dimensions']['width'],
                height:
                    (product['dimensions']['height'] is int)
                        ? (product['dimensions']['height'] as int).toDouble()
                        : product['dimensions']['height'],
                depth:
                    (product['dimensions']['depth'] is int)
                        ? (product['dimensions']['depth'] as int).toDouble()
                        : product['dimensions']['depth'],
              ),
              warrantyInformation: product['warrantyInformation'],
              shippingInformation: product['shippingInformation'],
              availabilityStatus: availabilityStatus,
              reviews:
                  (product['reviews'] as List)
                      .map(
                        (review) => Review(
                          rating: review['rating'],
                          comment: review['comment'],
                          date: DateTime.parse(review['date']),
                          reviewerName: review['reviewerName'],
                          reviewerEmail: review['reviewerEmail'],
                        ),
                      )
                      .toList(),
              returnPolicy: returnPolicy,
              minimumOrderQuantity: product['minimumOrderQuantity'],
              meta: Meta(
                createdAt: DateTime.parse(product['meta']['createdAt']),
                updatedAt: DateTime.parse(product['meta']['updatedAt']),
                barcode: product['meta']['barcode'],
                qrCode: product['meta']['qrCode'],
              ),
              images: List<String>.from(product['images']),
              thumbnail: product['thumbnail'],
            );
          }).toList(),
      total: jsonResponse['total'],
      skip: jsonResponse['skip'],
      limit: jsonResponse['limit'],
    );
  } else {
    throw Exception('Failed to load products');
  }
}
