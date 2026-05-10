import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Subscriptions',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 24, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _subscriptionCard(
              'Premium Tiffin Plan',
              'Lunch & Dinner',
              'Active',
              'Valid until 15 Dec 2026',
              AppColors.successGreen,
            ),
            const SizedBox(height: 16),
            _subscriptionCard(
              'Student Meal Box',
              'Lunch Only',
              'Expired',
              'Expired on 10 Oct 2023',
              AppColors.textSecondary,
            ),
            const SizedBox(height: 32),
            _buildInfoBox(),
          ],
        ),
      ),
    );
  }

  Widget _subscriptionCard(String title, String subtitle, String status, String expiry, Color statusColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.center,
              child: const Text('🍱', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                  Text(subtitle, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(expiry, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(status, style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primaryRed),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Subscriptions allow you to get meals at discounted prices. View our catalog to subscribe to a new plan.',
              style: GoogleFonts.outfit(color: AppColors.primaryRed, fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
