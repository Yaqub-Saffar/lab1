# 04 路 浠诲姟鈶?鏁板瓧淇″皝锛欸mSSL 瀹炵幇锛孊ob 鈫?Alice锛?0 鍒嗭級

> 棰橀潰锛堣妭閫夎嚜瀹為獙瑕佹眰锛夛細涓や汉涓€缁勶紝浣跨敤 **GmSSL 鍛戒护**瀹炵幇甯︾鍚嶇殑鏁板瓧淇″皝鍗忚锛?> **Bob 鍙戦€侊紝Alice 鎺ユ敹**锛涘弻鏂圭敓鎴?SM2 鍏閽ュ锛屾槑鏂囦负濮撳悕瀛﹀彿锛?> `k=rand(16B)`锛宍C=Sm4Enc(k,P)`锛宍KC=Sm2Enc(PKa,k)`锛宍S1=Sm2Sign(SKb,C)`锛?> 鍙戦€?`C||KC||S1`锛涙帴鏀剁楠岃瘉绛惧悕銆佽В KC 鍙?k銆佽В C 寰楁槑鏂囥€?> 涓庝换鍔♀憿鍚屼竴鏉″崗璁€佸悓涓€濂楁楠わ紝**鏂瑰悜鍙嶈浆**锛堜换鍔♀憿 Alice 鍙?/ 浠诲姟鈶?Bob 鍙戯級銆?
- **鍒嗗伐**锛欰lice = 20241422 绌嗗紙娑碉紙鏈汉锛夛紝Bob = 20241412 榄忕户鍗氾紙鎼。锛夈€?- **妯℃嫙鏂瑰紡**锛歚t4/bob/`銆乣t4/alice/` 涓や釜鐩綍 + `cp` 妯℃嫙淇￠亾浼犺緭锛?  鍏挜 `pkb.pub` 缁忋€屽崗璁鎻愬墠浜ゆ崲銆嶆斁鍏?Alice 鐩綍銆?- 寮曟搸锛欸mSSL 3.2.0锛?0 鑺傛簮鐮佺紪璇戯級銆備换鍔♀憽 宸查€愪釜楠岃瘉 SM2/SM3/SM4 鍘熷瓙鎿嶄綔锛?  姝ゅ鐩存帴鎼垚淇″皝銆傛暣濂楀懡浠ゅ浐鍖栦负 `scripts/task4-envelope-gmssl.sh`锛屽彲澶嶇幇銆?- 宸ュ叿宸紓鍏堜氦浠ｏ紙浠诲姟鈶¤鏋愶紝02.5 瀵圭収琛級锛欸mSSL 璇硶涓?  `sm4_cbc -encrypt|-decrypt`銆乣sm2sign/sm2verify -id`銆乣sm2encrypt/sm2decrypt`銆?  `rand -hex -outlen`锛岀閽ョ敤 `-pass` 鍙ｄ护鍔犲瘑瀛樺偍銆?
## 4.1 Bob 渚э紙鍙戦€佹柟锛夛細瀵嗛挜瀵?+ 鍔犲瘑鎵撳寘锛堚渽 瀹炴祴锛?
```
$ cd ~/exp1 && mkdir -p t4/bob t4/alice
$ gmssl sm2keygen -pass 123456 -out t4/bob/skb.key -pubout t4/bob/pkb.pub
$ gmssl sm2keygen -pass 123456 -out t4/alice/ska.key -pubout t4/alice/pka.pub
$ printf '%s' '20241412榄忕户鍗? > t4/bob/plain.txt; wc -c t4/bob/plain.txt
17 t4/bob/plain.txt
$ k=$(gmssl rand -hex -outlen 16); echo "k=$k"
k=4F880D69DBFEA53AF841476EA9EE093A
$ IV04=00000000000000000000000000000000
$ gmssl sm4_cbc -encrypt -key $k -iv $IV04 -in t4/bob/plain.txt -out t4/bob/C.txt
$ printf '%s' "$k" > t4/bob/k.txt
$ gmssl sm2encrypt -pubkey t4/alice/pka.pub -in t4/bob/k.txt -out t4/bob/KC.bin
$ gmssl sm2sign -key t4/bob/skb.key -pass 123456 -id 1234567812345678 -in t4/bob/C.txt -out t4/bob/S1.bin
$ cp t4/bob/pkb.pub t4/alice/          # 鍏挜鎻愬墠浜ゆ崲锛堝崗璁锛?$ cp t4/bob/C.txt t4/bob/KC.bin t4/bob/S1.bin t4/alice/   # 淇￠亾浼犺緭 C||KC||S1
$ wc -c t4/bob/plain.txt t4/bob/C.txt t4/bob/KC.bin t4/bob/S1.bin t4/alice/C.txt t4/alice/KC.bin t4/alice/S1.bin
 17 t4/bob/plain.txt
 32 t4/bob/C.txt
