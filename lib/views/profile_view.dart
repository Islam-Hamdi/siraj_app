import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? 'مستخدم سراج';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: SirajColors.beige50,
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            color: SirajColors.sirajBrown900,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: SirajColors.beige50,
        foregroundColor: SirajColors.sirajBrown900,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(user),
            
            const SizedBox(height: 24),
            
            // Stats Cards
            _buildStatsRow(),
            
            const SizedBox(height: 24),
            
            // Settings Section
            _buildSettingsSection(),
            
            const SizedBox(height: 24),
            
            // About Section
            _buildAboutSection(),
            
            const SizedBox(height: 24),
            
            // Sign Out Button
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SirajColors.sirajBrown700,
            SirajColors.sirajBrown900,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SirajColors.sirajBrown900.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: SirajColors.accentGold,
                child: Text(
                  _getInitials(user?.displayName ?? 'مستخدم سراج'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: SirajColors.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Name
          if (_isEditing)
            TextField(
              controller: _nameController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: SirajColors.accentGold),
                ),
              ),
            )
          else
            Text(
              user?.displayName ?? 'مستخدم سراج',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Email
          Text(
            user?.email ?? 'user@example.com',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Join Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'انضم في ${_formatDate(user?.metadata.creationTime)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.menu_book,
            title: 'الأجزاء المقروءة',
            value: '3',
            subtitle: 'من 30 جزء',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            title: 'الإنجازات',
            value: '5',
            subtitle: 'شارة مكتسبة',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            title: 'أيام متتالية',
            value: '12',
            subtitle: 'يوم نشط',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: SirajColors.sirajBrown900.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: SirajColors.accentGold,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: SirajColors.sirajBrown900,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: SirajColors.sirajBrown700,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: SirajColors.nude300,
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: SirajColors.sirajBrown900.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'الإعدادات',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: SirajColors.sirajBrown900,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'الإشعارات',
            subtitle: 'إدارة إشعارات الصلاة والتذكيرات',
            onTap: () => _showNotificationSettings(),
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'اللغة',
            subtitle: 'العربية',
            onTap: () => _showLanguageSettings(),
          ),
          _buildSettingItem(
            icon: Icons.dark_mode_outlined,
            title: 'المظهر',
            subtitle: 'فاتح',
            onTap: () => _showThemeSettings(),
          ),
          _buildSettingItem(
            icon: Icons.location_on_outlined,
            title: 'الموقع',
            subtitle: 'الدوحة، قطر',
            onTap: () => _showLocationSettings(),
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'الخصوصية',
            subtitle: 'إدارة بيانات الحساب',
            onTap: () => _showPrivacySettings(),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: SirajColors.accentGold,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: SirajColors.sirajBrown900,
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: SirajColors.sirajBrown700,
                ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: SirajColors.nude300,
            size: 16,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(
            color: SirajColors.beige100,
            height: 1,
            indent: 56,
          ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: SirajColors.sirajBrown900.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حول التطبيق',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: SirajColors.sirajBrown900,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildAboutItem('الإصدار', '1.0.0'),
          _buildAboutItem('المطور', 'فريق سراج'),
          _buildAboutItem('الدعم', 'support@siraj.app'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showFeedbackDialog(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SirajColors.accentGold,
                    side: const BorderSide(color: SirajColors.accentGold),
                  ),
                  child: const Text('إرسال ملاحظات'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showAboutDialog(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SirajColors.sirajBrown700,
                    side: const BorderSide(color: SirajColors.sirajBrown700),
                  ),
                  child: const Text('عن التطبيق'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: SirajColors.sirajBrown700,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: SirajColors.sirajBrown900,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showSignOutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: SirajColors.errorRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}';
    } else if (words.isNotEmpty) {
      return words[0][0];
    }
    return 'س';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveProfile() {
    // In a real app, this would update the user profile in Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الملف الشخصي')),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات الإشعارات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('إشعارات الصلاة'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('تذكيرات القراءة'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('إشعارات المجتمع'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: 'ar',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: 'ar',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('فاتح'),
              value: 'light',
              groupValue: 'light',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('داكن'),
              value: 'dark',
              groupValue: 'light',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('تلقائي'),
              value: 'auto',
              groupValue: 'light',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showLocationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات الموقع'),
        content: const Text('يتم استخدام موقعك لحساب أوقات الصلاة واتجاه القبلة بدقة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات الخصوصية'),
        content: const Text('نحن نحترم خصوصيتك ولا نشارك بياناتك مع أطراف ثالثة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرسال ملاحظات'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'شاركنا رأيك أو اقتراحاتك...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شكراً لك! تم إرسال ملاحظاتك')),
              );
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن سراج'),
        content: const Text(
          'سراج هو تطبيق روحاني مصمم لدعم المسلمين الجدد والمتعلمين في رحلتهم لفهم الإسلام. '
          'يوفر التطبيق مرشداً ذكياً ثلاثي الأبعاد، وأوقات الصلاة، وقراءة القرآن التفاعلية، والمزيد.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authServiceProvider).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SirajColors.errorRed,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

