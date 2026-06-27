include .env
export

# Menyusun URL Koneksi Database untuk dibaca oleh Goose di komputer lokal Anda (localhost)
DB_DSN="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${DB_PORT_EXTERNAL}/${POSTGRES_DB}?sslmode=disable"
MIGRATION_DIR=./backend/migrations

.PHONY: create up down status version force

# 1. CREATE: Membuat file tabel kosong (Gunakan argumen name=nama_tabel)
# Contoh: make create name=create_users_table
create:
	goose -dir $(MIGRATION_DIR) create $(name) sql

# 2. UP: Menjalankan semua migrasi yang belum dieksekusi (Membangun tabel)
up:
	goose -dir $(MIGRATION_DIR) postgres $(DB_DSN) up

# 3. DOWN: Rollback / Mundur 1 langkah (Menghapus tabel terakhir yang dibuat)
down:
	goose -dir $(MIGRATION_DIR) postgres $(DB_DSN) down

# 4. STATUS: Melihat status seluruh file migrasi (Applied / Pending)
status:
	goose -dir $(MIGRATION_DIR) postgres $(DB_DSN) status

# 5. VERSION: Melihat versi migrasi database saat ini
version:
	goose -dir $(MIGRATION_DIR) postgres $(DB_DSN) version

# 6. FORCE: Memaksa database menganggap sudah ada di versi tertentu (Contoh: make force version=3)
force:
	goose -dir $(MIGRATION_DIR) postgres $(DB_DSN) force $(version)
