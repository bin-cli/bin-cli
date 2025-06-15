use std::ffi::OsString;
use os_str_bytes::OsStrBytesExt;
use crate::arguments::Arguments;

use crate::errors::Error;
use crate::inventory::Inventory;
use crate::matching_commands::MatchingCommands;
use crate::options::Options;

pub(crate) fn print_completion_script(arguments: &Arguments) {
    let exe = arguments.exe_name();

    // 'complete -C' would require us to manually parse COMP_LINE, which is non-trivial,
    // as it only passes $0, the current word and the previous word.
    // https://www.reddit.com/r/bash/comments/qyr8sj/understanding_c_command_for_completions/hlhr026/
    // So we'll generate a small function that passes the arguments we actually need.
    // This doesn't handle quoted arguments well - but it's good enough for now.
    println!("_{exe}() {{");
    println!("  local args=${{COMP_LINE:0:COMP_POINT}}");

    // We can't use 'exe' because it may be an alias which won't be expanded
    print!("  COMPREPLY=( $({}", arguments.real_exe().display());

    if let Some(custom_exe_name) = &arguments.custom_exe_name {
        print!(" --exe '{}'", custom_exe_name)
    }

    if let Some(fixed_bin_dir) = &arguments.fixed_bin_dir {
        print!(" --dir '{}'", fixed_bin_dir.to_string_lossy())
    }

    // We need both the original version so we can check for a trailing space,
    // and the split version so can loop through the arguments.
    print!(" --complete-bash -- \"$args\" $args");
    println!(") )");

    println!("}}");

    println!("complete -F _{exe} -o default {exe}");
}

pub(crate) fn complete_for_bash(inventory: &Inventory, arguments: &Arguments) -> Result<(), Error> {
    let typed_input = &arguments.remaining[0];
    let mut typed_args: Vec<OsString> = arguments.remaining[1..].to_vec();
    if typed_input.ends_with(' ') {
        typed_args.push(OsString::from(""));
    }

    let typed_arguments = Arguments::parse(&typed_args[..]);
    let typed_options = Options::generate(inventory, &typed_arguments);

    let matches = MatchingCommands::find(
        &inventory.commands,
        &typed_arguments.remaining,
        typed_options.unique_prefix_matching,
    );

    if matches.arguments.is_empty() {
        for command in matches.commands() {
            println!("{}", command.name);
        }
    }

    Ok(())
}
