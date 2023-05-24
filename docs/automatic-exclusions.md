# Automatic exclusions

Scripts starting with `_` (underscore) are excluded from listings, but can be executed. This can be used for helper scripts that are not intended to be executed directly. (Or you could use a separate [`libexec` directory](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s07.html) if you prefer.)

Files starting with `.` (dot / period) are always ignored and cannot be executed with *Bin*.

Files that are not executable (not `chmod +x`) are listed as warnings, and will error if you try to run them. The exception is when using `root=.`, where they are just ignored.

A number of common non-executable file types (`*.json`, `*.md`, `*.yml` and so on) are also excluded from listings when using `root=.`, even if they are executable, to reduce the noise when all files are executable (e.g. on FAT32 filesystems).

The directories `/bin`, `/snap/bin`, `/usr/bin`, `/usr/local/bin` and `~/bin` are ignored when searching parent directories, unless there is a corresponding `.binconfig` file, because they are common locations for global executables.
