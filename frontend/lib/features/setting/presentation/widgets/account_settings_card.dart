import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/auth/domain/providers/auth_provider.dart';
import 'package:smartlist/localization/locale_provider.dart';

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
              localizations.getString('accountSettings'),
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
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  authProvider.user?.displayName ?? 'Unknown User',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                subtitle: Text(
                  authProvider.user?.email ?? 'No email',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {},
                ),
              ),
              ListTile(
                title: Text(
                  localizations.getString('language'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: Provider.of<LocaleProvider>(context).locale.languageCode,
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            localizations.getString('english'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'vi',
                          child: Text(
                            localizations.getString('vietnamese'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          Provider.of<LocaleProvider>(context, listen: false).setLocale(
                            Locale(value, value == 'en' ? 'US' : 'VN'),
                          );
                        }
                      },
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue),
                      underline: const SizedBox.shrink(),
                      dropdownColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  localizations.getString('changePassword'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
                onTap: () async {
                  final currentPasswordController = TextEditingController();
                  final newPasswordController = TextEditingController();

                  final shouldChange = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        localizations.getString('changePassword'),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: currentPasswordController,
                            decoration: InputDecoration(
                              labelText: localizations.getString('currentPassword'),
                            ),
                            obscureText: true,
                          ),
                          TextField(
                            controller: newPasswordController,
                            decoration: InputDecoration(
                              labelText: localizations.getString('newPassword'),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(localizations.getString('cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(localizations.getString('change')),
                        ),
                      ],
                    ),
                  );

                  if (shouldChange == true) {
                    try {
                      await authProvider.changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations.getString('passwordChanged')),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              localizations.getString(
                                authProvider.errorMessage ?? 'changePasswordFailed',
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              ListTile(
                title: Text(
                  localizations.getString('exportData'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}