
import 'package:dldetection/SelectPaymentMethod.dart';
import 'package:flutter/material.dart';

class ServiceDetailsAndBookingDetails extends StatelessWidget {
   ServiceDetailsAndBookingDetails
    ({super.key});

  double _getScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base design width is 375
    return width / 375.0;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScale(context);
    final double basePadding = 16.0 * scale;
    final double baseMargin = 8.0 * scale;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0 * scale),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20 * scale),
            onPressed: () {},
            padding: EdgeInsets.all(12 * scale),
          ),
          title: Text(
            'Booking details',
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1 * scale),
            child: Container(
              height: 1 * scale,
              color: const Color(0xFFF3F4F6),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Savings Banner
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: basePadding,
                vertical: 12 * scale,
              ),
              color: const Color(0xFFF8FAFF),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4 * scale),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4B88FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12 * scale,
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Text(
                    'Saving ₹390 on this task',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            // Service Details
            Container(
              margin: EdgeInsets.only(bottom: baseMargin),
              padding: EdgeInsets.all(basePadding),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby Delivery service',
                        style: TextStyle(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        'Completes within 2 hrs',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹459',
                        style: TextStyle(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        '₹789',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          decoration: TextDecoration.lineThrough,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Plus Subscription
            Container(
              margin: EdgeInsets.only(bottom: baseMargin),
              padding: EdgeInsets.all(basePadding),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24 * scale,
                            height: 24 * scale,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD86927),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 12 * scale,
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            'Plus',
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD86927),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹199',
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            '₹399',
                            style: TextStyle(
                              fontSize: 14 * scale,
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3 month plan',
                              style: TextStyle(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 16 * scale),
                            DottedDivider(scale: scale),
                            SizedBox(height: 16 * scale),
                            Text(
                              'Get 10% off on all bookings, upto ₹200',
                              style: TextStyle(
                                fontSize: 14 * scale,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                            SizedBox(height: 12 * scale),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'View all benefits',
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFD86927),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24 * scale,
                          vertical: 6 * scale,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1 * scale,
                          ),
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD86927),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Payment Summary
            Container(
              padding: EdgeInsets.all(basePadding),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment summary',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  // Item total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Item total',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '₹789',
                            style: TextStyle(
                              fontSize: 14 * scale,
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            '₹459',
                            style: TextStyle(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  // Taxes and Fee row with dotted underline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DottedUnderlineText(
                        text: 'Taxes and Fee',
                        scale: scale,
                        textStyle: TextStyle(
                          fontSize: 14 * scale,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      Text(
                        '₹25',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  Divider(
                    height: 1 * scale,
                    thickness: 1 * scale,
                    color: const Color(0xFFF3F4F6),
                  ),
                  SizedBox(height: 16 * scale),
                  // Total amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total amount',
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        '₹484',
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Add bottom padding to avoid content being hidden behind footer
            SizedBox(height: 20 * scale),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, -2 * scale),
              blurRadius: 10 * scale,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16 * scale),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share,
                    size: 24 * scale,
                    color: const Color(0xFF4B5563),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Container(
                    height: 56 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA15B13),
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SelectPaymentMethod()));
                          // Handle proceed to pay action
                        },

                        child: Text(
                          'PROCEED TO PAY',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5 * scale,
                          ),
                        ),
                      ),
                    ),
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

// Custom dotted line painter for full width dividers
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotWidth;
  final double dotSpace;
  final double strokeWidth;

  DottedLinePainter({
    required this.color,
    required this.dotWidth,
    required this.dotSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dotWidth, size.height / 2),
        paint,
      );
      startX += dotWidth + dotSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Full width dotted divider
class DottedDivider extends StatelessWidget {
  final double scale;

  const DottedDivider({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 1 * scale),
      painter: DottedLinePainter(
        color: const Color(0xFFD1D5DB),
        dotWidth: 4 * scale,
        dotSpace: 4 * scale,
        strokeWidth: 1 * scale,
      ),
    );
  }
}

// Dotted underline for text (exactly under the text)
class DottedUnderlineText extends StatelessWidget {
  final String text;
  final double scale;
  final TextStyle textStyle;

  const DottedUnderlineText({
    super.key,
    required this.text,
    required this.scale,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: textStyle),
          SizedBox(height: 2 * scale),
          CustomPaint(
            size: Size(double.infinity, 1 * scale),
            painter: DottedLinePainter(
              color: const Color(0xFF9CA3AF),
              dotWidth: 3 * scale,
              dotSpace: 3 * scale,
              strokeWidth: 1 * scale,
            ),
          ),
        ],
      ),
    );
  }
}