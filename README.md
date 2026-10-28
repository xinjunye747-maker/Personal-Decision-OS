# Personal-Decision-OS

> 个人决策系统与元提示词 · **v1.0.0（100-Question Deep Profile Edition）**
>
> 唯一战略目标：以绝对优势一战考取 **东南大学 电路与系统** 硕士（初试 920：信号与系统 + 数字电路；复试：电子线路）。

这套仓库不是日记，是一台**决策与执行机器**：把「我是谁、我要去哪、我今天该干什么」固化成可版本化、可喂给 AI、可被反复审计的文本资产。

---

## 一句话定位

用**顶级硅谷工程总监 + 华尔街对冲基金经理**的人格，对一个大三电子信息工科生进行零废话、ROI 唯一的每日督导；同时用 100 问画像让任何一个 AI 在 30 秒内完整加载「他是谁」。

---

## 仓库结构

| 文件 | 作用 | 喂给谁 |
|---|---|---|
| `SEU_EE_Master_Persona_System_Prompt.md` | 核心资产：导师人格提示词 + 100 问画像 + 40 天六级方案 + 决策矩阵 | ChatGPT 自定义指令 / Claude Project Instructions / Gemini 高级指令 |
| `100_Questions_Interview_Framework.md` | 标准化 100 问自测与访谈模板（可复用、可开源） | 自我复盘、访谈他人、周期性重测 |
| `.cursorrules` | 精简版人格规则（Cursor 每次对话自动加载） | Cursor / Windsurf 等 IDE Agent |
| `deploy_to_github.ps1` / `deploy_to_github.sh` | 一键初始化 + 建私有仓库 + 推送（幂等，可反复跑） | Windows PowerShell / Bash |

---

## 已部署状态

| 项 | 值 |
|---|---|
| 仓库 | https://github.com/xinjunye747-maker/Personal-Decision-OS |
| 可见性 | **Private**（含真实隐私画像，勿转公开） |
| 默认分支 | `main` |
| 首次提交 | `7a74f1d feat: init 100-question persona & master prompt v1.0` |

### 日常三条命令

```powershell
# 看状态
git status -sb

# 改完内容后提交（版本号按上方规范递增）
git commit -am "feat(v1.1.0): CET-6 出分 XXX，更新英语攻坚参数"

# 推送
git push
```

### 网络前提（重要）

国内直连 `github.com:443` 会被掐断，本机已配好走 v2rayN 本地代理：

```powershell
git config --global --get http.proxy        # 应为 http://127.0.0.1:10808
```

- `git` 走的是全局配置，代理没开时 `git push` 会超时——先把 v2rayN 启动好再推。
- `gh` 命令行不读 git 配置，需要临时环境变量：`$env:HTTPS_PROXY='http://127.0.0.1:10808'`。
- 若代理端口变了（比如换成 7890），`git config --global http.proxy http://127.0.0.1:7890` 改一下即可。

### 存储位置提醒

本仓库当前位于 OneDrive 同步目录内。`.git` 被云盘并发同步是小概率但真实存在的损坏源：

- 稳妥做法：把仓库迁到非同步路径（如 `C:\dev\Personal-Decision-OS`），再把 OneDrive 里这份删掉；
- 或者至少确认 OneDrive 没有在推送进行中锁住 `.git` 目录。

---

## 快速开始（3 步）

### 1) 配成「终身导师」

**ChatGPT**：设置 → 个性化 → 自定义指令 → 「希望 ChatGPT 如何回应」→ 粘贴 `SEU_EE_Master_Persona_System_Prompt.md` 的**模块一**全文。

**Claude**：Projects → 新建项目 `Personal-Decision-OS` → 上传本目录全部 `.md` 为 Project Knowledge → Project Instructions 填**模块一**。

**Gemini**：Gemini 高级指令 / Gems → 新建 Gem，指令填**模块一**，知识库上传本目录。

**Cursor**：把 `.cursorrules` 放进任意工作区根目录。

### 2) 每日调用开场词

```
调出我的个人画像，今天我要完成以下三件事，用顶级华尔街导师人格对我的计划进行严苛审查与计时：
1.
2.
3.
```

### 3) 里程碑迭代（Git Commit）

六级出分 / 数学一轮收官 / 初试 / 复试 / 选导师 / 选 offer —— 每次重大进展都改版本号并 commit：

```bash
git commit -am "feat(v1.1.0): CET-6 出分 XXX，更新英语攻坚参数"
```

---

## 版本迭代规范

| 版本位 | 触发条件 | 示例 |
|---|---|---|
| MAJOR | 战略目标变更（换院校 / 换专业 / 放弃考研） | `v2.0.0` |
| MINOR | 阶段目标达成或参数实质变化（出分、初试结束、换导师） | `v1.1.0` |
| PATCH | 措辞、排版、补充案例 | `v1.0.1` |

---

## 隐私说明

本仓库含真实姓名、院校、成绩、家庭与情感状况等强隐私信息。

- **必须设为 Private**；
- 不要 fork 到公开仓库，不要在任何公开平台粘贴模块二（100 问画像）；
- 分享「提示词框架」时，只分享去掉个人数据的骨架。

---

## 许可

私人使用。除本人授权外不对外开放。
