import {After, Before} from '@cucumber/cucumber';
import {copy, createSymlink, emptyDir, ensureDir} from 'fs-extra';
import * as paths from './paths.mjs';

Before({name: 'Create test jail'}, async function () {
    // Make sure there is nothing left over from a previous run
    await emptyDir(paths.jail);

    // Create a chroot jail to better mimic a regular filesystem and avoid accidental dependencies
    await ensureDir(`${paths.jail}/usr/bin`);

    for (const exe of ['bash', 'env', 'kcov', 'readlink', 'sort', 'uniq']) {
        await copy(`/usr/bin/${exe}`, `${paths.jail}/usr/bin/${exe}`);
    }

    await createSymlink('bash', `${paths.jail}/usr/bin/sh`);

    // Copy the 'bin' executable into it
    await copy(`${paths.root}/dist/bin`, `${paths.jail}/usr/bin/bin`);

    // Create the default working directory
    await ensureDir(`${paths.jail}/project`);
    this.workingDir = '/project';
});

After({name: 'Clear jail directory', tags: 'not @exit'}, async function (hook) {
    // If the test failed, keep the temp files for inspection
    if (hook.result.status === 'FAILED') {
        return 'skipped';
    }

    // Empty the temp directory, so we're not wasting space, but don't delete
    // it, so it doesn't keep appearing and disappearing
    await emptyDir(paths.jail);
});

After({name: '@exit', tags: '@exit'}, async function () {
    // Exit early, without cleaning up jail/, for manual debugging
    console.log();
    process.exit();
});
