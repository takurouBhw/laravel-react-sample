#!/bin/bash

#### Docker Composeの設定ファイルと環境変数を初期化するスクリプト ####

# .envrcファイルが存在しない場合は新規作成
if [ ! -f .envrc ]; then
  cp .envrc.example .envrc
fi

# docker-compose.ymlの.envファイルを生成するための環境変数を読み込む
. .envrc

# ディレクトリ名がデフォルトの場合はプロジェクトディレクトリに変更する
DEFAULT_NAME_DIR_PATH="${PROJECT_ROOT}/.devcontainer"
if [ -d "$DEFAULT_NAME_DIR_PATH" ]; then
  mv "$DEFAULT_NAME_DIR_PATH" "${PROJECT_NAME_DIR_PATH}"
fi

DOCKER_ENVFILE_PATH="${PROJECT_NAME_DIR_PATH}/.env"

# docker-composeの.envファイルが存在しない場合は作成
[ ! -f "$DOCKER_ENVFILE_PATH" ] && {
  echo "PROJECT_NAME=${PROJECT_NAME}"
  echo "VOLUME_PATH=${VOLUME_PATH}"
  echo "NODEJS_VERSION=${NODEJS_VERSION}"
  echo "LARAVEL_VERSION=${LARAVEL_VERSION}"
  echo "APP_NAME=${APP_NAME}"
  echo "DB_DATABASE=${DB_DATABASE}"
  echo "DB_USER=${DB_USER}"
  echo "USER=${USER}"
  echo "DB_PASSWORD=${DB_PASSWORD}"
  echo "PROXY_TEMPLATE_NAME=${PROXY_TEMPLATE_NAME}"
  echo "PROXY_PUBLIC_PORT=${PROXY_PUBLIC_PORT}"
  echo "PROXY_SSL_PORT=${PROXY_SSL_PORT}"
  echo "VITE_PORT=${VITE_PORT}"
  echo "REACT_PORT=${REACT_PORT}"
  echo "PHP_SERVE_PORT=${PHP_SERVE_PORT}"
  echo "PHP_MYADMIN_PUBLIC_PORT=${PHP_MYADMIN_PUBLIC_PORT}"
  echo "MEMORY_LIMIT=${MEMORY_LIMIT}"
  echo "UPLOAD_LIMIT=${UPLOAD_LIMIT}"
} > "$DOCKER_ENVFILE_PATH"


# 初期化時にdb/dataディレクトリは削除する
[ -d "${PROJECT_NAME_DIR_PATH}/db/data" ] && rm -rf "${PROJECT_NAME_DIR_PATH}/db/data"

# SQLファイル作成
echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}_test CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;GRANT ALL PRIVILEGES ON ${DB_DATABASE}_test.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';FLUSH PRIVILEGES;" > "${PROJECT_NAME_DIR_PATH}/db/init/init.sql"
