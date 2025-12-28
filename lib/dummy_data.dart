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

// 3. THE MASTER ITEM DATABASE (Food + Services + Fashion)
// We keep the variable name 'foodMenu' so the rest of your app doesn't break,
// but it now contains EVERYTHING organized by category.
final List<Map<String, String>> foodMenu = [
  
  // ==========================================
  // SECTION 1: FOOD & DRINKS
  // ==========================================
  
  // --- KOLEJ MALINJA: KAK SUE ---
  {'name': 'Nasi Lemak Ayam', 'price': '6.00', 'college': 'Kolej Malinja', 'seller': 'Kak Sue (Room 202)', 'status': 'Open', 'image_icon': 'rice_bowl'},
  {'name': 'Nasi Lemak Biasa', 'price': '3.00', 'college': 'Kolej Malinja', 'seller': 'Kak Sue (Room 202)', 'status': 'Open', 'image_icon': 'rice_bowl'},
  {'name': 'Nasi Goreng Kampung', 'price': '5.50', 'college': 'Kolej Malinja', 'seller': 'Kak Sue (Room 202)', 'status': 'Open', 'image_icon': 'rice_bowl'},
  {'name': 'Teh Ais Ikat Tepi', 'price': '2.50', 'college': 'Kolej Malinja', 'seller': 'Kak Sue (Room 202)', 'status': 'Open', 'image_icon': 'local_drink'},
  {'name': 'Milo Ais Kaw', 'price': '3.50', 'college': 'Kolej Malinja', 'seller': 'Kak Sue (Room 202)', 'status': 'Open', 'image_icon': 'local_drink'},
  {'name': 'Keropok Lekor', 'price': '3.00', 'college': 'Kolej Malinja', 'seller': 'Kak Sue (Room 202)', 'status': 'Open', 'image_icon': 'tapas'},

  // --- KOLEJ MAHSURI: BRO BURGER ---
  {'name': 'Burger Ayam Special', 'price': '4.50', 'college': 'Kolej Mahsuri', 'seller': 'Bro Burger (Room 112)', 'status': 'Open', 'image_icon': 'fastfood'},
  {'name': 'Burger Daging Special', 'price': '5.00', 'college': 'Kolej Mahsuri', 'seller': 'Bro Burger (Room 112)', 'status': 'Open', 'image_icon': 'fastfood'},
  {'name': 'Fries (Large)', 'price': '4.00', 'college': 'Kolej Mahsuri', 'seller': 'Bro Burger (Room 112)', 'status': 'Open', 'image_icon': 'tapas'},
  {'name': 'Coke Tin', 'price': '2.50', 'college': 'Kolej Mahsuri', 'seller': 'Bro Burger (Room 112)', 'status': 'Open', 'image_icon': 'local_drink'},

  // --- KOLEJ JASMINE: CHEF JOJO ---
  {'name': 'Chicken Chop', 'price': '12.00', 'college': 'Kolej Jasmine', 'seller': 'Chef Jojo (Room 305)', 'status': 'Open', 'image_icon': 'restaurant'},
  {'name': 'Spaghetti Aglio Olio', 'price': '9.00', 'college': 'Kolej Jasmine', 'seller': 'Chef Jojo (Room 305)', 'status': 'Open', 'image_icon': 'restaurant_menu'},
  {'name': 'Lemon Tea Ice', 'price': '3.00', 'college': 'Kolej Jasmine', 'seller': 'Chef Jojo (Room 305)', 'status': 'Open', 'image_icon': 'local_drink'},

  // --- KOLEJ MASRIA: SWEET TOOTH ---
  {'name': 'Waffle Chocolate', 'price': '3.50', 'college': 'Kolej Masria', 'seller': 'Sweet Tooth', 'status': 'Open', 'image_icon': 'cake'},
  {'name': 'Ice Cream Malaysia', 'price': '1.00', 'college': 'Kolej Masria', 'seller': 'Sweet Tooth', 'status': 'Open', 'image_icon': 'icecream'},

  // ==========================================
  // SECTION 2: SERVICES (REPAIR & TECH)
  // ==========================================
  
  // --- KOLEJ JASMINE: TECH FIXERS ---
  {'name': 'Laptop Format (Windows)', 'price': '30.00', 'college': 'Kolej Jasmine', 'seller': 'Tech Fixers (Room 305)', 'status': 'Open', 'image_icon': 'computer'},
  {'name': 'Install Software (Office)', 'price': '10.00', 'college': 'Kolej Jasmine', 'seller': 'Tech Fixers (Room 305)', 'status': 'Open', 'image_icon': 'save'},
  {'name': 'Laptop Dust Cleaning', 'price': '20.00', 'college': 'Kolej Jasmine', 'seller': 'Tech Fixers (Room 305)', 'status': 'Open', 'image_icon': 'cleaning_services'},
  {'name': 'Thermal Paste Service', 'price': '15.00', 'college': 'Kolej Jasmine', 'seller': 'Tech Fixers (Room 305)', 'status': 'Open', 'image_icon': 'build'},

  // ==========================================
  // SECTION 3: PRINTING SERVICES
  // ==========================================
  
  // --- KOLEJ MASRIA: AIMAN PRINT ---
  {'name': 'Printing (B&W)', 'price': '0.10', 'college': 'Kolej Masria', 'seller': 'Aiman Print', 'status': 'Open', 'image_icon': 'print'},
  {'name': 'Printing (Color)', 'price': '0.50', 'college': 'Kolej Masria', 'seller': 'Aiman Print', 'status': 'Open', 'image_icon': 'print'},
  {'name': 'Binding Service (Tape)', 'price': '2.00', 'college': 'Kolej Masria', 'seller': 'Aiman Print', 'status': 'Open', 'image_icon': 'menu_book'},
  {'name': 'Laminate (A4)', 'price': '1.50', 'college': 'Kolej Masria', 'seller': 'Aiman Print', 'status': 'Open', 'image_icon': 'layers'},

  // ==========================================
  // SECTION 4: FASHION & APPAREL
  // ==========================================
  
  // --- KOLEJ MASRIA: CAMPUS BUNDLE ---
  {'name': 'UiTM Corporate Shirt', 'price': '35.00', 'college': 'Kolej Masria', 'seller': 'Campus Bundle (Room 101)', 'status': 'Open', 'image_icon': 'checkroom'},
  {'name': 'Vintage Hoodie (L)', 'price': '15.00', 'college': 'Kolej Masria', 'seller': 'Campus Bundle (Room 101)', 'status': 'Open', 'image_icon': 'checkroom'},
  {'name': 'Pre-loved Jeans (32)', 'price': '10.00', 'college': 'Kolej Masria', 'seller': 'Campus Bundle (Room 101)', 'status': 'Open', 'image_icon': 'checkroom'},
  {'name': 'Cotton Cap', 'price': '8.00', 'college': 'Kolej Masria', 'seller': 'Campus Bundle (Room 101)', 'status': 'Open', 'image_icon': 'checkroom'},
];

