import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_management_system/Features/auth/presentation/login/login_screen.dart';
import 'package:padel_management_system/Features/owner/auth/owner_login_screen.dart';
import 'package:padel_management_system/Features/players/courts/court_browse.dart';
import 'package:padel_management_system/Features/players/open_matches/open_matches.dart';
import 'package:padel_management_system/Features/players/chat/chat_screen.dart';
import 'package:padel_management_system/Features/players/tournaments/tournaments.dart';
import 'package:padel_management_system/Features/players/recent_reservations_widget.dart';
import 'package:padel_management_system/Features/players/court_details/court_details_screen.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/Features/auth/data/provider_auth.dart';
import 'package:padel_management_system/core/const/image_string.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

class PlayerHome extends ConsumerStatefulWidget {
  const PlayerHome({super.key});

  @override
  ConsumerState<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends ConsumerState<PlayerHome> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Placeholder screens - replace with actual screens later
  final List<Widget> _screens = [
    const PlayerHomeScreen(),
    const CourtBrowseScreen(),
    const TournamentScreen(),
    const OpenMatchesScreen(),
    const ChatListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Get current user information from auth provider
    final user = ref.watch(currentUserProvider);
    bool dark = ADeviceutils.isDarkMode(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Row(
              children: [
                Text(
                  'Padel',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: dark ? AColors.white : AColors.darkGrey,
                  ),
                ),
                const Text(
                  'it',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // End drawer (sidebar) that appears from right
      endDrawer: Drawer(
        elevation: 16.0,
        child: Column(
          children: [
            // User profile header with FutureBuilder to load user data
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('players')
                  .doc(user?.uid)
                  .get(),
              builder: (context, snapshot) {
                String displayName = 'Player';
                String email = user?.email ?? 'player@example.com';
                String? avatarUrl;

                if (snapshot.hasData && snapshot.data?.exists == true) {
                  final userData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  displayName = userData != null
                      ? '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                      : 'Player';
                  email = userData?['email'] ?? email;
                  avatarUrl = userData?['avatarImage'];
                }

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: AColors.primaryColor,
                  ),
                  accountName: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  accountEmail: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: ClipOval(
                        child: avatarUrl != null
                            ? Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, _) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AColors.primaryColor,
                                ),
                              )
                            : Image.asset(AImages.avatar1)),
                  ),
                );
              },
            ),

            // Rest of the drawer content remains the same
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('My Reservations'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.sports_tennis),
              title: const Text('My Matches'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Divider(),

            // OWNER ACCESS BUTTON
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Owner Panel'),
              onTap: () {
                Navigator.pop(context);
                _showOwnerAccessDialog(context);
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);

                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await ref.read(authStateProvider.notifier).signOut();

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: dark ? Colors.black : Colors.white,
        selectedItemColor: AColors.primaryColor,
        unselectedItemColor: dark ? AColors.white : Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Courts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Tournaments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }

  // Owner Access Dialog
  void _showOwnerAccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Owner Panel'),
        content: const Text(
            'Enter "owner" as both email and password to access the owner panel'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to owner login
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OwnerLoginScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AColors.primaryColor,
            ),
            child: const Text('Go to Owner Login'),
          ),
        ],
      ),
    );
  }
}

// New Player Home Screen with Recent Reservations
class PlayerHomeScreen extends StatelessWidget {
  const PlayerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AColors.primaryColor,
                  AColors.primaryColor.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AColors.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ready to play padel today?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to court browse
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Book a Court',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recent Reservations Widget
          const RecentReservationsWidget(),
          const SizedBox(height: 30),

          // Featured Courts Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Courts',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        // This will be handled by tab navigation
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(color: AColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Featured Courts Grid
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 10),
                    children: [
                      _buildFeaturedCourtCard(
                        context,
                        'Al Noor Club',
                        'Downtown Cairo',
                        '\$250/hour',
                        4.8,
                        12,
                        'https://via.placeholder.com/150x150?text=Al+Noor',
                      ),
                      const SizedBox(width: 12),
                      _buildFeaturedCourtCard(
                        context,
                        'Al Ahmar Club',
                        'New Cairo',
                        '\$300/hour',
                        4.9,
                        18,
                        'https://via.placeholder.com/150x150?text=Al+Ahmar',
                      ),
                      const SizedBox(width: 12),
                      _buildFeaturedCourtCard(
                        context,
                        'Athletes Club',
                        'Giza',
                        '\$200/hour',
                        4.7,
                        25,
                        'https://via.placeholder.com/150x150?text=Athletes',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Quick Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Stats',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '12',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Courts Booked',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Rating',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourtCard(
    BuildContext context,
    String name,
    String location,
    String price,
    double rating,
    int reviews,
    String image,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Create dummy court object and navigate to details screen
        final pricePerHour = double.tryParse(
                price.replaceAll('\$', '').replaceAll('/hour', '')) ??
            250.0;
        final court = PadelCourt(
          id: name.replaceAll(' ', '_').toLowerCase(),
          name: name,
          location: location,
          description:
              'Premium padel court with world-class facilities and professional service',
          pricePerHour: pricePerHour,
          photos: [
            image,
            'https://via.placeholder.com/300x200?text=$name+Gallery+1',
            'https://via.placeholder.com/300x200?text=$name+Gallery+2'
          ],
          facilities: [
            'Air Conditioning',
            'Professional Lighting',
            'Restaurant',
            'Parking',
            'Locker Rooms'
          ],
          type: CourtType.indoor,
          rating: rating,
          totalBookings: reviews * 10,
          createdAt: DateTime.now(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourtDetailsScreen(court: court),
          ),
        );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Court Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AColors.textprimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '($reviews reviews)',
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
