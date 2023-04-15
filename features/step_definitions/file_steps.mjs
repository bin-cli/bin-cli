import {Given} from '@cucumber/cucumber';
import {createSymlink, ensureDir, outputFile} from 'fs-extra';
import {dirname, relative} from 'path';
import requireAbsolutePath from '../support/requireAbsolutePath.mjs';

Given('an empty directory {string}', async function (directory) {
    requireAbsolutePath(directory);
    await ensureDir(this.jailDir + directory);
});

Given('a script {string}', async function (file) {
    requireAbsolutePath(file);
    await outputFile(this.jailDir + file, `#!/bin/sh\necho "This should not be executed" >&2\nexit 1\n`, { mode: 0o777 });
});

Given('a script {string} with content:', async function (file, content) {
    requireAbsolutePath(file);
    await outputFile(this.jailDir + file, `${content}\n`, { mode: 0o777 });
});

Given('a script {string} that outputs {string}', async function (file, message) {
    requireAbsolutePath(file);
    await outputFile(this.jailDir + file, `#!/bin/sh\necho <<<'END'\n${message}\nEND\n`, { mode: 0o777 });
});

Given('an empty file {string}', async function (file) {
    requireAbsolutePath(file);
    await outputFile(this.jailDir + file, '');
});

Given('a file {string} with content:', async function (file, content) {
    requireAbsolutePath(file);
    await outputFile(this.jailDir + file, `${content}\n`);
});

Given('a file {string} with content {string}', async function (file, content) {
    requireAbsolutePath(file);
    await outputFile(this.jailDir + file, `${content}\n`);
});

Given('a symlink {string} pointing to {string}', async function (link, target) {
    requireAbsolutePath(link);
    requireAbsolutePath(target);
    await createSymlink(relative(dirname(this.jailDir + link), this.jailDir + target), this.jailDir + link);
});
