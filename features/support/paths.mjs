import {dirname, isAbsolute} from 'path';
import {fileURLToPath} from 'url';
import fs from 'fs-extra';

export const bin = dirname(dirname(dirname(fileURLToPath(import.meta.url))));
export const dist = `${bin}/dist`;
export const temp = `${bin}/temp`;
export const coverage = `${temp}/coverage`;
export const root = `${temp}/root`;

export function replace(string) {
    return string.replaceAll('{ROOT}', root);
}

export async function ensureInRoot(path) {
    if (!isAbsolute(path)) {
        throw new Error(`Path '${path}' must be absolute (use '{ROOT}' placeholder)`);
    }

    if (!path.startsWith(root)) {
        throw new Error(`Path '${path}' must be within '${root}' (use '{ROOT}' placeholder)`);
    }

    // Importing {realpath} directly doesn't seem to work
    if ((await fs.pathExists(path)) && !(await fs.realpath(path)).startsWith(root)) {
        throw new Error(`Realpath for '${path}' must be within '${root}' (use '{ROOT}' placeholder)`);
    }
}
