# 04 · 任务④ 数字信封：GmSSL 实现，Bob → Alice（10 分）

> 题面（节选自实验要求）：两人一组，使用 **GmSSL 命令**实现带签名的数字信封协议，
> **Bob 发送，Alice 接收**；双方生成 SM2 公私钥对，明文为姓名学号；
> `k=rand(16B)`，`C=Sm4Enc(k,P)`，`KC=Sm2Enc(PKa,k)`，`S1=Sm2Sign(SKb,C)`，
> 发送 `C||KC||S1`；接收端验证签名、解 KC 取 k、解 C 得明文。
> 与任务③同一条协议、同一套步骤，**方向反转**（任务③ Alice 发 / 任务④ Bob 发）。

- **分工**：Alice = 20241422 穆弈涵（本人），Bob = 20241412 魏继博（搭档）。
- **模拟方式**：`t4/bob/`、`t4/alice/` 两个目录 + `cp` 模拟信道传输；
  公钥 `pkb.pub` 经「协议外提前交换」放入 Alice 目录。
- 引擎：GmSSL 3.2.0（00 节源码编译）。任务② 已逐个验证 SM2/SM3/SM4 原子操作，
  此处直接搭成信封。整套命令固化为 `scripts/task4-envelope-gmssl.sh`，可复现。
- 工具差异先交代（任务②详析，02.5 对照表）：GmSSL 语法为
  `sm4_cbc -encrypt|-decrypt`、`sm2sign/sm2verify -id`、`sm2encrypt/sm2decrypt`、
  `rand -hex -outlen`，私钥用 `-pass` 口令加密存储。

## 4.1 Bob 侧（发送方）：密钥对 + 加密打包（✅ 实测）

```
$ cd ~/exp1 && mkdir -p t4/bob t4/alice
$ gmssl sm2keygen -pass 123456 -out t4/bob/skb.key -pubout t4/bob/pkb.pub
$ gmssl sm2keygen -pass 123456 -out t4/alice/ska.key -pubout t4/alice/pka.pub
$ printf '%s' '20241412魏继博' > t4/bob/plain.txt; wc -c t4/bob/plain.txt
17 t4/bob/plain.txt
$ k=$(gmssl rand -hex -outlen 16); echo "k=$k"
k=0C92A9142771C0074F857D475058D8D7
$ IV04=00000000000000000000000000000000
$ gmssl sm4_cbc -encrypt -key $k -iv $IV04 -in t4/bob/plain.txt -out t4/bob/C.txt
$ printf '%s' "$k" > t4/bob/k.txt
$ gmssl sm2encrypt -pubkey t4/alice/pka.pub -in t4/bob/k.txt -out t4/bob/KC.bin
$ gmssl sm2sign -key t4/bob/skb.key -pass 123456 -id 1234567812345678 -in t4/bob/C.txt -out t4/bob/S1.bin
$ cp t4/bob/pkb.pub t4/alice/          # 公钥提前交换（协议外）
$ cp t4/bob/C.txt t4/bob/KC.bin t4/bob/S1.bin t4/alice/   # 信道传输 C||KC||S1
$ wc -c t4/bob/plain.txt t4/bob/C.txt t4/bob/KC.bin t4/bob/S1.bin t4/alice/C.txt t4/alice/KC.bin t4/alice/S1.bin
 17 t4/bob/plain.txt
 32 t4/bob/C.txt
141 t4/bob/KC.bin
 71 t4/bob/S1.bin
 32 t4/alice/C.txt
141 t4/alice/KC.bin
 71 t4/alice/S1.bin
505 总计
```

逐项算法与尺寸来历：

