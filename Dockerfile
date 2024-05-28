# kcov is not available in Ubuntu 24.04 yet, nor in Debian 10/11/12 (28 May 2024)
ARG base=ubuntu:22.04
FROM ${base}

# Install development dependencies
COPY bin/setup /root/setup
RUN /root/setup

# Install Bin CLI itself
RUN curl https://github.com/bin-cli/bin-cli/releases/latest/download/bin -Lo /usr/local/bin/bin && \
    chmod +x /usr/local/bin/bin

# Create non-root user ('kcov' doesn't seem to work correctly as root;
# and it also ensures the generated files have the correct owner outside)
ARG UID=1000
RUN useradd --uid "$UID" --create-home --shell=/bin/bash docker
USER docker

# Install nvm under that user account
ARG NVM=0.39.7
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM/install.sh | bash

# Set the working directory (Note: should be bind mounted to the host at runtime)
WORKDIR /home/docker/bin-cli

# Install the required version of Node.js
COPY .nvmrc .
RUN bash -ic 'source ~/.bashrc && nvm install'

# Upgrade npm to stop it complaining
RUN bash -ic 'source ~/.bashrc && npm update -g nvm'

# Alias 'b' to 'bin' for convenience
RUN echo 'alias b=bin' >> ~/.bashrc
