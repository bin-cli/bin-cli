import {Given, Then, When} from '@cucumber/cucumber';
import {strict as assert} from 'assert';
import {spawnSync} from 'child_process';
import {ensureDir, exists, outputFile} from 'fs-extra';
import {quote} from 'shell-quote';
import requireAbsolutePath from '../support/requireAbsolutePath.mjs';
import {move} from 'fs-extra/lib/move/index.js';
import * as paths from '../support/paths.mjs';
import * as coverage from '../support/coverage.mjs';

Given('the working directory is {string}', async function (directory) {
    requireAbsolutePath(directory);
    await ensureDir(paths.jail + directory);
    this.workingDir = directory;
});

Given('kcov is disabled', function () {
    this.kcov = false;
});

When('I run {string}', async function (command) {

    // Write the command to a file to be displayed by the 'bin/tdd' script if the test fails
    await outputFile(paths.jail + '/command.txt', `cd ${this.workingDir}\n${command}\n`);

    // Use kcov to measure code coverage
    let kcovId;

    if (this.kcov) {
        await ensureDir(`${paths.jail}/coverage`);

        kcovId = coverage.nextId();

        command = [
            'kcov',
            '--bash-parser=/usr/bin/bash',
            // Using --collect-only doesn't work in kcov 38
            // https://github.com/SimonKagstrom/kcov/issues/342
            // '--collect-only',
            // --debug-force-bash-stderr seems to be required to pass through the stdout/stderr
            // https://github.com/SimonKagstrom/kcov/issues/362#issuecomment-962489973
            '--debug-force-bash-stderr',
            '--include-path=/usr/bin/bin',
            '--path-strip-level=0',
            `/coverage/result-${kcovId}`,
        ].join(' ') + ' ' + command;
    }

    // Use chroot to create a self-contained environment not affected by the local system contents
    // Use fakechroot so it works as a normal user, rather than requiring sudo
    command = quote([
        'fakechroot',
        // 'fakeroot', // Not needed, and breaks kcov
        'chroot',
        paths.jail,
        '/usr/bin/sh',
        '-c',
        quote(['cd', this.workingDir]) + ' && ' + command,
    ]);

    const result = spawnSync(command, {
        env: {
            HOME: '/home/user',
            PATH: '/usr/bin',
        },
        shell: true,
        stdio: ['pipe', 'pipe', 'pipe', 'pipe'],
        timeout: 1_000,
    });

    if (result.error) {
        throw result.error;
    }

    const status = result.status;

    // Write the output to files to be displayed by the 'bin/tdd' script if the test fails
    const stdout = result.stdout.toString();
    await outputFile(`${paths.jail}/stdout.txt`, stdout);

    const stderr = result.stderr.toString();
    await outputFile(`${paths.jail}/stderr.txt`, stderr);

    const debugLog = result.output[3].toString();
    await outputFile(`${paths.jail}/debug.txt`, debugLog);

    this.runResult = {status, stdout, stderr};

    // Stash the code coverage results for merging later
    if (this.kcov && await exists(`${paths.jail}/coverage/result-${kcovId}`)) {
        await move(`${paths.jail}/coverage/result-${kcovId}`, `${paths.coverage}/result-${kcovId}`);
    }
});

Then('it is successful', function () {
    // Check stderr before status because that is generally more useful for debugging
    assert.equal(this.runResult.stderr, '');
    assert.equal(this.runResult.status, 0);
});

Then('the exit code is {int}', function (expected) {
    assert.equal(this.runResult.status, expected);
});

Then('there is no output', function () {
    assert.equal(this.runResult.stdout, '');
});

Then('the output is:', function (expected) {
    assert.equal(this.runResult.stdout, `${expected}\n`);
});

Then('the output is {string}', function (expected) {
    assert.equal(this.runResult.stdout, `${expected}\n`);
});

Then('the output contains {string}', function (expected) {
    const actual = this.runResult.stdout;
    assert(actual.includes(expected), `Expected string to contain "${expected}":\n\n${actual}`);
});

Then('there is no error', function () {
    assert.equal(this.runResult.stderr, '');
});

Then('the error is:', function (expected) {
    assert.equal(this.runResult.stderr, `${expected}\n`);
});

Then('the error is {string}', function (expected) {
    assert.equal(this.runResult.stderr, `${expected}\n`);
});
