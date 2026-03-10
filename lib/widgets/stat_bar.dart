import 'package:flutter/material.dart';

/// แถบ stat เดี่ยว เช่น HP, Attack, Defense
/// รับ Animation<double> สำหรับ animate ค่าจาก 0 ไปยังค่าจริง
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final Animation<double> animation;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 255,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          // Animated number
          SizedBox(
            width: 40,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Text(
                  '${(value * animation.value).toInt()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Animated bar
          Expanded(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      // Background track
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Animated fill
                      FractionallySizedBox(
                        widthFactor:
                            (value / maxValue).clamp(0.0, 1.0) *
                            animation.value,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [color, color.withOpacity(0.7)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
