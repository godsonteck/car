import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/car_card.dart';
import '../services/car_service_optimized.dart';
import '../screens/car_list_screen.dart';
import 'package:provider/provider.dart';

class FeaturedVehiclesWidget extends StatelessWidget {
  const FeaturedVehiclesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final carService = Provider.of<CarServiceOptimized>(context, listen: true);
    final featuredCars = carService.getFeaturedCars();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FEATURED VEHICLES',
                    style: AppTheme.displaySmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Handpicked selection of our top quality vehicles',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(26), // 0.1 * 255
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
                    border: Border.all(
                      color: AppTheme.primaryColor.withAlpha(51), // 0.2 * 255
                      width: 1.5,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withAlpha(38), // 0.15 * 255
                        AppTheme.secondaryColor.withAlpha(20), // 0.08 * 255
                      ],
                    ),
                  ),
                  child: Text(
                    '${carService.getAllCars().length} available',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Featured Vehicles Vertical List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: featuredCars.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: CarCard(
                car: featuredCars[index],
                showPremiumBadge: true,
              ),
            );
          },
        ),

        // View All Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withAlpha(26), // 0.1 * 255
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(77), // 0.3 * 255
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to full car list
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CarListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceColor,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                icon: const Icon(Icons.explore_outlined, size: 18),
                label: const Text(
                  'VIEW ALL VEHICLES',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
