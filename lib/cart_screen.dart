import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'payment_screen.dart'; // Make sure this import is here!

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  
  // Helper: Calculate Total Price
  double getTotalPrice() {
    double total = 0;
    for (var item in userCart) {
      double price = double.parse(item['price'].toString());
      int qty = item['quantity'] as int;
      total += (price * qty);
    }
    return total;
  }

  // Helper: Show Confirmation Dialog before deleting
  void showDeleteConfirmation(int index, String itemName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Item?"),
        content: Text("Are you sure you want to remove $itemName from your cart?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                userCart.removeAt(index); // Actually delete it
              });
              Navigator.of(ctx).pop(); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Item removed"), duration: Duration(milliseconds: 500)),
              );
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: userCart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("Your cart is empty", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                // 1. LIST OF ITEMS
                Expanded(
                  child: ListView.builder(
                    itemCount: userCart.length,
                    itemBuilder: (context, index) {
                      final item = userCart[index];
                      final double itemTotal = double.parse(item['price'].toString()) * (item['quantity'] as int);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              // Food Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.fastfood, color: Colors.deepPurple),
                              ),
                              const SizedBox(width: 15),

                              // Name & Price Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text("RM ${item['price']} each", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 5),
                                    Text("Total: RM ${itemTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),

                              // BUTTONS ROW
                              Row(
                                children: [
                                  // MINUS BUTTON
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        if (item['quantity'] > 1) {
                                          item['quantity']--;
                                        } else {
                                          showDeleteConfirmation(index, item['name']);
                                        }
                                      });
                                    },
                                  ),
                                  
                                  // QUANTITY NUMBER
                                  Text(
                                    "${item['quantity']}",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),

                                  // PLUS BUTTON
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        item['quantity']++;
                                      });
                                    },
                                  ),
                                  
                                  // TRASH ICON
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                    onPressed: () {
                                       showDeleteConfirmation(index, item['name']);
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. CHECKOUT AREA
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Grand Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("RM ${getTotalPrice().toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            // NAVIGATE TO PAYMENT SCREEN
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(totalAmount: getTotalPrice()),
                              ),
                            );
                          },
                          child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}