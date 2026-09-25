#!/bin/sh
# XREA 用: CRONジョブから 1 回だけ叩く「配置・更新・初期化・診断」スクリプト（SSH もファイルマネージャーも不要）。
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/yasuotomita-cpu/shift-dist/main/xrea.sh)" -- install
# 公開リポジトリ shift-dist に置かれる（shift 本体は非公開。release.yml が自動で出す）
# 結果は https://shift.the-agent.co/_status.txt に書き出す（合言葉・キー・パスワードは書かない）。
# XREA の CRON は /bin/sh で実行・最長 3 分。POSIX sh だけで書く（bash 専用の書き方をしない）。
# 引数:  install … 最新の配布 zip を取得して置き換え → 初期化 → 診断（deploy/update.sh から呼ばれる）
#        weekly  … 週次サマリーを作る（deploy/weekly.sh から呼ばれる。ログは storage/logs/cron.log）
#        doctor  … 診断だけ
set -u
HOME="${HOME:-/virtual/theagent}"
START=$(date +%s)
DOMAIN=shift.the-agent.co
APP="$HOME/laravel-weight"
DOC="$HOME/public_html/$DOMAIN"
OUT="$DOC/_status.txt"
ZIP_URL="${ZIP_URL:-https://github.com/yasuotomita-cpu/shift-dist/releases/latest/download/shift-deploy.zip}"
MODE="${1:-install}"

mkdir -p "$DOC"
if [ "$MODE" = "weekly" ]; then OUT="$APP/storage/logs/cron.log"; exec >>"$OUT" 2>&1; else exec >"$OUT" 2>&1; fi
echo "== shift $MODE $(date '+%Y-%m-%d %H:%M:%S') HOME=$HOME"

# PHP 8.2 以上の CLI を探す（XREA は版ごとに別コマンド）
PHP=""
for c in php8.4 php84 php8.3 php83 php8.2 php82 /usr/bin/php84 /usr/bin/php83 /usr/bin/php82 /usr/local/bin/php84 /usr/local/bin/php83 /usr/local/bin/php82 /usr/local/php/8.3/bin/php /usr/local/php/8.4/bin/php php; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -r 'exit(PHP_VERSION_ID >= 80200 ? 0 : 1);' 2>/dev/null; then PHP=$(command -v "$c"); break; fi
done
if [ -z "$PHP" ]; then echo "NG PHP 8.2 以上の CLI が見つからない。XREA のマニュアル『CRON』に書かれた PHP のパスを Tommy に確認"; exit 1; fi
echo "OK PHP CLI: $PHP ($("$PHP" -r 'echo PHP_VERSION;'))"

if [ "$MODE" = "install" ] && [ -d "$APP" ] && [ ! -f "$APP/.env" ]; then
  echo "NG $APP はあるが .env が無い。置き場所が想定と違うので何も上書きせずに止めた。Tommy に確認"; exit 1
fi
if [ "$MODE" = "install" ] && [ ! -d "$APP" ] && [ -f "$DOC/index.php" ]; then
  echo "NG $DOC に index.php があるのに $APP が無い。置き場所が想定と違うので何も上書きせずに止めた。ls:"; ls -la "$HOME" | head -30; exit 1
fi
if [ "$MODE" = "install" ]; then
  TMP="$HOME/shift-tmp"; rm -rf "$TMP"; mkdir -p "$TMP"
  if ! curl -fsSL -o "$TMP/shift.zip" "$ZIP_URL"; then echo "NG 配布 zip を取得できない: $ZIP_URL"; exit 1; fi
  ( cd "$TMP" && unzip -q shift.zip ) || { echo "NG zip を展開できない（unzip が無い？）"; exit 1; }
  if [ -d "$APP" ]; then
    # 設定（.env）と保存データ（storage: 体写真・ログ・セッション）は引き継ぐ
    [ -f "$APP/.env" ] && cp "$APP/.env" "$TMP/laravel-weight/.env"
    rm -rf "$TMP/laravel-weight/storage" && cp -a "$APP/storage" "$TMP/laravel-weight/storage"
    rm -rf "$APP-old" && mv "$APP" "$APP-old"
  fi
  mv "$TMP/laravel-weight" "$APP"
  cp -a "$TMP/docroot/." "$DOC/"
  rm -rf "$TMP"
  echo "OK アプリを置いた（前の版は laravel-weight-old に退避）"
fi

cd "$APP" || { echo "NG $APP が無い。install を先に"; exit 1; }
if [ "$MODE" = "weekly" ]; then
  "$PHP" artisan weekly:summary
  echo "== 終わり（$(( $(date +%s) - START )) 秒）"; exit 0
fi
mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache storage/logs storage/app/private bootstrap/cache
chmod -R 775 storage bootstrap/cache
if [ ! -f .env ]; then cp .env.example .env; echo "OK .env を .env.example から作った（DB と合言葉と Gemini キーを入れる必要あり）"; fi
grep -q '^APP_KEY=base64:' .env || "$PHP" artisan key:generate --force
"$PHP" artisan config:clear >/dev/null; "$PHP" artisan route:clear >/dev/null; "$PHP" artisan view:clear >/dev/null
echo "OK 設定キャッシュを消した（.env を直接読む）"
if [ "$MODE" = "install" ]; then "$PHP" artisan migrate --force 2>&1 | tail -5; fi
echo "== 診断"
"$PHP" artisan shift:doctor
echo "== 終わり（所要 $(( $(date +%s) - START )) 秒。XREA の CRON は 3 分まで）。更新用の CRONジョブは無効にする"
