#!/usr/bin/env bash
# deploy_to_github.sh — 把本目录同步到 GitHub 私有仓库（幂等，可反复执行）
# 用法：
#   bash deploy_to_github.sh              # 用默认仓库名 Personal-Decision-OS
#   bash deploy_to_github.sh my-repo-name # 指定仓库名
#   PROXY=http://127.0.0.1:10808 bash deploy_to_github.sh   # 指定代理
# 依赖：git；可选 gh（已登录时自动建私有仓库、自动填远程地址）
set -euo pipefail

REPO_NAME="${1:-Personal-Decision-OS}"
BRANCH="main"
GH_USER_DEFAULT="xinjunye747-maker"
EMAIL_DEFAULT="xinjunye747@gmail.com"
PROXY="${PROXY:-}"

cd "$(dirname "$0")"

# 国内直连 GitHub 常被掐，能探测到本地代理就自动用上
if [ -z "$PROXY" ] && (exec 3<>/dev/tcp/127.0.0.1/10808) 2>/dev/null; then
  PROXY="http://127.0.0.1:10808"
  exec 3>&- 2>/dev/null || true
fi
if [ -n "$PROXY" ]; then
  export HTTPS_PROXY="$PROXY" HTTP_PROXY="$PROXY"
  git config --local http.proxy "$PROXY"
  git config --local https.proxy "$PROXY"
  echo "==> 使用代理 $PROXY"
fi

echo "==> 1/5 初始化仓库"
[ -d .git ] || git init -q
git branch -M "$BRANCH" 2>/dev/null || true

echo "==> 2/5 提交身份（仅本仓库生效）"
if ! git config user.email >/dev/null 2>&1; then
  git config user.name  "李宇翔"
  git config user.email "$EMAIL_DEFAULT"
fi

echo "==> 3/5 提交"
git add -A
if git diff --cached --quiet; then
  echo "    没有变更，跳过提交"
else
  git commit -q -m "${COMMIT_MSG:-chore: 同步本地变更}"
  echo "    已提交"
fi

echo "==> 4/5 确认远程仓库"
if ! git remote get-url origin >/dev/null 2>&1; then
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    gh repo create "$REPO_NAME" --private --source . --remote origin
  else
    GH_USER="${GH_USER:-$GH_USER_DEFAULT}"
    git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"
    echo "    已添加 origin；若仓库尚不存在，请先在网页端建同名【私有】仓库"
  fi
else
  echo "    已存在 origin：$(git remote get-url origin)"
fi

echo "==> 5/5 推送"
git push -u origin "$BRANCH"

echo "完成：$(git remote get-url origin | sed -E 's#(.*)\.git$#\1#')"
