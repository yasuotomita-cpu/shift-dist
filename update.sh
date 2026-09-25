#!/bin/sh
# XREA の CRONジョブに登録するファイル（「シェルスクリプト名」欄に laravel-weight/deploy/update.sh）。
# 公開リポジトリ shift-dist から最新の xrea.sh を取り、install を実行する。結果は https://shift.the-agent.co/_status.txt
# どこに置かれても XREA のホーム（/virtual/theagent）を見つける
D=$(cd "$(dirname "$0")" && pwd)
for B in "$D/../.." "$D" /virtual/theagent; do
  if [ -d "$B/public_html" ]; then BASE=$(cd "$B" && pwd); break; fi
done
[ -n "${BASE:-}" ] || { echo "NG ホームディレクトリが見つからない"; exit 1; }
DOC="$BASE/public_html/shift.the-agent.co"
URL=https://raw.githubusercontent.com/yasuotomita-cpu/shift-dist/main/xrea.sh
if command -v curl >/dev/null 2>&1; then curl -fsSL -o "$BASE/shift-xrea.sh" "$URL"; else wget -q -O "$BASE/shift-xrea.sh" "$URL"; fi \
  || { echo "NG xrea.sh を取得できない: $URL" > "$DOC/_status.txt"; exit 1; }
HOME="$BASE" sh "$BASE/shift-xrea.sh" install
