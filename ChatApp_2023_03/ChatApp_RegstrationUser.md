# SwiftでChatアプリの開発(新規ユーザ登録機能編)


## できること
SwiftでSafariブラウザをアプリ内で起動し、そこからユーザ登録サイトにアクセスする。
そして、ユーザ登録できるようにする


## 実行環境
- AWS EC2 Ubuntu
- XCode


## プロジェクト名
### Swiftファイル
ChatApp_RegstrationUser


### サーバ側コード
/home/ubuntu/Workspace/LoginServer_fromSwift/app.js     (EC2のUbuntu上で実行)


## 新規ユーザ登録処理について
### 登録フォームについて
- 登録フォームのファイル  
/home/ubuntu/Workspace/LoginServer_fromSwift/views/registrationUser.ejs
- アクセス先  
http://[サーバのIP]:3000/createUser


#### 新規ユーザ情報送信について
- 送信先  
http://[サーバのIP]:3000/registrationUser
- 送信データ  
LoginID, Password


## データベースの設計
### データベースのアクセス方法
host: 'localhost',
user: 'EC2_Ubuntu',
password: 'Kenji0510!',
database: 'LoginTest01'


### ChatTable(表)の構成（列について）
- Number  
データベース登録順序の番号
主キー
- RegistrationDate  
データベースへのデータ登録日時
型：YYYY-MM-DD oo:mm:ss

以下はJSON形式
- LoginID  
登録者を識別する要素
- Password  
パスワード


### データベースの階層
database: 'LoginTest01'
table: 'LoginTable'


## テストユーザ情報
### ユーザ1
- LoginID（ユーザ名）  
kenji
- Password（パスワード）  
toire

### ユーザ2
- LoginID（ユーザ名）  
murase
- Password（パスワード）  
poteti


## 進行状況
- 2023/03/23  
新規ユーザ登録機能の実装完了


## SQL文メモ
- 例  
INSERT INTO `LoginTable` VALUES (2, "2023-03-20 21:00:00", '{"LoginID": "murase", "Password": "poteti"}');