# 01 路 浠诲姟鈶?OpenSSL 鐩稿叧鍐呭瀹炶返锛? 鍒嗭級

- **渚濇嵁**锛氶闈㈢ 1 鏉°€屽疄璺佃绋嬫€濈淮瀵煎浘涓?OpenSSL 鐩稿叧鍐呭銆嶃€?  鎬濈淮瀵煎浘閾炬帴锛圥rocessOn锛夌粡鏈汉纭鏃犳湁鐢ㄥ唴瀹癸紝瀹炶返鑼冨洿鎸夐闈㈢偣鍚嶇殑
  OpenSSL 鍩烘湰鐢ㄦ硶瑕嗙洊锛氱増鏈€昏 鈫?闅忔満鏁?鈫?SM3 鈫?SM4 鈫?SM2銆?- **绾緥**锛氬彧璐寸湡瀹炴墽琛岃緭鍑猴紱宸ヤ綔鐩綍涓?VM 鍐?`~/exp1`锛涙瘡瀹屾垚涓€缁勪竴娆?git commit銆?
## 1.1 鐗堟湰鎬昏锛堚渽 瀹炴祴锛?
```
$ openssl version -a | head -4
OpenSSL 3.5.6 7 Apr 2026 (Library: OpenSSL 3.5.6 7 Apr 2026)
built on: Mon Sep  7 03:33:17 2026 UTC
platform: linux-x86_64
options:  bn(64,64)
```

## 1.2 闅忔満鏁帮紙鉁?瀹炴祴锛?
```
$ openssl rand -hex 16
be01d2cdc78c1f4106cd5cb893c6ca9
```

- 32 涓?hex 瀛楃 = 16 瀛楄妭銆傚鐓?00 鑺?GmSSL 渚?  `gmssl rand -hex -outlen 16` 鈫?`C432E97950B3CB75B1E8586C6860C1E0`锛?  涓ゅ伐鍏峰悇鐙珛浜х敓 16 瀛楄妭闅忔満鏁帮紙鏁板瓧淇″皝鐨?SM4 瀵嗛挜灏变粠杩欓噷鏉ワ級銆?
## 1.3 SM3 鎽樿锛歄penSSL 涓?GmSSL 鍙屽紩鎿庡鐓э紙鉁?瀹炴祴锛?
```
$ echo -n '20241422绌嗗紙娑? > t.txt
$ openssl dgst -sm3 t.txt
SM3(t.txt)= dfc1bb19a04773b7b3acbd568ea0a8fec80449510747f40fbeed3bf76ad028ff
$ gmssl sm3 -in t.txt
dfc1bb19a04773b7b3acbd568ea0a8fec80449510747f40fbeed3bf76ad028ff
```

- 鍏堟寜鏃ф枃妗?`gmssl sm3 t.txt` 浼氭姤 `sm3: illegal option 't.txt'`锛堣 1.7锛夈€?  鏌ユ簮鐮?`tools/sm3.c` usage锛坄[-hex|-bin] [-pubkey pem [-id str]] [-in file|-in_str str] [-out file]`锛?  鏀圭敤 `-in file` 鍚庯紝杈撳嚭涓?OpenSSL 鐨?`dgst -sm3` **閫愬瓧绗︿竴鑷?*
  `dfc1bb19鈥d028ff`鈥斺€斾袱濂楃嫭绔嬪疄鐜颁簰璁わ紝鍚岃緭鍏ュ繀鍚岃緭鍑恒€?
## 1.4 SM4-CBC 鍔犺В瀵嗗線杩旓紙鉁?瀹炴祴锛?
```
$ K=$(openssl rand -hex 16); IV=$(openssl rand -hex 16); echo "K=$K"; echo "IV=$IV"; echo "K浣嶆暟:${#K} IV浣嶆暟:${#IV}"
K=c24ee3476d8fec90dd06d714234b76ff
IV=3719a9fa0dafa1c3dc0be2fd72f5b209
K浣嶆暟:32 IV浣嶆暟:32
$ echo -n '20241422绌嗗紙娑?鏄庢枃娴嬭瘯' > plain1.txt; wc -c plain1.txt
30 plain1.txt
$ openssl enc -list | grep sm4
-sm4                       -sm4-cbc                   -sm4-cfb
-sm4-ctr                   -sm4-ecb                   -sm4-ofb
$ openssl enc -sm4-cbc -K $K -iv $IV -in plain1.txt -out sm4c.bin
$ wc -c sm4c.bin
32 sm4c.bin
$ openssl enc -sm4-cbc -d -K $K -iv $IV -in sm4c.bin -out sm4out.txt
$ cmp plain1.txt sm4out.txt && echo 瑙ｅ瘑涓€鑷?瑙ｅ瘑涓€鑷?$ od -A d -t x1 sm4c.bin
0000000 84 7e a9 b9 25 ec 27 6e 69 e2 ab ac 64 dc 67 23
0000016 37 bd bf bf 9e 6f 50 82 d9 59 bd 37 1e c2 21 19
```

- 鏄庢枃 30 瀛楄妭銆佸瘑鏂?32 瀛楄妭锛?*PKCS#7 琛ラ綈 2 瀛楄妭锛堝€?0x02锛?*銆?  琛ラ綈鍊煎湪瀵嗘枃閲屼笉鍙洿鎺ヨ瀵燂紝鐢?30鈫?2 鐨勯暱搴﹀樊涓庡垎缁勫搴?16 鎺ㄥ緱銆?- K銆両V 鍧囨潵鑷?`openssl rand -hex 16`锛屽悇 32 涓?hex 瀛楃锛?6 瀛楄妭锛夈€?
## 1.5 SM2 瀵嗛挜鐢熸垚涓庣鍚嶉獙绛撅紙鉁?瀹炴祴锛?
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
$ echo -n '20241422绌嗗紙娑?绡℃敼' > t2.txt
$ openssl pkeyutl -verify -in t2.txt -pubin -inkey sm2a.pub -rawin -digest sm3 -sigfile t.sig; echo "璐熶緥exit=$?"
Signature Verification Failure
80B0D911227F0000:error:030000EA:digital envelope routines:EVP_DigestVerifyFinal:provider signature failure:crypto/evp/m_sigver.c:701:SM2 digest_verify_final:
璐熶緥exit=1
```

