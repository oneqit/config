#!/usr/bin/env zsh
#
# Ghostty 테마 미리보기 스크립트
# 방향키로 테마를 순회하며 실시간 적용합니다.
# 자동 순회 모드도 지원합니다.
#

GHOSTTY_CONFIG="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
SOURCE_CONFIG="$(cd "$(dirname "$0")" && pwd)/config"

if [[ ! -f "$GHOSTTY_CONFIG" ]]; then
  echo "ERROR: Ghostty config 파일을 찾을 수 없습니다: $GHOSTTY_CONFIG"
  exit 1
fi

ORIGINAL_THEME=$(awk -F' = ' '/^theme / {print $2}' "$GHOSTTY_CONFIG")

apply_theme() {
  local theme="$1"
  local tmp="${GHOSTTY_CONFIG}.tmp"
  awk -v t="$theme" '{if ($0 ~ /^theme /) print "theme = " t; else print}' "$GHOSTTY_CONFIG" > "$tmp" && mv "$tmp" "$GHOSTTY_CONFIG"
  osascript -e 'tell application "System Events" to tell process "Ghostty" to keystroke "," using {command down, shift down}' 2>/dev/null
}

# 테마 목록 로드
THEMES=("${(@f)$(ghostty +list-themes | sed 's/ (resources)$//' | grep -iv light)}")
TOTAL=${#THEMES[@]}

# 현재 테마의 인덱스 찾기 (zsh는 1-indexed)
INDEX=1
for i in {1..$TOTAL}; do
  if [[ "${THEMES[$i]}" == "$ORIGINAL_THEME" ]]; then
    INDEX=$i
    break
  fi
done

# 검색 필터
FILTER=""
FILTERED_INDICES=()

rebuild_filter() {
  FILTERED_INDICES=()
  if [[ -z "$FILTER" ]]; then
    for i in {1..$TOTAL}; do
      FILTERED_INDICES+=($i)
    done
  else
    local lower_filter="${FILTER:l}"
    for i in {1..$TOTAL}; do
      local lower_theme="${THEMES[$i]:l}"
      if [[ "$lower_theme" == *"$lower_filter"* ]]; then
        FILTERED_INDICES+=($i)
      fi
    done
  fi
}

rebuild_filter

# 필터된 목록에서 현재 위치 (인자로 시작 번호 지정 가능)
START_POS=${1:-0}
if [[ $START_POS -gt 0 ]]; then
  FPOS=$(( START_POS > ${#FILTERED_INDICES[@]} ? ${#FILTERED_INDICES[@]} : START_POS ))
else
  FPOS=1
  for i in {1..${#FILTERED_INDICES[@]}}; do
    if [[ "${FILTERED_INDICES[$i]}" -eq "$INDEX" ]]; then
      FPOS=$i
      break
    fi
  done
fi

AUTO=false
AUTO_SEC=3

show_status() {
  local real_idx="${FILTERED_INDICES[$FPOS]}"
  local theme="${THEMES[$real_idx]}"
  local filtered_total=${#FILTERED_INDICES[@]}
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Ghostty 테마 미리보기"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo " 테마: $theme"
  echo " ($FPOS/$filtered_total)"
  if [[ -n "$FILTER" ]]; then
    echo " 검색: $FILTER"
  fi
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if $AUTO; then
    echo " 자동 순회 중 (${AUTO_SEC}초 간격)"
    echo " 아무 키: 정지 | q: 종료"
  else
    echo " ←→: 이전/다음 | a: 자동 순회"
    echo " /: 검색 | Enter: 확정 | q: 취소"
  fi
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

navigate() {
  local dir=$1
  local filtered_total=${#FILTERED_INDICES[@]}
  if [[ $filtered_total -eq 0 ]]; then return; fi
  FPOS=$(( (FPOS - 1 + dir + filtered_total) % filtered_total + 1 ))
  apply_theme "${THEMES[${FILTERED_INDICES[$FPOS]}]}"
}

cleanup() {
  if [[ -n "$ORIGINAL_THEME" ]]; then
    apply_theme "$ORIGINAL_THEME"
    echo ""
    echo "원래 테마로 복원: $ORIGINAL_THEME"
  fi
}

trap cleanup EXIT

show_status

while true; do
  if $AUTO; then
    if read -rsk1 -t "$AUTO_SEC" key 2>/dev/null; then
      AUTO=false
      show_status
      continue
    else
      navigate 1
      show_status
      continue
    fi
  fi

  read -rsk1 key
  case "$key" in
    $'\e')  # 방향키 (escape sequence)
      read -rsk2 -t 0.1 rest
      case "$rest" in
        '[C'|'[B') navigate 1; show_status ;;   # → 또는 ↓
        '[D'|'[A') navigate -1; show_status ;;   # ← 또는 ↑
      esac
      ;;
    'a'|'A')
      AUTO=true
      show_status
      ;;
    '/')
      echo ""
      read -r "FILTER? 검색어: "
      rebuild_filter
      FPOS=1
      if [[ ${#FILTERED_INDICES[@]} -gt 0 ]]; then
        apply_theme "${THEMES[${FILTERED_INDICES[$FPOS]}]}"
      fi
      show_status
      ;;
    $'\n')  # Enter
      trap - EXIT
      local selected="${THEMES[${FILTERED_INDICES[$FPOS]}]}"
      if [[ -f "$SOURCE_CONFIG" ]]; then
        awk -v t="$selected" '{if ($0 ~ /^theme /) print "theme = " t; else print}' "$SOURCE_CONFIG" > "${SOURCE_CONFIG}.tmp" && mv "${SOURCE_CONFIG}.tmp" "$SOURCE_CONFIG"
      fi
      echo ""
      echo "테마 적용 완료: $selected"
      exit 0
      ;;
    'q'|'Q')
      echo ""
      exit 0
      ;;
  esac
done
