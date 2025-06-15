mod arguments;
mod commands;
mod completion;
mod config_file;
mod debug;
mod errors;
mod help;
mod inventory;
mod matching_commands;
mod options;
mod version;

use crate::arguments::Action;
use crate::arguments::Arguments;
use crate::commands::CommandVariant;
use crate::errors::Error;
use crate::matching_commands::{MatchingCommands, MatchingCommandsKind};
use crate::options::Options;
use inventory::Inventory;
use nix::errno::Errno;
use nix::unistd;
use std::env;
use std::ffi::{CString, OsString};
use std::os::unix::ffi::OsStringExt;
use std::process::ExitCode;

fn main() -> ExitCode {
    let args_os: Vec<OsString> = env::args_os().collect();
    let arguments = Arguments::parse(&args_os);

    match run(&arguments) {
        Ok(_) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{}: {}", arguments.exe_name(), error.message());
            ExitCode::from(error.exit_code())
        }
    }
}

fn run(arguments: &Arguments) -> Result<(), Error> {
    // Handle simple actions that don't require us to parse config files or register commands
    match arguments.action {
        Action::Version => {
            version::display();
            return Ok(());
        }
        Action::Help => {
            help::display(arguments);
            return Ok(());
        }
        Action::CompletionScript => {
            completion::print_completion_script(arguments);
            return Ok(());
        }
        _ => {}
    }

    // Find the bin/ directory, parse config files and register commands
    let inventory = Inventory::register(arguments)?;

    // Handle tab completion
    if arguments.action == Action::CompleteForBash {
        completion::complete_for_bash(&inventory, arguments)?;
        return Ok(());
    }

    // Determine the final options
    let options = Options::generate(&inventory, arguments);

    // Work out which command(s) match the given arguments
    let matches = MatchingCommands::find(
        &inventory.commands,
        &arguments.remaining,
        options.unique_prefix_matching,
    );

    // If there are no matches, display an error
    if matches.kind == MatchingCommandsKind::NoMatches {
        if let Some(name) = matches.name {
            return Err(Error::NotFound(format!(
                // TODO: Add the correct paths
                "Command '{}' not found in /tmp/bin-cli/root/project/bin/ or /tmp/bin-cli/root/project/.binconfig",
                name,
            )));
        }
    }

    // If there is a single match (exact or unique prefix), execute it
    if let Some(command) = &matches.executable_command(options.unique_prefix_matching) {
        match &command.variant {
            CommandVariant::Executable(path) => {
                let mut argv: Vec<CString> = matches
                    .arguments
                    .iter()
                    .map(|arg| CString::new(arg.clone().into_vec()).unwrap())
                    .collect();

                let path_cstr = CString::new(path.to_str().unwrap().as_bytes()).unwrap();
                argv.insert(0, path_cstr.clone());

                match unistd::execv(&path_cstr, &argv).unwrap_err() {
                    Errno::EPERM => {
                        return Err(Error::NotExecutable(format!(
                            // TODO: Better error message?
                            // TODO: Add the correct paths
                            "bin: Command '{}' not executable in /tmp/bin-cli/root/project/bin/ or /tmp/bin-cli/root/project/.binconfig",
                            matches.name.unwrap(),
                        )));
                    }
                    code => {
                        return Err(Error::Generic(format!(
                            // TODO: Better error message?
                            "bin: execv() failed with code {}",
                            code
                        )));
                    }
                }
            }
            CommandVariant::Subcommands(_) => unreachable!(),
        }
    }

    // List available commands
    let listing_title = match matches.kind {
        MatchingCommandsKind::AllCommands => "Available Commands",
        MatchingCommandsKind::Subcommands => "Available Subcommands",
        MatchingCommandsKind::PrefixMatches => "Matching Commands",
        MatchingCommandsKind::ExactMatch | MatchingCommandsKind::NoMatches => unreachable!(),
    };

    // TODO: ANSI colours
    println!("{}", listing_title);

    if matches.is_empty() {
        println!("None found");
    } else {
        let commands = matches.all_commands();

        let max_name_length = commands
            .iter()
            .map(|command| command.full_name.len()) // TODO: Use character count not byte count (and below)
            .max()
            .unwrap();

        for command in commands {
            print!("bin {}", command.full_name);
            if let Some(help) = &command.help {
                let padding = max_name_length - command.full_name.len() + 4;
                let spaces = " ".repeat(padding);
                print!("{}{}", spaces, help);
            }
            println!();
        }
    }

    Ok(())
}
