import 'dart:math';
import 'dart:ui'; // Required for the blur effect (ImageFilter)
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Imports for packages
import 'package:hydro/regionalScreen.dart';
import 'package:hydro/stationScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'DashboardScreen.dart';
import 'alertScreen.dart';
import 'analysisScreen.dart';
import 'model/StationModel.dart';
import 'theme/appTheme.dart';


//==============================================================================
// App Entry Point
//==============================================================================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydrolytic',
      theme: buildAppTheme(),
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Replace your existing MainScreen widget with this updated version.

// MODIFIED: MainScreen now uses the reusable logout dialog.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedStationId = 'DWLR_CH_BMP_001';

  void _navigateToStationDetails(String stationId) {
    setState(() {
      _selectedStationId = stationId;
      _selectedIndex = 2;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardView(navigateToTab: _onItemTapped, navigateToStation: _navigateToStationDetails),
      RegionalAnalysisScreen(onStationTap: _navigateToStationDetails),
      StationDetailsScreen(key: ValueKey(_selectedStationId), stationId: _selectedStationId),
      const AnalysisScreen(),
      AlertsScreen(navigateToStation: _navigateToStationDetails),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.water_drop_outlined,
          color: AppColors.primary,
          size: 28,
        ),
        title: Column(
          children: [
            Text(
              'Hydrolytic',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 5,),
            Text(
              'Deep Data. Clear Insights.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.fontBody,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => showLogoutConfirmationDialog(context), // Use reusable dialog
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Regional'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Station'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AnomalyCard extends StatelessWidget {
  final Map<String, dynamic> anomaly;
  final Function(String) navigateToStation;
  const AnomalyCard({super.key, required this.anomaly, required this.navigateToStation});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (anomaly['severity']) {
      case 'critical':
        icon = Icons.error_rounded;
        color = AppColors.statusCritical;
        break;
      case 'low':
        icon = Icons.info_outline_rounded;
        color = AppColors.primary;
        break;
      default: // 'moderate'
        icon = Icons.warning_rounded;
        color = AppColors.statusModerate;
    }
    final gradient = LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)], begin: Alignment.topCenter, end: Alignment.bottomCenter);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.5), width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(gradient: gradient, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(anomaly['type'], style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color))),
            Text(anomaly['time'] ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(anomaly['location'], style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            Text('AI Insight:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(anomaly['insight'], style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: (anomaly['data'] as Map<String, String>).entries.map((entry) => Expanded(
                  child: Column(children: [
                    Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
                    Text(entry.value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => navigateToStation(anomaly['stationId']),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Investigate'),
                style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
              ),
            )
          ]),
        ),
      ]),
    );
  }
}
//==============================================================================
// REDESIGNED: Authentication Screen (Login & Signup)
//==============================================================================

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginView = true;

  void _toggleView() {
    setState(() {
      _isLoginView = !_isLoginView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Added a subtle gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo and Name
                  Icon(Icons.water_drop_outlined, color: AppColors.primary, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Hydrolytic',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 32),
                  ),
                  Text(
                    'Deep Data. Clear Insights.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 40),

                  // Card containing the form
                  Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: _isLoginView
                            ? LoginForm(key: const ValueKey('login'), onSwitchToSignup: _toggleView)
                            : SignupForm(key: const ValueKey('signup'), onSwitchToLogin: _toggleView),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Replace your existing LoginForm and SignupForm widgets with these new versions.

class LoginForm extends StatefulWidget {
  final VoidCallback onSwitchToSignup;
  const LoginForm({super.key, required this.onSwitchToSignup});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  // NEW: State variable to track password visibility
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Welcome Back', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Login to continue', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email ', prefixIcon: Icon(Icons.email_outlined)),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        // MODIFIED: Password field is now stateful
        TextField(
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            // NEW: Suffix icon to toggle password visibility
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            String email = _emailController.text.toLowerCase();
            if (email == 'policy@gov.in') {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PolicymakerDashboardScreen()));
            } else if (email == 'public@email.com') {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PublicDashboardScreen()));
            } else if (email == 'officer@gov.in') {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const FieldOfficerDashboardScreen()));
            }
            else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
            }
          },
          child: const Text('LOGIN'),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: widget.onSwitchToSignup,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium,
              children: [TextSpan(text: 'Sign Up', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))],
            ),
          ),
        ),
      ],
    );
  }
}

