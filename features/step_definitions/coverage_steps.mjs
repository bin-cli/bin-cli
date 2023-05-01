import {Given} from '@cucumber/cucumber';
import * as paths from '../support/paths.mjs';
import {move} from 'fs-extra/lib/move/index.js';
import {quote} from 'shell-quote';
import {spawnSync} from 'child_process';
import {createRequire} from 'module';

Given('code coverage must be at least {float}%', async function (minPercent) {

    // We have to use the jail to merge the results - otherwise the paths are wrong
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

    // Check we have 100% coverage (excluding ignored lines/sections)
    const require = createRequire(import.meta.url);
    const coverage = require(`${paths.coverage}/coverage.json`);

    if (coverage.percent_covered < minPercent) {
        throw new Error(`Test coverage dropped to ${coverage.percent_covered}%`);
    }
});
