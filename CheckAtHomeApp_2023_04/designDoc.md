# 再配達減少システムの構築(2023/04/01~)


## できること
利用者（荷物受取人）が在宅しているかをドライバー（配達便の人）が確認できる。
また、できるだけプライバシー考慮


## 実行環境
- 自宅サーバ(Ubuntu22.04のNode.js)  
- XCode  


## プロジェクト名
### 利用者側のSwiftファイル
<!-->
- 利用者スマホ側アプリ  
CheckAtHome_App
<-->

- Corebluetoothを使用したBLEプロジェクトコード  
  - SwiftUI_CoreBLE  (2023/04/03)  
  SwiftUIでBluetoothが使用できるかの確認プロジェクト
  - SwiftUI_CoreBLE2  (2023/04/04~04/05)  
  スマホからサーバへHTTP通信でデバイス情報を送信できるかの確認プロジェクト
  - SwiftUI_CoreBLE3  (2023/04/05~)  
  スマホにBLEペリフェラルのデバイス情報を登録できるかの確認プロジェクト
  - SwiftUI_CoreBLE4  (2023/04/06~)  
  自動で25分に一度、サーバへ在宅チェックデータを転送する。
  また、バックグラウンド実行できるようにする。(これはできてない)
  自動でペリフェラルの情報を更新できるようになる。
  RSSI取得できた。


### ドライバー側のSwiftファイル
- ドライバースマホ側アプリ  
  - SwiftUI_DriverApp1  
  database: 'CheckAtHome_App'のtable: 'CheckAtHome'の在宅チェックデータベースに問い合わせて、在宅チェックデータをJSONで取得できた。
  そして、在宅or留守で分割して表示し、ユーザ情報の在宅チェックをドライバーが確認できた。


### サーバ側コード
/home/kenji/WorkSpace/CheckAtHome_Project/app.js     (EC2のUbuntu上で実行)


## システム概要
利用者（荷物受取人）のスマホと家に設置しているBLEパケットビーコン（RasPi）とでBLE通信し、在宅かどうかの確認をする。その結果をスマホからサーバへ送信し、ドライバーのスマホに再配達対象の荷物受取人が在宅しているかをお知らせする。

### システム概要図
![システム概要図](./image/fig01.jpg)


## システム処理の流れ（概要図）
### 利用者スマホ側アプリ（IPhone, SwiftUI）
1. BLEビーコン（RasPi）の登録画面でBLE通信するビーコンを登録
2. 25分ごとに登録したBLEビーコンとの通信
  2-1. BLEビーコンとペアリング
  2-2. BLEビーコンから何らかのデータをスマホが受信（在宅確認用）
  2-3. BLEビーコンとのペアリング切断

<br>
一度、BLEビーコンをスマホに登録した後は、「2.」の処理を繰り返し行う。

### サーバ側（Node.js, express）
1. スマホからの利用者の在宅確認データを受信
2. データベースに在宅確認データを登録
3. ドライバーのスマホに対象荷物の再配達が必要or不必要を送信

### ドライバー側アプリ（IPhone, SwiftUI）
1. 定期的にサーバへ再配達必要の確認を行う
2. サーバから対象荷物の再配達が必要or不必要を受信
3. 画面に対象荷物の再配達の必要or不必要を表示


## データベースの設計
### データベースのアクセス方法
host: 'localhost',
user: 'EC2_Ubuntu',
password: 'Kenji0510!',
database: 'CheckAtHome_App'


### データベースの階層
database: 'CheckAtHome_App'
table: 'CheckAtHome'


### CheckAtHome(表)の構成（列について）
- Number  
データベース登録順序の番号
主キー
- RegistrationDate  
データベースへのデータ登録日時
型：YYYY-MM-DD oo:mm:ss
- userName  
利用者の名前
- Address  
利用者の住所

以下はJSON形式
- DeviceInfo  
データベースのJSON形式の大枠
- UserName  
利用者の名前
- UUID  
ペリフェラルのUUID
- DeviceName  
ペリフェラルのデバイス名
- isPeripheral  
ペリフェラルが利用者のスマホの近くにあるか（つまり、在宅かどうか）のチェックデータ
- Address  
利用者の住所情報


## 参考資料
- SwiftでBLE通信  
[URL1](https://zenn.dev/tomo_devl/articles/d58abecf10c599)

- SwiftでJSON配列を扱う方法  
[URL](https://capibara1969.com/2551/)


## 注意事項
- スマホ側（Swift）では、バックグラウンド実行ができる必要あり！  
- BLEビーコンの登録画面作成！  
- グローバルIPでアクセスする際は、ルータのポート開放が必要！！  
これはポート番号:3000で解放済み！

## できたこと
- 2023/04/04  
SwiftUIにてCorebletoothを使用してペリフェラルの情報を取得できた。
- 2023/04/05  
利用者スマホ側からサーバへ在宅チェックのJSONデータ送信し、サーバ側で確認できた。
- 2023/04/05  
利用者スマホ側からの在宅チェックのJSONデータをサーバのデータベースに格納できた。
- 2023/04/05  
利用者スマホ内のファイルに登録するペリフェラルのUUIDを保存することができた。


## データベースのメモ
### データベースへデバイス情報登録用のSQL文
INSERT INTO `CheckAtHome` VALUES (16, "2023-04-07 00:00:00", "Kenji3", "住所１", '{"userName": "Kenji", "UUID": "3C0F1F21-4578-D133-F3BF-060CC0EA9730", "DeviceName": "iPhone", "isPeripheral": "Yes"}');

'INSERT INTO `CheckAtHome` VALUES (?, "'+date+'", \'{"UUID": '+JSON.stringify(req.body.UUID)+', "DeviceName": '+JSON.stringify(req.body.DeviceName)+', "isPeripheral": '+JSON.stringify(req.body.isPeripheral)+'}\')'

### ### データベースへデバイス情報登録用のSQL文("isPeripheral"がbool型に変更)
INSERT INTO `CheckAtHome` VALUES (13, "2023-04-07 00:00:00", "Kenji14", "住所13", '{"userName": "Kenji", "UUID": "3C0F1F21-4578-D133-F3BF-060CC0EA9730", "DeviceName": "iPhone", "isPeripheral": false}');

'INSERT INTO `CheckAtHome` VALUES (?, "'+date+'", \'{"UUID": '+JSON.stringify(req.body.UUID)+', "DeviceName": '+JSON.stringify(req.body.DeviceName)+', "isPeripheral": true}\')'

'INSERT INTO `CheckAtHome` VALUES (?, "'+date+'", ?, ?,\'{"UUID": '+JSON.stringify(req.body.UUID)+', "DeviceName": '+JSON.stringify(req.body.DeviceName)+', "isPeripheral": ?}\')',
            [data + 1, req.body.UserName, req.body.Address, req.body.isPeripheral],

### テーブルに列（カラム）を追加するSQL文
ALTER TABLE `CheckAtHome` ADD Address varchar(255) AFTER UserName;

### UserNameとAddressの組で最新のデータだけ（重複なし）を抽出するSQL文
select max(Number), UserName, Address from `CheckAtHome` group by UserName, Address;

### JSONの列を検索するSQL文
select `DeviceInfo`->"$.isPeripheral" from `CheckAtHome`;

### JSONを対象にSELECT文のSQL文
select max(Number), UserName, Address, `DeviceInfo`->"$.isPeripheral" from `CheckAtHome` group by UserName, Address, DeviceInfo;