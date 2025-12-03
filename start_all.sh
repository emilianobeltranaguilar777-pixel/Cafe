#!/usr/bin/env bash
# Lanzador rápido del backend FastAPI.
# Usa uvicorn en modo recarga para facilitar el desarrollo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_DIR}/nucleo-api"

python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