class SignupForm extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const SignupForm({super.key, required this.onSwitchToLogin});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  String? _selectedRole;
  final List<String> _roles = ['Policymaker', 'Researcher', 'Field Officer', 'General Public'];
  String? _selectedState;
  final List<String> _indianStates = [
    'Bihar', 'Rajasthan', 'Maharashtra', 'Uttar Pradesh', 'Karnataka', 'Tamil Nadu', 'Delhi'
  ];

  // NEW: State variables for password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Create Account', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Get started with Hydrolytic', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        const TextField(decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)), keyboardType: TextInputType.name),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: _selectedRole, decoration: const InputDecoration(labelText: 'I am a...', prefixIcon: Icon(Icons.work_outline_rounded)), items: _roles.map((String role) => DropdownMenuItem<String>(value: role, child: Text(role))).toList(), onChanged: (String? newValue) => setState(() => _selectedRole = newValue)),
        const SizedBox(height: 16),
        const TextField(decoration: InputDecoration(labelText: 'Organization / Affiliation', prefixIcon: Icon(Icons.corporate_fare_rounded)), keyboardType: TextInputType.text),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: _selectedState, decoration: const InputDecoration(labelText: 'State', prefixIcon: Icon(Icons.location_city_rounded)), items: _indianStates.map((String state) => DropdownMenuItem<String>(value: state, child: Text(state))).toList(), onChanged: (String? newValue) => setState(() => _selectedState = newValue)),
        const SizedBox(height: 16),
        const TextField(decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)), keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        const TextField(decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        // MODIFIED: Password field
        TextField(
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // NEW: Confirm Password field
        TextField(
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_selectedRole == 'Policymaker') {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PolicymakerDashboardScreen()));
            } else if (_selectedRole == 'General Public') {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PublicDashboardScreen()));
            } else if (_selectedRole == 'Field Officer') {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const FieldOfficerDashboardScreen()));
            }
            else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
            }
          },
          child: const Text('SIGN UP'),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: widget.onSwitchToLogin,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Already have an account? ", style: Theme.of(context).textTheme.bodyMedium,
              children: [TextSpan(text: 'Login', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))],
            ),
          ),
        ),
      ],
    );
  }
}
// Replace your existing PolicymakerDashboardScreen widget with this corrected version.

// Replace your existing PolicymakerDashboardScreen widget with this corrected version.

class PolicymakerDashboardScreen extends StatefulWidget {
  const PolicymakerDashboardScreen({super.key});

  @override
  State<PolicymakerDashboardScreen> createState() => _PolicymakerDashboardScreenState();
}

class _PolicymakerDashboardScreenState extends State<PolicymakerDashboardScreen> {
  String _selectedState = 'Bihar';
  final List<String> _indianStates = ['Bihar', 'Rajasthan', 'Maharashtra', 'Uttar Pradesh', 'Karnataka', 'Tamil Nadu'];
  final Random _random = Random();

  int _selectedTabIndex = 0;

