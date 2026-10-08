# 01 · 任务① OpenSSL 相关内容实践（5 分）

- **依据**：题面第 1 条「实践课程思维导图中 OpenSSL 相关内容」。
  思维导图链接（ProcessOn）经本人确认无有用内容，实践范围按题面点名的
  OpenSSL 基本用法覆盖：版本总览 → 随机数 → SM3 → SM4 → SM2。
- **纪律**：只贴真实执行输出；工作目录为 VM 内 `~/exp1`；每完成一组一次 git commit。

## 1.1 版本总览（✅ 实测）

```
$ openssl version -a | head -4
OpenSSL 3.5.6 7 Apr 2026 (Library: OpenSSL 3.5.6 7 Apr 2026)
built on: Mon Sep  7 03:33:17 2026 UTC
platform: linux-x86_64
options:  bn(64,64)
```

## 1.2 随机数（✅ 实测）

```
$ openssl rand -hex 16
f0ad11bfc7846cd6d09983688cb1e54e
```

- 32 个 hex 字符 = 16 字节。对照 00 节 GmSSL 侧
  `gmssl rand -hex -outlen 16` → `C432E97950B3CB75B1E8586C6860C1E0`，
  两工具各独立产生 16 字节随机数（数字信封的 SM4 密钥就从这里来）。

## 1.3 SM3 摘要：OpenSSL 与 GmSSL 双引擎对照（🟡 gmssl 侧待重跑）

```
$ echo -n '20241422穆弈涵' > t.txt
$ openssl dgst -sm3 t.txt
SM3(t.txt)= dfc1bb19a04773b7b3acbd568ea0a8fec80449510747f40fbeed3bf76ad028ff
$ gmssl sm3 t.txt
sm3: illegal option 't.txt'
```

- GmSSL 3.2.0 的 `sm3` 不再接受位置参数（旧版/文档写法 `gmssl sm3 <file>` 已废）。
  查源码 `tools/sm3.c:20` usage：`[-hex|-bin] [-pubkey pem [-id str]] [-in file|-in_str str] [-out file]`
  → 正确写法 `gmssl sm3 -in t.txt`，重跑结果待回填。

## 1.4 SM4-CBC 加解密往返（✅ 实测）

```
$ K=$(openssl rand -hex 16); IV=$(openssl rand -hex 16); echo "K=$K"; echo "IV=$IV"; echo "K位数:${#K} IV位数:${#IV}"
K=00100398c0afe3afad17a2aa90fc390f
IV=221646e963f29c9bb98783792d300cf1
K位数:32 IV位数:32
$ echo -n '20241422穆弈涵 明文测试' > plain1.txt; wc -c plain1.txt
30 plain1.txt
$ openssl enc -list | grep sm4
-sm4                       -sm4-cbc                   -sm4-cfb
-sm4-ctr                   -sm4-ecb                   -sm4-ofb
$ openssl enc -sm4-cbc -K $K -iv $IV -in plain1.txt -out sm4c.bin
$ wc -c sm4c.bin
32 sm4c.bin
$ openssl enc -sm4-cbc -d -K $K -iv $IV -in sm4c.bin -out sm4out.txt
$ cmp plain1.txt sm4out.txt && echo 解密一致
解密一致
$ od -A d -t x1 sm4c.bin
0000000 84 7e a9 b9 25 ec 27 6e 69 e2 ab ac 64 dc 67 23
0000016 37 bd bf bf 9e 6f 50 82 d9 59 bd 37 1e c2 21 19
```

- 明文 30 字节、密文 32 字节：**PKCS#7 补齐 2 字节（值 0x02）**。
  补齐值在密文里不可直接观察，由 30→32 的长度差与分组宽度 16 推得。
- K、IV 均来自 `openssl rand -hex 16`，各 32 个 hex 字符（16 字节）。

## 1.5 SM2 密钥生成与签名验签（⬜ 待实测）

## 1.6 SM2 加解密（⬜ 待实测）

## 1.7 问题与反思

1. **`gmssl sm3` 新旧语法差异**：按旧文档 `gmssl sm3 t.txt` 报
   `sm3: illegal option 't.txt'` → 读 `tools/sm3.c` usage 定位为
   `-in file` 形式。**与 00 节问题 2 同源：GmSSL 3.x 全面改了命令行选项风格，
   凡题面/旧教程给的 gmssl 命令都要先对 3.2.0 源码核对。**
