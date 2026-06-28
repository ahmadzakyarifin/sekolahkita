#!/bin/bash
# ============================================================
# start-ngrok.sh — Expose Go Backend API via ngrok
# ============================================================
# Script ini untuk kamu (pemilik backend).
# Jalankan setelah `docker compose up` berhasil.
# ============================================================

set -e

# Warna output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║   🚀 SekolahKita — Ngrok Backend Tunnel     ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# 1. Cek apakah ngrok terinstall
if ! command -v ngrok &> /dev/null; then
    echo -e "${RED}❌ ngrok belum terinstall!${NC}"
    echo ""
    echo "Install ngrok dulu:"
    echo "  curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok-v3-stable-linux-amd64.tgz | sudo tar xz -C /usr/local/bin"
    echo ""
    echo "Atau pakai snap:"
    echo "  sudo snap install ngrok"
    echo ""
    echo "Lalu setup authtoken:"
    echo "  ngrok config add-authtoken TOKEN_KAMU"
    echo "  (Daftar gratis di https://ngrok.com)"
    exit 1
fi

echo -e "${GREEN}✅ ngrok terdeteksi${NC}"

# 2. Cek apakah backend berjalan di port 8080
if ! curl -s http://localhost:8080/api/v1/health > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Backend belum terdeteksi di port 8080${NC}"
    echo "   Pastikan sudah jalankan: docker compose up"
    echo ""
    read -p "Lanjut tetap jalankan ngrok? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✅ Backend aktif di port 8080${NC}"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📋 SETELAH ngrok jalan, lakukan ini:${NC}"
echo ""
echo "1. Copy URL ngrok (contoh: https://xxxx-xx-xx.ngrok-free.app)"
echo ""
echo "2. Tambahkan ke file .env di ALLOWED_ORIGINS:"
echo "   ALLOWED_ORIGINS=http://localhost:3001,http://localhost:5173,https://xxxx.ngrok-free.app"
echo ""
echo "3. Restart backend:"
echo "   docker compose restart backend"
echo ""
echo "4. Kirim URL ngrok ke teman FE, dia pakai sebagai:"
echo "   VITE_API_URL=https://xxxx.ngrok-free.app/api"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}🔥 Memulai ngrok tunnel ke localhost:8080...${NC}"
echo ""

# 3. Jalankan ngrok
ngrok http 8080
