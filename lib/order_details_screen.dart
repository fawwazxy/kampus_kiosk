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
  bool showRider = false;
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
    
    final firstItem = (widget.order['items'] as List)[0];
    String name = (firstItem['name'] ?? '').toString().toLowerCase();
    String seller = (firstItem['seller'] ?? '').toString().toLowerCase();

    // 1. Check Seller Name
    if (seller.contains('tech') || seller.contains('fix') || seller.contains('repair') || seller.contains('gadget')) {
      setState(() => orderType = 'Service'); return;
    }
    if (seller.contains('print') || seller.contains('copy') || seller.contains('xerox')) {
      setState(() => orderType = 'Printing'); return;
    }
    if (seller.contains('bundle') || seller.contains('fashion') || seller.contains('attire')) {
      setState(() => orderType = 'Fashion'); return;
    }
    if (seller.contains('cafe') || seller.contains('food') || seller.contains('kitchen') || seller.contains('sue') || seller.contains('burger') || seller.contains('chef')) {
      setState(() => orderType = 'Food'); return;
    }

    // 2. Check Item Name (Fallback)
    if (name.contains('laptop') || name.contains('format') || name.contains('paste') || name.contains('install') || name.contains('service')) {
      setState(() => orderType = 'Service'); return;
    }
    if (name.contains('print') || name.contains('bind') || name.contains('laminate')) {
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
    else if (['In Repair', 'Printing...', 'Packing Order', 'Preparing Order', 'Kitchen Cooking', 'Preparing...', 'Ready for Collection', 'Ready for Pickup'].contains(currentStatus)) currentStep = 2;
    else if (['Out for Delivery'].contains(currentStatus)) currentStep = 3;
    else if (['Completed', 'Delivered', 'Collected', 'Job Done'].contains(currentStatus)) currentStep = 4;
    if (currentStatus == 'Rejected') currentStep = -1; 
  }

  bool get _isPickup {
    String loc = widget.order['location'] ?? '';
    if (loc.contains('Runner')) return false; 
    return loc.contains('Pickup') || loc.contains('Walk-in') || loc.contains('Self');
  }

  // --- HELPER TO GET SHOP ADDRESS ---
  String _getShopAddress(String sellerName) {
    if (sellerName.contains('Print')) return "Kolej Malinja, Block B, Room 101";
    if (sellerName.contains('Tech') || sellerName.contains('Fix')) return "Pusat Pelajar, Kiosk 3";
    if (sellerName.contains('Cafe') || sellerName.contains('Food') || sellerName.contains('Burger')) return "Medan Selera, Kolej Malinja";
    if (sellerName.contains('Bundle')) return "Kolej Jasmine, Block C, G-04";
    return "Kolej Malinja, Shop Lot 5"; 
  }

  bool get _canCompleteOrder {
    if (currentStatus == 'Out for Delivery') return true;
    if (_isPickup && (currentStatus == 'Ready for Collection' || currentStatus == 'Ready for Pickup')) return true;
    return false;
  }

  bool get _isOrderFinished {
    return ['Completed', 'Delivered', 'Collected', 'Job Done'].contains(currentStatus);
  }

  void _handleSlideComplete() {
    setState(() {
      currentStatus = 'Completed';
      _updateStepFromStatus();
      
      final index = activeOrders.indexWhere((o) => o['id'] == widget.order['id']);
      if (index != -1) {
        activeOrders[index]['status'] = 'Completed';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order Marked as Completed!"), 
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  // --- FEE CALCULATORS ---
  double get _calculatedSubtotal {
    double sum = 0;
    for (var item in widget.order['items']) {
       sum += (double.tryParse(item['price'].toString()) ?? 0.0) * (int.tryParse(item['quantity'].toString()) ?? 1);
    }
    return sum;
  }

  double get _bindingFee {
    if (orderType == 'Printing') {
      String binding = widget.order['binding'] ?? '';
      if (binding == 'Tape Binding') return 1.00;
      if (binding == 'Comb Binding') return 2.00;
    }
    return 0.00;
  }

  double get _deliveryFee {
    String loc = widget.order['location'] ?? '';
    if (loc.contains('Pickup') || loc.contains('Walk-in') || loc.contains('Self')) {
      return 0.00;
    }
    return 2.00;
  }

  // --- TITLES & SUBTITLES ---
  String _getStatusTitle() {
    if (currentStatus == 'Pending') return "Pending Acceptance";
    if (currentStatus == 'Runner Collecting') return "Runner Coming";
    if (currentStatus == 'Item Received') return "Item at Shop";
    
    if (currentStatus == 'In Repair') return "Repairing Device";
    if (currentStatus == 'Printing...') return "Printing Documents";
    if (currentStatus == 'Packing Order') return "Packing Order";
    if (currentStatus == 'Kitchen Cooking' || currentStatus == 'Preparing Order') return "Preparing Order";
    
    if (currentStatus == 'Preparing...') {
        if(orderType == 'Service') return "Diagnosing Device";
        if(orderType == 'Fashion') return "Packing Item";
        if(orderType == 'Printing') return "Processing Files";
        return "Preparing Order";
    }

    if (currentStatus == 'Ready for Collection' || currentStatus == 'Ready for Pickup') return "Ready for Pickup";
    if (currentStatus == 'Out for Delivery') return "On the Way";
    
    if (_isOrderFinished) return "Order Completed";
    
    return currentStatus;
  }

  String _getStep2Title() {
    if (orderType == 'Fashion') return "Packing";
    if (orderType == 'Service') return "Repairing";
    if (orderType == 'Printing') return "Printing";
    return "Preparing"; 
  }

  String _getStep2Subtitle() {
    if (orderType == 'Fashion') return "Seller is packing your item";
    if (orderType == 'Service') return "Technician is fixing device"; 
    if (orderType == 'Printing') return "Processing document file";
    return "Seller is preparing your order"; 
  }

  String _getStep3Title() {
     if (_isPickup) return "Ready for Collection";
     if (orderType == 'Service') return "Return Delivery";
     return "Out for Delivery";
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.order['items'];
    
    // --- 1. GET SHOP NAME ---
    String shopName = items.isNotEmpty ? items[0]['seller'] : 'Unknown Shop';

    String fullLocation = widget.order['location'] ?? "Meet at Lobby";
    String method = "Delivery Method";
    String address = fullLocation;
    if (fullLocation.contains('(')) {
      List<String> parts = fullLocation.split('(');
      method = parts[0].trim(); 
      address = fullLocation.substring(fullLocation.indexOf('(') + 1, fullLocation.length - 1); 
    }

    Widget? bottomBar;
    
    if (currentStatus != 'Rejected') {
      if (_isOrderFinished) {
        bottomBar = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
          child: Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.green)),
            child: const Center(child: Text("Order Closed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
        );
      } else if (_canCompleteOrder) {
        bottomBar = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
          child: SlideToCompleteButton(onCompleted: _handleSlideComplete),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Order Details", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      
      bottomNavigationBar: bottomBar,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (currentStatus == 'Rejected') 
              Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red)), child: Column(children: [const Icon(Icons.cancel, size: 50, color: Colors.red), const SizedBox(height: 10), const Text("Order Rejected", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)), const SizedBox(height: 5), Text("Reason: ${rejectReason ?? 'Shop is currently busy'}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]))
            else 
              _buildNormalStatusView(address, method, items, shopName), 

            const SizedBox(height: 25),
            
            Container(
              padding: const EdgeInsets.all(20), 
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(widget.order['id'], style: const TextStyle(color: Colors.grey))]), 
                  const Divider(height: 20),
                  
                  // --- 2. SHOW SHOP NAME IN SUMMARY ---
                  Row(children: [
                    Icon(Icons.store, color: Colors.deepPurple, size: 20),
                    const SizedBox(width: 8),
                    Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepPurple)),
                  ]),
                  
                  const Divider(height: 20), 
                  ...items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Text("${item['quantity']}x", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500)), if (item['remarks'] != null && item['remarks'].isNotEmpty) Text(item['remarks'], style: const TextStyle(color: Colors.grey, fontSize: 12))])), Text("RM ${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold))]))), 
                  const Divider(height: 30), 

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Subtotal", style: TextStyle(color: Colors.grey)), Text("RM ${_calculatedSubtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))]),

                  if (_bindingFee > 0)
                    Padding(padding: const EdgeInsets.only(top: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Binding Fee", style: TextStyle(color: Colors.grey)), Text("RM ${_bindingFee.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))])),
                  
                  if (_deliveryFee > 0)
                    Padding(padding: const EdgeInsets.only(top: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Delivery Fee", style: TextStyle(color: Colors.grey)), Text("RM ${_deliveryFee.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))])),
                  
                  const Divider(height: 30), 

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Paid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("RM ${widget.order['total']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green))])
                ]
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalStatusView(String address, String method, List<dynamic> items, String shopName) {
    return Column(children: [
      _buildAnimatedHeader(), const SizedBox(height: 25), 
      
      if (orderType == 'Printing') Container(margin: const EdgeInsets.only(bottom: 25), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade100)), child: Column(children: [const Text("Job Requirements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(), _buildJobRow(Icons.description, "File", widget.order['file'] ?? "Unknown File"), _buildJobRow(Icons.format_align_justify, "Binding", widget.order['binding'] ?? "-")])),

      // --- LOCATION CONTAINER ---
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
                  // --- PICKUP LOGIC ---
                  if (_isPickup) ...[
                    const Text("Pickup At:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(_getShopAddress(shopName), style: const TextStyle(color: Colors.black87, fontSize: 14)),
                  ] 
                  // --- DELIVERY LOGIC ---
                  else ...[
                    Text(orderType == 'Service' ? "Service Center:" : "Delivering to:", style: const TextStyle(color: Colors.grey, fontSize: 12)), 
                    Text(orderType == 'Service' ? shopName : address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                    Text("via $method", style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic))
                  ]
                ]
              )
            )
          ]
        )
      ), 
      
      const SizedBox(height: 25),
      
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: [
        _buildTimelineStep("Order Placed", "Request received", 0, currentStep >= 0), _buildTimelineLine(currentStep >= 1),
        _buildTimelineStep(orderType == 'Service' ? "Pickup / Drop-off" : "Preparing", _isPickup ? "Item at shop" : "Runner collecting", 1, currentStep >= 1), _buildTimelineLine(currentStep >= 2),
        _buildTimelineStep(_getStep2Title(), _getStep2Subtitle(), 2, currentStep >= 2), _buildTimelineLine(currentStep >= 3),
        if (!_isPickup) ...[ _buildTimelineStep(_getStep3Title(), "Runner returning item", 3, currentStep >= 3), _buildTimelineLine(currentStep >= 4), ],
        _buildTimelineStep("Completed", "Order Finished", 4, currentStep >= 4)])),
      
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

