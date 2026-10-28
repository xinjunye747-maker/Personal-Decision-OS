# deploy_to_github.ps1 — Windows 一键推送（等价于 deploy_to_github.sh）
# 用法： pwsh -File deploy_to_github.ps1 [-RepoName Personal-Decision-OS]
param(
    [string]$RepoName = 'Personal-Decision-OS',
    [string]$Branch = 'main'
)

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

Write-Host '==> 1/5 初始化仓库'
if (-not (Test-Path '.git')) { git init | Out-Null }
git branch -M $Branch 2>$null

Write-Host '==> 2/5 提交身份（仅本仓库生效）'
if (-not (git config user.email)) {
    git config user.name  '李宇翔'
    git config user.email 'you@example.com'   # ← 改成你的 GitHub 邮箱
}

Write-Host '==> 3/5 提交'
git add -A
$staged = git diff --cached --name-only
if ($staged) {
    git commit -m 'feat: init 100-question persona & master prompt v1.0' | Out-Null
    Write-Host "    已提交 $($staged.Count) 个文件"
} else {
    Write-Host '    没有变更，跳过提交'
}

Write-Host '==> 4/5 建远程仓库'
$hasOrigin = $true
try { git remote get-url origin | Out-Null } catch { $hasOrigin = $false }

$ghReady = $false
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status *> $null
    if ($LASTEXITCODE -eq 0) { $ghReady = $true }
}

if (-not $hasOrigin) {
    if ($ghReady) {
        gh repo create $RepoName --private --source . --remote origin
    } else {
        $user = Read-Host '    请输入你的 GitHub 用户名'
        git remote add origin "https://github.com/$user/$RepoName.git"
        Write-Host '    已添加 origin；请先在 GitHub 网页端创建同名【私有】仓库，再 push'
    }
}

Write-Host '==> 5/5 推送'
git push -u origin $Branch
Write-Host '完成。'
