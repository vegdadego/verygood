# 📋 Configuración de Assets en Flutter

## ✅ Configuración Correcta (Actual)

En `pubspec.yaml`, los assets deben listarse **individualmente**, no como directorios:

```yaml
flutter:
  assets:
    - assets/images/icon.png
    - assets/images/PLACEHOLDER_EXAMPLE.txt
```

## ❌ Configuración Incorrecta (Eliminada)

Esta configuración causaba problemas de build:

```yaml
flutter:
  assets:
    - assets/images/    # ❌ Incorrecto - uso de directorio
    - assets/fonts/
    - assets/animations/
```

## 📝 Por Qué Funciona Ahora

1. **Assets individuales**: Flutter sabe exactamente qué archivos incluir
2. **Sin ambigüedad**: No hay confusión sobre archivos incluidos
3. **Optimización**: Solo los archivos especificados se empaquetan

## ➕ Agregar Más Assets

Para agregar más imágenes:

```yaml
flutter:
  assets:
    - assets/images/icon.png
    - assets/images/logo.png      # Nueva imagen
    - assets/images/background.jpg # Nueva imagen
```

**Importante**: Después de agregar, ejecuta:
```bash
flutter pub get
```

## 🔄 Cambios de Assets

Si cambias un asset:
1. Reemplaza el archivo
2. Ejecuta `flutter pub get` (opcional)
3. Ejecuta `flutter run`

## ✅ Estado Actual

```yaml
assets:
  - assets/images/icon.png
  - assets/images/PLACEHOLDER_EXAMPLE.txt
```

**Uso en código**:
```dart
Image.asset('assets/images/icon.png')
```

## 🎯 Mejores Prácticas

1. **Listar archivos específicos** (no directorios)
2. **Comentar con propósito** cada asset
3. **Mantener estructura organizada** en carpetas
4. **Optimizar imágenes** antes de agregar

