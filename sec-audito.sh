#!/bin/zsh

echo "ESPHome security audit"
echo "======================"
echo

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

WARNINGS=0
TMPFILE="/tmp/esphome_secrets_check.txt"

typeset -a INCIDENTS

cleanup() {
  [[ -f "$TMPFILE" ]] && rm -f "$TMPFILE"
}

trap cleanup EXIT

check() {
  local level="$1"
  local message="$2"

  case "$level" in
    OK)
      echo "${GREEN}[OK]${NC} $message"
      ;;
    WARN)
      echo "${YELLOW}[WARN]${NC} $message"
      ((WARNINGS++))
      INCIDENTS+=("$message")
      ;;
    FAIL)
      echo "${RED}[FAIL]${NC} $message"
      ((WARNINGS++))
      INCIDENTS+=("$message")
      ;;
  esac
}

FILES=$(find . -type f \( -name "*.yaml" -o -name "*.yml" \) \
  ! -name "secrets.yaml")

echo "1. Searching for plaintext credentials..."
echo

grep -RniE \
  'password:|ssid:|username:|api_key:|token:' \
  . \
  --include="*.yaml" \
  --include="*.yml" \
  --exclude="secrets.yaml" \
  | grep -v '!secret' \
  | grep -v '\${.*}' \
  | grep -v 'substitutions:' \
  > "$TMPFILE"

if [[ -s "$TMPFILE" ]]; then
  check FAIL "Potential plaintext secrets found"
  cat "$TMPFILE"
else
  check OK "No obvious plaintext secrets found"
fi

echo
echo "2. Checking API encryption..."
echo

for file in $FILES; do
  if grep -q "^api:" "$file"; then
    if grep -A5 "^api:" "$file" | grep -q "encryption:"; then
      check OK "$file uses API encryption"
    else
      check FAIL "$file has API without encryption"
    fi
  fi
done

echo
echo "3. Checking OTA password..."
echo

for file in $FILES; do
  if grep -q "^ota:" "$file"; then
    if grep -A10 "^ota:" "$file" | grep -q "password:"; then
      check OK "$file OTA protected"
    else
      check FAIL "$file OTA without password"
    fi
  fi
done

echo
echo "4. Checking web_server exposure..."
echo

for file in $FILES; do
  if grep -q "^web_server:" "$file"; then
    if grep -A10 "^web_server:" "$file" | grep -q "auth:"; then
      check OK "$file web_server authenticated"
    else
      check WARN "$file web_server without auth"
    fi
  fi
done

echo
echo "5. Checking for hardcoded IPs..."
echo

IPS=$(grep -RniE \
  'static_ip:|gateway:|subnet:' \
  . \
  --include="*.yaml" \
  --include="*.yml" \
  --exclude="secrets.yaml" \
  | grep -v '\${.*}')

if [[ -n "$IPS" ]]; then
  check WARN "Hardcoded network configuration found"
  echo "$IPS"
else
  check OK "No hardcoded IP configuration found"
fi

echo
echo "6. Checking external_components pinning..."
echo

for file in $FILES; do
  if grep -q "^external_components:" "$file"; then
    if grep -A20 "^external_components:" "$file" | grep -q "ref:"; then
      check OK "$file external components pinned"
    else
      check WARN "$file external components not pinned"
    fi
  fi
done

echo
echo "7. Checking .gitignore..."
echo

if [[ -f .gitignore ]]; then
  grep -q "secrets.yaml" .gitignore \
    && check OK ".gitignore excludes secrets.yaml" \
    || check FAIL ".gitignore missing secrets.yaml"

  grep -q "\*.bin" .gitignore \
    && check OK ".gitignore excludes firmware binaries" \
    || check WARN ".gitignore missing *.bin"

else
  check FAIL ".gitignore missing"
fi

echo
echo "8. Checking ESPHome config validity..."
echo

for file in $FILES; do
  esphome config "$file" >/dev/null 2>&1

  if [[ $? -eq 0 ]]; then
    check OK "$file valid"
  else
    check FAIL "$file invalid"
  fi
done

echo
echo "======================"
echo "Audit summary"
echo "======================"
echo

if [[ $WARNINGS -eq 0 ]]; then
  echo "${GREEN}No issues detected${NC}"
else
  echo "${YELLOW}Total potential issues: $WARNINGS${NC}"
  echo
  echo "Detected issues:"
  echo

  for incident in "${INCIDENTS[@]}"; do
    echo " - $incident"
  done
fi