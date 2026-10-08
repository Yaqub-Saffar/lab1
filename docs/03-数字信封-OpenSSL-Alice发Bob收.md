# 03 路 浠诲姟鈶?鏁板瓧淇″皝锛歄penSSL 瀹炵幇锛孉lice 鈫?Bob锛?0 鍒嗭級

> 棰橀潰锛堣妭閫夎嚜瀹為獙瑕佹眰锛夛細鍙岀 SM2 鍏挜浣撳埗寤虹珛锛屾槑鏂囦负鏈汉濮撳悕瀛﹀彿锛?> `k=rand(16B)`锛宍C=Sm4Enc(k,P)`锛宍KC=Sm2Enc(PKb,k)`锛宍S1=Sm2Sign(SKa,C)`锛?> 鍙戦€?`C||KC||S1`锛涙帴鏀剁楠岃瘉绛惧悕銆佽В KC 鍙?k銆佽В C 寰楁槑鏂囥€?> 鍙屾柟鍚勬寔绉侀挜锛屽叕閽ュ叕寮€锛涙湰瀹為獙 IV 鍦ㄥ崗璁湭瀹氫箟澶?*鏄惧紡鍥哄畾鍏ㄩ浂**骞惰褰曘€?
- **鍒嗗伐**锛欰lice = 20241422 绌嗗紙娑碉紙鏈汉锛夛紝Bob = 20241412 榄忕户鍗氾紙鎼。锛夈€?- **妯℃嫙鏂瑰紡**锛氱幇鍦轰互 `alice/`銆乣bob/` 涓や釜鐩綍 + `cp` 妯℃嫙淇￠亾浼犺緭锛?  鍏挜 `pka.pub` 缁忋€屽崗璁鎻愬墠浜ゆ崲銆嶆斁鍏?Bob 鐩綍锛堢湡瀹炲満鏅悓鐞嗭紝鍏挜鏈氨涓嶄繚瀵嗭級銆?- 寮曟搸锛歄penSSL 3.5.6銆備换鍔♀憼 宸查€愪釜楠岃瘉 SM2/SM3/SM4 鍚勫師瀛愭搷浣滐紝姝ゅ鐩存帴鎼垚淇″皝銆?
## 3.1 Alice 渚э細瀵嗛挜瀵?+ 鍔犲瘑鎵撳寘锛堚渽 瀹炴祴锛?
```
$ mkdir -p alice bob
$ openssl genpkey -algorithm SM2 -out alice/ska.key
$ openssl pkey -in alice/ska.key -pubout -out alice/pka.pub
$ openssl genpkey -algorithm SM2 -out bob/skb.key
$ openssl pkey -in bob/skb.key -pubout -out bob/pkb.pub
$ echo -n '20241422绌嗗紙娑? > alice/plain.txt; wc -c alice/plain.txt
17 alice/plain.txt
$ k=$(openssl rand -hex 16); echo "k=$k"
k=622422ca19bc93c88d234d71b621b8cf
$ IV0=00000000000000000000000000000000
$ openssl enc -sm4-cbc -K $k -iv $IV0 -in alice/plain.txt -out alice/C.txt
$ echo -n "$k" > alice/k.txt
$ openssl pkeyutl -encrypt -in alice/k.txt -inkey bob/pkb.pub -pubin -out alice/KC.bin
$ openssl pkeyutl -sign -in alice/C.txt -inkey alice/ska.key -rawin -digest sm3 -out alice/S1.bin
$ cp alice/pka.pub bob/          # 鍏挜鎻愬墠浜ゆ崲锛堝崗璁锛?$ cp alice/C.txt alice/KC.bin alice/S1.bin bob/   # 淇￠亾浼犺緭 C||KC||S1
$ wc -c alice/C.txt alice/KC.bin alice/S1.bin bob/C.txt bob/KC.bin bob/S1.bin
 32 alice/C.txt
139 alice/KC.bin
 71 alice/S1.bin
 32 bob/C.txt
139 bob/KC.bin
 71 bob/S1.bin
484 鎬昏
```

閫愰」绠楁硶涓庡昂瀵告潵鍘嗭細

| 鍒嗛噺 | 鐢熸垚鍛戒护 | 灏哄 | 鏉ュ巻 |
| --- | --- | --- | --- |
| plain.txt | `echo -n '20241422绌嗗紙娑?` | 17 B | 瀛﹀彿 8 鏁板瓧 + 濮撳悕 3 姹夊瓧脳3 瀛楄妭 = 8+9 |
| C | SM4-CBC(k, IV=0, plain) | 32 B | PKCS#7锛?7 % 16 = 1 鈫?琛?15 瀛楄妭 0x0F |
| KC | SM2Enc(pkb, k.txt) | 139 B | 鏄庢枃鏄?32 瀛?hex 鏄庢枃 鈫?姣?16B 鏄庢枃鏃?123)澶?16 |
| S1 | SM2Sign(ska, C) | 71 B | ASN.1 DER 鐨勪袱涓?256-bit 鏁存暟 + 缁撴瀯澶?|

