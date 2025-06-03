import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Future<Map<String, dynamic>> fetchProductDetails() async {
    var productDoc = await FirebaseFirestore.instance
        .collection('Category') // Ensure this matches your Firestore collection name
        .doc(widget.productId)
        .get();

    if (!productDoc.exists) {
      throw Exception('Product not found');
    }

    return productDoc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    int selection = 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: FutureBuilder<Map<String, dynamic>>(
          future: fetchProductDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text("Product Detail");
            }
            var product = snapshot.data!;
            return Text(
              "${product['name'] ?? 'Unknown'} - ${product['cat'] ?? 'Category'}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFC59D54),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No product details available.'));
          }

          var product = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the product image with proper fit
                        Container(
                          height: 250,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: product['image'] != null
                              ? Image.network(
                                  product['image'],
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(child: Text('Image not available'));
                                  },
                                )
                              : const Center(child: Text('No image available')),
                        ),
                        const SizedBox(height: 16),
                        // Product Name and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              'RM ${(product['price'] ?? 0.00).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Product Category
                        Text(
                          'Category: ${product['cat'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              // Add to Cart and Buy Now buttons at the bottom
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (product['status'] != 'In Stock')
                        ? null
                        : () {
                          setState(() {
                            selection = 0;
                          });
                          _showPopup(context, product, selection);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC59D54),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Add to cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (product['status'] != 'In Stock')
                        ? null
                        :() {
                          setState(() {
                            selection = 1;
                          });
                          _showPopup(context, product, selection);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC59D54),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Buy now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPopup(BuildContext context, Map<String, dynamic> product, int index) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Image
                  if (product['image'] != null)
                    Image.network(
                      product['image'],
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 10),
                  // Product Name and Price
                  Text(
                    product['name'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'RM ${(product['price'] ?? 0.00).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity:', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (quantity > 1) quantity--;
                              });
                            },
                          ),
                          Text('$quantity', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () => (index == 0) ? 
                    _savedToCart(context, product, quantity) : 
                    _buyNow(context, product, quantity),
                  //onPressed: () => _savedToCart(context, product, quantity),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _savedToCart(BuildContext context, Map<String, dynamic> product, int quantity) async {
     try{
      // Get the reference to the cart collection
      var cartCollection = FirebaseFirestore.instance.collection('cart');
      var user = FirebaseAuth.instance.currentUser!.uid;

      // Check if the product already exists in the cart
      var querySnapshot = await cartCollection
        .where('name', isEqualTo: product['name'])
        .where('user', isEqualTo: user)
        .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Product already exists in the cart, update quantity
        var existingDoc = querySnapshot.docs.first;
        int existingQuantity = existingDoc['quantity'];
        int newQuantity = existingQuantity + quantity;

        // Update the quantity in Firestore
        await cartCollection.doc(existingDoc.id).update({'quantity': newQuantity});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} quantity updated in cart!')),
        );
      }else{
          await FirebaseFirestore.instance.collection('cart').add({
          'name': product['name'] ?? 'Unknown',
          'cat': product['cat'] ?? 'Unknown',
          'price': product['price'] ?? 0.00,
          'quantity': quantity,
          'image': product['image'], 
          'user': user,
          'timestamp': FieldValue.serverTimestamp(), // Optional: Track when the item was added
        });
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} added to cart!')),
        );
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
    Navigator.pop(context);
  }

  Future<void> _buyNow(BuildContext context, Map<String, dynamic> product, int quantity) async {
    List<String> id = [widget.productId];

    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => CheckOut(selectedItems: id, isFromCart: false, quantity: quantity,)),
    );
  }
}
