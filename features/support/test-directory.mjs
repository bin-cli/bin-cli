import {After, Before} from '@cucumber/cucumber';
import {copy, emptyDir, ensureDir, pathExists, remove} from 'fs-extra';
import * as paths from './paths.mjs';

Before({name: 'Create test directory'}, async function () {
    // Create directory, or empty it if it already exists
    await emptyDir(paths.root);

    // Copy the 'bin' executable so we have a known path
    await ensureDir(`${paths.root}/usr/bin`);
    await copy(`${paths.dist}/bin`, `${paths.root}/usr/bin/bin`);

    // Create the default working directory
    await ensureDir(`${paths.root}/project`);
    this.workingDir = `${paths.root}/project`;
});

After({name: 'Delete test directory', tags: 'not @exit'}, async function (hook) {
    // If the test failed, keep the temp files for inspection
    if (hook.result.status === 'FAILED') {
        return 'skipped';
    }

    await remove(paths.root);
});

After({name: '@exit', tags: '@exit'}, async function () {
    // Exit early, without cleaning up, for manual debugging
    console.log();
    process.exit();
});
