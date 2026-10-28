import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/newOrder.dart'; 

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
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text('Our Work Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      // 2. The Wide Floating Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const NewOrderScreen()),
              );
            },
            backgroundColor: Colors.black, // Sleek black button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add),
            label: const Text(
              'Start a New Order', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ),
      ),
      
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchGallery(),
        builder: (context, snapshot) {
          // --- LOADING STATE ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- ERROR STATE ---
          if (snapshot.hasError) {
            return Center(child: Text('Error loading gallery: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          // --- EMPTY STATE ---
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No images yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  const Text('Check back later for our latest work.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final galleryItems = snapshot.data!;

          // 3. Split into two columns for the staggered Masonry look
          final leftColumn = galleryItems.where((e) => galleryItems.indexOf(e) % 2 == 0).toList();
          final rightColumn = galleryItems.where((e) => galleryItems.indexOf(e) % 2 != 0).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0), // Bottom padding for FAB
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: leftColumn.map((item) => _buildMasonryCard(item, true)).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                // Right Column
                Expanded(
                  child: Column(
                    children: rightColumn.map((item) => _buildMasonryCard(item, false)).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPER: Builds the Cool Masonry Image Card ---
  Widget _buildMasonryCard(Map<String, dynamic> item, bool isTall) {
    final imageUrl = item['image_url'];
    final title = item['title'] ?? 'Project';

    return GestureDetector(
      onTap: () {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImage(imageUrl: imageUrl, title: title),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: isTall ? 250 : 190, // Staggered heights
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
          color: Colors.grey[300], // Fallback background
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. The Image
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
                          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        );
                      },
                    )
                  : const Icon(Icons.image, size: 40, color: Colors.grey),

              // 2. Gradient Overlay for Text Readability
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- FULL SCREEN IMAGE VIEWER ---
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
          child: Image.network(
            imageUrl, 
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text('Failed to load image', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}