import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar Navigation
            _buildSidebar(context),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Header
                  _buildTopHeader(context),

                  // Main Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column - Main Dashboard
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                // Health Metrics Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildHealthMetricCard(
                                        icon: Icons.water_drop,
                                        iconColor: Colors.red,
                                        title: '150/90',
                                        subtitle: 'Blood Pressure',
                                        description:
                                            'Blood pressure may increase, and may be several times a day.',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildHealthMetricCard(
                                        icon: Icons.favorite,
                                        iconColor: Colors.red,
                                        title: '90bmp',
                                        subtitle: 'Heart Rate',
                                        description:
                                            'Pulse in the most important physiological indicator.',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildHealthMetricCard(
                                        icon: Icons.bloodtype,
                                        iconColor: Colors.blue,
                                        title: '70/90mg/dl',
                                        subtitle: 'Glucose Level',
                                        description:
                                            'The normal concentration of glucose is 80-120mg/dl.',
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Analytics Chart
                                _buildAnalyticsChart(),

                                const SizedBox(height: 24),

                                // Appointments Table
                                _buildAppointmentsTable(),
                              ],
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Right Column - Calendar & Consultations
                          SizedBox(
                            width: 350,
                            child: Column(
                              children: [
                                _buildCalendarCard(),
                                const SizedBox(height: 24),
                                _buildConsultationCards(),
                              ],
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
    );
  }

  // Sidebar Navigation
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo and Brand
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pink, Colors.red],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Medi.co',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(Icons.dashboard, 'Dashboard', true, () {}),
                _buildNavItem(
                  Icons.calendar_today,
                  'Appointment',
                  false,
                  () {},
                ),
                _buildNavItem(Icons.calendar_month, 'Calendar', false, () {}),
                _buildNavItem(
                  Icons.people,
                  'Patient',
                  false,
                  () => Get.toNamed('/patients'),
                ),
                _buildNavItem(Icons.person, 'Doctor', false, () {}),
                _buildNavItem(Icons.local_activity, 'Activity', false, () {}),
                _buildNavItem(Icons.settings, 'Settings', false, () {}),
                _buildNavItem(Icons.support, 'Support', false, () {}),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // Top Header
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search appointment, patient etc',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Theme Toggle
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode, color: Colors.grey),
          ),

          // Notifications
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.grey),
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

          // User Profile
          Obx(() {
            final user = authController.currentUserRx.value;
            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    user?.firstName != null && user!.firstName.isNotEmpty
                        ? user.firstName.substring(0, 1).toUpperCase()
                        : 'D',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName != null && user!.fullName.isNotEmpty
                          ? user.fullName
                          : 'Dr. Delowar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            );
          }),
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

  // Calendar Card
  Widget _buildCalendarCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'This month treatment calendar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    const Text('June 2020', style: TextStyle(fontSize: 14)),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Column(
      children: [
        // Week days header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days
              .map(
                (day) => SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar days
        ...List.generate(5, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - 6;
                final isValidDay = dayNumber > 0 && dayNumber <= 30;
                final isToday = dayNumber == 11;
                final hasEvent = [7, 11, 16, 23].contains(dayNumber);

                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF3B82F6)
                        : hasEvent
                        ? const Color(0xFFDCFDF7)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      isValidDay ? dayNumber.toString() : '',
                      style: TextStyle(
                        color: isToday
                            ? Colors.white
                            : hasEvent
                            ? const Color(0xFF059669)
                            : Colors.black,
                        fontWeight: isToday || hasEvent
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  // Consultation Cards
  Widget _buildConsultationCards() {
    return Column(
      children: [
        _buildConsultationCard(
          doctorName: 'Dr. Delowar DSP',
          specialty: 'Heart Surgeon',
          time: '10 AM-12 PM',
          type: 'Consultation',
          avatarColor: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildConsultationCard(
          doctorName: 'Dr. Nazmul Hasan',
          specialty: 'Psychologist',
          time: '2 AM-6 PM',
          type: 'Consultation',
          avatarColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildConsultationCard({
    required String doctorName,
    required String specialty,
    required String time,
    required String type,
    required Color avatarColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor.withOpacity(0.1),
            child: Icon(Icons.person, color: avatarColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  specialty,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.message, color: Colors.white, size: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ],
          ),
        ],
      ),
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
}
