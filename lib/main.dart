import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
          seedColor: const Color(0xFF00FFCC), // CapCut जैसा नियॉन थीम
          brightness: Brightness.dark,       // CapCut की तरह डार्क मोड
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
  final ImagePicker _picker = ImagePicker();

  // गैलरी से फोटो या वीडियो चुनने का फंक्शन
  Future<void> _pickMedia() async {
    final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
    if (media != null) {
      setState(() {
        _selectedImage = File(media.path);
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
            onPressed: () {}, // यहाँ प्रीमियम सब्स्क्रिप्शन पेज आएगा
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
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_selectedImage!, fit: BoxFit.contain),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_camera_back_outlined, size: 64, color: Color(0xFF00FFCC)),
                        SizedBox(height: 12),
                        Text('अपनी फोटो या वीडियो अपलोड करें', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // --- एड्स के लिए खाली जगह (Google AdMob Banner) ---
            Container(
              height: 60,
              color: Colors.grey[850],
              alignment: Alignment.center,
              child: const Text('Google AdMob Banner Area', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 24),

            // --- CapCut जैसे वीडियो/फोटो एडिटिंग फीचर्स ---
            FilledButton.icon(
              onPressed: _pickMedia,
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
              onPressed: () {}, // AI बैकग्राउंड रिमूवल
              icon: const Icon(Icons.layers_clear),
              label: const Text('AI Cutout (Remove BG)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {}, // AI इमेज और वीडियो एन्हांसर
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI Enhance (Clear Media)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {}, // वीडियो ट्रिम / क्रॉप
                    icon: const Icon(Icons.content_cut),
                    label: const Text('Trim / Crop'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {}, // ऑटो कैप्शन्स
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
