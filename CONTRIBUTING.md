# CodexPatch への貢献ガイド

CodexPatch への貢献にご興味をお持ちいただきありがとうございます！このドキュメントでは、プロジェクトに貢献する方法を説明します。

## 目次

- [行動規範](#行動規範)
- [どのように貢献できるか](#どのように貢献できるか)
- [開発環境のセットアップ](#開発環境のセットアップ)
- [プルリクエストのプロセス](#プルリクエストのプロセス)
- [コーディング規約](#コーディング規約)
- [コミットメッセージのガイドライン](#コミットメッセージのガイドライン)

---

## 行動規範

このプロジェクトは、すべての参加者が敬意を持って協力できる環境を維持することを目指しています。

### 期待される行動

- 他の貢献者を尊重する
- 建設的なフィードバックを提供する
- プロジェクトの目標に焦点を当てる
- 初心者に対して親切で忍耐強く接する

### 許容されない行動

- ハラスメントや差別的な言動
- 個人攻撃や侮辱
- プライバシーの侵害
- その他のプロフェッショナルでない行為

---

## どのように貢献できるか

### バグ報告

バグを見つけた場合は、以下の情報を含めて Issue を作成してください：

- **明確なタイトル**: バグの内容を簡潔に説明
- **再現手順**: バグを再現する詳細な手順
- **期待される動作**: 本来どうあるべきか
- **実際の動作**: 実際に何が起こったか
- **環境情報**: OS、Bashバージョン、Gitバージョンなど
- **スクリーンショット**: 該当する場合

**テンプレート:**

```markdown
## バグの説明
簡潔にバグを説明してください。

## 再現手順
1. '...' を実行
2. '...' をクリック
3. '...' を確認
4. エラーが表示される

## 期待される動作
本来どうあるべきかを説明してください。

## 実際の動作
実際に何が起こったかを説明してください。

## 環境
- OS: [e.g., macOS 14.0, Ubuntu 22.04]
- Bash: [e.g., 5.2.15]
- Git: [e.g., 2.42.0]

## 追加情報
その他の関連情報やスクリーンショット
```

### 機能提案

新しい機能のアイデアがある場合：

1. まず既存の Issue を確認（重複を避けるため）
2. Issue を作成して提案を説明
3. ユースケースと期待される効果を記載
4. 可能であれば実装案を提示

**テンプレート:**

```markdown
## 機能の概要
提案する機能を簡潔に説明してください。

## 動機
なぜこの機能が必要か、どのような問題を解決するか説明してください。

## 提案する解決策
どのように実装するか、アイデアを説明してください。

## 代替案
検討した他の解決策があれば説明してください。

## 追加情報
その他の関連情報やモックアップ
```

### ドキュメントの改善

- タイポや文法の修正
- 説明の明確化
- 例の追加
- 翻訳の貢献

### コードの貢献

- バグ修正
- 新機能の実装
- パフォーマンスの改善
- テストの追加

---

## 開発環境のセットアップ

### 必要なツール

- **Git** (2.30+)
- **Bash** (4.0+)
- **jq** (1.6+) - JSON処理用
- **テキストエディタ** (VS Code、Vim など)

### リポジトリのフォークとクローン

```bash
# 1. GitHubでリポジトリをフォーク

# 2. フォークしたリポジトリをクローン
git clone https://github.com/YOUR-USERNAME/CodexPatch.git
cd CodexPatch

# 3. アップストリームリモートを追加
git remote add upstream https://github.com/ORIGINAL-OWNER/CodexPatch.git

# 4. 最新の変更を取得
git fetch upstream
```

### ブランチの作成

```bash
# mainブランチから最新の変更を取得
git checkout main
git pull upstream main

# 新しいフィーチャーブランチを作成
git checkout -b feature/your-feature-name

# または バグ修正の場合
git checkout -b fix/bug-description
```

### ローカルでのテスト

```bash
# CLIツールのテスト
./tools/patch-cli.sh help
./tools/patch-cli.sh validate patches/examples/sample-readme-update.patch

# スクリプトのシンタックスチェック
bash -n tools/patch-cli.sh
bash -n scripts/generate-patch-template.sh

# ShellCheck（インストールされている場合）
shellcheck tools/patch-cli.sh
shellcheck scripts/generate-patch-template.sh
```

---

## プルリクエストのプロセス

### 1. 変更を実装

- 小さく、焦点を絞った変更を心がける
- 既存のコードスタイルに従う
- 適切なコメントを追加

### 2. テストを追加

新機能やバグ修正には、可能な限りテストを追加してください。

### 3. ドキュメントを更新

- README.md の更新（必要に応じて）
- コマンドのヘルプテキストの更新
- CHANGELOG.md への記載（該当する場合）

### 4. コミット

```bash
# 変更をステージング
git add .

# コミット（適切なメッセージで）
git commit -m "feat: add new validation feature"

# または複数のコミットを分ける
git add tools/patch-cli.sh
git commit -m "feat: add validation for patch metadata"

git add docs/TUTORIAL.md
git commit -m "docs: add validation examples to tutorial"
```

### 5. プッシュ

```bash
# フォークしたリポジトリにプッシュ
git push origin feature/your-feature-name
```

### 6. Pull Request の作成

1. GitHubでフォークしたリポジトリを開く
2. "Compare & pull request" をクリック
3. PRテンプレートに従って説明を記入
4. 関連するIssueをリンク（例: `Closes #123`）

**PRテンプレート:**

```markdown
## 変更の概要
この PR で何を変更したか簡潔に説明してください。

## 変更の種類
- [ ] バグ修正
- [ ] 新機能
- [ ] ドキュメントの更新
- [ ] リファクタリング
- [ ] パフォーマンス改善
- [ ] テストの追加

## 関連Issue
Closes #<issue番号>

## 変更内容の詳細
変更の詳細や実装方法について説明してください。

## テスト方法
この変更をどのようにテストしたか説明してください。

## チェックリスト
- [ ] コードが既存のスタイルガイドに従っている
- [ ] セルフレビューを実施した
- [ ] コードにコメントを追加した（特に理解しにくい部分）
- [ ] ドキュメントを更新した
- [ ] 変更によって新しい警告が発生していない
- [ ] テストを追加した（該当する場合）
- [ ] すべてのテストがパスする

## スクリーンショット（該当する場合）
変更による視覚的な影響がある場合は、スクリーンショットを追加してください。
```

### 7. レビューへの対応

- レビュアーからのフィードバックに迅速に対応
- 建設的な議論を心がける
- 必要に応じて変更を追加コミット

```bash
# フィードバックに基づいて修正
git add .
git commit -m "fix: address review comments"
git push origin feature/your-feature-name
```

---

## コーディング規約

### Bash スクリプト

#### 命名規則

- **関数名**: `snake_case`
  ```bash
  validate_patch() { ... }
  show_help() { ... }
  ```

- **変数名**: `snake_case` (ローカル変数) または `UPPER_CASE` (環境変数・定数)
  ```bash
  local patch_file="example.patch"
  readonly VERSION="1.0.0"
  ```

#### スタイル

- **インデント**: 4スペース
- **行の長さ**: 100文字以内を推奨
- **引用符**: 変数は常にダブルクォートで囲む
  ```bash
  echo "$variable"  # Good
  echo $variable    # Bad
  ```

- **エラーハンドリング**: `set -euo pipefail` を使用
  ```bash
  #!/bin/bash
  set -euo pipefail
  ```

- **関数の構造**:
  ```bash
  function_name() {
      local param1="$1"
      local param2="$2"
      
      # 処理
      
      return 0
  }
  ```

#### コメント

- 複雑なロジックにはコメントを追加
- 関数の前に目的を説明
- TODO/FIXME マーカーを適切に使用

```bash
# パッチファイルを検証する
# Arguments:
#   $1 - パッチファイルのパス
# Returns:
#   0 - 検証成功
#   1 - 検証失敗
validate_patch() {
    local patch_file="$1"
    
    # TODO: より詳細な検証を追加
    # FIXME: バイナリファイルの処理を改善
    
    if [[ ! -f "$patch_file" ]]; then
        return 1
    fi
    
    return 0
}
```

### GitHub Actions ワークフロー

- **インデント**: 2スペース
- **命名**: `kebab-case`
- **環境変数**: 明確に定義
- **ステップ名**: わかりやすい日本語または英語

```yaml
name: パッチ適用

on:
  workflow_dispatch:

jobs:
  apply-patch:
    runs-on: ubuntu-latest
    steps:
      - name: リポジトリをチェックアウト
        uses: actions/checkout@v4
```

---

## コミットメッセージのガイドライン

### Conventional Commits

このプロジェクトは [Conventional Commits](https://www.conventionalcommits.org/) に従います。

#### 形式

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type（種類）

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（空白、フォーマットなど）
- `refactor`: バグ修正でも機能追加でもないコード変更
- `perf`: パフォーマンス改善
- `test`: テストの追加や修正
- `chore`: ビルドプロセスや補助ツールの変更

#### Scope（スコープ）

変更の範囲を示す（オプション）:
- `cli`: CLIツール関連
- `workflow`: GitHub Actions関連
- `docs`: ドキュメント関連
- `scripts`: スクリプト関連

#### 例

```bash
# 新機能
git commit -m "feat(cli): add batch apply command"

# バグ修正
git commit -m "fix(workflow): correct token validation logic"

# ドキュメント
git commit -m "docs: update README with new examples"

# リファクタリング
git commit -m "refactor(cli): extract validation function"

# 詳細な説明付き
git commit -m "feat(cli): add 3-way merge support

Add --3way option to apply command for better conflict resolution.
This uses git apply --3way internally.

Closes #42"
```

---

## リリースプロセス

メンテナーが行うリリース手順：

1. **バージョンの決定**: セマンティックバージョニングに従う
2. **CHANGELOG.md の更新**: 新しいバージョンの変更をまとめる
3. **タグの作成**: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. **プッシュ**: `git push origin v1.0.0`
5. **GitHubリリースの作成**: リリースノートを記載

---

## 質問やサポート

- **Issue**: バグ報告や機能提案
- **Discussions**: 一般的な質問や議論
- **Email**: プライベートな問題や懸念

---

## ライセンス

このプロジェクトに貢献することで、あなたの貢献が MIT ライセンスの下でライセンスされることに同意したものとみなされます。

---

## 謝辞

CodexPatch への貢献に感謝します！あなたの時間と労力は、このプロジェクトをより良いものにします。
