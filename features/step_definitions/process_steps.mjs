import {After, Before, Given, Then, When} from '@cucumber/cucumber';
import {strict as assert} from 'assert';
import {spawnSync} from 'child_process';
import {ensureDir, exists, outputFile, remove} from 'fs-extra';
import * as paths from '../support/paths.mjs';

Given('the working directory is {string}', async function (directory) {
    directory = paths.replace(directory);
    await paths.ensureInRoot(directory);
    await ensureDir(directory);
    this.workingDir = directory;
});

Given('an environment variable {string} set to {string}', function (name, value) {
    this.env = this.env || {};
    this.env[name] = value;
});

async function run(command, env = {}) {
    command = paths.replace(command);

    // Merge with default environment vars
    env = {
        HOME: `${paths.root}/home/user`,
        PATH: `${paths.root}/usr/bin:${paths.root}/global/bin`,
        BIN_DEBUG_LOG: `${paths.temp}/debug.txt`,
        RUST_BACKTRACE: '1',
        ...env,
        ...(this.env || {}),
    };

    // Write the command to a file to be displayed by the 'bin/tdd' script if the test fails
    let env_string = '';
    for (let [key, value] of Object.entries(env)) {
        env_string += `${key}='${value}' \\\n`;
    }

    await outputFile(`${paths.temp}/command.txt`, `cd ${this.workingDir}\n${env_string}${command}\n`);

    const result = spawnSync(command, {
        cwd: this.workingDir,
        env,
        shell: true,
        stdio: ['ignore', 'pipe', 'pipe'],
    });

    if (result.error) {
        throw result.error;
    }

    const status = result.status;

    // Write the output to files to be displayed by the 'bin/tdd' script if the test fails
    const stdout = result.stdout.toString();
    await outputFile(`${paths.temp}/stdout.txt`, stdout);

    const stderr = result.stderr.toString();
    await outputFile(`${paths.temp}/stderr.txt`, stderr);

    this.runResult = {status, stdout, stderr};
}

When('I run {string}', run);

When('I tab complete {string}', function (input) {
    return run.call(this, `bin --complete-bash -- "${input}" ${input}`);
});

When('I tab complete {string} with arguments {string}', function (input, args) {
    return run.call(this, `bin ${args} --complete-bash -- "${input}" ${input}`);
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

Then('the output contains:', function (expected) {
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

Before({name: 'Remove temp files'}, async function (hook) {
    await remove(`${paths.temp}/command.txt`);
    await remove(`${paths.temp}/stdout.txt`);
    await remove(`${paths.temp}/stderr.txt`);
    await remove(`${paths.temp}/debug.txt`);
});

After({name: 'Remove temp files', tags: 'not @exit'}, async function (hook) {
    // If the test failed, keep the temp files for inspection
    if (hook.result.status === 'FAILED') {
        return 'skipped';
    }

    await remove(`${paths.temp}/command.txt`);
    await remove(`${paths.temp}/stdout.txt`);
    await remove(`${paths.temp}/stderr.txt`);
    await remove(`${paths.temp}/debug.txt`);
});
