# 02 路 浠诲姟鈶?GmSSL 鐩稿叧鍐呭瀹炶返锛? 鍒嗭級

- **渚濇嵁**锛氶闈㈢ 2 鏉°€屽疄璺佃绋嬫€濈淮瀵煎浘涓?GmSSL 鐩稿叧鍐呭銆嶃€?- 鐜锛欸mSSL 3.2.0锛?0 鑺傜紪璇戝畨瑁呰嚜瀹樻柟 v3.2.0 tarball锛夈€?- **閲嶈鍓嶇疆**锛欸mSSL 3.2.0 鍛戒护琛屼笌鏃х増/鏂囨。宸紓宸ㄥぇ锛坄-hex`/`-outlen`/`-in file`銆?  `sm2keygen` 寮哄埗 `-pass`銆丼M4 鍛戒护涓?`sm4_cbc` 绛夛級锛屾墍鏈夊懡浠ゅ潎鍏堝 3.2.0 婧愮爜
  `tools/*.c` 鐨?usage 鏍稿鍐嶆墽琛屻€?- 宸ヤ綔鐩綍锛歏M 鍐?`~/exp1`銆?
## 2.1 鐗堟湰涓庢湰濂椾欢鑳藉姏锛堚渽 瀹炴祴锛?
```
$ gmssl version
GmSSL 3.2.0
```

## 2.2 SM4-CBC 鍔犺В瀵嗗線杩旓紙鉁?瀹炴祴锛?
```
$ K2=$(gmssl rand -hex -outlen 16); IV2=$(gmssl rand -hex -outlen 16); echo "K2=$K2"; echo "IV2=$IV2"
K2=92B3C883C0B6BE0454775B92EC9F9D180
IV2=B2B8C5E71CE838D0AA192AEF819F7E24
$ echo -n '20241422绌嗗紙娑?鏄庢枃娴嬭瘯' > plain2.txt; wc -c plain2.txt
30 plain2.txt
$ gmssl sm4_cbc -encrypt -key $K2 -iv $IV2 -in plain2.txt -out sm4c2.bin
$ wc -c sm4c2.bin
32 sm4c2.bin
$ gmssl sm4_cbc -decrypt -key $K2 -iv $IV2 -in sm4c2.bin -out sm4out2.txt
$ cmp plain2.txt sm4out2.txt && echo 'GmSSL SM4 瑙ｅ瘑涓€鑷?
GmSSL SM4 瑙ｅ瘑涓€鑷?```

- 涓?1.4锛圤penSSL锛夊畬鍏ㄥ悓鍙傛暟锛歅KCS#7 琛ラ綈锛?0 瀛楄妭鏄庢枃 鈫?32 瀛楄妭瀵嗘枃锛孋BC+16 瀛楄妭 IV銆?- 娉ㄦ剰璇硶锛歚gmssl sm4_cbc -encrypt|-decrypt -key <hex> -iv <hex>`锛孠/IV 鍧囦负 32 瀛?hex銆?
## 2.3 SM2 瀵嗛挜鐢熸垚涓庣鍚嶉獙绛撅紙鉁?瀹炴祴锛?
```
$ gmssl sm2keygen -pass 123456 -out bob.key -pubout bob.pub
$ cat bob.pub
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoEcz1UBgi0DQgAEuuXXZjPtdq/tVvDb50j1GiPPaTUG
0Ohadp1L9E26EG1v2bKZB4q/iBnr0dumD3uEX7f1Z3SscUoPRTnQjMAcQA==
-----END PUBLIC KEY-----
$ echo -n 'GmSSL绛惧悕娑堟伅' > msg.txt
$ gmssl sm2sign -key bob.key -pass 123456 -id 1234567812345678 -in msg.txt -out msg.sig
$ gmssl sm2verify -pubkey bob.pub -id 1234567812345678 -in msg.txt -sig msg.sig
verify : success
$ echo -n 'GmSSL绡℃敼娑堟伅' > msg2.txt
$ gmssl sm2verify -pubkey bob.pub -id 1234567812345678 -in msg2.txt -sig msg.sig; echo "璐熶緥exit=$?"
/home/20241422myh/GmSSL-3.2.0/src/sm2_sign.c:265:sm2_fast_verify():
/home/20241422myh/GmSSL-3.2.0/src/sm2_sign.c:671:sm2_verify_finish():
gmssl sm2verify: inner error
璐熶緥exit=1
```

- 鍏挜 PEM 绠楁硶 OID 涓?`1.2.156.10197.1.301`锛堝浗瀵?SM2 妞渾鏇茬嚎 sm2p256v1锛?  ASN.1 閲屽舰濡?`YIKoEcz1UBgi0DQgAE`锛夛紝涓?OpenSSL `genpkey -algorithm SM2` 鍚屼竴鏉℃洸绾裤€?- 绛惧悕甯?*鐢ㄦ埛鏍囪瘑 distid**锛歚-id 1234567812345678`锛岀楠屽悓鍊兼墠鎴愬姛锛屼笌 1.5 缁撹浜掕瘉銆?- 绡℃敼璐熶緥锛欸mSSL 鎶ラ敊褰㈡€佷笌 OpenSSL 涓嶅悓鈥斺€斾笉杈撳嚭 `Signature Verification Failure`锛?  鑰屾槸**鍐呴儴閿欒 + 婧愮爜琛屽彿**锛坄sm2_sign.c:265/671`锛夛紝浣嗚涔変竴鑷达細**楠岃瘉澶辫触锛宔xit=1**銆?
## 2.4 SM2 鍔犺В瀵嗗線杩旓紙鉁?瀹炴祴锛?
```
$ gmssl rand -outlen 16 -out k16b.bin            # 浜岃繘鍒?16 瀛楄妭闅忔満
$ gmssl sm2encrypt -pubkey bob.pub -in k16b.bin -out k16b.enc
$ gmssl sm2decrypt -key bob.key -pass 123456 -in k16b.enc -out k16b.dec
$ cmp k16b.bin k16b.dec && echo 'GmSSL SM2 鍔犺В瀵嗕竴鑷?
GmSSL SM2 鍔犺В瀵嗕竴鑷?$ wc -c k16b.bin k16b.enc
 16 k16b.bin
123 k16b.enc
139 鎬昏
```

- 鍏挜鍔犲瘑 / 绉侀挜瑙ｅ瘑寰€杩斾竴鑷达紱锛堝姣?1.6锛歄penSSL 鐩稿悓杈撳叆涔熷緱鍒?**16鈫?23 瀛楄妭**锛?  涓や釜鐙珛瀹炵幇 SM2 瀵嗘枃灏哄瀹屽叏鐩稿悓 鈫?鏁板瓧淇″皝閲屾瘡浠?KC 鐨勫浐瀹氬紑閿€ 107 瀛楄妭鍙鐭ワ級銆?
## 2.5 OpenSSL 涓?GmSSL 鍏抽敭瀵圭収锛堜换鍔♀憼鈫斾换鍔♀憽锛?
| 鑳藉姏 | OpenSSL 3.5.6 | GmSSL 3.2.0 | 缁撹 |
| --- | --- | --- | --- |
| SM3 | `dgst -sm3` | `sm3 -in` | 鍚屾憳瑕?`dfc1bb19鈥 |
| SM4-CBC | `enc -sm4-cbc -K -iv` | `sm4_cbc -encrypt -key -iv` | 鍚屽弬鏁帮紝30鈫?2 瀛楄妭 |
| SM2 瀵嗛挜 | `genpkey -algorithm SM2` | `sm2keygen -pass` | 鍚屾洸绾?sm2p256v1 |
| SM2 绛惧悕 | `pkeyutl -sign/-verify -rawin -digest sm3` | `sm2sign/sm2verify -id` | 鍧囬獙绛炬垚鍔燂紱绡℃敼鍧囧け璐?exit=1 |
| SM2 鍔犲瘑 | `pkeyutl -encrypt/-decrypt` | `sm2encrypt/sm2decrypt` | 鍧囦负 16鈫?23 瀛楄妭 |
| 闅忔満鏁?| `openssl rand -hex 16` | `gmssl rand -hex -outlen 16` | 鍧囦骇 16 瀛楄妭 |

- 宸紓锛欸mSSL 瀵嗛挜寮哄埗鍙ｄ护 AE 鍔犲瘑瀛樺偍锛坄-pass`锛夛紱distid 蹇呴』鏄惧紡/鍚屽€硷紱鎶ラ敊甯︽簮鐮佽鍙枫€?- **涓嶅仛涓や釜寮曟搸涔嬮棿鐨勬贩鍚堝姞瑙ｅ瘑/楠岀浜掓搷浣?*鈥斺€斾袱濂楀伐鍏峰悇鑷棴鐜紝璺ㄥ簱鏍煎紡鍏煎鏄彟涓€涓棰樸€?
## 2.6 闂涓庡弽鎬?
1. GmSSL 3.2.0 涓庢枃妗ｅ懡浠ゅ樊寮傞泦涓垎鍙戯紙鍚?00 鑺傞棶棰?2銆?1 鑺傞棶棰?1 鍚屾簮锛夛細**鍑?GmSSL
   鍛戒护涓€寰嬪厛璇?`tools/*.c` usage**锛屾湰浠诲姟 8 鏉″懡浠ゅ叏閮ㄦ寜婧愮爜鏍稿鍚庝竴娆℃垚鍔熴€?2. 绡℃敼璐熶緥鐨勬姤閿欎笉鍚岋細OpenSSL 璧?EVP 鎶?`Signature Verification Failure`锛?   GmSSL 璧板唴閮?`inner error + src/sm2_sign.c:琛屽彿`銆?*楠岃瘉澶辫触鐨勫垽瀹氫緷鎹兘鏄?exit code=1**锛?   鎶ラ敊鏂囨涓嶈兘褰撹嚜鍔ㄥ寲鍒ゆ嵁鈥斺€旇繖涔熸槸瀹為獙缁撹涔嬩竴锛氳剼鏈牎楠屽繀椤荤湅杩斿洖鍊艰€岄潪 stderr銆?3. 璁板綍鍙ｄ护 `123456` 浠呬负鐣岄潰鍗犱綅锛欸mSSL 绉侀挜鏂囦欢鏈韩灏辨槸鍙ｄ护鍔犲瘑鐨勶紝鏍蜂緥鍙ｄ护瀵?   銆屼竴娆℃€у疄楠屽瘑閽ャ€嶆棤鍗卞锛岀湡瀹炲伐绋嬬閽ラ』鐢ㄥ己鍙ｄ护骞剁绾夸繚瀛樸€

