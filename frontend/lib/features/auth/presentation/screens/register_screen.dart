import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/auth/domain/providers/auth_provider.dart';
import 'package:smartlist/routing/route_paths.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool validateEmail(String email) {
    const re = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
    return RegExp(re).hasMatch(email);
  }

  bool validatePassword(String password) {
    const re = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$';
    return RegExp(re).hasMatch(password);
  }

  bool validatePasswordMatch() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  void _register() async {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _nameError =
          _fullNameController.text.trim().isEmpty
              ? localizations.getString('fullNameRequired')
              : null;
      _emailError =
          !validateEmail(_emailController.text)
              ? localizations.getString('invalidEmail')
              : null;
      _passwordError =
          !validatePassword(_passwordController.text)
              ? localizations.getString('passwordStrength')
              : null;
      _confirmPasswordError =
          !validatePasswordMatch()
              ? localizations.getString('passwordsNotMatch')
              : null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        await authProvider.register(
          _emailController.text,
          _passwordController.text,
          _fullNameController.text,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.getString('registerSuccess'))),
        );

        context.go(RoutePaths.noteList);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.getString(authProvider.errorMessage ?? 'authError'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (!mounted) return;
      setState(() {
        _errorMessage = localizations.getString('networkError');
      });
      return;
    }

    try {
      await authProvider.signInWithGoogle();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.getString('loginSuccess'))),
      );

      if (authProvider.isAuthenticated) {
        context.go(RoutePaths.noteList);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = localizations.getString(
          authProvider.errorMessage ?? 'googleSignInFailed',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingLarge,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  Image.network(
                    'https://readdy.ai/api/search-image?query=Modern%2520minimalist%2520app%2520logo%2520design%2520with%2520abstract%2520geometric%2520shapes%2520in%2520gradient%2520blue%2520and%2520purple%2520colors%252C%2520professional%2520clean%2520look%252C%2520isolated%2520on%2520transparent%2520background%252C%2520centered%2520composition%252C%2520high%2520quality%2520vector%2520style%252C%2520simple%2520and%2520elegant&width=150&height=150&seq=logo123&orientation=squarish',
                    height: 80,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 80),
                  ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  Text(
                    localizations.getString('registerTitle'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: localizations.getString('fullNameHint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person, color: Colors.grey),
                      errorText: _nameError,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.getString('fullNameRequired');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.spacingMedium(context)),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: localizations.getString('emailHint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      errorText: _emailError,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.getString('emailRequired');
                      }
                      if (!validateEmail(value)) {
                        return localizations.getString('invalidEmail');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.spacingMedium(context)),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: localizations.getString('passwordHint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed:
                            () =>
                                setState(() => _showPassword = !_showPassword),
                      ),
                      errorText: _passwordError,
                    ),
                    obscureText: !_showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.getString('passwordRequired');
                      }
                      if (!validatePassword(value)) {
                        return localizations.getString('passwordStrength');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.spacingMedium(context)),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: localizations.getString('confirmPasswordHint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed:
                            () => setState(
                              () =>
                                  _showConfirmPassword = !_showConfirmPassword,
                            ),
                      ),
                      errorText: _confirmPasswordError,
                    ),
                    obscureText: !_showConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.getString(
                          'confirmPasswordRequired',
                        );
                      }
                      if (!validatePasswordMatch()) {
                        return localizations.getString('passwordsNotMatch');
                      }
                      return null;
                    },
                  ),
                  if (_nameError != null ||
                      _emailError != null ||
                      _passwordError != null ||
                      _confirmPasswordError != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppSizes.spacingSmall(context),
                      ),
                      child: Text(
                        _nameError ??
                            _emailError ??
                            _passwordError ??
                            _confirmPasswordError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: Size(
                                AppSizes.buttonWidth(context),
                                AppSizes.buttonHeight(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              localizations.getString('registerButton'),
                            ),
                          );
                    },
                  ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  TextButton(
                    onPressed: () {
                      context.go(RoutePaths.login);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: localizations.getString('alreadyHaveAccount'),
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: ' ${localizations.getString('loginLink')}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingMedium(context),
                        ),
                        child: Text(
                          localizations.getString('orContinueWith'),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingMedium(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.g_translate, color: Colors.red),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  Text(
                    localizations.getString('termsAndPrivacy'),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
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
