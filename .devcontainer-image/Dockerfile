FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu-24.04

USER vscode

RUN curl https://mise.run | sh && \
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

COPY --chown=vscode mise.toml /tmp/mise.toml
RUN ~/.local/bin/mise trust /tmp/mise.toml && \
    MISE_CONFIG_FILE=/tmp/mise.toml ~/.local/bin/mise install && \
    rm -rf /tmp/mise.toml ~/.local/share/mise/downloads ~/.cache/coursier

USER root
