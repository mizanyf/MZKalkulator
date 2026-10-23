# MZ Kalkulator

Aplikasi kalkulator modern berbasis Flutter dengan tema gelap minimalis (*pure black* `#000000`), aksen cyan (`#19B5FE`), dan efek *glassmorphism* yang bersih serta nyaman di mata.

---

## ✨ Fitur Utama

- **Tampilan Bersih & Minimalis**: Desain antarmuka *edge-to-edge* full-screen tanpa distraksi logo atau teks di layar kalkulator.
- **Input Langsung di Field Utama**: Setiap angka dan operator langsung tampil jelas di kolom besar (contoh: `9 × 9`).
- **Hasil Sesuai Permintaan**: Hasil perhitungan baru muncul saat menekan tombol sama dengan (`=`), memindahkan rumus ke baris atas.
- **Riwayat Perhitungan Bersih (1 Baris)**: Kolom atas menampilkan 1 riwayat rumus perhitungan sebelumnya secara rapi dan tidak menambahkan tanda sama dengan/hasil saat perhitungan dilanjutkan secara berantai.
- **Operasi Matematika Lengkap**:
  - Operasi dasar: Tambah (`+`), Kurang (`−`), Kali (`×`), Bagi (`÷`).
  - Persentase (`%`), Positif/Negatif (`±`), dan Desimal (`.`).
  - Hapus per karakter (`DEL`) dan Hapus Semua (`AC`).
  - *Order of operations* (prioritas operator perkalian/pembagian diutamakan).
- **Haptic Feedback**: Getaran halus saat tombol ditekan untuk pengalaman mengetik yang responsif.
- **Ikon & Identitas Mobile**:
  - Nama aplikasi: **MZ Kalkulator**
  - Ikon aplikasi mobile dibuat langsung dari logo resmi di `assets/logo/logo.png`.

---

## 🚀 Cara Menjalankan

### Persyaratan
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.x atau lebih baru)
- Device Android, emulator, atau browser Chrome

### Langkah Menjalankan:
```bash
# 1. Unduh dependencies
flutter pub get

# 2. Jalankan aplikasi
flutter run
```

Untuk memilih target perangkat tertentu:
```bash
# Di Google Chrome (Web)
flutter run -d chrome

# Di Android Device / Emulator
flutter run -d android
```

---

## 🧪 Menjalankan Pengujian (Testing)

Proyek ini telah dilengkapi dengan unit test dan widget test komprehensif:

```bash
# Menjalankan static analysis
flutter analyze

# Menjalankan seluruh automated test suite (13 test cases)
flutter test
```

---

## 📁 Struktur Direktori

```text
lib/
├── main.dart                          # Inisialisasi aplikasi MZ Kalkulator
├── models/
│   └── calculation_history_item.dart  # Model data riwayat kalkulasi
├── screens/
│   └── calculator_screen.dart         # Layar kalkulator utama (Glassmorphic UI)
├── services/
│   ├── calculator_engine.dart         # Logika matematika & alur state
│   └── history_service.dart           # Layanan penyimpanan lokal riwayat
├── utils/
│   └── calculator_constants.dart      # Konstanta warna, gaya, & ukuran
└── widgets/
    ├── calculator_button.dart         # Komponen tombol kalkulator
    └── calculator_display.dart        # Komponen tampilan layar angka & riwayat
```
