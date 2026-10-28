#!/usr/bin/env bash
# deploy_to_github.sh — 一键把本目录推送到 GitHub 私有仓库
# 用法：
#   bash deploy_to_github.sh                 # 交互式，默认仓库名 Personal-Decision-OS
#   bash deploy_to_github.sh my-repo-name    # 指定仓库名
# 依赖：git；可选 gh（已登录时自动建私有仓库）
set -euo pipefail

REPO_NAME="${1:-Personal-Decision-OS}"
BRANCH="main"

cd "$(dirname "$0")"

echo "==> 1/5 初始化仓库"
if [ ! -d .git ]; then
  git init -q
fi
git branch -M "$BRANCH" 2>/dev/null || true

echo "==> 2/5 写入提交身份（仅本仓库生效，可改）"
if ! git config user.email >/dev/null 2>&1; then
  git config user.name  "李宇翔"
  git config user.email "you@example.com"   # ← 改成你的 GitHub 邮箱
fi

echo "==> 3/5 提交"
git add -A
if git diff --cached --quiet; then
  echo "    没有变更，跳过提交"
else
  git commit -q -m "feat: init 100-question persona & master prompt v1.0"
fi

echo "==> 4/5 建远程仓库"
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  if ! git remote get-url origin >/dev/null 2>&1; then
    gh repo create "$REPO_NAME" --private --source . --remote origin
  fi
else
  if ! git remote get-url origin >/dev/null 2>&1; then
    read -r -p "    请输入你的 GitHub 用户名: " GH_USER
    git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"
    echo "    已添加 origin；请先在 GitHub 网页端创建同名【私有】仓库，再运行 git push"
  fi
fi

echo "==> 5/5 推送"
git push -u origin "$BRANCH"

echo "完成：https://github.com/$(git remote get-url origin | sed -E 's#.*github.com[/:]([^/]+)/.*#\1#')/${REPO_NAME}"
