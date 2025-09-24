#!/usr/bin/env node

/**
 * J-Quants API認証スクリプト
 * リフレッシュトークンを取得して.envファイルに保存します
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// 環境変数の読み込み
require('dotenv').config();

const JQUANTS_API_BASE = 'https://api.jquants.com';

/**
 * HTTPSリクエストを送信するヘルパー関数
 */
function httpsRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(responseData);
          resolve({ statusCode: res.statusCode, data: parsedData });
        } catch (e) {
          resolve({ statusCode: res.statusCode, data: responseData });
        }
      });
    });
    
    req.on('error', reject);
    
    if (data) {
      req.write(data);
    }
    
    req.end();
  });
}

/**
 * J-Quants APIにログインしてリフレッシュトークンを取得
 */
async function authenticateJQuants() {
  console.log('🔐 J-Quants API認証を開始します...');
  
  const email = process.env.JQUANTS_API_MAIL;
  const password = process.env.JQUANTS_API_PASSWORD;
  
  if (!email || !password) {
    console.error('❌ JQUANTS_API_MAIL または JQUANTS_API_PASSWORD が設定されていません');
    console.log('💡 .envファイルに適切な値を設定してください');
    process.exit(1);
  }
  
  const loginData = JSON.stringify({
    mailaddress: email,
    password: password
  });
  
  const options = {
    hostname: 'api.jquants.com',
    path: '/v1/token/auth_user',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(loginData)
    }
  };
  
  try {
    console.log('📡 J-Quants APIにログイン中...');
    const response = await httpsRequest(options, loginData);
    
    if (response.statusCode === 200) {
      const refreshToken = response.data.refreshToken;
      
      if (!refreshToken) {
        console.error('❌ リフレッシュトークンが取得できませんでした');
        console.log('レスポンス:', response.data);
        process.exit(1);
      }
      
      console.log('✅ リフレッシュトークンを取得しました');
      
      // .envファイルを更新
      await updateEnvFile(refreshToken);
      
      console.log('🎉 J-Quants API認証が完了しました');
      console.log('💾 リフレッシュトークンが.envファイルに保存されました');
      
    } else {
      console.error('❌ 認証に失敗しました');
      console.log('ステータス:', response.statusCode);
      console.log('レスポンス:', response.data);
      
      if (response.statusCode === 400) {
        console.log('💡 メールアドレスまたはパスワードが間違っている可能性があります');
      } else if (response.statusCode === 429) {
        console.log('💡 レート制限に達しました。しばらく待ってから再試行してください');
      }
      
      process.exit(1);
    }
    
  } catch (error) {
    console.error('❌ ネットワークエラーが発生しました:', error.message);
    console.log('💡 インターネット接続を確認してください');
    process.exit(1);
  }
}

/**
 * .envファイルにリフレッシュトークンを保存
 */
async function updateEnvFile(refreshToken) {
  const envPath = path.join(process.cwd(), '.env');
  
  try {
    let envContent = '';
    
    if (fs.existsSync(envPath)) {
      envContent = fs.readFileSync(envPath, 'utf8');
    }
    
    // JQUANTS_REFRESH_TOKEN行を探して更新
    const lines = envContent.split('\n');
    let tokenLineFound = false;
    
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('JQUANTS_REFRESH_TOKEN=')) {
        lines[i] = `JQUANTS_REFRESH_TOKEN=${refreshToken}`;
        tokenLineFound = true;
        break;
      }
    }
    
    // JQUANTS_REFRESH_TOKEN行が見つからない場合は追加
    if (!tokenLineFound) {
      lines.push(`JQUANTS_REFRESH_TOKEN=${refreshToken}`);
    }
    
    // ファイルに書き戻し
    fs.writeFileSync(envPath, lines.join('\n'), 'utf8');
    
  } catch (error) {
    console.error('❌ .envファイルの更新に失敗しました:', error.message);
    console.log('💡 手動で以下の行を.envファイルに追加してください:');
    console.log(`JQUANTS_REFRESH_TOKEN=${refreshToken}`);
  }
}

// スクリプト実行時の処理
if (require.main === module) {
  authenticateJQuants();
}