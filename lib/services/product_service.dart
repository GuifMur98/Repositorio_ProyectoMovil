import 'package:proyecto/models/product.dart';
import 'package:proyecto/config/database.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ProductService {
  // Método para guardar un nuevo producto en la base de datos
  static Future<String?> createProduct(Product product) async {
    try {
      // Obtener la colección de productos directamente
      final productsCollection = DatabaseConfig.products;

      final productJson = product.toNewDocumentJson();

      // Insertar el documento en la colección
      final result = await productsCollection.insertOne(productJson);

      if (result.isSuccess) {
        print('Producto guardado con éxito en MongoDB.');
        return result.id?.toHexString();
      } else {
        print('Error al guardar producto en MongoDB: ${result.writeError}');
        // TODO: Manejar errores de escritura de MongoDB de forma más específica
        return null;
      }
    } catch (e) {
      print('Excepción al guardar producto en MongoDB: $e');
      // TODO: Manejar otras excepciones
      return null;
    }
  }

  // Método para obtener todos los productos de la base de datos
  static Future<List<Product>> getProducts() async {
    try {
      final productsCollection = DatabaseConfig.products;

      // Encontrar todos los documentos en la colección de productos
      final productsJson = await productsCollection.find().toList();

      print('Productos encontrados en MongoDB: ${productsJson.length}');

      // Convertir la lista de mapas JSON a una lista de objetos Product
      final products = productsJson
          .map((json) {
            try {
              return Product.fromJson(json);
            } catch (e) {
              print('Error al convertir producto: $e');
              print('JSON problemático: $json');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();

      print('Productos convertidos exitosamente: ${products.length}'); // Debug
      return products;
    } catch (e) {
      print('Excepción al obtener productos de MongoDB: $e');
      return [];
    }
  }

  // Método para obtener un producto específico por su ID
  static Future<Product?> getProductById(String productId) async {
    final productsCollection = DatabaseConfig.products;

    try {
      print('Buscando producto con ID: $productId');

      // Primero, obtener todos los productos para debug
      final allProducts = await productsCollection.find().toList();
      print('Todos los productos en la BD:');
      for (var product in allProducts) {
        print('ID: ${product['_id']}, Título: ${product['title']}');
      }

      // Extraer el ID hexadecimal del string ObjectId y limpiar las comillas
      String hexId;
      if (productId.startsWith('ObjectId(')) {
        hexId =
            productId.substring(9, productId.length - 1).replaceAll('"', '');
      } else {
        hexId = productId.replaceAll('"', '');
      }
      print('ID hexadecimal limpio: $hexId');

      // Buscar usando ObjectId
      final productJson = await productsCollection
          .findOne(where.id(ObjectId.fromHexString(hexId)));

      if (productJson == null) {
        print('Producto no encontrado con ID: $productId');
        return null;
      }

      print('Producto encontrado: ${productJson['title']}');
      return Product.fromJson(productJson);
    } catch (e) {
      print('Excepción al obtener producto por ID de MongoDB: $e');
      return null;
    }
  }
}
