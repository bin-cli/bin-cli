const VERSION: Option<&str> = option_env!("BIN_VERSION");

pub(crate) fn display() {
    println!("Bin CLI v{}", version());
}

pub(crate) fn version() -> String {
    VERSION.unwrap_or("1.2.3-source").to_string()
}