| 分量 | 生成命令 | 尺寸 | 来历 |
| --- | --- | --- | --- |
| plain.txt | `printf '%s' '20241412魏继博'` | 17 B | 学号 8 数字 + 姓名 3 汉字×3 字节 = 8+9 |
| C | `sm4_cbc -encrypt`（16B 密钥, K=0C92A9…） | 32 B | PKCS#7：17 % 16 = 1 → 补 15 字节 0x0F |
| KC | `sm2encrypt -pubkey alice/pka.pub`（明文 k.txt=32 字 hex） | 141 B | GmSSL DER 序列化，见下 |
| S1 | `sm2sign -key bob/skb.key -id …`（对象是密文 C） | 71 B | ASN.1 DER 的 r/s 两个 256-bit 整数 + 结构头 |

- 会话密钥 `k=0C92A9142771C0074F857D475058D8D7`（Bob 存 `t4/bob/k.txt` 备核，见 4.2）。
- 明文长度、C 补齐规律与任务③ 逐字节一致（17/32，PKCS#7 同源）。
- 签名对象是**密文 C**（题面 `Sm2Sign(SKb,C)`），与任务③ 的 `Sm2Sign(SKa,C)` 对称。

**KC 的 141 B 是 GmSSL 的 DER 结构，不是 OpenSSL 的 139 B——`od` 字节级复核（实测）：**

| 结构 | 字节 | 证据 |
| --- | --- | --- |
| SEQUENCE 头 | 3 | `30 81 8a`（内容长 0x8a=138 → 3+138=141） |
| INTEGER X（点横坐标） | 35 | `02 21 00` + 32B（`0xbe…` 最高位为 1，补 `00` 保正数） |
| INTEGER Y（点纵坐标） | 35 | 同形第二段 |
| OCTET STRING | 34 | 32B 的 C3（杂凑部分） |
| OCTET STRING | 34 | 32B 的 C2（对 k 密文） |

- 对比：任务③ 同一份 32 字节明文，OpenSSL `pkeyutl -encrypt` 出 **139 B**。
  **同明文、两工具输出尺寸不同**——分歧在 DER 结构（OpenSSL 为
  `C1(04||X||Y=65)||C3||C2`，GmSSL 为 `SEQUENCE{INTEGER,INTEGER,OCTET,OCTET}`），
  不在算法本身。按 02.5 声明，本实验只做同工具闭环，不做跨库互解。

## 4.2 Alice 侧（接收方）：验签 + 解信封（✅ 实测）

```
$ cat t4/alice/pkb.pub
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoEcz1UBgi0DQgAEfHuAIlAhh2N83mbCRW4d9YZzFL8Q
fQdnhlclkeB1VZwFxn97xBDWMTsBd0WLzbUqFYdOxMFRpMiCU7c8qj0rlw==
-----END PUBLIC KEY-----
$ gmssl sm2verify -pubkey t4/alice/pkb.pub -id 1234567812345678 -in t4/alice/C.txt -sig t4/alice/S1.bin
verify : success
$ gmssl sm2decrypt -key t4/alice/ska.key -pass 123456 -in t4/alice/KC.bin -out t4/alice/k_recv.txt
$ cat t4/alice/k_recv.txt
0C92A9142771C0074F857D475058D8D7
$ diff t4/bob/k.txt t4/alice/k_recv.txt && echo 'k一致：信封里的会话密钥被Alice正确取回'
k一致：信封里的会话密钥被Alice正确取回
$ krecv=$(cat t4/alice/k_recv.txt)
$ gmssl sm4_cbc -decrypt -key $krecv -iv 00000000000000000000000000000000 -in t4/alice/C.txt -out t4/alice/recv_plain.txt
$ cmp t4/bob/plain.txt t4/alice/recv_plain.txt && echo '信封闭环：Alice解出明文=Bob原文'
信封闭环：Alice解出明文=Bob原文
```

对照题面 Bob→Alice 三步：`Sm2Verify(PKb, C, S1)` 成功 → `Sm2Dec(Ska, KC)=k`
（与 Bob 侧 `t4/bob/k.txt` **逐字符一致**，`diff` 无输出）→
`Sm4Dec(k, C)=P`（与 `t4/bob/plain.txt` 逐字节一致，`cmp` 无差异）。

