# 完全クラウド運用ガイド

このガイドでは、**ローカル環境を一切使わず**、ブラウザとGitHub UIだけでCodexPatchを使用する方法を詳しく説明します。

## 🎯 前提条件

- ✅ GitHubアカウント
- ✅ Webブラウザ（Chrome、Firefox、Safari、Edgeなど）
- ❌ git コマンド不要
- ❌ ターミナル不要
- ❌ ローカルエディタ不要

---

## 📋 完全ブラウザワークフロー

### ステップ0: 初回セットアップ（1回のみ）

#### このリポジトリをフォークまたは使用

**オプションA: フォークする（推奨）**
1. https://github.com/original-owner/CodexPatch を開く
2. 右上の「Fork」ボタンをクリック
3. あなたのアカウントにフォークが作成されます
4. フォークしたリポジトリ（`https://github.com/YOUR-USERNAME/CodexPatch`）を使用

**オプションB: 直接このリポジトリを使う**
- このリポジトリへの書き込み権限がある場合
- 個人リポジトリの場合

---

### ステップ1: AIツールでパッチを生成

#### 1-1. Codex / Claude / ChatGPTに依頼

**例：ヘッダーコンポーネントの更新**

```
以下の変更を実装してください：

ファイル: src/components/Header.tsx
変更内容:
- タイトルのフォントサイズを24pxに変更
- 中央揃えに変更
- 背景色を白からライトグレーに変更

git diff 形式で出力してください。
ファイル全体ではなく、差分のみを出力してください。
```

#### 1-2. AIツールからの出力例

```diff
diff --git a/src/components/Header.tsx b/src/components/Header.tsx
index 1234567..abcdefg 100644
--- a/src/components/Header.tsx
+++ b/src/components/Header.tsx
@@ -5,11 +5,11 @@ import styles from './Header.module.css';
 export const Header: React.FC = () => {
   return (
-    <header className={styles.header}>
-      <h1 className={styles.title}>My App</h1>
+    <header className={styles.headerGray}>
+      <h1 className={styles.titleCenter}>My App</h1>
     </header>
   );
 };

diff --git a/src/components/Header.module.css b/src/components/Header.module.css
index abc123..def456 100644
--- a/src/components/Header.module.css
+++ b/src/components/Header.module.css
@@ -1,10 +1,16 @@
 .header {
   padding: 1rem;
-  background-color: white;
+  background-color: #f5f5f5;
 }
 
 .title {
-  font-size: 18px;
+  font-size: 24px;
+  text-align: center;
 }
```

#### 1-3. 出力をコピー

- 上記の差分全体を選択してコピー（Ctrl+C / Cmd+C）

---

### ステップ2: GitHub UIでパッチファイルを作成

#### 2-1. リポジトリを開く

1. ブラウザで `https://github.com/YOUR-USERNAME/CodexPatch` を開く
2. リポジトリのトップページが表示される

#### 2-2. patchesディレクトリに移動

1. ファイルリストから `patches/` フォルダをクリック
2. （オプション）整理のため、サブフォルダを作成:
   - 「Add file」→「Create new file」をクリック
   - ファイル名に `myorg_myrepo/dummy.txt` と入力（フォルダが自動作成される）
   - 「dummy」と入力
   - 「Commit new file」をクリック
   - 作成された `patches/myorg_myrepo/` フォルダに移動

#### 2-3. 新しいパッチファイルを作成

1. `patches/` または `patches/myorg_myrepo/` ディレクトリで「Add file」をクリック
2. 「Create new file」を選択

3. **ファイル名を入力**
   ```
   2025-11-04_update-header.patch
   ```
   命名規則: `YYYY-MM-DD_description.patch`

4. **パッチ内容を貼り付け**
   - エディタ領域にAIツールからコピーした差分を貼り付け（Ctrl+V / Cmd+V）
   - 内容が正しく貼り付けられたことを確認

5. **コミット**
   - 下部の「Commit new file」セクションに移動
   - コミットメッセージ（既定値でOK）: `Create 2025-11-04_update-header.patch`
   - 「Commit directly to the main branch」を選択（既定）
   - 「Commit new file」ボタンをクリック

✅ パッチファイルが作成されました！

---

### ステップ3: GitHub Actionsでパッチを適用

#### 3-1. Actionsタブを開く

1. リポジトリのトップページに戻る
2. 上部のタブから「Actions」をクリック

#### 3-2. ワークフローを選択

1. 左サイドバーに「Workflows」リストが表示される
2. 「Codexパッチ適用」をクリック

#### 3-3. ワークフローを手動実行

