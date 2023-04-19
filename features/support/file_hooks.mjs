import {After, Before} from '@cucumber/cucumber';
import {copy, createSymlink, emptyDir, ensureDir} from 'fs-extra';
import {dirname} from 'path';
import {fileURLToPath} from 'url';

Before({ name: 'Create test jail' }, async function () {
    this.rootDir = dirname(dirname(dirname(fileURLToPath(import.meta.url))));

    // Make sure there is nothing left over from a previous run
    this.jailDir = `${this.rootDir}/tmp`;
    await emptyDir(this.jailDir);

    // Create a chroot jail to better mimic a regular filesystem and avoid accidental dependencies
    await ensureDir(`${this.jailDir}/usr/bin`);

    for (const exe of ['bash', 'cat', 'env', 'realpath']) {
        await copy(`/bin/${exe}`, `${this.jailDir}/bin/${exe}`);
    }

    await createSymlink('bash', `${this.jailDir}/bin/sh`);

    // Copy the 'bin' executable into it
    await copy(`${this.rootDir}/dist/bin`, `${this.jailDir}/usr/bin/bin`);

    // Create the default working directory
    await ensureDir(`${this.jailDir}/project`);
    this.workingDir = '/project';
});

After({ name: 'Clear jail directory', tags: 'not @exit' }, async function (hook) {
    // If the test failed, keep the temp files for inspection
    if (hook.result.status === 'FAILED') {
        return 'skipped';
    }

    // Empty the temp directory, so we're not wasting space, but don't delete
    // it, so it doesn't keep appearing and disappearing
    await emptyDir(this.jailDir);
});
