import {AfterAll, Before, BeforeAll} from '@cucumber/cucumber';
import {emptyDir, exists} from 'fs-extra';
import * as paths from './paths.mjs';
import {spawnSync} from 'child_process';
import {quote} from 'shell-quote';
import {move} from 'fs-extra/lib/move/index.js';
import {clearJail, makeJail} from './jail.mjs';

let id = 1;

export function nextId() {
    return id++;
}

BeforeAll(async function () {
    await emptyDir(paths.coverage);
});

Before({tags: '@disable-kcov', name: 'Disable kcov'}, function () {
    this.kcov = false;
});

AfterAll(async function () {
    // Skip this if a test failed (and wasn't cleaned up)
    // I can't find a better way to do this since Cucumber doesn't seem to pass us the result
    if (await exists(`${paths.jail}/usr`)) {
        return;
    }

    // We have to use the jail to merge the results - otherwise the paths are wrong
    await makeJail();

    await move(paths.coverage, `${paths.jail}/coverage`);

    const command = quote([
        'fakechroot',
        'chroot',
        paths.jail,
        'sh',
        '-c',
        [
            'kcov',
            '--exclude-line=kcov-ignore-line',
            '--exclude-region=kcov-ignore-start:kcov-ignore-end',
            '--path-strip-level=0',
            '--merge',
            `/coverage/merged`,
            `/coverage/result-*`,
        ].join(' '),
    ]);

    const result = spawnSync(command, {
        shell: true,
    });

    if (result.error) {
        throw result.error;
    }

    const stderr = result.stderr.toString();
    if (stderr) {
        throw stderr;
    }

    await move(`${paths.jail}/coverage/merged/kcov-merged`, paths.coverage);

    clearJail();
});
