#!/usr/bin/env bash
set -e

ELECTRON_VERSION="28.3.3"
CACHE_DIR="$HOME/.cache/electron"

echo "==> Cleaning old build artifacts..."
rm -rf dist gui/dist

echo "==> Packaging Python backend with PyInstaller..."
pyinstaller --clean --onefile --log-level ERROR digimon_randomize.py

echo "==> Compiling TypeScript frontend..."
cd gui
npm install
npm run build
cd ..

echo "==> Assembling Linux Electron package..."
mkdir -p dist/gui

ZIP_FILE=$(find "$CACHE_DIR" -name "electron-v${ELECTRON_VERSION}-linux-x64.zip" 2>/dev/null | head -n 1)

if [ -z "$ZIP_FILE" ]; then
    echo "==> Downloading Electron binary v${ELECTRON_VERSION}..."
    mkdir -p "$CACHE_DIR"
    ZIP_FILE="$CACHE_DIR/electron-v${ELECTRON_VERSION}-linux-x64.zip"
    curl -L "https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-x64.zip" -o "$ZIP_FILE"
fi

unzip -q -o "$ZIP_FILE" -d dist/gui/
mv dist/gui/electron dist/gui/digimon_randomize

# Create application bundle
mkdir -p dist/gui/resources/app

# Copy all GUI root files (index.html, package.json, etc.) and compiled dist folder
cp -r gui/* dist/gui/resources/app/ 2>/dev/null || true
rm -rf dist/gui/resources/app/node_modules
cp -r gui/node_modules dist/gui/resources/app/

# Copy Python backend binary and settings into resources/app
mkdir -p dist/gui/resources/app/dist
mv dist/digimon_randomize dist/gui/resources/app/
cp settings.ini dist/gui/resources/app/ 2>/dev/null || true
cp README.md dist/gui/resources/app/ 2>/dev/null || true

zip -r dist/digimon_randomizer.zip dist/gui

echo "==> Build complete! Run ./dist/gui/digimon_randomize to test."
