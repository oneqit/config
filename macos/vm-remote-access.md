# macOS + Linux VM VPN 격리 환경 가이드

## 개요

VPN을 Mac이 아니라 **Linux VM 안에서만** 연결해서, VPN이 라우팅을 바꿔도 Mac 네트워크와 Mac으로 들어오는 SSH는 영향을 받지 않게 하는 구성.
SSH로 Mac에 붙을 수 있는 기기라면 어디서든(폰 Termux, 태블릿, 노트북) VPN이 필요한 작업을 VM 터미널에서 할 수 있다.

```
폰 / 태블릿 / 노트북
   │ ssh mac  (Mac sshd, 키 인증)
   ▼
Mac ── ssh vm ── UTM 공유 네트워크 (192.168.64.0/24) ──▶ Ubuntu VM (GUI 없이 사용)
 │                                                        ├─ VPN (tmux 세션에서 상시 유지)
 │                                                        └─ tmux + claude / codex
 └─ 브라우저 (VPN 전용 프로필) ── ssh -D ─────────────────────┘
```

- VPN 없이 하는 작업 → Mac에서 그대로
- VPN이 필요한 작업 → Mac에서 `ssh vm` 후 VM에서
- VPN 너머 웹 페이지 → Mac의 VPN 전용 브라우저 창 (VM을 SOCKS 프록시로 경유)

> Mac의 SSH 서버 설정은 [ssh-server.md](ssh-server.md) 참고

### 진행 상태

- [x] 1) VM 준비
- [x] 2) Mac → VM 키 인증
- [x] 3) VM 비밀번호 로그인 끄기
- [x] 4) VM에서 VPN 연결
- [x] 5) VPN 연결 상태에서 Mac → VM SSH 유지 확인 (dev / prod 정책 모두 ✅)
- [ ] 6) Mac 재부팅 시 VM 자동 시작
- [ ] 7) VPN 너머 웹 접속 (SOCKS 프록시)
- [ ] 8) 이미지 붙여넣기 (Mac 클립보드 → VM)

---

## 1) VM 준비 (UTM)

### 1-1) VM 생성

| 항목 | 값 | 비고 |
|---|---|---|
| 백엔드 | QEMU | |
| 게스트 OS | Ubuntu 26.04 (ARM64) | Apple Silicon은 arm64 네이티브 |
| 메모리 / CPU / 디스크 | 8GB / 4코어 / 64GB | |
| 네트워크 | **Shared Network** | Mac에서 VM IP로 바로 접근 (포트포워딩 불필요) |
| 디스플레이 | 하드웨어 OpenGL 가속 **끔** | 켜면 블랙스크린 등 이슈 |

- 설치가 끝나면 UTM 툴바 디스크 아이콘에서 ISO를 **Eject**

### 1-2) SSH 서버 설치 (VM 안에서)

```bash
sudo apt update
sudo apt install -y openssh-server
```

> `apt update`에서 `Release file ... is not valid yet` 에러가 나면 VM 시계가 틀린 것 (VM을 오래 일시정지했다 재개한 경우 등). `sudo chronyc makestep`으로 시계를 맞춘 뒤 다시 실행.

### 1-3) 개발 환경 세팅 (VM 안에서)

이 레포의 Linux 세팅으로 zsh, tmux, starship, mise, docker, claude, codex 등을 한 번에 설치한다.

```bash
git clone https://github.com/oneqit/config.git ~/.config/oneqit/config
~/.config/oneqit/config/init.sh
```

기본 셸(zsh)과 docker 그룹은 재로그인 후 반영된다.

### 1-4) VM IP 확인

VM 안에서:

```bash
ip -4 addr show | grep 192.168.64
```

또는 Mac에서:

```bash
arp -an | grep bridge100
```

> 이 문서는 VM IP `192.168.64.2`, VM 계정 `ubuntu`로 가정한다.
> IP는 UTM DHCP가 정하므로 바뀔 수 있다. 바뀌면 2-2)의 `HostName`만 수정 (또는 `<VM 호스트명>.local` 사용)

---

## 2) Mac → VM 키 인증

### 2-1) Mac 키 생성 (없을 때만)

```bash
ssh-keygen -t ed25519 -N "" -C "oneq@$(scutil --get LocalHostName)" -f ~/.ssh/id_ed25519
```

### 2-2) VM에 공개키 등록 + 별칭 설정

```bash
# VM 비밀번호를 마지막으로 한 번 입력
ssh-copy-id -i ~/.ssh/id_ed25519.pub ubuntu@192.168.64.2
```

