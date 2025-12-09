import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class MenuScreen extends StatefulWidget {
  final String selectedCategory; // Changed from 'selectedCollege'

  const MenuScreen({super.key, required this.selectedCategory});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // 1. SMART FILTER LOGIC
    // We filter the massive foodMenu based on the category selected
    final categoryItems = foodMenu.where((item) {
      String icon = item['image_icon']!;
      String itemCat = 'Food & Drinks'; // Default assumption

      // Define logic for other categories
      if (icon == 'checkroom') itemCat = 'Fashion';
      if (['print', 'computer', 'save', 'cleaning_services', 'menu_book'].contains(icon)) itemCat = 'Services';

      return itemCat == widget.selectedCategory;
    }).toList();
    
    // 2. SEARCH LOGIC
    List<Map<String, String>> filteredItems = categoryItems;
    if (_searchQuery.isNotEmpty) {
      filteredItems = categoryItems.where((item) {
        final name = item['name']!.toLowerCase();
        final seller = item['seller']!.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || seller.contains(query);
      }).toList();
    }

    // 3. GET UNIQUE SELLERS FROM FILTERED LIST
    var uniqueSellers = filteredItems.map((item) => item['seller']).toSet().toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Browsing", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(widget.selectedCategory, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Search in ${widget.selectedCategory}...",
                    filled: true, fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ),

          // SELLER LIST
          Expanded(
            child: uniqueSellers.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 60, color: Colors.grey), SizedBox(height: 10), Text("No items found.", style: TextStyle(color: Colors.grey))]))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: uniqueSellers.length,
                    itemBuilder: (context, index) {
                      final sellerName = uniqueSellers[index];
                      // Find first item to get general info
                      final exampleItem = categoryItems.firstWhere((item) => item['seller'] == sellerName);
                      final bool isOpen = exampleItem['status'] == 'Open';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => FoodItemsScreen(sellerName: sellerName!, collegeName: exampleItem['college']!),
                          ));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                          child: Row(
                            children: [
                              Hero(
                                tag: "seller_$sellerName",
                                child: Container(
                                  height: 70, width: 70,
                                  decoration: BoxDecoration(color: isOpen ? Colors.deepPurple.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                                  child: Icon(
                                    widget.selectedCategory == 'Fashion' ? Icons.checkroom : widget.selectedCategory == 'Services' ? Icons.build : Icons.store, 
                                    size: 35, color: isOpen ? Colors.deepPurple : Colors.grey
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sellerName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 5),
                                    Text("Located in ${exampleItem['college']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 5),
                                    Text(isOpen ? "Open Now" : "Closed", style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// FOOD ITEMS SCREEN (Keep this mostly same, just slight visual tweaks)
class FoodItemsScreen extends StatefulWidget {
  final String sellerName;
  final String collegeName;

  const FoodItemsScreen({super.key, required this.sellerName, required this.collegeName});

  @override
  State<FoodItemsScreen> createState() => _FoodItemsScreenState();
}

class _FoodItemsScreenState extends State<FoodItemsScreen> {
  void refresh() { setState(() {}); }
  int getCartTotalCount() {
    int total = 0;
    for (var item in userCart) { total += (item['quantity'] as int); }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final sellerMenu = foodMenu.where((item) => item['seller'] == widget.sellerName).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0, floating: false, pinned: true, backgroundColor: Colors.deepPurple,
            leading: IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black)), onPressed: () => Navigator.pop(context)),
            actions: [
               Stack(children: [IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.shopping_cart, color: Colors.black)), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => refresh()); }), if (userCart.isNotEmpty) Positioned(right: 4, top: 4, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('${getCartTotalCount()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))],), const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(widget.sellerName, style: const TextStyle(color: Colors.white, fontSize: 16, shadows: [Shadow(color: Colors.black45, blurRadius: 5)])),
              background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent], begin: Alignment.bottomLeft, end: Alignment.topRight)), child: Center(child: Hero(tag: "seller_${widget.sellerName}", child: const Icon(Icons.store, size: 80, color: Colors.white24)))),
            ),
          ),
          SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                final food = sellerMenu[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 5)]),
                  child: Row(children: [
                      Container(width: 90, height: 90, decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(15)), 
                        child: Icon(
                          food['image_icon'] == 'checkroom' ? Icons.checkroom : food['image_icon'] == 'computer' ? Icons.computer : Icons.fastfood, 
                          color: Colors.orange, size: 40
                        )
                      ),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(food['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text("RM ${food['price']}", style: const TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.bold))])),
                      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: const CircleBorder(), padding: const EdgeInsets.all(12)), onPressed: () {
                          if (isGuest) { showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Login Required"), content: const Text("You need to be a registered student."), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple), onPressed: () { Navigator.pop(context); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false); }, child: const Text("Login Now", style: TextStyle(color: Colors.white)))])); return; }
                          setState(() { int existingIndex = userCart.indexWhere((item) => item['name'] == food['name'] && item['seller'] == food['seller']); if (existingIndex != -1) { userCart[existingIndex]['quantity'] = (userCart[existingIndex]['quantity'] as int) + 1; } else { Map<String, dynamic> newEntry = Map.from(food); newEntry['quantity'] = 1; userCart.add(newEntry); } });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added ${food['name']} to cart!"), duration: const Duration(milliseconds: 500), backgroundColor: Colors.green));
                        }, child: const Icon(Icons.add, color: Colors.white))
                    ]),
                );
              }, childCount: sellerMenu.length),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      ),
    );
  }
}