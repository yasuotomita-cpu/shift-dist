# shift-dist

体重管理アプリ shift の**配布物だけ**を置く公開リポジトリ。ソース（非公開の shift）の GitHub Actions が自動で更新する。手で編集しない。

- `UPDATE.md` … Chrome の Claude に渡す本番更新の手順書
- `update.sh` … XREA の CRONジョブに登録するファイル（サーバーの laravel-weight/deploy/update.sh と同じ中身）
- `xrea.sh` … update.sh が取りに来る更新の本体
- Releases の `shift-deploy.zip` … 配布 zip（`.env`・鍵・パスワード・DB ダンプ・資料は含めない。build.sh が検査して止める）
