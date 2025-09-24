#!/bin/bash

# TrendCast 開発サーバー起動スクリプト
# サーバーとクライアントを同時起動します

echo "🚀 TrendCast 開発サーバーを起動しています..."

# 環境変数ファイルの確認
if [ ! -f ".env" ]; then
  echo "❌ .env ファイルが見つかりません"
  echo "💡 .env.example をコピーして .env を作成し、適切な値を設定してください"
  exit 1
fi

# Node.jsバージョンの確認
node_version=$(node -v | cut -d'v' -f2)
required_version="18.0.0"

if [ "$(printf '%s\n' "$required_version" "$node_version" | sort -V | head -n1)" != "$required_version" ]; then
  echo "❌ Node.js バージョン $required_version 以上が必要です（現在: v$node_version）"
  exit 1
fi

# 依存関係のインストール確認
if [ ! -d "node_modules" ]; then
  echo "📦 依存関係をインストールしています..."
  npm install
fi

if [ ! -d "src/client/node_modules" ]; then
  echo "📦 クライアント依存関係をインストールしています..."
  cd src/client && npm install && cd ../..
fi

if [ ! -d "src/server/node_modules" ]; then
  echo "📦 サーバー依存関係をインストールしています..."
  cd src/server && npm install && cd ../..
fi

echo "✅ 依存関係の確認が完了しました"
echo "🌐 サーバー: http://localhost:3001"
echo "🎨 クライアント: http://localhost:3000"
echo ""
echo "Ctrl+C で停止します"
echo ""

# 開発サーバー起動
npm run dev