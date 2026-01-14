import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String sellerName;
  final dynamic initialMessages; // Changed to dynamic to prevent crashes

  const ChatScreen({
    super.key, 
    required this.sellerName, 
    this.initialMessages 
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSellerMode = false; 

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessagesSafe();
  }

  void _loadMessagesSafe() {
    // 1. Check if data exists and is actually a List
    if (widget.initialMessages != null && widget.initialMessages is List) {
      List<dynamic> rawList = widget.initialMessages as List<dynamic>;
      
      setState(() {
        messages = rawList.map((item) {
          // 2. Safely extract data, defaulting to empty strings if null
          return {
            'text': item['text']?.toString() ?? "...",
            'isMe': item['isMe'] ?? false, 
            'time': item['time']?.toString() ?? "Now"
          };
        }).toList();
      });
    } else {
      // 3. Fallback if no messages found
      setState(() {
        messages = [
          {'text': "Hello! Welcome to ${widget.sellerName}.", 'isMe': false, 'time': 'Now'},
          {'text': "How can we help you today?", 'isMe': false, 'time': 'Now'},
        ];
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'text': _messageController.text,
        'isMe': !_isSellerMode, 
        'time': "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      });
      _messageController.clear();
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      // APP BAR (Should always show now)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sellerName, style: const TextStyle(color: Colors.black, fontSize: 16)),
                  const Text("Online", style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // MESSAGE LIST
          Expanded(
            child: messages.isEmpty 
            ? const Center(child: Text("No messages.")) 
            : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final bool isMe = msg['isMe'] == true; // Strict check
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepPurple : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
                        const SizedBox(height: 5),
                        Text(msg['time'], style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // INPUT AREA
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isSellerMode ? Colors.orange.shade50 : Colors.white, 
              border: Border(top: BorderSide(color: Colors.grey.shade200))
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isSellerMode ? Icons.store : Icons.person, color: _isSellerMode ? Colors.orange : Colors.grey),
                  onPressed: () => setState(() => _isSellerMode = !_isSellerMode),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _isSellerMode ? "Reply as Seller..." : "Type message...",
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Colors.deepPurple)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}