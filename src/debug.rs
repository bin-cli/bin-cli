#[macro_export]
macro_rules! debug {
    ($($arg:tt)*) => {
        #[cfg(debug_assertions)]
        {
            use std::env;
            use std::fs::OpenOptions;
            use std::io::Write;

            const GREY: &str = "\x1b[90m";
            const RESET: &str = "\x1b[0m";
            const FAILED: &str = "Failed to write to debug log";

            // This is very simple and not particularly efficient, but it's good enough for what we need
            // (We can't use stdout/stderr for logging because it would interfere with the tests)
            if let Ok(path) = env::var("BIN_DEBUG_LOG") {
                let mut file = OpenOptions::new().create(true).append(true).open(path).expect(FAILED);
                writeln!(file, "{GREY}[{}:{}:{}]{RESET}", file!(), line!(), column!()).expect(FAILED);
                writeln!(file, $($arg)*).expect(FAILED);
            }
        }
    };
}

#[macro_export]
macro_rules! dump {
    ( $( $arg:expr ),* $(,)? ) => {
        $(
            $crate::debug!("{} = {:#?}", stringify!($arg), $arg);
        )*
    };
}
