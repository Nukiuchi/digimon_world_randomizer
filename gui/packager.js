const packagerModule = require('@electron/packager') || require('electron-packager');
const packager = packagerModule.packager || packagerModule;

async function run() {
  console.log("==> Starting Electron Packaging...");
  try {
    const appPaths = await packager({
      dir: '.',
      name: 'digimon_randomize',
      platform: 'linux',
      arch: 'x64',
      out: 'dist_app',
      overwrite: true,
      prune: true
    });
    console.log(`==> Packaging complete! Output located at: ${appPaths}`);
  } catch (err) {
    console.error("==> Packaging failed:", err);
    process.exit(1);
  }
}

run();
