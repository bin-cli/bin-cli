
use crate::config_file::ConfigFile;
use std::collections::HashMap;
use std::ffi::{OsStr, OsString};
use std::fs;
use std::path::Path;

#[derive(Default, Debug)]
pub(crate) struct Commands(Vec<Command>);

#[derive(Debug)]
pub(crate) struct Command {
    pub(crate) name: String,
    pub(crate) full_name: String,
    pub(crate) variant: CommandVariant,
    pub(crate) help: Option<String>,
}

#[derive(Debug)]
pub(crate) enum CommandVariant {
    Executable(OsString),
    Subcommands(Commands),
}

impl Commands {
    pub(crate) fn register_directory(
        &mut self,
        path: &Path,
        config_file: &ConfigFile,
        parent_name: Option<&str>,
    ) {
        if let Ok(entries) = fs::read_dir(path) {
            for entry in entries.flatten() {
                let subpath = entry.path();
                if let Some(name) = subpath.file_name() {
                    self.register_path(config_file, parent_name, &subpath, name);
                }
            }
        }
    }

    fn register_path(
        &mut self,
        config_file: &ConfigFile,
        parent_name: Option<&str>,
        path: &Path,
        name: &OsStr,
    ) {
        let name_str = name.to_string_lossy();

        let full_name = match parent_name {
            Some(parent_name) => format!("{} {}", parent_name, name_str),
            None => name_str.clone().into_owned(),
        };

        if path.is_file() {
            self.insert(
                Command {
                    name: name_str.into_owned(),
                    full_name: full_name.clone(),
                    variant: CommandVariant::Executable(path.into()),
                    help: match config_file.commands.get(&full_name) {
                        Some(command_config) => command_config.help.clone(),
                        None => None,
                    },
                },
            );
        } else if path.is_dir() {
            let mut subcommands = Commands::default();

            subcommands.register_directory(path, config_file, Some(&full_name));

            self.insert(
                Command {
                    name: name_str.into_owned(),
                    full_name,
                    variant: CommandVariant::Subcommands(subcommands),
                    help: None,
                },
            );
        }
    }

    fn insert(&mut self, command: Command) {
        self.0.push(command);
    }

    pub(crate) fn iter(&self) -> std::slice::Iter<'_, Command> {
        self.0.iter()
    }

    pub(crate) fn collect(&self) -> Vec<&Command> {
        self.iter().collect()
    }

    pub(crate) fn get(&self, name: &str) -> Option<&Command> {
        // We could use a HashMap or a BTreeMap to save ourselves a loop.
        // However, that increases the cost of iterating through all elements
        // (HashMap) or building the list in the first place (BTreeMap), so
        // I'm not sure that it's worth it.
        self.iter().find(|cmd| cmd.name == name)
    }
}
