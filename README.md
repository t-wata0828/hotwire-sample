# Hotwire サンプルアプリケーション

Hotwire の主要機能（Turbo Frames、Turbo Streams、Stimulus）を学ぶための教材用 ToDo アプリケーションです。

## 概要

このアプリケーションは、Hotwire の 3 つの主要技術を実演します：

1. **Turbo Drive** - ページ遷移の高速化（デフォルトで有効）
2. **Turbo Frames** - ページの一部だけを更新
3. **Turbo Streams** - サーバーから複数の DOM 更新を指示
4. **Stimulus** - 軽量な JavaScript インタラクション

## 主な機能

- Todo の作成、編集、削除
- 完了/未完了の切り替え
- ページ全体をリロードせずにリアルタイム更新
- フェードイン/フェードアウトアニメーション

## 技術スタック

- Ruby 3.3.x
- Rails 8.1.x
- MySQL 8.4
- Hotwire (Turbo + Stimulus)
- Docker / Docker Compose

## セットアップ

### 1. 環境変数の設定

`.env` ファイルでデータベースのパスワードを設定してください。

```bash
DB_PASSWORD=your_password
```

### 2. Docker コンテナの起動

```bash
docker-compose up -d
```

### 3. データベースのセットアップ

```bash
docker-compose exec rails bin/rails db:create db:migrate
```

### 4. アプリケーションへのアクセス

ブラウザで http://localhost:3000 にアクセス

## コードの構成

### モデル層

- `app/models/todo.rb` - Todo モデル（バリデーション、スコープ）

### コントローラー層

- `app/controllers/todos_controller.rb` - CRUD 操作、Turbo Streams 対応

### ビュー層

#### HTML ビュー

- `app/views/todos/index.html.erb` - 一覧画面（Turbo Frame 使用）
- `app/views/todos/_todo.html.erb` - Todo アイテム（Turbo Frame 使用）
- `app/views/todos/edit.html.erb` - 編集フォーム（Turbo Frame 使用）

#### Turbo Stream ビュー

- `app/views/todos/create.turbo_stream.erb` - 作成時の DOM 更新
- `app/views/todos/update.turbo_stream.erb` - 更新時の DOM 更新
- `app/views/todos/destroy.turbo_stream.erb` - 削除時の DOM 更新
- `app/views/todos/toggle.turbo_stream.erb` - 完了切替時の DOM 更新

### JavaScript 層（Stimulus）

- `app/javascript/controllers/reset_form_controller.js` - フォームリセット
- `app/javascript/controllers/todo_item_controller.js` - アニメーション効果

### スタイル

- `app/assets/stylesheets/application.css` - アプリケーション全体のスタイル

## Hotwire の仕組み

### 1. Turbo Drive（ページ遷移の高速化）

リンクをクリックしたとき、ページ全体をリロードせずに Ajax で取得し、`<body>`だけを置き換えます。

```erb
<%= link_to "編集", edit_todo_path(todo) %>
<!-- 通常のHTMLリンクだが、Turbo Driveが自動的にAjax化 -->
```

### 2. Turbo Frames（部分更新）

`turbo_frame_tag` で囲まれた部分だけを更新できます。

```erb
<!-- index.html.erb -->
<%= turbo_frame_tag "new_todo" do %>
  <%= form_with model: @todo do |f| %>
    ...
  <% end %>
<% end %>

<!-- create.turbo_stream.erb -->
<%= turbo_stream.replace "new_todo" do %>
  <!-- 新しいフォーム（リセット済み） -->
<% end %>
```

**ポイント：**

- 同じ ID (`new_todo`) のフレーム同士が置き換わる
- ページ全体はそのまま、該当部分だけが更新される

### 3. Turbo Streams（複数箇所の同時更新）

サーバーから複数の DOM 操作を一度に指示できます。

```erb
<!-- create.turbo_stream.erb -->
<!-- 1. リストの先頭に新しいTodoを追加 -->
<%= turbo_stream.prepend "todos", partial: "todos/todo" %>

<!-- 2. フォームをリセット -->
<%= turbo_stream.replace "new_todo" do %>
  ...
<% end %>
```

**利用可能なアクション：**

- `append` - 末尾に追加
- `prepend` - 先頭に追加
- `replace` - 置き換え
- `update` - 内容を更新
- `remove` - 削除
- `before` - 前に追加
- `after` - 後に追加

### 4. Stimulus（JavaScript コントローラー）

HTML に data 属性で JavaScript を紐付けます。

```erb
<!-- HTML -->
<form data-controller="reset-form"
      data-action="turbo:submit-end->reset-form#reset">
  ...
</form>
```

```javascript
// reset_form_controller.js
export default class extends Controller {
  reset(event) {
    if (event.detail.success) {
      this.element.reset();
    }
  }
}
```

**命名規則：**

- ファイル名: `reset_form_controller.js`
- data-controller: `reset-form`
- data-action: `イベント名->コントローラー名#メソッド名`

## 学習のポイント

### 初心者向け

1. まずは動作を確認

   - Todo を作成・編集・削除してみる
   - ブラウザの開発者ツールでネットワークタブを確認
   - ページ全体がリロードされていないことを確認

2. コードの流れを追う

   - `todos_controller.rb` の `create` アクション
   - `create.turbo_stream.erb` の処理
   - ブラウザの DOM がどう変化するか

3. コメントを読む
   - 各ファイルに詳しいコメントが記載されています
   - 動作の仕組みを理解しながら読み進めてください

### 中級者向け

1. Turbo Frames と Turbo Streams の使い分け

   - Turbo Frames: 1 対 1 の置き換え（編集フォームなど）
   - Turbo Streams: 複数箇所を同時更新（作成後のリセットなど）

2. Stimulus の活用

   - ライフサイクルコールバック（`connect`, `disconnect`）
   - Targets, Values, Classes の使い方
   - イベントハンドリング

3. ActionCable との連携（発展編）
   - 複数ブラウザ間でのリアルタイム同期
   - `broadcasts_to` の使い方

## トラブルシューティング

### Todo が追加されない

- ブラウザのコンソールでエラーを確認
- `config/importmap.rb` に Turbo と Stimulus がピン留めされているか確認

### スタイルが適用されない

- `app/assets/stylesheets/application.css` が読み込まれているか確認
- ブラウザのキャッシュをクリア

### ActionCable のエラー

- このサンプルでは ActionCable は使用していません
- `turbo_stream_from` をコメントアウトしてあります
- 必要に応じて `bin/rails action_cable:install` で追加可能

## 参考リンク

- [Hotwire 公式サイト](https://hotwired.dev/)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Turbo Rails Gem](https://github.com/hotwired/turbo-rails)

## ライセンス

このサンプルアプリケーションは学習目的で自由に使用できます。