class SlideToCompleteButton extends StatefulWidget {
  final VoidCallback onCompleted;

  const SlideToCompleteButton({super.key, required this.onCompleted});

  @override
  State<SlideToCompleteButton> createState() => _SlideToCompleteButtonState();
}

class _SlideToCompleteButtonState extends State<SlideToCompleteButton> {
  double _dragValue = 0.0;
  bool _isCompleted = false;
  double _maxWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;
        return Container(
          height: 60,
          width: _maxWidth,
          decoration: BoxDecoration(
            color: _isCompleted ? Colors.green : Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  _isCompleted ? "COMPLETED" : "Slide to Complete Order  >>>",
                  style: TextStyle(
                    color: _isCompleted ? Colors.white : Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (!_isCompleted)
                Positioned(
                  left: _dragValue,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        double newData = _dragValue + details.delta.dx;
                        _dragValue = newData.clamp(0.0, _maxWidth - 60); 
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_dragValue > _maxWidth * 0.65) {
                        setState(() {
                          _dragValue = _maxWidth - 60;
                          _isCompleted = true;
                        });
                        widget.onCompleted();
                      } else {
                        setState(() {
                          _dragValue = 0.0;
                        });
                      }
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 10, offset: const Offset(2, 2))
                        ]
                      ),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ),
                  ),
                ),
              if (_isCompleted)
                 const Positioned(
                   right: 15,
                   top: 0,
                   bottom: 0,
                   child: Icon(Icons.check_circle, color: Colors.white, size: 30),
                 )
            ],
          ),
        );
      },
    );
  }
}