  int _selectedReportType = 0;
  DateTime? _startDate;
  DateTime? _endDate;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  Map<int, Widget> _buildTabContent() {
    return {
      0: _buildOverviewTab(),
      1: _buildPolicyActionTab(),
      2: _buildRegionalIntelTab(),
      3: _buildReportsTab(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              onTabChanged: (index) {
                if (index is int) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                }
              },
              selectedIndex: _selectedTabIndex,
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              // FIX: The Padding widget now has the required 'padding' argument.
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                key: ValueKey<int>(_selectedTabIndex),
                child: _buildTabContent()[_selectedTabIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // In _PolicymakerDashboardScreenState, replace the _buildSliverAppBar method with this one.

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      leading: Icon(Icons.water_drop_outlined,color: Colors.white,),
      expandedHeight: 200.0,
      pinned: true,
      elevation: 2,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      // NEW: Added the actions property with a logout button.
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Logout',
          onPressed: () => showLogoutConfirmationDialog(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Policymaker Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_getGreeting()} Policymaker', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildStateSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- TABS & CONTENT ---

  Widget _buildOverviewTab() {
    final overallStatus = ['Stressed', 'Critical', 'Normal'][_random.nextInt(3)];
    final trendValue = (_random.nextDouble() * -1.5).toStringAsFixed(1);
    final districtData = {
      'Critical': _random.nextInt(5) + 1,
      'Stressed': _random.nextInt(8) + 1,
      'Normal': _random.nextInt(10) + 2,
    };
    String statusTooltip;
    switch (overallStatus) {
      case 'Critical': statusTooltip = 'Widespread water stress, with over 75% of wells below critical levels.'; break;
      case 'Stressed': statusTooltip = 'Over 50% of wells are below the 5-year average for this season.'; break;
      default: statusTooltip = 'Water levels are stable and within the normal seasonal range.';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Tooltip(message: statusTooltip, child: _buildMetricCard(context, title: 'Overall Status', value: overallStatus, icon: overallStatus == 'Critical' ? Icons.error : Icons.warning_amber, color: overallStatus == 'Critical' ? AppColors.statusCritical : AppColors.statusModerate)),
              Tooltip(message: 'Average change in water table depth across all stations in $_selectedState over the last 30 days.', child: _buildMetricCard(context, title: '30-Day Trend', value: '$trendValue m', icon: Icons.arrow_downward_rounded, color: AppColors.statusCritical)),
            ],
          ),
        ),
        _DashboardSection(title: 'District Summary for $_selectedState', child: _buildDistrictChart(context, districtData)),
        _DashboardSection(title: 'Top Priority Alerts', child: Column(children: [
          _buildPriorityAlert(context, 'Critical Depletion', 'Araria & Purnia Districts', AppColors.statusCritical),
          _buildPriorityAlert(context, 'Severe Recharge Failure', 'Katihar District', AppColors.statusModerate),
        ])),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPolicyActionTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _DashboardSection(title: 'AI-Powered Recommendations', child: _buildRecommendationsCard(context)),
          _DashboardSection(title: 'Key Initiatives Tracker', child: _buildInitiativesCard(context)),
        ],
      ),
    );
  }

  Widget _buildRegionalIntelTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _DashboardSection(title: 'Long-Term Groundwater Forecast', child: _buildForecastCard(context)),
          _DashboardSection(title: 'Regional Water News', child: _buildNewsFeedCard(context)),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    final reportTypes = ['Monthly Summary', 'District Analysis', 'Alert History'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _DashboardSection(title: "Generate New Report", child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("1. Select Report Type", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: List<Widget>.generate(reportTypes.length, (int index) {
                        return ChoiceChip(
                          label: Text(reportTypes[index]),
                          selected: _selectedReportType == index,
                          onSelected: (bool selected) {
                            setState(() { _selectedReportType = selected ? index : 0; });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text("2. Select Date Range", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: FilledButton.tonalIcon(onPressed: () async {
                          final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                          setState(() { _startDate = picked; });
                        }, icon: const Icon(Icons.calendar_today), label: Text(_startDate == null ? "Start Date" : DateFormat.yMd().format(_startDate!)))),
                        const SizedBox(width: 16),
                        Expanded(child: FilledButton.tonalIcon(onPressed: () async {
                          final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                          setState(() { _endDate = picked; });
                        }, icon: const Icon(Icons.calendar_today), label: Text(_endDate == null ? "End Date" : DateFormat.yMd().format(_endDate!)))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.download_rounded), label: const Text("Generate & Download"))),
                  ],
                ),
              )
          )),
          _DashboardSection(title: "Recent Reports", child: Column(
            children: [
              _buildRecentReportItem(context, 'Monthly Summary - Aug 2025', 'Generated Sep 1, 2025'),
              _buildRecentReportItem(context, 'Alert History - Q3 2025', 'Generated Aug 28, 2025'),
            ],
          )),
        ],
      ),
    );
  }

  // --- Reusable & Redesigned Widgets ---

  Widget _DashboardSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.fontTitle)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
      child: DropdownButton<String>(
        value: _selectedState,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
        dropdownColor: AppColors.fontTitle,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, fontFamily: 'Poppins'),
        onChanged: (String? newValue) {
          if (newValue != null) { setState(() { _selectedState = newValue; }); }
        },
        items: _indianStates.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.fontBody)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictChart(BuildContext context, Map<String, int> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.fontTitle,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final category = data.keys.toList()[group.x.toInt()];
                    return BarTooltipItem(
                      '$category\n',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${rod.toY.toInt()} Districts',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final titles = data.keys.toList();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 12)),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: data.entries.map((entry) {
                int index = data.keys.toList().indexOf(entry.key);
                Color barColor;
                switch (entry.key) {
                  case 'Critical': barColor = AppColors.statusCritical; break;
                  case 'Stressed': barColor = AppColors.statusModerate; break;
                  default: barColor = AppColors.statusSafe;
                }
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(toY: entry.value.toDouble(), color: barColor, width: 25, borderRadius: BorderRadius.circular(6))
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityAlert(BuildContext context, String title, String location, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Icon(Icons.error_outline_rounded, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.fontBody),
        onTap: () {},
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.primary)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRecommendationItem('High Priority', 'Mandate rainwater harvesting for new constructions in Critical districts.'),
            const Divider(height: 24),
            _buildRecommendationItem('Moderate Priority', 'Launch public awareness campaigns on efficient irrigation in Stressed districts.'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String priority, String recommendation) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(priority, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(recommendation),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitiativesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInitiativeItem(context, "Jal Jeevan Mission", 0.75, "75%"),
            const SizedBox(height: 16),
            _buildInitiativeItem(context, "Aquifer Mapping Program", 0.40, "40%"),
          ],
        ),
      ),
    );
  }

  Widget _buildInitiativeItem(BuildContext context, String title, double progress, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(status, style: const TextStyle(color: AppColors.fontBody, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 10, decoration: BoxDecoration(color: AppColors.chartGrid, borderRadius: BorderRadius.circular(10))),
            LayoutBuilder(builder: (context, constraints) {
              return Container(width: constraints.maxWidth * progress, height: 10, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)));
            })
          ],
        )
      ],
    );
  }

  // In _PolicymakerDashboardScreenState, replace the old _buildForecastCard method with this one.

  Widget _buildForecastCard(BuildContext context) {
    // MODIFIED: This card now shows a specific groundwater forecast.
    return Card(
      // Using a warning color for a negative forecast
      color: AppColors.statusModerate,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.trending_down_rounded, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              "Groundwater Forecast (Next 6 Months)",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Models predict a further 0.8m drop in the water table by the end of the dry season if current trends continue.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsFeedCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNewsItem(context, 'Farmers in Araria protest falling water levels', 'Dainik Bhaskar'),
            const Divider(),
            _buildNewsItem(context, 'Patna Municipal Corp announces water rationing plan', 'The Times of India'),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, String headline, String source) {
    return ListTile(
      leading: const Icon(Icons.article_outlined, color: AppColors.fontBody),
      title: Text(headline),
      subtitle: Text(source),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildRecentReportItem(BuildContext context, String title, String date) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.chartGrid), borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(date),
        trailing: IconButton(icon: const Icon(Icons.download_for_offline_outlined), onPressed: (){}),
      ),
    );
  }
}

