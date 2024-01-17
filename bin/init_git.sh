#!/bin/bash

#### 初回gitレポジトリプッシュ時の処理をするスクリプト ####
source .envrc

echo "# ${PROJECT_NAME} " >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin "https://${GIT_USER}:${GIT_TOKEN}@github.com/${GIT_USER}/${GIT_REPOSITORY}.git"
git push -u origin main
