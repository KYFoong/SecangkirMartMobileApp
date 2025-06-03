import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProductSearchDelegate.dart';
import 'product_detail.dart'; // Import the ProductDetailScreen

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<Product> {
  int _selectedCategoryIndex = 0;
  List<String> categories = [
    "All",
    "Stationery",
    "Food&Snacks",
    "Beverages",
    "Personal Care",
    "Desserts"
  ];

  // Fetch products based on the selected category
  Stream<List<Map<String, String>>> fetchProducts(String categoryFilter) {
    final productsCollection = FirebaseFirestore.instance.collection('Category');
    Query query = productsCollection;

    // If category is not 'All', apply the category filter
    if (categoryFilter != "All") {
      query = query.where('cat', isEqualTo: categoryFilter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        print('Fetched product: $data'); // Log the fetched data for debugging

        // Safely fetch the 'status' field, providing a default value if it doesn't exist
        String status = data['status'] != null ? data['status'] as String : 'No status available';

        var price = data['price'];
        String priceString;
        if (price is num) {
          // Convert to double first to ensure decimal formatting works correctly
          priceString = "RM ${price.toStringAsFixed(2)}";  // Added RM and ensure 2 decimals
        } else{
          priceString = "RM 0.00";
        }

      return {
        'id': doc.id,
        'name': data['name'] as String,
        'cat': data['cat'] as String,
        'price': priceString,
        'image': data['image'] as String,
        'status': status,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: TextField(
              obscureText: false,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Search Product...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  onPressed: (){
                    showSearch(
                      context: context, 
                      delegate: ProductSearchDelegate()
                    );
                  }, 
                  icon: const Icon(Icons.search, color: Colors.grey)
                )
              ),
              onTap: (){
                showSearch(
                  context: context, 
                  delegate: ProductSearchDelegate()
                );
              },
            ),
            /*Row(
              children: [
                const Text(' Search Product',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20
                    )),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // When the search icon is clicked, navigate to the ProductSearchDelegate
                    showSearch(
                      context: context,
                      delegate: ProductSearchDelegate(),
                    );
                  },
                ),
              ],
            ),*/
          ),
          // Category selection widget
          CategorySelection(
            categories: categories,
            selectedCategoryIndex: _selectedCategoryIndex,
            onCategoryChanged: (index) {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
          ),

          // Product display widget
          Expanded(
            child: ProductList(
              selectedCategoryIndex: _selectedCategoryIndex,
              categories: categories,
              fetchProducts: fetchProducts(categories[_selectedCategoryIndex]),
            ),
          ),
        ],
      ),
    );
  }
}

class CategorySelection extends StatelessWidget {
  final List<String> categories;
  final int selectedCategoryIndex;
  final Function(int) onCategoryChanged;

  const CategorySelection({
    super.key,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          return GestureDetector(
            onTap: () => onCategoryChanged(index),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: selectedCategoryIndex == index
                    ? const Color(0xFFC59D54)
                    : Colors.grey, // Highlight selected category
              ),
              child: Padding(
                padding: const EdgeInsets.all(9.0),
                child: Text(
                  categories[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  final int selectedCategoryIndex;
  final List<String> categories;
  final Stream<List<Map<String, String>>> fetchProducts;

  const ProductList({
    super.key,
    required this.selectedCategoryIndex,
    required this.categories,
    required this.fetchProducts,
  });

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late Stream<List<Map<String, String>>> productsStream;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> allProducts = [];
  List<Map<String, String>> displayedProducts = [];

  @override
  void initState() {
    super.initState();
    productsStream = widget.fetchProducts; // Listen to real-time changes
    _searchController.addListener(_filterProducts); // Add listener for search
  }

  // Filter products based on search query and selected category
  void _filterProducts() {
    setState(() {
      displayedProducts = allProducts
          .where((product) {
        // Filter by category
        if (widget.selectedCategoryIndex == 0 || product['cat'] == widget.categories[widget.selectedCategoryIndex]) {
          // Filter by search query
          return product['name']!.toLowerCase().contains(_searchController.text.toLowerCase());
        }
        return false;
      })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, String>>>(  // Listen to changes
      stream: productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products available.'));
        }

        // Store all products
        allProducts = snapshot.data!;

        // Initially, display all products based on the selected category
        displayedProducts = allProducts
            .where((product) {
          return widget.selectedCategoryIndex == 0 || product['cat'] == widget.categories[widget.selectedCategoryIndex];
        })
            .toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: List.generate(
                  displayedProducts.length,
                      (index) {
                    var product = displayedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to ProductDetailScreen when a product is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(productId: product['id']!),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(product['image']!, width: 150, height: 150),
                          const SizedBox(width: 10),
                          Expanded(  // Wrap Text widget with Expanded to give space
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name']!,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  softWrap: true,  // Ensure the text wraps to the next line
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product['cat']!,
                                  style: const TextStyle(fontSize: 16),
                                  softWrap: true,  // Ensure the text wraps to the next line
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product['price']!,
                                  style: const TextStyle(fontSize: 14),
                                  softWrap: true,  // Ensure the text wraps to the next line
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product['status']!,
                                  style: (product['status'] == 'In Stock')
                                  ? const TextStyle(fontSize: 14)
                                  : const TextStyle(fontSize: 14, color: Colors.red),
                                  softWrap: true,  // Ensure the text wraps to the next line
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
