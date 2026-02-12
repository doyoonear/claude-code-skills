#!/bin/bash

# install-skill.sh
# skills CLI로 스킬 설치 후 external/skills/로 이동 + symlink 재생성
#
# Usage:
#   ./install-skill.sh <package> [skills CLI options]
#
# Examples:
#   ./install-skill.sh coreyhaines31/marketingskills
#   ./install-skill.sh coreyhaines31/marketingskills -s ab-test-setup
#   ./install-skill.sh coreyhaines31/marketingskills --all
#   ./install-skill.sh https://github.com/user/repo.git

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTERNAL_SKILLS="$SCRIPT_DIR/external/skills"
AGENTS_SKILLS="$HOME/.agents/skills"

if [ $# -eq 0 ]; then
  echo "Usage: ./install-skill.sh <package> [skills CLI options]"
  echo ""
  echo "Examples:"
  echo "  ./install-skill.sh coreyhaines31/marketingskills"
  echo "  ./install-skill.sh coreyhaines31/marketingskills -s ab-test-setup"
  echo "  ./install-skill.sh coreyhaines31/marketingskills --all"
  exit 1
fi

mkdir -p "$EXTERNAL_SKILLS" "$AGENTS_SKILLS"

# 1. 설치 전 ~/.agents/skills/ 스냅샷 (symlink 제외, 실제 디렉토리만)
before_install=()
for item in "$AGENTS_SKILLS"/*/; do
  [ -d "$item" ] && [ ! -L "${item%/}" ] && before_install+=("$(basename "${item%/}")")
done

# 2. skills CLI로 글로벌 설치 실행
echo "📦 Installing skills via CLI..."
npx skills add "$@" -g

# 3. 설치 후 새로 추가된 실제 디렉토리 감지
new_skills=()
for item in "$AGENTS_SKILLS"/*/; do
  [ -d "$item" ] || continue
  name="$(basename "${item%/}")"
  # symlink이면 스킵 (기존 install.sh로 연결된 것)
  [ -L "${item%/}" ] && continue
  # 이전에 없었던 새 디렉토리만
  found=false
  for prev in "${before_install[@]}"; do
    [ "$prev" = "$name" ] && found=true && break
  done
  $found || new_skills+=("$name")
done

if [ ${#new_skills[@]} -eq 0 ]; then
  echo ""
  echo "⚠️  새로 설치된 스킬이 감지되지 않았습니다."
  echo "   이미 설치된 스킬이거나 설치가 취소되었을 수 있습니다."
  exit 0
fi

# 4. 새 스킬을 external/skills/로 이동
echo ""
echo "📁 Moving skills to external/skills/..."
for name in "${new_skills[@]}"; do
  src="$AGENTS_SKILLS/$name"
  dest="$EXTERNAL_SKILLS/$name"

  if [ -d "$dest" ]; then
    echo "  ⚠️  $name already exists in external/skills/, overwriting..."
    rm -rf "$dest"
  fi

  mv "$src" "$dest"
  echo "  ✅ Moved: $name → external/skills/$name"
done

# 5. install.sh 실행하여 symlink 재생성
echo ""
echo "🔗 Running install.sh to create symlinks..."
bash "$SCRIPT_DIR/install.sh"

echo ""
echo "🎉 Complete! Installed skills:"
for name in "${new_skills[@]}"; do
  echo "  📌 $name"
  echo "     source: $EXTERNAL_SKILLS/$name"
  if [ -L "$AGENTS_SKILLS/$name" ]; then
    echo "     symlink: ~/.agents/skills/$name ✅"
  fi
  if [ -L "$HOME/.claude/skills/$name" ]; then
    echo "     symlink: ~/.claude/skills/$name ✅"
  fi
done
