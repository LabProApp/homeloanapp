import 'package:flutter/material.dart';

class AmenityData {
  final IconData icon;
  final String label;

  const AmenityData({
    required this.icon,
    required this.label,
  });
}

class AmenityIcon {
  static AmenityData getAmenity(String amenityNumber) {
    switch (amenityNumber) {
      case "1":
        return const AmenityData(
          icon: Icons.pool,
          label: "Swimming Pool",
        );
      case "2":
        return const AmenityData(
          icon: Icons.elevator,
          label: "Lift",
        );
      case "3":
        return const AmenityData(
          icon: Icons.fitness_center,
          label: "Gym",
        );
      case "4":
        return const AmenityData(
          icon: Icons.local_parking,
          label: "Parking",
        );
      case "5":
        return const AmenityData(
          icon: Icons.security,
          label: "Security",
        );
      case "6":
        return const AmenityData(
          icon: Icons.wifi,
          label: "Wi-Fi",
        );
      case "7":
        return const AmenityData(
          icon: Icons.groups,
          label: "Club House",
        );
      default:
        return const AmenityData(
          icon: Icons.check_circle_outline,
          label: "Amenity",
        );
    }
  }
}

