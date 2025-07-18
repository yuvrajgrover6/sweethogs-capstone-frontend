import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/analytics_controller.dart';
import '../../models/analytics_models.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final AnalyticsController analyticsController = Get.put(AnalyticsController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1200;
            final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
            final isMobile = constraints.maxWidth < 768;

            return Row(
              children: [
                // Sidebar Navigation (desktop only)
                if (isDesktop) _buildSidebar(context),

                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      // Top Header
                      _buildTopHeader(context),

                      // Main Content Area
                      Expanded(
                        child: Obx(() {
                          if (analyticsController.isLoading && !analyticsController.hasData) {
                            return _buildLoadingState();
                          }
                          
                          if (!analyticsController.hasData && analyticsController.errorMessage.isNotEmpty) {
                            return _buildErrorState();
                          }

                          return _buildDashboardContent(context, isDesktop, isTablet, isMobile);
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      drawer: MediaQuery.of(context).size.width < 1200
          ? _buildSidebar(context)
          : null,
    );
  }

  // Sidebar Navigation
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
                _buildNavItem(Icons.dashboard, 'Dashboard', true, () {}),
                _buildNavItem(
                  Icons.people,
                  'Patients',
                  false,
                  () => Get.toNamed('/patients'),
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
                    onPressed: () => _showLogoutDialog(context),
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

  Widget _buildNavItem(
    IconData icon,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
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

  // Top Header
  Widget _buildTopHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final showMenuButton = isMobile || isTablet; // Show menu button for mobile and tablet

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
          // Menu button for mobile and tablet
          if (showMenuButton) ...[
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            'Dashboard',
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

  // Health Metric Card
  Widget _buildHealthMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Analytics Chart
  Widget _buildAnalyticsChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patient Visit Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Weekly',
                  style: TextStyle(
                    color: Color(0xFF0EA5E9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Sun', 0.6, false),
                _buildChartBar('Mon', 0.8, false),
                _buildChartBar('Tue', 0.7, false),
                _buildChartBar('Wed', 1.0, false),
                _buildChartBar('Thu', 0.9, false),
                _buildChartBar('Fri', 0.95, false),
                _buildChartBar('Sat', 0.75, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double height, bool isToday) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: height * 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isToday ? const Color(0xFF3B82F6) : Colors.grey[600],
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Appointments Table
  Widget _buildAppointmentsTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Online Appointment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    color: Color(0xFF0EA5E9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Table(
            children: [
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Name:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Specialist:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Date:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Time:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Status',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
              _buildAppointmentRow(
                'Alexzendra',
                'Cardiologist',
                '22Sep,2022',
                '11 AM',
                'Confirm',
              ),
              _buildAppointmentRow(
                'Faruk Mia',
                'Dentist',
                '28Sep,2022',
                '12 PM',
                'Confirm',
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildAppointmentRow(
    String name,
    String specialist,
    String date,
    String time,
    String status,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Text(
                  name.substring(0, 1),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(specialist),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(date),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(time),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading dashboard data...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard data',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            analyticsController.errorMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => analyticsController.refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Main Dashboard Content
  Widget _buildDashboardContent(BuildContext context, bool isDesktop, bool isTablet, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(),
          const SizedBox(height: 24),

          // KPI Cards Row
          _buildKPICards(isDesktop, isTablet, isMobile),
          const SizedBox(height: 24),

          // Charts Section
          if (isDesktop) 
            _buildDesktopChartsLayout()
          else if (isTablet)
            _buildTabletChartsLayout()
          else
            _buildMobileChartsLayout(),
          
          const SizedBox(height: 24),

          // Statistics Section
          _buildStatisticsSection(isDesktop, isTablet, isMobile),
        ],
      ),
    );
  }

  // Welcome Header
  Widget _buildWelcomeHeader() {
    return Obx(() {
      final user = authController.currentUser;
      final analytics = analyticsController.patientAnalytics;
      
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 32,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.firstName ?? 'Doctor'}! 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s what\'s happening with your patients today',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  if (analytics != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildQuickStat(
                          '${analytics.kpis.totalPatients}',
                          'Total Patients',
                          Icons.people,
                        ),
                        const SizedBox(width: 32),
                        _buildQuickStat(
                          '${analytics.kpis.readmissionPercentage}%',
                          'Readmission Rate',
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.dashboard,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // KPI Cards
  Widget _buildKPICards(bool isDesktop, bool isTablet, bool isMobile) {
    return Obx(() {
      final analytics = analyticsController.patientAnalytics;
      if (analytics == null) return const SizedBox.shrink();

      final cards = [
        _buildKPICard(
          title: 'Total Patients',
          value: '${analytics.kpis.totalPatients}',
          icon: Icons.people,
          color: const Color(0xFF3B82F6),
          change: '+12%',
          isPositive: true,
        ),
        _buildKPICard(
          title: 'Diabetes Patients',
          value: '${analytics.kpis.diabetesPatients}',
          subtitle: '${analytics.kpis.diabetesPercentage}%',
          icon: Icons.medical_services,
          color: const Color(0xFF10B981),
          change: '+5%',
          isPositive: true,
        ),
        _buildKPICard(
          title: 'Readmissions',
          value: '${analytics.kpis.readmittedPatients}',
          subtitle: '${analytics.kpis.readmissionPercentage}%',
          icon: Icons.refresh,
          color: const Color(0xFFEF4444),
          change: '-8%',
          isPositive: false,
        ),
        _buildKPICard(
          title: 'Avg Stay',
          value: '${analytics.kpis.avgHospitalStay.toStringAsFixed(1)}',
          subtitle: 'days',
          icon: Icons.schedule,
          color: const Color(0xFFF59E0B),
          change: '+2%',
          isPositive: true,
        ),
      ];

      if (isMobile) {
        return Column(
          children: cards.map((card) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: card,
          )).toList(),
        );
      } else if (isTablet) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 16),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 16),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      } else {
        return Row(
          children: cards.map((card) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: card,
            ),
          )).toList(),
        );
      }
    });
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    String? change,
    bool isPositive = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Desktop Charts Layout
  Widget _buildDesktopChartsLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildGenderDistributionChart(),
              const SizedBox(height: 24),
              _buildAgeDistributionChart(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildDiabetesDistributionChart(),
              const SizedBox(height: 24),
              _buildReadmissionChart(),
            ],
          ),
        ),
      ],
    );
  }

  // Tablet Charts Layout
  Widget _buildTabletChartsLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildGenderDistributionChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildDiabetesDistributionChart()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildAgeDistributionChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildReadmissionChart()),
          ],
        ),
      ],
    );
  }

  // Mobile Charts Layout
  Widget _buildMobileChartsLayout() {
    return Column(
      children: [
        _buildGenderDistributionChart(),
        const SizedBox(height: 16),
        _buildDiabetesDistributionChart(),
        const SizedBox(height: 16),
        _buildAgeDistributionChart(),
        const SizedBox(height: 16),
        _buildReadmissionChart(),
      ],
    );
  }

  // Chart Widgets
  Widget _buildGenderDistributionChart() {
    return Obx(() {
      final analytics = analyticsController.patientAnalytics;
      if (analytics == null) return const SizedBox.shrink();

      final genderData = analytics.charts.genderDistribution;
      
      return _buildChartCard(
        title: 'Gender Distribution',
        icon: Icons.people,
        child: Column(
          children: genderData.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.label == 'Male' ? const Color(0xFF3B82F6) : const Color(0xFFEC4899),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${item.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${item.percentage})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      );
    });
  }

  Widget _buildDiabetesDistributionChart() {
    return Obx(() {
      final analytics = analyticsController.patientAnalytics;
      if (analytics == null) return const SizedBox.shrink();

      final diabetesData = analytics.charts.diabetesDistribution;
      
      return _buildChartCard(
        title: 'Diabetes Medication',
        icon: Icons.medication,
        child: Column(
          children: diabetesData.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.label == 'Yes' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item.label == 'Yes' ? 'On Medication' : 'No Medication'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${item.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${item.percentage})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      );
    });
  }

  Widget _buildAgeDistributionChart() {
    return Obx(() {
      final analytics = analyticsController.patientAnalytics;
      if (analytics == null) return const SizedBox.shrink();

      final ageData = analytics.charts.ageDistribution.take(5).toList();
      
      return _buildChartCard(
        title: 'Age Distribution',
        icon: Icons.bar_chart,
        child: Column(
          children: ageData.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: item.value / (ageData.isNotEmpty ? ageData.first.value : 1),
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${item.value}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      );
    });
  }

  Widget _buildReadmissionChart() {
    return Obx(() {
      final analytics = analyticsController.patientAnalytics;
      if (analytics == null) return const SizedBox.shrink();

      final readmissionData = analytics.charts.readmissionDistribution;
      
      return _buildChartCard(
        title: 'Readmission Status',
        icon: Icons.refresh,
        child: Column(
          children: readmissionData.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getReadmissionColor(item.label),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getReadmissionLabel(item.label),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${item.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${item.percentage})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      );
    });
  }

  Color _getReadmissionColor(String label) {
    switch (label) {
      case '>30':
        return const Color(0xFFEF4444);
      case '<30':
        return const Color(0xFFF59E0B);
      case 'NO':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getReadmissionLabel(String label) {
    switch (label) {
      case '>30':
        return 'After 30 days';
      case '<30':
        return 'Within 30 days';
      case 'NO':
        return 'No readmission';
      default:
        return label;
    }
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // Statistics Section
  Widget _buildStatisticsSection(bool isDesktop, bool isTablet, bool isMobile) {
    return Obx(() {
      final analytics = analyticsController.patientAnalytics;
      if (analytics == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Key Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  onPressed: () => analyticsController.refreshData(),
                  icon: Obx(() => Icon(
                    Icons.refresh,
                    color: analyticsController.isLoading 
                        ? const Color(0xFF6B7280) 
                        : const Color(0xFF3B82F6),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isMobile)
              _buildMobileStatsList(analytics)
            else
              _buildDesktopStatsGrid(analytics, isDesktop),
          ],
        ),
      );
    });
  }

  Widget _buildMobileStatsList(PatientAnalytics analytics) {
    final stats = [
      {'label': 'Average Medications', 'value': '${analytics.kpis.avgMedications.toStringAsFixed(1)}'},
      {'label': 'Average Procedures', 'value': '${analytics.kpis.avgProcedures.toStringAsFixed(1)}'},
      {'label': 'Average Lab Procedures', 'value': '${analytics.kpis.avgLabProcedures.toStringAsFixed(1)}'},
      {'label': 'Risk Level', 'value': analyticsController.getRiskLevel()},
    ];

    return Column(
      children: stats.map((stat) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stat['label']!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              stat['value']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDesktopStatsGrid(PatientAnalytics analytics, bool isDesktop) {
    final stats = [
      {'label': 'Average Medications', 'value': '${analytics.kpis.avgMedications.toStringAsFixed(1)}', 'icon': Icons.medication},
      {'label': 'Average Procedures', 'value': '${analytics.kpis.avgProcedures.toStringAsFixed(1)}', 'icon': Icons.medical_services},
      {'label': 'Average Lab Procedures', 'value': '${analytics.kpis.avgLabProcedures.toStringAsFixed(1)}', 'icon': Icons.science},
      {'label': 'Risk Level', 'value': analyticsController.getRiskLevel(), 'icon': Icons.warning},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : 1.2,
      children: stats.map((stat) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              stat['icon'] as IconData,
              color: const Color(0xFF3B82F6),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              stat['value'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat['label'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )).toList(),
    );
  }
}
