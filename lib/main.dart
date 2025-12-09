import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'menu_screen.dart';
import 'order_details_screen.dart'; 
import 'login_screen.dart'; 
import 'dart:async'; // Required for Real-Time updates

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(), 
  ));
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
    const OrdersScreen(), // This is now Stateful and Real-Time
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- 1. HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> homeCategories = const [
    {'name': 'Food & Drinks', 'icon': Icons.fastfood, 'color': Colors.orange, 'bg': 0xFFFFF3E0},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink, 'bg': 0xFFFCE4EC},
    {'name': 'Services', 'icon': Icons.build, 'color': Colors.blue, 'bg': 0xFFE3F2FD},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Good Morning,", style: TextStyle(color: Colors.grey)),
                    Text(isGuest ? "Guest" : (currentUser['name'] ?? "Student"), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, color: Colors.white),
                )
              ],
            ),
          ),

          // PROMO BANNER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: const [
                Icon(Icons.local_offer, color: Colors.white, size: 40),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "Free Delivery for Kolej Malinja today!",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Browse by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),

          // CATEGORY LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: homeCategories.length,
              itemBuilder: (context, index) {
                final cat = homeCategories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(selectedCategory: cat['name']),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(cat['bg']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(cat['icon'], color: cat['color'], size: 30),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            cat['name'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87.withOpacity(0.8)),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios, color: cat['color'].withOpacity(0.5), size: 18),
                        ],
                      ),
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

// --- 2. ORDERS SCREEN (NOW STATEFUL FOR REAL-TIME UPDATES) ---
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresh the list every 1 second to catch Seller updates
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Orders"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.receipt_long, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text("Login to see your orders", style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: activeOrders.isEmpty
          ? const Center(child: Text("No active orders"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeOrders.length,
              itemBuilder: (context, index) {
                final order = activeOrders[index];
                
                String itemsSummary = (order['items'] as List)
                    .map((item) => "${item['name']} x${item['quantity']}")
                    .join(", ");

                // --- DYNAMIC COLOR LOGIC ---
                Color statusBg = Colors.orange.shade100;
                Color statusText = Colors.deepOrange;

                String status = order['status'];

                if (['Delivered', 'Collected', 'Job Done'].contains(status)) {
                  statusBg = Colors.green.shade100;
                  statusText = Colors.green;
                } 
                else if (['Out for Delivery', 'Runner Collecting', 'Ready for Collection', 'In Repair'].contains(status)) {
                  statusBg = Colors.blue.shade100;
                  statusText = Colors.blue;
                }
                else if (status == 'Rejected') {
                  statusBg = Colors.red.shade100;
                  statusText = Colors.red;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(status, style: TextStyle(color: statusText, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(backgroundColor: Colors.deepPurple[50], child: const Icon(Icons.receipt, color: Colors.deepPurple)),
                            title: Text(itemsSummary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Tap to view details • ${order['time']}"),
                            trailing: Text("RM ${order['total']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- 3. PROFILE SCREEN (Kept Same) ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("You are browsing as Guest", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("Login to view your profile and orders", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: const Text("Login Now", style: TextStyle(color: Colors.white, fontSize: 16)),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.deepPurple, child: Icon(Icons.person, size: 50, color: Colors.white))),
            const SizedBox(height: 20),
            Text(currentUser['name'] ?? "Student", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Student ID: ${currentUser['id']}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 30),
            ListTile(leading: const Icon(Icons.email), title: const Text("Email"), subtitle: Text(currentUser['email'] ?? "No Email"), onTap: () {}),
            const Divider(),
            ListTile(leading: const Icon(Icons.location_on), title: const Text("Dorm Address"), subtitle: const Text("Kolej Malinja, Block B"), onTap: () {}),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Logout", style: TextStyle(color: Colors.red)), onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()))),
          ],
        ),
      ),
    );
  }
}