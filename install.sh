#!/bin/bash

# Skills and Agents Sync Script
# 커스텀 스킬과 에이전트를 ~/.claude/로 symlink 합니다.
# 외부 설치 스킬(.agents/skills/)은 보존됩니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
AGENTS_SRC="$SCRIPT_DIR/agents"
CLAUDE_SKILLS="$HOME/.claude/skills"
CLAUDE_AGENTS="$HOME/.claude/agents"

echo "🔄 Syncing skills and agents..."

# 폴더 생성
mkdir -p "$CLAUDE_SKILLS" "$CLAUDE_AGENTS"

# 기존 커스텀 스킬 symlink 정리 (skills-and-agents를 가리키는 것만)
echo "📦 Cleaning old symlinks..."
for link in "$CLAUDE_SKILLS"/*; do
  if [ -L "$link" ]; then
    target=$(readlink "$link")
    if [[ "$target" == *"skills-and-agents"* ]]; then
      rm "$link"
    fi
  fi
done

for link in "$CLAUDE_AGENTS"/*; do
  if [ -L "$link" ]; then
    target=$(readlink "$link")
    if [[ "$target" == *"skills-and-agents"* ]]; then
      rm "$link"
    fi
  fi
done

# 커스텀 스킬들 symlink
echo "🔗 Linking skills..."
for skill in "$SKILLS_SRC"/*; do
  name=$(basename "$skill")
  target="$CLAUDE_SKILLS/$name"

  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "  ⏭️  Skipped (exists): $name"
  else
    ln -s "$skill" "$target"
    echo "  ✅ Linked: $name"
  fi
done

# 에이전트 symlink
echo "🔗 Linking agents..."
for agent in "$AGENTS_SRC"/*; do
  name=$(basename "$agent")
  target="$CLAUDE_AGENTS/$name"

  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "  ⏭️  Skipped (exists): $name"
  else
    ln -s "$agent" "$target"
    echo "  ✅ Linked: $name"
  fi
done

echo ""
echo "✨ Done!"
echo "   Skills: $(ls -1 "$CLAUDE_SKILLS" | wc -l | tr -d ' ') items in $CLAUDE_SKILLS"
echo "   Agents: $(ls -1 "$CLAUDE_AGENTS" | wc -l | tr -d ' ') items in $CLAUDE_AGENTS"
