import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dining_menu_model.dart';

class GeminiMenuService {
  GenerativeModel? _model;
  late String _apiKey;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  GeminiMenuService() {
    _apiKey = '';
    _model = null;
  }

  void _initializeModel() {
    if (_apiKey.isEmpty) {
      _model = null;
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  // SharedPreferences'ten API key'i yükle
  Future<void> loadApiKeyFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString('geminiApiKey');
    if (savedKey != null && savedKey.isNotEmpty) {
      _apiKey = savedKey;
      _initializeModel();
    }
  }

  // API key'i SharedPreferences'e kaydet
  Future<void> saveApiKeyToPreferences(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('geminiApiKey', apiKey);
    _apiKey = apiKey;
    _initializeModel();
  }

  // Mevcut API key'i getir
  String getCurrentApiKey() => _apiKey;

  Future<List<DailyMenu>> parseMenuFromPdf(File pdfFile) async {
    try {
      print('🔍 [GeminiMenuService] parseMenuFromPdf başladı');
      print('🔑 API Key var mı? ${_apiKey.isNotEmpty}');
      print('📱 Model initialized? ${_model != null}');
      
      if (_apiKey.isEmpty || _model == null) {
        final errorMsg = 'Lütfen önce Gemini API anahtarını ayarlar bölümünden giriniz.';
        print('❌ [GeminiMenuService] $errorMsg');
        throw Exception(errorMsg);
      }

      final fileSize = await pdfFile.length();
      print('📄 PDF dosya boyutu: ${fileSize} bytes');

      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          print('🔄 [GeminiMenuService] Deneme $attempt/$_maxRetries');
          
          final bytes = await pdfFile.readAsBytes();
          print('✅ [GeminiMenuService] PDF bytes okundu: ${bytes.length} bytes');
          
          final prompt = Content.multi([
            TextPart('''
              Sen bir veri ayrıştırma asistanısın. Ekli PDF dosyasındaki yemek menüsünü analiz et.
              
              Aşağıdaki JSON formatında bir liste döndür. Her bir gün için bir obje oluştur:
              [
                {
                  "date": "2024-11-20", (ISO 8601 formatı)
                  "totalCalories": 2230, (Tam sayı)
                  "items": [
                    {
                      "name": "Yemek adı",
                      "calories": "350 kcal",
                      "type": "Breakfast" (veya "Lunch" veya "Dinner")
                    }
                  ]
                }
              ]
              
              Sadece JSON döndür, başka metin ekleme.
            '''),
            DataPart('application/pdf', bytes),
          ]);

          print('🚀 [GeminiMenuService] Gemini API çağrılıyor...');
          print('🚀 API Key length: ${_apiKey.length}');
          
          final response = await _model!.generateContent([prompt]);
          
          print('📥 [GeminiMenuService] API yanıt aldı');
          print('📝 Response candidates: ${response.candidates.length}');
          print('📝 Response text null mu? ${response.text == null}');
          if (response.candidates.isNotEmpty) {
            print('📝 Response finish reason: ${response.candidates.first.finishReason}');
          }
          
          if (response.text == null || response.text!.isEmpty) {
            print('⚠️ [GeminiMenuService] Boş yanıt, dizi döndürülüyor');
            return [];
          }

          print('🔧 [GeminiMenuService] JSON parse ediliyor...');
          final textLength = response.text!.length;
          final previewLength = textLength > 200 ? 200 : textLength;
          print('📄 Response: ${response.text!.substring(0, previewLength)}...');
          
          final List<dynamic> jsonList = jsonDecode(response.text!);
          print('✅ [GeminiMenuService] JSON başarıyla parse edildi: ${jsonList.length} gün');
          
          final result = jsonList.map((json) => DailyMenu.fromJson(json)).toList();
          print('✅ [GeminiMenuService] Menüler başarıyla dönüştürüldü: ${result.length} gün');
          return result;

        } on GenerativeAIException catch (e) {
          print('❌ [GeminiMenuService] GenerativeAI Hatası (Deneme $attempt/$_maxRetries)');
          print('📋 Hata Detayı: $e');
          print('📋 Hata Mesajı: ${e.message}');
          
          // 503 hatasıysa retry yap
          if (e.toString().contains('503') && attempt < _maxRetries) {
            print('🔄 [GeminiMenuService] 503 hatası, ${_retryDelay.inSeconds * attempt} saniye sonra tekrar denenir...');
            await Future.delayed(_retryDelay * attempt);
            continue;
          }
          
          // Son denemeseyse veya retry edilemeyen bir hata
          if (attempt == _maxRetries) {
            if (e.toString().contains('503')) {
              throw Exception('Gemini servisi şu anda meşgul. Lütfen birkaç saniye sonra tekrar deneyin.');
            }
            throw Exception('Menü analiz edilirken hata oluştu: ${e.message}');
          }
        } catch (e, stackTrace) {
          print('❌ [GeminiMenuService] Beklenmedik Hata (Deneme $attempt/$_maxRetries)');
          print('📋 Hata: $e');
          print('📍 Stack Trace: $stackTrace');
          
          if (attempt == _maxRetries) {
            throw Exception('Menü analiz edilirken beklenmedik bir hata oluştu: $e');
          }
          
          print('🔄 [GeminiMenuService] ${_retryDelay.inSeconds * attempt} saniye sonra tekrar denenir...');
          await Future.delayed(_retryDelay * attempt);
        }
      }
      
      throw Exception('Menü analiz edilirken hata oluştu.');
    } catch (e, stackTrace) {
      print('❌ [GeminiMenuService] Kritik Hata');
      print('📋 Hata: $e');
      print('📍 Stack Trace: $stackTrace');
      rethrow;
    }
  }
}