- 浼氳瘽瀵嗛挜 `k=622422ca19bc93c88d234d71b621b8cf`锛堝彂閫佹柟瀛?`alice/k.txt` 澶囨牳锛岃 3.2锛夈€?- 绛惧悕瀵硅薄鏄?*瀵嗘枃 C**锛堥闈?`Sm2Sign(SKa,C)`锛夛紝涓嶆槸鏄庢枃鈥斺€旈獙绛炬椂鐐瑰繀椤讳竴鑷淬€?
## 3.2 Bob 渚э細楠岀 + 瑙ｄ俊灏侊紙鉁?瀹炴祴锛?
```
$ cat bob/pka.pub
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoEcz1UBgi0DQgAESMNMMJOg+dJEe7bdPDxGTtbdLavq
MSwJK1tft7lv7obe/xjQ53vVSq5H7GbsxtoAqRoob4qXPexFjeqbyZTuyw==
-----END PUBLIC KEY-----
$ openssl pkeyutl -verify -in bob/C.txt -pubin -inkey bob/pka.pub -rawin -digest sm3 -sigfile bob/S1.bin
Signature Verified Successfully
$ openssl pkeyutl -decrypt -in bob/KC.bin -inkey bob/skb.key -out bob/k_recv.txt
$ cat bob/k_recv.txt
622422ca19bc93c88d234d71b621b8cf
$ diff alice/k.txt bob/k_recv.txt && echo 'k涓€鑷达細淇″皝閲岀殑浼氳瘽瀵嗛挜琚獴ob姝ｇ‘鍙栧洖'
k涓€鑷达細淇″皝閲岀殑浼氳瘽瀵嗛挜琚獴ob姝ｇ‘鍙栧洖
$ krecv=$(cat bob/k_recv.txt)
$ openssl enc -sm4-cbc -d -K $krecv -iv 00000000000000000000000000000000 -in bob/C.txt -out bob/recv_plain.txt
$ cmp alice/plain.txt bob/recv_plain.txt && echo '淇″皝闂幆锛欱ob瑙ｅ嚭鏄庢枃=Alice鍘熸枃'
淇″皝闂幆锛欱ob瑙ｅ嚭鏄庢枃=Alice鍘熸枃
```

瀵圭収棰橀潰 Bob 鐨勪笁姝ワ細`Sm2Verify(PKa, C, S1)` 鎴愬姛 鈫?`Sm2Dec(Skb, KC)=k`
锛堜笌 Alice 渚?`alice/k.txt` **閫愬瓧绗︿竴鑷?*锛夆啋 `Sm4Dec(k, C)=P`锛堜笌 `alice/plain.txt` 閫愬瓧鑺備竴鑷达級銆?
## 3.3 闂涓庡弽鎬?
1. **鍗忚鏈畾涔夌殑涓や釜鐐癸紝鏈疄楠屾樉寮忚ˉ鍏ㄥ苟鍐欐**锛氣憼 SM4-CBC 鐨?IV 鍥哄畾鍏ㄩ浂锛?   鈶?鍏挜 `pka.pub` 璧般€屽崗璁鎻愬墠浜ゆ崲銆嶃€備袱鏉￠兘鍐欐槑锛屼笉闈犲績鐓т笉瀹ｏ紝鍚屽/鑰佸笀澶嶆牳鍙鐜般€?2. **鍥涚被瀵嗛挜鍔ㄤ綔鐨勬柟鍚戞€?*锛氬姞瀵嗙敤**瀵规柟**鍏挜锛圞C 鐢?Bob 鍏挜锛夛紝瑙ｅ瘑鐢?*鑷繁**绉侀挜
   锛圔ob 瑙?KC锛夛紱绛惧悕鐢?*鑷繁**绉侀挜锛圫1 鐢?Alice 绉侀挜锛夛紝楠岀鐢?*瀵规柟**鍏挜銆?   鏀惧弽浠讳綍涓€姝ョ珛鍒诲け璐モ€斺€旇繖鏄潪瀵圭О瀵嗙爜鐨勪袱涓や簰琛ャ€?3. **淇″皝闂幆鐨勫弻閲嶉獙璇?*锛歚diff k` 璇佹槑銆屼細璇濆瘑閽ユ纭氦杈惧鏂广€嶏紝
   `cmp plain` 璇佹槑銆屾槑鏂囧唴瀹瑰埌瀵规柟銆嶃€備袱澶勯兘涓€鑷存墠鍙俊灏侀棴鍚堬紙璁板綍閲屼袱琛?echo 閮芥墦鍑轰簡锛夈€?4. 绛惧悕瀵硅薄鏄瘑鏂?C 鑰岄潪鏄庢枃锛欿erckhoffs 鍘熷垯涓嬬鍚嶄笉鏆撮湶鏄庢枃鍐呭锛屽悓鏃朵篃闃?C鈫扨' 鐨?   鏇挎崲鏀诲嚮銆備换鍔♀憼 绡℃敼璐熶緥锛?.5/2.3锛夊凡楠岃瘉锛欳 鎴?S1 浠讳竴琚敼锛岄獙绛惧嵆澶辫触銆

