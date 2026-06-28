package middleware

import (
	"log"
	"strings"

	"github.com/ahmadzakyarifin/sekolahkita/backend/config"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func CORSMiddleware(cfg *config.Config) gin.HandlerFunc {
	var allowedOrigins []string
	if cfg.AllowedOrigins != "" {
		for _, origin := range strings.Split(cfg.AllowedOrigins, ",") {
			trimmed := strings.TrimSpace(origin)
			if trimmed != "" {
				allowedOrigins = append(allowedOrigins, trimmed)
			}
		}
	}

	log.Printf("CORS diizinkan untuk origins: %v\n", allowedOrigins)

	return cors.New(cors.Config{
		AllowOrigins:     allowedOrigins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		AllowCredentials: true,
	})
}
