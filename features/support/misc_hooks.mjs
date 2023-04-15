import {After} from '@cucumber/cucumber';

After({ name: '@exit', tags: '@exit' }, async function () {
    // Exit early, without cleaning up tmp/, for manual debugging
    console.log();
    process.exit();
});
