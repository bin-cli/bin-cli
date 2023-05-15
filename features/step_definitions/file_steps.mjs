import {Given} from '@cucumber/cucumber';
import * as fs from 'fs';
import {ensureDir, outputFile} from 'fs-extra';
import {dirname} from 'path';
import {promisify} from 'util';
import * as paths from '../support/paths.mjs';

const symlink = promisify(fs.symlink);

Given('an empty directory {string}', async function (directory) {
    directory = paths.replace(directory);
    await paths.ensureInRoot(directory);
    await ensureDir(directory);
});

Given('a script {string}', async function (file) {
    file = paths.replace(file);
    await paths.ensureInRoot(file);
    await outputFile(file, `#!/bin/sh\necho "This should not be executed" >&2\nexit 222\n`, {mode: 0o777});
});

Given('a script {string} with content:', async function (file, content) {
    file = paths.replace(file);
    await paths.ensureInRoot(file);
    await outputFile(file, `${content}\n`, {mode: 0o777});
});

Given('a script {string} that outputs {string}', async function (file, message) {
    file = paths.replace(file);
    await paths.ensureInRoot(file);
    await outputFile(file, `#!/bin/sh\necho "${message}"\n`, {mode: 0o777});
});

Given('an empty file {string}', async function (file) {
    file = paths.replace(file);
    await paths.ensureInRoot(file);
    await outputFile(file, '');
});

Given('a file {string} with content:', async function (file, content) {
    file = paths.replace(file);
    await paths.ensureInRoot(file);
    await outputFile(file, `${content}\n`);
});

Given('a file {string} with content {string}', async function (file, content) {
    file = paths.replace(file);
    await paths.ensureInRoot(file);
    await outputFile(file, `${content}\n`);
});

Given('a symlink {string} pointing to {string}', async function (link, target) {
    link = paths.replace(link);
    target = paths.replace(target);
    await paths.ensureInRoot(link);
    await ensureDir(dirname(link));
    // Can't use createSymlink() from 'fs-extra' because it requires target to exist
    await symlink(target, link);
});
