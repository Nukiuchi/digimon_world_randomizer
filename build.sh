#!/usr/bin/env bash
set -e

if [ -n "$VIRTUAL_ENV" ]; then
    echo "Using active virtual environment: $VIRTUAL_ENV"
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

echo "==> Cleaning old build artifacts..."
rm -rf dist gui/dist_app gui/dist

echo "==> Packaging Python backend with PyInstaller..."
pyinstaller --clean --onefile --log-level ERROR digimon_randomize.py

echo "==> Building Electron GUI frontend..."
cd gui
npm run build
npm run package
cd ..

echo "==> Assembling distribution folder..."
mkdir -p dist/gui/resources/app

# Find and copy output folder
BUILD_OUTPUT=$(find gui/dist_app -maxdepth 1 -type d -name "*-linux-x64" | head -n 1)
cp -r "$BUILD_OUTPUT"/* dist/gui/

# Copy configuration and compiled backend executable
cp settings.ini README.md dist/gui/resources/app/
mv dist/digimon_randomize dist/gui/resources/app/

echo "==> Build finished successfully in dist/gui!"
