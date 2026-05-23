import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _keys = <String, String>{
    'order_updates': 'Order updates',
    'subscription_reminders': 'Subscription reminders',
    'offers': 'Offers and promos',
    'delivery_alerts': 'Delivery alerts',
  };

  final Map<String, bool> _values = <String, bool>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _keys.entries) {
      _values[entry.key] = prefs.getBool(entry.key) ?? true;
    }
    setState(() => _loading = false);
  }

  Future<void> _update(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() => _values[key] = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ..._keys.entries.map(
                  (entry) => Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.whiteSurface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: SwitchListTile(
                      value: _values[entry.key] ?? true,
                      onChanged: (value) => _update(entry.key, value),
                      activeThumbColor: AppColors.primaryRed,
                      title: Text(
                        entry.value,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Manage ${entry.value.toLowerCase()} for your account.',
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
