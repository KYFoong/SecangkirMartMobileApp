import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail.dart'; // Import the ProductDetailScreen

class ProductSearchDelegate extends SearchDelegate {
  final TextEditingController _searchController = TextEditingController();

  @override
  String? get searchFieldLabel => 'Search products';

  @override
  TextInputType? get keyboardType => TextInputType.text;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';  // Clears the query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);  // Closes the search view
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('Category').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allProducts = snapshot.data!.docs
            .map((doc) => {
          'id': doc.id,  // Get the product document ID
          'name': doc['name'],
          'cat': doc['cat'],
          'price': doc['price'],
          'image': doc['image'],
          'status': doc['status'] ?? 'No status available',
        })
            .toList();

        final filteredProducts = allProducts
            .where((product) =>
            product['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            var product = filteredProducts[index];
            return ListTile(
              leading: Image.network(product['image']!, width: 50, height: 50),
              title: Text(product['name']!),
              subtitle: Text('${product['price']} - ${product['cat']}'),
              onTap: () {
                // Navigate to the product detail screen with the product ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      productId: product['id'],  // Pass the product ID to ProductDetailScreen
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context); // You can show the same results as in buildResults
  }
}
