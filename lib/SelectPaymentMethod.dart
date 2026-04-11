import 'package:flutter/material.dart';

class SelectPaymentMethod extends StatelessWidget {
  const SelectPaymentMethod({super.key});

  double _getScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base design width is 375
    return width / 375.0;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScale(context);
    final double basePaddingH = 20.0 * scale; // px-5 = 20px
    final double basePaddingV = 16.0 * scale; // py-4 = 16px

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header (sticky top)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16 * scale, 24 * scale, 16 * scale, 16 * scale),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.all(4 * scale),
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 20 * scale,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Text(
                          'Select payment method',
                          style: TextStyle(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(66 * scale, 0, 16 * scale, 16 * scale),
                         child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Amount to pay: ₹484',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1 * scale,
                    color: const Color(0xFFF3F4F6),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // UPI Section
                  _buildUPISection(scale, basePaddingH, basePaddingV),
                  _buildDivider(scale),
                  // Cards Section
                  _buildCardsSection(scale, basePaddingH, basePaddingV),
                  _buildDivider(scale),
                  // Netbanking Section
                  _buildNetbankingSection(scale, basePaddingH, basePaddingV),
                  _buildDivider(scale),
                  // Pay After Service Section
                  _buildPayAfterServiceSection(scale, basePaddingH, basePaddingV),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(scale),
    );
  }

  Widget _buildUPISection(double scale, double padH, double padV) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with MOST POPULAR badge
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UPI',
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(width: 12 * scale),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(4 * scale),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E8E3E),
                    letterSpacing: 0.5 * scale,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Google Pay UPI row
        _buildPaymentRow(
          scale: scale,
          leading: Container(
            width: 48 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(6 * scale),
              color: Colors.white,
            ),
            child: Center(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCjlHJEAtSIpB2xdtVeMlhRTLLUCQ-7qim5QeBT_yD4KDwVJl3hcEzWrGcnEDTblkMa2AS0xoVUW8peJI2SrAVeYTeHpwyYQScF5YpNIxQppdW2sASo4B_RK3dfk_5fon60dG0M3cUJ5QNIpCnt05GyC1dgsVg3oKONycaQ1OWtSHf8i5Gs9bDU0e5PRaTH-uyQN9NUzTsDPnJpjDAc5OkAKRKZNCbHeQ61hO77Jqr8Pe8jg6Z6SQHsuM8UtUVcECQODKBmtNwaTHk',
                height: 16 * scale,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: 16 * scale),
              ),
            ),
          ),
          title: 'Google Pay UPI',
          onTap: () {},
        ),
        // Add new UPI ID row
        _buildPaymentRow(
          scale: scale,
          leading: Container(
            width: 48 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(6 * scale),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'UPI',
                  style: TextStyle(
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Icon(
                  Icons.play_arrow,
                  size: 10 * scale,
                  color: const Color(0xFFF97316),
                ),
              ],
            ),
          ),
          title: 'Add a new UPI ID',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCardsSection(double scale, double padH, double padV) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Text(
            'Cards',
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        _buildPaymentRow(
          scale: scale,
          leading: Container(
            width: 48 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(6 * scale),
              color: const Color(0xFFF1F3F4),
            ),
            child: Center(
              child: _CardIcon(scale: scale),
            ),
          ),
          title: 'Add new card',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildNetbankingSection(double scale, double padH, double padV) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Text(
            'Netbanking',
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        _buildPaymentRow(
          scale: scale,
          leading: Container(
            width: 48 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(6 * scale),
              color: const Color(0xFFF1F3F4),
            ),
            child: Icon(
              Icons.account_balance,
              size: 20 * scale,
              color: Colors.black87,
            ),
          ),
          title: 'Netbanking',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPayAfterServiceSection(double scale, double padH, double padV) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: 24 * scale),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Pay after service',
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            _buildChevron(scale),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow({
    required double scale,
    required Widget leading,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
        color: Colors.white,
        child: Row(
          children: [
            leading,
            SizedBox(width: 16 * scale),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15 * scale,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            _buildChevron(scale),
          ],
        ),
      ),
    );
  }

  Widget _buildChevron(double scale) {
    return Icon(
      Icons.chevron_right,
      size: 18 * scale,
      color: const Color(0xFF70757A),
    );
  }

  Widget _buildDivider(double scale) {
    return Container(
      height: 8 * scale,
      color: const Color(0xFFF4F5F7),
    );
  }

  Widget _buildFooter(double scale) {
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, -2 * scale),
            blurRadius: 8 * scale,
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            height: 56 * scale,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFC26E12), width: 1 * scale),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.share,
                  size: 20 * scale,
                  color: const Color(0xFFC26E12),
                ),
                SizedBox(width: 12 * scale),
                Text(
                  'ASK FRIENDS TO PAY',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5 * scale,
                    color: const Color(0xFFC26E12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom card icon matching the HTML SVG exactly
class _CardIcon extends StatelessWidget {
  final double scale;

  const _CardIcon({required this.scale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24 * scale,
      height: 18 * scale,
      child: CustomPaint(
        painter: _CardIconPainter(scale: scale),
      ),
    );
  }
}

class _CardIconPainter extends CustomPainter {
  final double scale;

  _CardIconPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFF5F6368)
      ..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(2 * scale),
    );
    canvas.drawRRect(rect, bgPaint);

    // White rectangles inside (as per original SVG)
    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // First rectangle: width 3, height 2 at x=4, y=6 (relative to original 24x18)
    final firstRect = Rect.fromLTWH(4 * scale, 6 * scale, 3 * scale, 2 * scale);
    canvas.drawRect(firstRect, whitePaint);

    // Second rectangle: width 10, height 1 at x=4, y=10
    final secondRect = Rect.fromLTWH(4 * scale, 10 * scale, 10 * scale, 1 * scale);
    canvas.drawRect(secondRect, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
