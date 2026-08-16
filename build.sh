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
# 1. Grant approval for Electron's install script in npm
npm install-scripts approve --all 2>/dev/null || npx npm install-scripts approve --all 2>/dev/null || true
# 2. Re-run install
npm install
# 3. Manually execute the Electron binary download script
node node_modules/electron/install.js
# 4. Compile frontend TypeScript assets
npm run build
# 5. Bundle with electron-packager
npx electron-packager . digimon_randomize --platform=linux --arch=x64 --out=dist_app --overwrite
cd ..

echo "==> Assembling distribution folder..."
mkdir -p dist/gui/resources/app

# Copy the built Electron app into dist/gui
cp -r gui/dist_app/digimon_randomize-linux-x64/* dist/gui/

# Copy static configuration files
cp settings.ini README.md dist/gui/resources/app/

# Move the Python executable into resources/app
mv dist/digimon_randomize dist/gui/resources/app/

echo "==> Creating final zip archive..."
cd dist
zip -r digimon_randomizer_linux.zip gui/
cd ..

echo "==> Build complete! Output located at dist/gui/ and dist/digimon_randomizer_linux.zip"
