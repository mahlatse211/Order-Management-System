import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  String _selectedService = 'Logo Design';
  final _titleController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _budgetController=TextEditingController();
  //  final _deadlineController=TextEditingController();
  bool _isLoading = false;

  final List<String> _services = ['Logo Design', 'Brand Design', 'Website Design', 'Event Promotion', 'Print Design', 'Digital Design'];

  Future<void> _submitOrder() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;

      await Supabase.instance.client.from('orders').insert({
          //  'auth_id': user?.id, // Uncommented: links order to the logged-in user
        // 'customer_id': user,
        'service_name': _selectedService, // Make sure your DB column accepts text, or change this to an ID
        'description': _titleController.text.trim(),
         'budget':_budgetController.text.trim(),
         'status': 'Pending',
        //  "deadline": _deadlineController.text.trim()
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order submitted successfully!'),
         backgroundColor: Colors.green,)
         ,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Let's Place Your Order")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select a service', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedService,
            isExpanded: true,
            items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => _selectedService = val!),
          ),
          const SizedBox(height: 15),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Order Title')),
          TextField(controller: _qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
          TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Additional Notes')),
          TextField(
  controller: _budgetController,
  keyboardType: TextInputType.number, // Opens the numeric keyboard on mobile
  inputFormatters: [
     // Restricts input to numbers (0-9) only
  ],
  decoration: const InputDecoration(
    labelText: 'Enter Budget',
  ),
),
// TextField(controller: _deadlineController, maxLines: 3, decoration: const InputDecoration(labelText: 'Deadline')),
          
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(15)),
            onPressed: _isLoading ? null : _submitOrder,
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
//Keep it here for now 
// final user = Supabase.instance.client.auth.currentUser;

//       await Supabase.instance.client.from('orders').insert({
//           'customer_id': user?.id, // Uncommented: links order to the logged-in user
//         // 'customer_id': user,
//         'service_name': _selectedService, // Make sure your DB column accepts text, or change this to an ID
//         'description': _titleController.text.trim(),
//          'budget':_budgetController.text.trim(),
//          'status': 'Pending',
//       });
//For Now
//Gemini Suggestion



  //Original Idea
  // Future<void> _submitOrder() async {
//     setState(() => _isLoading = true);
//     try {
//       final user = Supabase.instance.client.auth.currentUser;
//       await Supabase.instance.client.from('orders').insert({
//         //  'user_id': user?.id,
//         'service_id': _selectedService,
//         'description': _titleController.text.trim(),
//         // 'quantity': int.parse(_qtyController.text),
//         // 'notes': _notesController.text.trim(),
//         'status': 'Pending',
//       });

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order submitted successfully!')));
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }