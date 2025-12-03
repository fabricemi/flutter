import 'package:explorez_votre_ville/models/meteo.dart';
import 'package:flutter/material.dart';

class ShowMeteo extends StatelessWidget {
  final Meteo meteo;
  const ShowMeteo({super.key, required this.meteo});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  meteo.city,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      "https://openweathermap.org/img/wn/${meteo.tempCarData.icon}@2x.png",
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${meteo.tempNumData.temp}°C",
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Divider(),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.teal.shade50,
          child: Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud, color: Colors.teal, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Météo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      meteo.tempCarData.description,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.thermostat, color: Colors.teal, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Min / Max",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "${meteo.tempNumData.tempMin}° / ${meteo.tempNumData.tempMax}°",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.teal, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Humidité",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "${meteo.tempNumData.humidity}%",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.air, color: Colors.teal, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Pression",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "${meteo.tempNumData.pressure} hPa",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
