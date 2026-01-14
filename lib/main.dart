import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dummy_data.dart'; 
import 'menu_screen.dart'; // Contains MenuScreen & FoodItemsScreen
import 'order_details_screen.dart'; 
import 'login_screen.dart'; 
import 'dart:async'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kampus Kiosk',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), 
      ),
      home: const LoginScreen(), 
    );
  }
}

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const OrdersScreen(), 
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// ==========================================
// 1. HOME SCREEN (INTERACTIVE & WITH IMAGES)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  late Timer _bannerTimer;

  final List<Map<String, dynamic>> _banners = [
    {'title': "Free Delivery!", 'sub': "For Kolej Malinja", 'color': const Color(0xFF6A1B9A), 'icon': Icons.local_shipping}, 
    {'title': "50% Off Print", 'sub': "Min order 50 pages", 'color': const Color(0xFF1565C0), 'icon': Icons.print}, 
    {'title': "New Menu!", 'sub': "Try Chef Jojo today", 'color': const Color(0xFFE65100), 'icon': Icons.restaurant}, 
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentBanner < _banners.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(_currentBanner, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // Navigate to specific shop
  void _navigateToShop(String sellerName, String collegeName) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => FoodItemsScreen(sellerName: sellerName, collegeName: collegeName)
      )
    );
  }

  // Open Search Page
  void _openSearch({bool autoFocus = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage(autoFocus: autoFocus))
    );
  }

  @override
  Widget build(BuildContext context) {
    final popularItems = foodMenu.take(5).toList(); 

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION (Purple Gradient) ---
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF9575CD)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Good Morning,", style: TextStyle(color: Colors.purple.shade100, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(
                          isGuest ? "Guest" : (currentUser['name'] ?? "Student"),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const CircleAvatar(radius: 22, backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.deepPurple)),
                    )
                  ],
                ),
                const SizedBox(height: 25),
                
                // --- SEARCH BAR (Clickable) ---
                GestureDetector(
                  onTap: () => _openSearch(autoFocus: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]),
                    child: Row(children: [const Icon(Icons.search, color: Colors.deepPurple), const SizedBox(width: 10), Text("What are you looking for?", style: TextStyle(color: Colors.grey[400]))]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // --- BANNER SECTION ---
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              onPageChanged: (index) => setState(() => _currentBanner = index),
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: banner['color'], 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: (banner['color'] as Color).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(5)), child: const Text("PROMO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                            const SizedBox(height: 10),
                            Text(banner['title'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(banner['sub'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                      Icon(banner['icon'], color: Colors.white.withOpacity(0.9), size: 70),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 25),

          // --- CATEGORIES ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCategoryItem("Food", Icons.fastfood, Colors.orange),
                _buildCategoryItem("Drinks", Icons.local_drink, Colors.teal),
                _buildCategoryItem("Fashion", Icons.checkroom, Colors.pink),
                _buildCategoryItem("Printing", Icons.print, Colors.blue),
                _buildCategoryItem("Services", Icons.build, Colors.purple),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- POPULAR NOW ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Popular Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                
                // --- SEE ALL BUTTON ---
                GestureDetector(
                  onTap: () => _openSearch(autoFocus: false),
                  child: Text("See All", style: TextStyle(color: Colors.deepPurple[400], fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          
          SizedBox(
            height: 260,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 10, bottom: 20),
              scrollDirection: Axis.horizontal,
              itemCount: popularItems.length,
              itemBuilder: (context, index) {
                final item = popularItems[index];
                
                // Helper to fallback icon
                IconData getIcon() {
                  if(item['image_icon'] == 'fastfood') return Icons.fastfood;
                  if(item['image_icon'] == 'checkroom') return Icons.checkroom;
                  return Icons.restaurant;
                }

                return GestureDetector(
                  onTap: () => _navigateToShop(item['seller']!, item['college'] ?? 'Kolej Malinja'),
                  child: Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- IMAGE SECTION ---
// [Inside main.dart -> "Popular Now" ListView.builder]

                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.grey[100]), // Slightly darker to see it
                            
                            child: item.containsKey('image_url') && item['image_url'] != null
                                ? Image.network(
                                    item['image_url']!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    
                                    // 1. Loading Indicator
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                                    },
                                    
                                    // 2. VISUAL ERROR MESSAGE (This will show on the phone screen)
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.red.shade50, // Red background for error
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.error, color: Colors.red, size: 30),
                                            const SizedBox(height: 5),
                                            // PRINT THE ERROR ON SCREEN
                                            Text(
                                              error.toString(), 
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 10, color: Colors.red),
                                              maxLines: 3, 
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Center(child: Icon(getIcon(), size: 60, color: Colors.deepPurple.withOpacity(0.3))),
                          ),
                        ),
                      ),
                        
                        // --- TEXT DETAILS ---
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(item['seller']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("RM ${item['price']}", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16))
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () {
          String targetCat = name;
          if(name == 'Food' || name == 'Drinks') targetCat = 'Food & Drinks';
          Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(selectedCategory: targetCat)));
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. ORDERS SCREEN 
// ==========================================
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Timer? _timer;
  String _selectedFilter = 'Active'; 
  final List<String> _filters = ['Active', 'Completed', 'Cancelled', 'All'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (activeOrders.isEmpty) return [];
    return activeOrders.where((order) {
      String status = order['status'];
      bool isCompleted = ['Completed', 'Delivered', 'Collected', 'Job Done'].contains(status);
      bool isCancelled = status == 'Rejected';
      bool isActive = !isCompleted && !isCancelled;
      if (_selectedFilter == 'Active') return isActive;
      if (_selectedFilter == 'Completed') return isCompleted;
      if (_selectedFilter == 'Cancelled') return isCancelled;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Orders"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: const Center(child: Text("Login to see orders")),
      );
    }

    final ordersToShow = _filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.white, 
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  bool isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: Colors.deepPurple,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      backgroundColor: Colors.grey[100],
                      onSelected: (bool selected) { if (selected) setState(() => _selectedFilter = filter); },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ordersToShow.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox, size: 60, color: Colors.grey[300]), const SizedBox(height: 15), Text("No orders found", style: TextStyle(color: Colors.grey[500]))]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ordersToShow.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(ordersToShow[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    List items = order['items'] ?? [];
    String shopName = items.isNotEmpty ? (items[0]['seller'] ?? 'Unknown Shop') : 'Unknown Shop';
    String itemsSummary = items.map((item) => "${item['quantity']}x ${item['name']}").join(", ");
    String status = order['status'];
    Color statusColor = Colors.orange;
    Color statusBg = Colors.orange.shade50;

    if (['Delivered', 'Completed', 'Collected', 'Job Done'].contains(status)) { statusColor = Colors.green; statusBg = Colors.green.shade50; } 
    else if (['Out for Delivery', 'Runner Collecting', 'Ready for Collection'].contains(status)) { statusColor = Colors.blue; statusBg = Colors.blue.shade50; }
    else if (status == 'Rejected') { statusColor = Colors.red; statusBg = Colors.red.shade50; }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order))); },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.store, size: 18, color: Colors.deepPurple[400])), const SizedBox(width: 10), Expanded(child: Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis))])), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)))]),
              const SizedBox(height: 12),
              Text(order['id'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(itemsSummary, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 12), const Divider(height: 1), const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(order['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)), Text("RM ${order['total']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. PROFILE SCREEN
// ==========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return Scaffold(body: Center(child: ElevatedButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())), child: const Text("Login"))));
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(height: 250, width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF673AB7), Color(0xFF9575CD)]))),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text("My Profile", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                    child: Column(
                      children: [
                        const CircleAvatar(radius: 50, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 60, color: Colors.white)),
                        const SizedBox(height: 15),
                        Text(currentUser['name'] ?? "Student", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text("Student ID: ${currentUser['id']}", style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 30),
                        ListTile(leading: const Icon(Icons.email, color: Colors.deepPurple), title: const Text("Email"), subtitle: Text(currentUser['email'] ?? "-"), contentPadding: EdgeInsets.zero),
                        const Divider(),
                        const ListTile(leading: Icon(Icons.location_on, color: Colors.deepPurple), title: Text("Dorm"), subtitle: Text("Kolej Malinja, Block B"), contentPadding: EdgeInsets.zero),
                        const Divider(),
                        ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Logout", style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 4. SEARCH PAGE
// ==========================================
class SearchPage extends StatefulWidget {
  final bool autoFocus;
  const SearchPage({super.key, required this.autoFocus});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final results = foodMenu.where((item) {
      final name = item['name']!.toLowerCase();
      final seller = item['seller']!.toLowerCase();
      final q = _query.toLowerCase();
      return name.contains(q) || seller.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          autofocus: widget.autoFocus,
          onChanged: (val) => setState(() => _query = val),
          decoration: const InputDecoration(
            hintText: "Search items or shops...",
            border: InputBorder.none,
          ),
        ),
      ),
      body: results.isEmpty 
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 60, color: Colors.grey[300]), const SizedBox(height: 10), const Text("No results found.")]))
        : ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: results.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = results[index];
              return ListTile(
                leading: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    item['image_icon'] == 'fastfood' ? Icons.fastfood : 
                    item['image_icon'] == 'checkroom' ? Icons.checkroom : Icons.restaurant,
                    color: Colors.deepPurple
                  ),
                ),
                title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['seller']!),
                trailing: Text("RM ${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => FoodItemsScreen(
                        sellerName: item['seller']!, 
                        collegeName: item['college'] ?? 'Unknown'
                      )
                    )
                  );
                },
              );
            },
          ),
    );
  }
}