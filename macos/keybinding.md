# macOS 한영 키보드 백틱(`) 입력 설정

한글 키보드에서 `₩` 대신 백틱(`` ` ``)이 입력되도록 설정합니다.

```bash
mkdir -p ~/Library/KeyBindings
cat > ~/Library/KeyBindings/DefaultkeyBinding.dict << 'EOF'
{
    "₩" = ("insertText:", "`");
}
EOF
```

> 설정 후 앱을 재시작해야 적용됩니다.
