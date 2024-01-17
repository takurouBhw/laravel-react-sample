#!/bin/bash

## httpsに必要な署名ファイルを生成する

# https通信に必要なコマンドチェック
if type mkcert > /dev/null 2>&1; then
		mkcert -cert-file ./localhost.pem -key-file ./localhost-key.pem localhost
else
		# 存在しない場合はインストール
		OS_NAME=$(uname)
		# mac osxはbrew経由でインストールする
		case $OS_NAME in
			Darwin ) 
			# brewコマンド存在チェック
			if type  brew > /dev/null 2>&1; then
				brew install mkcert nss;
				mkcert -install;
			# 存在しない場合はhomebrewインストール
			else 
				/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
				brew install mkcert nss;
				mkcert -install;
			fi
		esac
fi