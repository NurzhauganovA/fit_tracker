import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await AuthService().signIn(
          email: email,
          password: password,
        );
      } else {
        await AuthService().signUp(
          email: email,
          password: password,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Color(0xFF4ECDC4),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString()
              .replaceAll(RegExp(r'\[.*?\]'), '')
              .replaceAll('Exception:', '')
              .replaceAll('firebase_auth/', '')
              .trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });

    _slideController.reset();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 40),
                        _buildLoginCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFFFF6B35),
                  const Color(0xFFFF8C42),
                  (_backgroundController.value * 2) % 1,
                )!,
                Color.lerp(
                  const Color(0xFF4ECDC4),
                  const Color(0xFF44A08D),
                  (_backgroundController.value * 2) % 1,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildFloatingIcon(
                top: 80,
                left: 30,
                icon: Icons.fitness_center_rounded,
                size: 60,
                duration: 4,
                offset: _backgroundController.value,
              ),
              _buildFloatingIcon(
                top: 250,
                right: 40,
                icon: Icons.local_fire_department_rounded,
                size: 80,
                duration: 5,
                offset: _backgroundController.value,
              ),
              _buildFloatingIcon(
                bottom: 200,
                left: 50,
                icon: Icons.restaurant_rounded,
                size: 70,
                duration: 6,
                offset: _backgroundController.value,
              ),
              _buildFloatingIcon(
                bottom: 350,
                right: 20,
                icon: Icons.trending_up_rounded,
                size: 50,
                duration: 7,
                offset: _backgroundController.value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingIcon({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required IconData icon,
    required double size,
    required int duration,
    required double offset,
  }) {
    final movement = math.sin(offset * math.pi * 2 / duration) * 15;

    return Positioned(
      top: top != null ? top + movement : null,
      bottom: bottom != null ? bottom + movement : null,
      left: left,
      right: right,
      child: Icon(
        icon,
        size: size,
        color: Colors.white.withOpacity(0.15),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 55,
              color: Color(0xFFFF6B35),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'FitTracker',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track Your Fitness Journey',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeToggle(),
            const SizedBox(height: 32),
            if (_errorMessage != null) _buildErrorMessage(),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 20),
            _buildSwitchModeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (!_isLogin) _toggleMode();
          },
          child: _buildModeTab('Sign In', _isLogin),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            if (_isLogin) _toggleMode();
          },
          child: _buildModeTab('Sign Up', !_isLogin),
        ),
      ],
    );
  }

  Widget _buildModeTab(String label, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
        )
            : null,
        color: isActive ? null : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Email Address',
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.email_rounded, color: Colors.white, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _submit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: _isLoading
                ? LinearGradient(
              colors: [
                Colors.grey[400]!,
                Colors.grey[500]!,
              ],
            )
                : const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isLoading
                ? null
                : [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin ? 'Sign In' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchModeButton() {
    return TextButton(
      onPressed: _toggleMode,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
          children: [
            TextSpan(
              text: _isLogin
                  ? "Don't have an account? "
                  : "Already have an account? ",
            ),
            TextSpan(
              text: _isLogin ? 'Sign Up' : 'Sign In',
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}