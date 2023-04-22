import {dirname} from 'path';
import {fileURLToPath} from 'url';

export const root = dirname(dirname(dirname(fileURLToPath(import.meta.url))));

export const jail = `${root}/jail`;
export const coverage = `${root}/coverage`;
