library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/core/services/auth_error_handler.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sending = false;

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _formAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _formAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _logoController.forward();
    _formController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0806) : AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo et titre avec animation
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) => Transform.scale(
                    scale: _logoAnimation.value,
                    child: Column(
                      children: [
                        // Logo moderne
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.halfBaked,
                                AppTheme.easternBlue,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.easternBlue.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_reset_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Titre
                        Text(
                          'Mot de passe oublié',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.accentColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Entrez votre email pour recevoir un lien de réinitialisation',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                          ),
                        ),
                      ],
                    ),
                  ),
              ),

              const SizedBox(height: 48),

              // Formulaire avec animation
              SlideTransition(
                position: _formAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Carte du formulaire
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1A17) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Instructions
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                  ? const Color(0xFF2A241F)
                                  : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                    ? const Color(0xFF3A332E)
                                    : const Color(0xFFE7D9CF),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: isDark
                                      ? const Color(0xFF60A5FA)
                                      : AppTheme.easternBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Nous vous enverrons un email avec les instructions pour réinitialiser votre mot de passe.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF6B5E56),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Champ email
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Entrez votre email',
                                prefixIcon: Icon(Icons.email_outlined),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Bouton d'envoi
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _sending ? null : _send,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.easternBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _sending
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Envoyer le lien de réinitialisation',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Bouton annuler
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: TextButton(
                                onPressed: _sending ? null : () => Navigator.pop(context),
                                child: Text(
                                  'Annuler',
                                  style: TextStyle(
                                    color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF6B5E56),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Aide supplémentaire
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                            ? const Color(0xFF2A241F)
                            : const Color(0xFFF8F6F3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Besoin d\'aide ?',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppTheme.accentColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Vérifiez que vous utilisez la bonne adresse email\n• Regardez dans vos spams\n• Le lien expirera après 24 heures',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF6B5E56),
                                height: 1.5,
                              ),
                            ),
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
      ),
    );
  }

  // Validation améliorée de l'email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);

    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(
        _emailCtrl.text.trim(),
      );

      if (mounted) {
        AuthErrorHandler.showSuccessSnackBar(
          context,
          'Email de réinitialisation envoyé avec succès',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AuthErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }
}

