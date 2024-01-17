-   [PHP と Laravel 環境設定](#phpとlaravel環境設定)
    -   [Xdebug 設定](#xdebug設定)
    -   [各ライブラリの導入手順](#各ライブラリの導入手順)
        -   [Laravel Sanctum](#laravel-sanctum)
        -   [Laraval Breeze](#laraval-breeze)
        -   [AdminLTE3](#adminlte3)
        -   [Jetstream](#jetstream)
        -   [Jetstream の設定](#jetstreamの設定)
    -   [artisan コマンド等](#artisanコマンド等)
    -   [その他注意事項](#その他注意事項)

# PHP と Laravel 環境設定

## プロジェクトの作成と Laravel 環境設定

1. “$APP_NAME 名”(.devcontainer/.env ファイルに記載)-php コンテナに入る。
1. 新規プロジェクトの場合は/var/www/html ディレクトリで以下コマンドを実行
   `install.sh`
   または
   `bash install.sh`
   どちらか動く方で。

-   警告: バージョンが不一致警告が出力された場合
    -   `php --version`でバージョンを確認し`composer config platform.php バージョン番号`でバージョンを合わせる。
    -   `composer install`を実行する。
    -   `php artisan key:generate`を実行する。

1. 作成したプロジェクトに移動し`.env`ファイル内を`.devcontainer/.env`に基づいて下記値に変更する。

    ```
    APP_NAME=`.devcontainer/.env`に記載されているアプリ名
    ...
    DB_CONNECTION=mysql
    DB_HOST=db
    DB_PORT=3306
    DB_DATABASE=`.devcontainer/.env`に記載されている接続先データベース
    DB_USERNAME=`.devcotainer/.env`に記載されているDBユーザー
    DB_PASSWORD=`.devcotainer/.env`に記載されているパスワード

    ```

2. `http://127.0.0.1:{.devcontainer/.env記載のPHP_MYADMIN_PUBLIC_PORT}`で PhpMyAdmin にアクセスできるか確認します。
3. Git からクローンした場合(プロジェクト新規作成の場合は不要)
   プロジェクトディレクトリ内で`composer install`を実行。
4. 下記コマンドを実行しマイグレーション・データを作成
   `php artisan migrate --seed`

## Vite 設定

1. .devcontainer/.env ファイル下記変数に任意のポートを設定する

```
VITE_PORT= # php artisan serveで動かす場合にviteで構築されたファイルを読み込むために必要
PHP_SERVE_PORT=
```

2. docker-compose.yml ファイル内: php サービスの下記コメントアウトを外す。

```
# ports:
      # - ${PHP_SERVE_PORT}:8000
      # - ${VITE_PORT}:${VITE_PORT}
 args:
     # VITE_PORT: ${VITE_PORT}
```

3. .devcontainer/php/Dockerfile の以下 Vite/php artisan serve 部分のコメントアウトを外す

```
# 引数を受け取ってコンテナ内で環境変数を定義
# ARG VITE_PORT

# ENV VITE_PORT=${VITE_PORT}

# Vite開発環境用のポート
# EXPOSE ${VITE_PORT}
# php artisan serveポート
# EXPOSE 8000
```

4. `welcome.blade.php`に以下を追加

    ```
    <!DOCTYPE html>
    <html ...>
        <head>
            {{-- ... --}}
            # 下記を追加する
            @vite(['resources/css/app.css', 'resources/js/app.js'])
        </head>
    ```

5. vite.config.js または vite.config.ts をを以下を参考に編集する。

    ```
    ## vite.config.jsの設定
    import { defineConfig } from "vite";
    import laravel from "laravel-vite-plugin";

    export default defineConfig({
        plugins: [
            laravel({
                // パス設定
                input: ["resources/css/app.css", "resources/js/app.js"],
                refresh: true,
            }),
        ],
        server: {
            //　docker-composeの.envで定義した${VITE_PORT}を指定。
            port: ${VITE_PORT},
            host: true, // trueにすると host 0.0.0.0
            // ホットリロードHMRとlocalhost: マッピング
            hmr: {
                host: "localhost",
            },
            // ポーリングモードで動作 wsl2の場合これを有効しないとホットリロード反映しない
            watch: {
                usePolling: true,
            },
        },
    });
    ```

6. 下記 2 点のコマンドを実行状態する。
   この両者コマンドを実行状態にしないと vite・laravel の開発環境が正常に動作しない。

```
npm run dev -- --host
php artisan serve --host 0.0.0.0
```

**Vite 開発設定時の注意点**

welcome.blade.php を読み込時に vite.config.js で定義されている server: { port: 番号}で指定された URL にアクセスしようとする。
外部ポートとコンテナ内で vite を起動してアクセスするポートを一致させないとアクセスできない。

docker-compse.yml で下記定義されている場合の例に説明すると、

```
ports:
    15173:5173
```

welcome.blade.php 返却->localhost:5173 に存在するリソースにアクセスしようとする。
このポートは外部公開されてないので、読み込む事ができないためエラーになり画面が真っ白になる。

```

server: {
         //　docker-composeの.envで定義した${VITE_PORT}を指定。
        port:
@vite(['resources/css/app.css', 'resources/js/app.js'])
```

## テスト開発環境設定と DB 設定(phpunit.xml が`<env>`タグの場合)

1. .env.testing を作る
   設定済みの .env をコピーして .env.testing を作る。
   基本的にはそのままだが下記 3 箇所修正

    ```
    APP_ENV=testing // testingに変更
    APP_KEY= // 空にしておく
    DB_DATABASE=テスト用のDB名 // ←に変更

    その上で下記実行
    php artisan key:generate --env=testing
    ```

2. phpunit.xml ファイルの下記を変更。

    ```
    <env name="DB_DATABASE" value="テスト用のDB名"/>
    ```

3. テストコード下記を追加して検証。

    ```
    php artisan make:controller UserController --test
    ```

    ```
    app/Http/Controllers/UserController.php

    use App\Models\User;

    class UserController extends Controller
    {
        public function index()
        {
            $users = User::all();

            return view('users.index', compact('users'));
        }
    }
    ```

    ```
    resources/views/users/index.blade.php

    use App\Http\Controllers\UserController;
    @foreach($users as $user)
        {{ $user->name }}
    @endforeach
    ```

    ```
    routes/web.php

    Route::get('users', [UserController::class, 'index']);
    ```

    ```
    tests/Feature/Http/Controllers/UserControllerTest.php
    <?php

    namespace Tests\Feature\Http\Controllers;

    use App\Models\User;
    use Illuminate\Foundation\Testing\RefreshDatabase;
    use Illuminate\Foundation\Testing\WithFaker;
    use Tests\TestCase;

    class UserControllerTest extends TestCase
    {
        use RefreshDatabase;

        use RefreshDatabase;

        /**
        * @test
        */
        function ユーザー一覧画面が表示できる()
        {
            // Arrange（準備）
            $user = User::factory()->create(['name' => 'テスト']);

            // Act（実行）
            $response = $this->get('users');

            // Assert（検証）
            $response
                ->assertOk()
                ->assertSee('テスト');
        }
    }
    ```

## テスト開発環境設定と DB 設定(phpunit.xml が`<server>`タグの場合)

**_.env_testing を作成_**
`cp .env .env_testing`
.env_testing の下記を変更または追加

    APP_ENV=test
    # dbは追加
    DB_TESTING_CONNECTION=mysql_testing
    DB_TESTING_HOST=ahr_db_testing
    DB_TESTING_PORT=3306
    DB_TESTING_DATABASE=test_ahr_db
    DB_TESTING_USERNAME=user

**_database.php を編集_**
config/database.php

    // mysqlの配列をコピーして貼り付け下記部分を変更
    'mysql_testing' => [　　　　名前変更
       'database' => 'test_db名',             変更点
    ],

\***\*phpunit ファイルの編集\*\***
phpunit.xml
phpunit を実行する際に使用するデータベースを設定。

        <php>
        <server name="APP_ENV" value="testing"/>
        <server name="BCRYPT_ROUNDS" value="4"/>
        <server name="CACHE_DRIVER" value="array"/>
        <server name="MAIL_MAILER" value="array"/>
        <server name="QUEUE_CONNECTION" value="sync"/>
        <server name="SESSION_DRIVER" value="array"/>
        <server name="TELESCOPE_ENABLED" value="false"/>
        <server name="DB_CONNECTION" value="mysql_testing"/>      変更点
        <server name="DB_DATABASE" value="test_db名"/>       変更点
        <server name="DB_HOST" value="127.0.0.1"/>
        </php>

**_テスト用データベースを正しく使用できるか確認_**
`php artisan migrate --env=testing`

    aravelにはデフォルトでuserのfactoryが用意されていて、seederも実行できる状態。

    テスト用dbにseederを実行して値が反映されているか確認。

\***\*テストファイルの編集\*\***

データベースと繋がっているのか確認。

```php
<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

use App\User;
use App\Item;

class ExampleTest extends TestCase
{
	use RefreshDatabase;

	public function setUp(): void
	{
		dd(env('APP_ENV'), env('DB_DATABASE'), env('DB_CONNECTION'));
	}
}
```

下記のコマンドを実行します。

```php
キャッシュ消してから
php artisan config:clear

vendor/bin/phpunit

ファイル指定で実行したい場合は下記のコマンドで出来ます。

vendor/bin/phpunit tests/Feature/ExampleTest.php
```

## Xdebug 設定

1. Laravel プロジェクトディレクトリを VSCode で開く。
2. `web.php`のルートに以下を追加する。
    ```
      Route::get('/phpinfo', function(){
          phpinfo();
    });
    ```
3. 以下コマンドを実行し `GET|HEAD  | phpinfo`が追加されているか確認。

    ```
    php artisan route:clear
    php artisan route:list | grep phpinfo
    ```

4. 上記のルートで設定した[URL](`http://127.0.0.1/phpinfo`)にアクセスする。
   `xdebug.client_port`を検索。ポート番号をコピーする。
5. 画面右側のデバッグアイコンをクリック、実行とデバッグ`.vscode/launch.json`を作成する。
6. `.vscode/launch.json`の設定を下記項目に変更する。

```
  "configurations": [
        {
          "name": "Listen for Xdebug",
          "type": "php",
          "request": "launch",
          "port": コピーしたポート番号,
          "pathMappings": {
              "nginxで設定されているドメインルート": "${workspaceRoot}"
          }
      },
```

**注意点**
`.vscode/launch.json`
上記ファイルの配置場所は EnvLaravel 直下に配置する。

## 各ライブラリの導入手順

下記を参考に実施する。

### Laravel Sanctum

1. 以下のコマンドを実行する。

```
  composer require laravel/sanctum
  php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
  php artisan migrate:fresh
```

2. `Kernel.php`ファイルの以下の記載部分を変更する。

```
'api' => [
    \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    \Illuminate\Session\Middleware\StartSession::class,
    // 'throttle:api',
    // \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

3. `config/sanctum.php`ファイルの以下を自身の環境に合わせ変更する。

```
  'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
      '%s%s',
      'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
      env('APP_URL') ? ','.parse_url(env('APP_URL'), PHP_URL_HOST) : ''
  ))),
```

4. 任意のコントローラーを作成して以下の内容を追加する。

```
namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

// ↓コントローラー・メソッドなどは任意の名前
class AuthController extends Controller
{

  /**
  * @param  Request  $request
  * @return \Illuminate\Http\JsonResponse
  */
  public function login(Request $request)
  {
      $credentials = $request->validate([
          'email' => ['required', 'email'],
          'password' => ['required'],
      ]);

      if (Auth::attempt($credentials)) {
          $request->session()->regenerate();

          return response()->json(Auth::user());
      }
      return response()->json([], 401);
  }

  /**
  * @param  Request  $request
  * @return \Illuminate\Http\JsonResponse
  */
  public function logout(Request $request)
  {
      Auth::logout();

      $request->session()->invalidate();

      $request->session()->regenerateToken();

      return response()->json(true);
  }


  public function register(Request $request)
  {
      $validatedData = $request->validate([
          'name' => 'required|string|max:255',
          'email' => 'required|string|email|max:255|unique:users',
          'password' => 'required|string|min:8',
      ]);

      $user = User::create([
          'name' => $validatedData['name'],
          'email' => $validatedData['email'],
          'password' => Hash::make($validatedData['password']),
      ]);

      $token = $user->createToken('auth_token')->plainTextToken;

      return response()->json([
          'access_token' => $token,
          'token_type' => 'Bearer',
      ]);
  }
}
```

5. api.php に以下を追記する

```
// routes/api.php
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout']);
// 下はテスト用
Route::get('/test', function(){
return response()->json([
    'test' => 'ok',
],200);
});

Route::middleware('auth:sanctum')->get('/user', function () {
return User::all();
});
```

6. `php artisan route:clear`を実行

以下参考 URL

-   [Sanctum](https://laravel.com/docs/9.x/sanctum)
-   [認証](https://laravel.com/docs/9.x/authentication)

-   **ログイン時にステータスコード 500 が送出される場合は以下の記事を参考にする**。
    [ログイン認証エラー ステータスコード(500)の対処](https://laracasts.com/discuss/channels/laravel/sanctum-throws-session-store-not-set-on-request)

### Laraval Breeze

-   [参考 1](https://reffect.co.jp/laravel/laravel8-breeze#Laravel_Breeze)

1. `composer require laravel/breeze --dev`
2. `php artisan breeze:install`
3. `npm install && npm run dev`

### AdminLTE3

-   [参考](https://chigusa-web.com/blog/laravel-crud/)

1. `composer require jeroennoten/laravel-adminlte`
2. `php artisan adminlte:install`

### Jetstream

```
composer require laravel/jetstream
composer require laravel/sanctum
php artisan jetstream:install livewire
npm install && npm run dev
# viewsリソースを作成
php artisan vendor:publish --tag=jetstream-views
```

`npm install`時のエラー対処

1. `webpack-cli] Error: Unknown option '--hide-modules'`が発生した場合
   `package.json`ファイル内で`--hide-modules`を検索し該当するオプションを削除する。

2. `` run `npm audit fix` to fix them, or `npm audit` for details ``が発生した場合
   `npm audit`を実行。セキュリティエラーメッセージの警告に従い解決する。

3. 一旦キャッシュをクリーンにして下記コマンドを実行する


    ```
      npm cache clean --force
      rm -rf ~/.npm
      rm -rf node_modules
      install && nmp run dev
    ```

### Jetstream の設定

-   プロフィール画像の表示方法

1. `config/jetstream.php`ファイルの`Features::profilePhotos()`変数のコメントアウトを外す。
2. ```
   # ストレージリンクを貼る
   php artisan storage:link
   ```
3. `.env`ファイルの項目を`APP_URL=http://localhost:{サーバーのポート}`に変更する。
4. `php artisan config:clear`でキャッシュをクリア。
5. `php artisan migrate:fresh`で DB に反映させる。

## artisan コマンド等

-   Middleware の作成

    ```
      php artisan make:middleware Cors
    ```

-   カスタムバリデーション

    ```
      php artisan make:rule {ルール名}
    ```

-   キャッシュをクリア
    ```
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    ```
-   ストレージリンク
    ```
    php artisan storage:link
    ```
-   リクエスト一覧
    ```
    php artisan route:list
    ```
-   シーダー作成
    [参照](https://readouble.com/laravel/8.x/ja/seeding.html)

    1. 下記コマンド実行
        ```
        php artisan make:seeder ProductSeeder
        ```
    2. `database/seeders/ProductSeeder.php`に追記

        ```
        use Illuminate\Support\Facades\DB;
        use Illuminate\Support\Facades\Hash;
        ...

        public function run() {
            DB::table('products')->insert([
              'name' => 'test',
              'price' => 1000,
              'password' => Hash::make('p@ssw0rd'),
              'created_ad => '2020/12/12 12:12:12',
            ]);
        }
        ```

    3. `database/seeders/DatabaseSeeder.php`に追記
        ```
          public function run()
          {
              // \App\Models\User::factory(10)->create();
              $this->call([
                  ProductSeeder::class
              ]);
          }
        ```
    4. `php artisan migrate:fresh --seed`を実行。

-   ダミーデータ作成
    -   [ダミーデータ一覧参照](https://qiita.com/tosite0345/items/1d47961947a6770053af)
        ```
        php artisan make:factory ProductFactory --model=Product
        ```
-   コントローラー作成
    [参照](https://readouble.com/laravel/8.x/ja/controllers.html)
    [同時作成参照(ver8.7.0 以降)](https://zenn.dev/nshiro/articles/204ce98cf088b9)

    ```
    php artisan make:controller ProductsController -r
    ```

-   ルーティング作成
    `web.php`に追記

    ```
    use App\Http\Controllers\ProductsController;
    ...

    // ルーティング一覧(showを使用しない場合の例)
    Route::resource('product', ProductsController::class, ['except' => ['show']]);
    ```

-   テーブル作成
    ```
    php artisan make:migration create_products_table
    php artisan migrate:fresh
    ```
-   モデル作成
    [同時作成の参照(ver 8.7.0 以降)](https://zenn.dev/nshiro/articles/204ce98cf088b9)
    (ver 8.7.0 以降)

    ```
    php artisan make:controller ProductController -R --model=Product

    Model created successfully.
    Request created successfully.
    Request created successfully.
    Controller created successfully.
    ```

    (ver 8.7.0 以前)

    ```
    php artisan make:model Product
    // フォームリクエスト等も同時に作成する場合
    php artisan make:model Product -rR

    Model created successfully.
    Request created successfully.
    Request created successfully.
    Controller created successfully.
    ```

-   フォームリクエスト作成

    ```
    php artisan make:request ProductStoreRequest
    ```

-   ダミーデータの作成方法
    1. `composer.json`内に"fakerphp/faker": "^1.9.1"が存在するか確認する。
    2. `config/app.php`内の`faker_locale => 'ja_JP'`に変更する。
    3. `php artisan config:clear`を実行。
    4. `php artisan make:factory モデルFactory --model=モデル名`で`モデルFactory.php`が生成される。
    5. 上記で生成されたファイルを[URL](https://qiita.com/tosite0345/items/1d47961947a6770053af)を参考に修正する。

## その他注意事項

**フォーム画面注意点**
画面を作成する際は`@csrf, @method('DELETE')`を追記する

```
<form method="POST" action="{{ route('owner.products.update', ['product' => $product->id]) }}">
  @csrf
  @method('PUT')
```