1. 右側に「This workflow has a workflow_dispatch event trigger.」と表示される
2. 右上の青い「Run workflow」ボタンをクリック
3. ドロップダウンメニューが表示される

#### 3-4. パラメータを入力

以下のフィールドに値を入力：

```
Use workflow from: Branch: main [そのまま]

target_repository: myorg/myrepo
  ↑ パッチを適用したいリポジトリ（owner/name形式）
  ↑ 空欄の場合はこのリポジトリ自身

target_branch: main
  ↑ 適用先のブランチ名

patch_file: patches/myorg_myrepo/2025-11-04_update-header.patch
  ↑ 先ほど作成したパッチファイルのパス

push_strategy: pull_request
  ↑ "pull_request" または "direct"
  ↑ pull_request推奨（レビューしてからマージ）

commit_message: style: update header component styling
  ↑ コミットメッセージ（Conventional Commits推奨）

pr_title: Update header component styling
  ↑ PRのタイトル（pull_request選択時のみ使用）

pr_body: [空欄でOK]
  ↑ PR本文（空欄なら自動生成）

run_tests: skip
  ↑ "skip" または "run"
  ↑ テストを実行する場合は "run"

test_command: [空欄]
  ↑ run_tests=runの場合のみ入力
  ↑ 例: npm ci && npm test
```

#### 3-5. ワークフローを実行

1. すべてのフィールドを確認
2. 下部の緑色「Run workflow」ボタンをクリック
3. ページがリロードされ、ワークフローが実行キューに追加される

#### 3-6. 実行状況を確認

1. 「Codexパッチ適用」ワークフローのページに黄色のドットが表示される
2. 実行中のワークフローをクリックして詳細を表示
3. 各ステップの進行状況をリアルタイムで確認できる

**ステップの流れ:**
- ✅ Set up job
- ✅ パッチを取得
- ✅ パッチファイルを検証
- ✅ 適用先リポジトリをチェックアウト
- ✅ 作業ブランチを準備
- ✅ パッチのサマリーを表示
- ✅ パッチを適用
- ✅ 作業ツリーの状態を表示
- ✅ コミットを作成
- ✅ 変更をプッシュ
- ✅ Pull Request を作成
- ✅ Complete job

#### 3-7. 成功を確認

- すべてのステップに緑色のチェックマークが表示される
- ワークフローが成功！🎉

---

### ステップ4: Pull Requestを確認してマージ

#### 4-1. 対象リポジトリのPRを開く

1. ブラウザで対象リポジトリを開く
   - 例: `https://github.com/myorg/myrepo`
2. 「Pull requests」タブをクリック
3. 新しいPRが表示される:
   - タイトル: 「Update header component styling」
   - 作成者: github-actions[bot]

#### 4-2. PRの内容を確認

1. PRをクリックして開く
2. 「Files changed」タブで変更内容を確認
3. 差分が正しく適用されているか確認

#### 4-3. レビューとマージ

**オプションA: すぐにマージ（小さな変更の場合）**
1. 「Merge pull request」ボタンをクリック
2. 「Confirm merge」をクリック
3. 完了！

**オプションB: レビュー後にマージ（推奨）**
1. チームメンバーにレビューを依頼
2. 承認後に「Merge pull request」をクリック
3. 「Confirm merge」をクリック
4. 完了！

**オプションC: 変更が必要な場合**
- PRをクローズ
- Codexに修正依頼
- 新しいパッチファイルを作成して再実行

---

## 🔄 複数パッチの一括適用

### シナリオ
複数の小さな修正を一度に適用したい。

### 手順

#### 1. 各パッチファイルを作成

GitHub UIで以下のファイルを順番に作成：

**パッチ1: タイポ修正**
- ファイル名: `patches/batch-nov04/fix-typo-readme.patch`
- 内容: READMEのタイポ修正差分

**パッチ2: 依存関係更新**
- ファイル名: `patches/batch-nov04/update-dependencies.patch`
- 内容: package.jsonの差分

**パッチ3: コメント追加**
- ファイル名: `patches/batch-nov04/add-code-comments.patch`
- 内容: ソースコードコメント追加の差分

#### 2. バッチワークフローを実行

1. 「Actions」→「複数パッチの一括適用」
2. 「Run workflow」をクリック
3. パラメータを入力:

```
target_repository: myorg/myrepo
target_branch: develop

patch_files:
patches/batch-nov04/fix-typo-readme.patch
patches/batch-nov04/update-dependencies.patch
patches/batch-nov04/add-code-comments.patch

↑ 各行に1つのパッチファイルパスを入力
↑ 改行で区切る

push_strategy: pull_request
commit_message: chore: apply multiple improvements
pr_title: Batch updates - typo fix, deps update, add comments
fail_fast: true
run_tests: run
test_command: npm ci && npm test
```

