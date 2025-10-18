library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/core/services/auth_error_handler.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _isCheckingAuth = true;
  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _formAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthState();
  }

  void _initializeAnimations() {
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
  }

  Future<void> _checkAuthState() async {
    // Attendre un court instant pour la vérification initiale
    await Future.delayed(const Duration(milliseconds: 500));

    // Vérifier si l'utilisateur est déjà connecté
    final authRepository = ref.read(authRepositoryProvider);
    final currentUser = authRepository.currentUser;

    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });

      // Démarrer les animations seulement après la vérification
      _logoController.forward();
      _formController.forward();

      // Si l'utilisateur est déjà connecté, rediriger
      if (currentUser != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/gallery');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.contact_page_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Titre
                        Text(
                          'Bienvenue',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.accentColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Connectez-vous à votre espace',
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
                              color: Colors.black.withOpacity(0.05),
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
                              validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
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
                              obscureText: _obscure,
                              validator: (v) => (v == null || v.length < 6) ? 'Min 6 caractères' : null,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                hintText: 'Entrez votre mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Mot de passe oublié
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/forgot'),
                                child: const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Bouton de connexion
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _onLogin,
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
                                        'Se connecter',
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
                            'Continuer avec Google',
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

                      // Lien vers inscription
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pas encore de compte ? ',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/signup'),
                            child: const Text(
                              'S\'inscrire',
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

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(_emailCtrl.text.trim(), _pwdCtrl.text.trim());
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

