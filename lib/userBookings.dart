import 'package:dldetection/BookingDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'UserBookingsModel.dart';

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

class userBookings extends StatelessWidget {
  userBookings({super.key});

  final List<Userbookingsmodel> bookings = [
    Userbookingsmodel(
      serviceName: 'Nearby Delivery service',
      completionTime: 'Completes within 2 hrs',
      bookingDate: 'Jan 20, 2026',
      price: '₹150',
      originalPrice: '₹150',
    ),
    Userbookingsmodel(
      serviceName: 'Nearby Delivery service',
      completionTime: 'Completes within 2 hrs',
      bookingDate: 'Jan 20, 2026',
      price: '₹150',
      originalPrice: '₹150',
    ),
    Userbookingsmodel(
      serviceName: 'Nearby Delivery service',
      completionTime: 'Completes within 2 hrs',
      bookingDate: 'Jan 20, 2026',
      price: '₹150',
      originalPrice: '₹150',
    ),
    Userbookingsmodel(
      serviceName: 'Nearby Delivery service',
      completionTime: 'Completes within 2 hrs',
      bookingDate: 'Jan 20, 2026',
      price: '₹150',
      originalPrice: '₹150',
    ),
    Userbookingsmodel(
      serviceName: 'Nearby Delivery service',
      completionTime: 'Completes within 2 hrs',
      bookingDate: 'Jan 20, 2026',
      price: '₹150',
      originalPrice: '₹150',
    ),
    Userbookingsmodel(
      serviceName: 'Premium Taxi Service',
      completionTime: 'Ready in 30 mins',
      bookingDate: 'Jan 21, 2026',
      price: '₹250',
      originalPrice: '₹300',
    ),
    Userbookingsmodel(
      serviceName: 'Food Delivery',
      completionTime: 'Arrives in 45 mins',
      bookingDate: 'Jan 22, 2026',
      price: '₹120',
      originalPrice: '₹140',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final widthScale = _widthScale(context);
    final heightScale = _heightScale(context);
    final fontScale = _fontScale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 56 * widthScale,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 22 * widthScale),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Your Bookings',
          style: TextStyle(
            fontSize: 20 * fontScale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                const Divider(
                  thickness: 1,
                  color: Color(0xFFDEDEDE),
                  height: 1,
                ),
                SizedBox(height: 24 * heightScale),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: bookings.length,
                    itemBuilder: (context, index) =>
                        UserBookingBuilder(booking: bookings[index]),
                    separatorBuilder: (context, index) => const Divider(
                      thickness: 2,
                      color: Color(0xFFDEDEDE),
                      height: 2,
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

class UserBookingBuilder extends StatelessWidget {
  final Userbookingsmodel booking;

  const UserBookingBuilder({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final widthScale = _widthScale(context);
    final heightScale = _heightScale(context);
    final fontScale = _fontScale(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthScale,
        vertical: 10 * heightScale,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18 * fontScale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4 * heightScale),
                Text(
                  booking.completionTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2 * heightScale),
                Text(
                  booking.bookingDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 10 * fontScale,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * widthScale),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                booking.price,
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2 * heightScale),
              Text(
                booking.originalPrice,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16 * fontScale,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.grey[600],
                  decorationThickness: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingDetailsScreen(),
                    ),
                  );
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                alignment: Alignment.centerRight,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 15 * widthScale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
