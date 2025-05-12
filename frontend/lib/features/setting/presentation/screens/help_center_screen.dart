import 'package:flutter/material.dart';
import 'package:smartlist/localization/app_localizations.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.getString('helpCenter')),
      ),
      body: const Center(
        child: Text('Help Center Content Goes Here'),
      ),
    );
  }
}