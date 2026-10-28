# deploy_to_github.ps1 — 把本目录同步到 GitHub 私有仓库（幂等，可反复执行）
# 用法： pwsh -File deploy_to_github.ps1 [-RepoName Personal-Decision-OS] [-Proxy http://127.0.0.1:10808]
param(
    [string]$RepoName = 'Personal-Decision-OS',
    [string]$Branch   = 'main',
    [string]$Proxy    = '',
    [string]$CommitMessage = 'chore: 同步本地变更'
)

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

$GhUserDefault = 'xinjunye747-maker'
$EmailDefault  = 'xinjunye747@gmail.com'

# gh 默认不在 PATH 里，补上安装目录
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    foreach ($p in @("$env:ProgramFiles\GitHub CLI", "${env:ProgramFiles(x86)}\GitHub CLI", "$env:LOCALAPPDATA\Programs\GitHubCLI\bin")) {
        if (Test-Path (Join-Path $p 'gh.exe')) { $env:Path += ";$p"; break }
    }
}

# 国内直连 GitHub 常被掐，能探测到本地代理就自动用上
if (-not $Proxy) {
    $proxyOpen = $false
    try {
        $c = [System.Net.Sockets.TcpClient]::new()
        $proxyOpen = $c.ConnectAsync('127.0.0.1', 10808).Wait(600) -and $c.Connected
        $c.Close()
    } catch { $proxyOpen = $false }
    if ($proxyOpen) { $Proxy = 'http://127.0.0.1:10808' }
}
if ($Proxy) {
    $env:HTTPS_PROXY = $Proxy
    $env:HTTP_PROXY  = $Proxy
    git config --local http.proxy  $Proxy
    git config --local https.proxy $Proxy
    Write-Host "==> 使用代理 $Proxy"
}

Write-Host '==> 1/5 初始化仓库'
if (-not (Test-Path '.git')) { git init | Out-Null }
git branch -M $Branch 2>$null

Write-Host '==> 2/5 提交身份（仅本仓库生效）'
if (-not (git config user.email)) {
    git config user.name  '李宇翔'
    git config user.email $EmailDefault
}

# 私有仓库推送需要凭据；没配助手时会卡在 401 密码提示上
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status *> $null
    if ($LASTEXITCODE -eq 0) {
        gh auth setup-git 2>$null
        Write-Host '    已配置 git 凭据助手（gh）'
    }
}

Write-Host '==> 3/5 提交'
git add -A
$staged = git diff --cached --name-only
if ($staged) {
    git commit -m $CommitMessage | Out-Null
    Write-Host "    已提交 $($staged.Count) 个文件"
} else {
    Write-Host '    没有变更，跳过提交'
}

Write-Host '==> 4/5 确认远程仓库'
$hasOrigin = $true
try { git remote get-url origin | Out-Null } catch { $hasOrigin = $false }

if (-not $hasOrigin) {
    $ghReady = $false
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        gh auth status *> $null
        if ($LASTEXITCODE -eq 0) { $ghReady = $true }
    }
    if ($ghReady) {
        gh repo create $RepoName --private --source . --remote origin
    } else {
        $user = Read-Host "    请输入你的 GitHub 用户名（回车默认 $GhUserDefault）"
        if (-not $user) { $user = $GhUserDefault }
        git remote add origin "https://github.com/$user/$RepoName.git"
        Write-Host '    已添加 origin；若仓库尚不存在，请先在网页端建同名【私有】仓库'
    }
} else {
    Write-Host "    已存在 origin：$(git remote get-url origin)"
}

Write-Host '==> 5/5 推送'
git push -u origin $Branch
Write-Host '完成。'
