# 📘 Panduan untuk Teman Frontend

Halo! 👋 Dokumen ini berisi langkah-langkah agar kamu bisa ngoding **React frontend** tanpa perlu install Docker, Redis, Database, atau backend apapun.

Semua backend sudah jalan di laptop host (pemilik project).

---

## ✅ Yang Kamu Butuhkan

| Software   | Versi Minimum | Cara Install                          |
| ---------- | ------------- | ------------------------------------- |
| **Node.js** | v20+         | [nodejs.org](https://nodejs.org)      |
| **npm**     | v10+         | Sudah bundled dengan Node.js          |
| **Git**     | v2+          | `sudo apt install git` / [git-scm.com](https://git-scm.com) |

## ❌ Yang TIDAK Perlu Kamu Install

- ~~Docker~~ — tidak perlu
- ~~PostgreSQL~~ — tidak perlu
- ~~Redis~~ — tidak perlu
- ~~Go / Golang~~ — tidak perlu
- ~~WAHA / n8n~~ — tidak perlu

---

## 🚀 Langkah-Langkah Setup

### 1. Clone Repository

```bash
git clone https://github.com/ahmadzakyarifin/sekolahkita.git
cd sekolahkita/frontend
```

### 3. Install Dependencies
Pastikan kamu sudah punya **Node.js** terinstall di laptopmu. Lalu jalankan:
```bash
npm install
```

### 4. Setup File Konfigurasi (`.env`)
Frontend membutuhkan URL Ngrok tadi agar tahu kemana harus menembak API.
Ada dua cara untuk membuat file `.env`:
- **Cara A (Buat Sendiri):** Copy file `.env.example` yang ada di root proyek, lalu ubah namanya menjadi `.env`.
- **Cara B (Minta ke temen mu):** Langsung minta file `.env` Frontend yang sudah jadi ke Ahmad, lalu letakkan di root proyek (`sekolahkita/.env`).

Buka file `.env` tersebut, cari bagian `VITE_API_URL`, lalu masukkan URL ngrok yang diberikan Ahmad. Jangan lupa tambahkan `/api` di belakangnya!
Contoh:
```env
VITE_API_URL=https://splotchy-waking-outcome.ngrok-free.dev/api
```

### 5. Jalankan React!
Di terminal (pastikan masih di dalam folder `frontend`), ketik:
```bash
npm run dev
```
Buka link `http://localhost:5173` di browser kamu. Selesai! Kamu sudah bisa mulai ngoding React. 🚀

---

## ⚠️ Troubleshooting (Jika Error)

**Kenapa halamannya blank / API tidak mau merespon / Error Fetch?**
Kamu tidak perlu panik. Kalau terjadi error koneksi ke API, kemungkinan besar **Ngrok di laptop Ahmad sedang offline**.

Penyebab Ngrok offline:
1. Laptop Ahmad sedang mati / sleep.
2. lupa menjalankan script `./start-ngrok.sh` di laptopnya.
3. Aplikasi Docker Backend di laptop Ahmad sedang mati.

**Solusi:**
Langsung chat Ahmad: *"Bro, ngrok-nya mati nih, tolong nyalain lagi dong!"*
Setelah Ahmad bilang sudah nyala, kamu cukup refresh browser kamu. Kamu tidak perlu mengubah apa-apa lagi di kodinganmu.

---

## 📁 Struktur Kerja Kamu

```
sekolahkita/
├── .env                  ← File ini yang baru kamu buat/dapat dari Ahmad
├── frontend/
│   ├── src/
│   │   └── App.jsx       ← Mulai ngoding di sini!
│   ├── package.json
│   └── vite.config.js
├── backend/              ← ABAIKAN folder ini (diurus Ahmad)
├── docker-compose.yml    ← ABAIKAN file ini (diurus Ahmad)
└── ...
```

Selamat ngoding! 🎉
