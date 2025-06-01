import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proyecto/screens/welcome_screen.dart';
import 'package:proyecto/screens/login_screen.dart';
import 'package:proyecto/screens/register_screen.dart';
import 'package:proyecto/screens/forgot_password_screen.dart';
import 'package:proyecto/screens/home_screen.dart';
import 'package:proyecto/screens/profile_screen.dart';
import 'package:proyecto/screens/favorites_screen.dart';
import 'package:proyecto/screens/chat_screen.dart';
import 'package:proyecto/screens/add_product_screen.dart';
import 'package:proyecto/screens/cart_screen.dart';
import 'package:proyecto/screens/notifications_screen.dart';
import 'package:proyecto/screens/edit_profile_screen.dart';
import 'package:proyecto/screens/addresses_screen.dart';
import 'package:proyecto/screens/user_products_screen.dart';
import 'package:proyecto/screens/purchase_history_screen.dart';
import 'package:proyecto/screens/help_support_screen.dart';
import 'package:proyecto/screens/privacy_security_screen.dart';
import 'package:proyecto/screens/add_address_screen.dart';
import 'package:proyecto/screens/edit_address_screen.dart';
import 'package:proyecto/screens/categories_screen.dart';
import 'package:proyecto/screens/category_screen.dart';
import 'package:proyecto/screens/product_detail_screen.dart';
import 'package:proyecto/services/user_service.dart';
import 'package:proyecto/config/database.dart';
import 'package:proyecto/config/cloudinary.dart';
import 'package:proyecto/services/auth_service.dart';
import 'package:proyecto/widgets/protected_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Cargar variables de entorno
    await dotenv.load(fileName: ".env");

    // Inicializar Cloudinary
    CloudinaryConfig.initialize();

    // Conectar a MongoDB
    await DatabaseConfig.connect();

    // Cargar sesión si existe
    await AuthService.loadSession();
  } catch (e) {
    print('Error al inicializar la aplicación: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const AuthWrapper(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => ProtectedRoute(child: const HomeScreen()),
        '/favorites': (context) =>
            ProtectedRoute(child: const FavoritesScreen()),
        '/publish': (context) =>
            ProtectedRoute(child: const AddProductScreen()),
        '/cart': (context) => ProtectedRoute(child: const CartScreen()),
        '/profile': (context) => ProtectedRoute(child: const ProfileScreen()),
        '/product-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final productId = args is Map && args['productId'] != null
              ? args['productId'] as String
              : '';
          return ProtectedRoute(
            child: ProductDetailScreen(productId: productId),
          );
        },
        '/category': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final category = args is Map && args['category'] != null
              ? args['category'] as String
              : '';
          return ProtectedRoute(child: CategoryScreen(category: category));
        },
        '/categories': (context) =>
            ProtectedRoute(child: const CategoriesScreen()),
        '/edit-profile': (context) =>
            ProtectedRoute(child: const EditProfileScreen()),
        '/addresses': (context) =>
            ProtectedRoute(child: const AddressesScreen()),
        '/notifications': (context) =>
            ProtectedRoute(child: const NotificationsScreen()),
        '/user-products': (context) =>
            ProtectedRoute(child: const UserProductsScreen()),
        '/purchase-history': (context) =>
            ProtectedRoute(child: const PurchaseHistoryScreen()),
        '/help-support': (context) =>
            ProtectedRoute(child: const HelpSupportScreen()),
        '/privacy-security': (context) =>
            ProtectedRoute(child: const PrivacySecurityScreen()),
        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final sellerId = args is Map && args['sellerId'] != null
              ? args['sellerId'] as String
              : null;
          return ProtectedRoute(child: ChatScreen(sellerId: sellerId));
        },
        '/add-address': (context) =>
            ProtectedRoute(child: const AddAddressScreen()),
        '/edit-address': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final addressId = args is Map && args['addressId'] != null
              ? args['addressId'] as int
              : -1;
          return ProtectedRoute(child: EditAddressScreen(addressId: addressId));
        },
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        }

        // Redirigir a welcome y limpiar el historial
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (route) => false,
          );
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
