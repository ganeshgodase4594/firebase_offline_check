import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatefulWidget {
  final Widget shellChild; // <-- required for GoRouter

  const MainShell({super.key, required this.shellChild});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  int _getIndexFromLocation(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/profile')) return 1;
    return 0;
  }

  void _onTap(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);

    switch (i) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/profile');
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;

    _currentIndex = _getIndexFromLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bool isWide = mq.size.width > 600;

    return Scaffold(
      body: SafeArea(child: widget.shellChild),

      // ----------------- BOTTOM NAV -----------------
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: isWide ? 24 : 12,
          right: isWide ? 24 : 12,
          bottom: mq.padding.bottom + 8,
        ),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.inputFieldBorder),
            ),
            child: Row(
              children: [
                _NavItem(
                  index: 0,
                  currentIndex: _currentIndex,
                  onTap: _onTap,
                  assetPath: AssetConstant.dashBoardImage,
                  label: "Dashboard",
                ),
                _NavItem(
                  index: 1,
                  currentIndex: _currentIndex,
                  onTap: _onTap,
                  assetPath: AssetConstant.profileImage,
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final Function(int) onTap;
  final String assetPath;
  final String label;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.assetPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = index == currentIndex;
    final active = AppColors.nameDividerColor;
    final inactive = AppColors.black;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                assetPath,
              ),

              //Image.asset(assetPath),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? active : inactive,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              selected
                  ? Container(
                      width: 20.wp,
                      height: .5.hp,
                      color: active,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
