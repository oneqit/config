---
name: oneq-create-commit-message-on-staged
description: Commit 메시지 생성
---

# Commit 메시지 생성

다음과 같이 staged된 변경사항을 분석하고 커밋 메시지를 작성해줘.
1. staged 변경 요약 확인
```
git diff --staged --stat
```

2. 전체 diff 분석
```
git diff --staged
```

3. 기존 커밋 메시지 스타일 참조
```
git log -n 10 --no-merges --format="%s%n%n%b----------"
```

## 규칙
- 직접 커밋 하지말고 커밋 메시지만 출력
- 코드블록이나 기타 마크다운 서식 없이 순수 텍스트만 출력
- 터미널 색상 코드(ANSI escape sequence) 없이 출력
- 기존 커밋 메시지 형식을 참고하여, prefix 스타일을 유지
- prefix 스타일이 명확하지 않다면 Conventional Commits 형식 사용
- .env, 시크릿, 임시/디버그 코드 등이 staged에 포함된 경우 첫 줄 맨 앞에 `⚠️⚠️⚠️` 를 붙이고 위험 내용을 명시해줘
- 수정사항이 간단한 경우, 본문 내용 생략 가능

## 형식
- 첫 줄: 수정 내용 전반을 간단 명료하게 한줄 요약
- 빈 줄
- 본문: 주요 변경사항부터 중요도 순으로 `-` 목록으로 작성 (가능한 경우 파일 이름을 본문에 포함)
- 빈 줄
- 주석: 자잘한 참고사항은 `# `으로 시작하는 주석으로 하단에 작성 (git commit 시 무시됨)
- 마지막 라인에 다음 구분자를 주석으로 추가
# ========================================================================

## 예시
### 일반 커밋
```
Fix login API crash when password is empty

- Handle empty password input in auth/login_service.py
- Add request validation in api/routes/login.py
- Return proper 400 response instead of server error
- Add unit test for empty password case in tests/test_login.py

# Prevents 500 error when client sends empty password
# ========================================================================
```

### Conventional Commit
```
feat: add image preview support to chafa.nvim

- Implement image rendering using chafa in lua/chafa/renderer.lua
- Add :ChafaPreview command for viewing images in buffer

# Enables terminal image preview inside Neovim
# ========================================================================
```
