package health_test

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/ahmadzakyarifin/sekolahkita/backend/internal/module/health"
	"github.com/gin-gonic/gin"
)

func TestCheckHealth(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.Default()

	health.RegisterRoutes(router.Group("/api/v1"))

	req, _ := http.NewRequest(http.MethodGet, "/api/v1/health", nil)
	
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status code %d, but got %d", http.StatusOK, w.Code)
	}

	expectedBody := `"status":"sukses"`
	if !strings.Contains(w.Body.String(), expectedBody) {
		t.Errorf("Expected body to contain %s, but got %s", expectedBody, w.Body.String())
	}
}
