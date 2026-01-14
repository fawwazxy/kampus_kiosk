import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'login_screen.dart';
import 'chat_screen.dart'; 
import 'dart:async'; 
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
  Timer? _refreshTimer; 
  String shopType = 'Food'; 
  
  // THE CRITICAL VARIABLE
  String mySellerId = ''; 

  @override
  void initState() {
    super.initState();
    _determineShopType();
    _findMyId(); // <--- ROBUST ID FINDER
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); 
    super.dispose();
  }

  // --- ROBUST ID FINDER (Fixes the "Determined ID: ''" issue) ---
  void _findMyId() {
    String incomingName = widget.shopName.trim(); // Remove accidental spaces
    print("DEBUG: Searching for ID matches for: '$incomingName'");

    // 1. Search in sellerAccounts (Single Source of Truth)
    try {
      final account = sellerAccounts.firstWhere((acc) {
        return acc['shop_name']?.trim() == incomingName;
      }, orElse: () => {});

      if (account.isNotEmpty) {
        setState(() {
          mySellerId = account['id']!;
        });
        print("DEBUG: Match Found! Name: '$incomingName' -> ID: '$mySellerId'");
      } else {
        // 2. Fallback: Maybe the Login Screen sent the ID directly?
        // Check if incomingName matches any ID in the database
        final idMatch = sellerAccounts.firstWhere((acc) {
          return acc['id'] == incomingName;
        }, orElse: () => {});

        if (idMatch.isNotEmpty) {
           setState(() => mySellerId = incomingName);
           print("DEBUG: Incoming string was already an ID. Set ID: '$mySellerId'");
        } else {
           print("DEBUG: CRITICAL FAILURE - Could not link Name to ID.");
        }
      }
    } catch (e) {
      print("DEBUG ERROR: $e");
    }
  }

  int _getTotalUnreadMessages() {
    int total = 0;
    try {
      for (var chat in sellerInbox) {
        if (chat['seller_id'] == mySellerId) {
           total += (chat['unread_count'] as int? ?? 0);
        }
      }
    } catch (e) { return 0; }
    return total;
  }

  void _determineShopType() {
    try {
      final myItem = foodMenu.firstWhere((item) => item['seller'] == widget.shopName, orElse: () => {});
      if (myItem.isNotEmpty) {
        String icon = myItem['image_icon'] ?? ''; 
        if (icon == 'checkroom') shopType = 'Fashion';
        else if (['print', 'menu_book'].contains(icon)) shopType = 'Printing'; 
        else if (['computer', 'save', 'cleaning_services', 'build'].contains(icon)) shopType = 'Service';
        else shopType = 'Food';
      }
    } catch (e) { shopType = 'Food'; }
  }

  void _advanceOrderStatus(String orderId, String currentStatus) {
    final orderIndex = activeOrders.indexWhere((o) => o['id'] == orderId);
    if (orderIndex == -1) return;
    final order = activeOrders[orderIndex];
    String location = order['location'] ?? '';
    bool isPickup = location.contains('Pickup') || location.contains('Walk-in') || location.contains('Self');
    if (order['rider_name'] == null && !isPickup) activeOrders[orderIndex]['rider_name'] = "Amirul Runner";
    String nextStatus = 'Preparing...'; 
    if (shopType == 'Service' && !isPickup) {
       if (currentStatus == 'Pending') nextStatus = 'Runner Collecting';
       else if (currentStatus == 'Runner Collecting') nextStatus = 'Item Received';
       else if (currentStatus == 'Item Received') nextStatus = 'In Repair';
       else if (currentStatus == 'In Repair') nextStatus = 'Out for Delivery';
    } else {
      if (currentStatus == 'Pending') {
        if (shopType == 'Printing') nextStatus = 'Printing...';
        else if (shopType == 'Service') nextStatus = 'In Repair';
        else if (shopType == 'Fashion') nextStatus = 'Packing Order';
        else nextStatus = 'Preparing Order'; 
      } else if (['Packing Order', 'Printing...', 'In Repair', 'Preparing Order', 'Preparing...'].contains(currentStatus)) {
        if (isPickup) nextStatus = 'Ready for Pickup'; else nextStatus = 'Out for Delivery';
      }
    }
    setState(() { activeOrders[orderIndex]['status'] = nextStatus; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status updated: $nextStatus"), backgroundColor: Colors.deepPurple));
  }

  String _getButtonText(String status, bool isPickup) {
    if (status == 'Pending') return "Accept Order";
    if (shopType == 'Service' && !isPickup) {
      if (status == 'Runner Collecting') return "Item Received";
      if (status == 'Item Received') return "Start Repairing";
      if (status == 'In Repair') return "Handover to Runner";
    }
    if (['Packing Order', 'Printing...', 'In Repair', 'Preparing Order', 'Preparing...'].contains(status)) {
        return isPickup ? "Notify Ready" : "Handover to Runner";
    }
    return "Next Step";
  }

  void _rejectOrder(String orderId) {
    TextEditingController reasonController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Reject Order"), content: TextField(controller: reasonController, decoration: const InputDecoration(labelText: "Reason", border: OutlineInputBorder())), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { setState(() { final idx = activeOrders.indexWhere((o) => o['id'] == orderId); if (idx != -1) { activeOrders[idx]['status'] = 'Rejected'; activeOrders[idx]['reject_reason'] = reasonController.text.isEmpty ? "Busy" : reasonController.text; } }); Navigator.pop(ctx); }, child: const Text("Reject", style: TextStyle(color: Colors.white)))]));
  }

  void _toggleFoodStatus(int i, List<Map<String, String>> m) { final idx = foodMenu.indexOf(m[i]); if (idx != -1) setState(() => foodMenu[idx]['status'] = foodMenu[idx]['status'] == 'Open' ? 'Closed' : 'Open'); }
  void _deleteItem(int i, List<Map<String, String>> m) { final idx = foodMenu.indexOf(m[i]); if (idx != -1) setState(() => foodMenu.removeAt(idx)); }
  void _showItemDialog({Map<String, String>? item, int? index}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: isEditing ? item['name'] : '');
    final priceController = TextEditingController(text: isEditing ? item['price'] : '');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(isEditing ? "Edit" : "Add"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")), TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), ElevatedButton(onPressed: () { if (nameController.text.isNotEmpty) { setState(() { if (isEditing) { final idx = foodMenu.indexOf(item!); foodMenu[idx]['name'] = nameController.text; foodMenu[idx]['price'] = priceController.text; } else { foodMenu.add({'name': nameController.text, 'price': priceController.text, 'college': 'Malinja', 'seller': widget.shopName, 'status': 'Open', 'image_icon': 'restaurant'}); } }); Navigator.pop(ctx); } }, child: const Text("Save"))]));
  }

  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0: return "Incoming Orders";
      case 1: return "Manage Menu";
      case 2: return "Customer Messages"; 
      case 3: return "Insights";
      default: return "Dashboard";
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalUnread = _getTotalUnreadMessages();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_appBarTitle), 
        backgroundColor: _selectedIndex == 0 ? Colors.redAccent : Colors.deepPurple, 
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())))]
      ),
      
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildAdvancedOrdersView(),
          _buildMenuView(),
          _buildMessagesView(), 
          _buildAnimatedAnalyticsView(),
        ],
      ),

      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton(onPressed: () => _showItemDialog(), backgroundColor: Colors.deepPurple, child: const Icon(Icons.add)) : null,
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: _selectedIndex == 0 ? Colors.redAccent : Colors.deepPurple,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Orders"),
          const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Services"),
          
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.chat_bubble_outline),
                if (totalUnread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text("$totalUnread", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
              ],
            ), 
            label: "Messages"
          ),

          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analytics"),
        ],
      ),
    );
  }

  // --- MESSAGES VIEW ---
  Widget _buildMessagesView() {
    // 1. FILTER USING THE ID WE FOUND
    final myChats = sellerInbox.where((chat) => chat['seller_id'] == mySellerId).toList();

    if (myChats.isEmpty) {
      // DEBUGGING VIEW
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 10),
              const Text("No messages found.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "DEBUG:\nLogged in Name: '${widget.shopName}'\nDetermined ID: '$mySellerId'\nMessages in Inbox: ${sellerInbox.length}", 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.brown)
                ),
              )
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: myChats.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chat = myChats[index];
        final String name = chat['name'] ?? "Unknown";
        final String lastMsg = chat['last_message'] ?? "";
        final String time = chat['time'] ?? "";
        final int colorVal = chat['color'] ?? 0xFF9E9E9E;
        final int unread = (chat['unread_count'] as int? ?? 0);
        final bool hasUnread = unread > 0;

        return InkWell(
          onTap: () {
            setState(() { chat['unread_count'] = 0; });
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(sellerName: name, initialMessages: chat['messages'] as List<dynamic>?)));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                CircleAvatar(radius: 28, backgroundColor: Color(colorVal), child: Text(name.isNotEmpty ? name[0] : "?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal, fontSize: 16)), const SizedBox(height: 5), Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: hasUnread ? Colors.black87 : Colors.grey, fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal))])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(time, style: TextStyle(color: hasUnread ? Colors.deepPurple : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 8), if (hasUnread) Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 22, minHeight: 22), child: Center(child: Text("$unread", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))) else const SizedBox(height: 22, width: 22)]),
              ],
            ),
          ),
        );
      },
    );
  }

  // (Other widgets remain the same)
  Widget _buildAdvancedOrdersView() {
    var myOrders = activeOrders.where((order) => order['items'][0]['seller'] == widget.shopName && order['status'] != 'Rejected').toList();
    if (_orderFilter != 'All') myOrders = myOrders.where((order) => order['status'].contains(_orderFilter.split(" ").first)).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), 
          color: Colors.white, 
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, 
            child: Row(
              children: ["All", "Pending", "Preparing", "Delivered"].map((filter) { 
                final isSelected = _orderFilter == filter; 
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0), 
                  child: ChoiceChip(
                    label: Text(filter), 
                    selected: isSelected, 
                    selectedColor: Colors.redAccent.withOpacity(0.1), 
                    onSelected: (bool selected) => setState(() => _orderFilter = filter)
                  )
                ); 
              }).toList()
            )
          )
        ),
        Expanded(
          child: myOrders.isEmpty ? const Center(child: Text("No active orders")) : ListView.builder(
            padding: const EdgeInsets.all(15), 
            itemCount: myOrders.length, 
            itemBuilder: (context, index) { 
              final order = myOrders[index];
              final items = order['items'] as List;
              final status = order['status'];
              bool isPickup = (order['location'] ?? '').contains('Pickup') || (order['location'] ?? '').contains('Walk-in') || (order['location'] ?? '').contains('Self');
              bool isCompleted = ['Completed', 'Job Done', 'Rejected', 'Collected'].contains(status);
              Color statusColor = status == 'Pending' ? Colors.red : ['Out for Delivery', 'In Repair', 'Runner Collecting', 'Item Received', 'Printing...', 'Packing Order', 'Preparing Order'].contains(status) ? Colors.blue : isCompleted ? Colors.green : Colors.orange;
              bool isWaitingForCustomer = status == 'Out for Delivery' || status == 'Ready for Pickup' || status == 'Ready for Collection';
              String rawLocation = order['location'] ?? "Lobby";
              String displayMethod = "Delivery";
              String displayDetails = rawLocation;
              if (rawLocation.contains('(')) {
                List<String> parts = rawLocation.split('(');
                displayMethod = parts[0].trim();
                displayDetails = rawLocation.substring(rawLocation.indexOf('(') + 1, rawLocation.length - 1);
              }

              return Card(
                elevation: 0, 
                margin: const EdgeInsets.only(bottom: 15), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)), 
                color: Colors.white, 
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), 
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.05), borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))), 
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(order['id'], style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)), Text(order['time'], style: const TextStyle(fontSize: 12, color: Colors.grey))])
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0), 
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [const CircleAvatar(radius: 20, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Student Customer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(displayMethod, style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)), Text(displayDetails, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500))]))]), 
                          if (order['rider_name'] != null) Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [Icon(Icons.motorcycle, size: 16, color: Colors.deepPurple), const SizedBox(width: 5), Text("Rider: ${order['rider_name']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))])),
                          const Divider(height: 25), 
                          if (shopType == 'Printing' && order['file'] != null) Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.description, size: 16, color: Colors.blue), const SizedBox(width: 10), Expanded(child: Text("File: ${order['file']}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))])),
                          ExpansionTile(tilePadding: EdgeInsets.zero, title: Text("${items.length} Items • RM ${order['total']}", style: const TextStyle(fontWeight: FontWeight.bold)), children: items.map<Widget>((item) => ListTile(visualDensity: VisualDensity.compact, leading: const Icon(Icons.circle, size: 8, color: Colors.grey), title: Text(item['name']), subtitle: (item['remarks'] != null && item['remarks'].toString().isNotEmpty) ? Text(item['remarks'], style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)) : null, trailing: Text("x${item['quantity']}"))).toList())
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15), 
                      child: Row(children: [
                          if (status == 'Pending') Expanded(child: OutlinedButton(onPressed: () => _rejectOrder(order['id']), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), child: const Text("Reject"))),
                          if (status == 'Pending') const SizedBox(width: 10),
                          Expanded(flex: 2, child: isWaitingForCustomer ? Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: const Center(child: Text("Waiting for Customer...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isCompleted ? Colors.grey : statusColor, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0), onPressed: isCompleted ? null : () => _advanceOrderStatus(order['id'], status), child: Text(isCompleted ? "Archived" : _getButtonText(status, isPickup), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
                      ])
                    )
                  ],
                ),
              ); 
            }
          )
        )
      ]
    );
  }

  Widget _buildMenuView() {
    final myMenu = foodMenu.where((item) => item['seller'] == widget.shopName).toList();
    return ListView.builder(padding: const EdgeInsets.all(15), itemCount: myMenu.length, itemBuilder: (context, index) { final food = myMenu[index]; bool isOpen = food['status'] == 'Open'; return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)), color: Colors.white, child: ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isOpen ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.category, color: isOpen ? Colors.green : Colors.red)), title: Text(food['name']!, style: TextStyle(decoration: isOpen ? null : TextDecoration.lineThrough)), subtitle: Text("RM ${food['price']}", style: TextStyle(fontWeight: FontWeight.bold)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showItemDialog(item: food, index: index)), Switch(value: isOpen, activeColor: Colors.green, onChanged: (val) => _toggleFoodStatus(index, myMenu)), IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => _deleteItem(index, myMenu))])));});
  }

  Widget _buildAnimatedAnalyticsView() {
    final allMyOrders = activeOrders.where((o) => (o['status'].contains('Completed') || o['status'].contains('Done') || o['status'].contains('Collected')) && (o['items'][0]['seller'] == widget.shopName)).toList();
    List<Map<String, dynamic>> filteredOrders = _analyticsTimeFilter == 'Today' ? allMyOrders.where((o) => o['day'] == 'Today').toList() : allMyOrders;
    double totalRevenue = 0; for (var order in filteredOrders) { totalRevenue += double.tryParse(order['total'].toString()) ?? 0.0; }
    int totalOrders = filteredOrders.length;
    double avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Performance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text("Track your business growth", style: TextStyle(color: Colors.grey))]), Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _analyticsTimeFilter, icon: const Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple), items: ["Today", "This Week"].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)))).toList(), onChanged: (val) => setState(() => _analyticsTimeFilter = val!))))]),
        const SizedBox(height: 20),
        TweenAnimationBuilder(tween: Tween<double>(begin: 0, end: totalRevenue), duration: const Duration(seconds: 2), curve: Curves.easeOutExpo, builder: (context, value, child) { return Container(width: double.infinity, padding: const EdgeInsets.all(25), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Total Revenue ($_analyticsTimeFilter)", style: const TextStyle(color: Colors.white70, fontSize: 16)), const SizedBox(height: 10), Text("RM ${value.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Row(children: [Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 14)), const SizedBox(width: 5), const Text("Active & Healthy", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))])])); }),
        const SizedBox(height: 25),
        Row(children: [Expanded(child: _buildAnimatedStatCard("Total Orders", "$totalOrders", Icons.receipt, Colors.orange, 0)), const SizedBox(width: 15), Expanded(child: _buildAnimatedStatCard("Avg Bill", "RM ${avgOrderValue.toStringAsFixed(0)}", Icons.pie_chart, Colors.blue, 200))]),
        const SizedBox(height: 30),
        const Text("Sales Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 15),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [_buildProgressBar("Food Sales", 0.75, Colors.purpleAccent), const SizedBox(height: 15), _buildProgressBar("Service Sales", 0.25, Colors.orangeAccent)])),
        const SizedBox(height: 30),
        const Text("Weekly Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 15),
        Container(height: 200, padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [_buildAnimatedBar("Mon", _analyticsTimeFilter == 'Today' ? 0 : 40, 0), _buildAnimatedBar("Tue", _analyticsTimeFilter == 'Today' ? 0 : 60, 100), _buildAnimatedBar("Wed", _analyticsTimeFilter == 'Today' ? 0 : 30, 200), _buildAnimatedBar("Thu", _analyticsTimeFilter == 'Today' ? 0 : 80, 300), _buildAnimatedBar("Fri", _analyticsTimeFilter == 'Today' ? 0 : 50, 400), _buildAnimatedBar("Sat", _analyticsTimeFilter == 'Today' ? 0 : 95, 500), _buildAnimatedBar("Sun", _analyticsTimeFilter == 'Today' ? 80 : 20, 600)])),
        const SizedBox(height: 30),
    ]));
  }

  Widget _buildAnimatedStatCard(String title, String value, IconData icon, Color color, int delay) { return TweenAnimationBuilder(tween: Tween<double>(begin: 0, end: 1), duration: Duration(milliseconds: 800 + delay), curve: Curves.easeOutBack, builder: (context, double val, child) { return Transform.scale(scale: val, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 28), const SizedBox(height: 15), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13))]))); }); }
  Widget _buildAnimatedBar(String label, double heightPct, int delay) { return Column(mainAxisAlignment: MainAxisAlignment.end, children: [TweenAnimationBuilder(tween: Tween<double>(begin: 0, end: heightPct), duration: Duration(milliseconds: 1000 + delay), curve: Curves.elasticOut, builder: (context, double val, child) { double safeVal = math.max(0, val); return Container(height: 100 * (safeVal / 100), width: 12, decoration: BoxDecoration(color: safeVal > 0 ? Colors.deepPurple : Colors.grey[200], borderRadius: BorderRadius.circular(6))); }), const SizedBox(height: 10), Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))]); }
  Widget _buildProgressBar(String label, double pct, Color color) { return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text("${(pct * 100).toInt()}%", style: const TextStyle(color: Colors.grey, fontSize: 12))]), const SizedBox(height: 8), TweenAnimationBuilder(tween: Tween<double>(begin: 0, end: pct), duration: const Duration(milliseconds: 1500), curve: Curves.easeOut, builder: (context, double val, child) { return ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: val, minHeight: 8, backgroundColor: Colors.grey[100], valueColor: AlwaysStoppedAnimation<Color>(color))); })]); }
}