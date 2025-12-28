import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class MenuScreen extends StatefulWidget {
  final String selectedCategory;

  const MenuScreen({super.key, required this.selectedCategory});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _searchQuery = "";

  void refresh() {
    setState(() {}); // Updates UI when returning from Cart
  }

  int getCartTotalCount() {
    int total = 0;
    for (var item in userCart) {
      total += (item['quantity'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // 1. FILTER SELLERS BASED ON CATEGORY
    final categoryItems = foodMenu.where((item) {
      String icon = item['image_icon']!;
      String itemCat = 'Food & Drinks'; 
      if (icon == 'checkroom') itemCat = 'Fashion';
      if (['print', 'computer', 'save', 'cleaning_services', 'menu_book', 'build', 'layers'].contains(icon)) itemCat = 'Services';
      return itemCat == widget.selectedCategory;
    }).toList();
    
    // 2. SEARCH SELLERS OR ITEMS
    List<Map<String, String>> filteredItems = categoryItems;
    if (_searchQuery.isNotEmpty) {
      filteredItems = categoryItems.where((item) {
        final name = item['name']!.toLowerCase();
        final seller = item['seller']!.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || seller.contains(query);
      }).toList();
    }

    var uniqueSellers = filteredItems.map((item) => item['seller']).toSet().toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // FLOATING CART BUTTON
      floatingActionButton: userCart.isNotEmpty 
        ? FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => refresh());
            },
            backgroundColor: Colors.deepPurple,
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              "View Cart (${getCartTotalCount()})", 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
            ),
          )
        : null,
      
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
                // SEARCH BAR
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Search shops or items...",
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
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.search_off, size: 60, color: Colors.grey), const SizedBox(height: 10), const Text("No results found.", style: TextStyle(color: Colors.grey))]))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: uniqueSellers.length,
                    itemBuilder: (context, index) {
                      final sellerName = uniqueSellers[index];
                      final exampleItem = categoryItems.firstWhere((item) => item['seller'] == sellerName);
                      final bool isOpen = exampleItem['status'] == 'Open';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => FoodItemsScreen(sellerName: sellerName!, collegeName: exampleItem['college']!),
                          )).then((_) => refresh()); 
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

// --- ADVANCED FOOD ITEMS SCREEN ---

class FoodItemsScreen extends StatefulWidget {
  final String sellerName;
  final String collegeName;

  const FoodItemsScreen({super.key, required this.sellerName, required this.collegeName});

  @override
  State<FoodItemsScreen> createState() => _FoodItemsScreenState();
}

class _FoodItemsScreenState extends State<FoodItemsScreen> {
  final ScrollController _scrollController = ScrollController();
  Map<String, List<Map<String, String>>> groupedMenu = {};
  final Map<String, GlobalKey> sectionKeys = {};
  String selectedFilter = ""; 
  String _inShopSearch = ""; 
  bool _showSearch = false; 

  @override
  void initState() {
    super.initState();
    _processMenuData();
  }

  void _processMenuData() {
    groupedMenu.clear();
    sectionKeys.clear();
    
    final rawMenu = foodMenu.where((item) {
      bool matchSeller = item['seller'] == widget.sellerName;
      bool matchSearch = item['name']!.toLowerCase().contains(_inShopSearch.toLowerCase());
      return matchSeller && matchSearch;
    }).toList();
    
    for (var item in rawMenu) {
      String cat = _guessCategory(item['name']!, item['image_icon']!);
      if (!groupedMenu.containsKey(cat)) {
        groupedMenu[cat] = [];
        sectionKeys[cat] = GlobalKey(); 
      }
      groupedMenu[cat]!.add(item);
    }

    if (groupedMenu.isNotEmpty && selectedFilter.isEmpty) {
      selectedFilter = groupedMenu.keys.first;
    }
  }

  String _guessCategory(String name, String icon) {
    String lowerName = name.toLowerCase();
    if (icon == 'checkroom') return 'Apparel';
    if (['computer', 'save', 'cleaning_services', 'build'].contains(icon)) return 'Services';
    if (['print', 'menu_book', 'layers'].contains(icon)) return 'Printing';
    
    if (lowerName.contains('nasi') || lowerName.contains('mee') || lowerName.contains('burger') || lowerName.contains('spaghetti') || lowerName.contains('chicken') || lowerName.contains('chop')) return 'Mains';
    if (lowerName.contains('teh') || lowerName.contains('milo') || lowerName.contains('sirap') || lowerName.contains('nescafe') || lowerName.contains('shake') || lowerName.contains('drink')) return 'Drinks';
    return 'Others';
  }

