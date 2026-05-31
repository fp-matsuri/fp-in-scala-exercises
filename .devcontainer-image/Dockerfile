FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# ghcup 経由の GHC がリンクに使うシステムライブラリ
RUN apt-get update && apt-get install -y --no-install-recommends \
    libffi-dev libffi8 libgmp-dev libgmp10 libncurses-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

USER vscode

RUN curl -fsSL https://mise.run | sh && \
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

COPY --chown=vscode mise.toml /tmp/mise.toml
RUN ~/.local/bin/mise trust /tmp/mise.toml && \
    MISE_BACKENDS_GHC='asdf:mise-plugins/mise-ghcup' \
    MISE_CONFIG_FILE=/tmp/mise.toml ~/.local/bin/mise install && \
    rm -rf /tmp/mise.toml ~/.local/share/mise/downloads ~/.cache/coursier

USER root
