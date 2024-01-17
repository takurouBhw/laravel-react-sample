#!/bin/bash

# .env ファイルのパスを設定
envfile_path="$(pwd)/.devcontainer/.env"

# もし .env ファイルが存在する場合は削除
if [ -f "$envfile_path" ]; then
    rm -f "$envfile_path"
fi

#  .devcontainerディレクトリ(初期状態の場合)に限り.envrcの準備処理を実行
if [ -d "$(pwd)/.devcontainer" ]; then
    # Docker Composeの環境設定を生成および実行
    . ./bin/gene_docker_compose_env.sh
fi

source .envrc
# install.shがボリューム先のディレクトリパスに存在するかチェック
if [ ! -e "${VOLUME_PATH}/install.sh" ]; then
    # install.shをボリューム先ディレクトリパスにコピーする
    cp "${PROJECT_NAME_DIR_PATH}/php/install.sh" "${VOLUME_PATH}/"
fi

cd ."${PROJECT_NAME}" || return

# dangling Dockerイメージの削除
none_images=$(docker images -f "dangling=true" -q)
if [ -n "$none_images" ]; then
    docker rmi $(docker images -f "dangling=true" -q)
fi

# docker と docker-compose コマンドの存在を確認する
# docker-composeで構築する場合
if  type "docker-compose" &>/dev/null; then
    docker-compose build --no-cache && \
    docker-compose up -d && \
    # 実行したファイルのディレクトリ位置に戻る
    cd ..
# docker composeプラグインで構築する場合
elif docker compose version | grep -q Docker; then
    docker compose build --no-cache  && \
    docker compose up -d && \
    # 実行したファイルのディレクトリ位置に戻る
    cd ..
else
    echo "dockerが存在しません"
fi

