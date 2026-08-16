#!/usr/bin/env bash
set -e

if [ -n "$VIRTUAL_ENV" ]; then
    echo "Using active virtual environment: $VIRTUAL_ENV"
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

# Clean up build artifacts
rm -rf dist gui/digimon_randomize-linux-x64 gui/digimon_randomize-win32-x64

# Build Linux Python binary
pyinstaller --clean --onefile --log-level ERROR digimon_randomize.py

# Build GUI package
cd gui
npm install
npm run build
npm run package
cd ..

# Copy packaged GUI files
mkdir -p dist/gui
cp -r gui/digimon_randomize-linux-x64/* dist/gui/

# Move binary and configuration into app resources
mkdir -p dist/gui/resources/app
cp settings.ini dist/gui/resources/app/
cp README.md dist/gui/resources/app/
mv dist/digimon_randomize dist/gui/resources/app/

# Create ZIP archive