`~/.ssh/config`:

```sshconfig
Host vm
  HostName 192.168.64.2
  User ubuntu
```

### 2-3) 키 로그인 확인

```bash
ssh -o PasswordAuthentication=no vm 'echo OK'
```

비밀번호를 묻지 않고 `OK`가 나오면 성공.

---

## 3) VM 비밀번호 로그인 끄기

**2-3) 확인 후에** 진행 (순서가 바뀌면 VM에 접속할 방법이 없어질 수 있음)

Mac에서 `ssh vm`으로 접속한 뒤, VM 안에서 `/etc/ssh/sshd_config` 수정:

```bash
ssh vm
sudo vi /etc/ssh/sshd_config
```

```sshconfig
PasswordAuthentication no
```

```bash
# 덮어쓰는 drop-in이 있는지 (있으면 그 줄도 no로 바꾸거나 삭제)
grep -rn -i 'PasswordAuthentication' /etc/ssh/sshd_config.d/

# 최종 적용값 확인 (no가 나와야 함)
sudo sshd -T | grep '^passwordauthentication'

# 반영
sudo systemctl reload ssh
```

확인 (Mac에서):

```bash
ssh -o PubkeyAuthentication=no vm
```

`Permission denied (publickey)`만 나오면 키 전용.

---

## 4) VM에서 VPN 연결

원칙:

- VPN 클라이언트는 **GUI 없이 터미널에서** 실행하고, VM 안의 **tmux 세션**에 띄워 둔다. (SSH가 끊겨도 VPN은 유지)
- 브라우저 로그인(SSO)이 필요한 VPN이면, 클라이언트가 출력하는 로그인 URL을 **Mac 브라우저**로 열어 처리한다.
- 공식 클라이언트가 "로컬 네트워크 접근 차단" 정책을 강제하면 Mac → VM SSH가 끊길 수 있다. 라우팅만 바꾸는 openconnect 계열 클라이언트를 우선 고려한다.

### 4-1) tmux 안에서 VPN 연결

```bash
ssh vm
sudo apt install -y tmux curl
tmux new -s vpn
# VPN 클라이언트 연결 (클라이언트별 명령)
# 연결되면 tmux에서 빠져나오기 (detach) → SSH를 닫아도 VPN 유지
```

- 다시 보기: `ssh vm` 후 `tmux attach -t vpn`
- ⚠️ SSH 셸에서 tmux 없이 바로 실행하면 VPN 클라이언트가 SSH 세션의 자식 프로세스가 되어, **창을 닫거나 SSH가 끊기는 순간 VPN도 끊긴다.**

### 4-2) HTTPS 검사하는 VPN이면 루트 인증서 설치

VPN이 HTTPS 트래픽을 검사(TLS 재서명)하는 경우, VM이 그 루트 인증서를 모르면 **VPN 너머 HTTPS가 전부 실패**한다.

```
curl: (60) SSL certificate OpenSSL verify result: self-signed certificate in certificate chain (19)
```

> `curl -s`는 에러까지 숨겨서 **아무 출력 없이 끝난다.** 확인할 때는 `-sS` 사용

루트 인증서 이름 확인 (VM에서, 체인 맨 위 `i:`가 루트):

```bash
echo | openssl s_client -connect <VPN 너머 호스트>:443 -servername <VPN 너머 호스트> -showcerts 2>/dev/null \
  | grep -E '^ *[0-9] s:|^ *i:'
```

Mac 키체인에 같은 인증서가 있으면 꺼내서 VM에 설치:

```bash
# Mac에서
security find-certificate -c "<루트 인증서 이름>" -p /Library/Keychains/System.keychain > vpn-root-ca.crt
scp vpn-root-ca.crt vm:~/

# VM에서
sudo cp ~/vpn-root-ca.crt /usr/local/share/ca-certificates/vpn-root-ca.crt
sudo update-ca-certificates   # "1 added" 확인
```

> Node 기반 도구(claude, codex 등)가 인증서 에러를 내면 `export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/vpn-root-ca.crt`

---

## 5) VPN 연결 상태에서 Mac → VM SSH 유지 확인

VPN을 켠 상태에서 Mac에서:

```bash
ssh vm 'ip route get 192.168.64.1'   # VPN 터널(tun0 등)이 아니라 원래 인터페이스로 나가야 정상
```

