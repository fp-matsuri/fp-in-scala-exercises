# Dev Container イメージ管理

## 概要

このリポジトリの Dev Container イメージは `ghcr.io/fp-matsuri/fp-in-scala-exercises/devcontainer` として管理されている。
イメージのタグには **コンテンツハッシュ**（後述）を使用し、`.devcontainer/devcontainer.json` に記載されたタグを参照して起動する。

配布イメージは **amd64（x86_64）専用**。arm64（Apple Silicon など）では、同じ Dockerfile から手元でビルドする別構成（後述）を使う。

## ファイル構成

```
.devcontainer/
  devcontainer.json          # 使用するイメージタグを記載（amd64 用・デフォルト）
  local-build/
    devcontainer.json        # 手元で Dockerfile からビルドする構成（arm64 用）
.devcontainer-image/
  Dockerfile                 # イメージ定義（amd64/arm64 両対応）
  content-hash.sh            # コンテンツハッシュ計算スクリプト
  build-image.sh             # ローカルビルド用スクリプト
.github/workflows/
  devcontainer.yml           # ビルド・プッシュ・devcontainer.json 更新ワークフロー
mise.toml                    # インストールするツールのバージョン定義
```

## コンテンツハッシュ

イメージのタグには `Dockerfile` と `mise.toml` の内容から計算した SHA-256 ハッシュ（先頭12文字）を使用する。

```bash
cat .devcontainer-image/Dockerfile mise.toml | sha256sum | cut -c1-12
```

この方式により、**イメージの内容が変わったときだけタグが変わる**。
コミットのたびにタグが変わる（コミットハッシュ方式の）問題を避けられる。

## VS Code からのツール解決（remoteEnv の PATH 設定）

mise によるツールの有効化（`mise activate`）はコンテナ内の `~/.bashrc` に書かれているため、
**対話シェル（統合ターミナルなど）でしか効かない**。VS Code の拡張機能（Metals、Calva など）が
LSP サーバーやツールを起動するプロセスは対話シェルを経由しないため、そのままでは
java や clojure が見つからず LSP が動かない。

このため `devcontainer.json` の `remoteEnv` で以下を設定している。

- `PATH` に mise の shims（`~/.local/share/mise/shims`）と opam の bin（`~/.opam/default/bin`、dune 用）を追加
  → シェルの種類に関係なく全ツールが解決できる
- `MISE_GLOBAL_CONFIG_FILE` にリポジトリの `mise.toml` を指定
  → shims がカレントディレクトリに依存せずバージョンを解決できる
  （shims は実行時にカレントディレクトリから mise 設定を探すため、これがないと
  ワークスペース外を起点とするプロセスから実行したときに失敗する）

## arm64（Apple Silicon など）での利用

配布イメージは amd64 専用のため、arm64 マシンでは「コンテナーで再度開く」時の構成選択ダイアログで
**「FP in Scala Exercises (Local Build / arm64)」**（`.devcontainer/local-build/devcontainer.json`）を選択する。
配布イメージを参照する代わりに、同じ Dockerfile を使って手元でネイティブ（arm64）イメージをビルドして起動する。

- 初回はビルドに時間がかかる（10〜20分程度。大半はツールのダウンロードと OCaml コンパイラのソースビルド）。2回目以降は Docker のキャッシュが効く
- `Dockerfile` や `mise.toml` が更新されたら、コマンドパレットの「Dev Containers: Rebuild Container」で再ビルドする

### arm64 版に含まれないツール

以下のツールは linux/arm64 バイナリが配布されていないため、arm64 ビルドには含まれない
（Dockerfile 内で `TARGETARCH` を見て除外している）。

- hlint（Haskell リンター）
- cljstyle（Clojure フォーマッタ）

このためコンテナ内で mise が missing tools の警告を出すことがあるが、無視してよい。
これら以外のツールは amd64 版と同じバージョンが入る。

## ローカルビルド（動作確認・デバッグ用）

```bash
.devcontainer-image/build-image.sh
```

コンテンツハッシュをタグとしてローカルの Docker にイメージをビルドする（push はしない）。
CI が作る配布イメージと同じ amd64 向けビルドを再現するもので、arm64 マシンではエミュレーションで動く点に注意。

## CI/CD ワークフロー

GitHub Actions ワークフロー（`.github/workflows/devcontainer.yml`）が以下を自動で行う。

```
手動実行（workflow_dispatch）
  ↓
コンテンツハッシュを計算
  ↓
ghcr.io に同タグのイメージが存在する？
  YES → スキップ
  NO  → ビルド & プッシュ
        → .devcontainer/devcontainer.json のタグを更新してコミット
```

現在は**手動実行のみ**。自動化する場合は `devcontainer.yml` の以下のコメントをインする。

```yaml
# push:
#   branches:
#     - main
#   paths:
#     - .devcontainer-image/Dockerfile
#     - mise.toml
```

## イメージを更新する手順

1. `Dockerfile` または `mise.toml` を変更してコミット・プッシュ
2. GitHub Actions の `Build and Push Dev Container Image` を手動実行
3. ワークフローが `.devcontainer/devcontainer.json` を新しいタグに更新してコミット
4. そのコミットを pull して Dev Container を再ビルド
