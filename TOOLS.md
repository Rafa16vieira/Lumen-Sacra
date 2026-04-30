# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Code Generation Agent

### GitHub Setup

**Personal Access Token (PAT):**
- Token stored in environment variable: `GITHUB_TOKEN`
- Required scopes: `repo` (full control of private repositories)
- Create at: https://github.com/settings/tokens

### Usage

```bash
export GITHUB_TOKEN='your_token_here'
./scripts/code-gen-agent.sh "<your command>"
```

**Command format:**
```
Build me a [topic] using [language/framework] with [features]. 
Repo: [https://github.com/owner/repo] (optional)
```

**Example:**
```
Build me a [todo app] using [React + TypeScript] with [Tailwind CSS, add/edit/delete tasks]. 
Repo: https://github.com/rafa/my-apps
```

### Notifications

- ✅ Success: PR link + summary
- ❌ Failure: Error logs + what went wrong
- Delivered via: Chat (this session)
