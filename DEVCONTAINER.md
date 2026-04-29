# Dev Container イメージ管理

## 概要

このリポジトリの Dev Container イメージは `ghcr.io/fp-matsuri/fp-in-scala-exercises/devcontainer` として管理されています。
イメージのタグには **コンテンツハッシュ**（後述）を使用し、`.devcontainer/devcontainer.json` に記載されたタグを参照して起動します。

## ファイル構成

```
.devcontainer/
  devcontainer.json          # 使用するイメージタグを記載
.devcontainer-image/
  Dockerfile                 # イメージ定義
  content-hash.sh            # コンテンツハッシュ計算スクリプト
  build-image.sh             # ローカルビルド用スクリプト
.github/workflows/
  devcontainer.yml           # ビルド・プッシュ・devcontainer.json 更新ワークフロー
mise.toml                    # インストールするツールのバージョン定義
```

## コンテンツハッシュ

イメージのタグには `Dockerfile` と `mise.toml` の内容から計算した SHA-256 ハッシュ（先頭12文字）を使用します。

```bash
cat .devcontainer-image/Dockerfile mise.toml | sha256sum | cut -c1-12
```

この方式により、**イメージの内容が変わったときだけタグが変わります**。
コミットのたびにタグが変わる（コミットハッシュ方式の）問題を避けられます。

## ローカルビルド（動作確認・デバッグ用）

```bash
.devcontainer-image/build-image.sh
```

コンテンツハッシュをタグとしてローカルの Docker にイメージをビルドします（push はしません）。

## CI/CD ワークフロー

GitHub Actions ワークフロー（`.github/workflows/devcontainer.yml`）が以下を自動で行います。

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

現在は**手動実行のみ**です。自動化する場合は `devcontainer.yml` の以下のコメントをインします。

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
