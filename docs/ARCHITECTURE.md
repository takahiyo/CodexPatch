# CodexPatch アーキテクチャドキュメント

## システム概要

CodexPatchは、AI生成のコードパッチを自動的に管理・適用するための統合システムです。ローカルCLIツールとGitHub Actionsの組み合わせにより、効率的なパッチ管理を実現します。

## アーキテクチャ図

```
┌─────────────────────────────────────────────────────────────┐
│                     CodexPatch System                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   AI Tools   │         │    Human     │                 │
│  │   (Codex)    │────────▶│  Developer   │                 │
│  └──────────────┘         └───────┬──────┘                 │
│                                    │                         │
│                                    ▼                         │
│                          ┌─────────────────┐                │
│                          │  Patch Files    │                │
│                          │  (.patch/.diff) │                │
│                          └────────┬────────┘                │
│                                   │                          │
│            ┌──────────────────────┼──────────────────────┐  │
│            ▼                      ▼                       ▼  │
│  ┌──────────────────┐   ┌──────────────┐   ┌──────────────┐│
│  │   Local CLI      │   │   GitHub     │   │   Patch      ││
│  │   Tools          │   │   Actions    │   │   Repository ││
│  │                  │   │              │   │              ││
│  │ • Validate       │   │ • Single     │   │ • Storage    ││
│  │ • Apply          │   │ • Batch      │   │ • Metadata   ││
│  │ • Create         │   │ • Test       │   │ • Versioning ││
│  │ • List/Info      │   │ • PR Create  │   │              ││
│  └──────────────────┘   └──────┬───────┘   └──────────────┘│
│                                 │                            │
│                                 ▼                            │
│                     ┌────────────────────┐                  │
│                     │  Target Repository │                  │
│                     │  (Code Changes)    │                  │
│                     └────────────────────┘                  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## コンポーネント

### 1. パッチファイル管理

**責任範囲:**
- パッチファイルの格納と整理
- メタデータの管理
- バージョン管理

**ディレクトリ構造:**
```
patches/
├── <repository_name>/
│   ├── YYYY-MM-DD_<patch_name>.patch
│   └── YYYY-MM-DD_<patch_name>.meta.json
└── examples/
    └── sample.patch
```

### 2. CLIツール (tools/patch-cli.sh)

**主要機能:**

#### validate
- パッチファイルの存在確認
- フォーマット検証
- 統計情報の表示

#### apply
- パッチのドライラン
- 実際の適用
- 3-wayマージサポート
- ロールバック機能

#### create
- 現在の変更からパッチを生成
- 自動メタデータ作成

#### list/info
- パッチファイルの一覧表示
- 詳細情報の表示

#### batch
- 複数パッチの一括処理
- JSON設定ファイルサポート

**技術スタック:**
- Bash script
- Git コマンド
- jq (JSON処理)

### 3. GitHub Actions ワークフロー

#### 単一パッチ適用 (apply-codex-patch.yml)

**フロー:**

```
1. パッチリポジトリのチェックアウト
   ↓
2. パッチファイルの検証
   ↓
3. ターゲットリポジトリのチェックアウト
   ↓
4. 作業ブランチの作成 (PR mode)
   ↓
5. パッチの統計表示
   ↓
6. パッチの適用
   ↓
7. テスト実行 (オプション)
   ↓
8. コミットの作成
   ↓
9. プッシュ
   ↓
10. PR作成 (PR mode)
```

**入力パラメータ:**
- target_repository
- target_branch
- patch_file
- push_strategy
- commit_message
- pr_title/pr_body
- run_tests/test_command

#### 複数パッチ一括適用 (apply-batch-patches.yml)

**フロー:**

```
1. パッチリストの解析
   ↓
2. 各パッチファイルの検証
   ↓
3. ターゲットリポジトリのチェックアウト
   ↓
4. 作業ブランチの作成
   ↓
5. パッチの順次適用
   ├─ 成功 → 次のパッチへ
   └─ 失敗 → fail_fast: true なら停止
   ↓
6. 適用結果のサマリー表示
   ↓
7. テスト実行 (オプション)
   ↓
8. 一括コミット
   ↓
