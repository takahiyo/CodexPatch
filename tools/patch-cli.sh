#!/bin/bash
# Codex Patch CLI Tool
# パッチファイルの検証、適用、管理を行うCLIツール

set -euo pipefail

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# ヘルプメッセージ
show_help() {
    cat <<EOF
Codex Patch CLI Tool v${VERSION}

使用方法:
    $(basename "$0") <command> [options]

コマンド:
    validate <patch_file>           パッチファイルを検証
    apply <patch_file> [options]    パッチをローカルリポジトリに適用
    list [directory]                パッチファイル一覧を表示
    info <patch_file>               パッチファイルの詳細情報を表示
    batch <config_file>             複数のパッチを一括適用
    create <output_file>            現在の変更からパッチを作成
    help                            このヘルプを表示
    version                         バージョン情報を表示

オプション:
    -d, --directory <path>          適用先ディレクトリ（デフォルト: カレントディレクトリ）
    -c, --check                     適用前にドライランを実行
    -3, --3way                      3-way マージを使用
    -r, --reverse                   パッチを逆適用
    -v, --verbose                   詳細出力
    -h, --help                      ヘルプを表示

例:
    # パッチを検証
    $(basename "$0") validate patches/feature-a.patch

    # パッチを適用（ドライラン）
    $(basename "$0") apply patches/feature-a.patch --check

    # パッチを実際に適用
    $(basename "$0") apply patches/feature-a.patch --directory /path/to/repo

    # パッチ一覧を表示
    $(basename "$0") list patches/

    # 現在の変更からパッチを作成
    $(basename "$0") create patches/my-changes.patch

    # 複数パッチを一括適用
    $(basename "$0") batch patches/batch-config.json
EOF
}

# バージョン表示
show_version() {
    echo "Codex Patch CLI Tool v${VERSION}"
}

# パッチファイルを検証
validate_patch() {
    local patch_file="$1"
    
    if [[ ! -f "$patch_file" ]]; then
        log_error "パッチファイルが見つかりません: $patch_file"
        return 1
    fi
    
    log_info "パッチファイルを検証中: $patch_file"
    
    # ファイルサイズをチェック
    local size=$(stat -f%z "$patch_file" 2>/dev/null || stat -c%s "$patch_file" 2>/dev/null || echo "0")
    if [[ $size -eq 0 ]]; then
        log_error "パッチファイルが空です"
        return 1
    fi
    
    # パッチフォーマットを検証
    if ! grep -q "^diff --git" "$patch_file" && ! grep -q "^---" "$patch_file"; then
        log_error "有効なパッチフォーマットではありません"
        return 1
    fi
    
    # 統計情報を表示
    local files_changed=$(grep -c "^diff --git" "$patch_file" || echo "0")
    local lines_added=$(grep -c "^+" "$patch_file" | grep -v "^+++" || echo "0")
    local lines_removed=$(grep -c "^-" "$patch_file" | grep -v "^---" || echo "0")
    
    log_success "パッチファイルは有効です"
    echo "  ファイル数: $files_changed"
    echo "  追加行数: $lines_added"
    echo "  削除行数: $lines_removed"
    echo "  ファイルサイズ: $size bytes"
    
    return 0
}

# パッチファイルの詳細情報を表示
show_info() {
    local patch_file="$1"
    
    if [[ ! -f "$patch_file" ]]; then
        log_error "パッチファイルが見つかりません: $patch_file"
        return 1
    fi
    
    log_info "パッチファイル情報: $patch_file"
    echo ""
    
    # 基本情報
    echo "=== 基本情報 ==="
    echo "ファイル名: $(basename "$patch_file")"
    echo "パス: $(realpath "$patch_file")"
    local size=$(stat -f%z "$patch_file" 2>/dev/null || stat -c%s "$patch_file" 2>/dev/null || echo "0")
    echo "サイズ: $size bytes"
    local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$patch_file" 2>/dev/null || stat -c "%y" "$patch_file" 2>/dev/null | cut -d'.' -f1)
    echo "最終更新: $modified"
    echo ""
    
    # 統計情報
    echo "=== 統計 ==="
    git apply --stat "$patch_file" 2>/dev/null || echo "統計情報を取得できませんでした"
    echo ""
    
    # 変更されるファイル一覧
    echo "=== 変更されるファイル ==="
    grep "^diff --git" "$patch_file" | sed 's/^diff --git a\/.* b\///' || echo "ファイル一覧を取得できませんでした"
}

# パッチを適用
apply_patch() {
    local patch_file="$1"
    local target_dir="${2:-.}"
    local check_only="${3:-false}"
    local use_3way="${4:-false}"
    local reverse="${5:-false}"
    local verbose="${6:-false}"
    
    if [[ ! -f "$patch_file" ]]; then
        log_error "パッチファイルが見つかりません: $patch_file"
        return 1
    fi
    
    if [[ ! -d "$target_dir" ]]; then
        log_error "対象ディレクトリが見つかりません: $target_dir"
        return 1
    fi
    
    cd "$target_dir"
    
    if [[ ! -d .git ]]; then
        log_error "Gitリポジトリではありません: $target_dir"
        return 1
    fi
    
    local apply_opts=()
    
    if [[ "$check_only" == "true" ]]; then
        apply_opts+=(--check)
        log_info "ドライラン実行中（実際の変更は行いません）"
    else
        log_info "パッチを適用中"
    fi
    
    if [[ "$use_3way" == "true" ]]; then
        apply_opts+=(--3way)
        log_info "3-way マージを使用"
    fi
    
    if [[ "$reverse" == "true" ]]; then
        apply_opts+=(--reverse)
        log_info "パッチを逆適用"
    fi
    
    if [[ "$verbose" == "true" ]]; then
        apply_opts+=(--verbose)
    fi
    
    # パッチ適用前の統計を表示
    log_info "適用するパッチの統計:"
    git apply --stat "$(realpath "$patch_file")"
    echo ""
    
    # パッチを適用
    if git apply "${apply_opts[@]}" --whitespace=fix "$(realpath "$patch_file")"; then
        if [[ "$check_only" == "true" ]]; then
            log_success "パッチは問題なく適用できます"
        else
            log_success "パッチを適用しました"
            log_info "変更されたファイル:"
            git status --short
        fi
        return 0
    else
        log_error "パッチの適用に失敗しました"
        return 1
    fi
}