// 4. Cart 
List<Map<String, dynamic>> userCart = [];

// 5. ACTIVE ORDERS (Demo Data)
List<Map<String, dynamic>> activeOrders = [
  // ORDER 1: PENDING (Food Runner)
  {
    'id': '#ORD-7701', 
    'total': '17.50', 
    'status': 'Pending', 
    'time': 'Just Now', 
    'day': 'Today',
    'location': 'Runner Delivery (Extra RM2) (Kolej Malinja, A-202)', 
    'rider_name': 'Amirul Runner', 
    'items': [
      {'name': 'Nasi Lemak Ayam', 'quantity': 2, 'price': '6.00', 'seller': 'Kak Sue (Room 202)'},
      {'name': 'Teh Ais Ikat Tepi', 'quantity': 1, 'price': '2.50', 'seller': 'Kak Sue (Room 202)'}
    ]
  },
  
  // ORDER 2: IN REPAIR (Service Walk-in)
  {
    'id': '#ORD-9905', 
    'total': '30.00', 
    'status': 'In Repair', 
    'time': '1 Hour ago', 
    'day': 'Today', 
    'location': 'Walk-in / Pickup (Shop)', 
    'rider_name': null, 
    'items': [{'name': 'Laptop Format', 'quantity': 1, 'price': '30.00', 'seller': 'Tech Fixers (Room 305)'}]
  },

  // ORDER 3: COMPLETED (Analytics)
  {
    'id': '#ORD-1001', 
    'total': '18.00', 
    'status': 'Delivered', 
    'time': 'Yesterday', 
    'day': 'Yesterday', 
    'location': 'Deliver to Room (Kolej Mahsuri)',
    'rider_name': 'Hafiz Rider',
    'items': [{'name': 'Burger Ayam Special', 'quantity': 4, 'price': '4.50', 'seller': 'Bro Burger (Room 112)'}]
  },
];

// 6. User Data
bool isGuest = false;
Map<String, String> currentUser = {}; 
List<Map<String, String>> registeredUsers = [
  {'name': 'Fawwaz Ruzain', 'id': '2025143733', 'email': 'student@uitm.edu.my', 'password': '123'}
];

// 7. Seller Accounts (Added all shops)
List<Map<String, String>> sellerAccounts = [
  {'id': 'admin', 'password': 'admin', 'shop_name': 'Kak Sue (Room 202)'},
  {'id': 'burger', 'password': '123', 'shop_name': 'Bro Burger (Room 112)'},
  {'id': 'tech', 'password': '123', 'shop_name': 'Tech Fixers (Room 305)'},
  {'id': 'print', 'password': '123', 'shop_name': 'Aiman Print'},
  {'id': 'chef', 'password': '123', 'shop_name': 'Chef Jojo (Room 305)'},
  {'id': 'bundle', 'password': '123', 'shop_name': 'Campus Bundle (Room 101)'},
];