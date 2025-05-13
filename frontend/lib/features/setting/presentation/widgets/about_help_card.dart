import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/routing/route_paths.dart';

class AboutHelpCard extends StatelessWidget {
  const AboutHelpCard({
    super.key,
    required this.appVersion,
  });

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Text(
              localizations.getString('aboutHelp'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          Column(
            children: [
              ListTile(
                title: Text(
                  localizations.getString('helpCenter'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
                onTap: () {
                  context.push(RoutePaths.helpCenter);
                },
              ),
              ListTile(
                title: Text(
                  localizations.getString('privacyPolicy'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
                onTap: () {
                  context.push(RoutePaths.privacyPolicy);
                },
              ),
              ListTile(
                title: Text(
                  localizations.getString('termsOfService'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
                onTap: () {
                  context.push(RoutePaths.termsOfService);
                },
              ),
              ListTile(
                title: Text(
                  localizations.getString('version'),
                  style: const TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  appVersion,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}