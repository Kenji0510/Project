const express = require('express');
const app = express();

const bodyParser = require('body-parser');
const mysql = require('mysql');
require('date-utils');

// MySQLへのアクセス情報(ログイン処理)
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'EC2_Ubuntu',
    password: 'Kenji0510!',
    database: 'LoginTest01'
});

// MySQLへのアクセス情報(メッセージ登録処理)
const connection2 = mysql.createConnection({
    host: 'localhost',
    user: 'EC2_Ubuntu',
    password: 'Kenji0510!',
    database: 'ChatApli01'
})

app.use(bodyParser.json());
app.use(express.static('public'));
app.use(express.urlencoded({extended: false}));


// ユーザ登録フォームを送信
app.get('/createUser', (req, res) => {
    res.render('registrationUser.ejs');
    console.log('registrationUser.ejs accessed!');
});

async function registationUser(req) {
    // 非同期処理で`LoginTable`の行数をカウント（１番はじめに実行！）
    const data = await new Promise((resolve, reject) => {
        connection.query(
            'SELECT count(Number) FROM `LoginTable`',
            (error, results) => {
                if (!results[0]) {
                    console.log("Nullエラー（行数カウント失敗）");
                    console.log(error);
                } else {
                    // 正常処理
                    // 非同期処理でデータ返す
                    resolve(results[0]['count(Number)']);
                }
            }
        )
    })

    // 現在時刻取得
    var dt = new Date();
    date = dt.toFormat("YYYY-MM-DD HH24:MI:SS");

    const queryRes = await new Promise((resolve, reject) => {
        // 登録フォームからのユーザ情報を表：`LoginTable`に登録
        connection.query(
            'INSERT INTO `LoginTable` VALUES (?, "'+date+'", \'{"LoginID": '+JSON.stringify(req.body.LoginID)+', "Password": '+JSON.stringify(req.body.Password)+'}\')',
            [data + 1],
            (error, results) => {
                if(error){
                    connection.end()
                    console.log(error);
                    reject("Registration Error!");
                } else {
                    // 正常処理
                    console.log("Successful registration of UserData");
                    resolve("Registration Successed!");
                }
            }
        )
    })
    // 登録処理の結果を返す
    return queryRes;

}

// ユーザ登録フォームからのユーザ情報を受信
app.post('/registrationUser', (req, res) => {
    // 登録フォームからのユーザ情報を登録
    let queryRes = registationUser(req);
    
    if (queryRes === "Registration Error!") {
        // ユーザ登録処理の結果がエラー時の処理
        res.send("Registration Error!");
    } else {
        res.send("Registration Successed!");
    }

    //res.end();
});

// Swiftからのログイン情報を受信する処理
app.post('/login', (req, res) => {
    var resJSON;

    connection.query(
        'SELECT * FROM `LoginTable` WHERE LoginInfo->"$.LoginID"=? AND LoginInfo->"$.Password"=?',
        [req.body.LoginID, req.body.Password],
        (error, results) => {
            // ログインの判定
            if (!results[0]){
                console.log("ログイン失敗");
                resJSON = {"LoginCheck": "Login unsuccessed!"};
                // Swiftへログイン結果を送信
                res.send(resJSON);
                console.log(error);
            } else {
                // ログイン成功の処理
                console.log("ログイン成功！");
                resJSON = {"LoginCheck": "Login successed!"};
                // Swiftへログイン結果を送信
                res.send(resJSON);
                console.log(results[0]);
            }
        }
    );
    //console.log(JSON.stringify(req.body));
    
});

// SwiftへChatメッセージを送信する処理(返信)
app.post('/getMessage', (req, res) => {
    
    connection2.query(
        //'SELECT * FROM `ChatTable` WHERE MessageInfo->"$.LoginID"=?'
        'SELECT * FROM `ChatTable` WHERE MessageInfo->"$.LoginID" = "murase" ORDER BY Number desc'
        ,
        [req.body.LoginID],
        (error, results) => {
            // 例外判定（指定したLoginIDがない場合）
            if (!results[0]){
                console.log("指定したLoginIDがありません")
                console.log(error);
            } else {
                // 正常処理
                //console.log(results[0].MessageInfo)
                var resBody = results[0].MessageInfo
                res.send(resBody)
            }
        }
    )
})

// 表：ChatTableにメッセージを登録する関数
async function dataRegistration(req) {
    // 非同期処理でChatTableの行数をカウント（１番始めに実行！！）
    const data = await new Promise((resolve, reject) => {

        connection2.query(
            'SELECT count(Number) FROM `ChatTable`',
            (error, results) => {
                if (!results[0]){
                    console.log("Nullエラー（行数カウント失敗）");
                    console.log(error);
                } else {
                    // 正常処理
                    // 非同期処理でデータ返す
                    resolve(results[0]['count(Number)']);
                }
            }
        )}
    );

    // 現在時刻取得
    var dt = new Date();
    date = dt.toFormat("YYYY-MM-DD HH24:MI:SS");
    
    // Swiftからのメッセージデータを表：ChatTableに格納
    connection2.query(
        'INSERT INTO `ChatTable` VALUES (?, "'+date+'", \'{"LoginID": '+JSON.stringify(req.body.LoginID)+', "MessageData": '+JSON.stringify(req.body.MessageData)+'}\')',
        [data + 1],
        (error, results) => {
            if (error){
                connection2.end()
                //console.log("SQLエラー");
                console.log(error);
            } else {
                // 正常処理
                console.log("Successful registration of data");
            }
        }
    )

}

// SwiftからChatメッセージを保存する処理
app.post('/postMessage', (req, res) => {
    
    console.log(req.body);
    // 表：ChatTableにメッセージを登録する関数
    dataRegistration(req);
    
   res.end()
})

app.listen(3000, () => {

});