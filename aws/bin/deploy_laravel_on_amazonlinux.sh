#!/bin/sh

### amazon linux用のシェルスクリプト #######
### laravelのセットアップとgit clone配置 ###

# 設定.envrcファイルをプロジェクトディレクトリ直下に配置し読み込ませる
source "${PROJECT_ROOT}/.envrc"

# 更新
sudo yum update -y
sudo yum update -y amazon-linux-extras

# phpのインストール
sudo amazon-linux-extras install -y php8.0
sudo yum install -y php-mbstring php-dom php-zip

# comporserのインストール
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer

# nodejsのインストール
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
sudo yum install -y nodejs

# nginxのインストールとサービスの起動
sudo amazon-linux-extras install -y nginx1
# 設定ファイルのバックアップ
sudo cat /etc/nginx/nginx.conf > ~/nginx.conf.bk
sudo service nginx start

# ディレクトリの作成
sudo mkdir -p "$PROJECT_ROOT"
cd "$PROJECT_ROOT"
sudo chmod 777 .

# Git Hubからソースコードをクローン
sudo yum install -y git
git clone "https://${GIT_USER}:${GIT_TOKEN}@github.com/${GIT_USER}/${GIT_REPOSITORY}.git"
sudo chmod 0755 .
cd "$GIT_REPOSITORY"

# Laravelセットアップ
composer install
cat .env.example > .env
chmod 0755 .env
php artisan key:generate
​​chmod 0777 -R storage
chmod 0777 -R bootstrap
