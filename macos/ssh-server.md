# macOS SSH 서버(Homebrew) 설정 가이드

## 1) Homebrew로 OpenSSH 설치

```bash
brew update
brew install openssh
```

설치 확인:

```bash
$(brew --prefix)/bin/sshd -V
```

---

## 2) 서버(sshd) 설정 파일/호스트키 확인

- 설정: `$(brew --prefix)/etc/ssh/sshd_config`
- 호스트 키: `$(brew --prefix)/etc/ssh/ssh_host_*`

### 2-2) `sshd_config` 작성

```bash
sudo vi "$(brew --prefix)/etc/ssh/sshd_config"
```

#### 포트 (임의로)

```sshconfig
Port 2222
```

#### 호스트키(실제 키 파일 경로로)

```sshconfig
HostKey /opt/homebrew/etc/ssh/ssh_host_ed25519_key
HostKey /opt/homebrew/etc/ssh/ssh_host_rsa_key
```

#### 인증 정책(예시)

```sshconfig
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
```

#### 접속 계정 제한(선택)

```sshconfig
# AllowUsers your_macos_username
```

설정 검증(정상이면 아무런 출력 없음):

```bash
$(brew --prefix)/sbin/sshd -t -f "$(brew --prefix)/etc/ssh/sshd_config"
```

---

## 3) SSH 서버 자동 실행 등록(launchctl)

> 포트 22는 특권 포트(1024 미만)라서 권한 이슈가 생길 수 있으므로, `2222` 같은 **비권한 포트** 권장

### 3-1) LaunchAgent plist 생성

#### 1) plist 작성

```bash
sudo vi /Library/LaunchDaemons/homebrew.sshd.plist
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>homebrew.sshd</string>

  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/opt/openssh/sbin/sshd</string>
    <string>-D</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>StandardOutPath</key>
  <string>/var/log/homebrew.sshd.out</string>
  <key>StandardErrorPath</key>
  <string>/var/log/homebrew.sshd.err</string>
</dict>
</plist>
```

### 3-3) 등록/시작(launchctl)

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/homebrew.sshd.plist
```

### 3-4) 상태 확인 / 로그 확인

#### 상태 확인

```bash
sudo launchctl print system/homebrew.sshd
```

### 3-5) 설정 변경 후 반영

```bash
sudo launchctl bootout system/homebrew.sshd
sudo launchctl bootstrap system /Library/LaunchDaemons/homebrew.sshd.plist
```

### 3-6) 중지/제거

```bash
sudo launchctl bootout system/homebrew.sshd
```

> 파일까지 지우려면: `rm -f /Library/LaunchDaemons/homebrew.sshd.plist`

---

## 4) 클라이언트 접속 설정 (SSH 키 등록)

### 4-1) 서버 준비 (macOS)

먼저 접속받을 macOS 계정(예: `oneq`)에서 키 저장소를 준비합니다.

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh

touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 4-2) 클라이언트 키 생성 & 등록

1. **키 생성** (이미 있다면 생략 가능)
   ```bash
   ssh-keygen -t ed25519 -C "device_name"
   ```
2. **공개키 내용 복사**
   - Windows: `type $env:USERPROFILE\.ssh\id_ed25519.pub`
   - macOS/Linux: `cat ~/.ssh/id_ed25519.pub`
3. **서버 등록**
   - 복사한 내용을 서버(macOS)의 `~/.ssh/authorized_keys` 파일에 한 줄 추가합니다.

> `ssh-copy-id` 명령어가 있는 환경(Linux 등)에서는 `ssh-copy-id -p 2222 user@host`로 한 번에 등록할 수도 있습니다.

