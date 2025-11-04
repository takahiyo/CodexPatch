# CodexPatch - AI生成パッチの自動適用システム

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-supported-brightgreen)

**Codex などの AI コーディング支援ツールが出力したパッチを自動的に検証・適用し、GitHub Actions で完全自動化**

[機能](#機能) | [クイックスタート](#クイックスタート) | [使い方](#使い方) | [高度な使い方](#高度な使い方)

</div>

---

## 🎯 概要

CodexPatchは、AI（Codex、Claude、GPTなど）が生成したコード差分（patch/diff）を効率的に管理し、GitHub Actions経由で自動適用するための統合システムです。

### 主な特徴

- 🤖 **AI生成パッチの自動適用** - Codexなどで生成されたパッチを自動で適用
- 🔄 **複数リポジトリ対応** - 他のリポジトリへもパッチを適用可能
- 📦 **一括適用機能** - 複数のパッチを一度に適用
- ✅ **詳細な検証** - パッチ適用前の自動検証とドライラン
- 🛠️ **CLIツール** - ローカル環境でのパッチ管理用ツール
- 🔧 **柔軟な設定** - 直接pushまたはPR作成を選択可能
- 📊 **テスト統合** - パッチ適用後の自動テスト実行

---

## 📁 プロジェクト構造

```
CodexPatch/
├── .github/
│   └── workflows/
│       ├── apply-codex-patch.yml        # 単一パッチ適用ワークフロー
│       └── apply-batch-patches.yml      # 複数パッチ一括適用ワークフロー
├── patches/                              # パッチファイル格納ディレクトリ
│   └── examples/                         # サンプルパッチ
│       ├── sample-readme-update.patch
│       ├── sample-readme-update.meta.json
│       └── batch-config.json
├── scripts/
│   └── generate-patch-template.sh       # パッチテンプレート生成スクリプト
├── tools/
│   └── patch-cli.sh                     # パッチ管理CLIツール
└── README.md                             # このファイル
```

---

## 🚀 クイックスタート

### 1. リポジトリのセットアップ

```bash
# リポジトリをクローン
git clone https://github.com/your-username/CodexPatch.git
cd CodexPatch

# CLIツールに実行権限を付与
chmod +x tools/patch-cli.sh scripts/generate-patch-template.sh
```

### 2. パッチテンプレートの作成

```bash
# パッチテンプレートを生成
./scripts/generate-patch-template.sh \
  -n "feature-update-header" \
  -r "your-org/your-repo" \
  -b "main" \
  -d "Update header component"
```

### 3. Codexで生成されたパッチを貼り付け

生成されたパッチファイル（例: `patches/your-org_your-repo/2025-11-04_feature-update-header.patch`）を開き、Codexから出力された差分を貼り付けます。

```diff
diff --git a/src/components/Header.tsx b/src/components/Header.tsx
index 1234567..abcdefg 100644
--- a/src/components/Header.tsx
+++ b/src/components/Header.tsx
@@ -10,7 +10,7 @@ export const Header = () => {
   return (
     <header>
-      <h1>Old Title</h1>
+      <h1>New Awesome Title</h1>
     </header>
   )
 }
```

### 4. パッチの検証

```bash
# パッチファイルを検証
./tools/patch-cli.sh validate patches/your-org_your-repo/2025-11-04_feature-update-header.patch

# パッチの詳細情報を確認
./tools/patch-cli.sh info patches/your-org_your-repo/2025-11-04_feature-update-header.patch
```

### 5. GitHub Actionsでパッチを適用

1. パッチファイルをコミット＆プッシュ
   ```bash
   git add patches/
   git commit -m "Add patch: feature-update-header"
   git push
   ```

2. GitHub上で「Actions」タブを開く
3. `Codexパッチ適用` ワークフローを選択
4. `Run workflow` をクリックし、必要な情報を入力
   - **target_repository**: 適用先リポジトリ（例: `your-org/your-repo`）
   - **target_branch**: 適用先ブランチ（例: `main`）
   - **patch_file**: パッチファイルのパス
   - **push_strategy**: `pull_request`（PRを作成）または `direct`（直接push）

---

## 📖 使い方

### CLIツールの使用

#### パッチファイルの検証

```bash
# 単一パッチを検証
./tools/patch-cli.sh validate patches/my-patch.patch

# パッチ一覧を表示
./tools/patch-cli.sh list patches/

# パッチの詳細情報を表示
./tools/patch-cli.sh info patches/my-patch.patch
```

#### ローカルでパッチを適用

```bash
# ドライラン（実際には適用しない）
./tools/patch-cli.sh apply patches/my-patch.patch --check

# 実際に適用
./tools/patch-cli.sh apply patches/my-patch.patch

# 特定のディレクトリに適用
./tools/patch-cli.sh apply patches/my-patch.patch --directory /path/to/repo

# 3-wayマージを使用
./tools/patch-cli.sh apply patches/my-patch.patch --3way

# パッチを逆適用（ロールバック）
./tools/patch-cli.sh apply patches/my-patch.patch --reverse
```

#### 現在の変更からパッチを作成

```bash
# 現在の変更をパッチファイルとして保存
./tools/patch-cli.sh create patches/my-changes.patch
```

### GitHub Actions ワークフロー

#### 単一パッチの適用

ワークフロー: `.github/workflows/apply-codex-patch.yml`

**入力パラメータ:**

| パラメータ | 必須 | デフォルト | 説明 |
|-----------|------|-----------|------|
| `target_repository` | ❌ | (空) | 適用先リポジトリ `owner/name` |
| `target_branch` | ✅ | `main` | 適用先ブランチ |
| `patch_file` | ✅ | `patch` | パッチファイルのパス |
| `push_strategy` | ✅ | `pull_request` | `direct` または `pull_request` |
| `commit_message` | ✅ | `Apply Codex patch` | コミットメッセージ |
| `pr_title` | ❌ | `Apply Codex patch` | PRタイトル |
| `pr_body` | ❌ | (自動生成) | PR本文 |
| `run_tests` | ✅ | `skip` | `run` または `skip` |
| `test_command` | ❌ | (空) | テストコマンド |

**使用例:**

```yaml
# GitHubのActions UIから手動実行
# または以下のようにワークフロー内から呼び出し
jobs:
  apply-patch:
    uses: ./.github/workflows/apply-codex-patch.yml
    with:
      target_repository: 'your-org/your-repo'
      target_branch: 'main'
      patch_file: 'patches/feature-x.patch'
      push_strategy: 'pull_request'
```

#### 複数パッチの一括適用

ワークフロー: `.github/workflows/apply-batch-patches.yml`

**入力パラメータ:**

| パラメータ | 必須 | デフォルト | 説明 |
|-----------|------|-----------|------|
| `target_repository` | ❌ | (空) | 適用先リポジトリ |
| `target_branch` | ✅ | `main` | 適用先ブランチ |
| `patch_files` | ✅ | (空) | パッチファイルのリスト（改行またはカンマ区切り） |
| `push_strategy` | ✅ | `pull_request` | `direct` または `pull_request` |
| `commit_message` | ✅ | `Apply multiple Codex patches` | コミットメッセージ |
| `fail_fast` | ✅ | `true` | 失敗時に即座に停止するか |
| `run_tests` | ✅ | `skip` | テスト実行の有無 |

**使用例:**

```
# patch_files に以下のように入力:
patches/feature-a.patch
patches/feature-b.patch
patches/bugfix-c.patch

# またはカンマ区切り:
patches/feature-a.patch,patches/feature-b.patch,patches/bugfix-c.patch
```

---

## 🔧 高度な使い方

### 複数パッチのバッチ適用（CLI）

バッチ設定ファイルを作成：

```json
{
  "description": "複数機能を一括適用",
  "targetRepository": "your-org/your-repo",
  "targetBranch": "develop",
  "patches": [
    {
      "file": "patches/feature-a.patch",
      "target": ".",
      "description": "機能Aを追加"
    },
    {
      "file": "patches/feature-b.patch",
      "target": ".",
      "description": "機能Bを追加"
    }
  ],
  "options": {
    "failFast": true,
    "runTests": true,
    "testCommand": "npm test"
  }
}
```

適用：

```bash
./tools/patch-cli.sh batch patches/batch-config.json
```

### 外部リポジトリへのパッチ適用

別のリポジトリにパッチを適用する場合は、Personal Access Token (PAT) が必要です。

#### 1. PATの作成

1. GitHub の [Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens) を開く
2. `Generate new token (classic)` をクリック
3. `repo` スコープを選択
4. トークンを生成してコピー

#### 2. シークレットの設定

1. このリポジトリの `Settings > Secrets and variables > Actions` を開く
2. `New repository secret` をクリック
3. Name: `PATCH_APPLIER_TOKEN`
4. Secret: 先ほどコピーしたトークン

#### 3. ワークフローの実行

`target_repository` に他のリポジトリ名を指定して実行します。

### パッチの整理とディレクトリ構造

推奨されるディレクトリ構造：

```
patches/
├── owner_repo-a/
│   ├── 2025-11-04_feature-x.patch
│   ├── 2025-11-04_feature-x.meta.json
│   └── 2025-11-05_bugfix-y.patch
├── owner_repo-b/
│   └── 2025-11-04_update-docs.patch
└── examples/
    └── sample.patch
```

**ベストプラクティス:**
- リポジトリごとにサブディレクトリを作成
- ファイル名に日付を含める（`YYYY-MM-DD_description.patch`）
- メタデータファイル（`.meta.json`）で追加情報を管理
- 適用済みパッチは別ディレクトリ（`applied/`）に移動

### テストの自動実行

パッチ適用後に自動的にテストを実行する設定：

```yaml
# GitHub Actions UIで以下を設定
run_tests: run
test_command: |
  npm install
  npm test
  npm run lint
```

または複数コマンド：

```yaml
test_command: |
  set -e
  echo "Running tests..."
  npm ci
  npm run build
  npm test
  npm run e2e
```

---

## 🔒 セキュリティとベストプラクティス

### セキュリティ

1. **PATの管理**: Personal Access Tokenは必ずGitHub Secretsに保存
2. **最小権限の原則**: 必要最小限のスコープのみを付与
3. **パッチの検証**: 適用前に必ず内容を確認
4. **テストの実行**: 本番環境への適用前にテストを実行

### ベストプラクティス

1. **段階的な適用**
   - まず開発ブランチで試す
   - テストを実行して確認
   - レビュー後に本番ブランチへ

2. **パッチの管理**
   - 明確な命名規則を使用
   - メタデータファイルで追跡
   - 適用済みパッチを整理

3. **コードレビュー**
   - PR作成モードを使用
   - レビュー後にマージ
   - 変更履歴を維持

4. **エラーハンドリング**
   - `fail_fast` オプションを適切に設定
   - ロールバック手順を用意
   - ログを確認

---

## 🐛 トラブルシューティング

### パッチ適用に失敗する

**原因:** パッチとターゲットコードのバージョンが一致していない

**解決策:**
```bash
# ドライランで確認
./tools/patch-cli.sh apply patches/my-patch.patch --check

# 3-wayマージを試す
./tools/patch-cli.sh apply patches/my-patch.patch --3way

# 手動で適用してパッチを再生成
```

### GitHub Actionsでトークンエラー

**原因:** Personal Access Tokenが設定されていない、または権限が不足

**解決策:**
1. `PATCH_APPLIER_TOKEN` がRepository Secretsに設定されているか確認
2. トークンに `repo` スコープがあるか確認
3. トークンが有効期限内か確認

### パッチファイルが見つからない

**原因:** パッチファイルがコミットされていない

**解決策:**
```bash
# パッチファイルをコミット
git add patches/
git commit -m "Add patch files"
git push

# ワークフローを再実行
```

---

## 📚 リファレンス

### CLIコマンド一覧

```bash
# ヘルプを表示
./tools/patch-cli.sh help

# バージョンを表示
./tools/patch-cli.sh version

# パッチを検証
./tools/patch-cli.sh validate <patch_file>

# パッチを適用
./tools/patch-cli.sh apply <patch_file> [options]

# パッチ一覧を表示
./tools/patch-cli.sh list [directory]

# パッチ情報を表示
./tools/patch-cli.sh info <patch_file>

# パッチを作成
./tools/patch-cli.sh create <output_file>

# バッチ適用
./tools/patch-cli.sh batch <config_file>
```

### パッチテンプレート生成

```bash
./scripts/generate-patch-template.sh \
  -n <patch_name> \
  -r <owner/repo> \
  -b <branch> \
  -d <description> \
  -o <output_dir>
```

---

## 🤝 貢献

貢献を歓迎します！以下の手順でご参加ください：

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. Pull Requestを作成

---

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

---

## 🙏 謝辞

- [GitHub Actions](https://github.com/features/actions) - CI/CDプラットフォーム
- [Codex](https://openai.com/blog/openai-codex) - AIコーディング支援
- コミュニティの皆様

---

## 📞 サポート

問題が発生した場合は、[Issues](https://github.com/your-username/CodexPatch/issues)で報告してください。

---

<div align="center">

**CodexPatch で AI 生成コードの適用を自動化しましょう！**

Made with ❤️ by the CodexPatch Team

</div>