- SM2 瀵嗛挜 256 bit锛堟洸绾?sm2p256v1 榛樿锛夈€俙genpkey -algorithm SM2` 涓€姝ョ敓鎴愮閽ワ紝
  `pkey -pubout` 瀵煎嚭鍏挜銆?- 绛惧悕锛歚pkeyutl -sign -rawin -digest sm3`锛涢獙绛惧悓鍙傛暟鎹㈠叕閽ャ€?  SM2 绠楁硶瑕佹眰甯?*鐢ㄦ埛鏍囪瘑 distid**鈥斺€旀澶勬湭鏄惧紡鎸囧畾锛孫penSSL 鐢ㄥ唴缃粯璁?  `1234567812345678`锛岀鍚嶄笌楠岀鍚屽€兼墍浠ユ垚鍔熴€傛暟瀛椾俊灏侀噷寤鸿鏄惧紡鍐欏畾锛屼袱杈逛竴鑷淬€?- **绡℃敼璐熶緥**锛氬鍐呭鏀瑰姩鍚庣殑鏂囦欢楠屽悓涓€绛惧悕 鈫?`Signature Verification Failure`锛?  `exit=1`銆傝瘉鏄庣鍚嶇‘瀹炵粦瀹氬師鏂囷紙瀹屾暣鎬?+ 璁よ瘉鎬э級銆?
## 1.6 SM2 鍔犺В瀵嗭紙鉁?瀹炴祴锛?
```
$ openssl genpkey -algorithm SM2 -out sm2b.key
$ openssl pkey -in sm2b.key -pubout -out sm2b.pub
$ openssl rand -out k16.bin 16
$ openssl pkeyutl -encrypt -in k16.bin -inkey sm2b.pub -pubin -out k16.enc
$ openssl pkeyutl -decrypt -in k16.enc -inkey sm2b.key -out k16.dec
$ cmp k16.bin k16.dec && echo SM2鍔犺В瀵嗕竴鑷?SM2鍔犺В瀵嗕竴鑷?```

- `sm2b` 璧枫€孊ob 閭ｆ妸瀵嗛挜銆嶇殑浣滅敤锛?*鐢ㄥ叕閽ュ姞瀵嗐€佺閽ヨВ瀵?*鈥斺€擿sm2b.pub` 鍔犲瘑
  鈫?`sm2b.key` 瑙ｅ瘑锛屽線杩斾竴鑷淬€傝繖姝ｆ槸鏁板瓧淇″皝閲屻€岀敤 Bob 鍏挜鍔犲瘑浼氳瘽瀵嗛挜銆嶇殑鍘熷瓙鎿嶄綔銆?- 鏄庢枃杩欓噷鏄?16 瀛楄妭闅忔満锛堟ā鎷熷绉板瘑閽ワ級锛屽姞瑙ｅ瘑鍚庨€愬瓧鑺備竴鑷达紙`k16.bin / k16.enc / k16.dec`锛夈€?
## 1.7 浠诲姟鈶?灏忕粨涓庨棶棰?
1. **`gmssl sm3` 鏂版棫璇硶宸紓**锛氭寜鏃ф枃妗?`gmssl sm3 t.txt` 鎶?   `sm3: illegal option 't.txt'` 鈫?璇?`tools/sm3.c` usage 瀹氫綅涓?   `-in file` 褰㈠紡銆?*涓?00 鑺傞棶棰?2 鍚屾簮锛欸mSSL 3.x 鍏ㄩ潰鏀逛簡鍛戒护琛岄€夐」椋庢牸锛?   鍑￠闈?鏃ф暀绋嬬粰鐨?gmssl 鍛戒护閮借鍏堝 3.2.0 婧愮爜鏍稿銆?*



