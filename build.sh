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
npm install
npm run build
npm run package
cd ..

echo "==> Assembling distribution folder..."
mkdir -p dist/gui/resources/app

# Copy the Linux-packaged Electron app into dist/gui
cp -r gui/*-linux-x64/* dist/gui/

# Copy configuration and static resources
cp settings.ini README.md dist/gui/resources/app/

# Move the compiled Python binary into the Electron app folder
mv dist/digimon_randomize dist/gui/resources/app/

echo "==> Creating final zip archive..."
cd dist
zip -r digimon_randomizer_linux.zip gui/
cd ..

echo "==> Build complete! Output located at dist/gui/ and dist/digimon_randomizer_linux.zip"