// Replace the existing _SliverTabBarDelegate class with this corrected version.

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Function(dynamic) onTabChanged;
  final int selectedIndex;

  _SliverTabBarDelegate({required this.onTabChanged, required this.selectedIndex});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(bottom: BorderSide(color: AppColors.chartGrid))
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      // FIX: Wrapped the SegmentedButton in a SingleChildScrollView to make it scrollable.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text("Overview")),
            ButtonSegment(value: 1, label: Text("Policy & Action")),
            ButtonSegment(value: 2, label: Text("Regional Intel")),
            ButtonSegment(value: 3, label: Text("Reports")),
          ],
          selected: {selectedIndex},
          onSelectionChanged: (newSelection) {
            onTabChanged(newSelection.first);
          },
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}



// NEW: Reusable Logout Confirmation Dialog
Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Logout'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to logout?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
        ],
      );
    },
  );
}



// Replace your existing PublicDashboardScreen widget with this updated version.

class PublicDashboardScreen extends StatefulWidget {
  const PublicDashboardScreen({super.key});

  @override
  State<PublicDashboardScreen> createState() => _PublicDashboardScreenState();
}

class _PublicDashboardScreenState extends State<PublicDashboardScreen> with SingleTickerProviderStateMixin {
  bool _areAlertsEnabled = false;

