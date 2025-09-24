# T006: J-Quants APIサービス実装

## 概要
J-Quants APIとの連携を行うサービスクラスを実装する。

## 実行内容
- J-Quants API認証処理を実装する
- 株価データ取得APIを実装する
- 銘柄検索APIを実装する
- レート制限対応（1秒間隔制御）を実装する
- エラーハンドリングとリトライ処理を実装する
- APIクライアント設定を作成する

## 参照資料
- [`docs/requirements.md`](../requirements.md) - API制限対策
- [`docs/api-specification.md`](../api-specification.md) - API仕様
- [`CLAUDE.md`](../../CLAUDE.md) - 外部API連携ルール

## 依存関係
- 前提: T002 (サーバー環境構築), T004 (共有型定義), T005 (Basic認証)
- 次ステップ: T008, T009

## 完了条件
- J-Quants APIとの認証ができている
- 株価データ取得機能が実装されている
- レート制限が適切に処理されている
- エラーハンドリングが実装されている

## ステータス
- [ ] 未着手