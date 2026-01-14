import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'main.dart'; 

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // --- 1. STATE VARIABLES ---
  String _orderMethod = 'Delivery'; 
  String _deliveryLocation = 'Lobby'; 
  
  String _selectedCollege = 'Kolej Malinja (Siswa)'; 
  final List<String> _collegeList = [
    'Kolej Malinja (Siswa)',
    'Kolej Murni (Siswi)',
    'Kolej Masria (Siswi)',
    'Kolej Mahsuri (Siswi)',
    'Kolej Jasmine (Siswi)',
  ];

  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController(); 
  String _selectedPayment = 'Cash'; 
  
  // Logic Category
  String orderCategory = 'Food'; 

  // Printing Specific State
  String? _uploadedFile;
  String _bindingType = 'Staple (Corner)';
  bool _isDoubleSided = false;

  @override
  void initState() {
    super.initState();
    _determineOrderCategory();
  }

  void _determineOrderCategory() {
    if (userCart.isNotEmpty) {
      String icon = userCart[0]['image_icon'] ?? '';
      
      if (['print', 'menu_book', 'layers'].contains(icon)) { 
        orderCategory = 'Printing';
      } 
      else if (['computer', 'save', 'cleaning_services', 'build'].contains(icon)) {
        orderCategory = 'Service';
      } 
      else if (icon == 'checkroom') {
        orderCategory = 'Fashion';
      }
    }
  }

  // --- 2. FEE CALCULATORS (New Helper Getters) ---
  
  // Calculate Binding Fee separately
  double get _bindingFee {
    if (orderCategory == 'Printing') {
      if (_bindingType == 'Tape Binding') return 1.00;
      if (_bindingType == 'Comb Binding') return 2.00;
    }
    return 0.00;
  }

  // Calculate Delivery Fee separately
  double get _deliveryFee {
    if (_orderMethod == 'Delivery') {
      return 2.00;
    }
    return 0.00;
  }

  // Final Total combines everything
  double get _finalTotal {
    return widget.totalAmount + _bindingFee + _deliveryFee;
  }

  void _simulateFileUpload() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading document...")));
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _uploadedFile = "assignment_final_v2.pdf";
      });
    });
  }

  @override
  void dispose() {
    _roomController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _handlePayment() {
    // Validation
    if (orderCategory == 'Printing' && _uploadedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload your document first!"), backgroundColor: Colors.red));
      return;
    }
    
    if (_orderMethod == 'Delivery' && _deliveryLocation == 'Room' && _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your Room Number"), backgroundColor: Colors.red));
      return;
    }

    // Construct Location String
    String finalLocationStr = "";

    if (_orderMethod == 'Pickup') {
      finalLocationStr = orderCategory == 'Service' ? "Walk-in (Shop)" : "Self-Pickup (Shop)";
    } 
    else {
      String base = _deliveryLocation == 'Room' ? "Deliver to Room" : "Meet at Lobby";
      String details = "";
      if (_deliveryLocation == 'Room') {
        details = "($_selectedCollege, ${_roomController.text})";
      } else {
        details = "($_selectedCollege)";
      }
      finalLocationStr = "Runner Delivery: $base $details";
    }

    String successMsg = "Your order has been placed.";
    if (orderCategory == 'Printing') successMsg = "Document sent to Aiman Print!";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(children: const [Icon(Icons.check_circle, color: Colors.green, size: 60), SizedBox(height: 10), Text("Order Confirmed!")]),
        content: Text(successMsg, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                activeOrders.insert(0, {
                  'id': '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                  'total': _finalTotal.toStringAsFixed(2),
                  'status': 'Pending', 
                  'time': 'Just Now',
                  'day': 'Today',
                  'location': finalLocationStr, 
                  'items': List.from(userCart), 
                  'binding': orderCategory == 'Printing' ? _bindingType : null,
                  'double_sided': orderCategory == 'Printing' ? _isDoubleSided : null,
                  'remarks': _remarksController.text.isEmpty ? 'None' : _remarksController.text,
                  'file': _uploadedFile,
                  'rider_name': null,
                });
                userCart.clear(); 
              });
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainScaffold(initialIndex: 1)), (route) => false);
            },
            child: const Text("Track Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text(orderCategory == 'Printing' ? "Print Job Checkout" : "Checkout", style: const TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PRINTING UPLOAD SECTION ---
            if (orderCategory == 'Printing') ...[
              const Text("Document Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.shade200)),
                child: Column(
                  children: [
                    InkWell(
                      onTap: _simulateFileUpload,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: _uploadedFile == null ? Colors.grey[100] : Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: _uploadedFile == null ? Colors.grey : Colors.green)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(_uploadedFile == null ? Icons.cloud_upload : Icons.check_circle, color: _uploadedFile == null ? Colors.grey : Colors.green), const SizedBox(width: 10), Text(_uploadedFile ?? "Tap to Upload PDF / Word", style: TextStyle(fontWeight: FontWeight.bold, color: _uploadedFile == null ? Colors.grey : Colors.green))]),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _bindingType,
                      decoration: const InputDecoration(labelText: "Finishing / Binding", border: OutlineInputBorder(), isDense: true),
                      items: ["Staple (Corner)", "Tape Binding", "Comb Binding", "None"].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (val) => setState(() => _bindingType = val!),
                    ),
                    const SizedBox(height: 10),
                    if (_bindingType == 'Tape Binding') const Align(alignment: Alignment.centerLeft, child: Text("+ RM 1.00 added for Tape", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold))),
                    if (_bindingType == 'Comb Binding') const Align(alignment: Alignment.centerLeft, child: Text("+ RM 2.00 added for Comb", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold))),
                    SwitchListTile(title: const Text("Double Sided Printing"), subtitle: const Text("Save paper (Eco-friendly)"), value: _isDoubleSided, activeColor: Colors.blue, onChanged: (val) => setState(() => _isDoubleSided = val)),
                    TextField(controller: _remarksController, decoration: const InputDecoration(labelText: "Remarks (e.g. Print page 1-5 only)", border: OutlineInputBorder()))
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],

            // --- COLLECTION / DELIVERY METHOD SECTION ---
            Text(orderCategory == 'Service' ? "Service Method" : "Collection Method", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                  DropdownButtonFormField<String>(
                    value: _orderMethod, 
                    items: ["Pickup", "Delivery"].map((String val) {
                      String label = val;
                      if (val == "Pickup") label = orderCategory == 'Service' ? "Walk-in (Bring device to shop)" : "Self Pickup (Go to shop)";
                      if (val == "Delivery") label = orderCategory == 'Service' ? "Runner Pickup (We collect from you)" : "Runner Delivery";
                      return DropdownMenuItem(value: val, child: Text(label));
                    }).toList(), 
                    onChanged: (val) => setState(() => _orderMethod = val!),
                    decoration: InputDecoration(labelText: "Method", border: const OutlineInputBorder(), prefixIcon: Icon(orderCategory == 'Printing' ? Icons.print : Icons.location_on, color: Colors.deepPurple))
                  ),
                  
                  if (_orderMethod == 'Delivery') ...[
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _deliveryLocation,
                      decoration: const InputDecoration(labelText: "Delivery Location", border: OutlineInputBorder(), isDense: true),
                      items: ["Lobby", "Room"].map((String val) => DropdownMenuItem(value: val, child: Text(val == 'Lobby' ? "Meet at Lobby" : "Deliver to Room"))).toList(),
                      onChanged: (val) => setState(() => _deliveryLocation = val!),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedCollege,
                      decoration: const InputDecoration(labelText: "Select College", border: OutlineInputBorder(), prefixIcon: Icon(Icons.apartment, color: Colors.deepPurple)),
                      items: _collegeList.map((String val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (val) => setState(() => _selectedCollege = val!),
                    ),
                    if (_deliveryLocation == 'Room') ...[
                      const SizedBox(height: 15),
                      TextField(controller: _roomController, decoration: const InputDecoration(labelText: "Room Number (e.g. A-201)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.door_front_door, color: Colors.deepPurple))),
                    ],
                    const SizedBox(height: 5),
                    const Text("+ RM 2.00 Delivery Fee applied", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
              ]),
            ),
            const SizedBox(height: 30),

            // --- 3. UPDATED ORDER SUMMARY ---
            const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  // List Items
                  ...userCart.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${item['quantity']}x ${item['name']}", style: const TextStyle(fontSize: 14))), Text("RM ${(double.parse(item['price'].toString()) * (item['quantity'] as int)).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))]))), 
                  
                  const Divider(thickness: 1, height: 20),
                  
                  // Subtotal (Cart items only)
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Subtotal", style: TextStyle(color: Colors.grey)), 
                    Text("RM ${widget.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))
                  ]),

                  // Binding Fee (Only shows if there is a fee)
                  if (_bindingFee > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Binding Fee", style: TextStyle(color: Colors.grey)), 
                        Text("RM ${_bindingFee.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))
                      ]),
                    ),

                  // Delivery Fee (Only shows if delivery selected)
                  if (_deliveryFee > 0)
                     Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Delivery Fee", style: TextStyle(color: Colors.grey)), 
                        Text("RM ${_deliveryFee.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))
                      ]),
                    ),

                  const Divider(thickness: 1, height: 20), 
                  
                  // Final Total
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Total Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
                    Text("RM ${_finalTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold))
                  ])
                ]
              ),
            ),
            const SizedBox(height: 30),

            // --- PAYMENT METHOD ---
            const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildPaymentOption(icon: Icons.money, title: "Cash Payment", value: "Cash", subtitle: orderCategory == 'Printing' ? "Pay at counter / to runner" : "Pay when you receive the item"),
            _buildPaymentOption(icon: Icons.qr_code_scanner, title: "DuitNow QR", value: "QR", subtitle: "Scan QR code instantly"),
            if (_selectedPayment == 'QR') Container(margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(20), width: double.infinity, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.deepPurple)), child: Column(children: const [Icon(Icons.qr_code_2, size: 100), Text("Scan to Pay", style: TextStyle(color: Colors.grey))])),
            _buildPaymentOption(icon: Icons.account_balance, title: "Online Banking", value: "Bank", subtitle: "Maybank2u, CIMB, etc"),
             if (_selectedPayment == 'Bank') Container(margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.deepPurple)), child: DropdownButton<String>(isExpanded: true, value: "Maybank2u", items: ["Maybank2u", "CIMB Clicks"].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (_) {})),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
        child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: _handlePayment, child: Text("Pay RM ${_finalTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildPaymentOption({required IconData icon, required String title, required String value, required String subtitle}) {
    final bool isSelected = _selectedPayment == value;
    return GestureDetector(onTap: () { setState(() { _selectedPayment = value; }); }, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: isSelected ? Colors.deepPurple.shade50 : Colors.white, border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300, width: isSelected ? 2 : 1), borderRadius: BorderRadius.circular(15)), child: Row(children: [Icon(icon, color: isSelected ? Colors.deepPurple : Colors.grey, size: 30), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.deepPurple : Colors.black)), Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))])), if (isSelected) const Icon(Icons.check_circle, color: Colors.deepPurple)])));
  }
}