  late AnimationController _animationController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 6));

    _topAlignmentAnimation = AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight).animate(_animationController);
    _bottomAlignmentAnimation = AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.bottomRight).animate(_animationController);

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  @override
  Widget build(BuildContext context) {
    // --- Data Scenario ---
    const double currentLevel = 14.5;
    const double lastYearLevel = 13.5;
    const double stateAverageLevel = 13.7;
    const double waterLevelPercentage = 0.4;
    const String statusText = "Low";
    const Color statusColor = AppColors.statusModerate;
    // --- End of Scenario ---

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.water_drop_outlined, color: AppColors.primary, size: 28),
        title: Column(
          children: [
            Text('Hydrolytic', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 5,),
            Text('Deep Data. Clear Insights.', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.fontBody)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => showLogoutConfirmationDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.secondary.withOpacity(0.2),
                    ],
                  ),
                ),
              );
            },
          ),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28,
                    color: AppColors.fontTitle,
                    shadows: [
                      const Shadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2)),
                    ]
                ),
              ),
              Text('Here is your local water summary for Patna.', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),

              Tooltip(
                  message: 'Current groundwater level reading for your district. Last updated: 2 hours ago.',
                  child: _buildLocalWaterLevel(context, currentLevel, waterLevelPercentage, statusText, statusColor)
              ),
              const SizedBox(height: 24),

              _buildPublicAlertsSection(context),
              const SizedBox(height: 24),

              Tooltip(
                  message: 'Compares the current water level to the same time last year to show the annual trend.',
                  child: _buildYearlyComparisonCard(context, currentLevel, lastYearLevel)
              ),
              const SizedBox(height: 24),

              // NEW: Added the Area vs. State Average card
              _buildComparisonCard(context, currentLevel, stateAverageLevel),
              const SizedBox(height: 24),

              _buildConservationTip(context),
              const SizedBox(height: 24),

              _buildAlertsOptInCard(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLocalWaterLevel(BuildContext context, double level, double percentage, String status, Color color) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Local Water Level', style: Theme.of(context).textTheme.titleLarge),
          const Text('Patna District', style: TextStyle(color: AppColors.fontBody)),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                  Text('${level}m below ground', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.fontTitle)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 70,
                height: 130,
                child: Stack(
                  children: [
                    Container(decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10))),
                    Align(alignment: Alignment.bottomCenter, child: Container(height: 130 * percentage, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)))),
                    Center(child: Text('${(percentage * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,1))]))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPublicAlertsSection(BuildContext context) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Local Water Alerts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildPublicAlertItem(context, icon: Icons.warning_amber_rounded, text: "Levels are low due to minimal rainfall.", time: '2 hours ago', color: AppColors.statusModerate),
          const Divider(color: Colors.white30),
          _buildPublicAlertItem(context, icon: Icons.info_outline_rounded, text: "A dry spell is forecasted for the next two weeks.", time: '1 day ago', color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildPublicAlertItem(BuildContext context, {required IconData icon, required String text, required String time, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.fontTitle.withOpacity(0.9))),
                Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.fontBody)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyComparisonCard(BuildContext context, double current, double lastYear) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Year vs. Last Year', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildComparisonMetric(context, "Last Year", "${lastYear}m"),
              _buildComparisonMetric(context, "This Year", "${current}m", color: AppColors.statusModerate),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: A card to compare local water level with the state average.
  Widget _buildComparisonCard(BuildContext context, double current, double stateAverage) {
    final double difference = current - stateAverage;
    final bool isBelow = difference > 0; // Remember, higher number means lower water level
    final Color statusColor = isBelow ? AppColors.statusModerate : AppColors.statusSafe;
    final String statusText = isBelow ? "Below Average" : "Above Average";

    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Area vs. State Average', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(isBelow ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: statusColor, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                '${difference.abs().toStringAsFixed(1)}m',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: statusColor),
              ),
              const Spacer(),
              Text(
                statusText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonMetric(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color ?? AppColors.fontTitle)),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.fontTitle.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildConservationTip(BuildContext context) {
    return _buildGlassContainer(
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.statusModerate.withOpacity(0.15), shape: BoxShape.circle), child: Icon(Icons.lightbulb_outline_rounded, color: AppColors.statusModerate, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conservation Tip', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.statusModerate)),
                const SizedBox(height: 4),
                Text('During dry spells, watering your garden in the early morning reduces evaporation.', style: TextStyle(color: AppColors.fontTitle.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsOptInCard(BuildContext context) {
    return _buildGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.notifications_active_outlined, size: 24, color: AppColors.primary)),
          const SizedBox(width: 16),
          Expanded(child: Text('Get Local Water Alerts', style: Theme.of(context).textTheme.titleMedium)),
          Switch.adaptive(
            activeColor: AppColors.primary,
            value: _areAlertsEnabled,
            onChanged: (bool value) {
              setState(() { _areAlertsEnabled = value; });
            },
          ),
        ],
      ),
    );
  }
}



