import {Given} from '@cucumber/cucumber';
import {createSymlink, ensureDir, outputFile} from 'fs-extra';
import {dirname, relative} from 'path';
import requireAbsolutePath from '../support/requireAbsolutePath.mjs';
import * as paths from '../support/paths.mjs';

Given('an empty directory {string}', async function (directory) {
    requireAbsolutePath(directory);
    await ensureDir(paths.jail + directory);
});

Given('a script {string}', async function (file) {
    requireAbsolutePath(file);
    await outputFile(paths.jail + file, `#!/usr/bin/sh\necho "This should not be executed" >&2\nexit 1\n`, {mode: 0o777});
});

Given('a script {string} with content:', async function (file, content) {
    requireAbsolutePath(file);
    await outputFile(paths.jail + file, `${content}\n`, {mode: 0o777});
});

Given('a script {string} that outputs {string}', async function (file, message) {
    requireAbsolutePath(file);
    await outputFile(paths.jail + file, `#!/usr/bin/sh\necho "${message}"\n`, {mode: 0o777});
});

Given('an empty file {string}', async function (file) {
    requireAbsolutePath(file);
    await outputFile(paths.jail + file, '');
});

Given('a file {string} with content:', async function (file, content) {
    requireAbsolutePath(file);
    await outputFile(paths.jail + file, `${content}\n`);
});

Given('a file {string} with content {string}', async function (file, content) {
    requireAbsolutePath(file);
    await outputFile(paths.jail + file, `${content}\n`);
});

Given('a symlink {string} pointing to {string}', async function (link, target) {
    requireAbsolutePath(link);
    requireAbsolutePath(target);
    await createSymlink(relative(dirname(paths.jail + link), paths.jail + target), paths.jail + link);
});
