import 'package:flutter/material.dart';

class AmenityIcon{
  static IconData getIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case "parking":
        return Icons.local_parking;
      case "wifi":
        return Icons.wifi;
      case "swimming pool":
        return Icons.pool;
      case "gym":
        return Icons.fitness_center;
      case "security":
        return Icons.security;
        case "lift":
        return Icons.elevator;
        case "club house":
        return Icons.groups;
      default:
        return Icons.check_circle_outline;
    }
  }

}