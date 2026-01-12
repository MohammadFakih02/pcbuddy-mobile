import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/database_helper.dart';
import 'package:pcbuddy/models/sync_models.dart';
import 'package:pcbuddy/pages/ai_build_page.dart';
import 'package:pcbuddy/pages/laptop_input_page.dart';
import 'package:pcbuddy/pages/build_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PrebuiltItem>> _prebuiltsFuture;

  @override
  void initState() {
    super.initState();
    _prebuiltsFuture = _fetchPrebuilts();
  }

  Future<List<PrebuiltItem>> _fetchPrebuilts() async {
    return await DatabaseHelper.instance.getTopRatedPrebuilts();
  }

  ImageProvider _getProfileImage(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return const NetworkImage('https://placehold.co/150x150/png?text=User');
    }
    if (relativePath.startsWith('http')) {
      return NetworkImage(relativePath);
    }
    return NetworkImage('${ApiConstants.baseUrl}$relativePath');
  }

  String _formatProductImage(String? url) {
    if (url == null || url.isEmpty) return 'https://placehold.co/200x200/png?text=PC';
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('http')) return url;
    return '${ApiConstants.baseUrl}$url';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$_greeting,",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.username ?? "Guest",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _getProfileImage(user?.profilePicture),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- 2. Hero AI Builder Card ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AIBuildPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1E40AF)], // Richer Blue
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AI Build Assistant",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Describe your dream PC and let AI generate the perfect part list.",
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.auto_awesome, size: 32, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- 3. Tools Grid ---
              const Text(
                "Power Tools",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3, // Slightly wider cards
                children: [
                  _buildToolCard(
                    context, 
                    Icons.speed, 
                    Colors.purpleAccent, 
                    "FPS Estimator", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIBuildPage())),
                  ),
                  _buildToolCard(
                    context, 
                    Icons.laptop_mac, 
                    Colors.orangeAccent, 
                    "Laptop Rater", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaptopInputPage())),
                  ),
                  _buildToolCard(
                    context, 
                    Icons.verified_user_outlined, 
                    Colors.greenAccent, 
                    "Compatibility", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PCBuilderPage())),
                  ),
                  _buildToolCard(
                    context, 
                    Icons.star_half, 
                    Colors.redAccent, 
                    "Rate My Build", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PCBuilderPage())),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- 4. Top Rated Builds ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Builds",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () { /* TODO: See All */ },
                    child: Text("See All", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 180, // Taller for better visual
                child: FutureBuilder<List<PrebuiltItem>>(
                  future: _prebuiltsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("No builds synced yet", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    final builds = snapshot.data!;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: builds.length,
                      itemBuilder: (context, index) {
                        final build = builds[index];
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                            ]
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      _formatProductImage(build.imageUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_,__,___) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image)),
                                    ),
                                    // Gradient Overlay for text readability
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Details
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        build.name, 
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 12, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(build.rating.toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          const Spacer(),
                                          Text(
                                            "\$${build.price.toStringAsFixed(0)}",
                                            style: const TextStyle(fontSize: 12, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, IconData icon, Color color, String label, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}