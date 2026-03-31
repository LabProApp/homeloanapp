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
    switch (amenityNumber.trim()) {

      case "1":
        return const AmenityData(icon: Icons.pool, label: "Swimming Pool");

      case "2":
        return const AmenityData(icon: Icons.elevator, label: "Lift");

      case "3":
        return const AmenityData(icon: Icons.fitness_center, label: "Gym");

      case "4":
        return const AmenityData(icon: Icons.local_parking, label: "Parking");

      case "5":
        return const AmenityData(icon: Icons.security, label: "Security");

      case "6":
        return const AmenityData(icon: Icons.wifi, label: "Wi-Fi");

      case "7":
        return const AmenityData(icon: Icons.groups, label: "Club House");

      case "8":
        return const AmenityData(icon: Icons.park, label: "Garden / Park");

      case "9":
        return const AmenityData(icon: Icons.sports_basketball, label: "Sports Area");

      case "10":
        return const AmenityData(icon: Icons.child_care, label: "Kids Play Area");

      case "11":
        return const AmenityData(icon: Icons.power, label: "Power Backup");

      case "12":
        return const AmenityData(icon: Icons.water_drop, label: "24x7 Water Supply");

      case "13":
        return const AmenityData(icon: Icons.restaurant, label: "Restaurant / Cafeteria");

      case "14":
        return const AmenityData(icon: Icons.videocam, label: "CCTV Surveillance");

      case "15":
        return const AmenityData(icon: Icons.pets, label: "Pet Friendly");

      case "16":
        return const AmenityData(icon: Icons.directions_bus, label: "Public Transport Nearby");

      case "17":
        return const AmenityData(icon: Icons.ev_station, label: "EV Charging");

      case "18":
        return const AmenityData(icon: Icons.meeting_room, label: "Conference Room");

      case "19":
        return const AmenityData(icon: Icons.weekend, label: "Lounge Area");

      default:
        return const AmenityData(
          icon: Icons.help_outline,
          label: "Other",
        );
    }
  }
}