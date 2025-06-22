import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../theme/colors.dart';

class CompassView extends ConsumerStatefulWidget {
  const CompassView({super.key});

  @override
  ConsumerState<CompassView> createState() => _CompassViewState();
}

class _CompassViewState extends ConsumerState<CompassView> {
  double? _heading;
  Position? _currentPosition;
  double? _qiblaDirection;
  bool _isLoading = true;
  String? _errorMessage;

  // Kaaba coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
  }

  Future<void> _initializeCompass() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'يرجى السماح بالوصول إلى الموقع لتحديد اتجاه القبلة';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'تم رفض إذن الموقع نهائياً. يرجى تفعيله من الإعدادات';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate Qibla direction
      _qiblaDirection = _calculateQiblaDirection(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // Listen to compass
      FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted) {
          setState(() {
            _heading = event.heading;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحديد الموقع: $e';
        _isLoading = false;
      });
    }
  }

  double _calculateQiblaDirection(double lat, double lng) {
    // Convert degrees to radians
    double latRad = lat * (math.pi / 180);
    double lngRad = lng * (math.pi / 180);
    double kaabaLatRad = kaabaLatitude * (math.pi / 180);
    double kaabaLngRad = kaabaLongitude * (math.pi / 180);

    // Calculate the difference in longitude
    double dLng = kaabaLngRad - lngRad;

    // Calculate the bearing
    double y = math.sin(dLng) * math.cos(kaabaLatRad);
    double x = math.cos(latRad) * math.sin(kaabaLatRad) -
        math.sin(latRad) * math.cos(kaabaLatRad) * math.cos(dLng);

    double bearing = math.atan2(y, x);

    // Convert from radians to degrees
    bearing = bearing * (180 / math.pi);

    // Normalize to 0-360 degrees
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SirajColors.beige50,
      appBar: AppBar(
        title: const Text(
          'بوصلة القبلة',
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _initializeCompass();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SirajColors.accentGold),
                  ),
                  SizedBox(height: 16),
                  Text('جاري تحديد الموقع واتجاه القبلة...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: SirajColors.errorRed,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _initializeCompass();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SirajColors.accentGold,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Location Info Card
                      _buildLocationCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Compass
                      _buildCompass(),
                      
                      const SizedBox(height: 24),
                      
                      // Prayer Times Card
                      _buildPrayerTimesCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Instructions Card
                      _buildInstructionsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: SirajColors.accentGold,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'موقعك الحالي',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: SirajColors.sirajBrown900,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_currentPosition != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'خط العرض:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: SirajColors.sirajBrown700,
                      ),
                ),
                Text(
                  '${_currentPosition!.latitude.toStringAsFixed(4)}°',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: SirajColors.sirajBrown900,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'خط الطول:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: SirajColors.sirajBrown700,
                      ),
                ),
                Text(
                  '${_currentPosition!.longitude.toStringAsFixed(4)}°',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: SirajColors.sirajBrown900,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'اتجاه القبلة:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: SirajColors.sirajBrown700,
                      ),
                ),
                Text(
                  '${_qiblaDirection?.toStringAsFixed(1)}°',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: SirajColors.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'بوصلة القبلة',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: SirajColors.sirajBrown900,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          
          // Compass Widget
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compass Background
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        SirajColors.beige50,
                        SirajColors.beige100,
                      ],
                    ),
                    border: Border.all(
                      color: SirajColors.accentGold,
                      width: 3,
                    ),
                  ),
                ),
                
                // Compass Markings
                ...List.generate(36, (index) {
                  final angle = index * 10.0;
                  final isMainDirection = angle % 90 == 0;
                  final isSecondaryDirection = angle % 30 == 0;
                  
                  return Transform.rotate(
                    angle: angle * (math.pi / 180),
                    child: Container(
                      width: 2,
                      height: isMainDirection ? 30 : isSecondaryDirection ? 20 : 15,
                      margin: EdgeInsets.only(top: isMainDirection ? 10 : isSecondaryDirection ? 15 : 20),
                      decoration: BoxDecoration(
                        color: isMainDirection ? SirajColors.sirajBrown900 : SirajColors.sirajBrown700,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                }),
                
                // Direction Labels
                const Positioned(
                  top: 20,
                  child: Text('ش', style: TextStyle(color: SirajColors.sirajBrown900, fontWeight: FontWeight.bold)),
                ),
                const Positioned(
                  right: 20,
                  child: Text('ق', style: TextStyle(color: SirajColors.sirajBrown900, fontWeight: FontWeight.bold)),
                ),
                const Positioned(
                  bottom: 20,
                  child: Text('ج', style: TextStyle(color: SirajColors.sirajBrown900, fontWeight: FontWeight.bold)),
                ),
                const Positioned(
                  left: 20,
                  child: Text('غ', style: TextStyle(color: SirajColors.sirajBrown900, fontWeight: FontWeight.bold)),
                ),
                
                // Qibla Direction Indicator
                if (_qiblaDirection != null && _heading != null)
                  Transform.rotate(
                    angle: (_qiblaDirection! - _heading!) * (math.pi / 180),
                    child: Container(
                      width: 4,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 120),
                      decoration: BoxDecoration(
                        color: SirajColors.accentGold,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: SirajColors.accentGold.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Kaaba Icon
                if (_qiblaDirection != null && _heading != null)
                  Transform.rotate(
                    angle: (_qiblaDirection! - _heading!) * (math.pi / 180),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 200),
                      child: const Icon(
                        Icons.account_balance,
                        color: SirajColors.accentGold,
                        size: 32,
                      ),
                    ),
                  ),
                
                // Center Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: SirajColors.sirajBrown900,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Compass Reading
          if (_heading != null)
            Text(
              '${_heading!.toStringAsFixed(0)}°',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: SirajColors.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SirajColors.sirajBrown700,
            SirajColors.sirajBrown900,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: SirajColors.accentGold,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'أوقات الصلاة',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'استخدم البوصلة أعلاه لتحديد اتجاه القبلة بدقة قبل الصلاة',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SirajColors.beige100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SirajColors.accentGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: SirajColors.accentGold,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'تعليمات الاستخدام',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: SirajColors.sirajBrown900,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionItem('1. تأكد من تفعيل خدمات الموقع'),
          _buildInstructionItem('2. امسك الهاتف بشكل مسطح'),
          _buildInstructionItem('3. ابتعد عن الأجهزة المغناطيسية'),
          _buildInstructionItem('4. اتجه نحو الخط الذهبي المؤشر للكعبة'),
          _buildInstructionItem('5. تأكد من الاتجاه قبل بدء الصلاة'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: const BoxDecoration(
              color: SirajColors.accentGold,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: SirajColors.sirajBrown700,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

