package app

import (
	"github.com/ahmadzakyarifin/sekolahkita/backend/internal/module/health"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRoutes(router *gin.Engine, db *gorm.DB) {
	api := router.Group("/api/v1")

	router.GET("/", func(c *gin.Context) {
		c.Redirect(301, "/api/v1/health")
	})

	health.RegisterRoutes(api)
}