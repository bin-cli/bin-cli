import * as paths from '../support/paths.mjs';
import {quote} from 'shell-quote';
import {spawnSync} from 'child_process';
import {createRequire} from 'module';
import {Then} from '@cucumber/cucumber';

Then('Code coverage must be at least {float}%', async function (minPercent) {

    if (process.env.DISABLE_KCOV) {
        return 'skipped';
    }

    const command = [
        'kcov',
        '--exclude-line=kcov-ignore-line',
        '--exclude-region=kcov-ignore-start:kcov-ignore-end',
        '--path-strip-level=0',
        '--merge',
        quote([`${paths.coverage}/merged`]),
        quote([`${paths.coverage}/result-`]) + '*',
    ].join(' ');

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

    // Check we have 100% coverage (excluding ignored lines/sections)
    const require = createRequire(import.meta.url);
    const coverage = require(`${paths.coverage}/merged/kcov-merged/coverage.json`);

    if (coverage.percent_covered < minPercent) {
        throw new Error(`Test coverage dropped to ${coverage.percent_covered}%`);
    }
});
