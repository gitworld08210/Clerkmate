# ClerkMate 📋

School clerk ke roz ke kaam automate karne wali Flutter Android app — **salary bill generator**, **AI-powered form auto-fill**, aur **staff/school database**.

## Features

### 1. Salary Bill Banayein 🧾
- Teachers/staff ka data ek baar save karein (Basic, DA, HRA, GIS, CPF, bank details).
- Month select karein aur har teacher ke **present days** daalein.
- Salary components **auto-calculate** (present days ke hisaab se proportionate) hoke ek saaf **PDF salary bill** ban jaata hai.
- Values generate karte time bhi **editable** hain.
- PDF **share** karein (WhatsApp / Gmail / Drive).

### 2. Form Auto-Fill (AI) 🤖
- Koi bhi school form **PDF ya photo** upload karein — chahe purana bhara hua ho ya handwritten.
- **Gemini AI** form ke fields samajhta hai (synonyms/translation ke saath — jaise *Vidyalaya = School Name*, *Head Master = Principal*).
- Database se blank fields khud bhar jaate hain.
- Ek naya **saaf PDF** aur **Excel sheet** ban jaata hai — messy original ki jagah.

### 3. Data Management 🗃️
- Teachers/staff aur Vidyalaya details phone me hi (SQLite) safe rehte hain.

## Setup

1. **Gemini API key** (free) chahiye AI feature ke liye — [Google AI Studio](https://aistudio.google.com/app/apikey) se banayein.
2. App me **Settings → API Key** me daal dein.

## APK Download

Har push par GitHub Actions APK build karta hai:
- **Releases** tab me latest `app-debug.apk` milega, ya
- **Actions** tab → latest run → Artifacts → `ClerkMate-apk`.

APK phone me install karke chalayein (unknown sources allow karna pad sakta hai).

## Tech Stack

- **Flutter** (Dart) — single codebase Android app
- **sqflite** — local database
- **Provider** — state management
- **Gemini 1.5 Flash** — AI form understanding
- **pdf / printing** — PDF generate + preview
- **excel** — Excel export
- **share_plus** — file sharing

## Build locally

```bash
flutter pub get
flutter build apk --debug
# output: build/app/outputs/flutter-apk/app-debug.apk
```
