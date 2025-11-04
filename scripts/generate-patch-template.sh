#!/bin/bash
# Patch Template Generator
# パッチファイルのテンプレートとメタデータを生成

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

show_help() {
    cat <<EOF
Patch Template Generator

使用方法:
    $(basename "$0") [options]

オプション:
    -n, --name <name>           パッチ名（必須）
    -r, --repo <owner/repo>     対象リポジトリ（例: octocat/Hello-World）
    -b, --branch <branch>       対象ブランチ（デフォルト: main）
    -d, --description <desc>    パッチの説明
    -o, --output <path>         出力ディレクトリ（デフォルト: patches/）
    -h, --help                  このヘルプを表示

例:
    $(basename "$0") -n feature-header -r myorg/myrepo -d "Update header component"
EOF
}

generate_template() {
    local name="$1"
    local repo="${2:-}"
    local branch="${3:-main}"
    local description="${4:-}"
    local output_dir="${5:-$PROJECT_ROOT/patches}"
    
    # 日付を取得
    local date=$(date +%Y-%m-%d)
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # ファイル名を生成
    local safe_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
    local filename="${date}_${safe_name}.patch"
    
    # リポジトリ別のディレクトリを作成
    if [[ -n "$repo" ]]; then
        local repo_safe=$(echo "$repo" | tr '/' '_')
        output_dir="${output_dir}/${repo_safe}"
    fi
    
    mkdir -p "$output_dir"
    
    local patch_file="${output_dir}/${filename}"
    local meta_file="${output_dir}/${date}_${safe_name}.meta.json"
    
    # パッチテンプレートを作成
    cat > "$patch_file" <<'PATCH_EOF'
# このファイルにCodexで生成されたパッチ（diff形式）を貼り付けてください
#
# 例:
# diff --git a/src/components/Header.tsx b/src/components/Header.tsx
# index 1234567..abcdefg 100644
# --- a/src/components/Header.tsx
# +++ b/src/components/Header.tsx
# @@ -10,7 +10,7 @@ export const Header = () => {
#    return (
#      <header>
# -      <h1>Old Title</h1>
# +      <h1>New Title</h1>
#      </header>
#    )
#  }

PATCH_EOF
    
    # メタデータファイルを作成
    cat > "$meta_file" <<EOF
{
  "name": "$name",
  "description": "$description",
  "targetRepository": "$repo",
  "targetBranch": "$branch",
  "patchFile": "$filename",
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "pending",
  "metadata": {
    "author": "${USER:-unknown}",
    "generator": "generate-patch-template.sh"
  }
}
EOF
    
    log_success "テンプレートを作成しました:"
    echo "  パッチファイル: $patch_file"
    echo "  メタデータ: $meta_file"
    echo ""
    log_info "次のステップ:"
    echo "  1. $patch_file を開いてCodexで生成されたパッチを貼り付ける"
    echo "  2. パッチファイルを検証: tools/patch-cli.sh validate $patch_file"
    echo "  3. ローカルでテスト: tools/patch-cli.sh apply $patch_file --check"
    echo "  4. 変更をコミット: git add $patch_file $meta_file && git commit -m 'Add patch: $name'"
}

# メイン処理
main() {
    local name=""
    local repo=""
    local branch="main"
    local description=""
    local output_dir="$PROJECT_ROOT/patches"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -r|--repo)
                repo="$2"
                shift 2
                ;;
            -b|--branch)
                branch="$2"
                shift 2
                ;;
            -d|--description)
                description="$2"
                shift 2
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "エラー: 不明なオプション: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$name" ]]; then
        echo "エラー: パッチ名を指定してください（-n または --name）"
        show_help
        exit 1
    fi
    
    generate_template "$name" "$repo" "$branch" "$description" "$output_dir"
}

main "$@"
