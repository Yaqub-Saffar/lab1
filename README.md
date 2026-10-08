# 銆婂瘑鐮佺郴缁熻璁°€嬪疄楠屼竴 路 宓屽叆寮忓紑鍙戝熀纭€

- **瀛﹀彿 / 濮撳悕**锛?0241422 绌嗗紙娑碉紙Alice锛?- **鎼。**锛?0241412 榄忕户鍗氾紙Bob锛?- **鐜**锛歰penEuler 24.03 LTS锛圴Mware 铏氭嫙鏈猴紝鍥惧舰鐣岄潰锛?- **鏈鑼冨洿**锛?-3 瀛︽椂瀹炶返瑕佹眰锛?0 鍒嗭級

## 浠诲姟涓庡垎鍊硷紙1-3 瀛︽椂锛?
| # | 浠诲姟 | 鍒嗗€?| 鐘舵€?| 璁板綍 |
| --- | --- | --- | --- | --- |
| 1 | OpenSSL 鐩稿叧鍐呭瀹炶返锛堥€愰」 git commit锛?| 5' | 猬?| `docs/01-openssl鍛戒护瀹炶返.md` |
| 2 | GmSSL 鐩稿叧鍐呭瀹炶返锛堥€愰」 git commit锛?| 5' | 猬?| `docs/02-gmssl鍛戒护瀹炶返.md` |
| 3 | OpenSSL 鍛戒护瀹炵幇甯︾鍚嶇殑鏁板瓧淇″皝锛圓lice 鍙?鈫?Bob 鏀讹級 | 10' | 猬?| `docs/03-鏁板瓧淇″皝-openssl.md` |
| 4 | GmSSL 鍛戒护瀹炵幇甯︾鍚嶇殑鏁板瓧淇″皝锛圔ob 鍙?鈫?Alice 鏀讹級 | 10' | 鉁?| `docs/04-鏁板瓧淇″皝-gmssl.md`锛堣剼鏈?`scripts/task4-envelope-gmssl.sh`锛?|
| 5 | gitee/github 璇剧▼椤圭洰閾炬帴 + `git log` 缁撴灉 | 鈥?| 猬?| `README.md` 鏈妭 |
| 6 | 瀹炶返杩囩▼ Markdown + 杞寲 PDF | 鈥?| 猬?| `README.md` + 鏍圭洰褰?PDF |

4-6 瀛︽椂锛堝簱缂栫▼ + 搴撶増鏁板瓧淇″皝锛屽彟 30 鍒嗭級涓庡疄楠屾姤鍛婏紙10 鍒嗭級涓嶅湪鏈鑼冨洿銆?
## 鏁板瓧淇″皝鍗忚锛堥闈㈠師鏍凤紝涓よ竟鍚屼竴鍗忚銆佹柟鍚戠浉鍙嶏級