# パッチファイル一覧を表示
list_patches() {
    local dir="${1:-$PROJECT_ROOT/patches}"
    
    if [[ ! -d "$dir" ]]; then
        log_error "ディレクトリが見つかりません: $dir"
        return 1
    fi
    
    log_info "パッチファイル一覧: $dir"
    echo ""
    
    local count=0
    while IFS= read -r -d '' patch_file; do
        ((count++))
        local size=$(stat -f%z "$patch_file" 2>/dev/null || stat -c%s "$patch_file" 2>/dev/null || echo "0")
        local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$patch_file" 2>/dev/null || stat -c "%y" "$patch_file" 2>/dev/null | cut -d'.' -f1)
        printf "%3d. %s\n     サイズ: %s bytes | 更新: %s\n" "$count" "$patch_file" "$size" "$modified"
    done < <(find "$dir" -type f \( -name "*.patch" -o -name "*.diff" \) -print0 | sort -z)
    
    if [[ $count -eq 0 ]]; then
        log_warn "パッチファイルが見つかりませんでした"
    else
        echo ""
        log_success "合計 $count 個のパッチファイルが見つかりました"
    fi
}

# 現在の変更からパッチを作成
create_patch() {
    local output_file="$1"
    local target_dir="${2:-.}"
    
    cd "$target_dir"
    
    if [[ ! -d .git ]]; then
        log_error "Gitリポジトリではありません: $target_dir"
        return 1
    fi
    
    # 変更があるかチェック
    if [[ -z "$(git status --short)" ]]; then
        log_error "変更がありません"
        return 1
    fi
    
    log_info "変更されたファイル:"
    git status --short
    echo ""
    
    log_info "パッチを作成中: $output_file"
    
    # 出力ディレクトリを作成
    mkdir -p "$(dirname "$output_file")"
    
    # パッチを作成
    if git diff HEAD > "$output_file"; then
        local size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")
        log_success "パッチファイルを作成しました: $output_file ($size bytes)"
        return 0
    else
        log_error "パッチの作成に失敗しました"
        return 1
    fi
}

# 複数パッチを一括適用
batch_apply() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "設定ファイルが見つかりません: $config_file"
        return 1
    fi
    
    log_info "バッチ設定ファイル: $config_file"
    
    # JSONファイルを解析
    if ! command -v jq &> /dev/null; then
        log_error "jqがインストールされていません。一括適用にはjqが必要です。"
        return 1
    fi
    
    local patches=$(jq -r '.patches[]' "$config_file")
    local count=0
    local success=0
    local failed=0
    
    while IFS= read -r patch_info; do
        ((count++))
        local patch_file=$(echo "$patch_info" | jq -r '.file')
        local target_dir=$(echo "$patch_info" | jq -r '.target // "."')
        
        echo ""
        log_info "[$count] パッチを適用: $patch_file → $target_dir"
        
        if apply_patch "$patch_file" "$target_dir" false false false false; then
            ((success++))
        else
            ((failed++))
        fi
    done < <(jq -c '.patches[]' "$config_file")
    
    echo ""
    log_info "=== バッチ適用結果 ==="
    echo "合計: $count"
    echo -e "${GREEN}成功: $success${NC}"
    echo -e "${RED}失敗: $failed${NC}"
    
    return $failed
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        validate)
            if [[ $# -eq 0 ]]; then
                log_error "パッチファイルを指定してください"
                exit 1
            fi
            validate_patch "$1"
            ;;
        apply)
            if [[ $# -eq 0 ]]; then
                log_error "パッチファイルを指定してください"
                exit 1
            fi
            
            local patch_file="$1"
            shift
            
            local target_dir="."
            local check_only=false
            local use_3way=false
            local reverse=false
            local verbose=false
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -d|--directory)
                        target_dir="$2"
                        shift 2
                        ;;
                    -c|--check)
                        check_only=true
                        shift
                        ;;
                    -3|--3way)
                        use_3way=true
                        shift
                        ;;
                    -r|--reverse)
                        reverse=true
                        shift
                        ;;
                    -v|--verbose)
                        verbose=true
                        shift
                        ;;
                    *)
                        log_error "不明なオプション: $1"
                        exit 1
                        ;;
                esac
            done
            
            apply_patch "$patch_file" "$target_dir" "$check_only" "$use_3way" "$reverse" "$verbose"
            ;;
        list)
            list_patches "${1:-$PROJECT_ROOT/patches}"
            ;;
        info)
            if [[ $# -eq 0 ]]; then
                log_error "パッチファイルを指定してください"
                exit 1
            fi
            show_info "$1"
            ;;
        create)
            if [[ $# -eq 0 ]]; then
                log_error "出力ファイル名を指定してください"
                exit 1
            fi
            create_patch "$1" "${2:-.}"
            ;;
        batch)
            if [[ $# -eq 0 ]]; then
                log_error "設定ファイルを指定してください"
                exit 1
            fi
            batch_apply "$1"
            ;;
        help|--help|-h)
            show_help
            ;;
        version|--version|-v)
            show_version
            ;;
        *)
            log_error "不明なコマンド: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
