package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	AppEnv string
	Port   string

	// Database
	DBUser string
	DBPass string
	DBHost string
	DBPort string
	DBName string

	// Redis
	RedisHost string
	RedisPort string
	RedisPass string
	RedisURL  string

	// Security
	JWTSecret          string
	CaptchaEnabled     bool
	TurnstileSecretKey string

	// Midtrans
	MidtransServerKey string
	MidtransClientKey string
	MidtransIsSandbox bool

	// Waha (WhatsApp)
	WahaURL               string
	WahaAPIKey            string
	WahaDashboardUsername string
	WahaDashboardPassword string
	WahaWebhookSecret     string

	// SMTP (Email)
	SMTPHost  string
	SMTPPort  string
	SMTPEmail string
	SMTPPass  string

	// Frontend
	FrontendURL  string
	FrontendPort string
}

func LoadConfig() *Config {
	err := godotenv.Load("../../.env")
	if err != nil {
		log.Println("Catatan: File .env tidak ditemukan. Menggunakan environment variable dari sistem (Docker).")
	}

	appEnv := os.Getenv("APP_ENV")
	if appEnv == "" {
		appEnv = "development"
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	captchaEnabled, _ := strconv.ParseBool(os.Getenv("CAPTCHA_ENABLED"))
	midtransIsSandbox, _ := strconv.ParseBool(os.Getenv("MIDTRANS_IS_SANDBOX"))

	return &Config{
		AppEnv: appEnv,
		Port:   port,

		DBUser: os.Getenv("DB_USER"),
		DBPass: os.Getenv("DB_PASS"),
		DBHost: os.Getenv("DB_HOST"),
		DBPort: os.Getenv("DB_PORT"),
		DBName: os.Getenv("DB_NAME"),

		RedisHost: os.Getenv("REDIS_HOST"),
		RedisPort: os.Getenv("REDIS_PORT"),
		RedisPass: os.Getenv("REDIS_PASS"),
		RedisURL:  os.Getenv("REDIS_URL"),

		JWTSecret:          os.Getenv("JWT_SECRET"),
		CaptchaEnabled:     captchaEnabled,
		TurnstileSecretKey: os.Getenv("TURNSTILE_SECRET_KEY"),

		MidtransServerKey: os.Getenv("MIDTRANS_SERVER_KEY"),
		MidtransClientKey: os.Getenv("MIDTRANS_CLIENT_KEY"),
		MidtransIsSandbox: midtransIsSandbox,

		WahaURL:               os.Getenv("WAHA_URL"),
		WahaAPIKey:            os.Getenv("WAHA_API_KEY"),
		WahaDashboardUsername: os.Getenv("WAHA_DASHBOARD_USERNAME"),
		WahaDashboardPassword: os.Getenv("WAHA_DASHBOARD_PASSWORD"),
		WahaWebhookSecret:     os.Getenv("WAHA_WEBHOOK_SECRET"),

		SMTPHost:  os.Getenv("SMTP_HOST"),
		SMTPPort:  os.Getenv("SMTP_PORT"),
		SMTPEmail: os.Getenv("SMTP_EMAIL"),
		SMTPPass:  os.Getenv("SMTP_PASS"),

		FrontendURL:  os.Getenv("FRONTEND_URL"),
		FrontendPort: os.Getenv("FRONTEND_PORT"),
	}
}
