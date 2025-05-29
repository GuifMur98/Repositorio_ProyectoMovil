# Proyecto de Marketplace Móvil

## Descripción
Aplicación móvil de marketplace desarrollada con Flutter que permite a los usuarios comprar y vender productos de manera segura y eficiente. La aplicación incluye funcionalidades de autenticación, gestión de productos, carrito de compras, favoritos, chat entre usuarios y notificaciones.

## Características Principales

### Autenticación y Perfil
- Registro e inicio de sesión de usuarios
- Perfil de usuario personalizable
- Gestión de información personal
- Historial de compras y ventas

### Productos
- Publicación de productos con imágenes, descripción y precio
- Categorización de productos
- Búsqueda de productos por nombre, descripción o categoría
- Filtrado por categorías
- Productos destacados en la página principal

### Favoritos
- Guardar productos favoritos
- Acceso rápido a productos favoritos
- Notificaciones de cambios en productos favoritos

### Carrito de Compras
- Añadir productos al carrito
- Gestionar cantidades
- Proceso de compra simplificado
- Historial de compras

### Chat
- Comunicación directa entre comprador y vendedor
- Interfaz de chat intuitiva
- Notificaciones de nuevos mensajes
- Historial de conversaciones

### Notificaciones
- Sistema de notificaciones en tiempo real
- Alertas de nuevos mensajes
- Notificaciones de cambios en productos favoritos
- Actualizaciones de estado de compras

## Tecnologías Utilizadas
- Flutter para el desarrollo de la interfaz de usuario
- Firebase para la autenticación y base de datos
- SQLite para el almacenamiento local
- Provider para la gestión del estado
- GetX para la navegación y gestión de rutas

## Estructura del Proyecto
```
lib/
├── models/         # Modelos de datos
├── screens/        # Pantallas de la aplicación
├── services/       # Servicios y lógica de negocio
├── widgets/        # Widgets reutilizables
├── utils/          # Utilidades y helpers
└── main.dart       # Punto de entrada de la aplicación
```

## Estructura de la Base de Datos

La aplicación utiliza SQLite para el almacenamiento local con las siguientes tablas:

### Tabla `users`
- `id`: TEXT (PRIMARY KEY)
- `name`: TEXT NOT NULL
- `email`: TEXT UNIQUE NOT NULL
- `password`: TEXT NOT NULL
- `phone`: TEXT
- `address`: TEXT
- `imageUrl`: TEXT

### Tabla `products`
- `id`: TEXT (PRIMARY KEY)
- `title`: TEXT NOT NULL
- `description`: TEXT NOT NULL
- `price`: REAL NOT NULL
- `imageUrl`: TEXT NOT NULL
- `category`: TEXT NOT NULL
- `address`: TEXT NOT NULL
- `sellerId`: TEXT NOT NULL (FOREIGN KEY)

### Tabla `cart`
- `id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `productId`: TEXT NOT NULL
- `userId`: TEXT NOT NULL (FOREIGN KEY)
- UNIQUE(productId, userId)

### Tabla `favorites`
- `id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `productId`: TEXT NOT NULL
- `userId`: TEXT NOT NULL (FOREIGN KEY)
- UNIQUE(productId, userId)

### Tabla `purchases`
- `id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `userId`: TEXT
- `products`: TEXT
- `total`: REAL
- `date`: TEXT

## Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/GuifMur98/Repositorio_ProyectoMovil.git
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar Firebase:
   - Crear un proyecto en Firebase Console
   - Añadir la aplicación Android/iOS
   - Descargar y configurar el archivo de configuración

4. Ejecutar la aplicación:
```bash
flutter run
```

## Características de la Interfaz

### Pantalla Principal
- Barra de búsqueda con filtrado en tiempo real
- Categorías principales con navegación rápida
- Productos destacados en grid
- Acceso rápido a favoritos y carrito

### Detalle de Producto
- Imágenes del producto
- Información detallada
- Botón de favoritos
- Opción de chat con el vendedor
- Añadir al carrito

### Chat
- Interfaz de mensajería intuitiva
- Indicador de estado de mensajes
- Soporte para imágenes
- Historial de conversaciones

### Perfil
- Información del usuario
- Productos publicados
- Historial de compras/ventas
- Configuración de cuenta

## Notas Importantes

- La aplicación requiere permisos de almacenamiento para guardar imágenes de productos.
- Se recomienda desinstalar y reinstalar la aplicación después de actualizaciones significativas de la base de datos.
- Los datos del carrito y favoritos están vinculados al usuario actual.
- La versión actual de la base de datos es 7, que incluye soporte para carrito y favoritos por usuario.

## Contribución
1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## Licencia
Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.



Instrucciones:
1. Deben de activar modo desarrollador en sus computadoras, debido a que se utiliza un plugin que lo requiere, en una 
terminal pueden correr este comando - ms-settings:developers –; Esto les abrirá una ventana de las settings donde deberán 
habilitar developer tools.
