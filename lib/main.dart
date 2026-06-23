import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const IndiCutAI());
}

class IndiCutAI extends StatelessWidget {
  const IndiCutAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IndiCut AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FFCC),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  File? _processedImage;
  bool _isLoading = false;
  String _statusText = 'अपनी फोटो या वीडियो अपलोड करें';
  final ImagePicker _picker = ImagePicker();

  // गैलरी से फोटो चुनने का फंक्शन
  Future<void> _pickMedia() async {
    final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
    if (media != null) {
      setState(() {
        _selectedImage = File(media.path);
        _processedImage = null; // नई फोटो चुनने पर पुराना रिजल्ट क्लियर करें
        _statusText = 'फोटो अपलोड हो गई है!';
      });
    }
  }

  // AI बैकएंड को कनेक्ट करने का मेन फंक्शन (Enhance & Cutout दोनों के लिए)
  Future<void> _processImageWithAI(String mode) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया पहले कोई फोटो अपलोड करें!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusText = mode == 'enhance' ? 'AI आपकी फोटो को साफ़ कर रहा है...' : 'AI बैकग्राउंड हटा रहा है...';
    });

    try {
      // यहाँ हम बैकएंड API का ढांचा तैयार कर रहे हैं
      // भविष्य में यहाँ अपनी लाइव API URL डालेंगे
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://httpbin.org/post'), // अभी टेस्टिंग के लिए डमी URL है
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
      request.fields['mode'] = mode;

      var response = await request.send();

      if (response.statusCode == 200) {
        // टेस्टिंग के लिए हम अभी डमी सक्सेस दिखा रहे हैं
        // जब आपकी असली API लिंक यहाँ लगेगी, तो वो एडिटेड इमेज वापस भेजेगी
        await Future.delayed(const Duration(seconds: 3)); // लाइव फील के लिए डिले
        
        setState(() {
          _isLoading = false;
          _processedImage = _selectedImage; // अभी प्रिव्यू के लिए वही फोटो दिखा रहे हैं
          _statusText = mode == 'enhance' ? 'फोटो सफलतापूर्वक साफ़ हो गई!' : 'बैकग्राउंड सफलतापूर्वक हट गया!';
        });
      } else {
        throw Exception('बिल्ड सर्वर एरर');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusText = 'गड़बड़ हुई! कृपया दोबारा प्रयास करें।';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'INDICUT AI',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Colors.amber),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- प्रिव्यू स्क्रीन ---
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: _isLoading
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF00FFCC)),
                        SizedBox(height: 16),
                        Text('AI जादू कर रहा है...', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : (_processedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_processedImage!, fit: BoxFit.contain),
                        )
                      : (_selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_selectedImage!, fit: BoxFit.contain),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.video_camera_back_outlined, size: 64, color: Color(0xFF00FFCC)),
                                const SizedBox(height: 12),
                                Text(_statusText, style: const TextStyle(color: Colors.grey)),
                              ],
                            ))),
            ),
            const SizedBox(height: 12),
            if (!_isLoading)
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 24),

            // --- एड्स एरिया ---
            Container(
              height: 60,
              color: Colors.grey[850],
              alignment: Alignment.center,
              child: const Text('Google AdMob Banner Area', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 24),

            // --- फीचर्स बटन्स ---
            FilledButton.icon(
              onPressed: _isLoading ? null : _pickMedia,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Upload Media (Photo/Video)'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00FFCC),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _processImageWithAI('cutout'),
              icon: const Icon(Icons.layers_clear),
              label: const Text('AI Cutout (Remove BG)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _processImageWithAI('enhance'),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI Enhance (Clear Media)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.content_cut),
                    label: const Text('Trim / Crop'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.closed_caption),
                    label: const Text('AI Caption'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ],
            ),
          ],
         ),
      ),
    );
  }
}