**篡改负例**（拆包后完整性被破坏，验签必须失败）：

```
$ cp t4/alice/C.txt t4/alice/C_tamper.txt
$ printf 'X' | dd of=t4/alice/C_tamper.txt bs=1 seek=5 conv=notrunc 2>/dev/null
$ gmssl sm2verify -pubkey t4/alice/pkb.pub -id 1234567812345678 -in t4/alice/C_tamper.txt -sig t4/alice/S1.bin; echo "exit=$?"
/home/20241422myh/GmSSL-3.2.0/src/sm2_sign.c:265:sm2_fast_verify():
/home/20241422myh/GmSSL-3.2.0/src/sm2_sign.c:671:sm2_verify_finish():
gmssl sm2verify: inner error
exit=1
```

- GmSSL 验签失败形态与任务② 篡改负例完全一致：`inner error` + 源码行号。
  判定失败凭 **exit code=1**（02.6 结论：报错文案不做自动化判据）。

## 4.3 问题与反思

1. **题面方向反转，但把协议文字也"复制"了过来**：任务④ 明文处仍写
   「Alice 发给 Bob」字样，且 `plain.txt 内容为自己的姓名学号`。
   本实验按**发送方自己的姓名学号**执行——任务④ 的明文是 Bob 的
   `20241412魏继博`（17 B），任务③ 是 Alice 的 `20241422穆弈涵`（17 B）。
   这一解释显式写在这里，防止歧义。
2. **协议未定义的三个点全部显式写死**：① SM4-CBC 的 IV 固定全零（与任务③ 同值）；
   ② 用户标识 `-id` 用 GM/T 0003 的默认值 `1234567812345678`，签/验两侧同值
   （OpenSSL 侧由 `-rawin -digest sm3` 隐含同一默认）；③ 公钥 `pkb.pub` 走
   「协议外提前交换」。不靠心照不宣，可复现。
3. **四类密钥动作的方向性**（与任务③ 同结论）：加密用**对方**公钥
   （KC 用 Alice 公钥），解密用**自己**私钥（Alice 解 KC）；签名用**自己**私钥
   （S1 用 Bob 私钥），验签用**对方**公钥。放反任何一步立刻失败。
4. **GmSSL 与 OpenSSL 的 SM2 密文序列化不同**：同 32 字节明文，GmSSL 141 B、
   OpenSSL 139 B，字节级核实为 DER 结构差异（4.1 表格）。工具可互换的是
   算法与语义，不是二进制格式——所以信封不跨库解，02.5 已声明。
5. **双重闭环验证**：`diff k` 证明会话密钥正确交达对方，`cmp plain` 证明
   明文内容到对方，`verify success` 证明来源可信。三处都过才叫信封闭合。
6. 私钥口令 `123456` 仅为界面占位（02.6.3）：GmSSL 私钥文件本身就是口令加密
   存储的，占位口令只适合一次性实验密钥，真实工程须强口令并离线保存。

## 4.4 与任务③的对应关系

| 环节 | 任务③ OpenSSL | 任务④ GmSSL | 一致性 |
| --- | --- | --- | --- |
| 密钥对 | `genpkey -algorithm SM2` | `sm2keygen -pass` | 同一曲线 sm2p256v1 |
| 随机数 k | `openssl rand -hex 16` | `gmssl rand -hex -outlen 16` | 均 16 字节 |
| SM4-CBC | `enc -sm4-cbc -K -iv` | `sm4_cbc -encrypt -key -iv` | 参数字节一致 |
| SM2 加密 | `pkeyutl -encrypt` | `sm2encrypt` | 密文格式不同（139/141） |
| SM2 签名 | `pkeyutl -sign -rawin -digest sm3` | `sm2sign -id` | 验签均成功、篡改均 exit=1 |
| 闭环 | diff k + cmp plain | diff k + cmp plain | 双向都通 |