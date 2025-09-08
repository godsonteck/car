import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../services/car_service_optimized.dart';
import '../widgets/car_card.dart';
import '../theme/app_theme.dart';

class CarListScreen extends StatefulWidget {
  final String? initialCategory;

  const CarListScreen({super.key, this.initialCategory});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Car> _filteredCars = [];
  String _selectedCategory = 'All';
  double _maxPrice = 1000;
  bool _showFilters = false;

  final List<String> categories = AppTheme.categories;

  @override
  void initState() {
    super.initState();
    // Set initial category if provided
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterCars();
  }

  void _filterCars() {
    final carService = Provider.of<CarServiceOptimized>(context, listen: false);
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCars = carService.getAllCars().where((car) {
        bool matchesSearch =
            query.isEmpty ||
            car.brand.toLowerCase().contains(query) ||
            car.model.toLowerCase().contains(query) ||
            car.category.toLowerCase().contains(query);

        bool matchesCategory =
            _selectedCategory == 'All' || car.category == _selectedCategory;

        bool matchesPrice = car.pricePerDay <= _maxPrice;

        return matchesSearch && matchesCategory && matchesPrice;
      }).toList();
    });
  }

  void _resetFilters() {
    final carService = Provider.of<CarServiceOptimized>(context, listen: false);
    setState(() {
      _selectedCategory = 'All';
      _maxPrice = 1000;
      _searchController.clear();
      _filteredCars = carService.getAllCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final carService = Provider.of<CarServiceOptimized>(context, listen: true);
    final screenWidth = MediaQuery.of(context).size.width;

    // Always update filtered cars when carService changes
    _filteredCars = carService.getAllCars().where((car) {
      bool matchesSearch =
          _searchController.text.isEmpty ||
          car.brand.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          car.model.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          car.category.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      bool matchesCategory =
          _selectedCategory == 'All' || car.category == _selectedCategory;

      bool matchesPrice = car.pricePerDay <= _maxPrice;

      return matchesSearch && matchesCategory && matchesPrice;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'BROWSE FLEET',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 1.1,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Toggle Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Premium Search Bar with beautiful gradient
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.gradientColors,
                stops: const [0.1, 0.9],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search brand, model, or category...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.textTertiary,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterCars();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors
                      .black, // Changed from AppTheme.textPrimary to black for visibility
                ),
              ),
            ),
          ),

          // Filters Section (Collapsible)
          if (_showFilters)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Category Filter
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected
                                      ? category
                                      : 'All';
                                  _filterCars();
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppTheme.primaryColor,
                              side: BorderSide(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price Filter
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Max Price',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${_maxPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: AppTheme.primaryColor,
                      overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _maxPrice,
                      min: 30,
                      max: 1000,
                      divisions: 47,
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = value;
                          _filterCars();
                        });
                      },
                    ),
                  ),

                  // Reset Filters Button
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _resetFilters,
                    icon: Icon(
                      Icons.refresh,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    label: Text(
                      'Reset Filters',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Results count and sort options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Text(
                  '${_filteredCars.length} vehicles found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Icon(Icons.sort, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Sort',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cars List View
          Expanded(
            child: _filteredCars.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.car_rental,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cars found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or search terms',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCars.length,
                    itemBuilder: (context, index) {
                      final car = _filteredCars[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CarCard(
                          car: car,
                          showPremiumBadge:
                              car.category == 'Luxury' ||
                              car.category == 'Supercar',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
