import {After} from "@cucumber/cucumber";
import * as paths from "./paths.mjs";
import {promisify} from "util";
import fs from "fs";

const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);

async function autoUpdate(filename, tag, output) {
    const content = await readFile(filename, 'utf-8');

    const startTag = `<!-- START ${tag} -->`;
    const endTag = `<!-- END ${tag} -->`;

    const startPos = content.indexOf(startTag);
    const endPos = content.indexOf(endTag);

    if (startPos < 0) {
        throw new Error(`Start tag ${startTag} not found in ${filename}`);
    }

    if (endPos < 0) {
        throw new Error(`End tag ${endTag} not found in ${filename}`);
    }

    if (startPos > endPos) {
        throw new Error(`Start tag ${startTag} appears after end tag ${endTag} in ${filename}`);
    }

    const newContent = content.slice(0, startPos + startTag.length) + output + content.slice(endPos);

    await writeFile(filename, newContent);
}

After({tags: '@auto-update-cli-reference-docs'}, async function (hook) {
    if (hook.result.status === 'FAILED') {
        return 'skipped';
    }

    await autoUpdate(
        `${paths.bin}/README.md`,
        'auto-update-cli-reference-docs',
        '\n\n```\n' + this.runResult.stdout + '```\n\n',
    );
});
