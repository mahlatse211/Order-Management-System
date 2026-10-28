import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatbotScreen extends StatefulWidget {
  final String orderId;
  final String serviceName;

  const ChatbotScreen({super.key, required this.orderId, required this.serviceName});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  bool _isBotTyping = false; 
  
  // 1. Initialize it immediately so FutureBuilder doesn't crash
  late Future<List<Map<String, dynamic>>> _requestsFuture;
  
  bool _isOrderCancelled = false; 

  @override
  void initState() {
    super.initState();
    // Set the future FIRST
    _requestsFuture = _fetchChangeRequests(); 
    // Then check the order status in the background
    _checkOrderStatus(); 
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // 2. Separate the check so it doesn't block the UI
  Future<void> _checkOrderStatus() async {
    try {
      final order = await Supabase.instance.client
          .from('orders')
          .select('status')
          .eq('order_id', widget.orderId)
          .single();
          
      if (mounted) {
        setState(() {
          _isOrderCancelled = order['status'].toString().toLowerCase() == 'cancelled';
        });
      }
    } catch (e) {
      debugPrint('Error checking status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchChangeRequests() async {
    final response = await Supabase.instance.client
        .from('change_requests')
        .select()
        .eq('order_id', widget.orderId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isOrderCancelled) return;

    final customerMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
      _isBotTyping = true; 
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      final customerRecord = await Supabase.instance.client
          .from('customers')
          .select('id')
          .eq('auth_id', user!.id)
          .single();

      final int customerId = customerRecord['id'];

      // 1. Save Customer Message
      await Supabase.instance.client.from('change_requests').insert({
        'order_id': widget.orderId,
        'customer_id': customerId,
        'message': customerMessage,
        'status': 'Pending',
        'is_admin': false,
      });

      setState(() {
        _requestsFuture = _fetchChangeRequests();
      });

      // 2. Bot Logic
      await Future.delayed(const Duration(seconds: 2));

      String botReply;
      String finalBotMessage;

      // 3. If Order is Cancelled, give the specific response
      if (_isOrderCancelled) {
        botReply = "Sorry! You have cancelled this order. We cannot proceed with the order.";
        finalBotMessage = "If you wish to start a new project, please place a new order.";
      } else {
        botReply = "Got it. I've received your request regarding the **${widget.serviceName}** order. Our admin team will review the details shortly.";
        
        if (customerMessage.toLowerCase().contains('color') || customerMessage.toLowerCase().contains('colour')) {
           botReply = "Noted! Color changes are a popular request. I've passed your update to the designer reviewing your **${widget.serviceName}** order.";
        } else if (customerMessage.toLowerCase().contains('urgent') || customerMessage.toLowerCase().contains('asap')) {
           botReply = "I understand this is urgent. I've flagged your **${widget.serviceName}** request for immediate review by our team.";
        }
        finalBotMessage = "If you need to add anything else, feel free to type below. Otherwise, keep an eye on this chat for our response!";
      }

      // 4. Save Bot Message
      await Supabase.instance.client.from('change_requests').insert({
        'order_id': widget.orderId,
        'customer_id': customerId,
        'message': "$botReply\n\n$finalBotMessage",
        'status': 'Info', 
        'is_admin': true, 
      });

      if (mounted) {
        setState(() {
          _isBotTyping = false;
          _requestsFuture = _fetchChangeRequests();
        });
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isBotTyping = false);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: ${widget.serviceName}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !_isBotTyping) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty && !_isBotTyping) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nSend a request to make changes to this order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length + (_isBotTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isBotTyping && index == requests.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)),
                              SizedBox(width: 10),
                              Text('Admin is typing...', style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      );
                    }

                    final req = requests[index];
                    final isApproved = req['status'] == 'Approved';
                    final isDeclined = req['status'] == 'Declined';
                    final isAdmin = req['is_admin'] == true;

                    if (isAdmin) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.smart_toy, color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(req['message'], style: const TextStyle(fontSize: 14, color: Colors.black87))),
                            ],
                          ),
                        ),
                      );
                    }

                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        decoration: BoxDecoration(
                          color: isApproved ? Colors.green[50] : isDeclined ? Colors.red[50] : Colors.grey[200],
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(2)),
                          border: Border.all(color: isApproved ? Colors.green : isDeclined ? Colors.red : Colors.grey[400]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req['message'], style: const TextStyle(fontSize: 15)),
                            
                            if (req['status'] != 'Info') ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(isApproved ? Icons.check_circle : isDeclined ? Icons.cancel : Icons.pending, color: isApproved ? Colors.green : isDeclined ? Colors.red : Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Status: ${req['status']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isApproved ? Colors.green : isDeclined ? Colors.red : Colors.orange)),
                                ],
                              ),
                            ],
                            if (req['admin_reply'] != null && req['admin_reply'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: Text('Admin: ${req['admin_reply']}', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- MESSAGE INPUT ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isBotTyping && !_isOrderCancelled, 
                    decoration: InputDecoration(
                      hintText: _isOrderCancelled 
                          ? 'Order Cancelled'
                          : (_isBotTyping ? 'Please wait...' : 'Type your change request...'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: (_isBotTyping || _isOrderCancelled) ? Colors.grey : Colors.redAccent,
                  radius: 24,
                  child: IconButton(
                    icon: _isSending && !_isBotTyping
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: (_isSending || _isBotTyping || _isOrderCancelled) ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}