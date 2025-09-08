import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/car_service_optimized.dart';
import '../widgets/car_card.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  bool _isRefreshing = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    // Initial availability check on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarServiceOptimized>(context, listen: false).updateCarAvailabilityNow();
      setState(() {
        _isInitialLoading = false;
      });
    });
  }

  Future<void> _refreshAvailability() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Add a small delay to show the loading indicator
      await Future.delayed(const Duration(milliseconds: 500));

      Provider.of<CarServiceOptimized>(context, listen: false).updateCarAvailabilityNow();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Availability refreshed'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh availability: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carService = Provider.of<CarServiceOptimized>(context, listen: true);
    final allCars = carService.getAllCars();
    final availableCars = allCars.where((car) => car.available).toList();
    final bookedCars = allCars.where((car) => !car.available).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Car Availability'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _refreshAvailability,
                  tooltip: 'Refresh Availability',
                ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Availability Summary Card
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Consumer<CarServiceOptimized>(
                        builder: (context, carService, child) {
                          final lastUpdate = carService.getLastUpdateTime();
                          final timeSinceUpdate = DateTime.now().difference(lastUpdate);

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 300;
                              return Column(
                                children: [
                                  isSmallScreen
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.update, size: 20, color: Colors.blue),
                                            const SizedBox(height: 8),
                                            Text(
                                              carService.getAvailabilitySummary(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.update, size: 20, color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                carService.getAvailabilitySummary(),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 8),
                                  Text(
                                    timeSinceUpdate.inSeconds < 60
                                        ? 'Updated ${timeSinceUpdate.inSeconds} seconds ago'
                                        : timeSinceUpdate.inMinutes < 60
                                            ? 'Updated ${timeSinceUpdate.inMinutes} minutes ago'
                                            : timeSinceUpdate.inHours < 24
                                                ? 'Updated ${timeSinceUpdate.inHours} hours ago'
                                                : 'Updated ${timeSinceUpdate.inDays} days ago',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10 : 12,
                                      color: timeSinceUpdate.inSeconds < 30
                                          ? Colors.green
                                          : timeSinceUpdate.inMinutes < 5
                                              ? Colors.orange
                                              : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Category-wise availability
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 400;
                        return isSmallScreen
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildCategoryAvailability('SUV', carService),
                                      _buildCategoryAvailability('Sedan', carService),
                                      _buildCategoryAvailability('Sports', carService),
                                      _buildCategoryAvailability('Luxury', carService),
                                      _buildCategoryAvailability('Supercar', carService),
                                    ],
                                  ),
                                ],
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildCategoryAvailability('SUV', carService),
                                    _buildCategoryAvailability('Sedan', carService),
                                    _buildCategoryAvailability('Sports', carService),
                                    _buildCategoryAvailability('Luxury', carService),
                                    _buildCategoryAvailability('Supercar', carService),
                                  ],
                                ),
                              );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tabbed view for Available vs Booked cars
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(
                              text: 'Available Cars',
                              icon: Icon(Icons.check_circle, color: Colors.green),
                            ),
                            Tab(
                              text: 'Currently Booked',
                              icon: Icon(Icons.schedule, color: Colors.orange),
                            ),
                          ],
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final screenHeight = MediaQuery.of(context).size.height;
                            final screenWidth = MediaQuery.of(context).size.width;
                            final isSmallScreen = screenWidth < 400;
                            final crossAxisCount = isSmallScreen ? 1 : 2;
                            final tabViewHeight = screenHeight * (isSmallScreen ? 0.4 : 0.5);

                            return SizedBox(
                              height: tabViewHeight,
                              child: TabBarView(
                                children: [
                                  // Available Cars Tab
                                  availableCars.isEmpty
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.car_rental, size: 64, color: Colors.grey),
                                              SizedBox(height: 16),
                                              Text(
                                                'All cars are currently booked',
                                                style: TextStyle(fontSize: 16, color: Colors.grey),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )
                                      : GridView.builder(
                                          padding: const EdgeInsets.all(16),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: isSmallScreen ? 0.9 : 0.75,
                                          ),
                                          itemCount: availableCars.length,
                                          itemBuilder: (context, index) {
                                            return CarCard(car: availableCars[index]);
                                          },
                                        ),

                                  // Booked Cars Tab
                                  bookedCars.isEmpty
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle, size: 64, color: Colors.green),
                                              SizedBox(height: 16),
                                              Text(
                                                'No cars are currently booked',
                                                style: TextStyle(fontSize: 16, color: Colors.green),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )
                                      : GridView.builder(
                                          padding: const EdgeInsets.all(16),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: isSmallScreen ? 0.9 : 0.75,
                                          ),
                                          itemCount: bookedCars.length,
                                          itemBuilder: (context, index) {
                                            return CarCard(car: bookedCars[index]);
                                          },
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryAvailability(String category, CarServiceOptimized carService) {
    final availableCount = carService.getAvailableCarsCountByCategory(category);
    final totalCount = carService.getAllCars().where((car) => car.category == category).length;

    if (totalCount == 0) return const SizedBox.shrink();

    return Chip(
      backgroundColor: availableCount > 0 ? Colors.green[100] : Colors.red[100],
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            availableCount > 0 ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: availableCount > 0 ? Colors.green[800] : Colors.red[800],
          ),
          const SizedBox(width: 4),
          Text(
            '$category: $availableCount/$totalCount',
            style: TextStyle(
              color: availableCount > 0 ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
