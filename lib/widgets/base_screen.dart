import 'package:flutter/material.dart';
import 'package:proyecto/widgets/bottom_navigation.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onNavigationTap;
  final PreferredSizeWidget? appBar;
  final bool showBottomNavigation;

  const BaseScreen({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavigationTap,
    this.appBar,
    this.showBottomNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: showBottomNavigation
          ? CustomBottomNavigation(
              currentIndex: currentIndex,
              onTap: onNavigationTap,
            )
          : null,
    );
  }
}
