import 'package:flutter/material.dart';
import 'package:smartlist/localization/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.getString('termsOfService')),
      ),
      body: const Center(
        child: Text('Terms of Service Content Goes Here'),
      ),
    );
  }
}