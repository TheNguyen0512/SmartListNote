import 'package:flutter/material.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/localization/app_localizations.dart';

class AppearanceCard extends StatefulWidget {
  const AppearanceCard({
    super.key,
    required this.theme,
    required this.textSize,
    required this.onThemeChange,
    required this.onTextSizeChange,
  });

  final String theme;
  final int textSize;
  final void Function(String) onThemeChange;
  final void Function(int) onTextSizeChange;

  @override
  State<AppearanceCard> createState() => _AppearanceCardState();
}

class _AppearanceCardState extends State<AppearanceCard> {
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
              localizations.getString('appearance'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      localizations.getString('theme'),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildThemeButton(
                          'light',
                          Icons.wb_sunny,
                          'Light',
                        ),
                        _buildThemeButton(
                          'dark',
                          Icons.nightlight_round,
                          'Dark',
                        ),
                        _buildThemeButton(
                          'system',
                          Icons.brightness_auto,
                          'System',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.getString('textSize'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          widget.textSize == 1
                              ? 'Small'
                              : widget.textSize == 2
                                  ? 'Medium'
                                  : widget.textSize == 3
                                      ? 'Large'
                                      : 'Extra Large',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: widget.textSize.toDouble(),
                      min: 1,
                      max: 4,
                      divisions: 3,
                      label: widget.textSize.toString(),
                      onChanged: (value) => widget.onTextSizeChange(value.toInt()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(String themeValue, IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onThemeChange(themeValue),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.theme == themeValue ? AppColors.primary : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(8),
            color: widget.theme == themeValue ? Colors.blue[50] : null,
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(
                  icon,
                  color: widget.theme == themeValue ? Colors.blue : Colors.grey,
                  size: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: widget.theme == themeValue ? Colors.blue : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}