4. 「Run workflow」をクリック

#### 3. 結果を確認

- ワークフローのサマリーに各パッチの適用状況が表示される
- 成功したパッチ数と失敗したパッチ数を確認
- 1つのPRにすべての変更がまとめられる

---

## 🔐 外部リポジトリへの適用設定

### 必要なケース
- 別の組織のリポジトリにパッチを適用したい
- プライベートリポジトリにパッチを適用したい
- 複数のリポジトリを管理したい

### 設定手順

#### ステップ1: Personal Access Token (PAT) を作成

1. **GitHub設定を開く**
   - 右上のプロフィールアイコンをクリック
   - 「Settings」を選択

2. **Developer settingsに移動**
   - 左サイドバー最下部の「Developer settings」をクリック

3. **Personal access tokensを開く**
   - 「Personal access tokens」→「Tokens (classic)」をクリック

4. **新しいトークンを生成**
   - 「Generate new token」→「Generate new token (classic)」をクリック
   - GitHub パスワードを入力（必要な場合）

5. **トークンを設定**
   ```
   Note: CodexPatch Applier Token
   Expiration: 90 days（または任意）
   
   Select scopes:
   ☑️ repo
     ☑️ repo:status
     ☑️ repo_deployment
     ☑️ public_repo
     ☑️ repo:invite
     ☑️ security_events
   ```

6. **トークンを生成**
   - 下部の「Generate token」ボタンをクリック
   - **重要**: トークンをコピー（一度しか表示されません！）
   - 例: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

#### ステップ2: Secretとして保存

1. **CodexPatchリポジトリを開く**
   - `https://github.com/YOUR-USERNAME/CodexPatch`

2. **Settingsタブを開く**
   - 上部タブの「Settings」をクリック

3. **Secrets設定を開く**
   - 左サイドバーの「Secrets and variables」を展開
   - 「Actions」をクリック

4. **新しいSecretを作成**
   - 「New repository secret」ボタンをクリック
   - Name: `PATCH_APPLIER_TOKEN`
   - Secret: コピーしたPATを貼り付け
   - 「Add secret」をクリック

✅ 設定完了！これで任意のリポジトリにパッチを適用できます。

#### ステップ3: 使用方法

ワークフロー実行時に `target_repository` に任意のリポジトリを指定：

```
target_repository: other-org/other-repo
target_branch: main
patch_file: patches/other-org_other-repo/my-patch.patch
...
```

ワークフローが自動的にPATを使用してアクセスします。

---

## 📱 モバイルブラウザでの使用

スマートフォンやタブレットからも使用可能です！

### 制限事項
- ファイル編集は可能だがやや操作しづらい
- コピー＆ペーストに注意が必要
- デスクトップブラウザ推奨

### モバイルでの手順

1. **GitHub mobileアプリまたはブラウザでアクセス**
2. **パッチファイル作成**
   - `patches/` フォルダに移動
   - 右上のメニュー（3点）→「Create new file」
   - パッチ内容を貼り付け
   - コミット

3. **ワークフロー実行**
   - 「Actions」タブ
   - ワークフローを選択
   - 「Run workflow」
   - パラメータ入力は縦にスクロール

4. **PR確認**
   - 対象リポジトリの「Pull requests」
   - 変更を確認してマージ

---

## 💡 便利なTips

### Tip 1: GitHub Webエディタを使う

パッチファイルをより快適に編集：

1. リポジトリページで `.` キー（ドット）を押す
2. ブラウザでVS Codeライクなエディタが開く
3. ファイルを編集してコミット

### Tip 2: ブックマークを活用

よく使うページをブックマーク：
- `https://github.com/YOUR-USERNAME/CodexPatch/actions`
- `https://github.com/YOUR-USERNAME/CodexPatch/tree/main/patches`

### Tip 3: テンプレートを用意

よく使うワークフローパラメータをメモ帳に保存：

```
target_repository: myorg/myrepo
target_branch: main
patch_file: patches/myorg_myrepo/YYYY-MM-DD_description.patch
push_strategy: pull_request
commit_message: type: description
run_tests: skip
```

使用時にコピー＆ペーストして日付と説明を変更。

### Tip 4: GitHub Notificationsを活用

ワークフロー完了やPR作成の通知を受け取る：

1. 右上のベルアイコン→「Settings」
2. 「Notifications」
3. 「Actions」の通知を有効化

---

## 🐛 トラブルシューティング

### 問題1: ワークフローが見つからない

**症状**: Actionsタブにワークフローが表示されない

