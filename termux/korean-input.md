# Termux 한글 입력 설정

## 한글 입력 활성화

Termux에서 한글 입력이 제대로 되지 않을 때 다음 설정을 활성화합니다.

### 설정 방법

1. **설정 파일 편집**

```bash
vi ~/.termux/termux.properties
```

2. **다음 라인 주석 해제 (앞의 `#` 제거)**

```properties
enforce-char-based-input = true
```

3. **Termux 재시작**

설정을 적용하려면 Termux를 완전히 종료하고 다시 실행합니다.

---

## 참고

- 이 설정은 문자 기반 입력을 강제하여 한글, 중국어, 일본어 등 멀티바이트 문자의 입력을 개선합니다.
- 키보드 앱에 따라 추가 설정이 필요할 수 있습니다 (예: Gboard, Samsung 키보드 등).
