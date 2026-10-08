# 03 · 任务③ 数字信封：OpenSSL 实现，Alice → Bob（10 分）

> 题面（节选自实验要求）：双端 SM2 公钥体制建立，明文为本人姓名学号；
> `k=rand(16B)`，`C=Sm4Enc(k,P)`，`KC=Sm2Enc(PKb,k)`，`S1=Sm2Sign(SKa,C)`，
> 发送 `C||KC||S1`；接收端验证签名、解 KC 取 k、解 C 得明文。
> 双方各持私钥，公钥公开；本实验 IV 在协议未定义处**显式固定全零**并记录。

- **分工**：Alice = 20241422 穆弈涵（本人），Bob = 20241412 魏继博（搭档）。
- **模拟方式**：现场以 `alice/`、`bob/` 两个目录 + `cp` 模拟信道传输；
  公钥 `pka.pub` 经「协议外提前交换」放入 Bob 目录（真实场景同理，公钥本就不保密）。
- 引擎：OpenSSL 3.5.6。任务① 已逐个验证 SM2/SM3/SM4 各原子操作，此处直接搭成信封。

## 3.1 Alice 侧：密钥对 + 加密打包（✅ 实测）

```
$ mkdir -p alice bob
$ openssl genpkey -algorithm SM2 -out alice/ska.key
$ openssl pkey -in alice/ska.key -pubout -out alice/pka.pub
$ openssl genpkey -algorithm SM2 -out bob/skb.key
$ openssl pkey -in bob/skb.key -pubout -out bob/pkb.pub
$ echo -n '20241422穆弈涵' > alice/plain.txt; wc -c alice/plain.txt
17 alice/plain.txt
$ k=$(openssl rand -hex 16); echo "k=$k"
k=622225f42551e9fee2a9156b700cc5a9
$ IV0=00000000000000000000000000000000
$ openssl enc -sm4-cbc -K $k -iv $IV0 -in alice/plain.txt -out alice/C.txt
$ echo -n "$k" > alice/k.txt
$ openssl pkeyutl -encrypt -in alice/k.txt -inkey bob/pkb.pub -pubin -out alice/KC.bin
$ openssl pkeyutl -sign -in alice/C.txt -inkey alice/ska.key -rawin -digest sm3 -out alice/S1.bin
$ cp alice/pka.pub bob/          # 公钥提前交换（协议外）
$ cp alice/C.txt alice/KC.bin alice/S1.bin bob/   # 信道传输 C||KC||S1
$ wc -c alice/C.txt alice/KC.bin alice/S1.bin bob/C.txt bob/KC.bin bob/S1.bin
 32 alice/C.txt
139 alice/KC.bin
 71 alice/S1.bin
 32 bob/C.txt
139 bob/KC.bin
 71 bob/S1.bin
484 总计
```

逐项算法与尺寸来历：

| 分量 | 生成命令 | 尺寸 | 来历 |
| --- | --- | --- | --- |
| plain.txt | `echo -n '20241422穆弈涵'` | 17 B | 学号 8 数字 + 姓名 3 汉字×3 字节 = 8+9 |
| C | SM4-CBC(k, IV=0, plain) | 32 B | PKCS#7：17 % 16 = 1 → 补 15 字节 0x0F |
| KC | SM2Enc(pkb, k.txt) | 139 B | 明文是 32 字 hex 明文 → 比 16B 明文时(123)多 16 |
| S1 | SM2Sign(ska, C) | 71 B | ASN.1 DER 的两个 256-bit 整数 + 结构头 |

- 会话密钥 `k=622225f42551e9fee2a9156b700cc5a9`（发送方存 `alice/k.txt` 备核，见 3.2）。
- 签名对象是**密文 C**（题面 `Sm2Sign(SKa,C)`），不是明文——验签时点必须一致。

## 3.2 Bob 侧：验签 + 解信封（⬜ 待实测）

## 3.3 问题与反思（⬜ 收侧完成后再写）