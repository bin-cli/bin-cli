use crate::arguments::Arguments;
use crate::config_file::ConfigFile;
use crate::inventory::Inventory;

#[derive(Debug)]
pub(crate) struct Options<'a> {
    pub(crate) template: &'a str,
    pub(crate) unique_prefix_matching: bool,
}

impl Default for Options<'_> {
    fn default() -> Self {
        Options {
            template: "#!/usr/bin/env bash\\nset -euo pipefail\\n\\n",
            unique_prefix_matching: true,
        }
    }
}

impl Options<'_> {
    pub(crate) fn generate(inventory: &Inventory, arguments: &Arguments) -> Self {
        let mut options = Options::default();

        for config_file in inventory.config_files.iter().rev() {
            options.set_from_config_file(config_file);
        }

        options.set_from_arguments(arguments);

        options
    }

    fn set_from_config_file(&mut self, config_file: &ConfigFile) {
        if let Some(value) = config_file.exact {
            self.unique_prefix_matching = !value;
        }
    }

    fn set_from_arguments(&mut self, arguments: &Arguments) {
        if let Some(value) = arguments.exact {
            self.unique_prefix_matching = !value;
        }
    }
}