141 t4/bob/KC.bin
 71 t4/bob/S1.bin
 32 t4/alice/C.txt
141 t4/alice/KC.bin
 71 t4/alice/S1.bin
505 鎬昏
```

閫愰」绠楁硶涓庡昂瀵告潵鍘嗭細

| 鍒嗛噺 | 鐢熸垚鍛戒护 | 灏哄 | 鏉ュ巻 |
| --- | --- | --- | --- |
| plain.txt | `printf '%s' '20241412榄忕户鍗?` | 17 B | 瀛﹀彿 8 鏁板瓧 + 濮撳悕 3 姹夊瓧脳3 瀛楄妭 = 8+9 |
| C | `sm4_cbc -encrypt`锛?6B 瀵嗛挜, K=0C92A9鈥︼級 | 32 B | PKCS#7锛?7 % 16 = 1 鈫?琛?15 瀛楄妭 0x0F |
| KC | `sm2encrypt -pubkey alice/pka.pub`锛堟槑鏂?k.txt=32 瀛?hex锛?| 141 B | GmSSL DER 搴忓垪鍖栵紝瑙佷笅 |
| S1 | `sm2sign -key bob/skb.key -id 鈥锛堝璞℃槸瀵嗘枃 C锛?| 71 B | ASN.1 DER 鐨?r/s 涓や釜 256-bit 鏁存暟 + 缁撴瀯澶?|

- 浼氳瘽瀵嗛挜 `k=4F880D69DBFEA53AF841476EA9EE093A`锛圔ob 瀛?`t4/bob/k.txt` 澶囨牳锛岃 4.2锛夈€?- 鏄庢枃闀垮害銆丆 琛ラ綈瑙勫緥涓庝换鍔♀憿 閫愬瓧鑺備竴鑷达紙17/32锛孭KCS#7 鍚屾簮锛夈€?- 绛惧悕瀵硅薄鏄?*瀵嗘枃 C**锛堥闈?`Sm2Sign(SKb,C)`锛夛紝涓庝换鍔♀憿 鐨?`Sm2Sign(SKa,C)` 瀵圭О銆?
**KC 鐨?141 B 鏄?GmSSL 鐨?DER 缁撴瀯锛屼笉鏄?OpenSSL 鐨?139 B鈥斺€擿od` 瀛楄妭绾у鏍革紙瀹炴祴锛夛細**

| 缁撴瀯 | 瀛楄妭 | 璇佹嵁 |
| --- | --- | --- |
| SEQUENCE 澶?| 3 | `30 81 8a`锛堝唴瀹归暱 0x8a=138 鈫?3+138=141锛?|
| INTEGER X锛堢偣妯潗鏍囷級 | 35 | `02 21 00` + 32B锛坄0xbe鈥 鏈€楂樹綅涓?1锛岃ˉ `00` 淇濇鏁帮級 |
| INTEGER Y锛堢偣绾靛潗鏍囷級 | 35 | 鍚屽舰绗簩娈?|
| OCTET STRING | 34 | 32B 鐨?C3锛堟潅鍑戦儴鍒嗭級 |
| OCTET STRING | 34 | 32B 鐨?C2锛堝 k 瀵嗘枃锛?|

- 瀵规瘮锛氫换鍔♀憿 鍚屼竴浠?32 瀛楄妭鏄庢枃锛孫penSSL `pkeyutl -encrypt` 鍑?**139 B**銆?  **鍚屾槑鏂囥€佷袱宸ュ叿杈撳嚭灏哄涓嶅悓**鈥斺€斿垎姝у湪 DER 缁撴瀯锛圤penSSL 涓?  `C1(04||X||Y=65)||C3||C2`锛孏mSSL 涓?`SEQUENCE{INTEGER,INTEGER,OCTET,OCTET}`锛夛紝
  涓嶅湪绠楁硶鏈韩銆傛寜 02.5 澹版槑锛屾湰瀹為獙鍙仛鍚屽伐鍏烽棴鐜紝涓嶅仛璺ㄥ簱浜掕В銆?
