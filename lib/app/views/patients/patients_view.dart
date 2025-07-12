import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patients_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/patient_model.dart';

class PatientsView extends StatelessWidget {
  PatientsView({super.key});

  final PatientsController patientsController = Get.put(PatientsController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: isMobile 
          ? _buildMobileLayout(context)
          : Row(
              children: [
                // Sidebar Navigation
                _buildSidebar(context, isMobile: isMobile, isTablet: isTablet),

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
                              _buildSearchAndFilterBar(isMobile: isMobile, isTablet: isTablet),
                              SizedBox(height: isMobile ? 16 : 24),

                              // Patients Table
                              Expanded(child: _buildPatientsTable(isMobile: isMobile, isTablet: isTablet)),
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
      // Add drawer for mobile
      drawer: isMobile ? _buildMobileDrawer(context) : null,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
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
                _buildNavItem(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  isActive: false,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.calendar_today,
                  title: 'Appointments',
                  isActive: false,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.medication,
                  title: 'Medications',
                  isActive: false,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  isActive: false,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          Text(
            'Patient Management',
            style: TextStyle(
              fontSize: 24,
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
                const Icon(Icons.notifications_outlined, size: 24),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Search Icon
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patients',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                'Total: ${patientsController.allPatients.length} patients',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const Spacer(),
        // Refresh Button
        Obx(
          () => ElevatedButton.icon(
            onPressed: patientsController.isLoading
                ? null
                : () => patientsController.refreshData(),
            icon: patientsController.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (value) => patientsController.searchPatients(value),
              decoration: InputDecoration(
                hintText: 'Search patients by ID, name, diagnosis...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
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
          const SizedBox(width: 16),

          // Filter Dropdown
          Container(
            width: 250,
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
          const SizedBox(width: 16),

          // Items per page
          Container(
            width: 140,
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
        ],
      ),
    );
  }

  Widget _buildPatientsTable() {
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
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading Patients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        patientsController.errorMessage,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => patientsController.refreshData(),
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
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Patients Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filter criteria',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
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
                        _buildTableHeader('Patient ID', flex: 2),
                        _buildTableHeader('Age', flex: 2),
                        _buildTableHeader('Gender', flex: 2),
                        _buildTableHeader('Medical Info', flex: 3),
                        _buildTableHeader('Risk Level', flex: 2),
                        _buildTableHeader('Actions', flex: 2),
                      ],
                    ),
                  ),

                  // Table Rows
                  Expanded(
                    child: ListView.builder(
                      itemCount: pagination.patients.length,
                      itemBuilder: (context, index) {
                        final patient = pagination.patients[index];
                        return _buildPatientRow(patient, index);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),

          // Pagination
          _buildPagination(),
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

  Widget _buildPatientRow(PatientModel patient, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          // Patient ID
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.patientId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  patient.encounterIdDisplay,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  patient.race,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Gender',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                      ? patient.medicalSpecialty
                      : 'General',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${patient.timeInHospital} days • ${patient.numMedications} meds',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: patient.riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: patient.riskColor.withOpacity(0.3)),
                ),
                child: Text(
                  patient.riskLevel,
                  style: TextStyle(
                    fontSize: 10,
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
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.analytics, size: 16),
                    label: const Text('Predict'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // More Actions Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
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
                        Get.snackbar(
                          'Info',
                          'View patient details - Feature coming soon!',
                        );
                        break;
                      case 'edit':
                        Get.snackbar(
                          'Info',
                          'Edit patient - Feature coming soon!',
                        );
                        break;
                      case 'history':
                        Get.snackbar(
                          'Info',
                          'Patient history - Feature coming soon!',
                        );
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

  Widget _buildPagination() {
    return Obx(() {
      final pagination = patientsController.currentPagination;
      if (pagination == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
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
                ...List.generate(pagination.totalPages.clamp(0, 5), (index) {
                  final pageNumber = index + 1;
                  final isCurrentPage = pageNumber == pagination.currentPage;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => patientsController.changePage(pageNumber),
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
}