**解決策**:
1. リポジトリに `.github/workflows/apply-codex-patch.yml` が存在するか確認
2. ファイルが正しくコミットされているか確認
3. YAMLのシンタックスエラーがないか確認

### 問題2: パッチ適用に失敗

**症状**: ワークフローは成功するがパッチ適用ステップでエラー

**原因と解決策**:

**原因A: パッチが古い**
- 対象コードが変更されているため差分が合わない
- 解決: Codexに最新のコードでパッチを再生成してもらう

**原因B: ファイルパスが間違っている**
- パッチ内のファイルパスが対象リポジトリと一致しない
- 解決: Codexにファイルパスを確認して再生成

**原因C: ファイルが見つからない**
- `patch_file` パラメータが間違っている
- 解決: ファイルパスをコピー＆ペーストで正確に入力

### 問題3: 権限エラー

**症状**: "refusing to allow a GitHub App..." エラー

**解決策**:
- ワークフローファイル（`.github/workflows/*.yml`）を変更しようとしている
- 通常のファイルはこのエラーは出ない
- パッチファイル（`patches/*.patch`）は問題なく作成できる

### 問題4: PATが動作しない

**症状**: 外部リポジトリへのアクセスでエラー

**解決策**:
1. Secret名が `PATCH_APPLIER_TOKEN` で正しいか確認（大文字小文字重要）
2. PATに `repo` スコープがあるか確認
3. PATの有効期限が切れていないか確認
4. 対象リポジトリへのアクセス権があるか確認

---

## 📊 実行例：完全な流れ

### 例: ブログサイトのフッター更新

#### 状況
- ブログサイト（`myblog/website`）のフッターに新しいリンクを追加したい
- ローカル環境なし

#### 実行

**1. Codexに依頼（ChatGPT/Claude）**
```
以下のファイルを編集してください：
src/components/Footer.tsx

変更内容：
- "Privacy Policy" リンクを追加
- URLは /privacy
- 既存のリンクの隣に配置

git diff形式で出力してください。
```

**2. Codexの出力**
```diff
diff --git a/src/components/Footer.tsx b/src/components/Footer.tsx
index abc123..def456 100644
--- a/src/components/Footer.tsx
+++ b/src/components/Footer.tsx
@@ -10,6 +10,7 @@ export const Footer = () => {
       <nav>
         <Link href="/about">About</Link>
         <Link href="/contact">Contact</Link>
+        <Link href="/privacy">Privacy Policy</Link>
       </nav>
       <p>&copy; 2025 My Blog</p>
     </footer>
```

**3. GitHub UIでパッチ作成**
- `https://github.com/MY-USERNAME/CodexPatch` を開く
- `patches/` → 「Add file」→「Create new file」
- ファイル名: `myblog_website/2025-11-04_add-privacy-link.patch`
- Codexの出力を貼り付け
- 「Commit new file」

**4. ワークフロー実行**
- 「Actions」→「Codexパッチ適用」→「Run workflow」
- パラメータ:
  ```
  target_repository: myblog/website
  target_branch: main
  patch_file: patches/myblog_website/2025-11-04_add-privacy-link.patch
  push_strategy: pull_request
  commit_message: feat: add privacy policy link to footer
  pr_title: Add Privacy Policy link
  run_tests: run
  test_command: npm test
  ```
- 「Run workflow」

**5. 結果確認（約2-3分後）**
- ワークフロー成功 ✅
- `myblog/website` にPR作成 ✅
- テスト合格 ✅

**6. PRマージ**
- `https://github.com/myblog/website/pulls` を開く
- 新しいPRを確認
- 「Merge pull request」
- 完了！🎉

**所要時間: 約5分（待ち時間含む）**

---

## 🎓 まとめ

このガイドで学んだこと：

✅ ローカル環境不要でパッチを適用する方法
✅ GitHub UIだけでファイルを作成・編集する方法
✅ GitHub Actionsでワークフローを実行する方法
✅ 外部リポジトリにパッチを適用する設定
✅ 複数パッチを一括で適用する方法
✅ トラブルシューティング方法

**すべてブラウザだけで完結！**

---

## 🚀 次のステップ

1. 実際に試してみる
   - サンプルパッチで練習
   - 実際のプロジェクトで使用

2. チームで活用
   - チームメンバーに共有
   - レビュープロセスに組み込む

3. 自動化を進める
   - 定期的なパッチ適用
   - CI/CDパイプラインとの統合

---

<div align="center">

**📖 このガイドがお役に立てば幸いです！**

[メインREADMEに戻る](../README.md) | [チュートリアル](TUTORIAL.md) | [アーキテクチャ](ARCHITECTURE.md)

</div>
