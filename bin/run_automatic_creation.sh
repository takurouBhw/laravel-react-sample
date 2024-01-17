#!/bin/sh

# マイグレーション・コントローラ・モデル・ファクトリ・テストケース自動作成スクリプト
# $1　モデル名記載のファイルパス

while read line
do
    php artisan make:controller "${line}Controller" -rR
    php artisan make:factory "${line}Factory" --model="${line}"
    php artisan make:model "$line" -m
    # モデルテスト
    php artisan make:test --unit "Models/${line}Test"
    # コントローラテスト
    php artisan make:test "Http/Controllers/${line}ControllerTest"
done < "$1"
