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

// 3. THE MASTER ITEM DATABASE
final List<Map<String, String>> foodMenu = [
  
  // ==========================================
  // SECTION 1: FOOD & DRINKS
  // ==========================================
  
  // --- KOLEJ MALINJA: KAK SUE ---
  {
    'name': 'Nasi Lemak Ayam', 
    'price': '6.00', 
    'college': 'Kolej Malinja', 
    'seller': 'Kak Sue (Room 202)', 
    'status': 'Open', 
    'image_icon': 'rice_bowl',
    'image_url': 'https://images.unsplash.com/photo-1626074353765-517a681e40be?w=600&q=80'
  },
  {
    'name': 'Nasi Lemak Biasa', 
    'price': '3.00', 
    'college': 'Kolej Malinja', 
    'seller': 'Kak Sue (Room 202)', 
    'status': 'Open', 
    'image_icon': 'rice_bowl',
    'image_url': 'https://images.unsplash.com/photo-1596560548464-f010549b84d7?w=600&q=80'
  },
  {
    'name': 'Nasi Goreng Kampung', 
    'price': '5.50', 
    'college': 'Kolej Malinja', 
    'seller': 'Kak Sue (Room 202)', 
    'status': 'Open', 
    'image_icon': 'rice_bowl',
    'image_url': 'https://images.unsplash.com/photo-1603133872878-684f10842740?w=600&q=80'
  },
  {
    'name': 'Teh Ais Ikat Tepi', 
    'price': '2.50', 
    'college': 'Kolej Malinja', 
    'seller': 'Kak Sue (Room 202)', 
    'status': 'Open', 
    'image_icon': 'local_drink',
    'image_url': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600&q=80'
  },
  {
    'name': 'Milo Ais Kaw', 
    'price': '3.50', 
    'college': 'Kolej Malinja', 
    'seller': 'Kak Sue (Room 202)', 
    'status': 'Open', 
    'image_icon': 'local_drink',
    'image_url': 'https://images.unsplash.com/photo-1542849187-5ec6ea5e6a27?w=600&q=80'
  },
  {
    'name': 'Keropok Lekor', 
    'price': '3.00', 
    'college': 'Kolej Malinja', 
    'seller': 'Kak Sue (Room 202)', 
    'status': 'Open', 
    'image_icon': 'tapas',
    'image_url': 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=600&q=80'
  },

  // --- KOLEJ MAHSURI: BRO BURGER ---
  {
    'name': 'Burger Ayam Special', 
    'price': '4.50', 
    'college': 'Kolej Mahsuri', 
    'seller': 'Bro Burger (Room 112)', 
    'status': 'Open', 
    'image_icon': 'fastfood',
    'image_url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80'
  },
  {
    'name': 'Burger Daging Special', 
    'price': '5.00', 
    'college': 'Kolej Mahsuri', 
    'seller': 'Bro Burger (Room 112)', 
    'status': 'Open', 
    'image_icon': 'fastfood',
    'image_url': 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=600&q=80'
  },
  {
    'name': 'Fries (Large)', 
    'price': '4.00', 
    'college': 'Kolej Mahsuri', 
    'seller': 'Bro Burger (Room 112)', 
    'status': 'Open', 
    'image_icon': 'tapas',
    'image_url': 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600&q=80'
  },
  {
    'name': 'Coke Tin', 
    'price': '2.50', 
    'college': 'Kolej Mahsuri', 
    'seller': 'Bro Burger (Room 112)', 
    'status': 'Open', 
    'image_icon': 'local_drink',
    'image_url': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=600&q=80'
  },

  // --- KOLEJ JASMINE: CHEF JOJO ---
  {
    'name': 'Chicken Chop', 
    'price': '12.00', 
    'college': 'Kolej Jasmine', 
    'seller': 'Chef Jojo (Room 305)', 
    'status': 'Open', 
    'image_icon': 'restaurant',
    'image_url': 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=600&q=80'
  },
  {
    'name': 'Spaghetti Aglio Olio', 
    'price': '9.00', 
    'college': 'Kolej Jasmine', 
    'seller': 'Chef Jojo (Room 305)', 
    'status': 'Open', 
    'image_icon': 'restaurant_menu',
    'image_url': 'https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?w=600&q=80'
  },
  {
    'name': 'Lemon Tea Ice', 
    'price': '3.00', 
    'college': 'Kolej Jasmine', 
    'seller': 'Chef Jojo (Room 305)', 
    'status': 'Open', 
    'image_icon': 'local_drink',
    'image_url': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&q=80'
  },

  // --- KOLEJ MASRIA: SWEET TOOTH ---
  {
    'name': 'Waffle Chocolate', 
    'price': '3.50', 
    'college': 'Kolej Masria', 
    'seller': 'Sweet Tooth', 
    'status': 'Open', 
    'image_icon': 'cake',
    'image_url': 'https://images.unsplash.com/photo-1562376552-0d160a2f238d?w=600&q=80'
  },
  {
    'name': 'Ice Cream Malaysia', 
    'price': '1.00', 
    'college': 'Kolej Masria', 
    'seller': 'Sweet Tooth', 
    'status': 'Open', 
    'image_icon': 'icecream',
    'image_url': 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=600&q=80'
  },

  // ==========================================
  // SECTION 2: SERVICES (REPAIR & TECH)
  // ==========================================
  
  // --- KOLEJ JASMINE: TECH FIXERS ---
  {
    'name': 'Laptop Format (Windows)', 
    'price': '30.00', 
    'college': 'Kolej Jasmine', 
    'seller': 'Tech Fixers (Room 305)', 
    'status': 'Open', 
    'image_icon': 'computer',
    'image_url': 'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?w=600&q=80'
  },
  {
    'name': 'Install Software (Office)', 
    'price': '10.00', 
    'college': 'Kolej Jasmine', 
    'seller': 'Tech Fixers (Room 305)', 
    'status': 'Open', 
    'image_icon': 'save',
    'image_url': 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=600&q=80'
  },
  {
    'name': 'Laptop Dust Cleaning', 
    'price': '20.00', 
    'college': 'Kolej Jasmine', 
    'seller': 'Tech Fixers (Room 305)', 
    'status': 'Open', 
    'image_icon': 'cleaning_services',
    'image_url': 'https://images.unsplash.com/photo-1588508065123-287b28e013da?w=600&q=80'
  },
  {
    'name': 'Thermal Paste Service', 
    'price': '15.00', 
    'college': 'Kolej Jasmine', 
    'seller': 'Tech Fixers (Room 305)', 
    'status': 'Open', 
    'image_icon': 'build',
    'image_url': 'https://images.unsplash.com/photo-1597872250990-d991aa21d43c?w=600&q=80'
  },

  // ==========================================
  // SECTION 3: PRINTING SERVICES
  // ==========================================
  
  // --- KOLEJ MASRIA: AIMAN PRINT ---
  {
    'name': 'Printing (B&W)', 
    'price': '0.10', 
    'college': 'Kolej Masria', 
    'seller': 'Aiman Print', 
    'status': 'Open', 
    'image_icon': 'print',
    'image_url': 'https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?w=600&q=80'
  },
  {
    'name': 'Printing (Color)', 
    'price': '0.50', 
    'college': 'Kolej Masria', 
    'seller': 'Aiman Print', 
    'status': 'Open', 
    'image_icon': 'print',
    'image_url': 'https://images.unsplash.com/photo-1562564025-51dc11516a0b?w=600&q=80'
  },
  {
    'name': 'Binding Service (Tape)', 
    'price': '2.00', 
    'college': 'Kolej Masria', 
    'seller': 'Aiman Print', 
    'status': 'Open', 
    'image_icon': 'menu_book',
    'image_url': 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600&q=80'
  },
  {
    'name': 'Laminate (A4)', 
    'price': '1.50', 
    'college': 'Kolej Masria', 
    'seller': 'Aiman Print', 
    'status': 'Open', 
    'image_icon': 'layers',
    'image_url': 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?w=600&q=80'
  },

  // ==========================================
  // SECTION 4: FASHION & APPAREL
  // ==========================================
  
  // --- KOLEJ MASRIA: CAMPUS BUNDLE ---
  {
    'name': 'UiTM Corporate Shirt', 
    'price': '35.00', 
    'college': 'Kolej Masria', 
    'seller': 'Campus Bundle (Room 101)', 
    'status': 'Open', 
    'image_icon': 'checkroom',
    'image_url': 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=600&q=80'
  },
  {
    'name': 'Vintage Hoodie (L)', 
    'price': '15.00', 
    'college': 'Kolej Masria', 
    'seller': 'Campus Bundle (Room 101)', 
    'status': 'Open', 
    'image_icon': 'checkroom',
    'image_url': 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600&q=80'
  },
  {
    'name': 'Pre-loved Jeans (32)', 
    'price': '10.00', 
    'college': 'Kolej Masria', 
    'seller': 'Campus Bundle (Room 101)', 
    'status': 'Open', 
    'image_icon': 'checkroom',
    'image_url': 'https://images.unsplash.com/photo-1542272617-08f086303293?w=600&q=80'
  },
  {
    'name': 'Cotton Cap', 
    'price': '8.00', 
    'college': 'Kolej Masria', 
    'seller': 'Campus Bundle (Room 101)', 
    'status': 'Open', 
    'image_icon': 'checkroom',
    'image_url': 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=600&q=80'
  },
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
  {'name': 'Fawwaz Ruzain', 'id': '1', 'email': 'student@uitm.edu.my', 'password': '1'}
];

