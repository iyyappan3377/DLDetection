import 'package:dldetection/ChoosePlanScreen.dart';
import 'package:flutter/material.dart';

double _contentWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width > 560 ? 560 : width;
}

double _widthScale(BuildContext context) {
  return (_contentWidth(context) / 375).clamp(0.85, 1.25);
}

double _heightScale(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height;
  return (height / 812).clamp(0.85, 1.15);
}

double _fontScale(BuildContext context) {
  final width = _contentWidth(context);
  return (width / 375).clamp(0.9, 1.2);
}

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final widthScale = _widthScale(context);
    final heightScale = _heightScale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(widthScale: widthScale, heightScale: heightScale),
                  const Divider(
                    color: Color(0xFFDEDEDE),
                    thickness: 1,
                    height: 1,
                  ),
                  _OfferBanner(widthScale: widthScale, heightScale: heightScale),
                  const Divider(
                    color: Color(0xFFDEDEDE),
                    thickness: 1,
                    height: 1,
                  ),
                  _ServiceInfo(widthScale: widthScale, heightScale: heightScale),
                  const _SectionSeparator(),
                  _TaskDetails(widthScale: widthScale, heightScale: heightScale),
                  const _SectionSeparator(),
                  _PaymentSummary(widthScale: widthScale, heightScale: heightScale),
                  _FooterActions(widthScale: widthScale, heightScale: heightScale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Header with back arrow and title
class _Header extends StatelessWidget {
  final double widthScale;
  final double heightScale;

  const _Header({
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthScale,
        vertical: 20 * heightScale,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Simulate back navigation
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              size: 20 * widthScale,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 12 * widthScale),
          Text(
            'Booking details',
            style: TextStyle(
              fontSize: 20 * _fontScale(context),
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827), // gray-900
            ),
          ),
        ],
      ),
    );
  }
}

// Savings Banner: "Saving ₹390 on this task"
class _OfferBanner extends StatelessWidget {
  final double widthScale;
  final double heightScale;

  const _OfferBanner({
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthScale,
        vertical: 12 * heightScale,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            size: 20 * widthScale,
            color: Colors.blue[500],
          ),
          SizedBox(width: 8 * widthScale),
          Text(
            'Saving ₹390 on this task',
            style: TextStyle(
              fontSize: 14 * _fontScale(context),
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937), // gray-800
            ),
          ),
        ],
      ),
    );
  }
}

// Service Info: Title, subtitle, price with strike-through
class _ServiceInfo extends StatelessWidget {
  final double widthScale;
  final double heightScale;

  const _ServiceInfo({
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthScale,
        vertical: 24 * heightScale,
      ),
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
                  fontSize: 20 * _fontScale(context),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4 * heightScale),
              Text(
                'Completes within 30 mins',
                style: TextStyle(
                  fontSize: 14 * _fontScale(context),
                  color: Color(0xFF6B7280), // gray-500
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
                  fontSize: 18 * _fontScale(context),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2 * heightScale),
              Text(
                '₹789',
                style: TextStyle(
                  fontSize: 14 * _fontScale(context),
                  decoration: TextDecoration.lineThrough,
                  color: Color(0xFF9CA3AF), // gray-400
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Section Separator (gray background with borders)
class _SectionSeparator extends StatelessWidget {
  const _SectionSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // gray-50
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
    );
  }
}

// Task Details: From/To locations, distance, time with dashed lines
class _TaskDetails extends StatelessWidget {
  final double widthScale;
  final double heightScale;

  const _TaskDetails({
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthScale,
        vertical: 24 * heightScale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task details',
            style: TextStyle(
              fontSize: 18 * _fontScale(context),
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 24 * heightScale),
          // From / To Locations
          _LocationRow(widthScale: widthScale, heightScale: heightScale),
          SizedBox(height: 24 * heightScale),
          // Distance and Time rows
          _DetailRow(
            label: 'Total distance of task',
            value: '15km',
            widthScale: widthScale,
          ),
          SizedBox(height: 12 * heightScale),
          _DetailRow(
            label: 'Time taken for task',
            value: '25mins',
            widthScale: widthScale,
          ),
        ],
      ),
    );
  }
}

// Row for From and To locations with swap icon
class _LocationRow extends StatelessWidget {
  final double widthScale;
  final double heightScale;

