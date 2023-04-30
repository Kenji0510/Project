const fs = require('fs');
const chokidar = require('chokidar');
const mysql = require('mysql');
const path = require('path');
const { rejects } = require('assert');
require('date-utils');


// MySQLへのアクセス情報(音楽データ情報のデータベース)
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'EC2_Ubuntu',
    password: 'Kenji0510!',
    database: 'MusicDataInfo'
});


// データベースに新規登録された音楽データの情報の追加
async function registerMusicInfo(musicName, musicPath) {
    // 非同期処理で`CheckAtHome`の行数をカウント(1番始めに実行！)
    const data = await new Promise((resolve, reject) => {
        connection.query(
            'select count(Number) from `MusicInfoTable`',
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
    });

    // 現在時刻取得
    var dt = new Date();
    date = dt.toFormat("YYYY-MM-DD HH24:MI:SS");

    // データベースに新規登録された音楽データの情報の追加
    const data2 = await new Promise((resolve, reject) => {
        //const musicName = "Track4.mp3";
        //const musicInfoPath = "/home/kenji/WorkSpace/FileServer/public/music/Track4.mp3";
        connection.query(
            'insert into `MusicInfoTable` VALUES (?, "'+date+'", \'{"MusicName": "'+musicName+'", "FilePath": "'+musicPath+'"}\')',
            [data + 1],
            (error, results) => {
                if(error) {
                    connection.end();
                    console.log(error);
                    //reject("Registration Error!");
                } else {
                    // 正常処理
                    console.log("Successful registration of MusicInfo!");
                    //resolve("Registration Successed!");
                }
            }
        )
    })
}



// ./public/musicのファイル更新監視処理
var watcher = chokidar.watch('./public/music/', {
    persistent: true
});

// イベントの定義
watcher.on('ready', () => {
    // 準備完了
    console.log("ready watching...");

    // ファイルの追加
    watcher.on('add', function(path) {
        console.log(path + " added!");
        // 音楽ファイル名と絶対パスを取得
        var musicName = path;
        for(var i = 0; i < 2; i++) {
            musicName = musicName.substring(musicName.indexOf('/') + 1);
        }
        var musicPath = __dirname + '/' + path;
        console.log(musicPath)
        
        // データベースに新規登録された音楽データの情報の追加
        registerMusicInfo(musicName, musicPath);

    });

    // ファイルの更新
    watcher.on('change', function(path) {
        console.log(path + " changed!");
    });
});