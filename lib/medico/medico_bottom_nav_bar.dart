import 'package:flutter/material.dart';

class MedicoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onProfileTap;

  const MedicoBottomNavBar({
    super.key,
    required this.currentIndex,
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
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                route: '/medico',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Agenda',
                route: '/medico/agendamentos',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.health_and_safety_outlined,
                activeIcon: Icons.health_and_safety,
                label: 'Dicas',
                route: '/medico/dicas',
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
    final primaryColor = const Color(0xFF3FA9C6);

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
    final isSelected = currentIndex == 3;
    final primaryColor = const Color(0xFF3FA9C6);

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
              Icons.person_outline,
              color: isSelected ? primaryColor : Colors.grey[500],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              'Perfil',
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
