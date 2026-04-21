# 開発環境のセットアップ

このリポジトリは [devenv](https://devenv.sh/) と [direnv](https://direnv.net/) を使って開発環境を管理します。

## 必要なツール

| ツール | 役割 | インストール方法 |
|--------|------|----------------|
| [Nix](https://nixos.org/download/) | パッケージ管理 | `sh <(curl -L https://nixos.org/nix/install)` |
| [devenv](https://devenv.sh/getting-started/) | 開発環境定義 | `nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable` |
| [direnv](https://direnv.net/docs/installation.html) | nix PATH の自動設定 | `nix-env -i direnv` |

### direnv のシェル統合

direnv はシェルのフックに組み込む必要があります。シェルに応じて設定ファイルに以下を追記し、シェルを再起動してください。

```bash
# ~/.bashrc
eval "$(direnv hook bash)"

# ~/.zshrc
eval "$(direnv hook zsh)"

# ~/.config/fish/config.fish
direnv hook fish | source
```

## 初回セットアップ

```bash
git clone https://github.com/fp-matsuri/fp-in-scala-exercises
cd fp-in-scala-exercises

# 各サブプロジェクトの .envrc を信頼する
direnv allow fp-in-clojure
direnv allow fp-in-haskell
direnv allow fp-in-scala
```

## 使い方

### 1. サブプロジェクトのディレクトリに移動する

```bash
cd fp-in-clojure   # Clojure の演習
cd fp-in-haskell   # Haskell の演習
cd fp-in-scala     # Scala の演習
```

direnv が `.envrc` を検知し、nix の PATH を自動で設定します。

### 2. devenv shell で開発環境に入る

各サブプロジェクトディレクトリ内で以下を実行します。

```bash
devenv shell
```

初回は devenv.nix の内容に従ってパッケージをダウンロード・ビルドします（数分かかる場合があります）。2回目以降はキャッシュが効くため高速に起動します。

### 3. 開発用コマンドを使う

`devenv shell` の中で以下のコマンドが使えます。

```bash
tests  # テスト実行
lint   # リント
fmt    # フォーマット
repl   # REPL 起動
```


## VS Code / Dev Container で使う

`.devcontainer/devcontainer.json` が用意されています。

1. VS Code で本リポジトリを開く
2. コマンドパレット（`Cmd+Shift+P`）から「Dev Containers: Reopen in Container」を選ぶ

コンテナ内では各言語の拡張機能（Calva・Haskell・Metals）がインストールされた状態で開発を始められます。
