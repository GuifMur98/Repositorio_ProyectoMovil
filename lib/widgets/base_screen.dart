import 'package:flutter/material.dart';
import 'package:proyecto/widgets/bottom_navigation.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onNavigationTap;
  final PreferredSizeWidget? appBar;
  final bool showBottomNavigation;
  final Widget? bottomBar;

  const BaseScreen({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavigationTap,
    this.appBar,
    this.showBottomNavigation = true,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: showBottomNavigation
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bottomBar != null) bottomBar!,
                CustomBottomNavigation(
                  currentIndex: currentIndex,
                  onTap: onNavigationTap,
                ),
              ],
            )
          : null,
    );
  }
}
