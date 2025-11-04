# CodexPatch - AI生成パッチの完全クラウド適用システム

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-supported-brightgreen)
![Cloud Native](https://img.shields.io/badge/Cloud-Native-orange)

**ローカル環境不要！ブラウザだけで完結する AI 生成パッチの自動適用システム**

[機能](#機能) | [クイックスタート](#クイックスタート) | [使い方](#使い方) | [トラブルシューティング](docs/TROUBLESHOOTING.md) | [FAQ](#faq)

</div>

---

## 🎯 概要

CodexPatchは、AI（Codex、Claude、GPTなど）が生成したコード差分（patch/diff）を、**ローカル環境不要でブラウザ上だけで管理**し、GitHub Actions経由で自動適用するための完全クラウドネイティブシステムです。

### 🌟 完全クラウド対応

- ✅ **ローカル環境不要** - git clone、コマンドライン操作一切不要
- ✅ **ブラウザだけで完結** - GitHub UIだけで全ての操作が可能
- ✅ **即座に使用開始** - 設定不要、今すぐ使える

### 主な特徴

- 🤖 **AI生成パッチの自動適用** - Codexなどで生成されたパッチを自動で適用
- 🔄 **複数リポジトリ対応** - 他のリポジトリへもパッチを適用可能
- 📦 **一括適用機能** - 複数のパッチを一度に適用
- ✅ **自動検証** - GitHub Actions上で自動検証
- 🔧 **柔軟な設定** - 直接pushまたはPR作成を選択可能
- 📊 **テスト統合** - パッチ適用後の自動テスト実行
- 🌐 **完全Web UI** - すべての操作をブラウザで完結

---

## 🚀 クイックスタート（ローカル環境不要）

### ステップ1: Codexでパッチを生成

AIツール（Codex、Claude、GitHub Copilotなど）に変更を依頼し、差分を出力させます。

**例：Codexへの依頼**
```
以下のファイルを修正してください：
- README.mdのタイトルを "Awesome Project" に変更
- 機能説明セクションを追加

差分をgit diff形式で出力してください。
```

**Codexからの出力（例）:**
```diff
diff --git a/README.md b/README.md
index 1234567..abcdefg 100644
--- a/README.md
+++ b/README.md
@@ -1,4 +1,6 @@
-# My Project
+# Awesome Project

-A simple project.
+A powerful project with amazing features.
+
+## Features
```

### ステップ2: GitHub UIでパッチファイルを作成

1. **このリポジトリ（CodexPatch）をブラウザで開く**
   - https://github.com/your-username/CodexPatch

2. **新しいパッチファイルを作成**
   - `patches/` フォルダを開く
   - 「Add file」→「Create new file」をクリック
   - ファイル名を入力: `patches/2025-11-04_update-readme.patch`

3. **パッチ内容を貼り付け**
   - Codexから出力された差分をそのまま貼り付け
   - 「Commit new file」をクリック
   - コミットメッセージ: `Add patch: update README`
   - 「Commit directly to the main branch」を選択
   - 「Commit new file」をクリック

### ステップ3: GitHub Actionsでパッチを適用

1. **Actionsタブを開く**
   - リポジトリのトップページで「Actions」タブをクリック

2. **ワークフローを実行**
   - 左サイドバーから「Codexパッチ適用」を選択
   - 右上の「Run workflow」ボタンをクリック

3. **パラメータを入力**
   ```
   target_repository: your-org/your-target-repo
   target_branch: main
   patch_file: patches/2025-11-04_update-readme.patch
   push_strategy: pull_request
   commit_message: docs: update README with Codex patch
   ```

4. **「Run workflow」をクリック**

5. **結果を確認**
   - ワークフローが完了すると、対象リポジトリにPRが自動作成されます
   - PRを確認してマージ

**完了！** ローカル環境を一切使わずにパッチを適用できました 🎉

---

## 📖 詳細な使い方

### パターン1: 単一パッチの適用

#### シナリオ
あなたのプロジェクト `myorg/myapp` の `Header.tsx` を更新したい。

#### 手順

**1. Codexでパッチを生成**
```
以下を実装してください：
- Header.tsxのタイトルを中央揃えに変更
- フォントサイズを20pxに設定

git diff形式で出力してください。
```

**2. GitHubでパッチファイルを作成**
- ブラウザでこのリポジトリ（CodexPatch）を開く
- `patches/myorg_myapp/` フォルダに移動（なければ作成）
- 「Add file」→「Create new file」
- ファイル名: `2025-11-04_header-update.patch`
- Codexの出力を貼り付け
- コミット

**3. ワークフローを実行**
- 「Actions」→「Codexパッチ適用」→「Run workflow」
- パラメータ入力:
  ```
  target_repository: myorg/myapp
  target_branch: main
  patch_file: patches/myorg_myapp/2025-11-04_header-update.patch
  push_strategy: pull_request
  commit_message: style: update header styling
  pr_title: Update header component styling
  run_tests: skip
  ```
- 実行

**4. PRを確認**
- `myorg/myapp` リポジトリの「Pull requests」タブを開く
- 自動作成されたPRを確認
- レビュー後にマージ

---

### パターン2: 複数パッチの一括適用

#### シナリオ
複数の小さな修正を一度に適用したい。

#### 手順

**1. 各パッチファイルを作成**

GitHub UIで以下のファイルを作成：
- `patches/batch-2025-11-04/fix-typo.patch`
- `patches/batch-2025-11-04/update-deps.patch`
- `patches/batch-2025-11-04/add-comments.patch`

それぞれにCodexで生成したパッチを貼り付けてコミット。

**2. バッチワークフローを実行**
- 「Actions」→「複数パッチの一括適用」→「Run workflow」
- パラメータ入力:
  ```
  target_repository: myorg/myapp
  target_branch: develop
  patch_files:
  patches/batch-2025-11-04/fix-typo.patch
  patches/batch-2025-11-04/update-deps.patch
  patches/batch-2025-11-04/add-comments.patch
  
  push_strategy: pull_request
  commit_message: chore: apply multiple improvements
  fail_fast: true
  ```
- 実行

**3. 結果確認**
- 1つのPRにすべてのパッチがまとめて適用されます
- Actions サマリーで各パッチの適用状況を確認できます

---

### パターン3: 他のリポジトリへの適用

#### 事前準備: Personal Access Token (PAT) の設定

**1. PATを作成**
- GitHub設定を開く: https://github.com/settings/tokens
- 「Generate new token (classic)」をクリック
- Note: `CodexPatch Applier`
- スコープ: `repo` にチェック
- 「Generate token」をクリック
- トークンをコピー（一度しか表示されません！）

**2. Secretを設定**
- このリポジトリ（CodexPatch）の「Settings」タブを開く
- 左サイドバーの「Secrets and variables」→「Actions」
- 「New repository secret」をクリック
- Name: `PATCH_APPLIER_TOKEN`
- Secret: コピーしたトークンを貼り付け
- 「Add secret」をクリック

これで、どのリポジトリにもパッチを適用できるようになりました！

---

## 💡 よくある使用例

### 例1: ドキュメントの更新

```
# Codexへの依頼
READMEのインストール手順を詳しくしてください。
npm installの手順とNode.jsバージョン要件を追加してください。
```

1. Codexの出力をコピー
2. GitHub UIで `patches/docs-update.patch` を作成
3. ワークフロー実行
4. 完了！

### 例2: バグ修正

```
# Codexへの依頼  
src/utils/validation.tsのemailバリデーションバグを修正してください。
現在の正規表現が間違っています。
```

1. Codexの出力をコピー
2. GitHub UIで `patches/bugfix-email-validation.patch` を作成
3. ワークフロー実行（`run_tests: run` を指定）
4. 自動テスト実行後にPR作成

### 例3: 新機能の追加

```
# Codexへの依頼
ダークモード切り替え機能を追加してください。
- Toggleボタンをヘッダーに追加
- localStorageで設定を保存
- CSSクラスで切り替え
```

1. Codexが複数ファイルの差分を出力
2. GitHub UIで `patches/feature-dark-mode.patch` を作成
3. ワークフロー実行
4. PRでレビュー→マージ

---

## 🎨 パッチファイルの整理方法

### 推奨ディレクトリ構造

```
patches/
├── myorg_myrepo/              # リポジトリごとに分類
│   ├── 2025-11-04_feature-a.patch
│   ├── 2025-11-04_bugfix-b.patch
│   └── 2025-11-05_docs-update.patch
├── another_repo/
│   └── 2025-11-04_refactor.patch
└── batch-2025-11-04/          # バッチ適用用
    ├── fix-1.patch
    ├── fix-2.patch
    └── fix-3.patch
```

### ファイル名規則

```
YYYY-MM-DD_description.patch

例：
2025-11-04_update-header.patch
2025-11-04_fix-validation-bug.patch
2025-11-05_add-dark-mode.patch
```

---

## ⚙️ ワークフローパラメータ詳細

### 単一パッチ適用ワークフロー

| パラメータ | 必須 | デフォルト | 説明 |
|-----------|------|-----------|------|
| `target_repository` | ❌ | (このリポジトリ) | 適用先リポジトリ `owner/name` |
| `target_branch` | ✅ | `main` | 適用先ブランチ |
| `patch_file` | ✅ | `patch` | パッチファイルのパス |
| `push_strategy` | ✅ | `pull_request` | `direct` または `pull_request` |
| `commit_message` | ✅ | `Apply Codex patch` | コミットメッセージ |
| `pr_title` | ❌ | `Apply Codex patch` | PRタイトル |
| `pr_body` | ❌ | (自動生成) | PR本文 |
| `run_tests` | ✅ | `skip` | `run` または `skip` |
| `test_command` | ❌ | (空) | テストコマンド（`run_tests=run`の場合） |

### 複数パッチ一括適用ワークフロー

| パラメータ | 必須 | デフォルト | 説明 |
|-----------|------|-----------|------|
| `target_repository` | ❌ | (このリポジトリ) | 適用先リポジトリ |
| `target_branch` | ✅ | `main` | 適用先ブランチ |
| `patch_files` | ✅ | (空) | パッチファイルのリスト（改行またはカンマ区切り） |
| `push_strategy` | ✅ | `pull_request` | `direct` または `pull_request` |
| `commit_message` | ✅ | `Apply multiple Codex patches` | コミットメッセージ |
| `pr_title` | ❌ | `Apply multiple Codex patches` | PRタイトル |
| `fail_fast` | ✅ | `true` | 失敗時に即座に停止するか |
| `run_tests` | ✅ | `skip` | テスト実行の有無 |
| `test_command` | ❌ | (空) | テストコマンド |

---

## 🔧 高度な使い方

### オプション: GitHub Codespacesを使用

もしローカル環境のような体験が欲しい場合（ただし完全にクラウド上）：

1. このリポジトリで「Code」→「Codespaces」→「Create codespace on main」
2. ブラウザでVS Codeが起動
3. ターミナルでCLIツールを使用可能
   ```bash
   ./tools/patch-cli.sh validate patches/my-patch.patch
   ./tools/patch-cli.sh apply patches/my-patch.patch --check
   ```
4. ファイルを編集してコミット＆プッシュ

**でも基本的にはGitHub UIだけで十分です！**

---

## ❓ FAQ

### Q: ローカルにgitやBashがありません。使えますか？
**A:** はい！このシステムはローカル環境を一切必要としません。ブラウザだけで全て完結します。

### Q: CLIツールは使わなくていいですか？
**A:** はい。CLIツールはオプションです。GitHub UIとGitHub Actionsだけで全機能を使用できます。

### Q: パッチファイルをどうやって作成しますか？
**A:** GitHub UIの「Add file」→「Create new file」から作成し、Codexの出力を貼り付けるだけです。

### Q: 複数のリポジトリに同じパッチを適用できますか？
**A:** はい。Personal Access Tokenを設定すれば、任意のリポジトリに適用できます。

### Q: パッチ適用に失敗したらどうなりますか？
**A:** ワークフローが失敗し、対象リポジトリには何も変更されません。Actionsのログで詳細を確認できます。

### Q: 適用前にテストできますか？
**A:** はい。`run_tests` パラメータを `run` に設定し、`test_command` にテストコマンドを指定してください。テストが失敗すればパッチは適用されません。

### Q: 既存のワークフローを壊さないか心配です
**A:** `push_strategy: pull_request` を使用すれば、PR経由でレビューしてからマージできるので安全です。

### Q: パッチが古くなって適用できない場合は？
**A:** ワークフローが失敗します。その場合はCodexに最新のコードベースでパッチを再生成してもらってください。

---

## 🎯 ベストプラクティス

### 1. 段階的な適用
- まず開発ブランチ（`develop`）で試す
- `push_strategy: pull_request` でPR作成
- レビュー後にマージ
- その後、本番ブランチ（`main`）に適用

### 2. パッチの命名
- 日付を含める: `2025-11-04_description.patch`
- 内容が分かる説明: `fix-validation-bug.patch`
- リポジトリごとにフォルダ分け

### 3. テストの活用
- 重要な変更には `run_tests: run` を使用
- テストコマンド例:
  ```bash
  npm ci && npm test
  pytest tests/
  make test
  ```

### 4. コミットメッセージ
- Conventional Commits形式を推奨:
  ```
  feat: add new feature
  fix: resolve bug in validation
  docs: update README
  style: format code
  refactor: restructure components
  test: add unit tests
  chore: update dependencies
  ```

### 5. エラーハンドリング
- バッチ適用時は `fail_fast: false` で全パッチを試行
- 失敗したパッチだけ後で個別に対応

---

## 🔒 セキュリティ

### Personal Access Token の管理
- ✅ 必要最小限のスコープのみ付与（`repo`のみ）
- ✅ GitHub Secretsに保存（コードには含めない）
- ✅ 定期的に更新
- ✅ 不要になったら削除

### パッチの検証
- ✅ 適用前にパッチの内容を必ず確認
- ✅ 信頼できないソースのパッチは使用しない
- ✅ PR経由でチームレビューを推奨
- ✅ テストを実行して動作確認

---

## 📞 サポート

問題が発生した場合：

1. **トラブルシューティングガイドを確認**
   - [詳細なトラブルシューティングガイド](docs/TROUBLESHOOTING.md)
   - よくあるエラーと解決方法を網羅

2. **Actionsログを確認**
   - 「Actions」タブで失敗したワークフローを開く
   - 詳細なエラーメッセージを確認

3. **Issueを作成**
   - https://github.com/your-username/CodexPatch/issues
   - エラーメッセージとパッチファイルを含める

4. **よくある問題と解決策**
   - パッチが古い → Codexに最新コードでパッチを再生成依頼
   - 権限エラー → Personal Access Tokenの設定を確認
   - ファイルが見つからない → patch_fileのパスを確認
   - 詳細は [トラブルシューティングガイド](docs/TROUBLESHOOTING.md) を参照

---

## 📄 ライセンス

MIT License - 自由に使用、改変、配布できます。

---

## 🙏 謝辞

- [GitHub Actions](https://github.com/features/actions) - クラウドCI/CDプラットフォーム
- AI Coding Tools - Codex, Claude, GitHub Copilot
- オープンソースコミュニティ

---

<div align="center">

**🌟 ローカル環境不要！ブラウザだけでパッチ適用を自動化 🌟**

Made with ❤️ for Cloud-Native Development

[始める](#クイックスタート) | [ドキュメント](#詳細な使い方) | [FAQ](#faq)

</div>
