import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'button.dart';
import 'checkout.dart';

class ShoppingCart extends StatefulWidget{
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  final List<String> _itemSelected = [];
  final List<bool> _selectedItems = []; 
  final Map<String, int> _quantities = {};
  double totalPrice = 0;
  late final double total;
  int _totalSelected = 0;
  bool _selectAll = true;
  bool _isEditing = false;

  @override
  void dispose() {
    _itemSelected.clear();
    _selectedItems.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    print(user!.uid);

    FirebaseFirestore.instance
      .collection('cart')
      .where('user', isEqualTo: user.uid)
      .get()
      .then((querySnapshot){
      final cartItems = querySnapshot.docs;

      setState(() {
        _selectedItems.clear();
        _selectedItems.addAll(List.generate(cartItems.length, (_)=>true));

        for(var item in cartItems){
        _quantities[item.id] = item['quantity'] ?? 1;
        }

        totalPrice = 0;
        for (var item in cartItems) {
          totalPrice += (item['price'] ?? 0) * (item['quantity'] ?? 1);
          _itemSelected.add(item.id);
        }
        total = totalPrice;
      });
      
      print('List: $_itemSelected, Total Price: $total');

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Cart', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
            )
          ),
        backgroundColor: const Color(0xFFC59D54),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined
          ),
          iconSize: 32,
          color: const Color.fromARGB(255, 255, 255, 255),
          ),
        actions: [TextButton(
          onPressed: (_selectedItems.isEmpty) ? 
            null : 
            () => setState(() {
              _isEditing = !_isEditing;
            }),
          child: Text(
            _isEditing ? 'Done' : 'Edit', 
            style: TextStyle(
              fontSize: 20,
              color: (_selectedItems.isEmpty) ? Colors.grey[400] : Colors.white,
            ),
            ),
        )],
      ),
      
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('cart')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(), 
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              )
            );
          }

          final cartItems = snapshot.data!.docs;
          
          // Initialize _selectedItems if empty or length mismatch
          if (_selectedItems.isEmpty || _selectedItems.length != cartItems.length) {
            _selectedItems.clear();
            _selectedItems.addAll(List.generate(cartItems.length, (_) => true));
          }

          // Now calculate total price
          totalPrice = 0;
          for (int i = 0; i < cartItems.length; i++) {
            if (_selectedItems[i]) {
              final item = cartItems[i];
              totalPrice += (item['price'] ?? 0) * (_quantities[item.id] ?? 1);
            }
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final product = cartItems[index];
              return Column(
                children: [
                  const SizedBox(height: 10,),
                  itemDetail(product, index),
                ],
              );
            }
          );
        }
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: _selectAll, 
                  onChanged: (_selectedItems.isEmpty) ?
                    null :
                    (bool? value){
                    setState(() {
                      if(_totalSelected == _selectedItems.length){
                        _selectAll = true;
                      }

                      _selectAll = value ?? false;
                      if(_selectAll){
                        _selectedItems.fillRange(0, _selectedItems.length, true);
                        _totalSelected = _selectedItems.length;
                        totalPrice = total;
                      }else{
                        _selectedItems.fillRange(0, _selectedItems.length, false);
                        totalPrice = 0;
                      }
                    });
                  }
                ),
                  const Text('All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Total:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text('RM ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: _selectedItems.isNotEmpty ? (){
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => CheckOut(selectedItems: _itemSelected, isFromCart: true,),
                      ),
                    );
                  } : null, 
                  style: payButton,
                  child: const Text(
                    'Check Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    )
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateQuantity(String pid, int qty){
    FirebaseFirestore.instance
              .collection('cart')
              .doc(pid)
              .update({'quantity': qty});
  }

  Widget itemDetail(QueryDocumentSnapshot product, int index){
    final productId = product.id;
    final productName = product['name'] ?? 'Product Name';
    final productCat = product['cat'] ?? 'Category'; 
    final num price = product['price'] ?? 0.00;
    int quantity = _quantities[productId] ?? 1;
    num sumPrice = price * quantity;

    return Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isEditing
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    FirebaseFirestore.instance
                        .collection('cart')
                        .doc(productId)
                        .delete(); // Remove item from Firestore
                    _selectedItems.removeAt(index); // Remove from selected list
                    _quantities.remove(productId); // Remove quantity tracking
                  });
                },
              )
            : Checkbox(
                value: _selectedItems[index],
                onChanged: (bool? value) {
                  setState(() {
                    _selectedItems[index] = value ?? false;
                    if (_selectedItems[index]) {
                      totalPrice += (price * quantity);
                      _itemSelected.add(productId);
                    } else {
                      totalPrice -= (price * quantity);
                      _itemSelected.remove(productId);
                    }

                    // Update _selectAll status
                    _selectAll = !_selectedItems.contains(false) ? true : false;
                  });
                },
              ),

           Image.network(
            product['image'],
            width: 150,
            height: 150,
           ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                
                    Text(productCat,
                      style: const TextStyle(
                        fontSize: 14
                      ),
                    ),
                
                    const SizedBox(height: 50,),
                    Row(
                      children: [
                        Text('RM ${sumPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                        const SizedBox(width: 25),
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.black)
                                  ),
                                ),
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      if(_quantities[productId]! > 1){
                                        _quantities[productId] = _quantities[productId]! - 1;
                                        totalPrice -= price;
                                        sumPrice -= price;
                                        updateQuantity(productId, _quantities[productId]!);
                                      }else{
                                        showDialog(
                                          context: context, 
                                          builder: (BuildContext context){
                                            return AlertDialog(
                                              title: const Text('Cannot Remove'),
                                              content: const Text('The minimum quantity can only be one.'),
                                              actions: <Widget>[
                                                TextButton(onPressed: Navigator.of(context).pop, child: const Text('OK'))
                                              ],
                                            );
                                          }
                                        );
                                      }
                                    });
                                  },
                                  child: const Icon(
                                    Icons.remove,
                                    size: 20,
                                  ),
                                ),
                              ),
                              
                              
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10
                                ),
                                child: Text('$quantity',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
              
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.black)
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _quantities[productId] = _quantities[productId]! + 1;
                                      totalPrice += price;
                                      sumPrice += price;
                                      updateQuantity(productId, _quantities[productId]!);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    size: 20,
                                  ),
                                ),
                              )
                            ],
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