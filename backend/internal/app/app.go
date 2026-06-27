package app

import (
	"log"

	"github.com/ahmadzakyarifin/sekolahkita/backend/config"
	"github.com/ahmadzakyarifin/sekolahkita/backend/internal/infrastructure"
	"github.com/gin-gonic/gin"
)

func Run() {
	cfg := config.LoadConfig()

	if cfg.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
		log.Println("GIN berjalan di Mode Produksi (Cepat & Aman)")
	}

	db, err := infrastructure.ConnectDatabase(cfg)
	if err != nil {
		log.Fatalf("Mati karena Database gagal terhubung: %v", err)
	}
	engine := gin.Default()

	SetupRoutes(engine, db)

	log.Printf("Server SchoolPay Backend menyala di port %s (Mode: %s)\n", cfg.Port, cfg.AppEnv)
	if err := engine.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Mati karena server gagal berjalan: %v", err)
	}
}
