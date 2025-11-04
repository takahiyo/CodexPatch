# CodexPatch チュートリアル

このチュートリアルでは、**ブラウザだけ**でCodexPatchを使った実際のワークフローを段階的に説明します。

## 🎯 このチュートリアルについて

- ✅ ローカル環境不要
- ✅ ブラウザだけで完結
- ✅ 実践的な例で学習
- ✅ 段階的に理解を深める

## 目次

1. [基本的な使い方（ブラウザのみ）](#基本的な使い方ブラウザのみ)
2. [単一パッチの適用](#単一パッチの適用)
3. [複数パッチの一括適用](#複数パッチの一括適用)
4. [他のリポジトリへの適用](#他のリポジトリへの適用)
5. [実践例](#実践例)
6. [オプション: CLIツールの使用](#オプション-cliツールの使用)

---

## 基本的な使い方（ブラウザのみ）

### シナリオ: READMEの更新パッチを適用

あなたのプロジェクトのREADMEを更新したいとします。Codexに依頼して差分を生成してもらいました。

> **注意**: このセクションは完全にブラウザだけで完結します。git cloneやコマンドライン操作は不要です。

#### ステップ1: Codexでパッチを生成

**Codex / ChatGPT / Claudeに依頼:**

```
以下のファイルを編集してください：
README.md

変更内容：
- プロジェクトの説明をより詳しくする
- 主な機能リストを追加
- インストール手順を明確化

git diff形式で出力してください。
```

**Codexの出力例:**
```diff
diff --git a/README.md b/README.md
index 1234567..abcdefg 100644
--- a/README.md
+++ b/README.md
@@ -1,6 +1,12 @@
 # MyProject
 
-A simple web application.
+A powerful web application built with modern technologies.
+
+MyProject helps teams collaborate more effectively with:
+- Real-time updates
+- AI-powered suggestions
+- Seamless integrations
 
 ## Installation
+
+Run `npm install` to get started.
```

#### ステップ2: GitHub UIでパッチファイルを作成

1. **CodexPatchリポジトリをブラウザで開く**
   - `https://github.com/YOUR-USERNAME/CodexPatch`

2. **patchesフォルダに移動**
   - ファイルリストから `patches/` をクリック

3. **サブフォルダを作成（整理のため）**
   - 「Add file」→「Create new file」
   - ファイル名欄に `myorg_myproject/.gitkeep` と入力
   - （スラッシュを入れるとフォルダが自動作成されます）
   - 空ファイルとしてコミット

4. **パッチファイルを作成**
   - `patches/myorg_myproject/` に移動
   - 「Add file」→「Create new file」
   - ファイル名: `2025-11-04_update-readme-description.patch`
   - エディタにCodexの出力を貼り付け
   - 「Commit new file」をクリック

#### ステップ3: GitHub Actionsでパッチを適用

1. **Actionsタブを開く**
   - リポジトリのトップページで「Actions」タブをクリック

2. **ワークフローを選択**
   - 左サイドバーから「Codexパッチ適用」をクリック
   - 「Run workflow」ボタンをクリック

3. **パラメータを入力**
   ```
   target_repository: myorg/myproject
   target_branch: main
   patch_file: patches/myorg_myproject/2025-11-04_update-readme-description.patch
   push_strategy: pull_request
   commit_message: docs: update README description
   pr_title: Update README with better description
   run_tests: skip
   ```

4. **ワークフローを実行**
   - 「Run workflow」をクリック
   - 実行状況を確認（約1-2分）

#### ステップ4: Pull Requestを確認してマージ

1. **対象リポジトリを開く**
   - `https://github.com/myorg/myproject`
   - 「Pull requests」タブをクリック

2. **PRの内容を確認**
   - 新しく作成されたPRを開く
   - 「Files changed」タブで差分を確認

3. **マージ**
   - 問題なければ「Merge pull request」
   - 「Confirm merge」
   - 完了！🎉

---

## 単一パッチの適用（GitHub Actions）

### シナリオ: GitHub Actions経由でパッチを適用

ローカル環境がない、または自動化したい場合、GitHub Actionsを使用します。

#### ステップ1: パッチファイルをコミット

```bash
cd /path/to/CodexPatch

# パッチファイルを追加
git add patches/myorg_myproject/2025-11-04_update-readme-description.patch
git add patches/myorg_myproject/2025-11-04_update-readme-description.meta.json
git commit -m "Add patch: update README description"
git push
```

#### ステップ2: GitHub Actionsでワークフローを実行

1. GitHubでCodexPatchリポジトリを開く
2. 「Actions」タブをクリック
3. 「Codexパッチ適用」ワークフローを選択
4. 「Run workflow」をクリック

#### ステップ3: パラメータを入力

```
target_repository: myorg/myproject
target_branch: main
patch_file: patches/myorg_myproject/2025-11-04_update-readme-description.patch
push_strategy: pull_request
commit_message: docs: update README description
pr_title: Update README with better description
pr_body: (空欄でOK - 自動生成されます)
run_tests: skip
```

#### ステップ4: ワークフローの実行を確認

ワークフローが成功すると、`myorg/myproject` リポジトリに新しいPRが作成されます。

#### ステップ5: PRをレビューしてマージ

1. `myorg/myproject` リポジトリの「Pull requests」タブを開く
2. 作成されたPRを確認
3. 変更内容をレビュー
4. 問題なければマージ

---

## 複数パッチの一括適用

### シナリオ: 複数の機能を一度に適用

複数のパッチを一度に適用したい場合の手順です。

#### パッチファイルの準備

以下の3つのパッチを準備したとします：

```
patches/myorg_myproject/2025-11-04_update-readme.patch
patches/myorg_myproject/2025-11-04_add-new-feature.patch
patches/myorg_myproject/2025-11-04_fix-bug.patch
```

#### 方法1: CLI でバッチ適用

バッチ設定ファイルを作成：

```json
{
  "description": "November 4th updates",
  "targetRepository": "myorg/myproject",
  "targetBranch": "develop",
  "patches": [
    {
      "file": "patches/myorg_myproject/2025-11-04_update-readme.patch",
      "target": ".",
      "description": "Update README"
    },
    {
      "file": "patches/myorg_myproject/2025-11-04_add-new-feature.patch",
      "target": ".",
      "description": "Add new feature"
    },
    {
      "file": "patches/myorg_myproject/2025-11-04_fix-bug.patch",
      "target": ".",
      "description": "Fix critical bug"
    }
  ],
  "options": {
    "failFast": true,
    "runTests": true,
    "testCommand": "npm test"
  }
}
```

保存場所: `patches/myorg_myproject/batch-2025-11-04.json`

実行:

```bash
./tools/patch-cli.sh batch patches/myorg_myproject/batch-2025-11-04.json
```

#### 方法2: GitHub Actions で一括適用

1. 「Actions」タブで「複数パッチの一括適用」ワークフローを選択
2. 「Run workflow」をクリック
3. パラメータを入力：

```
target_repository: myorg/myproject
target_branch: develop
patch_files:
patches/myorg_myproject/2025-11-04_update-readme.patch
patches/myorg_myproject/2025-11-04_add-new-feature.patch
patches/myorg_myproject/2025-11-04_fix-bug.patch

push_strategy: pull_request
commit_message: Apply November 4th updates
fail_fast: true
run_tests: run
test_command: npm ci && npm test
```

---

## 他のリポジトリへの適用

### シナリオ: 別の組織のリポジトリにパッチを適用

#### 事前準備: Personal Access Token の設定

1. **PATを作成**

GitHub で [Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens) を開き、新しいトークンを作成。

スコープ:
- ✅ `repo` (Full control of private repositories)

2. **CodexPatchリポジトリにSecretを設定**

CodexPatchリポジトリで:
- Settings → Secrets and variables → Actions
- 「New repository secret」をクリック
- Name: `PATCH_APPLIER_TOKEN`
- Secret: 作成したPATを貼り付け

#### パッチの適用

通常通りワークフローを実行し、`target_repository` に別のリポジトリを指定：

```
target_repository: anotherorg/anotherrepo
target_branch: main
patch_file: patches/anotherorg_anotherrepo/2025-11-04_feature.patch
...
```

---

## 実践例

### 例1: ヘッダーコンポーネントの更新

**状況**: React アプリのヘッダーデザインを更新

**Codexへの依頼**:
```
現在のヘッダーコンポーネントを以下のように更新してください：
- ロゴを左揃えから中央揃えに変更
- ナビゲーションメニューのフォントサイズを16pxに
- 背景色を白からダークブルーに
```

**生成されたパッチ**:
```diff
diff --git a/src/components/Header.tsx b/src/components/Header.tsx
index 1234567..abcdefg 100644
--- a/src/components/Header.tsx
+++ b/src/components/Header.tsx
@@ -5,11 +5,11 @@ import styles from './Header.module.css';
 export const Header: React.FC = () => {
   return (
-    <header className={styles.header}>
-      <div className={styles.logoLeft}>
+    <header className={styles.headerDark}>
+      <div className={styles.logoCenter}>
         <Logo />
       </div>
-      <nav className={styles.nav}>
+      <nav className={styles.navLarge}>
         <NavMenu />
       </nav>
     </header>

diff --git a/src/components/Header.module.css b/src/components/Header.module.css
index abc123..def456 100644
--- a/src/components/Header.module.css
+++ b/src/components/Header.module.css
@@ -1,16 +1,21 @@
 .header {
   padding: 1rem 2rem;
-  background-color: white;
+  background-color: #1a365d;
   border-bottom: 1px solid #e2e8f0;
 }
 
-.logoLeft {
-  text-align: left;
+.headerDark {
+  composes: header;
+}
+
+.logoCenter {
+  text-align: center;
 }
 
 .nav {
   margin-top: 1rem;
+  font-size: 16px;
 }
```

**適用手順**:
```bash
# テンプレート生成
./scripts/generate-patch-template.sh \
  -n "update-header-design" \
  -r "myorg/react-app" \
  -d "Update header component design"

# パッチを貼り付け
# (エディタで patches/myorg_react-app/2025-11-04_update-header-design.patch を編集)

# 検証
./tools/patch-cli.sh validate patches/myorg_react-app/2025-11-04_update-header-design.patch

# ドライラン
cd /path/to/react-app
/path/to/CodexPatch/tools/patch-cli.sh apply \
  /path/to/CodexPatch/patches/myorg_react-app/2025-11-04_update-header-design.patch \
  --check

# 適用
/path/to/CodexPatch/tools/patch-cli.sh apply \
  /path/to/CodexPatch/patches/myorg_react-app/2025-11-04_update-header-design.patch

# 動作確認
npm start
# ブラウザで確認

# テスト実行
npm test

# コミット
git add .
git commit -m "style: update header component design"
git push
```

### 例2: API エンドポイントの追加

**状況**: Express.js アプリに新しいAPIエンドポイントを追加

**Codexへの依頼**:
```
/api/users/:id/profile エンドポイントを追加してください。
- GET リクエストでユーザープロファイルを返す
- 認証が必要
- エラーハンドリングを含める
```

**適用後のテスト**:
```bash
# パッチ適用時にテストも実行
./tools/patch-cli.sh apply patches/myorg_api/2025-11-04_add-profile-endpoint.patch

# API サーバーを起動
npm start

# 別のターミナルでテスト
curl -X GET http://localhost:3000/api/users/123/profile \
  -H "Authorization: Bearer YOUR_TOKEN"

# 統合テストを実行
npm run test:integration
```

### 例3: 複数ファイルにわたる大規模リファクタリング

**状況**: 複数のコンポーネントで共通のユーティリティ関数を使用するようにリファクタリング

**Codexへの依頼**:
```
以下のコンポーネントで重複している日付フォーマット処理を
共通のユーティリティ関数に抽出してください：
- src/components/PostList.tsx
- src/components/CommentSection.tsx
- src/components/UserProfile.tsx
```

**生成されたパッチ（複数ファイル）**:
```diff
diff --git a/src/utils/dateFormat.ts b/src/utils/dateFormat.ts
new file mode 100644
index 0000000..1234567
--- /dev/null
+++ b/src/utils/dateFormat.ts
@@ -0,0 +1,10 @@
+export const formatDate = (date: Date): string => {
+  return new Intl.DateTimeFormat('ja-JP', {
+    year: 'numeric',
+    month: 'long',
+    day: 'numeric'
+  }).format(date);
+};

diff --git a/src/components/PostList.tsx b/src/components/PostList.tsx
...
(各コンポーネントの変更)
```

**適用とテスト**:
```bash
# パッチ適用
./tools/patch-cli.sh apply patches/myorg_app/2025-11-04_refactor-date-format.patch

# TypeScript の型チェック
npm run type-check

# すべてのテストを実行
npm test

# ビルドして確認
npm run build

# 問題なければコミット
git add .
git commit -m "refactor: extract common date formatting utility"
git push
```

---

## トラブルシューティング Tips

### パッチが適用できない場合（GitHub Actions）

1. **Actionsログを確認**
   - 「Actions」タブで失敗したワークフローを開く
   - 各ステップの詳細ログを確認
   - エラーメッセージをコピー

2. **よくある原因**
   - **パッチが古い**: 対象コードが変更されている
     - 解決: Codexに最新のコードでパッチを再生成依頼
   - **ファイルパスが間違っている**: `patch_file` パラメータが正しくない
     - 解決: パッチファイルのパスをコピー＆ペースト
   - **権限エラー**: PATが正しく設定されていない
     - 解決: Secret `PATCH_APPLIER_TOKEN` を確認

### GitHub Actions が失敗する場合

1. **ログを確認**: Actions タブで詳細ログを確認
2. **パッチファイルを確認**: ファイルが正しくコミットされているか
3. **権限を確認**: PATが正しく設定されているか（外部リポジトリの場合）
4. **パラメータを確認**: 入力パラメータが正しいか

---

## オプション: CLIツールの使用

> **注意**: このセクションはオプションです。ローカル環境がある場合や、GitHub Codespacesを使用する場合のみ参照してください。

### GitHub Codespacesで使用

1. リポジトリページで「Code」→「Codespaces」→「Create codespace」
2. ブラウザでVS Codeが起動
3. ターミナルでCLIコマンドを使用可能

### CLIコマンド例

```bash
# パッチを検証
./tools/patch-cli.sh validate patches/my-patch.patch

# パッチの詳細情報を表示
./tools/patch-cli.sh info patches/my-patch.patch

# ドライラン（適用テスト）
./tools/patch-cli.sh apply patches/my-patch.patch --check

# 実際に適用
./tools/patch-cli.sh apply patches/my-patch.patch

# パッチ一覧を表示
./tools/patch-cli.sh list patches/

# 現在の変更からパッチを作成
./tools/patch-cli.sh create patches/my-changes.patch
```

詳細は [CLI リファレンス](../tools/patch-cli.sh) を参照してください。

---

## まとめ

このチュートリアルでは、**ブラウザだけで完結する**CodexPatchの主要な使い方を実践的な例で学びました。

**重要なポイント**:
1. ✅ ローカル環境不要でパッチを適用できる
2. ✅ GitHub UIでパッチファイルを作成
3. ✅ GitHub Actionsで自動適用
4. ✅ PR経由で安全にレビュー＆マージ

**このシステムの利点**:
- 💻 どこからでもアクセス可能
- 🚀 すぐに使い始められる
- 🔒 安全（PR経由でレビュー）
- 📊 透明性が高い（すべてGitHub上で追跡可能）

## 次のステップ

1. **実際に試してみる**
   - [クラウド完全ガイド](CLOUD_ONLY_GUIDE.md)で詳細な手順を確認
   - サンプルパッチで練習

2. **チームで活用**
   - チームメンバーに共有
   - レビュープロセスに組み込む

3. **さらに学ぶ**
   - [README.md](../README.md) - 完全なリファレンス
   - [ARCHITECTURE.md](ARCHITECTURE.md) - システム設計
   - [CLOUD_ONLY_GUIDE.md](CLOUD_ONLY_GUIDE.md) - 完全クラウドガイド

---

<div align="center">

**📖 Happy Patching with Cloud-Native Workflow! 🚀**

[メインREADMEに戻る](../README.md) | [クラウド完全ガイド](CLOUD_ONLY_GUIDE.md) | [アーキテクチャ](ARCHITECTURE.md)

</div>
