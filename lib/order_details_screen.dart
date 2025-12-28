import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'dart:async'; 

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with TickerProviderStateMixin {
  late String currentStatus;
  String? rejectReason;
  String? riderName;
  int currentStep = 0; 
  String orderType = 'Service'; 
  
  late AnimationController _iconController;
  Timer? _statusChecker;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order['status'];
    rejectReason = widget.order['reject_reason'];
    riderName = widget.order['rider_name'];
    
    _determineOrderType(); 
    _updateStepFromStatus();

    _iconController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat(reverse: true);
    _statusChecker = Timer.periodic(const Duration(seconds: 1), (timer) { _checkRealStatus(); });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _statusChecker?.cancel(); 
    super.dispose();
  }

  void _checkRealStatus() {
    final globalOrder = activeOrders.firstWhere((o) => o['id'] == widget.order['id'], orElse: () => {});
    if (globalOrder.isNotEmpty) {
      String realStatus = globalOrder['status'];
      if (realStatus != currentStatus) {
        if (mounted) {
          setState(() {
            currentStatus = realStatus;
            if (currentStatus == 'Rejected') rejectReason = globalOrder['reject_reason'];
            if (globalOrder['rider_name'] != null) riderName = globalOrder['rider_name'];
            _updateStepFromStatus();
          });
        }
      }
    }
  }

  void _determineOrderType() {
    if ((widget.order['items'] as List).isEmpty) return;
    
    final firstItem = (widget.order['items'] as List)[0];
    String name = (firstItem['name'] ?? '').toString().toLowerCase();
    String seller = (firstItem['seller'] ?? '').toString().toLowerCase();

    // 1. Check Seller Name (Highest Priority)
    if (seller.contains('tech') || seller.contains('fix') || seller.contains('repair') || seller.contains('gadget')) {
      setState(() => orderType = 'Service'); return;
    }
    if (seller.contains('print') || seller.contains('copy') || seller.contains('xerox')) {
      setState(() => orderType = 'Printing'); return;
    }
    if (seller.contains('bundle') || seller.contains('fashion') || seller.contains('attire')) {
      setState(() => orderType = 'Fashion'); return;
    }

    // 2. Check Item Name (Fallback)
    if (name.contains('laptop') || name.contains('format') || name.contains('paste') || name.contains('install')) {
      setState(() => orderType = 'Service'); return;
    }
    if (name.contains('print') || name.contains('bind')) {
      setState(() => orderType = 'Printing'); return;
    }
    if (name.contains('shirt') || name.contains('hoodie') || name.contains('pants')) {
      setState(() => orderType = 'Fashion'); return;
    }

    setState(() => orderType = 'Food');
  }

  void _updateStepFromStatus() {
    if (currentStatus == 'Pending') currentStep = 0;
    else if (['Runner Collecting', 'Item Received'].contains(currentStatus)) currentStep = 1;
    else if (['In Repair', 'Printing...', 'Packing Order', 'Kitchen Cooking', 'Preparing...', 'Ready for Collection', 'Ready for Pickup'].contains(currentStatus)) currentStep = 2;
    else if (['Out for Delivery'].contains(currentStatus)) currentStep = 3;
    else if (['Completed', 'Delivered', 'Collected', 'Job Done'].contains(currentStatus)) currentStep = 4;
    
    if (currentStatus == 'Rejected') currentStep = -1; 
  }

  // Use Smart Location Logic
  String _getSmartLocation() {
    String? loc = widget.order['location'];
    if (loc != null && loc.isNotEmpty) return loc;
    if (orderType == 'Service') return "Walk-in (Tech Fixers)";
    if (orderType == 'Printing') return "Self-Pickup (Aiman Print)";
    if (orderType == 'Fashion') return "Self-Pickup (Campus Bundle)";
    return "Meet at Lobby";
  }

  bool get _isPickup {
    String loc = _getSmartLocation(); 
    if (loc.contains('Runner')) return false; 
    return loc.contains('Pickup') || loc.contains('Walk-in') || loc.contains('Self');
  }

  String _getStatusTitle() {
    if (currentStatus == 'Pending') return "Pending Acceptance";
    if (currentStatus == 'Runner Collecting') return "Runner Coming";
    if (currentStatus == 'Item Received') return "Item at Shop";
    
    if (currentStatus == 'In Repair') return "Repairing Device";
    if (currentStatus == 'Printing...') return "Printing Documents";
    if (currentStatus == 'Packing Order') return "Packing Order";
    if (currentStatus == 'Kitchen Cooking') return "Kitchen Cooking";
    
    if (currentStatus == 'Preparing...') {
        if(orderType == 'Service') return "Diagnosing Device";
        if(orderType == 'Fashion') return "Packing Item";
        return "Preparing Order";
    }

    if (currentStatus == 'Ready for Collection' || currentStatus == 'Ready for Pickup') return "Ready for Pickup";
    if (currentStatus == 'Out for Delivery') return "On the Way";
    
    if (['Completed', 'Delivered', 'Collected', 'Job Done'].contains(currentStatus)) return "Order Completed";
    
    return currentStatus;
  }

  String _getStep2Title() {
    if (orderType == 'Fashion') return "Packing";
    if (orderType == 'Service') return "Repairing";
    if (orderType == 'Printing') return "Printing";
    return "Cooking";
  }

  String _getStep2Subtitle() {
    if (orderType == 'Fashion') return "Seller is packing your item";
    if (orderType == 'Service') return "Technician is fixing device"; 
    if (orderType == 'Printing') return "Processing document file";
    return "Kitchen is preparing meal";
  }

  String _getStep3Title() {
     if (_isPickup) return "Ready for Collection";
     if (orderType == 'Service') return "Return Delivery";
     return "Out for Delivery";
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.order['items'];
    
    String fullLocation = _getSmartLocation();
    String method = "Delivery Method";
    String address = fullLocation;
    
    if (fullLocation.contains('(')) {
      List<String> parts = fullLocation.split('(');
      method = parts[0].trim(); 
      address = fullLocation.substring(fullLocation.indexOf('(') + 1, fullLocation.length - 1); 
    } else {
      method = _isPickup ? "Self-Pickup" : "Runner Delivery";
      address = fullLocation;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Order Details", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (currentStatus == 'Rejected') 
              Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red)), child: Column(children: [const Icon(Icons.cancel, size: 50, color: Colors.red), const SizedBox(height: 10), const Text("Order Rejected", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)), const SizedBox(height: 5), Text("Reason: ${rejectReason ?? 'Shop is currently busy'}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]))
            else 
              _buildNormalStatusView(address, method, items), 

            const SizedBox(height: 25),
            
            // ORDER SUMMARY
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(widget.order['id'], style: const TextStyle(color: Colors.grey))]), const Divider(height: 30), ...items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Text("${item['quantity']}x", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500)), if (item['remarks'] != null && item['remarks'].isNotEmpty) Text(item['remarks'], style: const TextStyle(color: Colors.grey, fontSize: 12))])), Text("RM ${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold))]))), const Divider(height: 30), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Paid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("RM ${widget.order['total']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green))])])),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalStatusView(String address, String method, List<dynamic> items) {
    return Column(children: [
      _buildAnimatedHeader(), const SizedBox(height: 25), 
      
      if (orderType == 'Printing') Container(margin: const EdgeInsets.only(bottom: 25), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade100)), child: Column(children: [const Text("Job Requirements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(), _buildJobRow(Icons.description, "File", widget.order['file'] ?? "Unknown File"), _buildJobRow(Icons.format_align_justify, "Binding", widget.order['binding'] ?? "-")])),

      Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.deepPurple.withOpacity(0.1))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(orderType == 'Service' ? Icons.store : Icons.location_on, color: Colors.deepPurple, size: 30), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(orderType == 'Service' ? "Service Center:" : _isPickup ? "Collection Point:" : "Delivering to:", style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(orderType == 'Service' ? items[0]['seller'] : address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), if (!_isPickup) Text("via $method", style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic))]))])), const SizedBox(height: 25),
      
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: [
        _buildTimelineStep("Order Placed", "Request received", 0, currentStep >= 0), _buildTimelineLine(currentStep >= 1),
        _buildTimelineStep(orderType == 'Service' ? "Pickup / Drop-off" : "Preparing", _isPickup ? "Item at shop" : "Runner collecting", 1, currentStep >= 1), _buildTimelineLine(currentStep >= 2),
        _buildTimelineStep(_getStep2Title(), _getStep2Subtitle(), 2, currentStep >= 2), _buildTimelineLine(currentStep >= 3),
        if (!_isPickup) ...[ _buildTimelineStep(_getStep3Title(), "Runner returning item", 3, currentStep >= 3), _buildTimelineLine(currentStep >= 4), ],
        _buildTimelineStep("Completed", "Order Finished", 4, currentStep >= 4)])),
      
      // --- RIDER INFO CARD ---
      // Show if it is NOT pickup (meaning it's a runner job), even if Pending
      if (!_isPickup) 
        Container(
          margin: const EdgeInsets.only(top: 25), 
          padding: const EdgeInsets.all(15), 
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.deepPurple.withOpacity(0.2))), 
          child: Column(
            children: [
              Row(children: [
                CircleAvatar(radius: 25, backgroundColor: Colors.orange, child: Icon(Icons.delivery_dining, color: Colors.white, size: 30)), 
                const SizedBox(width: 15), 
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(riderName != null ? "Rider: $riderName" : "Searching for Runner...", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                  Text(currentStatus == 'Pending' ? "Waiting for accept..." : (currentStatus == 'Runner Collecting' ? "Collecting from YOU" : "Delivering to YOU"), style: const TextStyle(color: Colors.grey, fontSize: 12))
                ])), 
              ]),
              // Only show buttons if rider is actually assigned
              if (riderName != null) ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 10)), onPressed: (){}, icon: const Icon(Icons.phone, size: 18), label: const Text("Call"))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 10)), onPressed: (){}, icon: const Icon(Icons.message, size: 18), label: const Text("Chat"))),
                  ],
                )
              ]
            ],
          )
        ),
    ]);
  }

  Widget _buildAnimatedHeader() {
    IconData mainIcon = Icons.hourglass_top; Color iconColor = Colors.grey;
    if (currentStep == 1 || currentStep == 3) { mainIcon = Icons.delivery_dining; iconColor = Colors.blue; }
    if (currentStep == 2) { 
        if(orderType == 'Fashion') mainIcon = Icons.checkroom;
        else if(orderType == 'Service') mainIcon = Icons.build;
        else if(orderType == 'Printing') mainIcon = Icons.print;
        else mainIcon = Icons.soup_kitchen;
        iconColor = Colors.orange; 
    }
    if (currentStep == 4) { mainIcon = Icons.check_circle; iconColor = Colors.green; }
    return Center(child: Column(children: [Container(height: 100, width: 100, decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle), child: Icon(mainIcon, size: 50, color: iconColor)), const SizedBox(height: 15), Text(_getStatusTitle(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black))]));
  }
  Widget _buildJobRow(IconData i, String l, String v) { return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(i, color: Colors.grey, size: 20), const SizedBox(width: 10), SizedBox(width: 100, child: Text(l, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))), Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold)))])); }
  Widget _buildTimelineStep(String t, String s, int i, bool a) { return Row(children: [Icon(a ? Icons.check_circle : Icons.radio_button_unchecked, color: a ? Colors.deepPurple : Colors.grey), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: a ? Colors.black : Colors.grey)), Text(s, style: const TextStyle(color: Colors.grey, fontSize: 12))])]); }
  Widget _buildTimelineLine(bool a) { return Container(margin: const EdgeInsets.only(left: 12), height: 30, width: 2, color: a ? Colors.deepPurple : Colors.grey[200]); }
}