// 7. Seller Accounts
List<Map<String, String>> sellerAccounts = [
  {'id': 'admin', 'password': 'admin', 'shop_name': 'Kak Sue (Room 202)'},
  {'id': 'burger', 'password': '123', 'shop_name': 'Bro Burger (Room 112)'},
  {'id': 'tech', 'password': '123', 'shop_name': 'Tech Fixers (Room 305)'},
  {'id': 'print', 'password': '123', 'shop_name': 'Aiman Print'},
  {'id': 'chef', 'password': '123', 'shop_name': 'Chef Jojo (Room 305)'},
  {'id': 'bundle', 'password': '123', 'shop_name': 'Campus Bundle (Room 101)'},
];

// 8. Seller Inbox (Chat History)
List<Map<String, dynamic>> sellerInbox = [
  // --- 1. KAK SUE (ID: admin) ---
  {
    'seller_id': 'admin', 
    'name': 'Ali (Student)',
    'last_message': 'Hi, is the Nasi Lemak still available?',
    'time': '10:45 AM',
    'unread_count': 2, 
    'color': 0xFF2196F3, 
    'messages': [
      {'text': 'Hi, is the Nasi Lemak still available?', 'isMe': false, 'time': '10:45 AM'},
      {'text': 'I want to order 5 packs.', 'isMe': false, 'time': '10:46 AM'},
    ]
  },

  // --- 2. BRO BURGER (ID: burger) ---
  {
    'seller_id': 'burger', 
    'name': 'Sarah (Student)',
    'last_message': 'Thank you! The burger was delicious.',
    'time': 'Yesterday',
    'unread_count': 0, 
    'color': 0xFFE91E63, 
    'messages': [
      {'text': 'Thank you! The burger was delicious.', 'isMe': false, 'time': 'Yesterday'},
    ]
  },

  // --- 3. TECH FIXERS (ID: tech) ---
  {
    'seller_id': 'tech', 
    'name': 'Aiman (Student)',
    'last_message': 'Can I pickup my laptop?',
    'time': 'Yesterday',
    'unread_count': 5, 
    'color': 0xFFFF9800, 
    'messages': [
      {'text': 'Can I pickup my laptop?', 'isMe': false, 'time': 'Yesterday'},
    ]
  },

  // --- 4. AIMAN PRINT (ID: print) ---
  {
    'seller_id': 'print', 
    'name': 'Siti (Student)',
    'last_message': 'Sent PDF for binding.',
    'time': '10:00 AM',
    'unread_count': 3, 
    'color': 0xFF9C27B0, 
    'messages': [
      {'text': 'Sent PDF.', 'isMe': false, 'time': '10:00 AM'},
    ]
  },

  // --- 5. CAMPUS BUNDLE (ID: bundle) ---
  {
    'seller_id': 'bundle', 
    'name': 'Farid (Student)',
    'last_message': 'Got size XL?',
    'time': '2 Days Ago',
    'unread_count': 1, 
    'color': 0xFF4CAF50, 
    'messages': [
      {'text': 'Got size XL?', 'isMe': false, 'time': '2 Days Ago'},
    ]
  },
  
  // --- 6. CHEF JOJO (ID: chef) ---
  {
    'seller_id': 'chef', 
    'name': 'Mei Ling (Student)',
    'last_message': 'Is the Chicken Chop spicy?',
    'time': '11:30 AM',
    'unread_count': 1, 
    'color': 0xFFE91E63, // Pink
    'messages': [
      {'text': 'Is the Chicken Chop spicy?', 'isMe': false, 'time': '11:30 AM'},
    ]
  },
];