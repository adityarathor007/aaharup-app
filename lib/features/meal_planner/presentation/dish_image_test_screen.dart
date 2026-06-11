import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DishImageTestScreen extends StatefulWidget {
  const DishImageTestScreen({super.key});

  @override
  State<DishImageTestScreen> createState() => _DishImageTestScreenState();
}

class _DishImageTestScreenState extends State<DishImageTestScreen> {
  // 🚨 PASTE YOUR TESTING URL STRING DIRECTLY IN THIS VARIABLE:
  final String _testImageUrl = 'http://www.archanaskitchen.com/_next/image?url=https%3A%2F%2Fstorage.googleapis.com%2Fak_strapi_cms_gcp%2Fimages%2Frecipes%2Findian%2Fmain-course%2Findian-rice-recipes%2Fvariety-rice-mixed-rice-flavoured-rice-recipes%2FMint_Khara_Pongal_Recipe_fc34062c3e.jpg&w=1920&q=90';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Crisp off-white home canvas
      appBar: AppBar(
        title: const Text(
          'Image Pipeline Sandbox',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------------------------------------------------------------
              // CARD CONTAINER FRAME
              // ---------------------------------------------------------------
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    24,
                  ), // Prevents edges leaking
                  child: CachedNetworkImage(
                    imageUrl: _testImageUrl,
                    fit: BoxFit
                        .cover, // Forces image to scale flush across card geometry
                    // 1. Loader visual state configuration
                    placeholder: (context, url) => Container(
                        color: const Color(
                        0xFFF1F5F9,
                        ), // Light slate backdrop tint
                        child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(
                            0xFF0D9488,
                            ), // Core fresh teal accent parameter
                            strokeWidth: 2.5,
                        ),
                        ),
                    ),

                    // 2. Fallback execution if the URL breaks, 404s, or drops offline
                    errorWidget: (context, url, error) => Container(
                        color: const Color(
                        0xFFFEF2F2,
                        ), // Muted red alert backdrop tint
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(
                            Icons.broken_image_rounded,
                            color: Colors.red.shade300,
                            size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                                'Failed to resolve network image link',
                                style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                ),
                            ),
                        ],
                        ),
                    ),
                    ),
                ),
            ),

            const SizedBox(height: 24),

              // Helper metadata card instructions
              Text(
                'Direct URL Integration Tester',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'If this loads, your CSV url structures will sync perfectly with your dishes details layout components natively!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    height: 1.4,
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
