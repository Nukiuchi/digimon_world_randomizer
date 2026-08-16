#!/usr/bin/env bash
set -e  # Exit immediately if any command fails

if [ -n "$VIRTUAL_ENV" ]; then
    echo "Using active virtual environment: $VIRTUAL_ENV"
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

echo "==> Cleaning old build artifacts..."
rm -rf dist
rm -rf gui/digimon_randomize-linux-x64
rm -rf gui/digimon_randomize-linux-x64-build

echo "==> Packaging Python backend with PyInstaller..."
pyinstaller --clean --onefile --log-level ERROR digimon_randomize.py

echo "==> Building Electron GUI frontend..."
cd gui

# 1. Update Electron to a modern version compatible with current Linux runtimes
npm install --save-dev electron@latest electron-packager@latest

# 2. Build TypeScript assets
npm run build

# 3. Package for Linux x64
npx electron-packager . digimon_randomize --platform=linux --arch=x64 --out=dist_app --overwrite
cd ..

echo "==> Assembling distribution folder..."
mkdir -p dist/gui/resources/app

# Copy packaged app files
cp -r gui/dist_app/digimon_randomize-linux-x64/* dist/gui/

# Copy configuration and static files
cp settings.ini README.md dist/gui/resources/app/

# Move the compiled Python executable into the resources folder
mv dist/digimon_randomize dist/gui/resources/app/

echo "==> Packaging completed successfully in dist/gui!"

echo "==> Creating final zip archive..."
cd dist
zip -r digimon_randomizer_linux.zip gui/
cd ..

echo "==> Build complete! Output located at dist/gui/ and dist/digimon_randomizer_linux.zip"
