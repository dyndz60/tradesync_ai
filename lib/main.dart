name: Flutter APK Build

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Set up Java
      uses: actions/setup-java@v4
      with:
        distribution: 'temurin'
        java-version: '17'

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        channel: 'stable'
        cache: true

    - name: Prepare project structure and get packages
      run: |
        # إنشاء المشروع بالاسم المناسب
        flutter create . --org com.tradesync --project-name tradesync_ai --platforms=android
        
        # التأكد من جلب التبعيات المحدثة
        flutter pub get

    - name: Build APK Release
      run: flutter build apk --release

    - name: Upload APK artifact
      uses: actions/upload-artifact@v4
      with:
        name: tradesync-ai-apk
        path: build/app/outputs/flutter-apk/app-release.apk
