import {Then} from '@cucumber/cucumber';
import * as paths from '../support/paths.mjs';
import {quote} from 'shell-quote';
import {spawnSync} from 'child_process';

Then('ShellCheck must report no errors', async function () {

    const command = quote([
        'shellcheck',
        '--color',
        // See 'shellcheck --list-optional' for all the optional tests available
        '--enable=add-default-case',
        '--enable=avoid-nullary-conditions',
        '--enable=check-extra-masked-returns',
        // '--enable=check-set-e-suppressed', // Can't see any good ways to solve these!
        '--enable=check-unassigned-uppercase',
        '--enable=deprecate-which',
        '--enable=quote-safe-variables',
        '--enable=require-double-brackets',
        // '--enable=require-variable-braces', // Too verbose
        `${paths.dist}/bin`,
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

    if (result.status !== 0) {
        const stdout = result.stdout.toString();
        if (stdout) {
            throw stdout;
        }
    }
});
