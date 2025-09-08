import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HeroSectionWidget extends StatelessWidget {
  const HeroSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.2,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background pattern
              Positioned(
                right: -40,
                bottom: -30,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.directions_car_filled,
                    size: 200,
                    color: const Color.fromARGB(255, 114, 45, 45),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                top: 60,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.local_offer,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 80,
                top: 100,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(Icons.speed, size: 80, color: Colors.white),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main headline
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.white, AppTheme.secondaryColor],
                        stops: [0.7, 1.0],
                      ).createShader(bounds),
                      child: Text(
                        'EXPERIENCE\nPREMIUM DRIVING',
                        style: TextStyle(
                          fontSize: constraints.maxWidth > 600 ? 32 : 24,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Luxury vehicles with exceptional service\nat competitive rates. Your journey starts here.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: constraints.maxWidth > 600 ? 14 : 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
