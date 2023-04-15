import {After, Before} from '@cucumber/cucumber';
import {copy, emptyDir, ensureDir} from 'fs-extra';
import {dirname} from 'path';
import {fileURLToPath} from 'url';

Before({ name: 'Create test jail' }, async function () {
    this.rootDir = dirname(dirname(dirname(fileURLToPath(import.meta.url))));

    // Make sure there is nothing left over from a previous run
    this.jailDir = `${this.rootDir}/tmp`;
    await emptyDir(this.jailDir);

    // Create a jail
    await ensureDir(`${this.jailDir}/usr/bin`);

    await copy(`/bin/sh`, `${this.jailDir}/bin/sh`);
    await copy(`/bin/dash`, `${this.jailDir}/bin/dash`);

    // For manual debugging:
    // 1. Uncomment these lines:
    // await copy(`/bin/bash`, `${this.jailDir}/bin/bash`);
    // await copy(`/bin/ls`, `${this.jailDir}/bin/ls`);
    // 2. Add the tag '@exit' to one of the tests, so it exits without cleaning up
    // 3. Run Cucumber (`bin/test`)
    // 4. Run `fakechroot fakeroot chroot tmp sh`

    // Copy the 'bin' executable into it
    await copy(`${this.rootDir}/dist/bin`, `${this.jailDir}/usr/bin/bin`);

    // Create the default working directory
    await ensureDir(`${this.jailDir}/home/project`);
    this.workingDir = '/home/project';
});

After({ name: 'Clear jail directory', tags: 'not @exit' }, async function () {
    // Empty, but don't delete, the temp directory, so it doesn't keep appearing and disappearing
    await emptyDir(this.jailDir);
});
