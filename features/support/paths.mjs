import {dirname} from 'path';
import {fileURLToPath} from 'url';
import fs from 'fs-extra';

export const bin = dirname(dirname(dirname(fileURLToPath(import.meta.url))));
export const temp = `${bin}/temp`;
export const coverage = `${temp}/coverage`;
export const dist = `${temp}/dist`;
export const root = `${temp}/root`;

export function replace(string) {
    return string.replace(/\{ROOT}/g, root);
}

export async function ensureInRoot(path) {
    if (path[0] !== '/') {
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
