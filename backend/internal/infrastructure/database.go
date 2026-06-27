package infrastructure

import (
	"fmt"
	"log"
	"time"

	"github.com/ahmadzakyarifin/sekolahkita/backend/config"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func ConnectDatabase(cfg *config.Config) (*gorm.DB, error) {

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
		cfg.DBHost, cfg.DBUser, cfg.DBPass, cfg.DBName, cfg.DBPort,
	)

	var gormLogger logger.Interface
	if cfg.AppEnv == "development" {
		gormLogger = logger.Default.LogMode(logger.Info)
		log.Println("Database berjalan di mode DEVELOPMENT. Query SQL akan ditampilkan.")
	} else {
		gormLogger = logger.Default.LogMode(logger.Error)
		log.Println("Database berjalan di mode PRODUCTION. Query SQL disembunyikan.")
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger:         gormLogger,
		PrepareStmt:    true, // Sangat Penting! Mempercepat query hingga 30% dengan melakukan caching SQL di RAM.
		TranslateError: true, // Otomatis menerjemahkan error Postgres (contoh: unik constraint) menjadi error Golang yang mudah dibaca.
	})
	if err != nil {
		return nil, fmt.Errorf("gagal terhubung ke database: %w", err)
	}

	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("gagal mendapatkan instans database: %w", err)
	}

	// 1. SetMaxOpenConns (Batas absolut jumlah koneksi)
	// Atur ini PERTAMA KALI agar Golang tahu batas maksimal ruangan restoran.
	sqlDB.SetMaxOpenConns(100)
	
	// 2. SetMaxIdleConns (Wajib seimbang dengan MaxOpenConns)
	// Jika disetel lebih kecil dari MaxOpen, Golang akan terus-menerus memutus dan menyambung ulang koneksi saat trafik tinggi.
	sqlDB.SetMaxIdleConns(100)
	
	// 3. SetConnMaxLifetime (Waktu hidup maksimal)
	// 5 menit terlalu sebentar, 30 menit sangat ideal agar koneksi stabil namun tetap di-refresh secara berkala.
	sqlDB.SetConnMaxLifetime(30 * time.Minute)
	
	// 4. SetConnMaxIdleTime (Waktu nganggur maksimal)
	// 1 menit terlalu agresif. 15 menit memberikan keseimbangan yang baik antara menghemat RAM dan menjaga kecepatan.
	sqlDB.SetConnMaxIdleTime(15 * time.Minute)

	log.Println("Koneksi database berhasil dibangun! 🚀")
	return db, nil
}
