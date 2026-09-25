# Chrome の Claude への指示書: shift を最新版に更新する（XREA）

**種別**: 正本
**これは何**: 最新版を XREA の本番（https://shift.the-agent.co）に入れる手順。XREA の「CRONジョブ」（シェルスクリプト名の欄だけ・/bin/sh で実行・最長 3 分）で `laravel-weight/deploy/update.sh` を 1 回動かす
**いつ読む**: 新しい機能・修正を本番に入れる時

---

## あなた（Chrome の Claude）へ

守ること:
- 触るのは `laravel-weight/deploy/update.sh` の置き換え（初回だけ）と CRONジョブの設定だけ。他のサイト（`the-agent.co` / `coast-life.biz`）や他のファイルには触らない
- 結果に `NG` があれば、その行をそのまま Tommy に報告して止まる（推測で直さない）
- 週次の CRONジョブ（`laravel-weight/deploy/weekly.sh`・毎週月 8:00）は**そのまま残す**

## 初回だけ: update.sh を最新の中身にする

今サーバーにある `laravel-weight/deploy/update.sh` は古い中身の可能性がある。次のファイルで置き換える。

1. https://raw.githubusercontent.com/yasuotomita-cpu/shift-dist/main/update.sh を開き、`update.sh` という名前で保存する
2. XREA のファイルマネージャー（または FTP）で `/virtual/theagent/laravel-weight/deploy/update.sh` に**上書き**でアップロードする
   - 上書きできない時は、代わりに `/virtual/theagent/shift-update.sh`（ホームの直下）に置き、以下の「シェルスクリプト名」を `shift-update.sh` にする。どちらに置いても動く
3. 置いたファイルの中に `shift-dist` という文字があることを確かめる

2 回目以降は、更新のたびに update.sh 自体も新しい版に入れ替わるので、この作業は要らない。

## 毎回: 更新する

1. XREA のコントロールパネル → CRONジョブ → 既存の `laravel-weight/deploy/update.sh` のジョブを編集する（無ければ新規）
   - シェルスクリプト名: `laravel-weight/deploy/update.sh`
   - 実行日時: **今から 2〜3 分後**の 1 回（月・日・時・分を今日の時刻に合わせる。毎日・毎時にしない）
   - 有効にして保存
2. 時刻を過ぎて 1〜2 分待ち、https://shift.the-agent.co/_status.txt を開く（古い時刻の内容なら、もう 1〜2 分待って再読み込み）
3. Tommy に報告する。成功の目印:
   - 1 行目の時刻が今日の今さっき
   - `OK アプリを置いた`
   - `ALL OK`
   - 最後の行の「所要 N 秒」（3 分＝180 秒を超えていないか）
4. このジョブを**無効にする**（または削除）。残すと次の日時にまた更新が走る
5. https://shift.the-agent.co/ を開いて、いつもどおり使えるか見る。スマホのホーム画面アプリは一度閉じて開き直すと新しい見た目になる

## うまくいかない時

| _status.txt の表示 | 意味 | どうする |
|---|---|---|
| 1 行目の時刻が古いまま 10 分 | CRONジョブが動いていない | ジョブの日時・有効・パスを見直す |
| `NG xrea.sh を取得できない` | サーバーから GitHub に届かない | そのまま Tommy に報告 |
| `NG PHP 8.2 以上の CLI が見つからない` | PHP の場所が分からない | XREA のマニュアル「CRON」で PHP のパスを調べて Tommy に報告 |
| `NG 配布 zip を取得できない` | 公開の置き場（shift-dist）から取れない | Tommy に報告（shift の Actions「Release zip」が緑か見てもらう） |
| `NG ... 置き場所が想定と違う` | 今のアプリが別の場所にある | 何も変わっていない。表示をそのまま Tommy に報告 |
| 診断に `NG` の行がある | 設定の不足 | その行をそのまま Tommy に報告 |

うまくいかなかった時も、前の版は `/virtual/theagent/laravel-weight-old` として残っている（戻すのは Tommy と相談してから）。
