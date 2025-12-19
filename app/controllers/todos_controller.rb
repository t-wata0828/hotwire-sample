# ========================================
# Todos コントローラー
# ========================================
# Hotwireを使ったTodo管理機能を提供
#
# 【重要なポイント】
# - respond_to で format.turbo_stream を指定することで、Turbo Streamsに対応
# - Turbo Streamsが使える場合は、対応するturbo_stream.erbビューを自動的にレンダリング
# - Turbo Streamsが使えない場合（JavaScriptオフなど）は、HTMLとしてレスポンス

class TodosController < ApplicationController
  # ========================================
  # フィルター
  # ========================================
  # edit, update, destroy, toggle アクションの前に @todo をセット
  before_action :set_todo, only: [ :edit, :update, :destroy, :toggle ]

  # ========================================
  # index アクション - Todoリスト表示
  # ========================================
  def index
    # すべてのTodoを新しい順に取得
    @todos = Todo.order(created_at: :desc)

    # 新規作成用の空のTodoオブジェクト（フォームで使用）
    @todo = Todo.new
  end

  # ========================================
  # create アクション - Todo作成
  # ========================================
  # 【Hotwire ポイント】
  # - format.turbo_stream が指定されると、create.turbo_stream.erb が自動的にレンダリングされる
  # - Turbo Streamビューでは、DOMの特定部分だけを更新する指示を出せる
  # - ページ全体をリロードせずに、新しいTodoをリストに追加できる
  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      respond_to do |format|
        # Turbo Stream形式でレスポンス（create.turbo_stream.erbを使用）
        format.turbo_stream

        # フォールバック: JavaScriptが無効の場合はHTMLでリダイレクト
        format.html { redirect_to todos_path, notice: "Todo was successfully created." }
      end
    else
      # バリデーションエラー時は422ステータスでindexビューを再レンダリング
      render :index, status: :unprocessable_entity
    end
  end

  # ========================================
  # edit アクション - Todo編集画面
  # ========================================
  # 【Hotwire ポイント】
  # - edit.html.erbビューは turbo_frame_tag で囲まれている
  # - Turbo Frameを使うことで、編集フォームだけを部分的に置き換えられる
  # - ページ全体はそのまま、編集したいTodo部分だけが編集フォームに切り替わる
  def edit
    # @todoは before_action の set_todo で既にセット済み
  end

  # ========================================
  # update アクション - Todo更新
  # ========================================
  # 【Hotwire ポイント】
  # - update.turbo_stream.erb で更新後のTodoだけを置き換える
  # - リストの他のTodoには影響を与えずに、該当のTodoだけが更新される
  def update
    if @todo.update(todo_params)
      respond_to do |format|
        # Turbo Stream形式でレスポンス（update.turbo_stream.erbを使用）
        format.turbo_stream

        # フォールバック: JavaScriptが無効の場合はHTMLでリダイレクト
        format.html { redirect_to todos_path, notice: "Todo was successfully updated." }
      end
    else
      # バリデーションエラー時は422ステータスでeditビューを再レンダリング
      render :edit, status: :unprocessable_entity
    end
  end

  # ========================================
  # destroy アクション - Todo削除
  # ========================================
  # 【Hotwire ポイント】
  # - destroy.turbo_stream.erb でTodoをDOMから削除
  # - アニメーション付きでスムーズに削除される（Stimulusコントローラーと連携）
  def destroy
    @todo.destroy
    respond_to do |format|
      # Turbo Stream形式でレスポンス（destroy.turbo_stream.erbを使用）
      format.turbo_stream

      # フォールバック: JavaScriptが無効の場合はHTMLでリダイレクト
      format.html { redirect_to todos_path, notice: "Todo was successfully destroyed." }
    end
  end

  # ========================================
  # toggle アクション - Todo完了/未完了の切り替え
  # ========================================
  # 【Hotwire ポイント】
  # - チェックボックスをクリックするだけで完了状態を切り替え
  # - toggle.turbo_stream.erb でTodoの表示を更新（完了時は打ち消し線、背景色変更など）
  # - ページ遷移なしで即座に反映される
  def toggle
    @todo.update(completed: !@todo.completed)
    respond_to do |format|
      # Turbo Stream形式でレスポンス（toggle.turbo_stream.erbを使用）
      format.turbo_stream

      # フォールバック: JavaScriptが無効の場合はHTMLでリダイレクト
      format.html { redirect_to todos_path }
    end
  end

  # ========================================
  # private メソッド
  # ========================================
  private

  # 指定されたIDのTodoを取得
  def set_todo
    @todo = Todo.find(params[:id])
  end

  # ストロングパラメータ: 許可するパラメータを定義
  # セキュリティのため、明示的に許可したパラメータのみ受け取る
  def todo_params
    params.require(:todo).permit(:title, :completed)
  end
end