  const _LocationRow({
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FROM',
                style: TextStyle(
                  fontSize: 10 * _fontScale(context),
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4 * heightScale),
              Text(
                'Konganthanparai',
                style: TextStyle(
                  fontSize: 16 * _fontScale(context),
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.swap_horiz,
          color: Color(0xFF9CA3AF),
          size: 20 * widthScale,
        ),
        SizedBox(width: 8 * widthScale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TO',
                style: TextStyle(
                  fontSize: 10 * _fontScale(context),
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4 * heightScale),
              Text(
                'Palayamkottai',
                style: TextStyle(
                  fontSize: 16 * _fontScale(context),
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Reusable row for distance/time: label, dashed line, value
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double widthScale;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.widthScale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * _fontScale(context),
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(width: 8 * widthScale),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 2 * widthScale),
            child: DashedLine(
              height: 1,
              dashWidth: 5 * widthScale,
              dashSpace: 3 * widthScale,
            ),
          ),
        ),
        SizedBox(width: 8 * widthScale),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * _fontScale(context),
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

// Payment Summary Section
class _PaymentSummary extends StatelessWidget {
  final double widthScale;
  final double heightScale;

  const _PaymentSummary({
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthScale,
        vertical: 24 * heightScale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment summary',
            style: TextStyle(
              fontSize: 18 * _fontScale(context),
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 24 * heightScale),
          // Item total row
          _PaymentRow(
            label: 'Item total',
            price: '₹459',
            oldPrice: '₹789',
            fontScale: _fontScale(context),
          ),
          SizedBox(height: 16 * heightScale),
          // Tax and fees row (with dashed underline)
          _TaxAndFeesRow(fontScale: _fontScale(context)),
          SizedBox(height: 12 * heightScale),
          // Blue Divider
          _BlueDivider(heightScale: heightScale),
          SizedBox(height: 20 * heightScale),
          // Total amount row
          _TotalRow(fontScale: _fontScale(context)),
        ],
      ),
    );
  }
}

// Row for Item total with strike-through
class _PaymentRow extends StatelessWidget {
  final String label;
  final String price;
  final String oldPrice;
  final double fontScale;

  const _PaymentRow({
    required this.label,
    required this.price,
    required this.oldPrice,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * fontScale,
            color: const Color(0xFF6B7280),
          ),
        ),
        Row(
          children: [
            Text(
              oldPrice,
              style: TextStyle(
                fontSize: 14 * fontScale,
                decoration: TextDecoration.lineThrough,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(width: 8 * fontScale),
            Text(
              price,
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Tax and fees row with dashed underline on text
class _TaxAndFeesRow extends StatelessWidget {
  final double fontScale;

  const _TaxAndFeesRow({required this.fontScale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tax and fees',
          style: TextStyle(
            fontSize: 14 * fontScale,
            color: const Color(0xFF6B7280),
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
            decorationColor: Colors.grey.shade400,
            decorationThickness: 1.2,
          ),
        ),
        Text(
          '₹25',
          style: TextStyle(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

// Blue solid divider (3px)
class _BlueDivider extends StatelessWidget {
  final double heightScale;

  const _BlueDivider({required this.heightScale});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3 * heightScale,
      color: const Color(0xFF00A3FF),
    );
  }
}

// Total amount row
class _TotalRow extends StatelessWidget {
  final double fontScale;

  const _TotalRow({required this.fontScale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total amount',
          style: TextStyle(
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          '₹484',
          style: TextStyle(
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

// Footer with share icon and Book Again button
class _FooterActions extends StatelessWidget {
  final double widthScale;
  final double heightScale;

  const _FooterActions({
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthScale,
        vertical: 24 * heightScale,
      ),
      child: Row(
        children: [
          // Share Icon
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share tapped')),
              );
            },
            child: Icon(
              Icons.share,
              size: 24 * widthScale,
              color: Color(0xFF9A3412), // orange-800
            ),
          ),
          SizedBox(width: 24 * widthScale),
          // Book Again Button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChoosePlanScreen()
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking again')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA65100),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12 * heightScale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * widthScale),
                ),
                elevation: 0,
              ),
              child: Text(
                'Book Again',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14 * _fontScale(context),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom dashed line painter for distance/time rows
class DashedLine extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashSpace;
  final Color color;

  const DashedLine({
    super.key,
    this.height = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.color = const Color(0xFFE5E7EB), // gray-200
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        return CustomPaint(
          size: Size(totalWidth, height),
          painter: _DashedLinePainter(
            dashWidth: dashWidth,
            dashSpace: dashSpace,
            color: color,
            totalWidth: totalWidth,
            lineHeight: height,
          ),
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final double totalWidth;
  final double lineHeight;

  const _DashedLinePainter({
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
    required this.totalWidth,
    required this.lineHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineHeight
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < totalWidth) {
      final endX = startX + dashWidth;
      if (endX > totalWidth) break;
      canvas.drawLine(
        Offset(startX, lineHeight / 2),
        Offset(endX, lineHeight / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
