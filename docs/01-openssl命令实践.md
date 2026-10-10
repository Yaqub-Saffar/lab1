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
be01d2cdc78c1f4106cd5cb893c6ca9
```

- 32 个 hex 字符 = 16 字节。对照 00 节 GmSSL 侧
  `gmssl rand -hex -outlen 16` → `C432E97950B3CB75B1E8586C6860C1E0`，
  两工具各独立产生 16 字节随机数（数字信封的 SM4 密钥就从这里来）。

## 1.3 SM3 摘要：OpenSSL 与 GmSSL 双引擎对照（✅ 实测）

```
$ echo -n '20241422穆弈涵' > t.txt
$ openssl dgst -sm3 t.txt
SM3(t.txt)= dfc1bb19a04773b7b3acbd568ea0a8fec80449510747f40fbeed3bf76ad028ff
$ gmssl sm3 -in t.txt
dfc1bb19a04773b7b3acbd568ea0a8fec80449510747f40fbeed3bf76ad028ff
```

- 先按旧文档 `gmssl sm3 t.txt` 会报 `sm3: illegal option 't.txt'`（见 1.7）。
  查源码 `tools/sm3.c` usage（`[-hex|-bin] [-pubkey pem [-id str]] [-in file|-in_str str] [-out file]`）
  改用 `-in file` 后，输出与 OpenSSL 的 `dgst -sm3` **逐字符一致**
  `dfc1bb19…ad028ff`——两套独立实现互认，同输入必同输出。

## 1.4 SM4-CBC 加解密往返（✅ 实测）

```
$ K=$(openssl rand -hex 16); IV=$(openssl rand -hex 16); echo "K=$K"; echo "IV=$IV"; echo "K位数:${#K} IV位数:${#IV}"
K=c24ee3476d8fec90dd06d714234b76ff
IV=3719a9fa0dafa1c3dc0be2fd72f5b209
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

## 1.5 SM2 密钥生成与签名验签（✅ 实测）

```
$ openssl genpkey -algorithm SM2 -out sm2a.key
$ openssl pkey -in sm2a.key -pubout -out sm2a.pub
$ openssl pkey -in sm2a.key -text -noout | head -6
Private-Key: (256 bit)
priv:
    b5:ee:78:cf:bd:15:a7:6b:c4:96:e3:56:e0:c6:80:
    30:8d:f8:86:bc:84:c6:56:8d:15:89:78:a3:b7:a7:
    dc:b0
pub:
$ openssl pkeyutl -sign -in t.txt -inkey sm2a.key -rawin -digest sm3 -out t.sig
$ openssl pkeyutl -verify -in t.txt -pubin -inkey sm2a.pub -rawin -digest sm3 -sigfile t.sig
Signature Verified Successfully
$ echo -n '20241422穆弈涵 篡改' > t2.txt
$ openssl pkeyutl -verify -in t2.txt -pubin -inkey sm2a.pub -rawin -digest sm3 -sigfile t.sig; echo "负例exit=$?"
Signature Verification Failure
80B0D911227F0000:error:030000EA:digital envelope routines:EVP_DigestVerifyFinal:provider signature failure:crypto/evp/m_sigver.c:701:SM2 digest_verify_final:
负例exit=1
```

- SM2 密钥 256 bit（曲线 sm2p256v1 默认）。`genpkey -algorithm SM2` 一步生成私钥，
  `pkey -pubout` 导出公钥。
- 签名：`pkeyutl -sign -rawin -digest sm3`；验签同参数换公钥。
  SM2 算法要求带**用户标识 distid**——此处未显式指定，OpenSSL 用内置默认
  `1234567812345678`，签名与验签同值所以成功。数字信封里建议显式写定，两边一致。
- **篡改负例**：对内容改动后的文件验同一签名 → `Signature Verification Failure`，
  `exit=1`。证明签名确实绑定原文（完整性 + 认证性）。

## 1.6 SM2 加解密（✅ 实测）

```
$ openssl genpkey -algorithm SM2 -out sm2b.key
$ openssl pkey -in sm2b.key -pubout -out sm2b.pub
$ openssl rand -out k16.bin 16
$ openssl pkeyutl -encrypt -in k16.bin -inkey sm2b.pub -pubin -out k16.enc
$ openssl pkeyutl -decrypt -in k16.enc -inkey sm2b.key -out k16.dec
$ cmp k16.bin k16.dec && echo SM2加解密一致
SM2加解密一致
```

- `sm2b` 起「Bob 那把密钥」的作用：**用公钥加密、私钥解密**——`sm2b.pub` 加密
  → `sm2b.key` 解密，往返一致。这正是数字信封里「用 Bob 公钥加密会话密钥」的原子操作。
- 明文这里是 16 字节随机（模拟对称密钥），加解密后逐字节一致（`k16.bin / k16.enc / k16.dec`）。

## 1.7 任务① 小结与问题

1. **`gmssl sm3` 新旧语法差异**：按旧文档 `gmssl sm3 t.txt` 报
   `sm3: illegal option 't.txt'` → 读 `tools/sm3.c` usage 定位为
   `-in file` 形式。**与 00 节问题 2 同源：GmSSL 3.x 全面改了命令行选项风格，
   凡题面/旧教程给的 gmssl 命令都要先对 3.2.0 源码核对。**
