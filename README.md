# 🦞 费曼虾（feynman-lobster）

> 你告诉龙虾你在做什么项目，龙虾读你的代码和笔记，在你需要时教你需要的知识。学习是做事的副产品。

**形态：** OpenClaw Skill + Web 面板  
**定位：** 项目驱动学习，不做脱离上下文的“课程助手”

详细介绍：https://gamma.app/docs/-jzk412qh98bo1rn

---

## 项目愿景

费曼虾想解决两个常见问题：

1. **学习脱离项目**：很多人“学了很多”，但落不到手头项目里
2. **只有自我承诺**：没有外部约束，计划很容易中断

因此它采用“项目契约”模式：

- 以项目为中心签约（做什么、为了什么、多久、代码/笔记路径）
- 读取你的真实上下文（只读），按需解释和追问
- 用费曼法验证掌握（不是背定义）
- 通过 A2A 邀请“监工龙虾”，把承诺变成社会约束(待定)

---

## 用户故事

### 1) 签约开始

用户说：“我在做一个 ML 项目，项目在 `~/projects/ml-train`，笔记在 `~/obsidian/翻译本.md`。”

费曼虾会：
- 收集契约要素（项目、动机、截止时间、资源路径）
- 拆解当前项目所需知识背景（概念型 + 工具型）
- 用户确认后写入契约并开始追踪

### 2) 用户主动提问

用户问：“`optimizer.zero_grad()` 是干什么的？”

费曼虾不会直接灌答案，而会基于项目上下文反问引导：
- 如果不调会怎样？
- 梯度会怎样累积？
- 在你的训练循环里它应该放哪？

### 3) 龙虾主动追问（心跳）

心跳时，费曼虾会读取项目/笔记变化，找到“你正在使用但可能没完全理解”的点，主动提问验证理解。

### 4) 动态增减条款

若发现前置知识缺失（如会用梯度但不懂偏导），会把前置条款插入契约；若发现新技术点（如 `model.eval()`），会追加条款并标记来源原因。

### 5) 外部监工（待定）

你可通过 A2A 邀请其他人的龙虾当监工。监工只看进度摘要，不看私密对话内容。

---

## 架构设计

### 运行架构（概念）

- **内部（OpenClaw Runtime）**
  - Skill 指令：`SKILL.md`
  - 追问调度：`HEARTBEAT.md` + Agent heartbeat
  - 状态存储：workspace 文件（如 `contracts.json`）
  - 对话检索：memory 插件
- **可视化（Web）**
  - 面板：`web/index.html`
  - 数据源：`http://localhost:18789/api/feynman/contracts`
  - 不可用时明确报错，不回退 mock 假数据

### 文件路由关系（核心）

#### 1. 对话路由（用户意图 -> 指令文件）

| 用户输入 | 路由文件 | 行为 |
|---|---|---|
| “我在做 X 项目” / “签约” | `instructions/contract.md` | 收集契约要素并创建契约 |
| “这个是什么意思” / “为什么要这样” | `instructions/feynman.md` | 基于项目上下文做费曼引导 |
| “来考我” | `instructions/feynman.md` | 立即发起主动追问 |
| 心跳触发 | `HEARTBEAT.md` -> `instructions/feynman.md` | 读项目后主动追问 |
| “我的契约” / “暂停” / “继续” / “找监工” | `SKILL.md` 路由规则 | 状态查询、状态切换|

#### 2. 文件读写路由（状态流）

| 文件 | 读/写 | 作用 |
|---|---|---|
| `contracts.json`（workspace） | 读写 | 契约主状态、条款进度、资源、监工 |
| `USER_PROFILE.md`（workspace） | 读写 | 跨项目用户画像与学习偏好 |
| `contract-memory/{contract_id}.md`（workspace） | 读写 | 单契约的理解记录、盲区、阶段总结 |
| 用户项目/笔记路径（resources.local.path） | **只读** | 作为追问与解释的真实上下文 |
| `MEMORY.md` | 只读说明 | 记忆分工文档，不做主存储 |

---

## 目录结构

```text
feynman-lobster/
├── SKILL.md
├── HEARTBEAT.md
├── instructions/
│   ├── contract.md
│   └── feynman.md
├── agent-card.json
├── MEMORY.md
├── USER_PROFILE.md
├── scripts/
│   ├── setup.sh
│   ├── start-panel.sh
│   └── requirements.txt
├── web/
│   ├── index.html
│   └── package.json
└── README.md
```

---

## 安装与初始化

### 方式 A：通过 ClawHub（推荐）

```bash
clawhub install feynman-lobster
```

### 方式 B：通过 OpenClaw

```bash
openclaw skills add https://github.com/yilin/feynman-lobster
```

### 初始化

```bash
bash ~/.openclaw/skills/feynman-lobster/scripts/setup.sh
```

如果你的 workspace 不是 `~/.openclaw`，请把路径替换为实际安装路径。

---

## 使用方式

### 在 IM 中使用

安装后，在飞书/Telegram/Discord 等渠道中对龙虾说：

| 你说 | 龙虾做什么 |
|---|---|
| “我在做 ML 项目，项目在 `~/projects/ml-train`” | 签约，记录项目与上下文路径 |
| “这个是什么意思” / “为什么要这样” | 基于项目上下文解释 + 费曼追问 |
| “来考我” | 立即发起一道项目相关追问 |
| “我的契约” | 返回当前进度摘要 |
| “找监工 {agent_card_url}” | 发起 A2A 监工邀请 |
| “暂停” / “继续” | 切换契约状态 |
| “面板” / “启动面板” | 返回面板地址与启动命令 |

### Web 面板

面板地址：`http://localhost:19380`
<img width="1331" height="724" alt="image" src="https://github.com/user-attachments/assets/da8f4e89-6f83-4708-98bb-361f55d97a5f" />

**推荐启动（任意目录可执行）**

```bash
bash ~/.openclaw/skills/feynman-lobster/scripts/start-panel.sh
```

如果通过 ClawHub 安装在项目本地 workspace（如 `./skills`），从 workspace 根目录执行：

```bash
bash skills/feynman-lobster/scripts/start-panel.sh
```

---

## 快速排错

- 面板打不开：确认 `start-panel.sh` 是否运行成功
- 面板报“无法连接 Gateway”：先启动 `openclaw gateway`
- 面板报 API 404/500：确认 Gateway 已提供 `/api/feynman/contracts`
- 签约无进度：检查契约资源路径是否可读（代码/笔记路径）

