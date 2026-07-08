import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart'; // Handles unlimited real-time conversions

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DynamicVoiceTranslator(),
  ));
}

class DynamicVoiceTranslator extends StatefulWidget {
  const DynamicVoiceTranslator({Key? key}) : super(key: key);

  @override
  _DynamicVoiceTranslatorState createState() => _DynamicVoiceTranslatorState();
}

class _DynamicVoiceTranslatorState extends State<DynamicVoiceTranslator> {
  late stt.SpeechToText _speechEngine;
  final GoogleTranslator _translatorEngine = GoogleTranslator();
  final FlutterTts _audioEngine = FlutterTts();

  bool _isListening = false;
  String _spokenWords = "Tap the mic and speak naturally...";
  String _translatedResult = "Your live translation will appear here...";
  
  // Mapping display languages to ISO-639-1 language codes
  String _targetLanguageName = 'Telugu';
  final Map<String, String> _langCodes = {
    'Telugu': 'te',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Kannada': 'kn',
    'Malayalam': 'ml',
    'Spanish': 'es',
    'French': 'fr'
  };
@override
  void initState() {
    super.initState();
    _speechEngine = stt.SpeechToText();
    
    // Explicitly initialize the audio engine for web browsers
    _audioEngine.setSharedInstance(true).then((_) {
      print("Audio engine initialized successfully.");
    });
  }
  

  // Activates the microphone and streams the voice capture
  void _toggleListeningStream() async {
    if (!_isListening) {
      bool working = await _speechEngine.initialize(
        onStatus: (status) => print('Microphone status: $status'),
        onError: (err) => print('Microphone error: $err'),
      );
      
      if (working) {
        setState(() => _isListening = true);
        _speechEngine.listen(
          onResult: (result) {
            setState(() {
              _spokenWords = result.recognizedWords;
            });
            // Fires an automated background API call as you speak words
            if (result.finalResult || result.recognizedWords.isNotEmpty) {
              _executeLiveTranslation(result.recognizedWords);
            }
          },
        );
      } else {
        setState(() => _spokenWords = "Mic permissions denied or unsupported by browser.");
      }
    } else {
      setState(() => _isListening = false);
      _speechEngine.stop();
    }
  }

  // Performs live calculations via the translator engine
  void _executeLiveTranslation(String textToTranslate) async {
    if (textToTranslate.isEmpty) return;
    
    String targetCode = _langCodes[_targetLanguageName] ?? 'te';
    
    try {
      var translation = await _translatorEngine.translate(
        textToTranslate, 
        to: targetCode
      );
      setState(() {
        _translatedResult = translation.text;
      });
    } catch (e) {
      setState(() {
        _translatedResult = "Translation service processing error. Try again.";
      });
    }
  }

  // Vocalizes the response text aloud
  void _playVocalAudio() async {
    String targetCode = _langCodes[_targetLanguageName] ?? 'te';
    
    // Explicitly map speech engine region tags for web components
    String localeValue = "${targetCode}-IN";
    if (targetCode == 'es') localeValue = 'es-ES';
    if (targetCode == 'fr') localeValue = 'fr-FR';

    try {
      // Direct sequential activation sequence to wake up web sound cards
      await _audioEngine.stop(); 
      await _audioEngine.setLanguage(localeValue);
      await _audioEngine.setVolume(1.0);
      await _audioEngine.setSpeechRate(0.45); // Slightly relaxed pace for clarity
      
      if (_translatedResult.isNotEmpty && 
          !_translatedResult.contains("Your live translation will appear here")) {
        // Remove any diagnostic text or parenthesis notes if translating long text
        String cleanSpeechText = _translatedResult.split('(')[0].trim();
        await _audioEngine.speak(cleanSpeechText);
        print("Speaking output text: $cleanSpeechText");
      }
    } catch (e) {
      print("Web audio engine synthesis mismatch: $e");
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: const Text('Live Voice Translator Pro'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Target selector header card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Translate To:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _targetLanguageName,
                      underline: const SizedBox(),
                      items: _langCodes.keys.map((String keyName) {
                        return DropdownMenuItem<String>(
                          value: keyName,
                          child: Text(keyName, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                          
                        );
                      }).toList(),
                      onChanged: (selectedVal) {
                        setState(() {
                          _targetLanguageName = selectedVal!;
                        });
                        if (_spokenWords != "Tap the mic and speak naturally...") {
                          _executeLiveTranslation(_spokenWords);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Captured Audio Box Container
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DETECTED ENGLISH VOICE INPUT:", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(_spokenWords, style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.4)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic Output Response UI Card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${_targetLanguageName.toUpperCase()} TRANSLATION:", style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.blueAccent, size: 28),
                          onPressed: _playVocalAudio,
                        )
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(_translatedResult, style: const TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold, height: 1.3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Microphone Interaction Node Action Trigger
            GestureDetector(
              onTap: _toggleListeningStream,
              child: CircleAvatar(
                radius: 42,
                backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent,
                child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isListening ? "Streaming voice data... Tap to lock text" : "Tap Microphone to Speak", 
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)
            ),
          ],
        ),
      ),
    );
  }
}