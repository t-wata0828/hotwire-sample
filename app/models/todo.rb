# ========================================
# Todo モデル
# ========================================
# Hotwire サンプルアプリケーションのメインモデル
# Todoアイテムの基本的なCRUD操作を提供します

class Todo < ApplicationRecord
  # ========================================
  # バリデーション
  # ========================================
  # titleは必須項目
  validates :title, presence: true

  # ========================================
  # スコープ（検索条件の定義）
  # ========================================
  # 完了済みのTodoを取得: Todo.completed
  scope :completed, -> { where(completed: true) }

  # 未完了のTodoを取得: Todo.pending
  scope :pending, -> { where(completed: false) }

  # ========================================
  # Hotwire / Turbo Streams との連携
  # ========================================
  # 【発展編】ActionCableを使用する場合
  # 以下のコードを追加すると、複数のブラウザ間でリアルタイム同期が可能になります
  #
  # broadcasts_to ->(todo) { "todos" }, inserts_by: :prepend
  #
  # 機能:
  # - Todoが作成/更新/削除されると、自動的にTurbo Streamを配信
  # - "todos"チャンネルを購読しているすべてのブラウザに変更が通知される
  # - inserts_by: :prepend で新しいTodoをリストの先頭に追加
end
