process.chdir(`${__dirname}/..`);

const Gherkin = require('@cucumber/gherkin');
const Messages = require('@cucumber/messages');
const {spawnSync} = require('child_process');
const {readdirSync, readFileSync, writeFileSync} = require('fs');
const marked = require('marked');

const uuidFn = Messages.IdGenerator.uuid();
const builder = new Gherkin.AstBuilder(uuidFn);
const matcher = new Gherkin.GherkinClassicTokenMatcher();
const parser = new Gherkin.Parser(builder, matcher);

// Using the '| ' prefix to indicate Markdown lines because it ensures Cucumber
// treats all lines as text - otherwise '#' is treated as a comment. Maybe this
// is / will be fixed in a later version, since the docs say "Descriptions can
// be in the form of Markdown".
const lineRegex = /\r?\n/;
const markdownRegex = /^\s*\|\s?(.*)$/;

function extractPrefixedMarkdown(content) {
    const lines = [];

    if (!content) {
        return '';
    }

    for (const line of content.split(lineRegex)) {
        const matches = line.match(markdownRegex);
        if (matches) {
            lines.push(matches[1]);
        }
    }

    let detailsTitle = null;
    if (lines[0].startsWith('COLLAPSE:')) {
        // GFM doesn't support Markdown inside HTML blocks, so transform the title now
        detailsTitle = marked.parseInline(lines.shift().slice(9).trim());
    }

    let markdown = lines.join('\n').trim();
    if (detailsTitle) {
        markdown = `<details><summary><em>${detailsTitle}</em></summary><blockquote>\n\n${markdown}\n\n</blockquote></details>`;
    }

    return markdown;
}

const markdownBlocks = [];

function addPrefixedBlock(block) {
    const markdown = extractPrefixedMarkdown(block);
    if (markdown) {
        markdownBlocks.push(markdown);
    }
}

function addFeatureFile(filename) {
    markdownBlocks.push(`<!-- ${filename} -->`);

    const fileContent = readFileSync(filename, 'utf8');
    const gherkinDocument = parser.parse(fileContent);

    if (gherkinDocument.feature.description) {
        addPrefixedBlock(gherkinDocument.feature.description);
    }

    for (const child of gherkinDocument.feature.children) {
        if (child.rule) {
            addPrefixedBlock(child.rule.description);
        }
        if (child.scenario) {
            addPrefixedBlock(child.scenario.description);
        }
    }
}

function addMarkdownFile(filename) {
    markdownBlocks.push(`<!-- ${filename} -->`);
    markdownBlocks.push(readFileSync(filename, 'utf8').trim());
}

markdownBlocks.push(`<!--\nThis file was automatically generated.\nDo not edit it directly.\n-->`);

for (const filename of readdirSync('features')) {
    if (filename.match(/\.feature$/)) {
        addFeatureFile(`features/${filename}`);
    } else if (filename.match(/\.md$/)) {
        addMarkdownFile(`features/${filename}`);
    }
}

let markdown = markdownBlocks.join('\n\n') + '\n';

function getOutput(command) {
    const result = spawnSync(command, {
        cwd: this.workingDir,
        env: {},
        shell: true,
    });

    if (result.error) {
        throw result.error;
    }

    return result.stdout.toString();
}

function replaceBlock(content, tag, output) {
    const startTag = `<!-- START ${tag} -->`;
    const endTag = `<!-- END ${tag} -->`;

    const startPos = content.indexOf(startTag);
    const endPos = content.indexOf(endTag);

    if (startPos < 0) {
        throw new Error(`Start tag ${startTag} not found`);
    }

    if (endPos < 0) {
        throw new Error(`End tag ${endTag} not found`);
    }

    if (startPos > endPos) {
        throw new Error(`Start tag ${startTag} appears after end tag ${endTag}`);
    }

    return content.slice(0, startPos + startTag.length) + output + content.slice(endPos);
}

const help = getOutput('src/bin --help').replace('v1.2.3-source', 'main');

markdown = replaceBlock(
    markdown,
    'auto-update-cli-reference',
    '\n\n```\n' + help + '```\n\n'
);

writeFileSync('README.md', markdown);
