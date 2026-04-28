import 'package:flutter/material.dart';

class AmenityData {
  final IconData icon;
  final String label;
  const AmenityData({required this.icon, required this.label});
}

class AmenityIcon {
  static AmenityData getAmenity(String amenity) {
    switch (amenity.trim().toLowerCase()) {
      case '1':
      case 'swimming pool':
      case 'pool':
        return const AmenityData(icon: Icons.pool, label: 'Swimming Pool');
      case '2':
      case 'lift':
      case 'elevator':
        return const AmenityData(icon: Icons.elevator, label: 'Lift');
      case '3':
      case 'gym':
      case 'gymnasium':
      case 'fitness center':
        return const AmenityData(icon: Icons.fitness_center, label: 'Gym');
      case '4':
      case 'parking':
        return const AmenityData(icon: Icons.local_parking, label: 'Parking');
      case '5':
      case 'security':
      case '24x7 security':
        return const AmenityData(icon: Icons.security, label: 'Security');
      case '6':
      case 'wi-fi':
      case 'wifi':
      case 'internet':
        return const AmenityData(icon: Icons.wifi, label: 'Wi-Fi');
      case '7':
      case 'club house':
      case 'clubhouse':
        return const AmenityData(icon: Icons.groups, label: 'Club House');
      case '8':
      case 'garden':
      case 'garden / park':
      case 'park':
        return const AmenityData(icon: Icons.park, label: 'Garden');
      case '9':
      case 'sports area':
      case 'sports':
        return const AmenityData(icon: Icons.sports_basketball, label: 'Sports Area');
      case '10':
      case 'kids play area':
      case 'play area':
      case 'children play area':
        return const AmenityData(icon: Icons.child_care, label: 'Kids Area');
      case '11':
      case 'power backup':
      case 'power back up':
        return const AmenityData(icon: Icons.power, label: 'Power Backup');
      case '12':
      case '24x7 water supply':
      case 'water supply':
        return const AmenityData(icon: Icons.water_drop, label: 'Water 24x7');
      case '13':
      case 'restaurant':
      case 'cafeteria':
      case 'restaurant / cafeteria':
        return const AmenityData(icon: Icons.restaurant, label: 'Restaurant');
      case '14':
      case 'cctv':
      case 'cctv surveillance':
      case 'cctv cameras':
        return const AmenityData(icon: Icons.videocam, label: 'CCTV');
      case '15':
      case 'pet friendly':
      case 'pets allowed':
        return const AmenityData(icon: Icons.pets, label: 'Pet Friendly');
      case '16':
      case 'public transport nearby':
      case 'public transport':
        return const AmenityData(icon: Icons.directions_bus, label: 'Transport');
      case '17':
      case 'ev charging':
      case 'ev station':
        return const AmenityData(icon: Icons.ev_station, label: 'EV Charging');
      case '18':
      case 'conference room':
      case 'meeting room':
        return const AmenityData(icon: Icons.meeting_room, label: 'Conference');
      case '19':
      case 'lounge area':
      case 'lounge':
        return const AmenityData(icon: Icons.weekend, label: 'Lounge');
      default:
        return AmenityData(
          icon: Icons.check_circle_outline,
          label: amenity.length > 12 ? '${amenity.substring(0, 11)}…' : amenity,
        );
    }
  }
}
