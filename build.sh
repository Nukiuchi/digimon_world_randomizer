#!/usr/bin/env bash
set -e

# Source virtual environment
if [ -n "$VIRTUAL_ENV" ]; then
    echo "Using active virtual environment: $VIRTUAL_ENV"
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

echo "==> Cleaning old build artifacts..."
rm -rf dist gui/dist_app

echo "==> Packaging Python backend with PyInstaller..."
pyinstaller --clean --onefile --log-level ERROR digimon_randomize.py

echo "==> Building Electron GUI frontend..."
cd gui
npm install
npm install --save-dev typescript@latest electron@latest electron-packager@latest
npx tsc --skipLibCheck
npx electron-packager . digimon_randomize --platform=linux --arch=x64 --out=dist_app --overwrite
cd ..

echo "==> Assembling distribution folder..."
mkdir -p dist/gui/resources/app

cp -r gui/dist_app/digimon_randomize-linux-x64/* dist/gui/
cp settings.ini README.md dist/gui/resources/app/
mv dist/digimon_randomize dist/gui/resources/app/

echo "==> Build complete! App located at dist/gui/digimon_randomize"
