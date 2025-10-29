import 'package:flutter/material.dart';
import '../routers/app_router.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, '📊', 'Tổng quan', AppRoutes.dashboard),
              _buildNavItem(context, 1, '➕', 'Thêm mới', AppRoutes.addUser),
              _buildNavItem(context, 2, '📋', 'Danh sách', AppRoutes.list),
              _buildNavItem(context, 3, '👤', 'Tôi', AppRoutes.profile),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(BuildContext context, int index, String icon, String label, String route) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFFF0F4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? Color(0xFF4F46E5) : Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
