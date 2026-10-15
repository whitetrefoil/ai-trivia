# AI Trivia

记录由我的突发奇想而起、与 AI 展开的对话。文章以聊天记录的形式展示（我问、AI 答、我追问、AI 再答），由 AI 整理撰写。基于 [Hugo](https://gohugo.io/) 生成静态站点，通过 GitHub Actions 以 rsync over SSH 部署到外部 VPS。没有外部主题，也没有 npm 依赖。

## 写作流程

1. 在 Claude / ChatGPT 的 chat（通过 GitHub 连接器），或网页版 Claude Code / Codex 等工具里让 AI 整理一篇文章；在 chat 里发布时，先提醒它读取 `AGENTS.md` 中的规则。
2. AI 按 `AGENTS.md` 的发布流程整理对话（除脱敏外尽量保持原样）、做发布前自检，遇到严重问题会暂停并与我商量。
3. AI 在 `content/posts/` 下新建 Markdown 文件并提一个 PR（除非我明确要求，否则不直接提交到 `main`）。
4. GitHub Actions 自动构建：PR 只做校验，合并到 `main` 后自动发布。

## Frontmatter 规范

`title`、`date` 始终必填；正文含 `ai` 消息时 `provider`、`model` 也必填（只有 `me` 的公告可以省略）。缺少必填字段会导致构建失败：

```yaml
---
title: "文章标题"
date: 2026-10-14T12:00:00+08:00
provider: "Anthropic"
model: "claude-opus-5-5"
---
```

`provider`、`model` 填原对话中给出回答的 AI（对话的原作者），而不是负责整理文章的 AI。

`date`、`provider`、`model` 会显示在文章页和列表页的标题下方。

## 正文格式

正文用 `me` / `ai` 两个 shortcode 按顺序记录对话，内部照常写 Markdown：

```markdown
{{< me >}}
我的问题
{{< /me >}}

{{< ai >}}
AI 的回答
{{< /ai >}}
```

追问就继续追加 `me` / `ai`。条数和顺序不限：只有一条 `me`（如公告）或只有一条 `ai`（如普通文章）都能正常显示。

站点禁用了原始 HTML。另外两点格式规则（详见 `AGENTS.md`「加粗、斜体与公式」）：

- 加粗 / 斜体的 `**` / `*` 内侧是标点、外侧紧挨文字时会失效，在外侧加 `\ `（渲染为空）：`**阿德维塔（Adwaita）**\ 的象龟`。`scripts/check-emphasis.sh` 会在构建后检查，CI 中也会执行。
- 数学公式：行内 `\(...\)`，独立成行 `$$...$$` 或 `\[...\]`，构建时转成 MathML；单个 `$` 不是定界符。

## 首次部署设置

1. 把仓库推送到 GitHub，默认分支为 `main`。
2. 在 VPS 上准备专用的站点目录（由 Nginx/Caddy 等直接托管），并为部署创建一对 SSH 密钥，把公钥加入 VPS 对应用户的 `~/.ssh/authorized_keys`。
3. 在仓库 **Settings → Secrets and variables → Actions** 中配置：
   - Secrets：`VPS_HOST`、`VPS_USER`、`VPS_PATH`（站点目录，**会被 `rsync --delete` 完全同步**，务必使用专用目录）、`VPS_SSH_KEY`（私钥全文）、`VPS_KNOWN_HOSTS`（`ssh-keyscan -p <端口> <主机>` 的输出）、可选 `VPS_PORT`（SSH 端口，默认 22）
   - Variables：`SITE_URL`（站点对外地址，如 `https://blog.example.com`）
4. 推送一次到 `main`（或在 Actions 页手动运行 `Build & Deploy`）。

构建时 `baseURL` 由 `SITE_URL` 通过 `--baseURL` 覆盖，无需修改 `hugo.toml` 里的 `baseURL`。VPS 上需安装 `rsync`。

建议在 **Settings → Branches** 中为 `main` 开启分支保护，并把 `build` 检查设为必需，这样不合规的 PR 无法合并。

## 本地预览（可选）

需要 Hugo **0.168.0** 或更高版本（与 `.github/workflows/deploy.yml` 中的 `HUGO_VERSION` 保持一致）：

```sh
hugo server          # 本地预览 http://localhost:1313/
hugo --gc --minify   # 生成到 public/
sh scripts/check-emphasis.sh   # 检查失效的加粗 / 斜体
hugo new posts/my-post.md   # 按模板新建文章
```

## 目录结构

```
content/posts/       文章
layouts/             模板（含 frontmatter 校验、me/ai 消息 shortcode）
assets/style.css     样式（构建时加内容指纹）
archetypes/posts.md  新文章模板
scripts/            构建后检查脚本
.github/workflows/   CI / 部署
```
