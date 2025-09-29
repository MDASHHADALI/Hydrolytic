import 'package:flutter/material.dart';

// Imports for packages
import 'package:hydro/regionalScreen.dart';
import 'package:hydro/stationScreen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'DashboardScreen.dart';
import 'alertScreen.dart';
import 'analysisScreen.dart';
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

  Future<void> _showLogoutConfirmationDialog() async {
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
        // NEW: Added a leading water icon for branding.
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
          // MODIFIED: Redesigned the logout icon and button.
          IconButton(
            icon: const Icon(Icons.logout_rounded), // Changed from account icon
            tooltip: 'Logout', // Updated tooltip
            onPressed: _showLogoutConfirmationDialog,
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

class LoginForm extends StatelessWidget {
  final VoidCallback onSwitchToSignup;
  const LoginForm({super.key, required this.onSwitchToSignup});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Login to continue',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          },
          child: const Text('LOGIN'),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onSwitchToSignup,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Don't have an account? ",
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// SignUpForm

class SignupForm extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const SignupForm({super.key, required this.onSwitchToLogin});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  String? _selectedRole;
  final List<String> _roles = ['Policymaker', 'Researcher', 'Field Officer', 'General Public'];

  // NEW: State variables for the new fields
  String? _selectedState;
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal', 'Delhi'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Get started with Hydrolytic',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(
            labelText: 'I am a...',
            prefixIcon: Icon(Icons.work_outline_rounded),
          ),
          items: _roles.map((String role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue;
            });
          },
        ),
        const SizedBox(height: 16),

        // NEW: Field for Organization / Affiliation
        const TextField(
          decoration: InputDecoration(
            labelText: 'Organization / Affiliation',
            prefixIcon: Icon(Icons.corporate_fare_rounded),
          ),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),

        // NEW: Dropdown for selecting State
        DropdownButtonFormField<String>(
          value: _selectedState,
          decoration: const InputDecoration(
            labelText: 'State',
            prefixIcon: Icon(Icons.location_city_rounded),
          ),
          items: _indianStates.map((String state) {
            return DropdownMenuItem<String>(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedState = newValue;
            });
          },
        ),
        const SizedBox(height: 16),

        // NEW: Field for Phone Number
        const TextField(
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          },
          child: const Text('SIGN UP'),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: widget.onSwitchToLogin,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Already have an account? ",
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: 'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}