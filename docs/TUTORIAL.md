# CodexPatch チュートリアル

このチュートリアルでは、CodexPatchを使った実際のワークフローを段階的に説明します。

## 目次

1. [基本的な使い方](#基本的な使い方)
2. [単一パッチの適用](#単一パッチの適用)
3. [複数パッチの一括適用](#複数パッチの一括適用)
4. [他のリポジトリへの適用](#他のリポジトリへの適用)
5. [実践例](#実践例)

---

## 基本的な使い方

### シナリオ: READMEの更新パッチを適用

あなたのプロジェクトのREADMEを更新したいとします。Codexに依頼して差分を生成してもらいました。

#### ステップ1: パッチテンプレートの生成

```bash
./scripts/generate-patch-template.sh \
  -n "update-readme-description" \
  -r "myorg/myproject" \
  -b "main" \
  -d "Update README with better project description"
```

出力:
```
[SUCCESS] テンプレートを作成しました:
  パッチファイル: patches/myorg_myproject/2025-11-04_update-readme-description.patch
  メタデータ: patches/myorg_myproject/2025-11-04_update-readme-description.meta.json
```

#### ステップ2: Codexで生成された差分をコピー

Codexから以下のような出力を得たとします：

```diff
diff --git a/README.md b/README.md
index abc123..def456 100644
--- a/README.md
+++ b/README.md
@@ -1,6 +1,8 @@
 # MyProject
 
-A simple web application.
+A powerful web application built with modern technologies.
+
+MyProject helps teams collaborate more effectively with real-time updates and AI-powered suggestions.
 
 ## Features
```

この差分を `patches/myorg_myproject/2025-11-04_update-readme-description.patch` に貼り付けます。

#### ステップ3: パッチを検証

```bash
./tools/patch-cli.sh validate patches/myorg_myproject/2025-11-04_update-readme-description.patch
```

出力:
```
[INFO] パッチファイルを検証中: patches/myorg_myproject/2025-11-04_update-readme-description.patch
[SUCCESS] パッチファイルは有効です
  ファイル数: 1
  追加行数: 4
  削除行数: 1
  ファイルサイズ: 342 bytes
```

#### ステップ4: パッチ情報の確認

```bash
./tools/patch-cli.sh info patches/myorg_myproject/2025-11-04_update-readme-description.patch
```

#### ステップ5: ドライラン

実際に適用する前に、問題がないか確認：

```bash
# ターゲットリポジトリのディレクトリに移動
cd /path/to/myproject

# ドライランを実行
/path/to/CodexPatch/tools/patch-cli.sh apply \
  /path/to/CodexPatch/patches/myorg_myproject/2025-11-04_update-readme-description.patch \
  --check
```

出力:
```
[INFO] ドライラン実行中（実際の変更は行いません）
[INFO] 適用するパッチの統計:
 README.md | 5 +++--
 1 file changed, 4 insertions(+), 1 deletion(-)

[SUCCESS] パッチは問題なく適用できます
```

#### ステップ6: パッチを実際に適用

```bash
/path/to/CodexPatch/tools/patch-cli.sh apply \
  /path/to/CodexPatch/patches/myorg_myproject/2025-11-04_update-readme-description.patch
```

出力:
```
[INFO] パッチを適用中
[INFO] 適用するパッチの統計:
 README.md | 5 +++--
 1 file changed, 4 insertions(+), 1 deletion(-)

[SUCCESS] パッチを適用しました
[INFO] 変更されたファイル:
 M README.md
```

#### ステップ7: 変更を確認してコミット

```bash
# 変更を確認
git diff

# コミット
git add README.md
git commit -m "docs: update README description"
git push
```

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

### パッチが適用できない場合

```bash
# 1. 詳細な情報を表示
./tools/patch-cli.sh apply patches/my-patch.patch --verbose

# 2. 3-way マージを試す
./tools/patch-cli.sh apply patches/my-patch.patch --3way

# 3. それでもダメな場合は手動で適用
git apply --reject patches/my-patch.patch
# .rej ファイルを確認して手動で修正
```

### GitHub Actions が失敗する場合

1. **ログを確認**: Actions タブで詳細ログを確認
2. **ローカルで再現**: 同じ環境でローカルテスト
3. **パッチファイルを確認**: ファイルが正しくコミットされているか
4. **権限を確認**: PATが正しく設定されているか

---

## まとめ

このチュートリアルでは、CodexPatchの主要な使い方を実践的な例で学びました。

**重要なポイント**:
1. 必ず検証してからパッチを適用
2. ドライランで安全性を確認
3. テストを実行して動作確認
4. PR経由で変更をレビュー

次のステップとして、[README.md](../README.md) で高度な機能を確認してください。
