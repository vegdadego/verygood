# Assets Directory

Esta carpeta contiene todos los recursos estáticos de la aplicación Smart Task Manager.

## 📁 Estructura

```
assets/
├── images/          # Imágenes y fotografías
├── fonts/           # Fuentes personalizadas
└── animations/      # Animaciones (JSON/Lottie)
```

## 🖼️ Images

Guarda todas las imágenes de la app:
- Logos
- Iconos
- Ilustraciones
- Placeholders
- Backgrounds

### Uso:
```dart
Image.asset('assets/images/logo.png')
```

## 🔤 Fonts

Almacena fuentes personalizadas (TTF, OTF).

### Configuración:
1. Agrega tus archivos `.ttf` en `assets/fonts/`
2. Descomenta y configura en `pubspec.yaml`:
```yaml
fonts:
  - family: CustomFont
    fonts:
      - asset: assets/fonts/CustomFont-Regular.ttf
      - asset: assets/fonts/CustomFont-Bold.ttf
        weight: 700
```
3. Usa en tu código:
```dart
Text('Hello', style: TextStyle(fontFamily: 'CustomFont'))
```

## 🎬 Animations

Contiene animaciones Lottie (JSON).

### Uso con lottie package:
```dart
Lottie.asset('assets/animations/loading.json')
```

## 📝 Notas

- Todos los assets deben estar registrados en `pubspec.yaml`
- Usa nombres descriptivos y en minúsculas
- Optimiza imágenes antes de añadirlas
- Considera diferentes densidades de pantalla (@1x, @2x, @3x)

