#!/bin/bash

# docker composeで構築した環境を初期状態に戻す
# 注意： 構築したデータベースは削除される

# .envrcを読み込み、プロジェクトディレクトリに移動
source .envrc && \
cd ."${PROJECT_NAME}"

# docker-composeの場合
if  type "docker-compose" &>/dev/null; then
    #  docker composeを使って現在の環境を停止
    docker-compose down
# docker composeプラグインの場合
elif docker compose version | grep -q Docker; then
    #  docker composeを使って現在の環境を停止
    docker compose down
else
    return;
fi

# dangling（未使用の）Dockerイメージがあるかをチェック
none_images=$(docker images -f "dangling=true" -q)
if [ -n "$none_images" ]; then
    # 4. danglingイメージを削除
    docker rmi $(docker images -f "dangling=true" -q)
fi

# データディレクトリ、初期化SQLファイル、.envファイルを削除
# rm -rf './db/data' && rm -f './db/init/init.sql' && rm -f ".env" && \
rm -rf './db/data' && rm -rf './db/log' && rm -f './db/init/init.sql' && rm -f ".env" && \
# プロジェクトディレクトリを元に戻す
cd ../ && \
mv "${PROJECT_NAME_DIR_PATH}" "${PROJECT_ROOT}/.devcontainer"
