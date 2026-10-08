#!/usr/bin/env bash
# 任务④ . 带签名数字信封（GmSSL 3.2.0 命令）：Bob 发送 → Alice 接收
# 用法：bash /mnt/hgfs/lab1/scripts/task4-envelope-gmssl.sh 2>&1 | tee /mnt/hgfs/lab1/_wip/task4-log.txt
# 协议与任务③同一套（题面原样），方向反转；明文=发送方自己的姓名学号。
set -uo pipefail

cd "$HOME/exp1" || { echo '~/exp1 不存在，先建工作目录'; exit 1; }
mkdir -p t4/bob t4/alice

DID=1234567812345678                                  # 用户标识：GM/T 0003 默认值，签验两侧同值
PASS=123456                                           # 实验用口令占位（见 02.6）
IV04=00000000000000000000000000000000                 # 协议未定义 IV，与任务③一致：显式固定全零

run() {
  printf '\n$ %s\n' "$*"
  "$@" 2>&1
}

gmssl version
echo "工作目录: $(pwd)"

echo '== 1 生成双方密钥对（Bob=发送方, Alice=接收方）=='
run gmssl sm2keygen -pass "$PASS" -out t4/bob/skb.key -pubout t4/bob/pkb.pub
run gmssl sm2keygen -pass "$PASS" -out t4/alice/ska.key -pubout t4/alice/pka.pub

echo '== 2 Bob 侧：明文 = 自己的姓名学号 + 会话密钥 k（gmssl rand, 16 字节）=='
run bash -c "printf '%s' '20241412魏继博' > t4/bob/plain.txt && wc -c t4/bob/plain.txt"
k=$(gmssl rand -hex -outlen 16)
echo "k=$k"
printf '%s' "$k" > t4/bob/k.txt

echo '== 3 Bob 侧：C = SM4_CBC_Enc(k, IV=0, plain) =='
run gmssl sm4_cbc -encrypt -key "$k" -iv "$IV04" -in t4/bob/plain.txt -out t4/bob/C.txt

echo '== 4 Bob 侧：KC = SM2_Enc(PK_alice, k) =='
run gmssl sm2encrypt -pubkey t4/alice/pka.pub -in t4/bob/k.txt -out t4/bob/KC.bin

echo '== 5 Bob 侧：S1 = SM2_Sign(SK_bob, C, DID) =='
run gmssl sm2sign -key t4/bob/skb.key -pass "$PASS" -id "$DID" -in t4/bob/C.txt -out t4/bob/S1.bin

echo '== 6 信道传输：公钥提前交换（协议外）+ 传送 C||KC||S1 =='
run sh -c "cp t4/bob/pkb.pub t4/alice/ && cp t4/bob/C.txt t4/bob/KC.bin t4/bob/S1.bin t4/alice/"

echo '== 7 尺寸核对 =='
run wc -c t4/bob/plain.txt t4/bob/C.txt t4/bob/KC.bin t4/bob/S1.bin t4/alice/C.txt t4/alice/KC.bin t4/alice/S1.bin

echo '== 8 Alice 侧：SM2_Verify(PK_bob, S1) =='
run cat t4/alice/pkb.pub
run gmssl sm2verify -pubkey t4/alice/pkb.pub -id "$DID" -in t4/alice/C.txt -sig t4/alice/S1.bin

echo '== 9 Alice 侧：SM2_Dec(SK_alice, KC) = k =='
run gmssl sm2decrypt -key t4/alice/ska.key -pass "$PASS" -in t4/alice/KC.bin -out t4/alice/k_recv.txt
run cat t4/alice/k_recv.txt
run bash -c "diff t4/bob/k.txt t4/alice/k_recv.txt && echo k一致：信封里的会话密钥被Alice正确取回"

echo '== 10 Alice 侧：SM4_CBC_Dec(k, C) = plain =='
krecv=$(cat t4/alice/k_recv.txt)
run gmssl sm4_cbc -decrypt -key "$krecv" -iv "$IV04" -in t4/alice/C.txt -out t4/alice/recv_plain.txt
run bash -c "cmp t4/bob/plain.txt t4/alice/recv_plain.txt && echo 信封闭环：Alice解出明文=Bob原文"

echo '== 11 负例：篡改 C 后验签必须失败（exit=1）=='
cp t4/alice/C.txt t4/alice/C_tamper.txt
printf 'X' | dd of=t4/alice/C_tamper.txt bs=1 seek=5 conv=notrunc 2>/dev/null
run gmssl sm2verify -pubkey t4/alice/pkb.pub -id "$DID" -in t4/alice/C_tamper.txt -sig t4/alice/S1.bin
echo "负例exit=$?"