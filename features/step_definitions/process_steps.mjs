import {Given, Then, When} from '@cucumber/cucumber';
import {strict as assert} from 'assert';
import {spawnSync} from 'child_process';
import {ensureDir, outputFile} from 'fs-extra';
import {quote} from 'shell-quote';
import requireAbsolutePath from '../support/requireAbsolutePath.mjs';

Given('the working directory is {string}', async function (directory) {
    requireAbsolutePath(directory);
    await ensureDir(this.jailDir + directory);
    this.workingDir = directory;
});

When('I run {string}', async function (command) {

    // Write the command to a file to be displayed by the 'bin/tdd' script if the test fails
    await outputFile(this.jailDir + '/command.txt', `cd ${this.workingDir}\n${command}\n`);

    const fullCommand = quote([
        'fakechroot',
        // 'fakeroot',
        'chroot',
        this.jailDir,
        '/bin/sh',
        '-c',
        quote(['cd', this.workingDir]) + ' && ' + command,
    ]);

    const result = spawnSync(fullCommand, {
        env: {
            HOME: '/home/user',
            PATH: '/usr/local/bin:/usr/bin:/bin',
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
    await outputFile(this.jailDir + '/stdout.txt', stdout);

    const stderr = result.stderr.toString();
    await outputFile(this.jailDir + '/stderr.txt', stderr);

    const debugLog = result.output[3].toString();
    await outputFile(this.jailDir + '/debug.txt', debugLog);

    this.runResult = { status, stdout, stderr };
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
