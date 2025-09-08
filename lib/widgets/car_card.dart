import 'package:flutter/material.dart';
import '../models/car.dart';
import '../screens/car_detail_screen.dart';
import '../theme/app_theme.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final bool showPremiumBadge;

  const CarCard({super.key, required this.car, this.showPremiumBadge = false});

  @override
  Widget build(BuildContext context) {
    final bool isPremium =
        car.category == 'Luxury' || car.category == 'Supercar';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CarDetailScreen(car: car)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Car Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusL),
                topRight: Radius.circular(AppTheme.borderRadiusL),
              ),
              child: Container(
                width: 280, // Fixed width to limit card length
                height: 180, // Increased height for better car fit with contain
                child: Stack(
                  children: [
                    // Check if image is a logo (company branding) and replace with placeholder
                    car.imagePath.contains('avis.png') ||
                            car.imagePath.contains('hertz.png') ||
                            car.imagePath.contains('tesla.jpg')
                        ? Container(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 48,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${car.brand} ${car.model}',
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Image.asset(
                            car.imagePath,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: 180, // Match container height
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        size: 48,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${car.brand} ${car.model}',
                                        style: AppTheme.bodyLarge.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    // Premium badge overlay
                    if (isPremium && showPremiumBadge)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5, // Reduced padding
                            vertical: 1, // Reduced padding
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusS,
                            ),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Car Details
            Padding(
              padding: const EdgeInsets.all(
                4,
              ), // Reduced padding for more compact layout
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Car Name
                  Text(
                    '${car.brand} ${car.model}',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontSize: 13, // Reduced font size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2), // Further reduced spacing
                  // Car Specifications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: _buildSpecItem(
                          Icons.people_outline,
                          '${car.seats}',
                          AppTheme.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: _buildSpecItem(
                          Icons.local_gas_station_outlined,
                          car.fuelType,
                          AppTheme.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: _buildSpecItem(
                          Icons.settings_outlined,
                          car.transmission,
                          AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4), // Reduced spacing
                  // Price and Availability
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${car.pricePerDay.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14, // Reduced font size
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              'per day',
                              style: AppTheme.labelSmall.copyWith(
                                color: AppTheme.textTertiary,
                                fontSize: 9, // Reduced font size
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Availability Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5, // Reduced padding
                          vertical: 1, // Reduced padding
                        ),
                        decoration: BoxDecoration(
                          color: car.available
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusS,
                          ),
                        ),
                        child: Text(
                          car.available ? 'Available' : 'Booked',
                          style: AppTheme.labelSmall.copyWith(
                            color: car.available
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 9, // Reduced font size
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
