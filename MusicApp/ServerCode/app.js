const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const { execSync } = require('child_process');
//require('date-utils');

const app = express();

app.use(bodyParser.json());
app.use(express.static('public'));
app.use(express.urlencoded({extended: false}));


// MySQLへのアクセス情報(音楽データ情報のデータベース)
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'EC2_Ubuntu',
    password: 'Kenji0510!',
    database: 'MusicDataInfo'
});


// スマホアプリからの音声データ情報を要求に対する処理
async function getMusicInfo() {
    const data = await new Promise((resolve, reject) => {
        connection.query(
            'select `MusicInfo`->"$.MusicName", RegistrationDate from `MusicInfoTable`',
            (error, results) => {
                if (error) {
                    console.log(error);
                } else {
                    // 正常処理
                    resolve(results);
                }
            }
        );
    });
    return data;
}

// スマホアプリからの音楽データ情報要求受付
app.get('/getMusicInfo', (req, res) => {
    console.log('Accessed /getMusicInfo!');
    // Promise処理を待ってから実行する
    // スマホアプリからの音声データ情報を要求に対する処理
    getMusicInfo().then((data) => {
        console.log(data.length);

        const musicInfoList = [];
        for(let i = 0; i < data.length; i++) {
            musicInfoList.push({MusicName: data[i]['`MusicInfo`->"$.MusicName"'], RegistrationDate: data[i].RegistrationDate});
        }
        console.log(JSON.stringify(musicInfoList));
        // JSON形式でデータを返す
        res.json(musicInfoList);
    });

});

// スマホアプリから指定された音楽ファイル名をデータベースから取得
async function getSelectedMusicInfo(req) {
    const data = await new Promise((resolve, reject) => {
        connection.query(
            'select RegistrationDate, `MusicInfo`->"$.FilePath" from `MusicInfoTable` where `MusicInfo`->"$.MusicName" = ?',
            [req.body.selectMusicName],
            (error, results) => {
                if (error) {
                    console.log(error);
                } else {
                    // 正常処理
                    resolve(results);
                }
            }
        );
    });
    return data;
}


// 音楽ファイルのデータを送信
app.post('/music', (req, res) => {
    console.log('Accessed /music!');
    // スマホアプリから指定された音楽ファイルのパスをデータベースから取得
    getSelectedMusicInfo(req).then((data) => {
        //console.log(data[0]['`MusicInfo`->"$.FilePath"']);
        var musicDir = data[0]['`MusicInfo`->"$.FilePath"'];
        // 指定された音楽ファイルをアプリに送信
        //console.log(path.join(__dirname, 'public/music/Dance My Generation.mp3'));
        res.sendFile(musicDir.replace(/\"/g, ""));
    })
});


// アプリからYoutubeの動画を変換したい要求を受付
app.post('/requestConvertToMP3', (req, res) => {
    console.log('Accessed /requestConvertToMP3!');
    console.log(req.body.youtubeURL);
    console.log(req.body.saveMusicName);

    
    // ダウンロードするyoutubeの動画URL
    var musicURL = req.body.youtubeURL;
    // ダウンロード出力先 + 出力ファイル名
    var outputFilePath = "./public/youtubeMovie/abc.m4a";
    // mp3へ変換した時の出力先 + 出力ファイル名
    var convertFilePath = "./public/music/" + req.body.saveMusicName;


    /* 以下は同期実行（上から順番に実行） */
    // yt-dlpで指定されたYoutubeの動画をm4aでダウンロードするコマンド
    var stdout = execSync('yt-dlp -x --audio-format m4a -o ' + outputFilePath +' -i ' + musicURL);
    console.log(`stdout: ${stdout.toString()}`);

    // ffmpegでm4aをmp3へ変換するコマンド
    stdout = execSync('ffmpeg -i ' + outputFilePath + ' -f mp3 -b:a 192k ' + convertFilePath);
    console.log(`stdout: ${stdout.toString()}`);

    // ./public/youtubeMovie/abc.m4aを削除
    execSync('rm ./public/youtubeMovie/abc.m4a');

    res.json({resMessage: "Successuful!"});
    
    //res.end()
});


app.listen(3000, function(){
    console.log('Started Server!');
});