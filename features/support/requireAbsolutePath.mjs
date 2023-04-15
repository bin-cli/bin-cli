export default function requireAbsolutePath(path) {
    if (path[0] !== '/') {
        throw new Error(`Path must be absolute (within the jail): ${path}`);
    }
}