class FieldOfficerDashboardScreen extends StatefulWidget {
  const FieldOfficerDashboardScreen({super.key});

  @override
  State<FieldOfficerDashboardScreen> createState() => _FieldOfficerDashboardScreenState();
}

class _FieldOfficerDashboardScreenState extends State<FieldOfficerDashboardScreen> {
  bool _isOffline = true;
  int _unsyncedRecords = 2;
  String _activeFilter = 'All';

  // MODIFIED: Now using all stations for a more complete map view.
  final List<Station> _assignedStations = MockDataService().getAllStations();
  late List<Station> _filteredStations;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _filteredStations = _assignedStations;
  }

  // MODIFIED: This function is now more robust and handles single-point results.
  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      List<Station> tempFiltered;
      switch (filter) {
        case 'Offline':
          tempFiltered = _assignedStations.where((s) => s.id.contains('BMP') || s.id.contains('JAI')).toList();
          break;
        case 'Critical':
          tempFiltered = _assignedStations.where((s) => s.status == 'critical').toList();
          break;
        case 'Anomalies':
          tempFiltered = _assignedStations.where((s) => s.status == 'moderate').toList();
          break;
        case 'All':
        default:
          tempFiltered = _assignedStations;
      }
      _filteredStations = tempFiltered;

      // FIX: Handle map camera update based on the number of results to prevent crashes.
      if (_filteredStations.length > 1) {
        // If more than one station, fit bounds to all of them.
        _mapController.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(_filteredStations.map((s) => s.coordinates).toList()),
          padding: const EdgeInsets.all(50),
        ));
      } else if (_filteredStations.length == 1) {
        // If only one station, move the camera directly to it.
        _mapController.move(_filteredStations.first.coordinates, 12.0); // Zoom level 12
      }
      // If no stations, do nothing to the camera.
    });
  }

  void _syncData() {
    setState(() {
      _isOffline = false;
      _unsyncedRecords = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data successfully synced!"), backgroundColor: AppColors.statusSafe),
    );
  }

  void _onStationSelectedFromSearch(Station station) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => FieldOfficerStationDetailScreen(station: station)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.water_drop_outlined, color: AppColors.primary),
        title: Text("Field Officer Portal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.sync_rounded), tooltip: 'Sync Data', onPressed: _syncData),
          IconButton(icon: const Icon(Icons.logout_rounded), tooltip: 'Logout', onPressed: () => showLogoutConfirmationDialog(context)),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildAtAGlanceSummary(context)),
          SliverToBoxAdapter(child: _buildNearbyMap(context, _filteredStations)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_activeFilter == 'All' ? "All Assigned Tasks" : "Filtered Tasks", style: Theme.of(context).textTheme.titleLarge),
                  if (_activeFilter != 'All')
                    TextButton(onPressed: () => _applyFilter('All'), child: const Text("Show All"))
                ],
              ),
            ),
          ),
          _buildTaskListView(_filteredStations),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text("Quick Actions", style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Good morning, Officer!", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28)),
          Text("Here are your priorities for today.", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildAtAGlanceSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: AppColors.card,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard(context, '3', 'Stations Offline', Icons.signal_wifi_off_rounded, AppColors.statusCritical, 'Offline'),
              _buildSummaryCard(context, '2', 'Critical Level', Icons.error_outline_rounded, AppColors.statusCritical, 'Critical'),
              _buildSummaryCard(context, '2', 'Anomalies', Icons.build_circle_outlined, AppColors.statusModerate, 'Anomalies'),
            ],
          ),
          const SizedBox(height: 12),
          Text("Last synced: Today, 01:16 AM", style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String count, String label, IconData icon, Color color, String filter) {
    bool isActive = _activeFilter == filter;
    return InkWell(
      onTap: () => _applyFilter(filter),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyMap(BuildContext context, List<Station> stations) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: LatLng(24.0, 85.0), initialZoom: 5.0), // Centered on India
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              MarkerLayer(
                markers: stations.map((station) {
                  Color markerColor;
                  switch (station.status) {
                    case 'critical': markerColor = AppColors.statusCritical; break;
                    case 'moderate': markerColor = AppColors.statusModerate; break;
                    default: markerColor = AppColors.statusSafe;
                  }
                  return Marker(
                    point: station.coordinates, width: 80, height: 80,
                    child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FieldOfficerStationDetailScreen(station: station))),
                        child: Icon(Icons.location_pin, color: markerColor, size: 40)
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'mapSearchButton',
              mini: true,
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: StationSearchDelegate(
                    allStations: _assignedStations,
                    onStationSelected: _onStationSelectedFromSearch,
                  ),
                );
              },
              child: const Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListView(List<Station> stations) {
    if (stations.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 60, color: AppColors.fontBody),
                const SizedBox(height: 16),
                Text("No stations match the filter.", style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final station = stations[index];
          return _buildTaskListItem(context, station);
        },
        childCount: stations.length,
      ),
    );
  }

  Widget _buildTaskListItem(BuildContext context, Station station) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(Icons.error_outline_rounded, color: AppColors.statusCritical, size: 32),
        title: Text("Verify Critical Alert", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(station.id),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FieldOfficerStationDetailScreen(station: station))),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildActionButton(context, icon: Icons.add_location_alt_outlined, label: "Submit Reading", onTap: () {}),
          _buildActionButton(context, icon: Icons.camera_alt_outlined, label: "Upload Photo", onTap: () {}),
          _buildActionButton(context, icon: Icons.construction_rounded, label: "Report Issue", onTap: () {}),
          _buildActionButton(context, icon: Icons.history_edu_rounded, label: "Reports Log", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsLogScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 40),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
