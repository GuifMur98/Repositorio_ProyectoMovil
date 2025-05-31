# TradeNest - Aplicación de Comercio Electrónico

TradeNest es una aplicación móvil de comercio electrónico desarrollada con Flutter, que permite a los usuarios comprar y vender productos de manera fácil y segura.

## Características Principales

### Autenticación
- Pantalla de bienvenida con diseño atractivo
- Sistema de inicio de sesión
- Registro de nuevos usuarios
- Usuario de prueba disponible (email: usuario@prueba.com, contraseña: 123456)

### Pantalla Principal
- Barra de búsqueda de productos
- Sección de categorías con diseño visual atractivo
- Productos destacados
- Navegación inferior con 5 secciones principales

### Categorías
- Vista de categorías en cuadrícula
- Categorías principales: Electrónica, Ropa, Hogar, Deportes, Libros, Mascotas
- Filtrado de productos por categoría

### Carrito de Compras
- Lista de productos en el carrito
- Ajuste de cantidades
- Resumen del pedido con subtotal, envío y total
- Selección de dirección de envío
- Proceso de pago (simulado en la versión demo)

### Perfil de Usuario
- Información personal
- Historial de compras
- Productos favoritos
- Gestión de direcciones
- Configuración de cuenta

### Publicación de Productos
- Formulario para crear nuevos productos
- Carga de imágenes
- Categorización
- Gestión de productos publicados

## Tecnologías Utilizadas

- Flutter
- Dart
- Material Design
- Gestión de estado local
- Navegación entre pantallas
- Diseño responsivo

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/tradenest.git
```

2. Navega al directorio del proyecto:
```bash
cd tradenest
```

3. Instala las dependencias:
```bash
flutter pub get
```

4. Ejecuta la aplicación:
```bash
flutter run
```

## Versión de Demostración

Esta es una versión de demostración que incluye:
- Datos de ejemplo para productos y categorías
- Funcionalidades simuladas para compras y publicaciones
- Usuario de prueba predefinido
- Interfaz de usuario completa y funcional

## Estructura del Proyecto

```
lib/
  ├── screens/         # Pantallas de la aplicación
  ├── widgets/         # Widgets reutilizables
  ├── services/        # Servicios y lógica de negocio
  ├── models/          # Modelos de datos
  └── main.dart        # Punto de entrada de la aplicación
```

## Contribución

1. Haz un Fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.

Instrucciones:
1. Deben de activar modo desarrollador en sus computadoras, debido a que se utiliza un plugin que lo requiere, en una 
terminal pueden correr este comando - ms-settings:developers –; Esto les abrirá una ventana de las settings donde deberán 
habilitar developer tools.
