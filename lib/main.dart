import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
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
import 'package:proyecto/services/auth_service.dart';
import 'package:proyecto/widgets/protected_route.dart';
import 'package:flutter/services.dart';
import 'package:proyecto/screens/all_products_screen.dart';
import 'package:proyecto/screens/chats_screen.dart';
import 'package:proyecto/services/local_notifications_service.dart';
import 'models/address.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Inicializar notificaciones locales
  await NotificationsService().init();

  try {} catch (e) {
    print('Error al inicializar la aplicación: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const ProtectedRoute(child: HomeScreen()),
        '/profile': (context) => const ProtectedRoute(child: ProfileScreen()),
        '/favorites': (context) =>
            const ProtectedRoute(child: FavoritesScreen()),
        '/cart': (context) => const ProtectedRoute(child: CartScreen()),
        '/create-product': (context) =>
            const ProtectedRoute(child: AddProductScreen()),
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
          final chatId = args is Map && args['chatId'] != null
              ? args['chatId'] as String
              : null;
          return ProtectedRoute(
              child: ChatScreen(sellerId: sellerId, chatId: chatId));
        },
        '/add-address': (context) =>
            ProtectedRoute(child: const AddAddressScreen()),
        '/edit-address': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          // Espera un objeto Address como argumento
          if (args is Address) {
            return ProtectedRoute(child: EditAddressScreen(address: args));
          }
          // Si no se pasa un Address, muestra error o regresa
          return const Scaffold(
            body: Center(child: Text('No se encontró la dirección a editar.')),
          );
        },
        '/all-products': (context) =>
            ProtectedRoute(child: AllProductsScreen()),
        '/chats': (context) => ProtectedRoute(child: const ChatsScreen()),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product-detail') {
          final args = settings.arguments;
          String productId = '';
          if (args is Map && args.containsKey('productId')) {
            productId = args['productId'] as String;
          }
          return MaterialPageRoute(
            builder: (context) => ProtectedRoute(
                child: ProductDetailScreen(productId: productId)),
          );
        }
        if (settings.name == '/category') {
          final args = settings.arguments;
          String category = '';
          if (args is Map && args.containsKey('category')) {
            category = args['category'] as String;
          }
          return MaterialPageRoute(
            builder: (context) =>
                ProtectedRoute(child: CategoryScreen(category: category)),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkSessionAndAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data != true) {
          // Redirigir a welcome y limpiar sesión local
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await AuthService.logout();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (route) => false,
            );
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return const HomeScreen();
      },
    );
  }

  Future<bool> _checkSessionAndAuth() async {
    final localSession = await AuthService.loadSession();
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    return localSession && fbUser != null;
  }
}

class TestNotificationButton extends StatelessWidget {
  const TestNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await NotificationsService().showNotification(
          title: '¡Notificación local!',
          body: 'Este es un ejemplo de notificación local.',
        );
      },
      child: const Text('Probar notificación local'),
    );
  }
}
