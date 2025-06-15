#[derive(Debug)]
pub(crate) enum Error {
    NotExecutable(String),
    NotFound(String),
    Generic(String),
}

impl Error {
    pub(crate) fn exit_code(&self) -> u8 {
        match self {
            Error::NotExecutable(_) => 126,
            Error::NotFound(_) => 127,
            Error::Generic(_) => 246,
        }
    }

    pub(crate) fn message(&self) -> &str {
        match self {
            Error::NotExecutable(message) => message,
            Error::NotFound(message) => message,
            Error::Generic(message) => message,
        }
    }
}
