import 'package:flutter/material.dart';
import 'package:pcbuddy/pages/laptop_input_page.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/database_helper.dart';
import 'package:pcbuddy/models/sync_models.dart';
import 'package:pcbuddy/pages/ai_build_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- 1. Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back,",
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    Text(
                      user?.username ?? "Guest",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: _getProfileImage(user?.profilePicture),
                  onBackgroundImageError: (_, __) {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIBuildPage()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.shade400,
                      Colors.blueAccent.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AI Build Assistant",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Describe your dream PC and let AI generate the parts for you.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.auto_awesome, size: 50, color: Colors.white),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "AI Tools",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildToolCard(context, Icons.speed, Colors.purpleAccent, "FPS Estimator", () {
                   // TODO: Link to FPS Page
                }),
                
                // LINKED HERE:
                _buildToolCard(context, Icons.laptop_mac, Colors.orangeAccent, "Laptop Rater", () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const LaptopInputPage()));
                }),
                
                _buildToolCard(context, Icons.verified_user_outlined, Colors.greenAccent, "Compatibility", () {
                   // TODO: Link to Compat Page
                }),
                _buildToolCard(context, Icons.star_half, Colors.redAccent, "Rate My Build", () {
                   // TODO: Link to Rate Page
                }),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top Rated Builds",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.arrow_forward, size: 20, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 160, 
              child: FutureBuilder<List<PrebuiltItem>>(
                future: _prebuiltsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Center(
                        child: Text(
                          "Sync data to see featured builds", 
                          style: TextStyle(color: Colors.grey)
                        )
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
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  image: DecorationImage(
                                    image: NetworkImage(_formatProductImage(build.imageUrl)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      build.name, 
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 12, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(build.rating.toString(), style: const TextStyle(fontSize: 11)),
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
          ],
        ),
      ),
    );
  }

Widget _buildToolCard(BuildContext context, IconData icon, Color color, String label, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // Use the callback
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}