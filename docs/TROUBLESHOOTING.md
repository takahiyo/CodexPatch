# トラブルシューティングガイド

このドキュメントでは、CodexPatchを使用する際によくある問題と解決方法を説明します。

## 目次

1. [パッチ適用の失敗](#パッチ適用の失敗)
2. [ワークフローの失敗](#ワークフローの失敗)
3. [権限エラー](#権限エラー)
4. [パッチファイルの問題](#パッチファイルの問題)

---

## パッチ適用の失敗

### エラー: `error: patch failed: <file>:1` または `error: <file>: patch does not apply`

**症状:**
```
error: patch failed: README.md:1
error: README.md: patch does not apply
##[error]Process completed with exit code 1.
```

**原因:**

パッチが対象とするコードと、実際の現在のコードが一致していません。主な原因：

1. **パッチが古い**
   - パッチ作成後に対象ファイルが変更された
   - 別のブランチで作成したパッチを異なるブランチに適用しようとした

2. **パッチの行番号やコンテキストが合わない**
   - パッチ内の前後の行（コンテキスト）が現在のファイルと一致しない

3. **ファイルが存在しない**
   - パッチが対象とするファイルがリポジトリに存在しない

**解決方法:**

#### 方法1: 最新のコードでパッチを再生成

1. 対象リポジトリの最新コードを確認
2. Codex/Claude/ChatGPTに最新のコードを提供して再度パッチを生成依頼
3. 新しいパッチで再実行

**例:**
```
現在のtest.txtの内容:
---
hello world
---

このファイルを以下のように変更してください:
- "hello world" を "Hello, World!" に変更

git diff形式で出力してください。
```

#### 方法2: パッチの行番号を手動で調整

1. Actions の失敗ログでどの行で失敗したか確認
2. パッチファイル内の行番号とコンテキストを現在のファイルに合わせて調整
3. パッチファイルをコミットして再実行

#### 方法3: 3-way マージを試す（ローカル環境がある場合）

```bash
# GitHub Codespacesまたはローカル環境で
git apply --3way patches/my-patch.patch
```

### エラー: `trailing whitespace`

**症状:**
```
/home/runner/work/_temp/codex.patch:26: trailing whitespace.
This is a line with trailing spaces
warning: 1 line adds whitespace errors.
```

**原因:**

パッチファイルに行末の空白文字が含まれています。これは通常、コピー＆ペースト時に発生します。

**影響:**

通常は警告のみで、パッチは正常に適用されます。ただし、厳密な設定の場合はエラーになることがあります。

**解決方法:**

#### 自動修正（推奨）

ワークフローは既に `--whitespace=fix` オプションを使用しているため、自動的に修正されます。

#### 手動修正（完璧を期す場合）

1. パッチファイルをエディタで開く
2. 行末の空白を削除
3. コミットして再実行

---

## ワークフローの失敗

### エラー: `パッチファイルが見つかりません`

**症状:**
```
##[error]::パッチファイルが見つかりません: patches/my-patch.patch
```

**原因:**

1. パッチファイルのパスが間違っている
2. パッチファイルがコミットされていない
3. 異なるブランチを指定している

**解決方法:**

#### 1. パスを確認

ワークフロー実行時の `patch_file` パラメータを確認：

```
patch_file: patches/my-patch.patch
```

実際のファイルパス（リポジトリルートからの相対パス）:
```
patches/my-patch.patch  ← 正しい
/patches/my-patch.patch ← 間違い（先頭のスラッシュ不要）
my-patch.patch          ← 間違い（patchesディレクトリが省略されている）
```

#### 2. ファイルがコミットされているか確認

GitHub UIで確認:
1. リポジトリのファイルリストで `patches/` フォルダを開く
2. 目的のパッチファイルが表示されるか確認
3. 表示されない場合は、ファイルを作成してコミット

#### 3. ブランチを確認

ワークフローは `source_branch` パラメータで指定されたブランチからパッチを取得します。

- デフォルト: ワークフローを実行したブランチ
- 異なるブランチのパッチを使いたい場合は `source_branch` パラメータを指定

### エラー: `指定されたソースブランチが存在しません`

**症状:**
```
指定されたソースブランチ feature-branch が origin に存在しません。
```

**原因:**

`source_branch` パラメータで指定されたブランチがリモートに存在しません。

**解決方法:**

1. ブランチ名のスペルを確認
2. ブランチがプッシュされているか確認:
   ```bash
   git push origin your-branch-name
   ```
3. または `source_branch` を空欄にしてデフォルト（mainブランチ）を使用

---

## 権限エラー

### エラー: `refusing to allow a GitHub App to create or update workflow`

**症状:**
```
! [remote rejected] main -> main (refusing to allow a GitHub App to create or update workflow `.github/workflows/apply-batch-patches.yml` without `workflows` permission)
error: failed to push some refs to 'https://github.com/...'
```

**原因:**

GitHub Appトークンに `workflows` 権限がないため、ワークフローファイル（`.github/workflows/*.yml`）を直接変更できません。

**影響:**

- パッチファイル（`patches/*.patch`）の作成・変更は問題なし
- ワークフローファイル自体の変更のみ制限される

**解決方法:**

#### ワークフローファイルを変更する必要がある場合:

**方法1: GitHub UIで手動作成（推奨）**

1. GitHubリポジトリで `.github/workflows/` に移動
2. 「Add file」→「Create new file」
3. ファイル名: `your-workflow.yml`
4. 内容を貼り付けてコミット

**方法2: パッチファイルとして提供**

ワークフロー変更をパッチとして提供し、ユーザーに手動適用を依頼:
```bash
# ローカルまたはCodespacesで
git apply patches/workflow-enhancements.patch
git add .github/workflows/
git commit -m "Add new workflow"
git push origin main
```

### エラー: 外部リポジトリへのアクセス権限なし

**症状:**
```
Error: Resource not accessible by integration
```

**原因:**

Personal Access Token (PAT) が設定されていないか、権限が不足しています。

**解決方法:**

1. **PATを作成**
   - GitHub Settings → Developer settings → Personal access tokens
   - `repo` スコープを選択
   - トークンを生成してコピー

2. **Secretに設定**
   - CodexPatchリポジトリの Settings → Secrets and variables → Actions
   - New repository secret
   - Name: `PATCH_APPLIER_TOKEN`
   - Value: コピーしたトークン

3. **ワークフロー再実行**

詳細は [CLOUD_ONLY_GUIDE.md](CLOUD_ONLY_GUIDE.md#外部リポジトリへの適用設定) を参照。

---

## パッチファイルの問題

### 問題: パッチが大きすぎる

**症状:**

パッチファイルが数千行に及び、レビューが困難。

**原因:**

Codexが大量の変更を一度に出力した。

**解決方法:**

#### 方法1: 変更を分割

Codexに小さな単位で変更を依頼:

```
変更を3つに分割してください:
1. ファイルAの変更のみ
2. ファイルBの変更のみ
3. ファイルCの変更のみ

各変更をgit diff形式で個別に出力してください。
```

#### 方法2: バッチ適用を使用

複数の小さなパッチに分割し、バッチ適用ワークフローで一括適用。

### 問題: パッチにバイナリファイルが含まれている

**症状:**
```
error: cannot apply binary patch to <file> without full index
```

**原因:**

画像やその他のバイナリファイルの変更がパッチに含まれています。

**解決方法:**

#### パッチでバイナリファイルを扱わない

バイナリファイルは別途アップロード:
1. GitHub UIで直接ファイルをアップロード
2. テキストファイルのみパッチで適用

#### または git format-patch を使用（ローカル環境）

```bash
git format-patch -1 HEAD --binary
```

### 問題: パッチ内のファイルパスが間違っている

**症状:**
```
error: <path>: No such file or directory
```

**原因:**

パッチ内のファイルパスが対象リポジトリの構造と一致していません。

**解決方法:**

1. 対象リポジトリの構造を確認
2. Codexに正しいパスを提供して再生成:

```
リポジトリ構造:
src/
  components/
    Header.tsx
  utils/
    helpers.ts

src/components/Header.tsx を変更してください。
ファイルパスは src/components/Header.tsx です。
git diff形式で出力してください。
```

---

## デバッグ方法

### GitHub Actions ログの確認

1. リポジトリの「Actions」タブを開く
2. 失敗したワークフロー実行をクリック
3. 失敗したジョブをクリック
4. 各ステップを展開して詳細ログを確認

**重要なステップ:**
- 「パッチファイルを取得」- ファイルが正しく取得されたか
- 「パッチのサマリーを表示」- 統計情報
- 「パッチを適用」- エラーメッセージ

### ローカルでのテスト（GitHub Codespaces）

1. リポジトリで「Code」→「Codespaces」→「Create codespace」
2. ターミナルで:

```bash
# パッチを検証
./tools/patch-cli.sh validate patches/my-patch.patch

# ドライラン
./tools/patch-cli.sh apply patches/my-patch.patch --check

# 詳細情報
./tools/patch-cli.sh info patches/my-patch.patch
```

---

## よくある質問

### Q: パッチが何度やっても失敗する

**A:** 以下を確認:

1. 対象ファイルの現在の内容をCodexに共有
2. 最新のコードでパッチを再生成
3. 簡単な変更でテスト（例: 1行だけの変更）
4. それでも失敗する場合は、GitHub Codespacesでローカルテスト

### Q: ワークフローは成功するが変更が反映されない

**A:** 考えられる原因:

1. 正しいブランチを見ているか確認
2. ブラウザのキャッシュをクリア
3. コミット履歴を確認して実際にコミットされたか確認

### Q: 複数人で同時にパッチを適用すると競合する

**A:** 対策:

1. PR戦略を使用（`push_strategy: pull_request`）
2. パッチ適用前に最新のコードを確認
3. チーム内で適用順序を調整

---

## サポート

上記で解決しない場合:

1. **Issue を作成**
   - リポジトリの Issues タブ
   - エラーメッセージの全文を含める
   - パッチファイルの内容（センシティブな情報を除く）

2. **ログを共有**
   - GitHub Actions の詳細ログをエクスポート
   - 問題の再現手順を記載

3. **検索**
   - 同様の問題が既に報告されていないか確認
   - GitHub Issues で検索

---

<div align="center">

**このガイドがお役に立てば幸いです！**

[メインREADMEに戻る](../README.md) | [クラウド完全ガイド](CLOUD_ONLY_GUIDE.md) | [チュートリアル](TUTORIAL.md)

</div>
