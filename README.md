# 《密码系统设计》实验一 · 嵌入式开发基础

- **学号 / 姓名**：20241422 穆弈涵（Alice）
- **搭档**：20241412 魏继博（Bob）
- **环境**：openEuler 24.03 LTS（VMware 虚拟机，图形界面）
- **本次范围**：1-3 学时实践要求（30 分）

## 任务与分值（1-3 学时）

| # | 任务 | 分值 | 状态 | 记录 |
| --- | --- | --- | --- | --- |
| 1 | OpenSSL 相关内容实践（逐项 git commit） | 5' | ⬜ | `docs/01-openssl命令实践.md` |
| 2 | GmSSL 相关内容实践（逐项 git commit） | 5' | ⬜ | `docs/02-gmssl命令实践.md` |
| 3 | OpenSSL 命令实现带签名的数字信封（Alice 发 → Bob 收） | 10' | ⬜ | `docs/03-数字信封-openssl.md` |
| 4 | GmSSL 命令实现带签名的数字信封（Bob 发 → Alice 收） | 10' | ✅ | `docs/04-数字信封-gmssl.md`（脚本 `scripts/task4-envelope-gmssl.sh`） |
| 5 | gitee/github 课程项目链接 + `git log` 结果 | — | ⬜ | `README.md` 末节 |
| 6 | 实践过程 Markdown + 转化 PDF | — | ⬜ | `README.md` + 根目录 PDF |

4-6 学时（库编程 + 库版数字信封，另 30 分）与实验报告（10 分）不在本次范围。

## 数字信封协议（题面原样，两边同一协议、方向相反）

身份替换：Alice = `20241422穆弈涵`，Bob = `20241412魏继博`。

- 明文 `plain.txt` = Alice 的姓名学号
- Alice：`k = gmssl rand` 产生 16 字节 SM4 密钥
- Alice：`Sm4Enc(k, P) = C`
- Alice：`Sm2Enc(PKb, k) = KC`
- Alice：`Sm2Sign(SKa, C) = S1`
- Alice → Bob：数字信封 `C || KC || S1`
- Bob：`Sm2Verify(PKa, S1)` → `Sm2Dec(SKb, KC) = k` → `Sm4Dec(k, C) = P`

任务 3 用 OpenSSL 命令（Alice 发）；任务 4 用 GmSSL 命令（Bob 发）。

## 目录结构

```
实验一/
├── README.md            本文件：任务表、协议、git log、仓库链接
├── docs/
│   ├── 00-环境搭建.md    系统信息、OpenSSL/GmSSL 安装、PS1 学号水印
│   ├── 01-openssl命令实践.md
│   ├── 02-gmssl命令实践.md
│   ├── 03-数字信封-openssl.md
│   └── 04-数字信封-gmssl.md
├── scripts/setup-vm.sh   VM 一次性环境准备脚本
├── screenshots/          实操截图（PS1 带学号水印）
└── artifacts/            密钥/密文等过程物（.gitignore，不入库）
```

## 提交要求对照（题面第 6 条）

- [ ] 实践过程 Markdown + 转化 PDF
- [ ] 代码与文档托管到 gitee/github（链接见下）
- [ ] 记录遇到的问题、解决过程、反思 → 各 `docs/*.md` 的「问题与反思」节 + 报告
- [ ] `git log` 运行结果 → 见下
- [ ] 每完成一项一次 commit

## 课程项目链接

- GitHub 仓库：`https://github.com/Yaqub-Saffar/lab1`
- 提交物：README + `docs/`（实践命令与反思）+ `scripts/`（复现脚本）+ `screenshots/`
- ⚠️ `artifacts/`、`_wip/`、`*.key` 被 `.gitignore` 排除，密钥/过程物不入库

## git log 运行结果

（收尾时回填 `git log --oneline` 输出）
