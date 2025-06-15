use crate::arguments::Arguments;
use crate::version;

pub(crate) fn display(arguments: &Arguments) {
    // Also update the man page - src/bin.1.md
    println!("Usage: {} [OPTIONS] [--] [COMMAND] [ARGUMENTS...]", arguments.exe_name());
    println!();
    println!("Options that can be used with a command:");
    println!("  --dir DIR             Specify the directory name to search for (overrides .binconfig)");
    println!("  --exact               Disable unique prefix matching");
    println!("  --exe NAME            Override the executable name displayed in the command list");
    println!("  --fallback COMMAND    If the command is not found, run the given global command (implies '--exact')");
    println!("  --no-exact, --prefix  Enable unique prefix matching (overrides .binconfig)");
    println!("  --shim                If the command is not found, run the global command with the same name (implies '--exact')");
    println!();
    println!("Options that do something with a COMMAND:");
    println!("  --create, -c          Create the given script and open in your $EDITOR (implies '--exact')");
    println!("  --edit, -e            Open the given script in your $EDITOR");
    println!();
    println!("Options that do something special and don't accept a COMMAND:");
    println!("  --completion          Output a tab completion script for the current shell");
    println!("  --info                Display information about the current project (root, bin directory and config file location)");
    println!("  --help, -h            Display this help");
    println!("  --version, -v         Display the current version number");
    println!();
    println!("Any options must be given before the command, because everything after the command will be passed as parameters to the script.");
    println!();
    println!("For more details see https://github.com/bin-cli/bin-cli/tree/v{}#readme", version::version());
}
