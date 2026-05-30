import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isLoggedIn;
  final VoidCallback onProfileTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.isLoggedIn,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Início',
                route: '/home',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.local_hospital_outlined,
                activeIcon: Icons.local_hospital,
                label: 'Clínicas',
                route: '/clinicas',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Chatbot',
                route: '/chatbot',
              ),
              _buildNavItem(
                context: context,
                index: 3,
                icon: Icons.contact_support_outlined,
                activeIcon: Icons.contact_support,
                label: 'Contato',
                route: '/contato',
              ),
              _buildProfileItem(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () {
        if (isSelected) return;
        Navigator.pushReplacementNamed(context, route);
      },
      splashColor: primaryColor.withOpacity(0.1),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryColor : Colors.grey[500],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context) {
    final isSelected = currentIndex == 4;
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onProfileTap,
      splashColor: primaryColor.withOpacity(0.1),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLoggedIn ? Icons.person : Icons.login,
              color: isSelected ? primaryColor : Colors.grey[500],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              isLoggedIn ? 'Perfil' : 'Entrar',
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
