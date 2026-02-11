# Proyek 4 - Modul 1: Counter App (SRP Implementation)

Aplikasi penghitung sederhana yang menerapkan prinsip **Single Responsibility Principle (SRP)**. Proyek ini memisahkan logika bisnis (Controller) dari tampilan antarmuka (View).

## Fitur Utama
1. **Multi-Step Counter**: Bisa nambah/kurang angka sesuai langkah (step) yang diatur di slider (1-10).
2. **History Logger**: Mencatat riwayat aktivitas (Tambah/Kurang) secara *real-time*.
3. **Limit Data**: Riwayat otomatis membatasi hanya 5 aktivitas terakhir (data lama terhapus).
4. **Dynamic UI**: Teks riwayat berwarna **Hijau** (jika ditambah) dan **Merah** (jika dikurang).
5. **Safety Reset**: Fitur reset data dengan konfirmasi dialog (Alert Dialog) dan notifikasi (SnackBar).

## Refleksi Penerapan SRP (Homework)
Jujur, awalnya terasa agak ribet harus memecah file jadi `main.dart`, `counter_controller.dart`, dan `counter_view.dart`. Tapi setelah masuk ke tugas praktikum (Task 1 & 2), baru kerasa manfaatnya:
- Pas mau nambah fitur "History", saya fokus ngoding logikanya cuma di **Controller**. Gak perlu takut nyenggol kode tampilan tombol atau warna.
- Pas mau warnain teks (Hijau/Merah), saya cuma mainan logika di **View** tanpa ngerusak hitungan angkanya.
- Kodenya jadi lebih bersih. Kalau ada error di hitungan, saya tau pasti salahnya di Controller, bukan di UI.

