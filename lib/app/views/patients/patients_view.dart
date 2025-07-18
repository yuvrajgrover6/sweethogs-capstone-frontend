import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patients_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/patient_model.dart';
import '../../utils/custom_snackbar.dart';

class PatientsView extends StatelessWidget {
  PatientsView({super.key});

  final PatientsController patientsController = Get.put(PatientsController());
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: (isMobile || isTablet)
            ? _buildMobileLayout(context)
            : Row(
                children: [
                  // Sidebar Navigation - only show on desktop
                  if (isDesktop)
                    _buildSidebar(
                      context,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),

                  // Main Content
                  Expanded(
                    child: Column(
                      children: [
                        // Top Header
                        _buildTopHeader(context),

                        // Main Content Area
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Page Title and Actions
                                _buildPageHeader(isMobile: isMobile),
                                SizedBox(height: isMobile ? 16 : 24),

                                // Search and Filter Bar
                                _buildSearchAndFilterBar(
                                  isMobile: isMobile,
                                  isTablet: isTablet,
                                ),
                                SizedBox(height: isMobile ? 16 : 24),

                                // Patients Table
                                Expanded(
                                  child: _buildPatientsTable(
                                    isMobile: isMobile,
                                    isTablet: isTablet,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      // Add drawer for mobile and tablet
      drawer: (isMobile || isTablet) ? _buildMobileDrawer(context) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewPatient(),
        backgroundColor: const Color(0xFF0098B9),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(isMobile ? 'Add' : 'Add Patient'),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Column(
      children: [
        // Top Header with hamburger menu
        _buildMobileTopHeader(context),

        // Main Content Area
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title and Actions
                _buildPageHeader(isMobile: isMobile),
                SizedBox(height: isMobile ? 16 : 20),

                // Search and Filter Bar
                _buildSearchAndFilterBar(
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
                SizedBox(height: isMobile ? 16 : 20),

                // Patients Table
                Expanded(
                  child: _buildPatientsTable(
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          // Hamburger menu
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Patient Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          // Notification Icon
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 20),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1E293B),
        child: Column(
          children: [
            // Logo and Title
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SweetHogs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Medical Dashboard',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      Get.offNamed('/home');
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.people,
                    title: 'Patients',
                    isActive: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildNavItem(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    isActive: false,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildNavItem(
                    icon: Icons.calendar_today,
                    title: 'Appointments',
                    isActive: false,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildNavItem(
                    icon: Icons.medication,
                    title: 'Medications',
                    isActive: false,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildNavItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    isActive: false,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // User Profile Section
            Container(
              padding: const EdgeInsets.all(12),
              child: Obx(() {
                final user = authController.currentUser;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF3B82F6),
                      child: Text(
                        user?.firstName.isNotEmpty == true
                            ? user!.firstName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => authController.logout(),
                      icon: const Icon(
                        Icons.logout,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context, {
    bool isMobile = false,
    bool isTablet = false,
  }) {
    final sidebarWidth = isTablet ? 240.0 : 280.0;

    return Container(
      width: sidebarWidth,
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          // Logo and Title
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SweetHogs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Medical Dashboard',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  isActive: false,
                  onTap: () => Get.offNamed('/home'),
                ),
                _buildNavItem(
                  icon: Icons.people,
                  title: 'Patients',
                  isActive: true,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // User Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final user = authController.currentUser;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF3B82F6),
                    child: Text(
                      user?.firstName.isNotEmpty == true
                          ? user!.firstName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => authController.logout(),
                    icon: const Icon(Icons.logout, color: Color(0xFF94A3B8)),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          Text(
            'Patient Management',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          // Notification Icon
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined, size: isMobile ? 20 : 24),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: isMobile ? 6 : 8,
                    height: isMobile ? 6 : 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 8 : 16),
          // Search Icon
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, size: isMobile ? 20 : 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader({bool isMobile = false}) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patients',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                'Total: ${patientsController.allPatients.length} patients',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const Spacer(),

        // API Buttons - only show on desktop/tablet
        if (!isMobile) ...[
          // Batch Predict Button
          Obx(
            () => ElevatedButton.icon(
              onPressed: patientsController.isAnalyzing
                  ? null
                  : () => _showBatchPredictDialog(),
              icon: patientsController.isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.batch_prediction, size: 18),
              label: const Text('Batch Predict'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[100],
                foregroundColor: Colors.purple[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Model Info Button
          Obx(
            () => ElevatedButton.icon(
              onPressed: patientsController.isAnalyzing
                  ? null
                  : () => patientsController.getModelInfo(),
              icon: patientsController.isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.info_outline, size: 18),
              label: const Text('Model Info'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Test API Button
          Obx(
            () => ElevatedButton.icon(
              onPressed: patientsController.isAnalyzing
                  ? null
                  : () => patientsController.testApiConnection(),
              icon: patientsController.isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_done, size: 18),
              label: const Text('Test API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                foregroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Refresh Button
        Obx(
          () => ElevatedButton.icon(
            onPressed: patientsController.isLoading
                ? null
                : () => patientsController.refreshData(),
            icon: patientsController.isLoading
                ? SizedBox(
                    width: isMobile ? 14 : 16,
                    height: isMobile ? 14 : 16,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh, size: isMobile ? 16 : 20),
            label: Text(isMobile ? 'Refresh' : 'Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 10 : 12,
              ),
              textStyle: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar({
    bool isMobile = false,
    bool isTablet = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) =>
                      patientsController.searchPatients(value),
                  decoration: InputDecoration(
                    hintText: 'Search patients...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Row
                Row(
                  children: [
                    // Filter Dropdown
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            value: patientsController.selectedFilter,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: InputBorder.none,
                            ),
                            items: patientsController.filterOptions
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option['value'],
                                    child: Text(
                                      option['label']!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                patientsController.applyFilter(value);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Items per page
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Obx(
                          () => DropdownButtonFormField<int>(
                            value: patientsController.itemsPerPage,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: InputBorder.none,
                            ),
                            items: [5, 10, 25, 50]
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      '$value/page',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                patientsController.changeItemsPerPage(value);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 6,
                  child: TextField(
                    onChanged: (value) =>
                        patientsController.searchPatients(value),
                    decoration: InputDecoration(
                      hintText: 'Search patients by ID, name, diagnosis...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Filter Dropdown
                Expanded(
                  flex: 2,
                  child: Container(
                    // width: isTablet ? 200 : 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        value: patientsController.selectedFilter,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        items: patientsController.filterOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option['value'],
                                child: Text(
                                  option['label']!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            patientsController.applyFilter(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Items per page
                Expanded(
                  child: Container(
                    // width: isTablet ? 120 : 145,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Obx(
                      () => DropdownButtonFormField<int>(
                        value: patientsController.itemsPerPage,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        items: [5, 10, 25, 50]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  '$value per page',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            patientsController.changeItemsPerPage(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPatientsTable({bool isMobile = false, bool isTablet = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Content
          Expanded(
            child: Obx(() {
              if (patientsController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (patientsController.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: isMobile ? 48 : 64,
                        color: Colors.red[300],
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'Error Loading Patients',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Text(
                        patientsController.errorMessage,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 12 : 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isMobile ? 16 : 24),
                      ElevatedButton(
                        onPressed: () => patientsController.refreshPatientData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final pagination = patientsController.currentPagination;
              if (pagination == null || pagination.patients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: isMobile ? 48 : 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'No Patients Available',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Text(
                        'Connect to the API server or add new patients to get started',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 12 : 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return isMobile
                  ? _buildMobilePatientsList(pagination.patients)
                  : Column(
                      children: [
                        // Table Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 24,
                            vertical: isTablet ? 12 : 16,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildTableHeader(
                                'Patient ID',
                                flex: isTablet ? 3 : 2,
                              ),
                              _buildTableHeader('Age', flex: isTablet ? 2 : 2),
                              _buildTableHeader(
                                'Gender',
                                flex: isTablet ? 2 : 2,
                              ),
                              _buildTableHeader(
                                'Medical Info',
                                flex: isTablet ? 3 : 3,
                              ),
                              _buildTableHeader(
                                'Risk Level',
                                flex: isTablet ? 2 : 2,
                              ),
                              _buildTableHeader(
                                'Actions',
                                flex: isTablet ? 2 : 2,
                              ),
                            ],
                          ),
                        ),

                        // Table Rows
                        Expanded(
                          child: ListView.builder(
                            itemCount: pagination.patients.length,
                            itemBuilder: (context, index) {
                              final patient = pagination.patients[index];
                              return _buildPatientRow(
                                patient,
                                index,
                                isTablet: isTablet,
                              );
                            },
                          ),
                        ),
                      ],
                    );
            }),
          ),

          // Pagination
          _buildPagination(isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildMobilePatientsList(List<PatientModel> patients) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return _buildMobilePatientCard(patient, index);
      },
    );
  }

  Widget _buildMobilePatientCard(PatientModel patient, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient ID and Risk Level
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.patientId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      patient.encounterIdDisplay,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: patient.riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: patient.riskColor.withOpacity(0.3)),
                ),
                child: Text(
                  patient.riskLevel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: patient.riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Demographics
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${patient.displayAge} years',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      patient.gender,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Medical Info
          Text(
            'Medical Info',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            patient.medicalSpecialty != '?'
                ? patient.medicalSpecialty ?? ""
                : 'General',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            '${patient.timeInHospital} days • ${patient.numMedications} medications',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: patientsController.isAnalyzing
                        ? null
                        : () => patientsController.predictReadmission(patient),
                    icon: patientsController.isAnalyzing
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.analytics, size: 14),
                    label: const Text('Predict'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _editPatient(patient),
                icon: const Icon(Icons.edit, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0098B9).withOpacity(0.1),
                  foregroundColor: const Color(0xFF0098B9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPatientRow(
    PatientModel patient,
    int index, {
    bool isTablet = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 24,
        vertical: isTablet ? 12 : 16,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          // Patient ID
          Expanded(
            flex: isTablet ? 3 : 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.patientId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 13 : 14,
                  ),
                ),
                Text(
                  patient.encounterIdDisplay,
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Age
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patient.displayAge} years',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 13 : 14,
                  ),
                ),
                Text(
                  patient.race != '?' ? patient.race ?? "" : 'Unknown',
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Gender
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.gender,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 13 : 14,
                  ),
                ),
                Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Medical Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.medicalSpecialty != '?'
                      ? patient.medicalSpecialty ?? ""
                      : 'General',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 13 : 14,
                  ),
                ),
                Text(
                  '${patient.timeInHospital} days • ${patient.numMedications} meds',
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Risk Level
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: isTablet ? 70 : 80,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 6 : 8,
                  vertical: isTablet ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: patient.riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: patient.riskColor.withOpacity(0.3)),
                ),
                child: Text(
                  patient.riskLevel,
                  style: TextStyle(
                    fontSize: isTablet ? 9 : 10,
                    fontWeight: FontWeight.w600,
                    color: patient.riskColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Readmission Prediction Button
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: patientsController.isAnalyzing
                        ? null
                        : () => patientsController.predictReadmission(patient),
                    icon: patientsController.isAnalyzing
                        ? SizedBox(
                            width: isTablet ? 12 : 14,
                            height: isTablet ? 12 : 14,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.analytics, size: isTablet ? 14 : 16),
                    label: const Text('Predict'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 12,
                        vertical: isTablet ? 6 : 8,
                      ),
                      minimumSize: Size(0, isTablet ? 32 : 36),
                      textStyle: TextStyle(fontSize: isTablet ? 10 : 12),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 4 : 8),

                // More Actions Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: isTablet ? 16 : 18),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 16),
                          SizedBox(width: 8),
                          Text('History'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        CustomSnackbar.comingSoon('View patient details - Feature coming soon!');
                        break;
                      case 'edit':
                        _editPatient(patient);
                        break;
                      case 'history':
                        CustomSnackbar.comingSoon('Patient history - Feature coming soon!');
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination({bool isMobile = false}) {
    return Obx(() {
      final pagination = patientsController.currentPagination;
      if (pagination == null) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: isMobile
            ? Column(
                children: [
                  // Results info
                  Text(
                    'Showing ${pagination.startIndex}-${pagination.endIndex} of ${pagination.totalItems} patients',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Pagination controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous button
                      IconButton(
                        onPressed: pagination.hasPreviousPage
                            ? () => patientsController.previousPage()
                            : null,
                        icon: const Icon(Icons.chevron_left, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: pagination.hasPreviousPage
                              ? Colors.white
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Current page indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${pagination.currentPage} / ${pagination.totalPages}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Next button
                      IconButton(
                        onPressed: pagination.hasNextPage
                            ? () => patientsController.nextPage()
                            : null,
                        icon: const Icon(Icons.chevron_right, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: pagination.hasNextPage
                              ? Colors.white
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  // Results info
                  Text(
                    'Showing ${pagination.startIndex}-${pagination.endIndex} of ${pagination.totalItems} patients',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),

                  // Pagination controls
                  Row(
                    children: [
                      // Previous button
                      IconButton(
                        onPressed: pagination.hasPreviousPage
                            ? () => patientsController.previousPage()
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: pagination.hasPreviousPage
                              ? Colors.white
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Page numbers
                      ...List.generate(pagination.totalPages.clamp(0, 5), (
                        index,
                      ) {
                        final pageNumber = index + 1;
                        final isCurrentPage =
                            pageNumber == pagination.currentPage;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: () =>
                                patientsController.changePage(pageNumber),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isCurrentPage
                                    ? Colors.blue[600]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCurrentPage
                                      ? Colors.blue[600]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  pageNumber.toString(),
                                  style: TextStyle(
                                    color: isCurrentPage
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontWeight: isCurrentPage
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(width: 8),

                      // Next button
                      IconButton(
                        onPressed: pagination.hasNextPage
                            ? () => patientsController.nextPage()
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: pagination.hasNextPage
                              ? Colors.white
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
    });
  }

  // Show batch prediction dialog
  void _showBatchPredictDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.batch_prediction,
                      color: Colors.purple[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batch Readmission Prediction',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          'Predict readmission for multiple patients',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Options
              Text(
                'Select patients for batch prediction:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              // Batch prediction options
              Column(
                children: [
                  _buildBatchOption(
                    'High Risk Patients',
                    'Predict for all patients with high risk indicators',
                    Icons.warning,
                    Colors.red,
                    () => _runBatchPrediction('high_risk'),
                  ),
                  const SizedBox(height: 12),
                  _buildBatchOption(
                    'Current Page',
                    'Predict for all patients on current page',
                    Icons.list_alt,
                    Colors.blue,
                    () => _runBatchPrediction('current_page'),
                  ),
                  const SizedBox(height: 12),
                  _buildBatchOption(
                    'Random Sample (10)',
                    'Predict for 10 random patients',
                    Icons.shuffle,
                    Colors.green,
                    () => _runBatchPrediction('random_sample'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildBatchOption(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Get.back(); // Close dialog first
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _runBatchPrediction(String type) {
    List<PatientModel> patientsToPredict = [];

    switch (type) {
      case 'high_risk':
        patientsToPredict = patientsController.allPatients
            .where((patient) => patient.isHighRisk)
            .take(20) // Limit to 20 for demo
            .toList();
        break;
      case 'current_page':
        final pagination = patientsController.currentPagination;
        if (pagination != null) {
          patientsToPredict = pagination.patients;
        }
        break;
      case 'random_sample':
        final allPatients = List<PatientModel>.from(
          patientsController.allPatients,
        );
        allPatients.shuffle();
        patientsToPredict = allPatients.take(10).toList();
        break;
    }

    if (patientsToPredict.isEmpty) {
      Get.snackbar(
        'No Patients',
        'No patients found for the selected criteria',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return;
    }

    // Run batch prediction
    patientsController.predictBatchReadmission(patientsToPredict);
  }

  // Navigate to add new patient
  void _addNewPatient() async {
    final result = await Get.toNamed('/patient-form');
    if (result == true) {
      // Refresh the patient list if a patient was added/updated
      patientsController.refreshPatientData();
    }
  }

  // Navigate to edit patient
  void _editPatient(PatientModel patient) async {
    final result = await Get.toNamed('/patient-form', arguments: patient);
    if (result == true) {
      // Refresh the patient list if a patient was updated
      patientsController.refreshPatientData();
    }
  }
}
