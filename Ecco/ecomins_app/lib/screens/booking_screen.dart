import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/database_service.dart';
import 'booking_confirmed_screen.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic>? initialService;
  const BookingScreen({super.key, this.initialService});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  bool _isLoading = false;
  int _selectedServiceIdx = 0;
  int _selectedPackageIdx = 0;
  bool _imageUploaded = false;
  bool _notesExpanded = false;
  bool _ecoDetailsExpanded = false;
  double _swipeProgress = 0.0;
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 2));
  late TabController _tabController;
  final ScrollController _serviceScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final services = _db.getServiceCatalogSync();
    if (widget.initialService != null) {
      _selectedServiceIdx = services.indexWhere(
          (s) => s['id'] == widget.initialService!['id']);
      if (_selectedServiceIdx < 0) _selectedServiceIdx = 0;
    }
    _tabController = TabController(length: services.length, vsync: this);
    _tabController.animateTo(_selectedServiceIdx);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _handleServiceChange(_tabController.index);
      }
    });
  }

  void _handleServiceChange(int index) {
      setState(() {
         _selectedServiceIdx = index;
         _selectedPackageIdx = 0;
         _imageUploaded = false;
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _serviceScrollController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentOptions {
     final service = _db.getServiceCatalogSync()[_selectedServiceIdx];
     return List<Map<String, dynamic>>.from(service['features']['options']);
  }

  String get _selectedPackage {
     final options = _currentOptions;
     if (_selectedPackageIdx >= options.length || _selectedPackageIdx < 0) return options[0]['label'] as String;
     return options[_selectedPackageIdx]['label'] as String;
  }

  double get _packagePrice {
     final options = _currentOptions;
     if (_selectedPackageIdx >= options.length || _selectedPackageIdx < 0) return options[0]['price'] as double;
     return options[_selectedPackageIdx]['price'] as double;
  }

  double get _gst => _packagePrice * 0.18;
  double get _total => _packagePrice + _gst;

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    try {
      final uid = 'mock_user_123';
      final services = _db.getServiceCatalogSync();
      await _db.saveBooking(uid, {
        'service': services[_selectedServiceIdx]['title'],
        'package': _selectedPackage,
        'date': _selectedDate.toIso8601String(),
        'price': _total,
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => BookingConfirmedScreen(totalAmount: _total)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _db.getServiceCatalogSync();
    final selectedService = services[_selectedServiceIdx];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.onSurface),
          ),
        ),
        title: const Text(
          'Book Service',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Redesigned modern Service tab bar using chips
          Container(
            height: 60,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            child: RawScrollbar(
              controller: _serviceScrollController,
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(8),
              thumbColor: AppColors.primary.withValues(alpha: 0.5),
              crossAxisMargin: 2,
              child: ListView.builder(
                controller: _serviceScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: services.length,
                itemBuilder: (context, idx) {
                  final s = services[idx];
                final isSelected = _selectedServiceIdx == idx;

                return GestureDetector(
                  onTap: () {
                    _tabController.animateTo(idx);
                    _handleServiceChange(idx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: 12),
                    height: 50,
                    padding: const EdgeInsets.only(left: 6, right: 16, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.containsKey('image'))
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(s['image'] as String),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(s['emoji'] as String, style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Text(
                          (s['title'] as String).replaceAll('\n', ' '),
                          style: TextStyle(
                            color: isSelected ? Colors.black : AppColors.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected service card
                  _buildSelectedServiceHeader(selectedService),
                  const SizedBox(height: 24),

                  // Suggestions Board
                  if (selectedService['features']?['suggestion'] != null) ...[
                     _buildSuggestionBox(selectedService['features']['suggestion'] as String),
                     const SizedBox(height: 24),
                  ],

                  // Package selector
                  _buildSectionTitle('Choose Option'),
                  const SizedBox(height: 12),
                  _buildPackageSelector(),
                  const SizedBox(height: 24),

                  // Image Upload Section (conditionally)
                  if (selectedService['features']?['requiresImage'] == true) ...[
                     _buildSectionTitle('Site Assessment (Required)'),
                     const SizedBox(height: 12),
                     _buildImageUploadSection(),
                     const SizedBox(height: 24),
                  ],

                  // Address
                  _buildSectionTitle('Service Address'),
                  const SizedBox(height: 12),
                  _buildAddressCard(),
                  const SizedBox(height: 24),

                  // Schedule
                  _buildSectionTitle('Schedule'),
                  const SizedBox(height: 12),
                  _buildScheduleCard(),
                  const SizedBox(height: 24),

                  // Notes for Provider
                  _buildNotesSection(),
                  const SizedBox(height: 24),

                  // Eco Impact
                  _buildEcoImpactCard(selectedService),
                  const SizedBox(height: 24),

                  // Price breakdown
                  _buildSectionTitle('Price Breakdown'),
                  const SizedBox(height: 12),
                  _buildPriceBreakdown(),
                  const SizedBox(height: 32),

                  // CTA - Swipe to confirm
                  _buildSwipeConfirmButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedServiceHeader(Map<String, dynamic> service) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (service.containsKey('image'))
            Positioned.fill(
              child: Image.asset(
                service['image'] as String,
                fit: BoxFit.cover,
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    if (service.containsKey('image')) ...[
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                      const Color(0xFF0D0D0D).withValues(alpha: 0.95),
                    ] else ...[
                      const Color(0xFF1A3A1F),
                      const Color(0xFF0D1F10),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!service.containsKey('image'))
                  Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(service['emoji'] as String,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                if (service.containsKey('image'))
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(service['emoji'] as String, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          service['category']?.toString().toUpperCase() ?? 'SERVICE',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  (service['title'] as String).replaceAll('\n', ' '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB74D), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${service['rating']}  •  ${service['duration']}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (service['tags'] as List<dynamic>)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelector() {
    final options = _currentOptions;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(options.length, (idx) {
        final opt = options[idx];
        final label = opt['label'] as String;
        final price = opt['price'] as double;
        final isSelected = _selectedPackageIdx == idx;

        return GestureDetector(
          onTap: () => setState(() => _selectedPackageIdx = idx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.8)
                        : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSuggestionBox(String suggestion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE68A).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDE68A).withValues(alpha: 0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFFDE68A), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Before we arrive',
                  style: TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion,
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: () {
        // Mock image upload picking
        setState(() {
          _imageUploaded = !_imageUploaded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: _imageUploaded ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imageUploaded ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
            width: _imageUploaded ? 2 : 1,
            style: _imageUploaded ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: _imageUploaded
            ? const Column(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'Image Attached Successfully!',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to re-upload or clear',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: AppColors.onSurfaceVariant, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to Upload Photo',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Help us assess the area and bring the right tools.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '14, 2nd Cross, Koramangala',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Bengaluru, Karnataka - 560034',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Change',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null && mounted) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'As soon as possible',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoImpactCard(Map<String, dynamic> service) {
    final features = service['features'] ?? {};
    final List<String> ecoImpactList = List<String>.from(features['ecoImpact'] ?? ['Reduces carbon footprint', 'Saves water']);
    final int ecoScore = features['ecoScore'] ?? 80;

    return GestureDetector(
      onTap: () => setState(() => _ecoDetailsExpanded = !_ecoDetailsExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _ecoDetailsExpanded ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
          boxShadow: _ecoDetailsExpanded ? [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌿', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Eco Impact Score',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '$ecoScore / 100',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Container(
                                height: 6,
                                width: constraints.maxWidth,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                height: 6,
                                width: constraints.maxWidth * (ecoScore / 100),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    )
                                  ]
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _ecoDetailsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0, width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: ecoImpactList.map((impact) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            impact,
                            style: const TextStyle(color: AppColors.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              crossFadeState: _ecoDetailsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          _buildPriceRow('Service ($_selectedPackage)', _packagePrice),
          const SizedBox(height: 12),
          _buildPriceRow('GST (18%)', _gst,
              color: AppColors.onSurfaceVariant),
          Divider(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
              height: 24),
          _buildPriceRow('Total', _total,
              isBold: true, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isBold = false, Color? color}) {
    final textColor = color ?? AppColors.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? textColor : AppColors.onSurfaceVariant,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: textColor,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Notes for Provider'),
            GestureDetector(
              onTap: () => setState(() => _notesExpanded = !_notesExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _notesExpanded ? AppColors.surfaceContainerLow : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  _notesExpanded ? Icons.close_rounded : Icons.add_rounded,
                  color: _notesExpanded ? AppColors.onSurfaceVariant : AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0, width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Any special instructions? (optional)',
                hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 14),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          crossFadeState: _notesExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _buildSwipeConfirmButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxSwipe = constraints.maxWidth - 60; // 60 is the button width
        if (_isLoading) {
          return SizedBox(
            width: double.infinity,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                ),
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              // Swipe text
              Center(
                child: Text(
                  'Swipe to Confirm – ₹${_total.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: (1.0 - (_swipeProgress / maxSwipe)).clamp(0.0, 1.0)),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              // Draggable button
              Positioned(
                left: _swipeProgress,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _swipeProgress += details.delta.dx;
                      if (_swipeProgress < 0) _swipeProgress = 0;
                      if (_swipeProgress > maxSwipe) _swipeProgress = maxSwipe;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_swipeProgress >= maxSwipe * 0.9) {
                      setState(() => _swipeProgress = maxSwipe);
                      _confirmBooking();
                    } else {
                      setState(() => _swipeProgress = 0);
                    }
                  },
                  child: Container(
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
