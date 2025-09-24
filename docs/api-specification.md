# API仕様書

## 概要
TrendCast株価予測システムのREST API仕様

**ベースURL**: `http://localhost:3001/api`
**認証**: Basic認証（全エンドポイントで必須）

## エンドポイント一覧

### 1. 認証

#### POST /api/auth/login
ログイン処理

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "ログイン成功",
  "token": "session-token"
}
```

---

### 2. 銘柄検索

#### GET /api/stocks/search
銘柄検索（コードまたは企業名）

**Query Parameters:**
- `q` (string, required): 検索クエリ（証券コードまたは企業名）
- `limit` (number, optional): 結果の最大件数（デフォルト: 20）

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "code": "7203",
      "name": "トヨタ自動車",
      "market": "東証プライム",
      "sector": "輸送用機器"
    }
  ]
}
```

---

### 3. 株価データ取得

#### GET /api/stocks/:code/prices
指定銘柄の株価データを取得

**Path Parameters:**
- `code` (string): 証券コード

**Query Parameters:**
- `period` (string, optional): 期間（"1y", "6m", "3m", "1m"）デフォルト: "1y"

**Response:**
```json
{
  "success": true,
  "data": {
    "code": "7203",
    "name": "トヨタ自動車",
    "prices": [
      {
        "date": "2024-01-01",
        "open": 2500,
        "high": 2550,
        "low": 2480,
        "close": 2530,
        "volume": 15000000,
        "adjustedClose": 2530
      }
    ]
  }
}
```

---

### 4. テクニカル分析

#### GET /api/stocks/:code/technical
テクニカル指標を計算して返却

**Path Parameters:**
- `code` (string): 証券コード

**Query Parameters:**
- `indicators` (string, optional): 指標のカンマ区切りリスト
  - 例: "sma,ema,macd,rsi,bb"
  - デフォルト: 全指標

**Response:**
```json
{
  "success": true,
  "data": {
    "code": "7203",
    "indicators": {
      "sma": {
        "5": [2500, 2510, 2520],
        "25": [2480, 2490, 2500],
        "75": [2450, 2460, 2470]
      },
      "ema": {
        "5": [2505, 2515, 2525],
        "25": [2485, 2495, 2505],
        "75": [2455, 2465, 2475]
      },
      "macd": {
        "macd": [15, 18, 20],
        "signal": [12, 15, 17],
        "histogram": [3, 3, 3]
      },
      "rsi": {
        "values": [55, 60, 58],
        "overbought": 70,
        "oversold": 30
      },
      "bollingerBands": {
        "upper": [2600, 2610, 2620],
        "middle": [2500, 2510, 2520],
        "lower": [2400, 2410, 2420]
      }
    },
    "dates": ["2024-01-01", "2024-01-02", "2024-01-03"]
  }
}
```

---

### 5. AI予測

#### POST /api/stocks/:code/predict
AIによる株価予測

**Path Parameters:**
- `code` (string): 証券コード

**Request Body (optional):**
```json
{
  "model": "gpt-4",
  "includeReasoning": true
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "code": "7203",
    "currentPrice": 2530,
    "predictions": {
      "3days": {
        "median": 2550,
        "upper": 2600,
        "lower": 2500,
        "confidence": 0.75
      },
      "1week": {
        "median": 2580,
        "upper": 2680,
        "lower": 2480,
        "confidence": 0.65
      },
      "1month": {
        "median": 2650,
        "upper": 2850,
        "lower": 2450,
        "confidence": 0.55
      }
    },
    "reasoning": "移動平均線が上向きであり、MACDがゴールデンクロスを形成。RSIは中立域にあり上昇余地あり。",
    "generatedAt": "2024-01-01T10:00:00Z",
    "model": "gpt-4"
  }
}
```

---

### 6. 統合データ取得

#### GET /api/stocks/:code/analyze
株価、テクニカル分析、予測を一括取得

**Path Parameters:**
- `code` (string): 証券コード

**Query Parameters:**
- `includePredict` (boolean, optional): AI予測を含めるか（デフォルト: true）

**Response:**
```json
{
  "success": true,
  "data": {
    "stock": {
      "code": "7203",
      "name": "トヨタ自動車"
    },
    "prices": [...],
    "technical": {...},
    "prediction": {...}
  }
}
```

---

## エラーレスポンス

### 共通エラー形式
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "エラーメッセージ",
    "details": {}
  }
}
```

### エラーコード一覧

| コード | HTTPステータス | 説明 |
|-------|--------------|------|
| AUTH_REQUIRED | 401 | 認証が必要 |
| AUTH_FAILED | 401 | 認証失敗 |
| NOT_FOUND | 404 | リソースが見つからない |
| RATE_LIMIT | 429 | レート制限超過 |
| INVALID_PARAM | 400 | パラメータエラー |
| EXTERNAL_API_ERROR | 503 | 外部API連携エラー |
| SERVER_ERROR | 500 | サーバー内部エラー |

---

## レート制限

### J-Quants API制限対策
- リクエスト間隔: 最小1秒
- 同時リクエスト数: 1
- エラー時のリトライ: 最大3回（指数バックオフ）

### OpenAI API制限対策
- リクエスト/分: 設定ファイルで調整可能
- トークン数制限: プロンプトの最適化
- キャッシュ: 同一銘柄の予測は5分間キャッシュ

---

## HTTPヘッダー

### リクエストヘッダー
```
Authorization: Basic base64(username:password)
Content-Type: application/json
Accept: application/json
```

### レスポンスヘッダー
```
Content-Type: application/json
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704096000
```

---

## サンプルコード

### JavaScript (axios)
```javascript
const axios = require('axios');

// Basic認証の設定
const auth = {
  username: 'user1',
  password: 'password1'
};

// 銘柄検索
async function searchStock(query) {
  const response = await axios.get(
    'http://localhost:3001/api/stocks/search',
    {
      params: { q: query },
      auth: auth
    }
  );
  return response.data;
}

// 株価予測
async function predictStock(code) {
  const response = await axios.post(
    `http://localhost:3001/api/stocks/${code}/predict`,
    { model: 'gpt-4' },
    { auth: auth }
  );
  return response.data;
}
```

### cURL
```bash
# 銘柄検索
curl -u user1:password1 \
  "http://localhost:3001/api/stocks/search?q=トヨタ"

# 株価予測
curl -u user1:password1 \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-4"}' \
  "http://localhost:3001/api/stocks/7203/predict"
```