  void _scrollToCategory(String category) {
    setState(() => selectedFilter = category);
    final key = sectionKeys[category];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut, alignment: 0.1);
    }
  }

  void refresh() { setState(() {}); }
  
  double getCartTotal() {
    double total = 0;
    for (var item in userCart) { 
      total += (double.tryParse(item['price'].toString()) ?? 0.0) * (item['quantity'] as int);
    }
    return total;
  }
  
  int getCartCount() {
    int total = 0;
    for (var item in userCart) { total += (item['quantity'] as int); }
    return total;
  }

  // --- SMART ADD TO CART DIALOG (FASHION AWARE) ---
  void _showAddToCartDialog(Map<String, String> food) {
    if (isGuest) {
      showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Login Required"), content: const Text("Please login to order."), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false); }, child: const Text("Login"))]));
      return;
    }

    int quantity = 1;
    TextEditingController remarksController = TextEditingController();
    
    // FASHION LOGIC
    bool isFashion = food['image_icon'] == 'checkroom';
    String selectedSize = 'M'; // Default Size
    List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food['name']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("RM ${food['price']}", style: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // --- SIZE SELECTOR (ONLY FOR FASHION) ---
                  if (isFashion) ...[
                    const Text("Select Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sizes.map((size) {
                          bool isSelected = selectedSize == size;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(size),
                              selected: isSelected,
                              selectedColor: Colors.deepPurple,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                              onSelected: (selected) {
                                if (selected) setModalState(() => selectedSize = size);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(onPressed: () { if(quantity > 1) setModalState(() => quantity--); }, icon: const Icon(Icons.remove_circle_outline)),
                          Text("$quantity", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(onPressed: () { setModalState(() => quantity++); }, icon: const Icon(Icons.add_circle, color: Colors.deepPurple)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Remarks
                  TextField(
                    controller: remarksController,
                    decoration: InputDecoration(
                      labelText: isFashion ? "Color / Special Request" : "Special Instructions",
                      hintText: isFashion ? "e.g. Black color" : "e.g. No spicy",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        setState(() {
                          // Construct Remarks: Combine Size + User Input
                          String finalRemarks = remarksController.text;
                          if (isFashion) {
                            finalRemarks = "Size: $selectedSize. $finalRemarks";
                          }

                          // Logic to add to cart
                          // Note: For fashion, we treat different sizes as different items, so we check remarks/size too
                          int existingIndex = userCart.indexWhere((item) => 
                            item['name'] == food['name'] && 
                            item['seller'] == food['seller'] &&
                            (!isFashion || (item['remarks'] ?? '').contains("Size: $selectedSize")) // Strict check for fashion size
                          );

                          if (existingIndex != -1) {
                            userCart[existingIndex]['quantity'] = (userCart[existingIndex]['quantity'] as int) + quantity;
                          } else {
                            Map<String, dynamic> newEntry = Map.from(food);
                            newEntry['quantity'] = quantity;
                            newEntry['remarks'] = finalRemarks;
                            userCart.add(newEntry);
                          }
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added $quantity x ${food['name']}"), backgroundColor: Colors.green));
                      },
                      child: Text("Add to Cart - RM ${(double.parse(food['price']!) * quantity).toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    _processMenuData(); 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 160.0, floating: false, pinned: true, backgroundColor: Colors.deepPurple,
                leading: IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black)), onPressed: () => Navigator.pop(context)),
                actions: [IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.search, color: Colors.black)), onPressed: () => setState(() => _showSearch = !_showSearch)), const SizedBox(width: 15)],
                flexibleSpace: FlexibleSpaceBar(centerTitle: true, title: Text(widget.sellerName, style: const TextStyle(color: Colors.white, fontSize: 16, shadows: [Shadow(color: Colors.black45, blurRadius: 5)])), background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent], begin: Alignment.bottomLeft, end: Alignment.topRight)), child: Center(child: Hero(tag: "seller_${widget.sellerName}", child: const Icon(Icons.store, size: 80, color: Colors.white24))))),
              ),
              if (_showSearch) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(15.0), child: TextField(autofocus: true, onChanged: (val) => setState(() => _inShopSearch = val), decoration: InputDecoration(hintText: "Search in ${widget.sellerName}...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))))),
              SliverPersistentHeader(delegate: _SliverCategoryHeaderDelegate(categories: groupedMenu.keys.toList(), selectedCategory: selectedFilter, onCategorySelected: _scrollToCategory), pinned: true),
              SliverPadding(padding: const EdgeInsets.only(bottom: 100), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) { final categories = groupedMenu.keys.toList(); if (index >= categories.length) return null; String category = categories[index]; List<Map<String, String>> items = groupedMenu[category]!; return Column(key: sectionKeys[category], crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.fromLTRB(20, 25, 20, 10), child: Text(category, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))), ...items.map((food) => _buildFoodItem(food))]); }, childCount: groupedMenu.length))),
            ],
          ),
          if (userCart.isNotEmpty) Positioned(bottom: 20, left: 20, right: 20, child: GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => refresh()); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: Text("${getCartCount()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const Text("View Basket", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text("RM ${getCartTotal().toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))])))),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Map<String, String> food) {
    return InkWell(
      onTap: () => _showAddToCartDialog(food),
      child: Container(margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 5)]), child: Row(children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15)), child: Icon(food['image_icon'] == 'checkroom' ? Icons.checkroom : food['image_icon'] == 'computer' ? Icons.computer : Icons.fastfood, color: Colors.deepPurpleAccent, size: 35)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(food['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text("RM ${food['price']}", style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold))])), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.deepPurple, size: 20))])),
    );
  }
}

class _SliverCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  _SliverCategoryHeaderDelegate({required this.categories, required this.selectedCategory, required this.onCategorySelected});
  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) { return Container(color: Colors.white, alignment: Alignment.centerLeft, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), itemCount: categories.length, itemBuilder: (context, index) { final cat = categories[index]; final isSelected = cat == selectedCategory; return Padding(padding: const EdgeInsets.only(right: 10), child: ChoiceChip(label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)), selected: isSelected, selectedColor: Colors.deepPurple, backgroundColor: Colors.grey.shade100, onSelected: (_) => onCategorySelected(cat))); })); }
  @override
  bool shouldRebuild(_SliverCategoryHeaderDelegate oldDelegate) { return oldDelegate.selectedCategory != selectedCategory; }
}