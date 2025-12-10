// responsive_helper.dart
import 'package:flutter/material.dart';

/// Singleton class for responsive sizing across the app
class ResponsiveHelper {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;
  static late double _safeBlockHorizontal;
  static late double _safeBlockVertical;
  static late EdgeInsets _safeAreaPadding;

  /// Initialize responsive helper - Call this once in your app
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _safeAreaPadding = mediaQuery.padding;

    // Calculate block sizes (1% of screen)
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    // Safe area blocks (excluding notch, navigation bar, etc.)
    _safeBlockHorizontal =
        (_screenWidth - _safeAreaPadding.left - _safeAreaPadding.right) / 100;
    _safeBlockVertical =
        (_screenHeight - _safeAreaPadding.top - _safeAreaPadding.bottom) / 100;
  }

  // Screen dimensions
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;

  // Safe area padding
  static EdgeInsets get safeAreaPadding => _safeAreaPadding;

  /// Width in percentage (0-100)
  static double wp(double percentage) => _blockSizeHorizontal * percentage;

  /// Height in percentage (0-100)
  static double hp(double percentage) => _blockSizeVertical * percentage;

  /// Safe width in percentage (0-100) - excludes notch areas
  static double swp(double percentage) => _safeBlockHorizontal * percentage;

  /// Safe height in percentage (0-100) - excludes notch/navigation areas
  static double shp(double percentage) => _safeBlockVertical * percentage;

  /// Responsive font size based on screen width
  static double sp(double size) {
    // Base design width (iPhone 11 Pro or similar)
    const baseWidth = 375.0;
    return (size / baseWidth) * _screenWidth;
  }

  /// Responsive radius/spacing
  static double radius(double size) => wp(size / 3.75);

  /// Check device type
  static bool isSmallPhone(BuildContext context) => _screenWidth < 360;
  static bool isMediumPhone(BuildContext context) =>
      _screenWidth >= 360 && _screenWidth < 400;
  static bool isLargePhone(BuildContext context) => _screenWidth >= 400;

  /// Orientation check
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
}

/// Extension on num for easier usage
extension ResponsiveExtension on num {
  /// Width percentage
  double get wp => ResponsiveHelper.wp(toDouble());

  /// Height percentage
  double get hp => ResponsiveHelper.hp(toDouble());

  /// Safe width percentage
  double get swp => ResponsiveHelper.swp(toDouble());

  /// Safe height percentage
  double get shp => ResponsiveHelper.shp(toDouble());

  /// Responsive font size
  double get sp => ResponsiveHelper.sp(toDouble());

  /// Responsive radius
  double get r => ResponsiveHelper.radius(toDouble());
}

// ============================================
// USAGE EXAMPLE
// ============================================

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize responsive helper (do this once per screen or in main)
    ResponsiveHelper.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Responsive Example'),
        toolbarHeight: 8.hp, // 8% of screen height
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 5.wp, // 5% of width
            vertical: 2.hp, // 2% of height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive text
              Text(
                'Hello World',
                style: TextStyle(
                  fontSize: 24.sp, // Scales with screen size
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 2.hp),

              // Responsive container
              Container(
                width: 90.wp, // 90% of screen width
                height: 20.hp, // 20% of screen height
                padding: EdgeInsets.all(4.wp),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius:
                      BorderRadius.circular(12.r), // Responsive radius
                ),
                child: Center(
                  child: Text(
                    'Responsive Container',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 3.hp),

              // Responsive Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.wp,
                  mainAxisSpacing: 2.hp,
                  childAspectRatio: 0.8,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        'Item $index',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 3.hp),

              // Responsive button
              SizedBox(
                width: double.infinity,
                height: 6.hp, // 6% screen height
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Click Me',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),

              SizedBox(height: 2.hp),

              // Device info
              Text(
                'Screen: ${ResponsiveHelper.screenWidth.toInt()} x ${ResponsiveHelper.screenHeight.toInt()}',
                style: TextStyle(fontSize: 12.sp),
              ),
              Text(
                'Is Small Phone: ${ResponsiveHelper.isSmallPhone(context)}',
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// COMMON RESPONSIVE PATTERNS
// ============================================

class ResponsivePatterns {
  // Standard padding
  static EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: 5.wp,
        vertical: 2.hp,
      );

  // Card padding
  static EdgeInsets get cardPadding => EdgeInsets.all(4.wp);

  // Button height
  static double get buttonHeight => 6.hp;

  // Input field height
  static double get inputHeight => 7.hp;

  // Standard spacing
  static SizedBox verticalSpace(double percentage) =>
      SizedBox(height: percentage.hp);
  static SizedBox horizontalSpace(double percentage) =>
      SizedBox(width: percentage.wp);

  // Standard text styles
  static TextStyle heading1 = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle heading2 = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
  );

  static TextStyle caption = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
  );
}
