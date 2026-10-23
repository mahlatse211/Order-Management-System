import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/newOrder.dart'; // Ensure this path is correct

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // 1. Fetch ALL items from the portfolio table
  Future<List<Map<String, dynamic>>> _fetchGallery() async {
    final response = await Supabase.instance.client
        .from('portfolio')
        .select()
        .order('created_at', ascending: false); 
        
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Work Gallery', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      
      // 2. The Wide Floating Button in the Bottom Center
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SizedBox(
          width: double.infinity, // Makes the button stretch across the bottom
          height: 55,
          child: FloatingActionButton.extended(
            onPressed: () {
              // Navigate to the New Order Page
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const NewOrderScreen()),
              );
            },
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            icon: const Icon(Icons.shopping_bag),
            label: const Text(
              'Start a New Order', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchGallery(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading gallery: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No images in the gallery yet.', style: TextStyle(color: Colors.grey)));
          }

          final galleryItems = snapshot.data!;

          return GridView.builder(
            // 3. Add padding at the bottom so the grid doesn't hide behind the floating button
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 90.0), 
            itemCount: galleryItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85, 
            ),
            itemBuilder: (context, index) {
              final item = galleryItems[index];
              final imageUrl = item['image_url'];
              final title = item['title'] ?? 'Project';

              return GestureDetector(
                onTap: () {
                  if (imageUrl != null && imageUrl.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          imageUrl: imageUrl, 
                          title: title,
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl, 
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                      
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                            ),
                          ),
                          child: Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Full screen image viewer
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImage({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}