# 🎨 Configuración del Icono de la App

## 📍 Ubicación
El icono personalizado está en: `assets/images/icon.png`

## 🎯 Uso Actual

### TaskListPage (Lista Principal)
- Icono visible en el AppBar junto al título
- Tamaño: 32x32 píxeles
- Fallback: Icono `Icons.checklist` si la imagen falla

### CreateTaskPage (Crear Tarea)
- Icono en el header de la pantalla
- Tamaño: 64x64 píxeles
- Fallback: Icono `Icons.task_alt` si la imagen falla

## 🚀 Cambiar el App Icon (Opción Avanzada)

Para usar este icono como ícono de la aplicación en Android/iOS:

### 1. Instala flutter_launcher_icons
```bash
flutter pub add --dev flutter_launcher_icons
```

### 2. Descomenta en pubspec.yaml
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/icon.png"
```

### 3. Genera los íconos
```bash
flutter pub run flutter_launcher_icons
```

## 📝 Requisitos del Archivo
- Formato: PNG (recomendado)
- Dimensiones: Mínimo 1024x1024 px
- Transparencia: Soportada
- Tamaño del archivo: < 1MB

## ✅ Estado Actual
✅ Icono configurado en UI
✅ Fallback handlers implementados  
✅ Assets registrados en pubspec.yaml
⏳ App icon nativo (requiere flutter_launcher_icons)