// ==============================================================================
// REDESIGNED: FieldOfficerStationDetailScreen with Analyst-Grade Hydrograph
// ==============================================================================

class FieldOfficerStationDetailScreen extends StatelessWidget {
  final Station station;
  const FieldOfficerStationDetailScreen({super.key, required this.station});

  // Data generation logic for the chart and table - same as analyst
  List<Map<String, dynamic>> _generateStationReadings(int numberOfDays) {
    final random = Random(station.id.hashCode);
    final baseLevel = station.currentLevel;
    final List<Map<String, dynamic>> readings = [];

    for (int i = 0; i < numberOfDays; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      // Slight variation to simulate real data
      final level = baseLevel + sin(i * pi / 15 + random.nextDouble()) * 0.8 + (random.nextDouble() - 0.5) * 0.4;
      readings.add({"date": date, "level": level});
    }
    return readings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(station.id),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCoreFieldTools(context),
          const SizedBox(height: 24),
          _buildHydrographCard(context), // Analyst-grade hydrograph
        ],
      ),
    );
  }

  // --- CORE FIELD TOOLS WIDGET (Remains the same) ---
  Widget _buildCoreFieldTools(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Core Field Tools", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text("Enter Manual Reading"),
              onPressed: () => _showManualReadingDialog(context),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.construction_rounded),
              label: const Text("Report Issue"),
              onPressed: () => _showReportIssueDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGS FOR FIELD TOOLS (Remain the same) ---

  Future<void> _showManualReadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Manual Reading'),
          content: const TextField(
            decoration: InputDecoration(labelText: 'Water level (meters below ground)'),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            FilledButton(child: const Text('Submit'), onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  Future<void> _showReportIssueDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report an Issue'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select issue type(s):", style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(value: false, onChanged: (val){}, title: const Text("Sensor/Equipment Damaged")),
                CheckboxListTile(value: false, onChanged: (val){}, title: const Text("Vandalism")),
                CheckboxListTile(value: false, onChanged: (val){}, title: const Text("Site Inaccessible")),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.camera_alt_outlined), label: const Text("Attach Photo")),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            FilledButton(child: const Text('Report'), onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  // --- HYDROGRAPH WIDGET (Analyst-grade design) ---
  Widget _buildHydrographCard(BuildContext context) {
    final readings = _generateStationReadings(30);
    final spots = readings.reversed.toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['level'] as double);
    }).toList();

    // Determine min/max Y for the chart, dynamically adjusting around current level
    final double minY = (station.currentLevel - 3).floorToDouble();
    final double maxY = (station.currentLevel + 3).ceilToDouble();

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Groundwater Hydrograph', style: Theme.of(context).textTheme.titleLarge),
            Text('Last 30 days', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: station.criticalLevel,
                      color: AppColors.statusCritical.withOpacity(0.8),
                      strokeWidth: 2,
                      dashArray: [8, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (line) => 'Critical Level',
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 2),
                        style: const TextStyle(color: AppColors.statusCritical, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ]),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 2)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 7, getTitlesWidget: (value, meta) {
                      if (value == meta.max || value == meta.min) return const SizedBox.shrink(); // Hide labels at ends
                      return Text(DateFormat('d/M').format(DateTime.now().subtract(Duration(days: 29 - value.toInt()))));
                    })),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.fontTitle,
                      getTooltipItems: (touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final date = DateTime.now().subtract(Duration(days: 29 - barSpot.x.toInt()));
                          return LineTooltipItem(
                            '${DateFormat.MMMd().format(date)}\n',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            children: [TextSpan(text: '${barSpot.y.toStringAsFixed(2)} m', style: const TextStyle(color: Colors.white))],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.chartGrid, strokeWidth: 1, dashArray: [3, 4])),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// Station Search Delegate (New class for map search functionality)
