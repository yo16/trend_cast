#!/bin/bash

# TrendCast ビルドスクリプト
# プロダクション用のビルドを実行します

echo "🏗️ TrendCast プロダクションビルドを開始しています..."

# 環境変数の確認
if [ ! -f ".env" ]; then
  echo "❌ .env ファイルが見つかりません"
  echo "💡 .env.example をコピーして .env を作成し、適切な値を設定してください"
  exit 1
fi

# 既存のビルドファイルをクリーンアップ
echo "🧹 既存のビルドファイルをクリーンアップしています..."
npm run clean 2>/dev/null || true

# TypeScript型チェック
echo "🔍 TypeScript型チェックを実行しています..."
npm run type-check
if [ $? -ne 0 ]; then
  echo "❌ TypeScript型チェックに失敗しました"
  exit 1
fi

# Lintチェック
echo "🧼 コード品質チェックを実行しています..."
npm run lint
if [ $? -ne 0 ]; then
  echo "❌ Lintチェックに失敗しました"
  exit 1
fi

# テスト実行
echo "🧪 テストを実行しています..."
npm run test
if [ $? -ne 0 ]; then
  echo "❌ テストに失敗しました"
  exit 1
fi

# ビルド実行
echo "🏗️ プロダクションビルドを実行しています..."
npm run build

if [ $? -eq 0 ]; then
  echo "✅ ビルドが正常に完了しました"
  echo "🚀 npm run start でプロダクションサーバーを起動できます"
else
  echo "❌ ビルドに失敗しました"
  exit 1
fi