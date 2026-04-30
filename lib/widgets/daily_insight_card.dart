import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tokens.dart';

class DailyInsightCard extends StatelessWidget {
  final String text;

  const DailyInsightCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent rule
          Container(
            width: 2,
            constraints: const BoxConstraints(minHeight: 36),
            margin: const EdgeInsets.only(left: 2, right: 12),
            decoration: BoxDecoration(
              color: AppColors.you.withAlpha(128),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily signal', style: AppText.tracked(size: 9, color: AppColors.ink3)),
                const SizedBox(height: 4),
                Text(
                  '"$text"',
                  style: GoogleFonts.newsreader(
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.ink1,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