韬唤鏇挎崲锛欰lice = `20241422绌嗗紙娑礰锛孊ob = `20241412榄忕户鍗歚銆?
- 鏄庢枃 `plain.txt` = Alice 鐨勫鍚嶅鍙?- Alice锛歚k = gmssl rand` 浜х敓 16 瀛楄妭 SM4 瀵嗛挜
- Alice锛歚Sm4Enc(k, P) = C`
- Alice锛歚Sm2Enc(PKb, k) = KC`
- Alice锛歚Sm2Sign(SKa, C) = S1`
- Alice 鈫?Bob锛氭暟瀛椾俊灏?`C || KC || S1`
- Bob锛歚Sm2Verify(PKa, S1)` 鈫?`Sm2Dec(SKb, KC) = k` 鈫?`Sm4Dec(k, C) = P`

浠诲姟 3 鐢?OpenSSL 鍛戒护锛圓lice 鍙戯級锛涗换鍔?4 鐢?GmSSL 鍛戒护锛圔ob 鍙戯級銆?
## 鐩綍缁撴瀯

```
瀹為獙涓€/
鈹溾攢鈹€ README.md            鏈枃浠讹細浠诲姟琛ㄣ€佸崗璁€乬it log銆佷粨搴撻摼鎺?鈹溾攢鈹€ docs/
鈹?  鈹溾攢鈹€ 00-鐜鎼缓.md    绯荤粺淇℃伅銆丱penSSL/GmSSL 瀹夎銆丳S1 瀛﹀彿姘村嵃
鈹?  鈹溾攢鈹€ 01-openssl鍛戒护瀹炶返.md
鈹?  鈹溾攢鈹€ 02-gmssl鍛戒护瀹炶返.md
鈹?  鈹溾攢鈹€ 03-鏁板瓧淇″皝-openssl.md
鈹?  鈹斺攢鈹€ 04-鏁板瓧淇″皝-gmssl.md
鈹溾攢鈹€ scripts/setup-vm.sh   VM 涓€娆℃€х幆澧冨噯澶囪剼鏈?鈹溾攢鈹€ screenshots/          瀹炴搷鎴浘锛圥S1 甯﹀鍙锋按鍗帮級
鈹斺攢鈹€ artifacts/            瀵嗛挜/瀵嗘枃绛夎繃绋嬬墿锛?gitignore锛屼笉鍏ュ簱锛?```

## 鎻愪氦瑕佹眰瀵圭収锛堥闈㈢ 6 鏉★級

- [ ] 瀹炶返杩囩▼ Markdown + 杞寲 PDF
- [ ] 浠ｇ爜涓庢枃妗ｆ墭绠″埌 gitee/github锛堥摼鎺ヨ涓嬶級
- [ ] 璁板綍閬囧埌鐨勯棶棰樸€佽В鍐宠繃绋嬨€佸弽鎬?鈫?鍚?`docs/*.md` 鐨勩€岄棶棰樹笌鍙嶆€濄€嶈妭 + 鎶ュ憡
- [ ] `git log` 杩愯缁撴灉 鈫?瑙佷笅
- [ ] 姣忓畬鎴愪竴椤逛竴娆?commit

## 璇剧▼椤圭洰閾炬帴

- GitHub 浠撳簱锛歚https://github.com/Yaqub-Saffar/lab1`
- 鎻愪氦鐗╋細README + `docs/`锛堝疄璺靛懡浠や笌鍙嶆€濓級+ `scripts/`锛堝鐜拌剼鏈級+ `screenshots/`
- 鈿狅笍 `artifacts/`銆乣_wip/`銆乣*.key` 琚?`.gitignore` 鎺掗櫎锛屽瘑閽?杩囩▼鐗╀笉鍏ュ簱

## Git log 运行结果

锛堟敹灏炬椂鍥炲～ `git log --oneline` 杈撳嚭锛?


376fbca [exp1] README 回填课程项目链接 + 删除来历不明的 pka.pub
571a3d3 [exp1] 任务④ GmSSL 数字信封落册：Bob 发→Alice 收，信封闭环
695dcdf [exp1] 任务③ 收口：Bob 侧验签/解k/解明三重闭环，3.3 四条反思（IV与公钥分发补全、密钥方向性、双闭环校验）
2f1e59e [exp1] 任务③ Alice 侧信封落册：C/KC/S1 尺寸来历逐项有据（17→32, 139, 71）
c06087e [exp1] 任务② GmSSL 实践落册（01-02 小节 1.3 补充后，共 13 图清单定稿）
61ea95e [exp1] 任务① SM2 落册 + 截图清单定死（图01-13）
6f3aab8 [exp1] 任务① OpenSSL 实践 1.1-1.4 落册：版本/随机数/SM3对照/SM4-CBC往返
e678348 [exp1] 00-环境搭建 收口：GmSSL 3.2.0 官方源码编译完成，环境全绿
2562f28 [exp1] 00-环境搭建 回填实测：openEuler 24.03 LTS-SP4 / UKUI / OpenSSL 3.5.6
c335238 [exp1] 钉死行尾：*.sh 强制 LF，防止入 VM 后 CRLF 报错
f254fad [exp1] 初始化实验一目录结构与环境准备脚本




