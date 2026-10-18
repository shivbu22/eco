class DatabaseService {
  // ---------- User Stats ----------
  Stream<Map<String, dynamic>> userStats(String uid) {
    return Stream.periodic(const Duration(seconds: 5), (_) => {
      'walletBalance': 540.0,
      'carbonSaved': 12.5,
      'points': 1200,
      'bookingsCompleted': 8,
      'treesEquivalent': 3,
    });
  }

  // ---------- Service Catalog ----------
  static const List<Map<String, dynamic>> _services = [
    {
      'id': '1',
      'title': 'Eco Home\nCleaning',
      'emoji': '🧹',
      'image': 'assets/images/eco_cleaning.png',
      'price': 499.0,
      'rating': 4.8,
      'duration': '10 min',
      'category': 'cleaning',
      'tags': ['biodegradable', 'zero-waste'],
      'features': {
        'ecoScore': 92,
        'ecoImpact': ['Saves ~2.4kg CO₂', 'Biodegradable products', 'Zero plastic waste'],
        'requiresImage': false,
        'suggestion': 'Clear the floor space before arrival for the fastest service.',
        'options': [
          {'label': '1BHK', 'price': 399.0},
          {'label': '2BHK', 'price': 499.0},
          {'label': '3BHK', 'price': 699.0},
          {'label': 'Villa', 'price': 999.0},
        ],
      },
    },
    {
      'id': '2',
      'title': 'Garbage\nCollection',
      'emoji': '♻️',
      'image': 'assets/images/garbage_collection.png',
      'price': 149.0,
      'rating': 4.7,
      'duration': '10 min',
      'category': 'waste',
      'tags': ['doorstep', 'sorted'],
      'features': {
        'ecoScore': 85,
        'ecoImpact': ['Proper landfill diversion', 'Methane reduction', 'Recovers recyclables'],
        'requiresImage': true,
        'suggestion': 'Separate wet and dry waste, and bag it securely if possible.',
        'options': [
          {'label': '1 Day', 'price': 29.0},
          {'label': '1 Week', 'price': 149.0},
          {'label': '1 Month', 'price': 499.0},
        ],
      },
    },
    {
      'id': '3',
      'title': 'Recycling\nPickup',
      'emoji': '🗃️',
      'image': 'assets/images/recycling_pickup.png',
      'price': 99.0,
      'rating': 4.9,
      'duration': '10 min',
      'category': 'recycling',
      'tags': ['e-waste', 'paper', 'plastic'],
      'features': {
        'ecoScore': 95,
        'ecoImpact': ['Prevents toxic e-waste', 'Saves resource extraction', '100% material recovery'],
        'requiresImage': true,
        'suggestion': 'Upload a quick photo of your recyclables so our workers can prepare correct bins.',
        'options': [
          {'label': 'Electronics', 'price': 99.0},
          {'label': 'Mixed Paper/Cardboard', 'price': 49.0},
          {'label': 'Plastics & Glass', 'price': 49.0},
        ],
      },
    },
    {
      'id': '4',
      'title': 'Bulk Waste\nPickup',
      'emoji': '🚛',
      'image': 'assets/images/bulk_waste.png',
      'price': 899.0,
      'rating': 4.6,
      'duration': '20 min',
      'category': 'waste',
      'tags': ['heavy', 'same-day'],
      'features': {
        'ecoScore': 88,
        'ecoImpact': ['Upcycles old furniture', 'Responsible e-waste dumping', 'Avoids illegal tipping'],
        'requiresImage': true,
        'suggestion': 'Ensure the pathway is clear for our movers. Uploading photos is required for bulky items.',
        'options': [
          {'label': 'Furniture', 'price': 499.0},
          {'label': 'Appliances', 'price': 699.0},
          {'label': 'Half Truck Load', 'price': 899.0},
          {'label': 'Full Truck Load', 'price': 1499.0},
        ],
      },
    },
    {
      'id': '5',
      'title': 'Deep Clean\nPro',
      'emoji': '✨',
      'image': 'assets/images/deep_clean.png',
      'price': 1299.0,
      'rating': 4.9,
      'duration': '3 hrs',
      'category': 'cleaning',
      'tags': ['eco-certified', 'steam'],
      'features': {
        'ecoScore': 82,
        'ecoImpact': ['Low water usage design', 'Toxic-free chemicals', 'Energy efficient equipment'],
        'requiresImage': false,
        'suggestion': 'Keep pets securely away during the deep steam cleaning process.',
        'options': [
          {'label': '1BHK', 'price': 999.0},
          {'label': '2BHK', 'price': 1299.0},
          {'label': '3BHK', 'price': 1699.0},
          {'label': 'Villa', 'price': 2499.0},
        ],
      },
    },
    {
      'id': '6',
      'title': 'Garden\nCare',
      'emoji': '🌱',
      'image': 'assets/images/garden_care.png',
      'price': 399.0,
      'rating': 4.7,
      'duration': '45 min',
      'category': 'garden',
      'tags': ['organic', 'pruning'],
      'features': {
        'ecoScore': 94,
        'ecoImpact': ['Organic compost', 'Promotes local flora', 'Water retention techniques'],
        'requiresImage': true,
        'suggestion': 'A photo of your garden helps us bring the exact organic compost needed.',
        'options': [
          {'label': 'Balcony', 'price': 199.0},
          {'label': 'Small Yard', 'price': 399.0},
          {'label': 'Large Yard', 'price': 799.0},
        ],
      },
    },
    {
      'id': '7',
      'title': 'Homeguard\nService',
      'emoji': '🔒',
      'image': 'assets/images/homeguard.png',
      'price': 299.0,
      'rating': 4.5,
      'duration': '10 min',
      'category': 'security',
      'tags': ['verified', 'trusted'],
      'features': {
        'ecoScore': 75,
        'ecoImpact': ['Local neighborhood focus', 'Reduced transit emissions', 'Digital reports only'],
        'requiresImage': false,
        'suggestion': 'No extra steps needed. Our verified guard will check in via the app.',
        'options': [
          {'label': '1 Day', 'price': 299.0},
          {'label': '1 Week', 'price': 1499.0},
          {'label': '1 Month', 'price': 4999.0},
        ],
      },
    },
    {
      'id': '8',
      'title': 'Sweeper\nService',
      'emoji': '🪣',
      'image': 'assets/images/sweeper.png',
      'price': 199.0,
      'rating': 4.6,
      'duration': '10 min',
      'category': 'cleaning',
      'tags': ['daily', 'morning'],
      'features': {
        'ecoScore': 80,
        'ecoImpact': ['Micro-fiber sweeps', 'Water-conscious mopping', 'Clean neighborhood'],
        'requiresImage': false,
        'suggestion': 'Leave your broom/water access visible if possible.',
        'options': [
          {'label': 'Daily', 'price': 199.0},
          {'label': 'Weekly', 'price': 999.0},
          {'label': 'Monthly', 'price': 2999.0},
        ],
      },
    },
    {
      'id': '9',
      'title': 'Solar Panel\nCleaning',
      'emoji': '☀️',
      'image': 'assets/images/solar_cleaning.png',
      'price': 699.0,
      'rating': 4.9,
      'duration': '1 hr',
      'category': 'maintenance',
      'tags': ['renewable', 'efficiency'],
      'features': {
        'ecoScore': 98,
        'ecoImpact': ['Maintains 100% solar efficiency', 'Chemical-free washing', 'Increases clean energy yield'],
        'requiresImage': true,
        'suggestion': 'Uploading a photo of the panel setup on your roof is highly recommended for safety assessments.',
        'options': [
          {'label': '1-5 Panels', 'price': 499.0},
          {'label': '6-10 Panels', 'price': 699.0},
          {'label': '11-20 Panels', 'price': 1199.0},
        ],
      },
    },
    {
      'id': '10',
      'title': 'Water Tank\nClean',
      'emoji': '💧',
      'image': 'assets/images/water_tank.png',
      'price': 499.0,
      'rating': 4.8,
      'duration': '45 min',
      'category': 'cleaning',
      'tags': ['hygiene', 'safety'],
      'features': {
        'ecoScore': 84,
        'ecoImpact': ['Prevents water contamination', 'Non-toxic scrubbing', 'Water-saving flush'],
        'requiresImage': false,
        'suggestion': 'Ensure the main water valve is accessible before our team arrives.',
        'options': [
          {'label': 'Up to 500L', 'price': 499.0},
          {'label': '500-1000L', 'price': 799.0},
          {'label': '1000L+', 'price': 1299.0},
        ],
      },
    },
    {
      'id': '11',
      'title': 'Air Purifier\nMaint.',
      'emoji': '🌬️',
      'image': 'assets/images/air_purifier.png',
      'price': 249.0,
      'rating': 4.7,
      'duration': '30 min',
      'category': 'maintenance',
      'tags': ['health', 'filters'],
      'features': {
        'ecoScore': 90,
        'ecoImpact': ['Recycles HEPA filters', 'Optimizes airflow', 'Extends device life'],
        'requiresImage': true,
        'suggestion': 'Upload a snapshot of your filter indicator so we know what replacements to bring.',
        'options': [
          {'label': 'Filter Cleaning', 'price': 249.0},
          {'label': 'Filter Replacement', 'price': 899.0},
        ],
      },
    },
    {
      'id': '12',
      'title': 'Smart Compost\nSetup',
      'emoji': '🪴',
      'image': 'assets/images/smart_compost.png',
      'price': 899.0,
      'rating': 4.9,
      'duration': '2 hrs',
      'category': 'garden',
      'tags': ['zero-waste', 'organic'],
      'features': {
        'ecoScore': 99,
        'ecoImpact': ['Creates self-sustaining soil', 'Massive methane reduction', 'Zero food waste to landfill'],
        'requiresImage': false,
        'suggestion': 'Decide on a shaded area in your home/balcony to place the compost bin.',
        'options': [
          {'label': 'Setup Only', 'price': 499.0},
          {'label': 'Setup + Bin Included', 'price': 899.0},
        ],
      },
    },
  ];

  Stream<List<Map<String, dynamic>>> getServiceCatalog() {
    return Stream.value(List<Map<String, dynamic>>.from(_services));
  }

  List<Map<String, dynamic>> getServiceCatalogSync() => List<Map<String, dynamic>>.from(_services);

  // ---------- Top Workers ----------
  static const List<Map<String, dynamic>> _workers = [
    {
      'id': 'w1',
      'name': 'Arjun M.',
      'rating': 4.9,
      'jobs': 142,
      'speciality': 'Eco Cleaning',
      'avatar': '👨‍🔧',
      'verified': true,
    },
    {
      'id': 'w2',
      'name': 'Priya S.',
      'rating': 4.8,
      'jobs': 115,
      'speciality': 'Recycling Expert',
      'avatar': '👩‍💼',
      'verified': true,
    },
    {
      'id': 'w3',
      'name': 'Rahul K.',
      'rating': 4.8,
      'jobs': 98,
      'speciality': 'Deep Clean Pro',
      'avatar': '👨‍💼',
      'verified': true,
    },
    {
      'id': 'w4',
      'name': 'Sneha T.',
      'rating': 4.7,
      'jobs': 87,
      'speciality': 'Garden Care',
      'avatar': '👩‍🌾',
      'verified': false,
    },
  ];

  List<Map<String, dynamic>> getTopWorkers() => List<Map<String, dynamic>>.from(_workers);

  // ---------- Bookings ----------
  static final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'b1',
      'service': 'Eco Home Cleaning',
      'emoji': '🧹',
      'status': 'completed',
      'date': '2 Apr 2026',
      'time': '10:30 AM',
      'worker': 'Arjun M.',
      'price': 499.0,
      'carbonSaved': 2.4,
    },
    {
      'id': 'b2',
      'service': 'Garbage Collection',
      'emoji': '♻️',
      'status': 'completed',
      'date': '28 Mar 2026',
      'time': '08:00 AM',
      'worker': 'Priya S.',
      'price': 149.0,
      'carbonSaved': 0.8,
    },
    {
      'id': 'b3',
      'service': 'Deep Clean Pro',
      'emoji': '✨',
      'status': 'active',
      'date': 'Today',
      'time': '03:00 PM',
      'worker': 'Rahul K.',
      'price': 1299.0,
      'carbonSaved': 5.2,
    },
  ];

  List<Map<String, dynamic>> getBookings(String uid) => List<Map<String, dynamic>>.from(_bookings);

  Future<void> saveBooking(String uid, Map<String, dynamic> bookingData) async {
    await Future.delayed(const Duration(seconds: 1));
    _bookings.add({
      'id': 'b${_bookings.length + 1}',
      ...bookingData,
      'status': 'active',
      'carbonSaved': 2.0,
    });
  }

  // ---------- Notifications ----------
  static const List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n1',
      'type': 'update',
      'icon': '🔔',
      'title': 'Your pro is on the way!',
      'body': 'Arjun M. is 5 mins away. Get ready.',
      'time': '2 min ago',
      'unread': true,
    },
    {
      'id': 'n2',
      'type': 'achievement',
      'icon': '🏆',
      'title': 'Eco Hero Unlocked!',
      'body': 'You have saved 10kg of CO₂ this month. Amazing!',
      'time': '1 hr ago',
      'unread': true,
    },
    {
      'id': 'n3',
      'type': 'offer',
      'icon': '⚡',
      'title': 'Flash Offer: 30% OFF Deep Clean',
      'body': 'Today only. Use code ECO30 at checkout.',
      'time': '3 hr ago',
      'unread': false,
    },
    {
      'id': 'n4',
      'type': 'update',
      'icon': '✅',
      'title': 'Booking Completed',
      'body': 'Your Eco Home Cleaning was completed. Rate your experience.',
      'time': '2 Apr',
      'unread': false,
    },
    {
      'id': 'n5',
      'type': 'achievement',
      'icon': '🌿',
      'title': 'Green Streak: 5 Days!',
      'body': 'You have booked eco-friendly services 5 days in a row.',
      'time': '1 Apr',
      'unread': false,
    },
  ];

  List<Map<String, dynamic>> getNotifications(String uid) =>
      List<Map<String, dynamic>>.from(_notifications);

  // ---------- Leaderboard ----------
  static const List<Map<String, dynamic>> _leaderboard = [
    {'rank': 1, 'name': 'Kavya R.', 'avatar': '👩‍💻', 'co2Saved': 48.2, 'points': 4820, 'isMe': false},
    {'rank': 2, 'name': 'Amit J.', 'avatar': '👨‍💼', 'co2Saved': 41.0, 'points': 4100, 'isMe': false},
    {'rank': 3, 'name': 'You', 'avatar': '🧑', 'co2Saved': 12.5, 'points': 1200, 'isMe': true},
    {'rank': 4, 'name': 'Sita K.', 'avatar': '👩‍🌾', 'co2Saved': 10.2, 'points': 1020, 'isMe': false},
    {'rank': 5, 'name': 'Rohan P.', 'avatar': '👨‍🔧', 'co2Saved': 8.9, 'points': 890, 'isMe': false},
    {'rank': 6, 'name': 'Meena B.', 'avatar': '👩‍💼', 'co2Saved': 7.3, 'points': 730, 'isMe': false},
    {'rank': 7, 'name': 'Dev S.', 'avatar': '👨‍🎓', 'co2Saved': 5.1, 'points': 510, 'isMe': false},
  ];

  List<Map<String, dynamic>> getLeaderboard(String uid) =>
      List<Map<String, dynamic>>.from(_leaderboard);

  // ---------- Profile ----------
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ---------- Sustainability Impact ----------
  Map<String, dynamic> getImpactStats() => {
    'milestone': 'Eco Warrior',
    'level': 2,
    'nextLevel': 'Sustainability Titan',
    'currentXP': 1240,
    'requiredXP': 2000,
    'topPercent': 8,
    'co2Prevented': 42.8,
    'co2Change': '+13% VS LY',
    'treesPlanted': 14,
    'wasteRedirected': 124,
    'wasteGoal': 150,
    'weeklyActivity': [12, 18, 15, 32, 28, 22, 10],
    'recentEvents': [
      {'icon': '🚚', 'title': 'EV Courier Delivery', 'subtitle': 'Reduced transport emissions by 1.2kg CO2', 'xp': 45, 'time': '2H AGO'},
      {'icon': '⚡', 'title': 'Off-Peak Energy Usage', 'subtitle': 'Smart home efficiency optimization', 'xp': 20, 'time': 'YESTERDAY'},
    ],
    'rewards': [
      {'title': 'CARBON CREDIT V04', 'issuer': 'Global Forest Registry', 'vouchers': 4},
    ],
    'project': {'name': 'Amazon Reforestation', 'label': 'OZOMIN PROJECT'},
  };

  // ---------- Scheduled Services ----------
  Map<String, dynamic> getScheduledServices() => {
    'activeServices': [
      {'id': 'ss1', 'icon': '🗑️', 'title': 'Weekly Garbage Collection', 'frequency': 'Every Tuesday', 'nextDate': 'Oct 24, 2023', 'autoPay': true, 'status': 'Active'},
      {'id': 'ss2', 'icon': '🧹', 'title': 'Bi-weekly Home Cleaning', 'frequency': 'Every 2nd Friday', 'nextDate': 'Oct 27, 2023', 'autoPay': true, 'status': 'Active'},
    ],
    'nextService': {'title': 'Waste Pickup', 'time': 'Tomorrow at 08:00 AM'},
    'scheduledDates': [10, 17, 24, 28],
    'impactScore': 1240,
    'plans': [
      {'title': 'Zero-Waste Pro', 'desc': 'Full circular home auditing & waste reduction.', 'tag': 'Most Popular'},
      {'title': 'Garden Maintenance', 'desc': 'Biophilic design & smart irrigation upkeep.', 'tag': 'New Service'},
    ],
  };

  // ---------- Referral Program ----------
  Map<String, dynamic> getReferralInfo() => {
    'referralCode': 'ECO-992-X',
    'co2Potential': '1.2 Tons',
    'rewardCredits': 500,
    'steps': [
      {'step': 1, 'title': 'Broadcast Link', 'desc': 'Send your unique link to friends via any social channel.'},
      {'step': 2, 'title': 'First Action', 'desc': 'They sign up and complete their first eco-friendly task.'},
      {'step': 3, 'title': 'Mutual Reward', 'desc': 'Both accounts are instantly credited with 500 points.'},
    ],
  };

  // ---------- Eco Events ----------
  List<Map<String, dynamic>> getEcoEvents() => [
    {
      'id': 'ev1',
      'title': 'Composting 101: Kitchen Waste',
      'desc': 'Turn your scraps into black gold. Complete guide to indoor worm bins and odor-free...',
      'date': 'OCT 12 • 10:00 AM',
      'location': 'Green Hub, SE',
      'points': 120,
      'category': 'Workshops',
    },
    {
      'id': 'ev2',
      'title': 'Solar Panel DIY Installation',
      'desc': 'A hands-on workshop on mounting and wiring small-scale solar setups for home balcony use.',
      'date': 'OCT 15 • 02:00 PM',
      'location': 'Tech Lab 4',
      'points': 350,
      'category': 'Tech & DIY',
    },
    {
      'id': 'ev3',
      'title': 'Beach Clean & Plastic Sort',
      'desc': 'Our monthly river-bank cleanup. Help us remove microplastics and sort recyclables for the local center.',
      'date': 'OCT 18 • 08:00 AM',
      'location': 'Riverside Park',
      'points': 50,
      'joined': 45,
      'category': 'Cleanups',
    },
  ];

  Map<String, int> getEventCategories() => {
    'Workshops': 12,
    'Cleanups': 8,
    'Tech & DIY': 5,
  };

  // ---------- Smart Home ----------
  Map<String, dynamic> getSmartHomeData() => {
    'impactScore': 98.2,
    'co2Today': 4.2,
    'livePower': 1.24,
    'powerHistory': [0.8, 1.1, 0.9, 1.3, 1.0, 1.24, 0.7],
    'devices': [
      {
        'id': 'sh1', 'type': 'waste', 'name': 'Smart Waste Bin',
        'model': 'ECO-BIN-X1', 'status': 'ONLINE',
        'fillLevel': 74, 'autoCompact': true,
      },
      {
        'id': 'sh2', 'type': 'garden', 'name': 'Garden Hydration',
        'lastWatered': '14h ago', 'alert': 'DRY SOIL',
        'moisture': 12, 'flowRate': 0.0,
      },
    ],
    'solarGen': [20, 35, 42, 38, 50, 45, 30],
    'gridConsumption': [15, 12, 18, 10, 8, 14, 20],
    'netSavings': 124.50,
    'activeAutomations': 12,
    'pendingOptimizations': 4,
  };

  // ---------- Transaction Details ----------
  List<Map<String, dynamic>> getTransactions() => [
    {
      'id': 'TXN-8829-ECO-440219',
      'service': 'Recycling Pickup',
      'icon': '♻️',
      'amount': 450.0,
      'currency': 'EMERALD COINS',
      'status': 'Completed',
      'date': 'Oct 24, 2023 • 14:32',
      'co2Offset': -12.4,
      'location': 'Metro Recycling Hub Central',
    },
    {
      'id': 'TXN-7712-ECO-331105',
      'service': 'Eco Home Cleaning',
      'icon': '🧹',
      'amount': 320.0,
      'currency': 'EMERALD COINS',
      'status': 'Completed',
      'date': 'Oct 22, 2023 • 09:15',
      'co2Offset': -8.1,
      'location': 'Green Living Complex',
    },
  ];

  // ---------- Settings / Privacy ----------
  Map<String, dynamic> getUserSettings() => {
    'name': 'Aarav Sharma',
    'email': 'aarav.sharma@eco.com',
    'phone': '+91 98765 43210',
    'phoneVerified': true,
    'tier': 'Platinum Eco-Member',
    'twoFactorEnabled': true,
    'locationAccess': true,
    'profileVisibility': true,
    'flashOffers': true,
    'serviceUpdates': true,
    'version': '4.2.0 (Bioluminescent Build)',
  };
}
