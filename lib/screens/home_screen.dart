import 'package:flutter/material.dart';
import 'contact_list_screen.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isRailVisible = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Widget> _screens = [
    const ContactListScreen(),
    const FavoriteScreen(),
    const Center(child: Text('Settings')),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleRail() {
    setState(() {
      _isRailVisible = !_isRailVisible;
      if (_isRailVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe right
            if (!_isRailVisible) toggleRail();
          } else if (details.primaryVelocity! < 0) {
            // Swipe left
            if (_isRailVisible) toggleRail();
          }
        },
        child: Row(
          children: [
            SizeTransition(
              axis: Axis.horizontal,
              sizeFactor: _animation,
              child: NavigationRail(
                extended: MediaQuery.of(context).size.width >= 800,
                backgroundColor: Theme.of(context).colorScheme.primary,
                selectedIconTheme: const IconThemeData(color: Colors.white),
                unselectedIconTheme: IconThemeData(
                  color: Colors.white.withOpacity(0.5),
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                ),
                labelType: NavigationRailLabelType.selected,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.contacts),
                    selectedIcon: Icon(Icons.contacts),
                    label: Text('Contacts'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite_border),
                    selectedIcon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
              ),
            ),
            if (_isRailVisible) const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
