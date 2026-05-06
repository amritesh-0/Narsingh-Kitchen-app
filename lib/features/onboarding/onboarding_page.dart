import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.color,
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.currentIndex,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  final Color color;
  final String image;
  final String title;
  final String description;
  final String buttonText;
  final int currentIndex;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.55;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(60),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative elements
                      Positioned(
                        top: -50,
                        left: -50,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: color.withValues(alpha: 0.05),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        right: -30,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: color.withValues(alpha: 0.08),
                        ),
                      ),
                      
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: onSkip,
                                child: Text(
                                  'Skip',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Hero(
                            tag: 'onboarding_$currentIndex',
                            child: Image.asset(
                              image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedSmoothIndicator(
                              activeIndex: currentIndex,
                              count: totalPages,
                              effect: ExpandingDotsEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                activeDotColor: color,
                                dotColor: AppColors.dividerGray,
                                expansionFactor: 4,
                                spacing: 6,
                              ),
                            ),
                            SizedBox(
                              height: 64,
                              width: 64,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: AppColors.whiteSurface,
                                  padding: EdgeInsets.zero,
                                  elevation: 4,
                                  shadowColor: color.withValues(alpha: 0.4),
                                  shape: const CircleBorder(),
                                ),
                                onPressed: onNext,
                                child: const Icon(Icons.arrow_forward_ios_rounded, size: 24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
