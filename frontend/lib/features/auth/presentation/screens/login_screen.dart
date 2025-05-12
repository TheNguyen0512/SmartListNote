import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/features/auth/domain/providers/auth_provider.dart';
import 'package:smartlist/features/notes/domain/providers/note_provider.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/routing/route_paths.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (!mounted) return;
      setState(() {
        _errorMessage = localizations.getString('networkError');
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _errorMessage = null;
      });

      try {
        await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.getString('loginSuccess'))),
        );

        if (authProvider.isAuthenticated) {
          await noteProvider.loadNotes();
          if (!mounted) return;
          context.go(RoutePaths.noteList); // Thay pushReplacement
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = localizations.getString(
            authProvider.errorMessage ?? 'authError',
          );
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

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
        await noteProvider.loadNotes(); // Load notes after Google sign-in
        if (!mounted) return;
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
                  Image.asset(
                    'lib/assets/icon/app_icon.png',
                    height: 80,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 80),
                  ),

                  SizedBox(height: AppSizes.spacingLarge(context)),
                  Text(
                    localizations.getString('welcomeBack'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: localizations.getString('emailHint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      errorText:
                          _errorMessage != null &&
                                  _errorMessage!.contains('invalidEmail')
                              ? localizations.getString('invalidEmail')
                              : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.getString('emailRequired');
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
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
                      errorText:
                          _errorMessage != null &&
                                  _errorMessage!.contains('wrongCredentials')
                              ? localizations.getString('wrongCredentials')
                              : null,
                    ),
                    obscureText: !_showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.getString('passwordRequired');
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null &&
                      !(_errorMessage!.contains('invalidEmail') ||
                          _errorMessage!.contains('wrongCredentials')))
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppSizes.spacingSmall(context),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: AppSizes.spacingMedium(context)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final emailController =
                            TextEditingController(); // Assuming you have an email field
                        final shouldReset = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  localizations.getString('resetPassword'),
                                ),
                                content: TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: localizations.getString(
                                      'emailHint',
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text(
                                      localizations.getString('cancel'),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text(
                                      localizations.getString('send'),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (shouldReset == true) {
                          try {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            await authProvider.sendPasswordResetEmail(
                              emailController.text,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.getString('resetPasswordSent'),
                                ),
                              ),
                            );
                          } catch (e) {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.getString(
                                    authProvider.errorMessage ??
                                        'resetPasswordFailed',
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(localizations.getString('forgotPassword')),
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingMedium(context)),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _login,
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
                            child: Text(localizations.getString('loginButton')),
                          );
                    },
                  ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  TextButton(
                    onPressed: () {
                      context.go(RoutePaths.register);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: localizations.getString('noAccount'),
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: ' ${localizations.getString('registerLink')}',
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
                      const Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingMedium(context),
                        ),
                        child: Text(
                          localizations.getString('orContinueWith'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingMedium(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.g_translate, color: Colors.red),
                        onPressed: _signInWithGoogle,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingLarge(context)),
                  Text(
                    localizations.getString('termsAndPrivacy'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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
