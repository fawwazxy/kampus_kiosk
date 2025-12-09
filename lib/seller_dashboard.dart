import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'login_screen.dart';
import 'dart:math' as math;

class SellerDashboard extends StatefulWidget {
  final String shopName;

  const SellerDashboard({super.key, required this.shopName});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int _selectedIndex = 0; 
  String _orderFilter = 'All';
  String _analyticsTimeFilter = 'Today';
  
  String shopType = 'Food'; 

  @override
  void initState() {
    super.initState();
    _determineShopType();
  }

  void _determineShopType() {
    try {
      final myItem = foodMenu.firstWhere((item) => item['seller'] == widget.shopName, orElse: () => {});
      if (myItem.isNotEmpty) {
        String icon = myItem['image_icon']!;
        if (icon == 'checkroom') shopType = 'Fashion';
        else if (['print', 'menu_book'].contains(icon)) shopType = 'Printing'; 
        else if (['computer', 'save', 'cleaning_services'].contains(icon)) shopType = 'Service';
        else shopType = 'Food';
      }
    } catch (e) {
      shopType = 'Food';
    }
  }

  // --- SMART STATUS UPDATE LOGIC ---
  void _advanceOrderStatus(String orderId, String currentStatus) {
    final orderIndex = activeOrders.indexWhere((o) => o['id'] == orderId);
    if (orderIndex == -1) return;

    final order = activeOrders[orderIndex];
    String location = order['location'] ?? '';
    bool isPickup = location.contains('Pickup') || location.contains('Walk-in') || location.contains('Self');

    String nextStatus = 'Preparing...'; // Default next step

    // --- STEP 0: PENDING -> ACCEPTED ---
    if (currentStatus == 'Pending') {
      nextStatus = 'Preparing...';
    }
    // --- STEP 1: PREPARING -> READY/OUT ---
    else if (currentStatus == 'Preparing...') {
      if (shopType == 'Service') nextStatus = 'In Repair';
      else if (shopType == 'Printing') nextStatus = isPickup ? 'Ready for Collection' : 'Runner Collecting';
      else nextStatus = isPickup ? 'Ready for Pickup' : 'Out for Delivery';
    } 
    // --- STEP 2: READY/OUT -> COMPLETED ---
    else {
      if (shopType == 'Service') nextStatus = 'Job Done';
      else if (shopType == 'Printing') nextStatus = 'Collected';
      else nextStatus = isPickup ? 'Collected' : 'Delivered';
    }

    setState(() {
      activeOrders[orderIndex]['status'] = nextStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status updated: $nextStatus"), backgroundColor: Colors.deepPurple));
  }

  // --- SMART BUTTON TEXT ---
  String _getButtonText(String status, bool isPickup) {
    if (status == 'Pending') return "Accept Order"; 
    
    if (status == 'Preparing...') {
      if (shopType == 'Service') return "Start Repair";
      if (shopType == 'Printing') return "Start Printing";
      if (shopType == 'Fashion') return "Start Packing";
      return "Start Cooking";
    } 
    else {
      if (shopType == 'Service') return "Finish Job";
      if (isPickup) return "Customer Collected";
      return "Delivered";
    }
  }

  // --- REJECT WITH REASON ---
  void _rejectOrder(String orderId) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Order"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Reason for customer:"),
            const SizedBox(height: 10),
            TextField(controller: reasonController, decoration: const InputDecoration(labelText: "Reason (e.g. Closing)", border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                final idx = activeOrders.indexWhere((o) => o['id'] == orderId);
                if (idx != -1) {
                  activeOrders[idx]['status'] = 'Rejected';
                  activeOrders[idx]['reject_reason'] = reasonController.text.isEmpty ? "Shop busy" : reasonController.text;
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // ... (Menu Helper functions) ...
  void _toggleFoodStatus(int i, List<Map<String, String>> m) { final idx = foodMenu.indexOf(m[i]); if (idx != -1) setState(() => foodMenu[idx]['status'] = foodMenu[idx]['status'] == 'Open' ? 'Closed' : 'Open'); }
  void _deleteItem(int i, List<Map<String, String>> m) { final idx = foodMenu.indexOf(m[i]); if (idx != -1) setState(() => foodMenu.removeAt(idx)); }
  void _showItemDialog({Map<String, String>? item, int? index}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: isEditing ? item['name'] : '');
    final priceController = TextEditingController(text: isEditing ? item['price'] : '');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(isEditing ? "Edit" : "Add"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")), TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), ElevatedButton(onPressed: () { if (nameController.text.isNotEmpty) { setState(() { if (isEditing) { final idx = foodMenu.indexOf(item!); foodMenu[idx]['name'] = nameController.text; foodMenu[idx]['price'] = priceController.text; } else { foodMenu.add({'name': nameController.text, 'price': priceController.text, 'college': 'Malinja', 'seller': widget.shopName, 'status': 'Open', 'image_icon': 'restaurant'}); } }); Navigator.pop(ctx); } }, child: const Text("Save"))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text(_selectedIndex == 0 ? "Incoming Orders" : _selectedIndex == 1 ? "Manage Menu" : "Insights"), backgroundColor: _selectedIndex == 0 ? Colors.redAccent : Colors.deepPurple, actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())))]),
      body: _selectedIndex == 0 ? _buildAdvancedOrdersView() : _selectedIndex == 1 ? _buildMenuView() : _buildAnimatedAnalyticsView(),
      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton(onPressed: () => _showItemDialog(), backgroundColor: Colors.deepPurple, child: const Icon(Icons.add)) : null,
      bottomNavigationBar: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (index) => setState(() => _selectedIndex = index), selectedItemColor: _selectedIndex == 0 ? Colors.redAccent : Colors.deepPurple, type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Orders"), BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "My Services"), BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analytics")]),
    );
  }

