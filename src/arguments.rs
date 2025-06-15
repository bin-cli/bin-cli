use os_str_bytes::OsStrBytesExt;
use std::env;
use std::ffi::OsString;
use std::os::unix::ffi::OsStrExt;
use std::path::PathBuf;

#[derive(Debug, Default, PartialEq)]
pub(crate) enum Action {
    #[default]
    Default,
    CompleteForBash,
    CompletionScript,
    CreateCommand,
    EditCommand,
    Help,
    Info,
    Version,
}

#[derive(Debug, Default)]
pub(crate) struct Arguments {
    pub(crate) action: Action,
    pub(crate) custom_exe_name: Option<String>,
    pub(crate) exact: Option<bool>,
    pub(crate) fixed_bin_dir: Option<OsString>,
    pub(crate) fallback_command: Option<OsString>,
    pub(crate) remaining: Vec<OsString>,
    pub(crate) shim: bool,
}

impl Arguments {
    pub(crate) fn parse(args: &[OsString]) -> Arguments {
        let mut arguments = Arguments::default();

        let args_len = args.len();
        let mut index = 1;

        while index < args_len {
            let arg = &args[index];

            match arg.as_bytes() {
                b"--complete-bash" => {
                    arguments.action = Action::CompleteForBash;
                }
                b"--completion" => {
                    arguments.action = Action::CompletionScript;
                }
                b"--create" | b"-c" => {
                    arguments.action = Action::CreateCommand;
                }
                b"--dir" => {
                    index += 1;
                    if index < args_len {
                        arguments.fixed_bin_dir = Some(arg.clone());
                    } else {
                        todo!()
                    }
                }
                b"--edit" | b"-e" => {
                    arguments.action = Action::EditCommand;
                }
                b"--exact" => {
                    arguments.exact = Some(true);
                }
                b"--no-exact" | b"--prefix" => {
                    arguments.exact = Some(false);
                }
                b"--exe" => {
                    index += 1;
                    if index >= args_len {
                        todo!()
                    } else if let Some(name) = arg.to_str() {
                        arguments.custom_exe_name = Some(name.to_string());
                    } else {
                        todo!()
                    }
                }
                b"--fallback" => {
                    index += 1;
                    if index < args_len {
                        arguments.fallback_command = Some(arg.clone());
                    } else {
                        todo!()
                    }
                }
                b"--help" | b"-h" => {
                    arguments.action = Action::Help;
                }
                b"--info" => {
                    arguments.action = Action::Info;
                }
                b"--shim" => {
                    arguments.shim = true;
                }
                b"--version" | b"-v" => {
                    arguments.action = Action::Version;
                }
                b"--" => {
                    arguments.remaining = args[index + 1..].to_vec();
                    break;
                }
                _ if arg.starts_with("-") => {
                    if let Some(value) = arg.strip_prefix("--dir=") {
                        arguments.fixed_bin_dir = Some(value.to_os_string());
                    } else if let Some(value) = arg.strip_prefix("--exe=") {
                        if let Some(name) = value.to_str() {
                            arguments.custom_exe_name = Some(name.to_string());
                        } else {
                            todo!()
                        }
                    } else if let Some(value) = arg.strip_prefix("--fallback=") {
                        arguments.fallback_command = Some(value.to_os_string());
                    } else {
                        todo!()
                    }
                }
                _ => {
                    arguments.remaining = args[index..].to_vec();
                    break;
                }
            }
            index += 1;
        }

        arguments
    }

    pub(crate) fn real_exe(&self) -> OsString {
        env::args_os().next().unwrap_or("bin".into())
    }

    pub(crate) fn exe_name(&self) -> String {
        match &self.custom_exe_name {
            Some(value) => value.to_string(),
            None => self.real_exe().to_string_lossy().to_string(),
        }
    }
}
