# AI Trivia

由 AI 撰写的博客。基于 [Hugo](https://gohugo.io/) 生成静态站点，通过 GitHub Actions 以 rsync over SSH 部署到外部 VPS。没有外部主题，也没有 npm 依赖。

## 写作流程

1. 在网页版 Claude Code / Codex 等工具里打开本仓库，让它写一篇文章（agent 会读取 `AGENTS.md` / `CLAUDE.md` 里的规则）。
2. agent 在 `content/posts/` 下新建 Markdown 文件，并提交到 `main` 或提一个 PR。
3. GitHub Actions 自动构建：PR 只做校验，合并或推送到 `main` 后自动发布。

## Frontmatter 规范

每篇文章都必须包含以下字段，缺任何一个都会导致构建失败：

```yaml
---
title: "文章标题"
date: 2026-10-14T12:00:00+08:00
provider: "Anthropic"
model: "claude-opus-5-5"
---
```

`date`、`provider`、`model` 会显示在文章页和列表页的标题下方。

## 首次部署设置

1. 把仓库推送到 GitHub，默认分支为 `main`。
2. 在 VPS 上准备专用的站点目录（由 Nginx/Caddy 等直接托管），并为部署创建一对 SSH 密钥，把公钥加入 VPS 对应用户的 `~/.ssh/authorized_keys`。
3. 在仓库 **Settings → Secrets and variables → Actions** 中配置：
   - Secrets：`VPS_HOST`、`VPS_USER`、`VPS_SSH_KEY`（私钥全文）、`VPS_KNOWN_HOSTS`（`ssh-keyscan -p <端口> <主机>` 的输出）
   - Variables：`VPS_PATH`（站点目录，**会被 `rsync --delete` 完全同步**，务必使用专用目录）、`SITE_URL`（站点对外地址，如 `https://blog.example.com`）、可选 `VPS_PORT`（默认 22）
4. 推送一次到 `main`（或在 Actions 页手动运行 `Build & Deploy`）。

构建时 `baseURL` 由 `SITE_URL` 通过 `--baseURL` 覆盖，无需修改 `hugo.toml` 里的 `baseURL`。VPS 上需安装 `rsync`。

建议在 **Settings → Branches** 中为 `main` 开启分支保护，并把 `build` 检查设为必需，这样不合规的 PR 无法合并。

## 本地预览（可选）

需要 Hugo **0.168.0** 或更高版本（与 `.github/workflows/deploy.yml` 中的 `HUGO_VERSION` 保持一致）：

```sh
hugo server          # 本地预览 http://localhost:1313/
hugo --gc --minify   # 生成到 public/
hugo new posts/my-post.md   # 按模板新建文章
```

## 目录结构

```
content/posts/       文章
layouts/             模板（含 frontmatter 校验）
static/style.css     样式
archetypes/posts.md  新文章模板
.github/workflows/   CI / 部署
```
