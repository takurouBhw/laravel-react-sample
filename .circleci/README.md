# Circle CIの設定

## 実施手順
1. [CircleCIのログイン画面](https://circleci.com/ja/vcs-authorize/)にアクセスします。
2. GitHubで登録、またはログインします。
3. ダッシュボード左側の`Projects`をクリックします。
4. リポジトリ一覧が表示されるのでCICDを利用するプロジェクトの`Set Up Project`ボタンをクリックします。
5. ラジオボタン`First`を選択し次に`PHP`を選択します。
- 黒いテキスト画面に表示されているのは、CircleCIの処理内容を定義するためのconfig.ymlというファイルの内容です。
この内容はブラウザから編集できるので全て削除して、`.circleci/config.yml`のファイル内容をコピーし貼り付けてください。
CircleCIの処理は、Dockerコンテナ上で処理されます。
使用するDockerイメージは、imageで指定します。
[CircleCIの公式](https://circleci.com/docs/ja/configuration-reference#docker)に用意しているPHPとnode.jsのDockerイメージを使用するよう指定しています。

画面に表示されたconfig.ymlを修正したら、Commit and Runボタンを押してください。
GitHubリポジトリに`circleci-project-setup`という名前のブランチが作られ、CircleCIの処理が開始されます。

5. CircleCIの実行結果を確認する
全セクションで実行したCircleCIの処理結果を確認します。
これからワークフロー、ジョブ、ステップの順で内容を確認していきます。
この関係性は以下の通りです。
    ```
    workflow
    ├── job1
    │   ├── step1
    │   ├── step2
    │   └── step3
    ├── job2
    │   ├── step1
    │   ├── step2
    │   └── step3
    └── job3
        ├── step1
        ├── step2
        └── step3
    ```

### 実行順序
- `Spin Up Environment`: Dockerコンテナ起動
- `Preparing Environment Variables`:　環境変数の準備
- `echo "Hello World"`: `config.yml`の`build`ジョブのステップ

最初のSpin Up Environmentは、Dockerコンテナの起動を行なっています。
Preparing Environment Variablesは、環境変数の準備を行なっています。
これら2つのステップは、config.ymlのbuildジョブには記述されていませんが、自動で実行されます。
最後のecho "Hello World"は、config.ymlのbuildジョブの最初に記述したステップです。
このecho "Hello World"をクリックすると、その処理結果を確認できます。


`circleci-project-setup`ブランチを作成しましたが
`name`: CircleCIの画面に表示されるステップ名となります。
`command`: 指定した内容がそのままステップ名となります。
[公式ドキュメント](https://circleci.com/docs/ja/configuration-reference#run)
```
- restore_cache:
    key: composer-v1-{{ checksum "composer.lock" }}
```
restore_cacheでは、保存されたキャッシュを復元します。
keyには、復元するキャッシュの名前を指定します。
実行時に`Found a cache...`(キャッシュが見つかった)となり、キャッシュが復元されます。
keyに指定している`composer-v1-{{ checksum "composer.lock" }}`は「save_cacheのkey」で説明します

- save_cache
```
    - save_cache:
        key: composer-v1-{{ checksum "composer.lock" }}
        paths:
            - vendor
```
save_cacheでは、keyに指定した名前でキャッシュを保存します。
保存するディレクトリ名やファイル名はpathsに指定します。
ComposerによってPHP関連のパッケージがインストールされるディレクトリであるvendorを指定しています。
`{{ checksum "ファイル名" }}`とすることで、ファイルをハッシュ化した値を算出しています。
Ll2iLt7gIJrDlzkiVJ5VLPoRVCfsXdodzAHiljMy+VM=
composer.lockでは、Composerによってインストールされた各パッケージのバージョンが、依存パッケージも含め管理されています。
composer.lockファイルのハッシュ値を、キャッシュのkeyに含めています。
composer.lockに変更があれば、算出されるハッシュ値も異なったものとなり、キャッシュのkeyとして違った名前になります。
結果としてrestore_cacheでは、保存済みのキャッシュ(vendorディレクトリ)が復元されることはありません。
次のステップのcomposer instalでvendorディレクトリが作成されるとともにPHP関連のパッケージがインストールされます。

結論として
composer.lockに変更が無い限りは、restore_chacheでは「前回以前のCircleCI実行時のsave_cacheで保存されたキャッシュ」を復元する。
composer.lockに何か変更があれば、restore_chacheではキャッシュを復元せず、save_cacheで新しいkeyにてキャッシュを保存し直す。
といった動きになります。

### CircleCIで利用するPHPコマンド
- キーを標準出力
`php artisan key:generate --show`
