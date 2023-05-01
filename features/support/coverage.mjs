import {Before, BeforeAll} from '@cucumber/cucumber';
import {emptyDir} from 'fs-extra';
import * as paths from './paths.mjs';

let id = 1;

export function nextId() {
    return id++;
}

BeforeAll(async function () {
    await emptyDir(paths.coverage);
});

Before({tags: '@disable-kcov', name: 'Disable kcov'}, function () {
    this.disableKcov = true;
});