## 4.2 Alice 渚э紙鎺ユ敹鏂癸級锛氶獙绛?+ 瑙ｄ俊灏侊紙鉁?瀹炴祴锛?
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
4F880D69DBFEA53AF841476EA9EE093A
$ diff t4/bob/k.txt t4/alice/k_recv.txt && echo 'k涓€鑷达細淇″皝閲岀殑浼氳瘽瀵嗛挜琚獳lice姝ｇ‘鍙栧洖'
k涓€鑷达細淇″皝閲岀殑浼氳瘽瀵嗛挜琚獳lice姝ｇ‘鍙栧洖
$ krecv=$(cat t4/alice/k_recv.txt)
$ gmssl sm4_cbc -decrypt -key $krecv -iv 00000000000000000000000000000000 -in t4/alice/C.txt -out t4/alice/recv_plain.txt
$ cmp t4/bob/plain.txt t4/alice/recv_plain.txt && echo '淇″皝闂幆锛欰lice瑙ｅ嚭鏄庢枃=Bob鍘熸枃'
淇″皝闂幆锛欰lice瑙ｅ嚭鏄庢枃=Bob鍘熸枃
```

瀵圭収棰橀潰 Bob鈫扐lice 涓夋锛歚Sm2Verify(PKb, C, S1)` 鎴愬姛 鈫?`Sm2Dec(Ska, KC)=k`
锛堜笌 Bob 渚?`t4/bob/k.txt` **閫愬瓧绗︿竴鑷?*锛宍diff` 鏃犺緭鍑猴級鈫?`Sm4Dec(k, C)=P`锛堜笌 `t4/bob/plain.txt` 閫愬瓧鑺備竴鑷达紝`cmp` 鏃犲樊寮傦級銆?
**绡℃敼璐熶緥**锛堟媶鍖呭悗瀹屾暣鎬ц鐮村潖锛岄獙绛惧繀椤诲け璐ワ級锛?
```
$ cp t4/alice/C.txt t4/alice/C_tamper.txt
$ printf 'X' | dd of=t4/alice/C_tamper.txt bs=1 seek=5 conv=notrunc 2>/dev/null
$ gmssl sm2verify -pubkey t4/alice/pkb.pub -id 1234567812345678 -in t4/alice/C_tamper.txt -sig t4/alice/S1.bin; echo "exit=$?"
/home/20241422myh/GmSSL-3.2.0/src/sm2_sign.c:265:sm2_fast_verify():
/home/20241422myh/GmSSL-3.2.0/src/sm2_sign.c:671:sm2_verify_finish():
gmssl sm2verify: inner error
exit=1
```

- GmSSL 楠岀澶辫触褰㈡€佷笌浠诲姟鈶?绡℃敼璐熶緥瀹屽叏涓€鑷达細`inner error` + 婧愮爜琛屽彿銆?  鍒ゅ畾澶辫触鍑?**exit code=1**锛?2.6 缁撹锛氭姤閿欐枃妗堜笉鍋氳嚜鍔ㄥ寲鍒ゆ嵁锛夈€?
## 4.3 闂涓庡弽鎬?
1. **棰橀潰鏂瑰悜鍙嶈浆锛屼絾鎶婂崗璁枃瀛椾篃"澶嶅埗"浜嗚繃鏉?*锛氫换鍔♀懀 鏄庢枃澶勪粛鍐?   銆孉lice 鍙戠粰 Bob銆嶅瓧鏍凤紝涓?`plain.txt 鍐呭涓鸿嚜宸辩殑濮撳悕瀛﹀彿`銆?   鏈疄楠屾寜**鍙戦€佹柟鑷繁鐨勫鍚嶅鍙?*鎵ц鈥斺€斾换鍔♀懀 鐨勬槑鏂囨槸 Bob 鐨?   `20241412榄忕户鍗歚锛?7 B锛夛紝浠诲姟鈶?鏄?Alice 鐨?`20241422绌嗗紙娑礰锛?7 B锛夈€?   杩欎竴瑙ｉ噴鏄惧紡鍐欏湪杩欓噷锛岄槻姝㈡涔夈€?2. **鍗忚鏈畾涔夌殑涓変釜鐐瑰叏閮ㄦ樉寮忓啓姝?*锛氣憼 SM4-CBC 鐨?IV 鍥哄畾鍏ㄩ浂锛堜笌浠诲姟鈶?鍚屽€硷級锛?   鈶?鐢ㄦ埛鏍囪瘑 `-id` 鐢?GM/T 0003 鐨勯粯璁ゅ€?`1234567812345678`锛岀/楠屼袱渚у悓鍊?   锛圤penSSL 渚х敱 `-rawin -digest sm3` 闅愬惈鍚屼竴榛樿锛夛紱鈶?鍏挜 `pkb.pub` 璧?   銆屽崗璁鎻愬墠浜ゆ崲銆嶃€備笉闈犲績鐓т笉瀹ｏ紝鍙鐜般€?3. **鍥涚被瀵嗛挜鍔ㄤ綔鐨勬柟鍚戞€?*锛堜笌浠诲姟鈶?鍚岀粨璁猴級锛氬姞瀵嗙敤**瀵规柟**鍏挜
   锛圞C 鐢?Alice 鍏挜锛夛紝瑙ｅ瘑鐢?*鑷繁**绉侀挜锛圓lice 瑙?KC锛夛紱绛惧悕鐢?*鑷繁**绉侀挜
   锛圫1 鐢?Bob 绉侀挜锛夛紝楠岀鐢?*瀵规柟**鍏挜銆傛斁鍙嶄换浣曚竴姝ョ珛鍒诲け璐ャ€?4. **GmSSL 涓?OpenSSL 鐨?SM2 瀵嗘枃搴忓垪鍖栦笉鍚?*锛氬悓 32 瀛楄妭鏄庢枃锛孏mSSL 141 B銆?   OpenSSL 139 B锛屽瓧鑺傜骇鏍稿疄涓?DER 缁撴瀯宸紓锛?.1 琛ㄦ牸锛夈€傚伐鍏峰彲浜掓崲鐨勬槸
   绠楁硶涓庤涔夛紝涓嶆槸浜岃繘鍒舵牸寮忊€斺€旀墍浠ヤ俊灏佷笉璺ㄥ簱瑙ｏ紝02.5 宸插０鏄庛€?5. **鍙岄噸闂幆楠岃瘉**锛歚diff k` 璇佹槑浼氳瘽瀵嗛挜姝ｇ‘浜よ揪瀵规柟锛宍cmp plain` 璇佹槑
   鏄庢枃鍐呭鍒板鏂癸紝`verify success` 璇佹槑鏉ユ簮鍙俊銆備笁澶勯兘杩囨墠鍙俊灏侀棴鍚堛€?6. 绉侀挜鍙ｄ护 `123456` 浠呬负鐣岄潰鍗犱綅锛?2.6.3锛夛細GmSSL 绉侀挜鏂囦欢鏈韩灏辨槸鍙ｄ护鍔犲瘑
   瀛樺偍鐨勶紝鍗犱綅鍙ｄ护鍙€傚悎涓€娆℃€у疄楠屽瘑閽ワ紝鐪熷疄宸ョ▼椤诲己鍙ｄ护骞剁绾夸繚瀛樸€?
## 4.4 涓庝换鍔♀憿鐨勫搴斿叧绯?
| 鐜妭 | 浠诲姟鈶?OpenSSL | 浠诲姟鈶?GmSSL | 涓€鑷存€?|
| --- | --- | --- | --- |
| 瀵嗛挜瀵?| `genpkey -algorithm SM2` | `sm2keygen -pass` | 鍚屼竴鏇茬嚎 sm2p256v1 |
| 闅忔満鏁?k | `openssl rand -hex 16` | `gmssl rand -hex -outlen 16` | 鍧?16 瀛楄妭 |
| SM4-CBC | `enc -sm4-cbc -K -iv` | `sm4_cbc -encrypt -key -iv` | 鍙傛暟瀛楄妭涓€鑷?|
| SM2 鍔犲瘑 | `pkeyutl -encrypt` | `sm2encrypt` | 瀵嗘枃鏍煎紡涓嶅悓锛?39/141锛?|
| SM2 绛惧悕 | `pkeyutl -sign -rawin -digest sm3` | `sm2sign -id` | 楠岀鍧囨垚鍔熴€佺鏀瑰潎 exit=1 |
| 闂幆 | diff k + cmp plain | diff k + cmp plain | 鍙屽悜閮介€?|
