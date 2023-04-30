const { execSync } = require('child_process');


// ダウンロードするyoutubeの動画URL
var musicURL = "https://www.youtube.com/watch?v=qX7pFYH9O04"
// ダウンロード出力先 + 出力ファイル名
var outputFilePath = "./public/youtubeMovie/abc.m4a"
// mp3へ変換した時の出力先 + 出力ファイル名
var convertFilePath = "./public/music/abc.mp3"


/* 以下は同期実行（上から順番に実行） */
// yt-dlpで指定されたYoutubeの動画をm4aでダウンロードするコマンド
var stdout = execSync('yt-dlp -x --audio-format m4a -o ' + outputFilePath +' -i ' + musicURL);
console.log(`stdout: ${stdout.toString()}`);

// ffmpegでm4aをmp3へ変換するコマンド
stdout = execSync('ffmpeg -i ' + outputFilePath + ' -f mp3 -b:a 192k ' + convertFilePath);
console.log(`stdout: ${stdout.toString()}`);