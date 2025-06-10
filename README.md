# TradeNest - Aplicación de Comercio Electrónico

TradeNest es una aplicación móvil de comercio electrónico desarrollada con Flutter y Firebase/Firestore, que permite a los usuarios comprar y vender productos de manera fácil y segura.

## Características Principales

### Autenticación
- Pantalla de bienvenida con diseño atractivo
- Sistema de inicio de sesión
- Registro de nuevos usuarios
- Recuperación de contraseña real: el usuario recibe una contraseña temporal por email para restablecer su acceso

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
- Proceso de pago (simulado)

### Perfil de Usuario
- Información personal editable
- Historial de compras (persistente en Firestore)
- Productos favoritos
- Gestión de direcciones
- Configuración de cuenta
- Avatar de usuario y mejoras visuales

### Publicación de Productos
- Formulario para crear nuevos productos
- Carga de imágenes
- Categorización
- Gestión de productos publicados (persistente en Firestore)

## Tecnologías Utilizadas

- Flutter
- Dart
- Firebase (Firestore, Auth, Storage)
- mailer (envío de correos reales)
- Material Design
- Navegación entre pantallas
- Diseño responsivo

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/GuifMur98/Repositorio_ProyectoMovil.git
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## Notas Importantes

- Toda la información de usuarios, productos, compras y favoritos se almacena y consulta directamente en Firebase Firestore.
- La recuperación de contraseña es real: el usuario recibe una contraseña temporal por email (requiere configuración de SMTP en producción).
- El diseño de la app incluye mejoras visuales modernas en pantallas de perfil y edición de perfil.
- Para el correcto funcionamiento del envío de correos, asegúrate de configurar las credenciales SMTP en el backend.
- Las notificaciones y toda la lógica de la app se gestionan 100% desde el cliente Flutter usando Firebase .

## Estructura del Proyecto

```
lib/
  ├── screens/         # Pantallas de la aplicación
  ├── widgets/         # Widgets reutilizables
  ├── services/        # Servicios y lógica de negocio
  ├── models/          # Modelos de datos
  └── main.dart        # Punto de entrada de la aplicación
```



## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.

Instrucciones:
1. Deben de activar modo desarrollador en sus computadoras, debido a que se utiliza un plugin que lo requiere, en una 
terminal pueden correr este comando - ms-settings:developers –; Esto les abrirá una ventana de las settings donde deberán 
habilitar developer tools.
