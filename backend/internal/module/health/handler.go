package health

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// RegisterRoutes mendaftarkan rute khusus modul health
func RegisterRoutes(router *gin.RouterGroup) {
	healthGroup := router.Group("/health")
	{
		healthGroup.GET("", CheckHealth)
	}
}

// CheckHealth adalah handler sederhana untuk memastikan server berjalan
func CheckHealth(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "sukses",
		"message": "Backend SchoolPay beroperasi dengan normal! ",
		"mode":    "siap",
	})
}
