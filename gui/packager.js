const packager = require('@electron/packager')
const rebuild = require('electron-rebuild').default

(async () => {
  try {
    const appPaths = await packager({
  dir: __dirname,
  afterCopy: [(buildPath, electronVersion, platform, arch, callback) => {
    rebuild({ buildPath, electronVersion, arch })
      .then(() => callback())
      .catch((error) => callback(error));
  }]
    });
    console.log(`Packaged successfully to: ${appPaths}`);
  } catch (err) {
    console.error('Packaging failed:', err);
    process.exit(1);
  }
})();
