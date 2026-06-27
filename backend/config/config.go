package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	AppEnv   string
	Port     string
	DBUser   string
	DBPass   string
	DBHost   string
	DBPort   string
	DBName   string
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

	return &Config{
		AppEnv:   appEnv,
		Port:     port,
		DBUser:   os.Getenv("DB_USER"),
		DBPass:   os.Getenv("DB_PASS"),
		DBHost:   os.Getenv("DB_HOST"),
		DBPort:   os.Getenv("DB_PORT"),
		DBName:   os.Getenv("DB_NAME"),
	}
}
