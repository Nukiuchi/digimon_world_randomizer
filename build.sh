#!/usr/bin/env bash
set -e

if [ -n "$VIRTUAL_ENV" ]; then
    echo "Using active virtual environment: $VIRTUAL_ENV"
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

echo "==> Cleaning old build artifacts..."
rm -rf dist build gui/digimon_randomize-linux-x64 gui/digimon_randomize-win32-x64 gui/dist gui/node_modules

echo "==> Packaging Python backend with PyInstaller..."
pyinstaller --clean --onefile --log-level ERROR digimon_randomize.py

echo "==> Building Electron GUI frontend..."
cd gui
npm install --ignore-scripts=false
node node_modules/electron/install.js
npm run build
npm run package
cd ..

echo "==> Assembling distribution folder..."
mkdir -p dist/gui
cp -r gui/digimon_randomize-linux-x64/* dist/gui/
mkdir -p dist/gui/resources/app
cp settings.ini dist/gui/resources/app/
cp README.md dist/gui/resources/app/
mv dist/digimon_randomize dist/gui/resources/app/

echo "==> Build finished successfully in dist/gui!"

echo "==> Zipping dist..."
zip -r dist/digimon_randomizer.zip dist

echo "==> Zip OK!"
