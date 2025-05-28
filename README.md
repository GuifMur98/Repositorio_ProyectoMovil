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

## Instalación

1. Clonar el repositorio:
```bash
git clone [URL_DEL_REPOSITORIO]
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

## Contribución
1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## Licencia
Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.



Instrucciones:
1.  Deben de activar modo desarrollador en sus computadoras, debido a que se utiliza un plugin que lo requiere, en una 
terminal pueden correr este comando - ms-settings:developers –; Esto les abrirá una ventana de las settings donde deberán 
habilitar developer tools.