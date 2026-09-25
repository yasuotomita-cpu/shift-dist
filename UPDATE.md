# Chrome の Claude への指示書: shift を最新版に更新する（XREA）

**種別**: 正本
**これは何**: GitHub の最新版を XREA の本番（https://shift.the-agent.co）に反映する手順。SSH もファイルマネージャーも使わず、XREA の「CRONジョブ」だけで済む
**いつ読む**: 新しい機能・修正を本番に入れる時

---

## あなた（Chrome の Claude）へ

XREA のコントロールパネル（https://cp.xrea.com）で、CRONジョブを 1 つ登録して 1 回だけ動かし、結果を読んで、そのジョブを消します。

守ること:
- 既存のファイルや他のサイト（`the-agent.co` / `coast-life.biz`）には触らない。やるのは CRONジョブの登録と削除だけ
- 結果ファイルに `NG` があれば、その行をそのまま Tommy に報告して止まる（推測で直さない）

## 手順

1. 左メニュー「サイト設定」→ 下の方の **「CRONジョブ」** を開く
2. 新しいジョブを追加する。実行時刻は**今から 2〜3 分後の時刻を 1 回**（毎日・毎時にしない）。コマンド:
   ```
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/yasuotomita-cpu/shift-dist/main/xrea.sh)" -- install
   ```
3. 時刻を過ぎて 1〜2 分待ったら、ブラウザで開く: https://shift.the-agent.co/_status.txt
   （古い内容や 404 なら、もう 1〜2 分待って再読み込み）
4. 中身を Tommy に報告する。成功の目印:
   - `OK アプリを置いた`
   - いちばん下に `ALL OK`
5. **CRONジョブを削除する**（残すと毎回上書き更新が走る）
6. https://shift.the-agent.co/ を開いて、いつもどおり使えるか見る。スマホのホーム画面アプリは一度閉じて開き直すと新しい見た目になる

## うまくいかない時

| _status.txt の表示 | 意味 | どうする |
|---|---|---|
| ページが無い（404）のまま 10 分 | CRONジョブが動いていない | ジョブの時刻・有効化を見直す。XREA のマニュアル「CRON」の書き方と違っていたら、その書き方に合わせる |
| `NG PHP 8.2 以上の CLI が見つからない` | PHP の場所が分からない | XREA のマニュアル「CRON」に書かれた PHP のパスを Tommy に見せて相談 |
| `NG 配布 zip を取得できない` | 公開の置き場（shift-dist）から取れない | Tommy に報告（shift の Actions「Release zip」が緑か見てもらう） |
| `NG ... 置き場所が想定と違う` | 今のアプリが別の場所にある | 何も変わっていない。表示をそのまま Tommy に報告 |
| 診断に `NG` の行がある | 設定の不足 | その行をそのまま Tommy に報告 |

うまくいかなかった時も、前の版は `laravel-weight-old` として残っている（戻すのは Tommy と相談してから）。
