import 'package:flutter/material.dart';
import 'package:proyecto/screens/welcome_screen.dart';
import 'package:proyecto/screens/login_screen.dart';
import 'package:proyecto/screens/register_screen.dart';
import 'package:proyecto/screens/home_screen.dart';
import 'package:proyecto/screens/profile_screen.dart';
import 'package:proyecto/screens/favorites_screen.dart';
import 'package:proyecto/screens/chat_screen.dart';
import 'package:proyecto/screens/create_product_screen.dart';
import 'package:proyecto/screens/product_detail_screen.dart';
import 'package:proyecto/screens/user_product_detail_screen.dart';
import 'package:proyecto/screens/category_screen.dart';
import 'package:proyecto/screens/cart_screen.dart';
import 'package:proyecto/screens/notifications_screen.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:proyecto/services/auth_service.dart';
import 'package:proyecto/screens/edit_profile_screen.dart';
import 'package:proyecto/screens/addresses_screen.dart';
import 'package:proyecto/screens/user_products_screen.dart';
import 'package:proyecto/screens/purchase_history_screen.dart';
import 'package:proyecto/screens/help_support_screen.dart';
import 'package:proyecto/screens/privacy_security_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la base de datos
  await DatabaseService.initDatabase();

  // Verificar si el usuario está logueado
  final isLoggedIn = await AuthService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarketPlace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5C3D2E),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF5C3D2E)),
          titleTextStyle: TextStyle(
            color: Color(0xFF5C3D2E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C3D2E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/create-product': (context) => const CreateProductScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/product-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final productId = args is Map && args['productId'] != null
              ? args['productId'] as String
              : '';
          return ProductDetailScreen(productId: productId);
        },
        '/category': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final category = args is Map && args['category'] != null
              ? args['category'] as String
              : '';
          return CategoryScreen(category: category);
        },
        '/cart': (context) => const CartScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/addresses': (context) => const AddressesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/user-products': (context) => const UserProductsScreen(),
        '/purchase-history': (context) => const PurchaseHistoryScreen(),
        '/help-support': (context) => const HelpSupportScreen(),
        '/privacy-security': (context) => const PrivacySecurityScreen(),
        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final sellerId = args is Map && args['sellerId'] != null
              ? args['sellerId'] as String
              : null;
          return ChatScreen(sellerId: sellerId);
        },
      },
    );
  }
}
