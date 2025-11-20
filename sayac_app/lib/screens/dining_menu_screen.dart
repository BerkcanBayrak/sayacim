import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../models/dining_menu_model.dart';
import '../services/gemini_menu_service.dart';
import '../widgets/drawer_widget.dart';

class DiningMenuScreen extends StatefulWidget {
  const DiningMenuScreen({super.key});

  @override
  State<DiningMenuScreen> createState() => _DiningMenuScreenState();
}

class _DiningMenuScreenState extends State<DiningMenuScreen> {
  final GeminiMenuService _geminiService = GeminiMenuService();
  late SharedPreferences _prefs;
  List<DailyMenu> _menus = [];
  bool _isLoading = false;
  int _selectedDayIndex = 0;
  String _loadingStatus = 'PDF yükleniyor...';
  String? _lastUploadedFileName;

  @override
  void initState() {
    super.initState();
    _initializeApiKey();
    _loadMenus();
  }

  Future<void> _initializeApiKey() async {
    await _geminiService.loadApiKeyFromPreferences();
  }

  Future<void> _loadMenus() async {
    _prefs = await SharedPreferences.getInstance();
    final menusJson = _prefs.getString('menusData');
    if (menusJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(menusJson);
        setState(() {
          _menus = jsonList.map((json) => DailyMenu.fromJson(json)).toList();
          if (_menus.isNotEmpty) {
            _lastUploadedFileName = _prefs.getString('lastMenuFileName') ?? 'Yüklü Menü';
            _setTodayIndex();
          }
        });
      } catch (e) {
        print('Menü yükleme hatası: $e');
      }
    }
  }

  void _setTodayIndex() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    
    for (int i = 0; i < _menus.length; i++) {
      final menuDateOnly = DateTime(_menus[i].date.year, _menus[i].date.month, _menus[i].date.day);
      if (menuDateOnly == todayOnly) {
        _selectedDayIndex = i;
        return;
      }
    }
  }

  Future<void> _saveMenus() async {
    final menusJson = jsonEncode(_menus.map((m) => {
      'date': m.date.toIso8601String(),
      'totalCalories': m.totalCalories,
      'items': m.items.map((item) => {
        'name': item.name,
        'calories': item.calories,
        'type': item.type,
      }).toList(),
    }).toList());
    await _prefs.setString('menusData', menusJson);
    if (_lastUploadedFileName != null) {
      await _prefs.setString('lastMenuFileName', _lastUploadedFileName!);
    }
  }

  Future<void> _pickAndUploadPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
        _loadingStatus = 'PDF analiz ediliyor... (Biraz zaman alabilir)';
        _lastUploadedFileName = result.files.single.name;
      });
      
      try {
        File file = File(result.files.single.path!);
        final menus = await _geminiService.parseMenuFromPdf(file);
        
        setState(() {
          _menus = menus;
          _isLoading = false;
          _loadingStatus = '';
        });
        await _saveMenus();
      } catch (e) {
        setState(() {
          _isLoading = false;
          _loadingStatus = '';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${e.toString()}'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryColor = AppColors.primary;
    final textColor = isDark ? const Color(0xFFE0E0E0) : const Color(0xFF112117);
    final secondaryText = isDark ? const Color(0xFF888888) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: textColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Yemek Menüsü',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: _showApiKeyDialog,
            tooltip: 'Gemini API Ayarları',
          ),
          if (_menus.isNotEmpty)
            IconButton(
              icon: Icon(Icons.refresh, color: textColor),
              onPressed: _showClearConfirmDialog,
            )
        ],
      ),
      body: SafeArea(
        child: _isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                Text(
                  _loadingStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ],
            ),
          )
        : _menus.isEmpty 
          ? _buildEmptyState(isDark, primaryColor, textColor, secondaryText)
          : _buildMenuContent(isDark, cardColor, textColor, secondaryText, primaryColor),
      ),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: const Text('Menüyü Sıfırla?'),
          content: const Text('Yüklü menüyü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _menus = [];
                  _selectedDayIndex = 0;
                  _lastUploadedFileName = null;
                });
                await _prefs.remove('menusData');
                await _prefs.remove('lastMenuFileName');
                Navigator.pop(context);
              },
              child: const Text('Sıfırla', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showApiKeyDialog() {
    final TextEditingController apiKeyController = TextEditingController(
      text: _geminiService.getCurrentApiKey(),
    );

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? const Color(0xFFE0E0E0) : const Color(0xFF112117);

        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            'Gemini API Anahtarı',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API anahtarını aşağıya girin. Bu veriler cihazda şifreli olarak saklanacaktır.',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'AIza...',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFFCCCCCC)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA),
                ),
                style: TextStyle(color: textColor),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final apiKey = apiKeyController.text.trim();
                if (apiKey.isNotEmpty) {
                  await _geminiService.saveApiKeyToPreferences(apiKey);
                  await _geminiService.loadApiKeyFromPreferences();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ API anahtarı başarıyla kaydedildi!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Lütfen API anahtarı girin'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Kaydet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, Color primary, Color textColor, Color secondaryText) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: 120,
              height: 150,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF212121) : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for(int i=0; i<3; i++)
                  Container(
                    height: 4, 
                    width: 60, 
                    color: isDark ? const Color(0xFF3D3D3D) : Colors.grey[500], 
                    margin: const EdgeInsets.symmetric(vertical: 4)
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Menü Bulunamadı",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            "Günlük yemekleri görmek için menü PDF'ini yükleyin",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: secondaryText),
          ),
          if (_lastUploadedFileName != null) ...[
            const SizedBox(height: 16),
            Text(
              "Son yüklenen: $_lastUploadedFileName",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: secondaryText, fontStyle: FontStyle.italic),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _pickAndUploadPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text("PDF Yükle", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMenuContent(bool isDark, Color cardColor, Color textColor, Color secondaryText, Color primary) {
    final currentMenu = _menus[_selectedDayIndex];

    return Column(
      children: [
        Container(
          height: 85,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _menus.length,
            itemBuilder: (context, index) {
              final menu = _menus[index];
              final isSelected = index == _selectedDayIndex;
              final dayName = DateFormat('EEE').format(menu.date);
              final dayNum = menu.date.day.toString();

              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  width: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primary : cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dayName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : secondaryText)),
                      const SizedBox(height: 4),
                      Text(dayNum, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : textColor)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
            children: [
              if (currentMenu.breakfast.isNotEmpty) ...[
                _buildSectionHeader("Kahvaltı", textColor),
                ...currentMenu.breakfast.map((m) => _buildMealCard(m, cardColor, textColor, secondaryText, primary)),
              ],
              if (currentMenu.lunch.isNotEmpty) ...[
                _buildSectionHeader("Öğle Yemeği", textColor),
                ...currentMenu.lunch.map((m) => _buildMealCard(m, cardColor, textColor, secondaryText, primary)),
              ],
              if (currentMenu.dinner.isNotEmpty) ...[
                _buildSectionHeader("Akşam Yemeği", textColor),
                ...currentMenu.dinner.map((m) => _buildMealCard(m, cardColor, textColor, secondaryText, primary)),
              ],
              if (currentMenu.totalCalories > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Günlük Toplam Kalori", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                        Text("${currentMenu.totalCalories} kcal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildMealCard(MealItem item, Color cardColor, Color textColor, Color secondaryText, Color primary) {
    IconData icon;
    if (item.type == 'Breakfast') icon = Icons.bakery_dining;
    else if (item.type == 'Lunch') icon = Icons.soup_kitchen;
    else icon = Icons.dinner_dining;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(20)),
            child: Text(item.calories, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: secondaryText)),
          ),
        ],
      ),
    );
  }
}
