import replaceAll from 'string.prototype.replaceall';

// Added in Node.js v15
if (!('replaceAll' in String.prototype)) {
    String.prototype.replaceAll = function(...args) {
        return replaceAll(this, ...args);
    }
}
