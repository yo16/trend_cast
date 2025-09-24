#!/bin/bash

# TrendCast API動作確認スクリプト
# サーバーの各エンドポイントをテストします

echo "🧪 TrendCast API 動作確認を開始します..."

# サーバーのURLとポート
SERVER_URL="http://localhost:3001"
API_BASE="$SERVER_URL/api"

# Basic認証の情報（.envから読み込み）
if [ ! -f ".env" ]; then
  echo "❌ .env ファイルが見つかりません"
  exit 1
fi

# 環境変数を読み込み
source .env

# AUTH_USERSから最初のユーザー情報を取得
if [ -z "$AUTH_USERS" ]; then
  echo "❌ AUTH_USERS が設定されていません"
  exit 1
fi

FIRST_USER=$(echo $AUTH_USERS | cut -d',' -f1)
USERNAME=$(echo $FIRST_USER | cut -d':' -f1)
PASSWORD=$(echo $FIRST_USER | cut -d':' -f2)

echo "👤 テストユーザー: $USERNAME"

# サーバーの起動確認
echo "🔌 サーバーの起動確認..."
response=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/health" 2>/dev/null || echo "000")

if [ "$response" != "200" ] && [ "$response" != "404" ]; then
  echo "❌ サーバーが起動していません ($SERVER_URL)"
  echo "💡 npm run dev:server でサーバーを起動してください"
  exit 1
fi

echo "✅ サーバーが起動しています"

# ヘルスチェック
echo ""
echo "🏥 ヘルスチェック..."
curl -s -u "$USERNAME:$PASSWORD" "$SERVER_URL/health" | jq . 2>/dev/null || echo "ヘルスチェックエンドポイントが見つかりません"

# 認証テスト
echo ""
echo "🔐 認証テスト..."
auth_response=$(curl -s -w "%{http_code}" -u "$USERNAME:$PASSWORD" "$API_BASE/auth/status" 2>/dev/null || echo "000")
echo "認証レスポンス: $auth_response"

# 銘柄検索テスト
echo ""
echo "🔍 銘柄検索テスト..."
search_response=$(curl -s -w "%{http_code}" -u "$USERNAME:$PASSWORD" "$API_BASE/stocks/search?q=トヨタ" 2>/dev/null || echo "000")
echo "検索レスポンス: $search_response"

# 株価データ取得テスト
echo ""
echo "📈 株価データ取得テスト..."
price_response=$(curl -s -w "%{http_code}" -u "$USERNAME:$PASSWORD" "$API_BASE/stocks/7203/prices" 2>/dev/null || echo "000")
echo "株価データレスポンス: $price_response"

# テクニカル分析テスト
echo ""
echo "📊 テクニカル分析テスト..."
technical_response=$(curl -s -w "%{http_code}" -u "$USERNAME:$PASSWORD" "$API_BASE/stocks/7203/technical" 2>/dev/null || echo "000")
echo "テクニカル分析レスポンス: $technical_response"

echo ""
echo "🎯 API動作確認が完了しました"
echo "💡 詳細なレスポンスを確認したい場合は、個別にcurlコマンドを実行してください"
echo ""
echo "例:"
echo "curl -u \"$USERNAME:$PASSWORD\" \"$API_BASE/stocks/search?q=トヨタ\" | jq ."