- Mac(`192.168.64.1`)은 VM과 **직접 연결된 서브넷**이라, VPN이 기본 경로를 바꿔도 더 구체적인 경로가 우선해서 보통 유지된다.
- ⚠️ 과거에 VPN을 켜자 Mac → VM scp가 `No route to host`로 실패한 기록이 있다. 재현되면:
  - VPN 클라이언트의 로컬 네트워크 차단 정책 여부 확인 (4) 원칙 참고)
  - VPN이 VM 서브넷과 겹치는 경로를 내려주는지 확인 (`ip route`)
  - 최후 수단: VPN을 VM 안의 별도 네트워크 네임스페이스(또는 컨테이너)에 가둬, VM 기본 네트워크를 VPN과 분리

---

## 6) Mac 재부팅 시 VM 자동 시작

Mac 로그인 시 launchd(LaunchAgent)가 UTM VM을 시작하도록 한다.

```bash
/Applications/UTM.app/Contents/MacOS/utmctl list            # VM 이름/UUID 확인
/Applications/UTM.app/Contents/MacOS/utmctl start <VM 이름>
```

- `~/Library/LaunchAgents/`에 위 `utmctl start`를 `RunAtLoad`로 실행하는 plist 등록
- LaunchAgent는 **로그인 후** 실행되므로, Mac 자동 로그인이 켜져 있어야 재부팅 후 원격에서 바로 쓸 수 있다.
- VPN은 재부팅 후 수동으로 다시 연결 (4) 참고)

---

## 7) VPN 너머 웹 접속 (SOCKS 프록시)

VM을 SOCKS 프록시로 쓰고, Mac에서는 **VPN 전용 브라우저 프로필**로 접속한다.
프로필의 모든 트래픽이 VM(VPN)을 거치므로 도메인별 프록시 설정이 필요 없다.

`~/.ssh/config`의 `Host vm`에 추가:

```sshconfig
  DynamicForward 1080
```

`ssh vm`으로 접속해 있는 동안 `localhost:1080`에 SOCKS 프록시가 열린다.

```bash
# VPN 전용 Chrome 창 (평소 Chrome과 프로필 분리)
open -na "Google Chrome" --args \
  --user-data-dir="$HOME/.chrome-vpn" \
  --proxy-server="socks5://127.0.0.1:1080"
```

- Chrome의 SOCKS5는 DNS 조회도 프록시(VM) 쪽에서 하므로 VPN 내부 도메인도 열린다.
- 폰에서 VPN 너머 웹 접속은 범위 밖 (안드로이드는 SOCKS 프록시를 시스템 전체에 적용하지 않음)

---

## 8) 이미지 붙여넣기 (Mac 클립보드 → VM)

claude-code의 Ctrl+V 이미지 붙여넣기는 **claude가 실행 중인 기기의 클립보드**를 읽는다. GUI 없는 VM에는 클립보드가 없고, SSH로는 텍스트만 넘어간다.
대신 claude-code는 프롬프트에 붙여넣은 **이미지 파일 경로**를 이미지로 인식하므로, 이미지를 VM에 올리고 경로를 붙여넣는다.

```bash
brew install pngpaste
```

```bash
# Mac: 클립보드 이미지 → VM 업로드 → VM 경로를 클립보드에
f="clip-$(date +%Y%m%d-%H%M%S).png"
pngpaste "/tmp/$f" && ssh vm 'mkdir -p /tmp/clip' && scp -q "/tmp/$f" vm:/tmp/clip/ \
  && printf '/tmp/clip/%s' "$f" | pbcopy
```

1. 스크린샷을 클립보드로 복사 (Cmd+Ctrl+Shift+4)
2. 위 스크립트 실행 (Karabiner 단축키에 연결)
3. claude에서 Cmd+V → 경로 붙여넣기

---

## 나중에: 외부 기기에서 VM으로 한 번에 접속 (ProxyJump)

지금은 기기 → `ssh mac` → `ssh vm` 두 번 접속한다. 한 번에 접속하고 싶어지면:

1. 기기의 공개키를 **VM에도** 등록 (ProxyJump에서 Mac은 연결만 중계하고, VM은 **접속한 기기의 키**로 인증)

   ```bash
   # Mac에서 (VM 비밀번호 로그인이 꺼져 있으므로 ssh-copy-id 대신)
   cat ~/.ssh/authorized_keys | ssh vm 'cat >> ~/.ssh/authorized_keys'
   ```

2. 기기의 `~/.ssh/config`:

   ```sshconfig
   Host mac
     HostName <Mac 주소>
     Port <Mac sshd 포트>
     User oneq

   Host vm
     HostName 192.168.64.2
     User ubuntu
     ProxyJump mac
   ```

- `ssh mac` → Mac / `ssh vm` → Mac 경유 VM
