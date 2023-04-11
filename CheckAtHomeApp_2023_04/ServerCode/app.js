const express = require('express');
const app = express();

const bodyParser = require('body-parser');
const mysql = require('mysql');
require('date-utils');

app.use(bodyParser.json());
app.use(express.static('public'));
app.use(express.urlencoded({extended: false}));


// MySQLへのアクセス情報(デバイス情報登録＆確認処理)
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'EC2_Ubuntu',
    password: 'Kenji0510!',
    database: 'CheckAtHome_App'
});


// 利用者のデバイス情報をデータベースへ登録
async function registrationDeviceInfo(req) {
    // 非同期処理で`CheckAtHome`の行数をカウント(1番始めに実行！)
    const data = await new Promise((resolve, reject) => {
        connection.query(
            'SELECT count(Number) FROM `CheckAtHome`',
            (error, results) => {
                if (error) {
                    console.log("Nullエラー（行数カウント失敗）");
                    console.log(error);
                } else {
                    // 正常処理
                    resolve(results[0]['count(Number)']);
                }
            }
        );
    })

    // 現在時刻取得
    var dt = new Date();
    date = dt.toFormat("YYYY-MM-DD HH24:MI:SS");

    // 利用者のBLEデバイス情報を`CheckAtHome`に登録
    const queryRes = await new Promise((resolve, results) => {
        connection.query(
            'INSERT INTO `CheckAtHome` VALUES (?, "'+date+'", ?, ?,\'{"UUID": '+JSON.stringify(req.body.UUID)+', "DeviceName": '+JSON.stringify(req.body.DeviceName)+', "isPeripheral": ?}\')',
            [data + 1, req.body.UserName, req.body.Address, req.body.isPeripheral],
            (error, results) => {
                if(error) {
                    connection.end();
                    console.log(error);
                    //reject("Registration Error!");
                } else {
                    // 正常処理
                    console.log("Successful registration of DeviceInfo!");
                    resolve("Registration Successed!");
                }
            }
        )
    })
    // 登録処理の結果を返す
    return queryRes;
}

// 利用者スマホからの在宅チェック送信データの待受
app.post('/postAtHome', (req, res) => {
    console.log(JSON.stringify(req.body));
    // 利用者のデバイス情報をデータベースへ登録
    registrationDeviceInfo(req);
    //console.log(req.body.UserName);

    res.end();
});


async function getCheckAtHome() {
    // 非同期処理で在宅チェックデータをデータベースから取得
    const data = await new Promise((resolve, reject) => {
        connection.query(
            'select max(Number), UserName, Address, `DeviceInfo`->"$.isPeripheral" from `CheckAtHome` group by UserName, Address, DeviceInfo',
            (error, results) => {
                if (error) {
                    console.log(error);
                    connection.end();
                } else {
                    // 正常処理
                    resolve(results);
                    //console.log(results);
                    //res.send(results[0]);
                }
            }
        );
    });

    return data;
}

// ドライバーアプリへ利用者名と住所を返す
app.post('/getCheckAtHome', (req, res) => {
    // Promise処理を待ってから実行する
    getCheckAtHome().then((data) => {
        console.log(data.length);

        const checkList = {};
        const list = [];
        for(let i = 0; i<data.length; i++) {
            checkList['userInfo'+ i] = {userName: data[i].UserName, Address: data[i].Address, isPeripheral: data[i]['`DeviceInfo`->"$.isPeripheral"']};
            list.push({userName: data[i].UserName, Address: data[i].Address, isPeripheral: data[i]['`DeviceInfo`->"$.isPeripheral"']});

        }
        console.log(JSON.stringify(list));
        // JSON形式でデータ返す
        res.json(list);
    });
    
});


// 外部からアクセスできるかの確認関数
app.get('/', (req, res) => {
    console.log("Accessed!");
    res.send('Hello!');
    res.end();
})


app.listen(3000, () => {

});


/*
const port = 3000
const host = "192.168.0.100"

app.get('/', (req, res) => res.send('Hello World!'))

app.listen(port, host, () => console.log(`Example app listening on ${host}:${port}!`))
*/