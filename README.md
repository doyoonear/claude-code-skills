# Skills and Agents

Claude Code와 다른 AI 에이전트에서 사용하는 커스텀 스킬과 에이전트 모음입니다.

## 구조

```
skills-and-agents/
├── skills/          # 커스텀 스킬 (SKILL.md 또는 .md 파일)
├── agents/          # 커스텀 에이전트 정의
├── install.sh       # symlink 동기화 스크립트
└── backup/          # 로컬 백업 (gitignore)
```

## 설치

```bash
git clone https://github.com/doyoonear/claude-code-skills.git ~/skills-and-agents
cd ~/skills-and-agents
./install.sh
```

`install.sh`는 `~/.claude/skills/`와 `~/.claude/agents/`에 symlink를 생성합니다.

## 스킬 추가/변경

1. `skills/` 폴더에 스킬 추가 (폴더 또는 `.md` 파일)
2. `./install.sh` 실행
3. Git commit & push

### 스킬 형식

**폴더 형식** (권장):
```
skills/my-skill/
├── SKILL.md        # 메인 스킬 파일
├── scripts/        # 스크립트 (선택)
└── references/     # 참고 문서 (선택)
```

**단일 파일 형식**:
```
skills/my-guide.md
```

### SKILL.md 예시

```yaml
---
name: my-skill
description: 스킬 설명 및 트리거 키워드
---

# My Skill

스킬 지시사항...
```

## 외부 스킬

`npx openskills install` 등으로 설치한 외부 스킬은 `~/.agents/skills/`에 저장되고 `~/.claude/skills/`로 symlink됩니다. `install.sh`는 이 외부 스킬들을 건드리지 않습니다.

## 다른 에이전트 지원

- **Claude Code**: `~/.claude/skills/`
- **Cursor**: `.cursor/skills/`
- **VS Code Copilot**: `.github/skills/`

다른 에이전트용 symlink가 필요하면 `install.sh`를 수정하세요.
