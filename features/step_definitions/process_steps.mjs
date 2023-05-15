import {Given, setDefaultTimeout, Then, When} from '@cucumber/cucumber';
import {strict as assert} from 'assert';
import {spawnSync} from 'child_process';
import {ensureDir, exists, outputFile} from 'fs-extra';
import {move} from 'fs-extra/lib/move/index.js';
import * as paths from '../support/paths.mjs';
import * as coverage from '../support/coverage.mjs';
import {platform} from 'os';

Given('the working directory is {string}', async function (directory) {
    directory = paths.replace(directory);
    await paths.ensureInRoot(directory);
    await ensureDir(directory);
    this.workingDir = directory;
});

async function run(command, env = {}) {
    command = paths.replace(command);

    // Merge with default environment vars
    env = {
        HOME: `${paths.root}/home/user`,
        PATH: `${paths.root}/usr/bin:${process.env.PATH}`,
        BIN_TEST_ROOT: paths.root,
        ...env,
    };

    // Use kcov to measure code coverage
    // Except on one particular test where it doesn't work
    // And it's is really slow on macOS (even with --include-path), so disable it there completely
    let kcovId;

    if (!this.disableKcov && platform() !== 'darwin') {
        await ensureDir(paths.coverage);

        kcovId = coverage.nextId();

        command = [
            'kcov',
            // Using --collect-only doesn't work in kcov 38
            // https://github.com/SimonKagstrom/kcov/issues/342
            // '--collect-only',
            // --debug-force-bash-stderr seems to be required to pass through the stdout/stderr
            // https://github.com/SimonKagstrom/kcov/issues/362#issuecomment-962489973
            '--debug-force-bash-stderr',
            `--include-path=${paths.root}/usr/bin/bin`,
            '--path-strip-level=0',
            `${paths.coverage}/result-${kcovId}`,
        ].join(' ') + ' ' + command;
    }

    // Write the command to a file to be displayed by the 'bin/tdd' script if the test fails
    let env_string = '';
    for (let [key, value] of Object.entries(env)) {
        env_string += `${key}='${value}' \\\n`;
    }

    await outputFile(`${paths.root}/command.txt`, `cd ${this.workingDir}\n${env_string}${command}\n`);

    const result = spawnSync(command, {
        cwd: this.workingDir,
        env,
        shell: true,
        stdio: ['pipe', 'pipe', 'pipe', 'pipe'],
    });

    if (result.error) {
        throw result.error;
    }

    const status = result.status;

    // Write the output to files to be displayed by the 'bin/tdd' script if the test fails
    const stdout = result.stdout.toString();
    await outputFile(`${paths.root}/stdout.txt`, stdout);

    const stderr = result.stderr.toString();
    await outputFile(`${paths.root}/stderr.txt`, stderr);

    const debugLog = result.output[3].toString();
    await outputFile(`${paths.root}/debug.txt`, debugLog);

    this.runResult = {status, stdout, stderr};

    // Stash the code coverage results for merging later
    if (!this.disableKcov && await exists(`${paths.root}/coverage/result-${kcovId}`)) {
        await move(`${paths.coverage}/result-${kcovId}`, `${paths.coverage}/result-${kcovId}`);
    }
}

When('I run {string}', run);

When('I tab complete {string}', function (input) {
    const COMP_POINT = input.includes('|') ? input.indexOf('|') : input.length;
    const COMP_LINE = input.slice(0, COMP_POINT) + input.slice(COMP_POINT + 1);

    return run.call(this, 'bin --complete-bash', {COMP_LINE, COMP_POINT});
});

Then('it is successful', function () {
    // Check stderr before status because that is generally more useful for debugging
    assert.equal(this.runResult.stderr, '');
    assert.equal(this.runResult.status, 0);
});

Then('it fails with exit code {int}', function (expected) {
    assert.equal(this.runResult.stdout, '');
    assert.equal(this.runResult.status, expected);
});

Then('the exit code is {int}', function (expected) {
    assert.equal(this.runResult.status, expected);
});

Then('there is no output', function () {
    assert.equal(this.runResult.stdout, '');
});

Then('the output is:', function (expected) {
    expected = paths.replace(expected);
    assert.equal(this.runResult.stdout, `${expected}\n`);
});

Then('the output is {string}', function (expected) {
    expected = paths.replace(expected);
    assert.equal(this.runResult.stdout, `${expected}\n`);
});

Then('the output contains {string}', function (expected) {
    expected = paths.replace(expected);
    const actual = this.runResult.stdout;
    assert(actual.includes(expected), `Expected string to contain "${expected}":\n\n${actual}`);
});

Then('there is no error', function () {
    assert.equal(this.runResult.stderr, '');
});

Then('the error is:', function (expected) {
    expected = paths.replace(expected);
    assert.equal(this.runResult.stderr, `${expected}\n`);
});

Then('the error is {string}', function (expected) {
    expected = paths.replace(expected);
    assert.equal(this.runResult.stderr, `${expected}\n`);
});
