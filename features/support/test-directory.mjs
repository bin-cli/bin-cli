import {After, Before} from '@cucumber/cucumber';
import {copy, emptyDir, ensureDir, ensureSymlink, remove} from 'fs-extra';
import which from 'which';
import * as paths from './paths.mjs';

Before({name: 'Create test directory'}, async function () {
    // Create directory, or empty it if it already exists
    await emptyDir(paths.root);

    // Copy the 'bin' executable so we have a known path
    await copy(`${paths.dist}/bin`, `${paths.root}/usr/bin/bin`);

    // Symlink the executables we need, since we won't be using the global $PATH
    const executables = [
        'bash', // bash
        'basename', // coreutils
        'chmod', // coreutils
        'dirname', // coreutils
        'mkdir', // coreutils
        'readlink', // coreutils
        'sort', // coreutils
        'tr', // coreutils
        'uniq', // coreutils
    ];

    if (!this.disableKcov && !process.env.DISABLE_KCOV) {
        executables.push('kcov');
    }

    for (const exe of executables) {
        // We can't use '{root}/usr/bin' here because it would interfere with
        // the '/usr/bin' path test, to use '{root}/global/bin' instead
        await ensureSymlink(await which(exe), `${paths.root}/global/bin/${exe}`);
    }

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
