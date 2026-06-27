# SchoolPay 🎓

Sistem manajemen pembayaran sekolah modern yang dirancang untuk performa tinggi, stabilitas, dan skalabilitas (siap menampung ribuan transaksi/detik). 

---

## 🚀 Tech Stack Utama

Proyek ini dibangun menggunakan teknologi *Enterprise-Grade*:
- **Bahasa Pemrograman**: Golang (Go)
- **Web Framework**: Gin Gonic (Sangat cepat & ringan)
- **ORM / Database**: GORM & PostgreSQL
- **Database Migrations**: Goose (Berbasis SQL murni)
- **Rate Limiter (Anti-Spam)**: Redis (Sementara seluruh data utama dan cache menggunakan PostgreSQL)
- **Integrasi Eksternal**: 
  - Waha (WhatsApp API / Bot)
  - n8n (Workflow Automation)
  - SMTP (Sistem Notifikasi Email)
- **Infrastruktur**: Docker & Docker Compose (Multi-container setup)

---

## 🏗️ Arsitektur: Modular Monolith

Proyek ini dengan sengaja **TIDAK** menggunakan *Clean Architecture* tradisional yang membagi folder berdasarkan Layer (Lapisan). Sebagai gantinya, proyek ini menggunakan arsitektur **Modular Monolith**.

### Struktur Modul (Plug and Play)
Setiap fitur (misalnya `auth`, `student`, `billing`) akan memiliki foldernya sendiri di dalam `internal/module/`. Di dalam setiap folder fitur tersebut, isinya dibagi menjadi:
- **`model/`**: Mewakili bentuk tabel di database (GORM).
- **`dto/`** *(Data Transfer Object)*: Mewakili bentuk JSON saat *request* masuk atau *response* keluar (Validasi API).
- **`handler/`**: Mengurus urusan HTTP (Menerima request, membalas JSON).
- **`service/`**: Tempat otak/logika bisnis utama berjalan.
- **`repository/`**: Tempat menyimpan perintah *query* SQL/GORM.

> **Kenapa pakai `Model` & `DTO` dan meninggalkan `Entity`?**  
> Konsep `Entity` bawaan *Clean Architecture murni* seringkali terlalu kaku dan membuat kode menjadi sangat panjang (*over-engineered*). Menggunakan `Model` (fokus ke tabel) yang dikombinasikan dengan `DTO` (fokus ke validasi input user) adalah jalan tengah terbaik. Jauh lebih cepat diketik, gampang dipahami, dan tidak pusing saat *maintenance*.

---

## 📖 Catatan Pembelajaran Pribadi & Filosofi Desain

Dokumentasi ini ditulis sebagai pengingat mengapa keputusan-keputusan arsitektur di bawah ini diambil:

### 1. Kenapa `main.go` sangat sepi dan "Bongkar Pasang" dipindah ke `app.go`?
- **Golang Rule:** Fungsi `main()` adalah zona yang memblokir program (karena perintah `engine.Run()` berputar tanpa henti menunggu pengunjung web).
- **Testability:** Jika semua perakitan ditaruh di `main()`, kita tidak bisa membuat *Unit Test* otomatis. Dengan memindahkannya ke `internal/app/app.go`, kita bisa memanggil router dari file `_test.go` dan mengetes API tanpa harus benar-benar menyalakan port server. Ini adalah standar *Enterprise*.

### 2. Kenapa `config/` dan `infrastructure/` dipisah? Kenapa tidak disatukan?
- **`config/`**: Bertugas murni membaca file `.env` (Port, JWT Secret, Kredensial DB). Karena berdiri sendiri, ia bisa dipanggil/diimpor oleh modul mana saja yang membutuhkan konfigurasi.
- **`infrastructure/`**: Membutuhkan data dari `config` untuk menyalakan mesin berat seperti PostgreSQL atau Redis. 
- Jika keduanya disatukan, akan terjadi masalah besar bernama *Cyclic Import* di Golang. Memisahnya membuat `config` bisa berkeliling ke seluruh modul, sementara `infrastructure` fokus menjaga koneksi (seperti mengatur *Connection Pool: MaxOpenConns, MaxIdleConns*).

### 3. Kenapa dikelompokkan pakai `module` (Modul) bukan `layer` (Lapisan)?
- **Masalah Clean Architecture (Layer):** Biasanya *Clean Architecture* menaruh folder secara global: `controllers/`, `services/`, `repositories/`. Jika kita ingin mengedit fitur **Siswa**, kita harus melompat mencari file Siswa di 3 folder yang sangat jauh tersebut. Sangat melelahkan!
- **Solusi Modular Monolith:** Semua file yang berkaitan dengan fitur **Siswa** berkumpul di satu tempat: `internal/module/student/`. Sangat mudah dibaca. Kelebihan lainnya, jika besok proyek ini membesar dan fitur Siswa ingin dipisah menjadi server *Microservice* tersendiri, kita tinggal memotong 1 folder tersebut dan memindahkannya ke server baru (*Plug and Play*).
