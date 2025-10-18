library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/core/services/auth_error_handler.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

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
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
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
                                AppTheme.secondaryColor,
                                AppTheme.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Titre
                        Text(
                          'Créer un compte',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.accentColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Rejoignez-nous dès aujourd\'hui',
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

                            const SizedBox(height: 20),

                            // Champ mot de passe
                            TextFormField(
                              controller: _pwdCtrl,
                              obscureText: _obscure1,
                              validator: _validatePassword,
                              onChanged: (_) => _formKey.currentState?.validate(),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                hintText: 'Min 6 caractères',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure1
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Champ confirmation mot de passe
                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: _obscure2,
                              validator: _validateConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmer le mot de passe',
                                hintText: 'Retapez votre mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure2
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Bouton d'inscription
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _onSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Créer mon compte',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Séparateur
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isDark ? const Color(0xFF3A332E) : const Color(0xFFE7D9CF),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Ou',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isDark ? const Color(0xFF3A332E) : const Color(0xFFE7D9CF),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Bouton Google
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _onGoogle,
                          icon: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  color: Color(0xFF4285F4),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          label: Text(
                            'S\'inscrire avec Google',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFEAB676) : AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFF3A332E) : const Color(0xFFE7D9CF),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Lien vers connexion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Déjà un compte ? ',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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

  // Validation améliorée du mot de passe
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Minimum 6 caractères';
    }
    return null;
  }

  // Validation de la confirmation du mot de passe
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    if (value != _pwdCtrl.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(_emailCtrl.text.trim(), _pwdCtrl.text.trim());
      if (mounted) context.go('/gallery');
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onGoogle() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) context.go('/gallery');
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object e) {
    AuthErrorHandler.showErrorSnackBar(context, e);
  }
}

