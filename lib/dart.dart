import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Audio package

class FlashcardWidget extends StatefulWidget {
  final String original;
  final String translation;

  const FlashcardWidget({
    Key? key,
    required this.original,
    required this.translation,
  }) : super(key: key);

  @override
  _FlashcardWidgetState createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _showFront = true;
  final FlutterTts _flutterTts = FlutterTts();

  void _speak() async {
    // Speaks the original language word aloud
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(widget.original);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFront = !_showFront; // This triggers the card flip!
        });
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 320,
          height: 400,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          color:Colors.white,
         
          child: _showFront 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      widget.original,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue, size: 30),
                      onPressed: () {
                        // Prevent card flipping when pressing the audio button itself
                        _speak();
                      },
                    ),
                    const Spacer(),
                    const Text("Tap to reveal translation", style: TextStyle(color: Colors.grey)),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      widget.translation,
                      style: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Text("Tap to view original", style: TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }
}