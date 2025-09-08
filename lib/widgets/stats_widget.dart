import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact Header
          Text(
            'Why Choose Us',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Compact Stats Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompactStatItem(
                  '50+', 'Vehicles', AppTheme.primaryColor, Icons.directions_car_outlined
                ),
                const SizedBox(width: 12),
                _buildCompactStatItem(
                  '24/7', 'Support', AppTheme.successColor, Icons.support_agent_outlined
                ),
                const SizedBox(width: 12),
                _buildCompactStatItem(
                  '4.9★', 'Rating', AppTheme.accentColor, Icons.star_outline
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Compact Features Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompactFeatureItem(Icons.local_offer_outlined, 'Best Prices'),
                const SizedBox(width: 8),
                _buildCompactFeatureItem(Icons.security_outlined, 'Insured'),
                const SizedBox(width: 8),
                _buildCompactFeatureItem(Icons.clean_hands_outlined, 'Sanitized'),
                const SizedBox(width: 8),
                _buildCompactFeatureItem(Icons.phone_iphone_outlined, 'Mobile App'),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCompactStatItem(String number, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFeatureItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }


}
