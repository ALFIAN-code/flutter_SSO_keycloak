# Belajar SSO dengan Keycloak di Flutter

Repository ini berisi implementasi Single Sign-On (SSO) menggunakan Keycloak untuk autentikasi dengan Flutter sebagai client dan Dart Frog sebagai backend.

## 📁 Struktur Project

```
belajar_sso/
├── client/          # Flutter Application (Client)
├── server/          # Dart Frog API (Backend)
└── README.md
```

## 🛠️ Tech Stack

### Frontend (Client)
- **Flutter** - Cross-platform mobile framework
- **Bloc/Cubit** - State management
- **Dio** - HTTP client untuk API calls
- **App Links** - Deep linking untuk callback handling
- **URL Launcher** - Membuka browser untuk login

### Backend (Server)
- **Dart Frog** - Web framework untuk Dart
- **Keycloak** - Identity and Access Management

## 🚀 Fitur

- ✅ Single Sign-On dengan Keycloak
- ✅ Deep linking untuk callback handling
- ✅ Token-based authentication
- ✅ Secure storage untuk session management
- ✅ Cross-platform support (Android & iOS)

## 📋 Prerequisites

1. **Flutter SDK** (3.0+)
2. **Dart SDK** (3.0+)
3. **Dart Frog CLI**
4. **Keycloak Server** (running on port 8080)

## ⚙️ Setup

### 1. Keycloak Configuration

1. Start Keycloak server
2. Create realm: `learning-realm`
3. Create client: `test-sso`
4. Configure redirect URI: `com.belajar.sso://login-callback`

### 2. Backend Setup (Dart Frog)

```bash
cd server
dart pub get
dart_frog dev
```

Server akan berjalan di `http://localhost:3000`

### 3. Client Setup (Flutter)

```bash
cd client
flutter pub get
flutter run
```

## 🔧 Konfigurasi

### Backend Configuration

Update `server/secret.dart`:
```dart
const keycloakUrl = 'http://your-keycloak-server:8080';
const realm = 'learning-realm';
const clientId = 'test-sso';
```

### Client Configuration

Update `client/lib/service/auth_service.dart`:
```dart
_dio.options.baseUrl = 'http://your-backend-server:3000';
```

## 🔄 Flow Autentikasi

1. User membuka aplikasi Flutter
2. Aplikasi request login URL dari backend
3. Backend generate URL Keycloak dan session ID
4. User tap "Login with SSO"
5. Browser terbuka dengan halaman login Keycloak
6. User login di Keycloak
7. Keycloak redirect ke `com.belajar.sso://login-callback`
8. Flutter app menangkap deep link
9. App kirim authorization code ke backend
10. Backend exchange code dengan access token
11. User berhasil login dan diarahkan ke homepage

## 📱 Deep Linking Setup

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.belajar.sso" />
</intent-filter>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.belajar.sso</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.belajar.sso</string>
        </array>
    </dict>
</array>
```

## 🐛 Debugging

### Common Issues

1. **Deep link tidak berfungsi**: Pastikan custom URL scheme terkonfigurasi dengan benar
2. **Connection refused**: Pastikan backend dan Keycloak berjalan
3. **Invalid redirect URI**: Periksa konfigurasi client di Keycloak

### Debug Commands

```bash
# Flutter logs
flutter logs

# Dart Frog logs
cd server && dart_frog dev --verbose

# Test API manually
curl http://localhost:3000/auth/login
```

## 📚 Referensi

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Frog Documentation](https://dartfrog.vgv.dev/)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [OAuth 2.0 Flow](https://oauth.net/2/)


**Note**: Pastikan untuk tidak commit file `secret.dart` yang berisi kredensial sensitive ke repository public.
