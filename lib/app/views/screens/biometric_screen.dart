import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/utils/constants.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _auth = Get.find();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Auto-attempt auth after brief delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), _tryAuth);
    });
  }

  Future<void> _tryAuth() async {
    final ok = await _auth.authenticate();
    if (ok) Get.offAllNamed(AppRoutes.main);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0D1117),
                    Color(0xFF161B22),
                    Color(0xFF0D1117)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFFEEF4FF),
                    Color(0xFFF5F7FA),
                    Color(0xFFE8F0FE)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo & App Name
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        )
                      ],
                    ),
                    child:
                        const Icon(Icons.bolt, color: Colors.white, size: 44),
                  ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: 16),
                  Text(
                    'Eletro',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  Text(
                    'قم بالتحقق من هويتك للمتابعة',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText,
                        ),
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                ],
              ),
              const Spacer(),
              // Fingerprint Button
              GestureDetector(
                onTap: _tryAuth,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary
                              .withOpacity(0.3 + _pulseController.value * 0.5),
                          width: 2 + _pulseController.value * 2,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(
                                  0.8 + _pulseController.value * 0.2),
                              AppColors.accent.withOpacity(
                                  0.8 + _pulseController.value * 0.2),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(
                                  0.3 + _pulseController.value * 0.3),
                              blurRadius: 20 + _pulseController.value * 15,
                              spreadRadius: 2 + _pulseController.value * 5,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          color: Colors.white,
                          size: 72,
                        ),
                      ),
                    );
                  },
                ),
              ).animate().scale(
                    delay: 600.ms,
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 24),
              Obx(() => _auth.isAuthenticating
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : Column(
                      children: [
                        if (_auth.authError.isNotEmpty)
                          Text(
                            _auth.authError,
                            style: const TextStyle(color: AppColors.danger),
                          ).animate().fadeIn(),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط للتحقق بالبصمة',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkSubText
                                        : AppColors.lightSubText,
                                  ),
                        ),
                      ],
                    )),
              const Spacer(),
              // Skip button
              TextButton(
                onPressed: _auth.skipAuth,
                child: Text(
                  'تخطي التحقق',
                  style: TextStyle(
                    color:
                        isDark ? AppColors.darkSubText : AppColors.lightSubText,
                    fontSize: 14,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
