import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  // Hugging Face की फ्री API Key (यहाँ आप अपनी की भी डाल सकते हैं)
  // अभी के लिए हम एक पब्लिक मॉडल का इस्तेमाल कर रहे हैं
  final String _hfToken = "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"; // डमी टोकन, यहाँ आपकी असली की आएगी

  Future<void> _pickMedia() async {
    final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
    if (media != null) {
      setState(() {
        _selectedImage = File(media.path);
        _processedImage = null;
        _statusText = 'फोटो अपलोड हो गई है!';
      });
    }
  }

  // असली AI प्रोसेसिंग फंक्शन
  Future<void> _processImageWithAI(String mode) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया पहले कोई फोटो अपलोड करें!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusText = mode == 'enhance' ? 'AI फोटो क्लियर कर रहा है...' : 'AI बैकग्राउंड हटा रहा है...';
    });

    try {
      // mode के हिसाब से अलग-अलग AI मॉडल का लिंक
      String modelUrl = mode == 'enhance' 
          ? 'https://api-inference.huggingface.co/models/TencentARC/GFPGAN' // फोटो क्लियर करने का बेस्ट मॉडल
          : 'https://api-inference.huggingface.co/models/briaai/RMBG-1.4'; // बैकग्राउंड हटाने का बेस्ट मॉडल

      Uint8List imageBytes = await _selectedImage!.readAsBytes();

      var response = await http.post(
        Uri.parse(modelUrl),
        headers: {
          'Authorization': 'Bearer $_hfToken',
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      );

      if (response.statusCode == 200) {
        // AI द्वारा एडिट की गई नई इमेज को सेव करना
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/ai_output_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _isLoading = false;
          _processedImage = file;
          _statusText = mode == 'enhance' ? 'फोटो सफलतापूर्वक साफ़ हो गई!' : 'बैकग्राउंड सफलतापूर्वक हट गया!';
        });
      } else {
        // अगर API लोड ले रही हो या टोकन एरर हो
        throw Exception('सर्वर रिस्पॉन्स कोड: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusText = 'अभी सर्वर बिजी है। कृपया 10 सेकंड बाद दोबारा प्रयास करें!';
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
            Container(
              height: 60,
              color: Colors.grey[850],
              alignment: Alignment.center,
              child: const Text('Google AdMob Banner Area', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 24),
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
