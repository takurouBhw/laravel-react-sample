- [メールサービス設定](#メールサービス設定)
  - [Stripeの設定](#stripeの設定)
  - [Mailtrapの設定](#mailtrapの設定)
# メールサービス設定
## Stripeの設定
1. [Strip](https://stripe.com/jp)にアクセスしアカウント作成、またはログインする。
2. [APIキー](https://dashboard.stripe.com/test/apikeys)にアクセスし公開キーとシークレットキーをコピーする。<br>
3. Laravel環境変数`.env`ファイルに上記の公開・シークレットキーを下記項目に追記する。
    ```
    STRIPE_PUBLIC_KEY="コピーした公開キー"
    STRIPE_SERCRET_KEY="コピーしたシークレットキー"
    ```
## Mailtrapの設定
1. [Mailtrap](https://mailtrap.io/)アクセスしユーザー情報を作成、またはログインする。
2. メニュー画面の Testing -> Inboxes -> Project内 MyInboxをクリックする。
3. My Inbox内のSMTP settingsを選択しIntegrations下部の選択ボックスのLaravel *+を選択。
下記6項目が表示されるので`.env`ファイル内項目を変更。
    ```
    MAIL_MAILER=smtp
    MAIL_HOST=
    MAIL_PORT=
    MAIL_USERNAME=
    MAIL_PASSWORD=
    MAIL_ENCRYPTION=
    ```
4. `php artisan config:clear`を実行しキャッシュをクリアする。
5. Dockerを再起動する。

