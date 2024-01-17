# 環境構築資料

- [環境構築資料](#環境構築資料)
  - [置くところ](#置くところ)
    - [構造](#構造)
  - [dockerでSSLをつかう(windowsの方法)](#dockerでsslをつかうwindowsの方法)
  - [Laravelのライブラリ導入とコマンド一覧](#laravelのライブラリ導入とコマンド一覧)
  - [Docker開発環境構築手順](#docker開発環境構築手順)
    - [Dockerファイル全体構成](#dockerファイル全体構成)
    - [必要条件とツールの導入](#必要条件とツールの導入)
    - [wsl上での構築手順(任意)](#wsl上での構築手順任意)
    - [Dockerインフラ構築](#dockerインフラ構築)
    - [複数コンテナを稼働させる場合](#複数コンテナを稼働させる場合)
    - [起動しなくなった場合](#起動しなくなった場合)
    - [コンテナ立ち上げ後に`.devcotainer/.env`を編集した場合](#コンテナ立ち上げ後にdevcotainerenvを編集した場合)
    - [コンテナ内での作業](#コンテナ内での作業)
    - [プロジェクトの作成とLaravel環境設定](#プロジェクトの作成とlaravel環境設定)
  - [Vite設定](#vite設定)
  - [テスト開発環境設定とDB設定](#テスト開発環境設定とdb設定)
  - [開発環境URLアクセス法](#開発環境urlアクセス法)
  - [自動化スクリプト](#自動化スクリプト)
  - [Dockerコマンド](#dockerコマンド)

# 置くところ
volumeをCドライブとかとやり取りするとめちゃくちゃ重いのでwslのlinuxの中の、homeとかに置くといいらしい。

# dockerでSSLをつかう(windowsの方法)
## 作る
一回作ったら使い回す。<br>
参考 https://shimota.app/windows環境にhttps-localhost-環境を作成する/<br>
- https://chocolatey.org/install でコマンドをコピー
- powershellを管理者で実行、貼り付け、 `choco list -l` で確認
- powershellを一旦閉じて再度開けて、 `choco install mkcert` やって `mkcert --install`
- localhost-key.pem と localhost.pem が実行したディレクトリに落ちてるので保存して使い回す。
## 使う
- .devcontainer のうちに、proxyのなかにsslフォルダを作って、上記2つを入れておく
※ pemのファイルは各環境で違うものが要るので、必要に応じて手動でやる。
- このあとで .envrc をつくるので、そのとき、 `export PROXY_TEMPLATE_NAME="default.conf.templateForSSL"` とする。ForSSLの方のテンプレートを使うよう設定している。

# Docker開発環境構築手順

## Dockerファイル全体構成

- .devcontainer/
    - 開発環境で利用する`docker-compse`のリソースが格納。
- .devcontainer/db/
    - `docker-compse build`で利用するMySQLの設定が格納。
- .devcontainer/php/
    - `docker-compose build`で利用するphpの設定が格納。
- .devcontainer/proxy/
    - `docker-compose build`で利用するnginxの設定が格納。

## 必要条件とツールの導入

[Docker の公式サイト](https://www.docker.com/)から手順に従って導入し`docker-compose`コマンドを利用できるようにします。
[docker-composeの詳細](https://docs.docker.com/compose/compose-file/)はリファレンスを参考にしてください。
[docerk-composeコマンド](https://matsuand.github.io/docs.docker.jp.onthefly/engine/reference/commandline/compose/)はリファレンスを参考にしてください。
[Dockerプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)を導入してください。

## wsl上での構築手順(任意)

wsl上では [Dockerインフラ構築](#dockerインフラ構築)前に下記手順を実施(任意)。

この手順を踏まなくても[Dockerインフラ構築](#dockerインフラ構築)に移行しても構築は可能。
1. プロジェクト直下に存在する.envrc.expamleファイルを.envrcにリネーム
2. Node.jsのバージョンやプロジェクト名など適宜設定。特に各種PORT番号をプロジェクトごとに分けるなどしているときは必要に応じて記載。
2. `make container-init`を実行

上記手順を実行すると以下が変更または追加される。
- `.devcontainer`フォルダが.envrcに設定されている`.${PROJECT_NAME}`にリネームされる。
- `.${PROJECT_NAME}/db/init/init.sql`が生成。
このファイルは内容は`${PROJECT_NAME}_db`とテスト用DBが定義されたファイルを作成する。
sqlファイルは.docker-compose.ymlで利用される。
- `.${PROJECT_NAME}/.env`ファイルが作成される。ファイル内容は`.envrc`で定義したポートなど設定ファイルとして作成される。

## Dockerインフラ構築
1. `.devcontainer`ディレクトリ下で`.env`ファイルを作成し`env.example`の内容をコピーします。
2. 作成した`.env`ファイルを作成するアプリケーションに応じて編集します。<br>
    編集後に[自動化スクリプト](#自動化スクリプト)を参照し実行すると自動でコンテナが立ち上がる。<br>
    自動化スクリプトを利用した場合は以降の手順は不要。
    ```
    #### .devcontainer/.envファイル ###
    #プロジェクト名
    PROJECT_NAME=●●●プロジェクト名●●●

    # nodejsのバージョン https://github.com/nodesource/distributions/blob/master/README.md からOSごとの設定を確認
    # 書き方は NODEJS_VERSION=20.x など
    NODEJS_VERSION=●●●nodejsのバージョン●●●

    # laravelのバージョン 書き方は LARAVEL_VERSION=10.* など
    LARAVEL_VERSION=●●●laravelのバージョン●●●

    # アプリ名: この名前がdockerコンテナのプレフィックス名になる
    APP_NAME=●●●プロジェクト名●●●

    # linux環境のユーザー名
    USER=user

    # linux環境のユーザー(上記 USER で設定したもの)のパスワード
    PASSWORD=password

    # db名
    DB_DATABASE=●●●プロジェクト名●●●

    # dbユーザー名…laravelの.envはこれに合わせる
    DB_USER=db_user

    # dbパスワード…laravelの.envはこれに合わせる
    DB_PASSWORD=db_password

    # webサーバー: webブラウザからアクセスするポート番号。非ssl。
    PROXY_PUBLIC_PORT=8080

    # webサーバー: ssl接続するポート番号
    PROXY_SSL_PORT=8443

    # Viteのポート番号
    VITE_PORT=5173

    # PhpMyAdmin: webブラウザからアクセスするポート番号
    PHP_MYADMIN_PUBLIC_PORT=83306

    # sqlファイルのPhpMyAdminファイルのアップロードサイズ
    MEMORY_LIMIT=128M

    # sqlファイルPhpMyAdminアップロードサイズ
    UPLOAD_LIMIT=64M
    ```

    ● 補足
    proxy/default.conf.template のrootパスとlaravelプロジェクトを作成するコンテナのパスが一致することを確認してください。
    ```
    # proxy/default.conf.templateのルートパス定義
    root /var/www/html/public;
    # phpコンテナ内のlaravelプロジェクトのパス
    /var/www/html/public;
    ```

1. `/.devcontainer`ディレクトリに移動し`docker-compose up -d --build`を実行。

 **ビルドができない。コンテナが起動しない場合。**
 - `for proxy Cannot start service proxy: Mounts denied:`が出力された場合
    DockerアプリのPreferences > Resources > File sharing設定にプロジェクトディレクトリのパスを追加。
- Apply & Restartボタンで再起動。

- `Service 'node' failed to build: failed to register layer: Error processing tar file(exit status 1): write /usr/local/bin/node: no space left on device`
- 容量が足りないため、下記コマンドでキャッシュファイルを削除
`docker builder prune`

## 複数コンテナを稼働させる場合
1. ルートディレクトリ下の`.devcontainer`ディレクトリ名を任意の名前変更。
    上記のディレクトリ名がcomposeのコンテナ名になるので複数立ち上げる場合は重複させないようにディレクトリ名を変更する。
**コンテナを複数立ち上げる場合はブラウザからアクセスするポート番号を重複しないように変更する。**

## 起動しなくなった場合
- 起動しない
    1. `.devcontainer/`下で `docker-compose down --rmi all --volumes`を実行。
    2. `.devcontainer/db/data`ディレクトリ(存在する場合は)削除
    3. `docker rmi $(docker images -f "dangling=true" -q)`でnone(不明)dockerイメージ削除
    4. `.devcontainer/`下で`docker-compose build --no-cache`
    5. `.devcontainer/`下で`docker-compose up -d`を実行。
- Windowsでエラー docker-credential-desktop.exe": executable file not found in $PATH, out: の場合
    1. `~/.docker/config.json`ファイル内
    ```
    {
        "credsStore": "desktop.exe"
    }
    ```
    ```
    {
        "credStore": "desktop.exe"
    }
    ```

    上記`"credsStore"`のsを除外し`docker-compose build --no-cache`を実行

## コンテナ立ち上げ後に`.devcotainer/.env`を編集した場合

1. 画面左の[Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)パネルをクリック。
2. 対象のコンテナをクリックしCompose Downを実行。
3. `docker-compose up -d --build`を実行。

# コンテナ内での作業
[Dockerプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) 導入。

- エディタ画面左側にDocdkrのアイコンが表示されます。
アイコンをクリックし最上段にある`CONTAINERS`をクリックします。
コンテナリストが表示されサフィックスに`-php`が表示されている箇所をクリックします。
    - Attach Shellと表示されている箇所をクリックしたとき
    →VSCodeにコンテナのターミナル画面が表示されます。
    - Attach Visual Studio Code と表示されている箇所をクリックしたとき
    →VSCodeの新しいウィンドウがコンテナ内に開きます。
## 開発環境URLアクセス法

1. コンテナが起動していない場合はコマンド `cd .devcontainer`で移動し`docker-compose up -d`を実行。
2. コンテナ立ち上げ後に下記URLでアクセス。
- ドメイン
    - URL: [http://127.0.0.1](http://127.0.0.1/):PROXY_PUBLIC_PORT/
- PhpMyAdmin
    - URL: [http://127.0.0.1](http://127.0.0.1/):.PHP_MYADMIN_PUBLIC_PORT/
- URLアクセス時画面に`No application encryption key has been specified.`が出力された場合
    1. `php artisan key:generate`を実行。
    2. サーバーを再起動。
    3. 起動後に`cd プロジェクト名`を実行。
    4. `php artisan config:clear`を実行。

## Make 自動化スクリプト
以下コマンドを実行するとdockerのコンテナの自動で作成と削除を実行してくれる。
- makeが導入されていない場合は以下コマンドで導入する。
    ```
    sudo apt install make
    ```
- .envrcファイルの定義情報を元にdocker-composeの開発環境を構築する。
	```
    make container-init
    ```
- docker-composeの環境を一旦削除して初期状態に戻したい場合は以下を実行する。
    ```
    make container-remove
    ```

## Dockerコマンド

コンテナ削除などのコマンド

- docker-compseのダウン
    - `cd .devcontainer`でディレクトリに移動し`docker-compose down`
- docker-compseのコンテナ、イメージ、ボリューム、ネットワークの一括削除。
    - docker-compse.ymlが配置されているディレクトリで`docker-compose down --rmi all --volumes --remove-orphans`
- Dockerで作成したコンテナを全削除
    - `docker rm $(docker ps -a -q)`
- Dockerのnoneイメージのみ全削除
    - `docker rmi $(docker images -f "dangling=true" -q)`
- Dockerの容量が足りないなど、キャッシュファイルを削除
    -  `docker builder prune`

## Laravelのライブラリ導入とコマンド一覧
`laravel/README.md`にライブラリ導入手順や`artisan`コマンドの一覧が記述されています。