9. プッシュ＆PR作成
```

**特徴:**
- 複数パッチの順次適用
- fail_fast オプション
- 詳細な統計情報
- 自動PR本文生成

### 4. パッチテンプレート生成 (scripts/generate-patch-template.sh)

**機能:**
- パッチファイルのテンプレート生成
- メタデータファイルの自動作成
- ディレクトリ構造の自動整理

**生成されるファイル:**
```json
// <patch_name>.meta.json
{
  "name": "patch_name",
  "description": "...",
  "targetRepository": "owner/repo",
  "targetBranch": "main",
  "patchFile": "patch_name.patch",
  "createdAt": "2025-11-04T00:00:00Z",
  "status": "pending",
  "metadata": {
    "author": "user",
    "generator": "generate-patch-template.sh"
  }
}
```

## データフロー

### ローカル開発フロー

```
Developer
    │
    ├─ AI Tool (Codex) で差分生成
    │       │
    │       ▼
    ├─ パッチファイルに保存
    │       │
    │       ▼
    ├─ patch-cli.sh validate で検証
    │       │
    │       ▼
    ├─ patch-cli.sh apply --check でドライラン
    │       │
    │       ▼
    ├─ 問題なければ実際に適用
    │       │
    │       ▼
    └─ テスト＆コミット
```

### GitHub Actions フロー

```
Developer
    │
    ├─ パッチファイルをコミット＆プッシュ
    │       │
    │       ▼
    ├─ GitHub Actions を手動起動
    │       │
    │       ▼
GitHub Actions
    │
    ├─ パッチリポジトリをクローン
    │       │
    │       ▼
    ├─ ターゲットリポジトリをクローン
    │       │
    │       ▼
    ├─ パッチを適用
    │       │
    │       ▼
    ├─ テストを実行
    │       │
    │       ▼
    ├─ コミット＆プッシュ
    │       │
    │       ▼
    └─ PR作成 (オプション)
            │
            ▼
Review & Merge
```

## セキュリティ考慮事項

### 認証とアクセス制御

1. **GitHub Token**
   - 同一リポジトリ: `GITHUB_TOKEN` (自動提供)
   - 外部リポジトリ: `PATCH_APPLIER_TOKEN` (手動設定)

2. **権限スコープ**
   - 最小権限: `repo` (読み取り・書き込み)
   - 必要に応じて追加スコープ

3. **トークン保存**
   - GitHub Secrets に保存
   - ログに出力しない
   - 有効期限の管理

### パッチ検証

1. **形式検証**
   - diff/patch フォーマットの確認
   - ファイルサイズの確認
   - エンコーディングの確認

2. **内容検証**
   - ドライラン実行
   - 影響範囲の確認
   - テストの実行

3. **レビュープロセス**
   - PR作成による可視化
   - コードレビューの実施
   - 承認後のマージ

## 拡張性

### 新しいコマンドの追加

CLIツールに新しいコマンドを追加する場合：

```bash
# tools/patch-cli.sh の main() 関数に追加
case "$command" in
    # ... existing commands ...
    your-new-command)
        your_new_function "$@"
        ;;
esac
```

### カスタムワークフローの作成

```yaml
# .github/workflows/custom-patch-workflow.yml
name: Custom Patch Workflow

on:
  workflow_dispatch:
    inputs:
      # カスタム入力パラメータ
      
jobs:
  custom-apply:
    runs-on: ubuntu-latest
    steps:
      # カスタムステップ
      - name: Custom Step
        run: |
          # カスタム処理
```

### プラグインシステム

将来的な拡張として、プラグインシステムの導入を検討：

```bash
# plugins/validate-custom.sh
plugin_validate_custom() {
    local patch_file="$1"
    # カスタム検証ロジック
}
```

## パフォーマンス最適化

### 大規模パッチの処理

1. **ストリーミング処理**
   - 大きなパッチファイルを分割
   - チャンク単位で処理

2. **並列処理**
   - 独立したパッチは並列適用
   - ワークフロー内でマトリックス戦略を使用

3. **キャッシング**
   - Git クローンのキャッシュ
   - 依存関係のキャッシュ

## モニタリングとログ

### ログレベル

- **INFO**: 通常の処理状況
- **WARN**: 警告（処理は続行）
- **ERROR**: エラー（処理中断）
- **SUCCESS**: 成功メッセージ

### GitHub Actions ログ

```yaml
- name: Log Example
  run: |
    echo "::notice::通知メッセージ"
    echo "::warning::警告メッセージ"
    echo "::error::エラーメッセージ"
```

### 統計情報の記録

- 適用されたパッチ数
- 失敗したパッチ数
- 処理時間
- 変更されたファイル数

## 今後の改善案

1. **Web UI の追加**
   - パッチ管理ダッシュボード
   - 視覚的なdiff表示

2. **通知システム**
   - Slack/Discord 連携
   - メール通知

3. **高度な競合解決**
   - インタラクティブなマージ
   - AI支援の競合解決

4. **テンプレートシステム**
   - カスタムテンプレート
   - プロジェクト固有の設定

5. **統計とレポート**
   - パッチ適用履歴
   - 成功率の追跡
   - パフォーマンスメトリクス
