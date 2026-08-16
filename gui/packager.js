const packager = require('@electron/packager');

async function main() {
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
    console.log(`Successfully packaged to: ${appPaths}`);
  } catch (err) {
    console.error('Build failed:', err);
    process.exit(1);
  }
}

main();
