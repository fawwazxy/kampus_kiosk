// lib/dummy_data.dart

// 1. The 4 Colleges
final List<Map<String, dynamic>> colleges = [
  {'name': 'Kolej Malinja', 'icon': 0xe7f1, 'color': 0xFF6A1B9A}, 
  {'name': 'Kolej Mahsuri', 'icon': 0xe0b0, 'color': 0xFFD81B60}, 
  {'name': 'Kolej Masria', 'icon': 0xe80c, 'color': 0xFF1976D2},  
  {'name': 'Kolej Jasmine', 'icon': 0xe55e, 'color': 0xFFF57C00}, 
];

// 2. Categories
final List<String> categories = ["Food", "Drinks", "Fashion", "Printing", "Repair"];

// 3. The Menu
final List<Map<String, String>> foodMenu = [
  // KOLEJ MALINJA (Food)
  {'name': 'Nasi Lemak Ayam', 'price': '6.00', 'college': 'Kolej Malinja', 'seller': 'Kak Sue (Room 202)', 'status': 'Open', 'image_icon': 'rice_bowl'},
  {'name': 'Teh Ais Ikat Tepi', 'price': '2.50', 'college': 'Kolej Malinja', 'seller': 'Kak Sue (Room 202)', 'status': 'Open', 'image_icon': 'local_drink'},
  
  // KOLEJ JASMINE (Services)
  {'name': 'Laptop Format (Windows)', 'price': '30.00', 'college': 'Kolej Jasmine', 'seller': 'Tech Fixers (Room 305)', 'status': 'Open', 'image_icon': 'computer'},
  {'name': 'Laptop Cleaning', 'price': '20.00', 'college': 'Kolej Jasmine', 'seller': 'Tech Fixers (Room 305)', 'status': 'Open', 'image_icon': 'cleaning_services'},
  
  // KOLEJ MASRIA (Printing & Clothes)
  {'name': 'Printing (B&W)', 'price': '0.10', 'college': 'Kolej Masria', 'seller': 'Aiman Print', 'status': 'Open', 'image_icon': 'print'},
  {'name': 'UiTM Corporate Shirt', 'price': '35.00', 'college': 'Kolej Masria', 'seller': 'Campus Bundle (Room 101)', 'status': 'Open', 'image_icon': 'checkroom'},
];

// 4. Cart 
List<Map<String, dynamic>> userCart = [];

// 5. ACTIVE ORDERS (Updated with Rider Names)
List<Map<String, dynamic>> activeOrders = [
  // CASE 1: Printing (Runner Delivery)
  {
    'id': '#ORD-7701', 
    'total': '3.50', 
    'status': 'Pending', 
    'time': 'Just Now', 
    'day': 'Today',
    'location': 'Runner Delivery (Extra RM2) (Kolej Malinja, A-202)', 
    'file': 'Assignment1.pdf',
    'rider_name': 'Amirul Runner', // NEW FIELD
    'items': [{'name': 'Printing (B&W)', 'quantity': 10, 'price': '0.10', 'seller': 'Aiman Print'}]
  },
  
  // CASE 2: Service (Walk-in)
  {
    'id': '#ORD-9905', 
    'total': '30.00', 
    'status': 'In Repair', 
    'time': 'Yesterday', 
    'day': 'Today', 
    'location': 'Walk-in / Pickup (Shop)', 
    'rider_name': null, // No rider for walk-in
    'items': [{'name': 'Laptop Format', 'quantity': 1, 'price': '30.00', 'seller': 'Tech Fixers (Room 305)'}]
  },
];

// 6. User Data
bool isGuest = false;
Map<String, String> currentUser = {}; 
List<Map<String, String>> registeredUsers = [
  {'name': 'Fawwaz Ruzain', 'id': '2025143733', 'email': 'student@uitm.edu.my', 'password': '123'}
];

// 7. Seller Accounts
List<Map<String, String>> sellerAccounts = [
  {'id': 'admin', 'password': 'admin', 'shop_name': 'Kak Sue (Room 202)'},
  {'id': 'tech', 'password': '123', 'shop_name': 'Tech Fixers (Room 305)'},
  {'id': 'print', 'password': '123', 'shop_name': 'Aiman Print'},
];