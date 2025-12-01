import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                TyperAnimatedText(
                  "Explorez",
                  speed: Duration(milliseconds: 150),
                  textStyle: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                TyperAnimatedText(
                  "Votre",
                  speed: Duration(milliseconds: 150),
                  textStyle: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                TyperAnimatedText(
                  "Ville",
                  speed: Duration(milliseconds: 150),
                  textStyle: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
              pause: Duration(milliseconds: 100),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
            ElevatedButton.icon(
              onPressed: null,
              icon: Icon(Icons.start),
              label: Text("Commencez"),
            ),
          ],
        ),
      ),
    );
  }
}
