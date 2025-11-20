import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../core/constants/app_colors.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'account_settings_screen.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _examReminders = true;
  String _targetGPA = '3.8';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF112117) : const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: (isDark ? const Color(0xFF112117) : const Color(0xFFF6F8F6)).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.grey[200] : Colors.grey[800]),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.grey[200] : Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          SizedBox(width: 48) // Placeholder for symmetry
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Profile Header
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    child: userProvider.userProfile.profileImagePath != null
                        ? ClipOval(
                            child: Image.file(
                              File(userProvider.userProfile.profileImagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 80,
                            color: AppColors.primary,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.userProfile.name.isEmpty ? 'Adı Giriniz' : userProvider.userProfile.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[200] : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userProvider.userProfile.email.isEmpty ? 'Email Giriniz' : userProvider.userProfile.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // General Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'GENERAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2C22) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Dark Mode Toggle
                  _buildSettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    isDark: isDark,
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.setDarkMode(value);
                      },
                      activeColor: AppColors.primary,
                    ),
                    showBorder: true,
                  ),
                  // Target GPA
                  _buildSettingsTile(
                    icon: Icons.track_changes,
                    title: 'Target GPA',
                    isDark: isDark,
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: TextEditingController(text: _targetGPA),
                        onChanged: (value) => _targetGPA = value,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'e.g., 3.8',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.grey[200] : Colors.grey[800],
                        ),
                      ),
                    ),
                    showBorder: true,
                  ),
                  // Account Settings
                  _buildSettingsTile(
                    icon: Icons.account_circle,
                    title: 'Account Settings',
                    isDark: isDark,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    showBorder: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Notifications Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'NOTIFICATIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2C22) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Push Notifications
                  _buildSettingsTile(
                    icon: Icons.notifications,
                    title: 'Push Notifications',
                    isDark: isDark,
                    trailing: Switch(
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() => _pushNotifications = value);
                        if (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bildirimler Açıldı! Artık sınav hatırlatmaları alacaksınız.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                    showBorder: true,
                  ),
                  // Exam Reminders
                  _buildSettingsTile(
                    icon: Icons.school,
                    title: 'Exam Reminders',
                    isDark: isDark,
                    trailing: Switch(
                      value: _examReminders,
                      onChanged: (value) {
                        setState(() => _examReminders = value);
                      },
                      activeColor: AppColors.primary,
                    ),
                    showBorder: false,
                  ),
                ],
              ),
            ),

            // About Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'ABOUT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2C22) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Version
                  _buildSettingsTile(
                    icon: Icons.info,
                    title: 'Version',
                    isDark: isDark,
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    showBorder: true,
                  ),
                  // Privacy Policy
                  _buildSettingsTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    isDark: isDark,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    showBorder: true,
                    onTap: () {
                      _showPrivacyPolicyDialog(isDark);
                    },
                  ),
                  // Terms of Service
                  _buildSettingsTile(
                    icon: Icons.gavel,
                    title: 'Terms of Service',
                    isDark: isDark,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    showBorder: false,
                    onTap: () {
                      _showTermsOfServiceDialog(isDark);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required Widget trailing,
    required bool showBorder,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2C22) : Colors.white,
        title: Text(
          'Gizlilik Politikası',
          style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
        ),
        content: SingleChildScrollView(
          child: Text(
            '''Son Güncelleme: 20 Kasım 2025

"Not Takip" ("biz", "bizim" veya "uygulama") olarak, gizliliğinize önem veriyoruz. Bu Gizlilik Politikası, uygulamamızı kullandığınızda bilgilerinizin nasıl toplandığını, kullanıldığını ve saklandığını açıklar.

1. Toplanan Bilgiler

Uygulamamız tamamen çevrimdışı (offline) çalışmaktadır.

Kişisel Veriler: Adınız, ders notlarınız, sınav tarihleriniz ve hedef ortalamalarınız gibi girdiğiniz tüm veriler sadece kendi cihazınızda saklanır.

Sunucu İletişimi: Bu veriler hiçbir şekilde harici bir sunucuya, bulut depolama alanına veya üçüncü taraf hizmetlere gönderilmez.

2. Verilerin Saklanması

Uygulama içerisine kaydettiğiniz dersler ve notlar, cihazınızın yerel veritabanında (SQLite) tutulur. Uygulamayı sildiğinizde veya cihazınızı sıfırladığınızda bu veriler silinebilir. Veri güvenliği ve yedeklemesi tamamen kullanıcının sorumluluğundadır.

3. Üçüncü Taraf Hizmetler

Uygulamamız şu an için herhangi bir reklam ağı, analiz aracı (Google Analytics vb.) veya üçüncü taraf takip yazılımı kullanmamaktadır.

4. İzinler

Uygulama, çalışabilmek için cihazınızda aşağıdaki izinlere ihtiyaç duyabilir:

Depolama/Veri Yazma: Veritabanını cihazınızda oluşturmak ve kaydetmek için.

Bildirimler: (Eğer aktifse) Sınav hatırlatmaları gönderebilmek için.

5. Çocukların Gizliliği

Uygulamamız genel kullanıma uygundur ve çocuklardan bilerek herhangi bir kişisel veri toplamaz (zaten veri toplamıyoruz).

6. Değişiklikler

Bu gizlilik politikasını zaman zaman güncelleyebiliriz. Değişiklikler yapıldığında uygulama üzerinden bilgilendirme yapılacaktır.

7. İletişim

Gizlilik politikamızla ilgili sorularınız varsa, lütfen b.bayrak26@hotmail.com adresi üzerinden bizimle iletişime geçin.''',
            style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfServiceDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2C22) : Colors.white,
        title: Text(
          'Kullanım Koşulları',
          style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
        ),
        content: SingleChildScrollView(
          child: Text(
            '''Son Güncelleme: 20 Kasım 2025

Lütfen "Not Takip" uygulamasını kullanmadan önce bu Kullanım Koşullarını dikkatlice okuyun.

1. Kabul

Uygulamayı indirerek veya kullanarak, bu koşulları kabul etmiş sayılırsınız. Eğer bu koşulları kabul etmiyorsanız, lütfen uygulamayı kullanmayın.

2. Hizmetin Kapsamı

"Not Takip", öğrencilerin derslerini takip etmesi ve ortalama hesaplaması için yardımcı bir araç olarak tasarlanmıştır.

3. Sorumluluk Reddi (Önemli)

Hesaplama Hataları: Uygulama, notlarınızı ve ortalamalarınızı hesaplamak için standart algoritmalar kullanır. Ancak, üniversitenizin hesaplama sistemi veya yuvarlama kuralları farklılık gösterebilir. Bu nedenle, resmi not dökümünüz (transkript) ile uygulama sonuçları arasında oluşabilecek farklardan tarafımız sorumlu tutulamaz.

Veri Kaybı: Verileriniz cihazınızda yerel olarak saklanır. Cihaz arızası, uygulamanın silinmesi veya güncellemeler sırasında oluşabilecek veri kayıplarından kullanıcı sorumludur.

4. Kullanıcı Sorumlulukları

Uygulamayı yasalara uygun şekilde kullanmayı ve uygulamanın güvenliğini tehdit edecek (tersine mühendislik vb.) faaliyetlerde bulunmamayı kabul edersiniz.

5. Fikri Mülkiyet

Uygulamanın tasarımı, kodları, logosu ve içeriği Berkcan Bayrak'a aittir ve izinsiz kopyalanamaz.

6. Değişiklikler

Kullanım koşullarını dilediğimiz zaman değiştirme hakkımız saklıdır. Uygulamayı kullanmaya devam etmeniz, yeni koşulları kabul ettiğiniz anlamına gelir.

7. İletişim

Sorularınız ve geri bildirimleriniz için: b.bayrak26@hotmail.com''',
            style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
