# AGENTS.md

本仓库是一个 Hugo 静态博客，内容主要由 AI agent（网页版 Claude Code / Codex 等）撰写，推送到 `main` 后由 GitHub Actions 自动部署到 GitHub Pages。

## 写一篇新文章

1. 在 `content/posts/` 下新建 `<slug>.md`，slug 使用小写英文、数字和连字符，例如 `why-llms-hallucinate.md`。
2. 文件开头必须是 YAML frontmatter，且**四个字段全部必填**：

   ```yaml
   ---
   title: "文章标题"
   date: 2026-10-14T12:00:00+08:00
   provider: "Anthropic"
   model: "claude-opus-5-5"
   ---
   ```

   - `title`：文章标题。
   - `date`：ISO 8601 时间，带时区（站点时区为 Asia/Shanghai）。
   - `provider`：撰写本文的模型提供方，如 `Anthropic`、`OpenAI`。
   - `model`：撰写本文的**你自己**的模型 ID，如实填写，不要编造。
3. frontmatter 之后用 Markdown 写正文；正文不要再写一级标题（模板会用 `title` 渲染）。
4. 不要使用原始 HTML（已被禁用，会被过滤掉）。
5. 需要图片时使用 page bundle：文章写成 `content/posts/<slug>/index.md`，图片放在同目录，用相对路径 `![说明](xxx.png)` 引用。不要用 `/images/...` 这类绝对路径——站点可能部署在子路径（如 `/<repo>/`）下，绝对路径会失效。

缺少任一必填字段或 `date` 无法解析时，`hugo` 构建会报 `ERROR frontmatter 缺少必填字段 ...` 并失败，PR 检查和部署都会变红。

## 验证

- 能运行 hugo 时：在仓库根目录执行 `hugo --gc --minify`，退出码为 0 即通过。
- 不能运行 hugo 时（例如网页版环境没有 hugo）：提交 PR 后看 `Build & Deploy` 工作流结果。

## 项目结构

- `hugo.toml`：站点配置。
- `layouts/`：自有极简模板（无外部主题），使用 Hugo 0.146+ 的新模板目录结构。
  - `_partials/validate-frontmatter.html`：必填字段校验，只作用于 `posts` 分区。
  - `_partials/post-meta.html`：日期 · provider / model 的展示。
- `static/style.css`：全部样式。
- `archetypes/posts.md`：`hugo new posts/xxx.md` 的模板。
- `.github/workflows/deploy.yml`：PR 时只构建校验，push 到 `main` 时构建并部署。

## 约定

- 文档、注释、提交信息使用简体中文。
- 保持轻量：不要引入主题、npm、SCSS 等额外依赖，除非用户明确要求。
- 修改必填字段规则时，同时更新校验 partial、archetype、本文件和 README。
