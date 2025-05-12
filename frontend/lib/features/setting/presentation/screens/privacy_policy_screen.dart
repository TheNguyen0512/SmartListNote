import 'package:flutter/material.dart';
import 'package:smartlist/localization/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.getString('privacyPolicy')),
      ),
      body: const Center(
        child: Text('Privacy Policy Content Goes Here'),
      ),
    );
  }
}