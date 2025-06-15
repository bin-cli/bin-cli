use crate::arguments::Arguments;
use crate::commands::Commands;
use crate::config_file::ConfigFile;
use std::env;
use std::ffi::OsString;
use std::path::Path;
use crate::errors::Error;

#[derive(Default, Debug)]
pub(crate) struct Inventory {
    pub(crate) config_files: Vec<ConfigFile>,
    pub(crate) commands: Commands,
}

impl Inventory {
    pub(crate) fn register(arguments: &Arguments) -> Result<Self, Error> {
        let mut commands = Inventory::default();

        if let Some(dir) = &arguments.fixed_bin_dir {
            commands.register_fixed_bin_dir(dir);
        } else {
            let dir = env::current_dir().unwrap();
            match commands.register_relative_to_directory(&dir)? {
                true => {}
                false => {
                    return Err(Error::NotFound(format!(
                        "Could not find 'bin/' directory or '.binconfig' file starting from '{}'",
                        dir.display()
                    )));
                }
            }
        }

        Ok(commands)
    }

    fn register_relative_to_directory(&mut self, path: &Path) -> Result<bool, Error> {
        let bin = path.join("bin");

        if bin.exists() {
            self.register_commands_in_directory_unless_blacklisted(&bin)
        } else if let Some(parent) = path.parent() {
            self.register_relative_to_directory(parent)
        } else {
            Ok(false)
        }
    }

    fn register_commands_in_directory_unless_blacklisted(
        &mut self,
        path: &Path,
    ) -> Result<bool, Error> {
        if Self::bin_directory_is_blacklisted(path) {
            return Ok(false);
        }

        let config_path = path.parent().unwrap().join(".binconfig");

        let config_file = ConfigFile::load(config_path.as_path())?;

        // TODO: Handle config files later
        self.commands.register_directory(path, &config_file, None);

        self.config_files.push(config_file);

        Ok(true)
    }

    fn bin_directory_is_blacklisted(path: &Path) -> bool {
        let path_str = match path.to_str() {
            Some(s) => s,
            None => return false,
        };

        const GLOBAL_BLACKLIST: [&str; 4] = ["/bin", "/usr/bin", "/usr/local/bin", "/snap/bin"];
        if GLOBAL_BLACKLIST.contains(&path_str) {
            return true;
        }

        if let Ok(home) = env::var("HOME") {
            let home_blacklist = [format!("{}/bin", home), format!("{}/.local/bin", home)];
            if home_blacklist.contains(&path_str.to_string()) {
                return true;
            }
        }

        false
    }

    fn register_fixed_bin_dir(&mut self, _dir: &OsString) {
        todo!()
    }
}
