#!/usr/bin/env bash

# ───────────────────────────────────────────────────────
#  색상 정의
# ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "  ${BLUE}[i]${NC} $1"; }
success() { echo -e "  ${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "  ${YELLOW}[!]${NC} $1"; }
error()   { echo -e "  ${RED}[✘]${NC} $1"; exit 1; }
section() { echo ""; echo -e "${BLUE}── $1${NC}"; }