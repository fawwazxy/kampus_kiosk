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
  // 1. General State
  String _deliveryType = 'Deliver to Room'; 
  
  // College Selection
  String _selectedCollege = 'Kolej Malinja (Siswa)'; 
  final List<String> _collegeList = [
    'Kolej Malinja (Siswa)',
    'Kolej Murni (Siswi)',
    'Kolej Masria (Siswi)',
    'Kolej Mahsuri (Siswi)',
  ];

  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController(); 
  String _selectedPayment = 'Cash'; 
  
  // 2. Logic Category
  String orderCategory = 'Food'; 

  // 3. Printing Specific State
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
        _deliveryType = 'Self Pickup (Shop)'; 
      } 
      else if (['computer', 'save', 'cleaning_services', 'build'].contains(icon)) {
        orderCategory = 'Service';
        _deliveryType = 'Walk-in / Pickup';
      } 
      else if (icon == 'checkroom') {
        orderCategory = 'Fashion';
      }
    }
  }

  double get _finalTotal {
    double total = widget.totalAmount;
    if (orderCategory == 'Printing') {
      if (_bindingType == 'Tape Binding') total += 1.00;
      if (_bindingType == 'Comb Binding') total += 2.00;
    }
    // Add cost if using Runner/Delivery/Lobby
    // NOTE: Meet at Lobby also incurs fee as it's a delivery
    if (_deliveryType.contains('Runner') || _deliveryType == 'Deliver to Room' || _deliveryType == 'Meet at Lobby') total += 2.00; 
    return total;
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
    if (orderCategory == 'Printing' && _uploadedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload your document first!"), backgroundColor: Colors.red));
      return;
    }
    
    // Check Room Number ONLY if "Deliver to Room" is selected
    if (_deliveryType == 'Deliver to Room' && _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your Room Number"), backgroundColor: Colors.red));
      return;
    }

    // --- CONSTRUCT LOCATION STRING ---
    String finalLocation = _deliveryType;
    
    if (_deliveryType == 'Deliver to Room') {
      finalLocation = "$_deliveryType ($_selectedCollege, ${_roomController.text})";
    } 
    // --- FIX: Meet at Lobby also needs College ---
    else if (_deliveryType == 'Meet at Lobby') {
      finalLocation = "$_deliveryType ($_selectedCollege)";
    }
    else if (_deliveryType.contains('Runner')) {
       finalLocation = "$_deliveryType ($_selectedCollege)"; // Runner needs to know where to go
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
                  'status': 'Pending', // Start as Pending
                  'time': 'Just Now',
                  'day': 'Today',
                  'location': finalLocation, 
                  'items': List.from(userCart), 
                  'binding': orderCategory == 'Printing' ? _bindingType : null,
                  'double_sided': orderCategory == 'Printing' ? _isDoubleSided : null,
                  'remarks': _remarksController.text.isEmpty ? 'None' : _remarksController.text,
                  'file': _uploadedFile,
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
    List<String> deliveryOptions = ["Deliver to Room", "Meet at Lobby"];
    if (orderCategory == 'Service') deliveryOptions = ["Walk-in / Pickup", "Runner Pickup (Extra RM2)"];
    if (orderCategory == 'Printing') deliveryOptions = ["Self Pickup (Shop)", "Runner Delivery (Extra RM2)"];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text(orderCategory == 'Printing' ? "Print Job Checkout" : "Checkout", style: const TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Text(orderCategory == 'Printing' ? "Collection Method" : "Delivery Details", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                  DropdownButtonFormField<String>(
                    value: _deliveryType, 
                    items: deliveryOptions.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(), 
                    onChanged: (val) => setState(() => _deliveryType = val!),
                    decoration: InputDecoration(labelText: "Method", border: const OutlineInputBorder(), prefixIcon: Icon(orderCategory == 'Printing' ? Icons.print : Icons.location_on, color: Colors.deepPurple))
                  ),
                  
                  // --- FIX: Show College Selection for ALL delivery types except Self Pickup ---
                  if (!_deliveryType.contains('Self') && !_deliveryType.contains('Walk-in')) ...[
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedCollege,
                      decoration: const InputDecoration(labelText: "Select College", border: OutlineInputBorder(), prefixIcon: Icon(Icons.apartment, color: Colors.deepPurple)),
                      items: _collegeList.map((String val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (val) => setState(() => _selectedCollege = val!),
                    ),
                  ],

                  // Show Room Number ONLY for "Deliver to Room"
                  if (_deliveryType == 'Deliver to Room') ...[
                    const SizedBox(height: 15),
                    TextField(controller: _roomController, decoration: const InputDecoration(labelText: "Room Number (e.g. A-201)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.door_front_door, color: Colors.deepPurple))),
                  ],

                  // Show Delivery Fee Note
                  if (!_deliveryType.contains('Self') && !_deliveryType.contains('Walk-in')) ...[
                    const SizedBox(height: 5),
                    const Text("+ RM 2.00 Delivery Fee", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ]
              ]),
            ),
            const SizedBox(height: 30),

            const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                ...userCart.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${item['quantity']}x ${item['name']}", style: const TextStyle(fontSize: 14))), Text("RM ${(double.parse(item['price'].toString()) * (item['quantity'] as int)).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))]))), 
                const Divider(thickness: 1, height: 30), 
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text("RM ${_finalTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold))])]),
            ),
            const SizedBox(height: 30),

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