// ==============================================================================

class StationSearchDelegate extends SearchDelegate<Station?> {
  final List<Station> allStations;
  final Function(Station) onStationSelected;

  StationSearchDelegate({required this.allStations, required this.onStationSelected});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary, // Customize AppBar background
        foregroundColor: Colors.white, // Customize AppBar text/icon color
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allStations.where((station) =>
    station.id.toLowerCase().contains(query.toLowerCase()) ||
        station.location.toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 60, color: AppColors.fontBody),
            const SizedBox(height: 16),
            Text("No results found for '$query'", style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final station = results[index];
        return ListTile(
          leading: Icon(Icons.location_pin, color: AppColors.primary),
          title: Text(station.id),
          subtitle: Text(station.location),
          onTap: () {
            onStationSelected(station); // Use the callback
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allStations.where((station) =>
    station.id.toLowerCase().contains(query.toLowerCase()) ||
        station.location.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final station = suggestions[index];
        return ListTile(
          leading: Icon(Icons.location_pin, color: AppColors.primary),
          title: Text(station.id),
          subtitle: Text(station.location),
          onTap: () {
            query = station.id;
            showResults(context);
          },
        );
      },
    );
  }
}
class ReportsLogScreen extends StatelessWidget {
  const ReportsLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reports Log"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportLogItem(context, "Manual Reading", "DWLR_CH_BMP_001", true),
          _buildReportLogItem(context, "Issue Report (Vandalism)", "DWLR_RJ_JAI_001", true),
          _buildReportLogItem(context, "Manual Reading", "DWLR_MH_PUN_002", false),
        ],
      ),
    );
  }

  Widget _buildReportLogItem(BuildContext context, String title, String stationId, bool isSynced) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(stationId),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded, color: isSynced ? AppColors.statusSafe : AppColors.statusModerate),
            const SizedBox(width: 8),
            Text(isSynced ? "Synced" : "Pending"),
          ],
        ),
      ),
    );
  }
}




