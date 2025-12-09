import 'package:flutter/material.dart';
import 'dummy_data.dart';
import 'main.dart';
import 'seller_dashboard.dart'; // IMPORTANT: Import the admin screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // 1. ANIMATION CONTROLLERS
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // 2. FORM STATE
  bool isRegistering = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Setup Animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- MAIN AUTHENTICATION LOGIC ---
  void _handleAuth() {
    String inputID = _idController.text.trim();
    String inputPass = _passwordController.text.trim();

    // 1. REGISTER MODE
    if (isRegistering) {
      if (_nameController.text.isEmpty || inputID.isEmpty || inputPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.red));
        return;
      }
      
      // Save to "Database"
      registeredUsers.add({
        'name': _nameController.text,
        'id': inputID,
        'email': _emailController.text.isEmpty ? 'student@uitm.edu.my' : _emailController.text,
        'password': inputPass,
      });
      
      currentUser = registeredUsers.last;
      isGuest = false;
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Logging in..."), backgroundColor: Colors.green));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScaffold()));
    } 
    
    // 2. LOGIN MODE
    else {
      // A. CHECK IF SELLER?
      // "firstWhere" returns empty map if nothing found, handled by orElse
      var foundSeller = sellerAccounts.firstWhere(
        (user) => user['id'] == inputID && user['password'] == inputPass,
        orElse: () => {},
      );

      if (foundSeller.isNotEmpty) {
        // YES! GO TO SELLER DASHBOARD
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => SellerDashboard(shopName: foundSeller['shop_name']!))
        );
        return;
      }

      // B. CHECK IF STUDENT?
      var foundUser = registeredUsers.firstWhere(
        (user) => user['id'] == inputID && user['password'] == inputPass,
        orElse: () => {},
      );

      if (foundUser.isNotEmpty) {
        // YES! GO TO MAIN APP
        currentUser = foundUser;
        isGuest = false;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScaffold()));
      } else {
        // FAIL
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Login Failed"),
            content: const Text("Invalid credentials.\n\nStudent: 2025143733 / 123456\nSeller: admin / admin"),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
          ),
        );
      }
    }
  }

  // Handle System Back Button
  Future<bool> _onWillPop() async {
    if (isRegistering) {
      setState(() {
        isRegistering = false;
        _controller.reset();
        _controller.forward();
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView( 
          child: SizedBox(
            height: MediaQuery.of(context).size.height, 
            child: Stack(
              children: [
                // --- SECTION 1: PURPLE HEADER ---
                Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.storefront_outlined, size: 60, color: Colors.deepPurple),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: const Text("KampusKiosk", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                            ),
                            const SizedBox(height: 5),
                            FadeTransition(
                              opacity: _controller,
                              child: const Text("UiTM Kedah Delivery App", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(flex: 6, child: Container(color: Colors.white)), 
                  ],
                ),

                // --- SECTION 2: SLIDING FORM ---
                Positioned.fill(
                  child: Column(
                    children: [
                      const Spacer(flex: 4), 
                      Expanded(
                        flex: 6,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isRegistering ? "Create Account" : "Welcome Back",
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const Text("Please sign in to continue", style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 25),

                                  if (isRegistering) ...[
                                    _buildTextField(_nameController, "Full Name", Icons.person, false),
                                    const SizedBox(height: 15),
                                  ],
                                  _buildTextField(_idController, "User ID / Student ID", Icons.badge, true),
                                  const SizedBox(height: 15),
                                  if (isRegistering) ...[
                                    _buildTextField(_emailController, "Email (Optional)", Icons.email, false),
                                    const SizedBox(height: 15),
                                  ],
                                  _buildTextField(_passwordController, "Password", Icons.lock, false, isPassword: true),

                                  const SizedBox(height: 30),

                                  // LOGIN BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 5,
                                      ),
                                      onPressed: _handleAuth,
                                      child: Text(
                                        isRegistering ? "Register" : "Login",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // TOGGLE & GUEST
                                  Center(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isRegistering = !isRegistering;
                                              _controller.reset();
                                              _controller.forward();
                                            });
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              text: isRegistering ? "Already have an account? " : "New here? ",
                                              style: const TextStyle(color: Colors.grey),
                                              children: [
                                                TextSpan(
                                                  text: isRegistering ? "Login" : "Create Account",
                                                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextButton(
                                          onPressed: () {
                                            isGuest = true;
                                            currentUser = {};
                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScaffold()));
                                          },
                                          child: const Text("Skip & Continue as Guest", style: TextStyle(color: Colors.grey)),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SECTION 3: BACK BUTTON (Register Mode) ---
                if (isRegistering)
                  Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isRegistering = false;
                          _controller.reset();
                          _controller.forward();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isNumber, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}