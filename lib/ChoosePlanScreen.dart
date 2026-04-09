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

class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  // 0 = Elite, 1 = Sending items
  int _selectedPlan = 0;

  void _selectPlan(int index) {
    setState(() {
      _selectedPlan = index;
    });
  }

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _Header(
                            widthScale: widthScale,
                            heightScale: heightScale,
                          ),
                          Expanded(
                            child: _PlanSelectionContent(
                              selectedPlan: _selectedPlan,
                              onSelectPlan: _selectPlan,
                              widthScale: widthScale,
                              heightScale: heightScale,
                            ),
                          ),
                          _BottomFooter(
                            widthScale: widthScale,
                            heightScale: heightScale,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Header widget
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
      padding: EdgeInsets.fromLTRB(
        24 * widthScale,
        32 * heightScale,
        24 * widthScale,
        16 * heightScale,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20 * widthScale,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(width: 16 * widthScale),
          Text(
            'Choose your plan',
            style: TextStyle(
              fontSize: 20 * _fontScale(context),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

// Main content area with plan cards
class _PlanSelectionContent extends StatelessWidget {
  final int selectedPlan;
  final Function(int) onSelectPlan;
  final double widthScale;
  final double heightScale;

  const _PlanSelectionContent({
    required this.selectedPlan,
    required this.onSelectPlan,
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 24 * widthScale;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16 * heightScale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanCard(
            title: 'Elite',
            startsFrom: '₹15/km',
            isSelected: selectedPlan == 0,
            onTap: () => onSelectPlan(0),
            activeBorderColor: const Color(0xFFA16244),
            activeTextColor: const Color(0xFF8E6E5D),
            widthScale: widthScale,
            heightScale: heightScale,
          ),
          SizedBox(height: 24 * heightScale),
          _PlanCard(
            title: 'Sending\nitems',
            startsFrom: '₹15/km',
            isSelected: selectedPlan == 1,
            onTap: () => onSelectPlan(1),
            activeBorderColor: const Color(0xFFA16244),
            activeTextColor: const Color(0xFF8E6E5D),
            widthScale: widthScale,
            heightScale: heightScale,
          ),
        ],
      ),
    );
  }
}

// Individual Plan Card
class _PlanCard extends StatelessWidget {
  final String title;
  final String startsFrom;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeBorderColor;
  final Color activeTextColor;
  final double widthScale;
  final double heightScale;

  const _PlanCard({
    required this.title,
    required this.startsFrom,
    required this.isSelected,
    required this.onTap,
    required this.activeBorderColor,
    required this.activeTextColor,
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20 * widthScale),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? activeBorderColor
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8 * widthScale),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: _RadioIndicator(
                isSelected: isSelected,
                activeColor: activeBorderColor,
                widthScale: widthScale,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18 * _fontScale(context),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 16 * heightScale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starts from',
                      style: TextStyle(
                        fontSize: 11 * _fontScale(context),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 2 * heightScale),
                    Text(
                      startsFrom,
                      style: TextStyle(
                        fontSize: 14 * _fontScale(context),
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? activeTextColor
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom radio indicator (outer circle + inner dot when selected)
class _RadioIndicator extends StatelessWidget {
  final bool isSelected;
  final Color activeColor;
  final double widthScale;

  const _RadioIndicator({
    required this.isSelected,
    required this.activeColor,
    required this.widthScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16 * widthScale,
      height: 16 * widthScale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? activeColor : const Color(0xFFD1D5DB),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 8 * widthScale,
                height: 8 * widthScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                ),
              ),
            )
          : null,
    );
  }
}

// Bottom footer with share icon and book again button
class _BottomFooter extends StatelessWidget {
  final double widthScale;
  final double heightScale;

  const _BottomFooter({
    required this.widthScale,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24 * widthScale,
        16 * heightScale,
        24 * widthScale,
        32 * heightScale,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share tapped')),
              );
            },
            child: Icon(
              Icons.share,
              size: 24 * widthScale,
              color: const Color(0xFFB25900),
            ),
          ),
          SizedBox(width: 16 * widthScale),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking again')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB25900),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14 * heightScale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * widthScale),
                ),
                elevation: 0,
              ),
              child: Text(
                'Book Again',
                style: TextStyle(
                  fontSize: 14 * _fontScale(context),
                  fontWeight: FontWeight.w600,
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
