use configparser::ini::Ini;
use std::collections::HashMap;
use std::path::Path;
use crate::errors::Error;

const GLOBAL_OPTIONS: &str = "\0"; // Not a valid command name

#[derive(Default, Debug)]
pub(crate) struct ConfigFile {
    pub(crate) commands: HashMap<String, CommandConfig>,
    pub(crate) dir: Option<String>,
    pub(crate) exact: Option<bool>,
    pub(crate) merge: Option<MergeOption>,
    pub(crate) template: Option<String>,
    // pub(crate) warnings: Vec<String>,
}

#[derive(Default, Debug)]
pub(crate) struct CommandConfig {
    pub(crate) aliases: Vec<String>,
    pub(crate) args: Option<String>,
    pub(crate) command: Option<String>,
    pub(crate) help: Option<String>,
    pub(crate) warnings: Vec<String>,
}

#[derive(Debug)]
pub(crate) enum MergeOption {
    False,
    True,
    Optional,
}

impl ConfigFile {
    pub(crate) fn load(path: &Path) -> Result<Self, Error> {
        let mut config = Self::default();

        // If the file doesn't exist, that's fine
        // TODO: Change this to return None instead of a default instance?
        if !path.exists() {
            return Ok(config);
        }

        // Parse the config file to a hashmap
        let mut ini = Ini::new_cs();
        ini.set_default_section(GLOBAL_OPTIONS);
        ini.set_inline_comment_symbols(Some(&[])); // No inline comments (None means defaults)

        if let Err(message) = ini.load(path) {
            // TODO: Check whether the errors it returns are helpful enough
            return Err(Error::Generic(message));
        };

        config.load_global_options(&ini, path)?;
        config.load_commands(&ini, path)?;

        Ok(config)
    }

    fn load_global_options(&mut self, ini: &Ini, path: &Path) -> Result<(), Error> {
        if let Some(value) = ini.get(GLOBAL_OPTIONS, "dir") {
            self.dir = Some(value);
        }

        match ini.getboolcoerce(GLOBAL_OPTIONS, "exact") {
            Ok(Some(value)) => {
                self.exact = Some(value);
            }
            Ok(None) => {}
            Err(_) => return Err(Error::Generic(format!(
                // It would be helpful to include the line number, but
                // the Ini parser doesn't expose that information
                "Invalid value for 'exact' in {}: {}",
                path.display(),
                ini.get(GLOBAL_OPTIONS, "exact").unwrap(),
            ))),
        }

        if let Some(value) = ini.get(GLOBAL_OPTIONS, "merge") {
            if value.to_lowercase() == "optional" {
                self.merge = Some(MergeOption::Optional)
            } else if let Ok(Some(value)) = ini.getboolcoerce(GLOBAL_OPTIONS, "merge") {
                self.merge = match value {
                    true => Some(MergeOption::True),
                    false => Some(MergeOption::False),
                }
            };
        }

        if let Some(value) = ini.get(GLOBAL_OPTIONS, "template") {
            self.template = Some(value);
        }

        Ok(())
    }

    fn load_commands(&mut self, ini: &Ini, path: &Path) -> Result<(), Error> {
        for command_name in ini.sections() {
            if command_name == GLOBAL_OPTIONS {
                continue;
            }

            let mut command = CommandConfig::default();
            command.load_from_ini(&command_name, ini, path)?;

            self.commands.insert(command_name, command);
        }

        Ok(())
    }
}

impl CommandConfig {
    fn load_from_ini(&mut self, command_name: &str, ini: &Ini, path: &Path) -> Result<(), Error> {
        if let Some(aliases) = ini.get(command_name, "aliases") {
            self.aliases = split_aliases(aliases);

            if ini.get(command_name, "alias").is_some() {
                self.warnings.push(format!(
                    "Both 'aliases' and 'alias' are set for command '{}' in '{}' - 'alias' will be ignored.",
                    command_name,
                    path.display(),
                ));
            }
        } else if let Some(aliases) = ini.get(command_name, "alias") {
            self.aliases = split_aliases(aliases);
        }

        if let Some(args) = ini.get(command_name, "args") {
            self.args = Some(args);
        }

        if let Some(cmd) = ini.get(command_name, "command") {
            self.command = Some(cmd);
        }

        if let Some(help) = ini.get(command_name, "help") {
            self.help = Some(help);
        }

        Ok(())
    }
}

fn split_aliases(aliases: String) -> Vec<String> {
    aliases
        .split(',')
        .map(|alias| alias.trim().to_string())
        .collect()
}
