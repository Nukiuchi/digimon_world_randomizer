const packager = require('@electron/packager');

(async () => {
  try {
    const appPaths = await packager({
      dir: '.',
      name: 'digimon_randomize',
      platform: 'linux',
      arch: 'x64',
      out: '.',
      overwrite: true
    });
    console.log(`Packaged successfully to: ${appPaths}`);
  } catch (err) {
    console.error('Packaging failed:', err);
    process.exit(1);
  }
})();
