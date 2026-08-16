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

# Locate cached Electron zip or download if missing
ZIP_FILE=$(find "$CACHE_DIR" -name "electron-v${ELECTRON_VERSION}-linux-x64.zip" 2>/dev/null | head -n 1)

if [ -z "$ZIP_FILE" ]; then
    echo "==> Downloading Electron binary v${ELECTRON_VERSION}..."
    mkdir -p "$CACHE_DIR"
    ZIP_FILE="$CACHE_DIR/electron-v${ELECTRON_VERSION}-linux-x64.zip"
    curl -L "https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-x64.zip" -o "$ZIP_FILE"
fi

# Unpack binary and rename main executable
unzip -q -o "$ZIP_FILE" -d dist/gui/
mv dist/gui/electron dist/gui/digimon_randomize

# Copy app code into Electron's resource directory
mkdir -p dist/gui/resources/app
cp gui/package.json dist/gui/resources/app/
cp -r gui/dist dist/gui/resources/app/
cp -r gui/node_modules dist/gui/resources/app/ 2>/dev/null || true

# Inject backend binary and configuration
cp settings.ini dist/gui/resources/app/ 2>/dev/null || true
cp README.md dist/gui/resources/app/ 2>/dev/null || true
mv dist/digimon_randomize dist/gui/resources/app/

# Create archive
zip -r dist/digimon_randomizer.zip dist/gui

echo "==> Build complete! Binary located at: dist/gui/digimon_randomize"
