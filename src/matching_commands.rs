use crate::commands::{Command, CommandVariant, Commands};
use std::ffi::OsString;

#[derive(Debug)]
pub(crate) struct MatchingCommands<'a> {
    pub(crate) name: Option<String>,
    pub(crate) kind: MatchingCommandsKind,
    commands: Vec<&'a Command>,
    pub(crate) arguments: &'a [OsString],
}

#[derive(Debug, PartialEq)]
pub(crate) enum MatchingCommandsKind {
    AllCommands,
    Subcommands,
    PrefixMatches,
    ExactMatch,
    NoMatches,
}

impl MatchingCommands<'_> {
    pub(crate) fn find<'a>(
        commands: &'a Commands,
        arguments: &'a [OsString],
        unique_prefix_matching: bool,
    ) -> MatchingCommands<'a> {
        // No arguments to parse - just return a list of everything
        if arguments.is_empty() {
            return MatchingCommands {
                name: None,
                kind: MatchingCommandsKind::AllCommands,
                commands: commands.collect(),
                arguments,
            };
        }

        // Loop through the arguments
        let mut arguments_str = Vec::with_capacity(arguments.len());
        let mut parent = None;
        let mut children = commands;

        for (index, arg_osstr) in arguments.iter().enumerate() {
            if let Some(arg_str) = arg_osstr.to_str() {
                // Keep track of the arguments parsed so far for use in error messages
                arguments_str.push(arg_str.to_owned());

                // Find commands matching this argument - preferably an exact
                // match, otherwise any commands that start with it
                let (matches, is_exact_match) = Self::matching_children(children, arg_str);

                // If there are no matches, we'll need to display an error
                if matches.is_empty() {
                    return MatchingCommands {
                        name: Some(arguments_str.join(" ")),
                        kind: MatchingCommandsKind::NoMatches,
                        commands: vec![],
                        arguments: &arguments[index + 1..],
                    };
                }

                // If we matched a command that has subcommands, we now need to
                // search those commands for the next argument
                if is_exact_match || (unique_prefix_matching && matches.len() == 1) {
                    let command = matches[0];

                    if let CommandVariant::Subcommands(subcommands) = &command.variant {
                        parent = Some(command);
                        children = subcommands;
                        continue;
                    }
                }

                // Otherwise we return the command(s) that matched
                return MatchingCommands {
                    name: Some(arguments_str.join(" ")),
                    kind: match is_exact_match {
                        true => MatchingCommandsKind::ExactMatch,
                        false => MatchingCommandsKind::PrefixMatches,
                    },
                    commands: matches,
                    arguments: &arguments[index + 1..],
                };
            } else {
                unimplemented!("Non-UTF-8 argument '{}'", arg_osstr.display());
            }
        }

        // If we exited the loop without returning, we have exhausted the
        // arguments but still have subcommands to list
        MatchingCommands {
            name: Some(arguments_str.join(" ")),
            kind: MatchingCommandsKind::Subcommands,
            // For tab completion we need the parent; for listings either is fine
            commands: vec![parent.unwrap()],
            arguments: &[],
        }
    }

    fn matching_children<'a>(commands: &'a Commands, argument: &str) -> (Vec<&'a Command>, bool) {
        // If there is an exact match, return only that
        if let Some(subcommand) = commands.get(argument) {
            return (vec![subcommand], true);
        }

        // Otherwise return all commands that start with the argument
        // (If the argument is "", e.g. during tab completion, all will match)
        let results = commands
            .iter()
            .filter(|command| command.name.starts_with(argument))
            .collect();

        (results, false)
    }

    pub(crate) fn commands(&self) -> Vec<&Command> {
        let mut result = self.commands.clone();
        result.sort_unstable_by(|a, b| a.full_name.cmp(&b.full_name));
        result
    }

    pub(crate) fn all_commands(&self) -> Vec<&Command> {
        let mut result = Vec::new();

        for command in &self.commands {
            Self::flatten_commands(command, &mut result);
        }

        result.sort_unstable_by(|a, b| a.full_name.cmp(&b.full_name));

        result
    }

    fn flatten_commands<'a>(command: &'a Command, result: &mut Vec<&'a Command>) {
        if let CommandVariant::Subcommands(subcommands) = &command.variant {
            for subcommand in subcommands.iter() {
                Self::flatten_commands(subcommand, result);
            }
        } else {
            result.push(command);
        }
    }

    pub(crate) fn executable_command(&self, unique_prefix_matching: bool) -> Option<&Command> {
        if self.is_executable(unique_prefix_matching) {
            Some(self.commands[0])
        } else {
            None
        }
    }

    pub(crate) fn is_empty(&self) -> bool {
        // Note: It is possible for .variant to be AllCommands and there to be no commands
        self.commands.is_empty()
    }

    fn is_executable(&self, unique_prefix_matching: bool) -> bool {
        if self.kind == MatchingCommandsKind::ExactMatch {
            true
        } else if unique_prefix_matching {
            self.kind == MatchingCommandsKind::PrefixMatches && self.commands.len() == 1
        } else {
            false
        }
    }
}
