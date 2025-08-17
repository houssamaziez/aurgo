import 'package:aurgo/views/home/StationPickupApp.dart';
import 'package:flutter/material.dart';

import '../views/home/AutonomousRideScreen.dart';
import '../views/home/CarRentalApp.dart';
import '../views/home/ChauffeuredRideRequestScreen.dart';
import '../views/home/NearbyAutonomousScreen.dart';

class ServiceOption {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget rout;

  const ServiceOption({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rout,
  });
}

// قائمة الخيارات
final List<ServiceOption> serviceOptions = [
  const ServiceOption(
    color: Colors.blueAccent,
    icon: Icons.directions_car,
    title: "طلب سيارة بسائق",
    subtitle: "سيارة بسائق عند الطلب",
    rout: ChauffeuredRideRequestScreen(),
  ),
  const ServiceOption(
    color: Colors.purpleAccent,
    icon: Icons.smart_toy,
    title: "سيارة ذاتية القيادة",
    subtitle: "تجربة مستقبلية آمنة",
    rout: NearbyAutonomousScreen(),
  ),
  const ServiceOption(
    color: Colors.orangeAccent,
    icon: Icons.local_shipping,
    title: "توصيل من محطة",
    subtitle: "أرسل أو استلم من محطة",
    rout: StationPickupScreen(),
  ),
  const ServiceOption(
    color: Colors.greenAccent,
    icon: Icons.vpn_key,
    title: "استئجار سيارة",
    subtitle: "احجز سيارة لفترة محددة",
    rout: CarRentalHome(),
  ),
];
