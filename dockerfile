# --- ステージ1: 依存関係のインストールとビルド ---
# ベースイメージとしてNode.jsの公式イメージを使用します。
# '18-alpine'は、バージョン18系の軽量なAlpine Linux版を指定しています。
FROM node:22-alpine AS builder
# コンテナ内の作業ディレクトリを設定します。以降のコマンドはこのディレクトリで実行されます。
WORKDIR /app

# package.json と package-lock.json (あれば) をコンテナの作業ディレクトリにコピーします。
# これらを先にコピーすることで、コードの変更がない限り依存関係のインストールステップがキャッシュされ、ビルドが高速になります。
COPY package.json package-lock.json* ./

# 依存関係をインストールします。--frozen-lockfile は package-lock.json に基づいて厳密にインストールするオプションです。
RUN npm install --frozen-lockfile

# プロジェクトの全てのファイルを作業ディレクトリにコピーします。
COPY . .

# Next.jsアプリケーションを本番用にビルドします。
# これにより、最適化されたコードが `.next` ディレクトリに生成されます。
RUN npm run build

# --- ステージ2: 本番用イメージの作成 ---
# 再度、軽量なNode.jsイメージをベースにします。
FROM node:22-alpine AS runner

# コンテナ内の作業ディレクトリを設定します。
WORKDIR /app

# 本番環境に必要なファイルのみを前のステージからコピーします。
# これにより、最終的なイメージサイズを小さく保つことができます (マルチステージビルド)。
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.mjs ./next.config.mjs 
# Next.js設定ファイルもコピー

# アプリケーションがリッスンするポートを指定します (Next.jsのデフォルトは3000)。
EXPOSE 3000

# コンテナが起動したときに実行されるコマンドを指定します。
# これにより、ビルドされたNext.jsアプリケーションが起動します。
CMD ["npm", "start"]