  Widget _buildAdvancedOrdersView() {
    var myOrders = activeOrders.where((order) => order['items'][0]['seller'] == widget.shopName && order['status'] != 'Rejected').toList();
    if (_orderFilter != 'All') myOrders = myOrders.where((order) => order['status'].contains(_orderFilter.split(" ").first)).toList();

    return Column(children: [
        Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), color: Colors.white, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ["All", "Pending", "Preparing", "Delivered"].map((filter) { final isSelected = _orderFilter == filter; return Padding(padding: const EdgeInsets.only(right: 8.0), child: ChoiceChip(label: Text(filter), selected: isSelected, selectedColor: Colors.redAccent.withOpacity(0.1), onSelected: (bool selected) => setState(() => _orderFilter = filter))); }).toList()))),
        Expanded(child: myOrders.isEmpty ? const Center(child: Text("No active orders")) : ListView.builder(padding: const EdgeInsets.all(15), itemCount: myOrders.length, itemBuilder: (context, index) { 
          final order = myOrders[index];
          final items = order['items'] as List;
          final status = order['status'];
          bool isPickup = (order['location'] ?? '').contains('Pickup') || (order['location'] ?? '').contains('Walk-in') || (order['location'] ?? '').contains('Self');
          
          Color statusColor = status == 'Pending' ? Colors.red : ['Out for Delivery', 'In Repair', 'Ready for Collection'].contains(status) ? Colors.blue : ['Delivered', 'Job Done', 'Collected'].contains(status) ? Colors.green : Colors.orange;
          bool isCompleted = ['Delivered', 'Collected', 'Job Done', 'Rejected'].contains(status);
          
          return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)), color: Colors.white, child: Column(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: statusColor.withOpacity(0.05), borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(order['id'], style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)), Text(order['time'], style: const TextStyle(fontSize: 12, color: Colors.grey))])),
            Padding(padding: const EdgeInsets.all(15.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const CircleAvatar(radius: 20, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Student Customer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(order['location'] ?? "Lobby", style: const TextStyle(color: Colors.grey, fontSize: 13, overflow: TextOverflow.ellipsis))]))]), const Divider(height: 25), 
            
            // --- PRINTING FILE DISPLAY ---
            if (shopType == 'Printing' && order['file'] != null)
              Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.description, size: 16, color: Colors.blue), const SizedBox(width: 10), Expanded(child: Text("File: ${order['file']}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))]),),

            ExpansionTile(tilePadding: EdgeInsets.zero, title: Text("${items.length} Items • RM ${order['total']}", style: const TextStyle(fontWeight: FontWeight.bold)), children: items.map((item) => ListTile(visualDensity: VisualDensity.compact, leading: const Icon(Icons.circle, size: 8, color: Colors.grey), title: Text(item['name']), trailing: Text("x${item['quantity']}"))).toList())])),
            Padding(padding: const EdgeInsets.fromLTRB(15, 0, 15, 15), child: Row(children: [
              if (status == 'Pending' || status == 'Preparing...') Expanded(child: OutlinedButton(onPressed: () => _rejectOrder(order['id']), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), child: const Text("Reject"))),
              if (status == 'Pending' || status == 'Preparing...') const SizedBox(width: 10),
              Expanded(flex: 2, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isCompleted ? Colors.grey : statusColor, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0), onPressed: isCompleted ? null : () => _advanceOrderStatus(order['id'], status), child: Text(isCompleted ? "Archived" : _getButtonText(status, isPickup), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))]))])); 
        }))
    ]);
  }

  Widget _buildMenuView() {
    final myMenu = foodMenu.where((item) => item['seller'] == widget.shopName).toList();
    return ListView.builder(padding: const EdgeInsets.all(15), itemCount: myMenu.length, itemBuilder: (context, index) { final food = myMenu[index]; bool isOpen = food['status'] == 'Open'; return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)), color: Colors.white, child: ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isOpen ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.category, color: isOpen ? Colors.green : Colors.red)), title: Text(food['name']!, style: TextStyle(decoration: isOpen ? null : TextDecoration.lineThrough)), subtitle: Text("RM ${food['price']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showItemDialog(item: food, index: index)), Switch(value: isOpen, activeColor: Colors.green, onChanged: (val) => _toggleFoodStatus(index, myMenu)), IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => _deleteItem(index, myMenu))])));});
  }

  // --- RESTORED: FULL ANIMATED ANALYTICS ---
  Widget _buildAnimatedAnalyticsView() {
    final allMyOrders = activeOrders.where((o) => (o['status'].contains('Deliver') || o['status'].contains('Done') || o['status'].contains('Collect')) && (o['items'][0]['seller'] == widget.shopName)).toList();
    List<Map<String, dynamic>> filteredOrders = [];
    
    if (_analyticsTimeFilter == 'Today') {
      filteredOrders = allMyOrders.where((o) => o['day'] == 'Today').toList();
    } else {
      filteredOrders = allMyOrders;
    }

    double totalRevenue = 0;
    for (var order in filteredOrders) {
      totalRevenue += double.tryParse(order['total'].toString()) ?? 0.0;
    }
    int totalOrders = filteredOrders.length;
    double avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER & FILTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Performance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Track your business growth", style: TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _analyticsTimeFilter,
                    icon: const Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple),
                    items: ["Today", "This Week"].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)))).toList(),
                    onChanged: (val) => setState(() => _analyticsTimeFilter = val!),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // ANIMATED REVENUE CARD
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: totalRevenue),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOutExpo,
            builder: (context, value, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Revenue ($_analyticsTimeFilter)", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 10),
                    Text("RM ${value.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 14)),
                        const SizedBox(width: 5),
                        const Text("Active & Healthy", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 25),

          // ANIMATED STAT CARDS
          Row(
            children: [
              Expanded(child: _buildAnimatedStatCard("Total Orders", "$totalOrders", Icons.receipt, Colors.orange, 0)),
              const SizedBox(width: 15),
              Expanded(child: _buildAnimatedStatCard("Avg Bill", "RM ${avgOrderValue.toStringAsFixed(0)}", Icons.pie_chart, Colors.blue, 200)),
            ],
          ),
          const SizedBox(height: 30),

          // SALES BREAKDOWN
          const Text("Sales Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
            child: Column(
              children: [
                _buildProgressBar("Food Sales", 0.75, Colors.purpleAccent),
                const SizedBox(height: 15),
                _buildProgressBar("Drink Sales", 0.25, Colors.orangeAccent),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // ANIMATED BAR CHART
          const Text("Weekly Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            height: 200,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildAnimatedBar("Mon", _analyticsTimeFilter == 'Today' ? 0 : 40, 0),
                _buildAnimatedBar("Tue", _analyticsTimeFilter == 'Today' ? 0 : 60, 100),
                _buildAnimatedBar("Wed", _analyticsTimeFilter == 'Today' ? 0 : 30, 200),
                _buildAnimatedBar("Thu", _analyticsTimeFilter == 'Today' ? 0 : 80, 300),
                _buildAnimatedBar("Fri", _analyticsTimeFilter == 'Today' ? 0 : 50, 400),
                _buildAnimatedBar("Sat", _analyticsTimeFilter == 'Today' ? 0 : 95, 500), 
                _buildAnimatedBar("Sun", _analyticsTimeFilter == 'Today' ? 80 : 20, 600),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard(String title, String value, IconData icon, Color color, int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutBack,
      builder: (context, double val, child) {
        return Transform.scale(
          scale: val,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 28), const SizedBox(height: 15), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13))]),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBar(String label, double heightPct, int delay) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: heightPct),
          duration: Duration(milliseconds: 1000 + delay),
          curve: Curves.elasticOut,
          builder: (context, double val, child) {
            double safeVal = math.max(0, val);
            return Container(
              height: 100 * (safeVal / 100),
              width: 12,
              decoration: BoxDecoration(color: safeVal > 0 ? Colors.deepPurple : Colors.grey[200], borderRadius: BorderRadius.circular(6)),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProgressBar(String label, double pct, Color color) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text("${(pct * 100).toInt()}%", style: const TextStyle(color: Colors.grey, fontSize: 12))]),
        const SizedBox(height: 8),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: pct),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut,
          builder: (context, double val, child) {
            return ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: val, minHeight: 8, backgroundColor: Colors.grey[100], valueColor: AlwaysStoppedAnimation<Color>(color)));
          },
        ),
      ],
    );
  }
}