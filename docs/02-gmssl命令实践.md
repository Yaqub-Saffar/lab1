# 02 · 任务② GmSSL 相关内容实践（5 分）

- **依据**：题面第 2 条「实践课程思维导图中 GmSSL 相关内容」。
- 环境：GmSSL 3.2.0（00 节编译安装自官方 v3.2.0 tarball）。
- **重要前置**：GmSSL 3.2.0 命令行与旧版/文档差异巨大（`-hex`/`-outlen`/`-in file`、
  `sm2keygen` 强制 `-pass`、SM4 命令为 `sm4_cbc` 等），所有命令均先对 3.2.0 源码
  `tools/*.c` 的 usage 核对再执行。
- 工作目录：VM 内 `~/exp1`。

## 2.1 版本与本套件能力（✅ 实测）

```
$ gmssl version
GmSSL 3.2.0
```

## 2.2 SM4-CBC 加解密往返（✅ 实测）

```
$ K2=$(gmssl rand -hex -outlen 16); IV2=$(gmssl rand -hex -outlen 16); echo "K2=$K2"; echo "IV2=$IV2"
K2=92B3C883C0B6BE0454775B92EC9F9D180
IV2=B2B8C5E71CE838D0AA192AEF819F7E24
$ echo -n '20241422穆弈涵 明文测试' > plain2.txt; wc -c plain2.txt
30 plain2.txt
$ gmssl sm4_cbc -encrypt -key $K2 -iv $IV2 -in plain2.txt -out sm4c2.bin
$ wc -c sm4c2.bin
32 sm4c2.bin
$ gmssl sm4_cbc -decrypt -key $K2 -iv $IV2 -in sm4c2.bin -out sm4out2.txt
$ cmp plain2.txt sm4out2.txt && echo 'GmSSL SM4 解密一致'
GmSSL SM4 解密一致
```

- 与 1.4（OpenSSL）完全同参数：PKCS#7 补齐，30 字节明文 → 32 字节密文，CBC+16 字节 IV。
- 注意语法：`gmssl sm4_cbc -encrypt|-decrypt -key <hex> -iv <hex>`，K/IV 均为 32 字 hex。

## 2.3 SM2 密钥生成与签名验签（✅ 实测）

```
$ gmssl sm2keygen -pass 123456 -out bob.key -pubout bob.pub
$ cat bob.pub
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoEcz1UBgi0DQgAEuuXXZjPtdq/tVvDb50j1GiPPaTUG
0Ohadp1L9E26EG1v2bKZB4q/iBnr0dumD3uEX7f1Z3SscUoPRTnQjMAcQA==
-----END PUBLIC KEY-----
$ echo -n 'GmSSL签名消息' > msg.txt
$ gmssl sm2sign -key bob.key -pass 123456 -id 1234567812345678 -in msg.txt -out msg.sig
$ gmssl sm2verify -pubkey bob.pub -id 1234567812345678 -in msg.txt -sig msg.sig
verify : success
$ echo -n 'GmSSL篡改消息' > msg2.txt
$ gmssl sm2verify -pubkey bob.pub -id 1234567812345678 -in msg2.txt -sig msg.sig; echo "负例exit=$?"
/home/20241422myh/GmSSL-3.2.0/src/sm2_sign.c:265:sm2_fast_verify():
/home/20241422myh/GmSSL-3.2.0/src/sm2_sign.c:671:sm2_verify_finish():
gmssl sm2verify: inner error
负例exit=1
```

- 公钥 PEM 算法 OID 为 `1.2.156.10197.1.301`（国密 SM2 椭圆曲线 sm2p256v1，
  ASN.1 里形如 `YIKoEcz1UBgi0DQgAE`），与 OpenSSL `genpkey -algorithm SM2` 同一条曲线。
- 签名带**用户标识 distid**：`-id 1234567812345678`，签验同值才成功，与 1.5 结论互证。
- 篡改负例：GmSSL 报错形态与 OpenSSL 不同——不输出 `Signature Verification Failure`，
  而是**内部错误 + 源码行号**（`sm2_sign.c:265/671`），但语义一致：**验证失败，exit=1**。

## 2.4 SM2 加解密往返（✅ 实测）

```
$ gmssl rand -outlen 16 -out k16b.bin            # 二进制 16 字节随机
$ gmssl sm2encrypt -pubkey bob.pub -in k16b.bin -out k16b.enc
$ gmssl sm2decrypt -key bob.key -pass 123456 -in k16b.enc -out k16b.dec
$ cmp k16b.bin k16b.dec && echo 'GmSSL SM2 加解密一致'
GmSSL SM2 加解密一致
$ wc -c k16b.bin k16b.enc
 16 k16b.bin
123 k16b.enc
139 总计
```

- 公钥加密 / 私钥解密往返一致；（对比 1.6：OpenSSL 相同输入也得到 **16→123 字节**，
  两个独立实现 SM2 密文尺寸完全相同 → 数字信封里每份 KC 的固定开销 107 字节可预知）。

## 2.5 OpenSSL 与 GmSSL 关键对照（任务①↔任务②）

| 能力 | OpenSSL 3.5.6 | GmSSL 3.2.0 | 结论 |
| --- | --- | --- | --- |
| SM3 | `dgst -sm3` | `sm3 -in` | 同摘要 `dfc1bb19…` |
| SM4-CBC | `enc -sm4-cbc -K -iv` | `sm4_cbc -encrypt -key -iv` | 同参数，30→32 字节 |
| SM2 密钥 | `genpkey -algorithm SM2` | `sm2keygen -pass` | 同曲线 sm2p256v1 |
| SM2 签名 | `pkeyutl -sign/-verify -rawin -digest sm3` | `sm2sign/sm2verify -id` | 均验签成功；篡改均失败 exit=1 |
| SM2 加密 | `pkeyutl -encrypt/-decrypt` | `sm2encrypt/sm2decrypt` | 均为 16→123 字节 |
| 随机数 | `openssl rand -hex 16` | `gmssl rand -hex -outlen 16` | 均产 16 字节 |

- 差异：GmSSL 密钥强制口令 AE 加密存储（`-pass`）；distid 必须显式/同值；报错带源码行号。
- **不做两个引擎之间的混合加解密/验签互操作**——两套工具各自闭环，跨库格式兼容是另一个课题。

## 2.6 问题与反思

1. GmSSL 3.2.0 与文档命令差异集中爆发（同 00 节问题 2、01 节问题 1 同源）：**凡 GmSSL
   命令一律先读 `tools/*.c` usage**，本任务 8 条命令全部按源码核对后一次成功。
2. 篡改负例的报错不同：OpenSSL 走 EVP 报 `Signature Verification Failure`，
   GmSSL 走内部 `inner error + src/sm2_sign.c:行号`。**验证失败的判定依据都是 exit code=1**，
   报错文案不能当自动化判据——这也是实验结论之一：脚本校验必须看返回值而非 stderr。
3. 记录口令 `123456` 仅为界面占位：GmSSL 私钥文件本身就是口令加密的，样例口令对
   「一次性实验密钥」无危害，真实工程私钥须用强口令并离线保存。
