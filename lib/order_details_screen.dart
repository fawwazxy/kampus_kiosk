import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'dart:async';
import 'dart:math' as math; 

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with TickerProviderStateMixin {
  late String currentStatus;
  String? rejectReason;
  int currentStep = 0; 
  bool showRider = false;
  String orderType = 'Food'; 
  late AnimationController _iconController;
  Timer? _statusChecker;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order['status'];
    rejectReason = widget.order['reject_reason'];
    _determineOrderType(); 
    _updateStepFromStatus();

    _iconController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat(reverse: true);

    _statusChecker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkRealStatus();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _statusChecker?.cancel(); 
    super.dispose();
  }

  void _checkRealStatus() {
    final globalOrder = activeOrders.firstWhere(
      (o) => o['id'] == widget.order['id'], 
      orElse: () => {}
    );

    if (globalOrder.isNotEmpty) {
      String realStatus = globalOrder['status'];
      
      if (realStatus != currentStatus) {
        if (mounted) {
          setState(() {
            currentStatus = realStatus;
            if (currentStatus == 'Rejected') rejectReason = globalOrder['reject_reason'];
            _updateStepFromStatus();
            
            // Show rider animation logic
            // If it is a runner job, we generally show the rider graphic
            if (['Out for Delivery', 'Runner Collecting', 'Delivered', 'In Repair'].contains(currentStatus)) {
              showRider = true;
            } else {
              showRider = false;
            }
          });
        }
      }
    }
  }

  void _determineOrderType() {
    if ((widget.order['items'] as List).isEmpty) return;
    
    final firstItemName = (widget.order['items'] as List)[0]['name'];
    try {
      final menuItem = foodMenu.firstWhere((item) => item['name'] == firstItemName, orElse: () => {});
      if (menuItem.isNotEmpty) {
        String icon = menuItem['image_icon']!;
        if (icon == 'checkroom') orderType = 'Fashion';
        else if (['print', 'menu_book'].contains(icon)) orderType = 'Printing'; 
        else if (['computer', 'save', 'cleaning_services'].contains(icon)) orderType = 'Service';
        else orderType = 'Food';
      }
    } catch (e) {
      orderType = 'Food';
    }
  }

  void _updateStepFromStatus() {
    if (currentStatus == 'Pending') {
      currentStep = 0; 
    }
    else if (currentStatus == 'Preparing...') {
      currentStep = 1; 
    }
    else if (['Out for Delivery', 'Runner Collecting', 'Ready for Collection', 'In Repair', 'Ready for Pickup'].contains(currentStatus)) {
      currentStep = 2; 
    }
    else if (['Delivered', 'Collected', 'Job Done', 'Returned & Done'].contains(currentStatus)) {
      currentStep = 3; 
    }
    
    if (currentStatus == 'Rejected') currentStep = -1; 
  }

  // --- HELPER: CHECK IF PICKUP ---
  // FIXED LOGIC: Even if it says "Pickup", if it says "Runner", it is NOT self-pickup.
  bool get _isPickup {
    String loc = widget.order['location'] ?? '';
    if (loc.contains('Runner')) return false; // <--- THE FIX
    return loc.contains('Pickup') || loc.contains('Walk-in') || loc.contains('Self');
  }

  // --- DYNAMIC TEXT GENERATORS ---
  String _Step1Title() {
    if (orderType == 'Printing') return "Printing in Progress";
    // If it's a Runner Service, Step 1 is the rider picking up the item
    if (orderType == 'Service') return _isPickup ? "Device Received" : "Rider Picking Up";
    if (orderType == 'Fashion') return "Packing Item";
    return "Preparing Food"; 
  }
  
  String _Step1Subtitle() {
    if (orderType == 'Printing') return "Shop is printing your file";
    if (orderType == 'Service') return _isPickup ? "Shop has your device" : "Please pass device to runner";
    if (orderType == 'Fashion') return "Seller is packing your order";
    return "Kitchen is cooking";
  }

  String _Step2Title() {
    if (_isPickup) return "Ready for Collection"; 
    
    if (orderType == 'Printing') return "Runner Collecting";
    if (orderType == 'Service') return "In Repair"; 
    
    return "Out for Delivery"; 
  }
  
  String _Step2Subtitle() {
    if (_isPickup) return "Please come to shop to collect";

    if (orderType == 'Printing') return "Runner is picking up document";
    if (orderType == 'Service') return "Technician is fixing it now"; 
    
    return "Rider is on the way";
  }

  String _Step3Title() {
    if (orderType == 'Service') return "Job Done / Returned"; 
    if (_isPickup) return "Collected";
    return "Delivered"; 
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.order['items'];
    
    // Parse Location
    String fullLocation = widget.order['location'] ?? "Meet at Lobby";
    String method = "Delivery Method";
    String address = fullLocation;

    if (fullLocation.contains('(')) {
      List<String> parts = fullLocation.split('(');
      method = parts[0].trim(); 
      address = fullLocation.substring(fullLocation.indexOf('(') + 1, fullLocation.length - 1); 
    }

    // STRICT LOGIC: Never show rider if it is Self Pickup
    bool displayRiderCard = showRider && !_isPickup;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Order Details", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            // --- 1. REJECTION CARD ---
            if (currentStatus == 'Rejected') 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red)),
                child: Column(
                  children: [
                    const Icon(Icons.cancel, size: 50, color: Colors.red),
                    const SizedBox(height: 10),
                    const Text("Order Rejected", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 5),
                    Text("Reason: ${rejectReason ?? 'Shop is currently busy'}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    const Text("No payment was deducted. Please try ordering from another shop.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
                  ],
                ),
              )
            else 
              _buildNormalStatusView(address, method), 

            const SizedBox(height: 25),

            // --- 2. ORDER SUMMARY ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(widget.order['id'], style: const TextStyle(color: Colors.grey))]),
                const Divider(height: 30),
                ...items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Text("${item['quantity']}x", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)), const SizedBox(width: 10), Expanded(child: Text(item['name'])), Text("RM ${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold))]))),
                const Divider(height: 30),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Paid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("RM ${widget.order['total']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green))]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: NORMAL TRACKING VIEW ---
  Widget _buildNormalStatusView(String address, String method) {
    // Determine the main icon based on pickup/runner status
    bool isRunner = !_isPickup; 

    return Column(
      children: [
        _buildAnimatedHeader(),
        const SizedBox(height: 25),

        // JOB DETAILS (Only for Printing)
        if (orderType == 'Printing')
          Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Job Requirements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                const Divider(),
                _buildJobRow(Icons.description, "File", widget.order['file'] ?? "Unknown File"),
                _buildJobRow(Icons.format_align_justify, "Binding", widget.order['binding'] ?? "-"),
                _buildJobRow(Icons.eco, "Eco-Friendly", (widget.order['double_sided'] ?? false) ? "Double Sided (Yes)" : "Single Sided"),
                _buildJobRow(Icons.comment, "Remarks", widget.order['remarks'] ?? "None"),
              ],
            ),
          ),

        // LOCATION CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.deepPurple.withOpacity(0.1))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(orderType == 'Service' ? Icons.store : Icons.location_on, color: Colors.deepPurple, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderType == 'Service' ? "Service Center:" : _isPickup ? "Collection Point:" : "Delivering to:", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(orderType == 'Service' ? "Tech Fixers" : address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (!_isPickup) // Only show method if it's NOT self-pickup
                      Text("via $method", style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 25),

        // TIMELINE
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            _buildTimelineStep("Order Placed", "Request received", 3, currentStep >= 0),
            _buildTimelineLine(currentStep >= 1),
            _buildTimelineStep(_Step1Title(), _Step1Subtitle(), 2, currentStep >= 1),
            _buildTimelineLine(currentStep >= 2),
            _buildTimelineStep(_Step2Title(), _Step2Subtitle(), 1, currentStep >= 2),
            
            // Only show step 3 if NOT rejected
            if (currentStep >= 0) ...[
                _buildTimelineLine(currentStep >= 3),
                _buildTimelineStep(_Step3Title(), "Job Completed", 0, currentStep >= 3),
            ]
          ]),
        ),
        const SizedBox(height: 25),

        // RIDER / SELLER INFO (Strictly Hidden for Self-Pickup)
        AnimatedOpacity(
          duration: const Duration(seconds: 1),
          opacity: (showRider && !_isPickup) ? 1.0 : 0.0,
          child: (showRider && !_isPickup) ? Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.deepPurple.withOpacity(0.2))),
            child: Row(children: [
              CircleAvatar(radius: 25, backgroundColor: Colors.orange, child: Icon(Icons.delivery_dining, color: Colors.white, size: 30)),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Runner: Abang Aiman", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                Text(orderType == 'Service' ? "Collecting/Returning Device" : "On bike to $address", style: const TextStyle(color: Colors.grey, fontSize: 12))
              ])),
              Container(decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.phone, color: Colors.white), onPressed: () {}))
            ]),
          ) : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildJobRow(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [Icon(icon, color: Colors.grey, size: 20), const SizedBox(width: 10), SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)))]));
  }

  Widget _buildAnimatedHeader() {
    IconData mainIcon = Icons.soup_kitchen;
    Color iconColor = Colors.orange;
    String statusText = "Processing...";
    
    // Status Logic for Header Icon
    if (currentStep == 0) { mainIcon = Icons.hourglass_top; iconColor = Colors.grey; statusText = "Pending"; }
    else if (currentStep == 1) { 
      mainIcon = orderType == 'Printing' ? Icons.print : Icons.soup_kitchen; 
      iconColor = Colors.orange; 
      statusText = "Processing";
    }
    else if (currentStep == 2) { 
      // If Pickup, show Store icon. If Delivery, show Bike.
      if (_isPickup) {
        mainIcon = Icons.store;
        iconColor = Colors.green;
      } else {
        mainIcon = orderType == 'Service' ? Icons.build : Icons.delivery_dining; 
        iconColor = Colors.blue; 
      }
      statusText = "Working/Moving";
    }
    else if (currentStep == 3) { mainIcon = Icons.check_circle; iconColor = Colors.green; statusText = "Completed"; }

    return Center(child: Column(children: [
      Container(height: 100, width: 100, decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle), child: Icon(mainIcon, size: 50, color: iconColor)),
      const SizedBox(height: 15),
      Text(currentStatus, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black))
    ]));
  }

  Widget _buildTimelineStep(String title, String subtitle, int index, bool isActive) {
    return Row(children: [Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: isActive ? Colors.deepPurple : Colors.grey), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey)), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12))])]);
  }
  Widget _buildTimelineLine(bool isActive) { return Container(margin: const EdgeInsets.only(left: 12), height: 30, width: 2, color: isActive ? Colors.deepPurple : Colors.grey[200]); }
}