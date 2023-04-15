import {Given, Then, When} from '@cucumber/cucumber';
import {strict as assert} from 'assert';
import {spawnSync} from 'child_process';
import {ensureDir} from 'fs-extra';
import {quote} from 'shell-quote';
import requireAbsolutePath from '../support/requireAbsolutePath.mjs';

Given('the working directory is {string}', async function (directory) {
    requireAbsolutePath(directory);
    await ensureDir(this.jailDir + directory);
    this.workingDir = directory;
});

When('I run {string}', function (command) {
    command = quote([
        'fakechroot',
        // 'fakeroot',
        'chroot',
        this.jailDir,
        '/bin/sh',
        '-c',
        quote(['cd', this.workingDir]) + ' && ' + command,
    ]);

    this.runResult = spawnSync(command, {
        env: {
            HOME: '/home/user',
            PATH: '/usr/local/bin:/usr/bin:/bin',
        },
        shell: true,
        timeout: 1_000,
    });

    if (this.runResult.error) {
        throw this.runResult.error;
    }
});

Then('it is successful', function () {
    // Check stderr before status because that is generally more useful for debugging
    assert.equal(this.runResult.stderr.toString(), '');
    assert.equal(this.runResult.status, 0);
});

Then('the exit code is {int}', function (expected) {
    assert.equal(this.runResult.status, expected);
});

Then('there is no output', function () {
    assert.equal(this.runResult.stdout.toString(), '');
});

Then('the output is:', function (expected) {
    assert.equal(this.runResult.stdout.toString(), `${expected}\n`);
});

Then('the output is {string}', function (expected) {
    assert.equal(this.runResult.stdout.toString(), `${expected}\n`);
});

Then('the output contains {string}', function (expected) {
    const actual = this.runResult.stdout.toString();
    assert(actual.includes(expected), `Expected string to contain "${expected}":\n\n${actual}`);
});

Then('there is no error', function () {
    assert.equal(this.runResult.stderr.toString(), '');
});

Then('the error is:', function (expected) {
    assert.equal(this.runResult.stderr.toString(), `${expected}\n`);
});

Then('the error is {string}', function (expected) {
    assert.equal(this.runResult.stderr.toString(), `${expected}\n`);
});
