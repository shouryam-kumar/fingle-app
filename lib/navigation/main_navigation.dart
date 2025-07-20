import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/fingle/fingle_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../core/theme/app_colors.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: appProvider.currentIndex,
            children: const [
              HomeScreen(),
              SearchScreen(),
              FingleScreen(), // This is now "Bites" (TikTok-style videos)
              ActivityScreen(), // This is now "Mingle" (dating/matchmaking)
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: appProvider.currentIndex,
              onTap: appProvider.setCurrentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textLight,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_circle_outline),
                  activeIcon: Icon(Icons.play_circle),
                  label: 'Bites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Mingle',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
