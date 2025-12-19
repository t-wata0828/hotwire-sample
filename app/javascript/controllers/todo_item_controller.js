import { Controller } from "@hotwired/stimulus";

// ========================================
// todo_item_controller.js - TodoアイテムのStimulusコントローラー
// ========================================
// 【Stimulusとは】
// - Hotwireの一部で、HTMLに軽量なJavaScriptの振る舞いを追加するフレームワーク
// - data-controller 属性でHTMLとJavaScriptを紐付ける
// - React/Vueのような大規模なフレームワークではなく、必要な部分にだけJSを追加
//
// 【このコントローラーの役割】
// - Todoアイテムにアニメーション効果を追加
// - 新規作成時: フェードイン
// - 削除時: フェードアウト（※現在は使用していない）
//
// 【使用場所】
// _todo.html.erb の <div data-controller="todo-item"> で紐付け

export default class extends Controller {
  // ========================================
  // connect() - ライフサイクルコールバック
  // ========================================
  // Stimulusコントローラーが要素に接続されたときに自動的に呼ばれる
  //
  // 【いつ呼ばれるか】
  // - ページ読み込み時に data-controller="todo-item" の要素が存在する場合
  // - Turbo Streamsで新しいTodoが追加された場合
  //
  // 【動作】
  // - 要素に "fade-in" クラスを追加
  // - CSSアニメーション（application.css で定義）が実行される
  // - 0.3秒かけてフェードイン
  connect() {
    // this.element は data-controller が指定された要素（.todo-item）を指す
    this.element.classList.add("fade-in");
  }

  // ========================================
  // remove() - 削除時のアニメーション（※現在未使用）
  // ========================================
  // 【注意】
  // このメソッドは現在使用していません
  // Turbo Streamsの turbo_stream.remove が直接DOMから削除するため
  //
  // 【使用する場合】
  // _todo.html.erb の削除ボタンに以下を追加:
  // data-action="click->todo-item#remove"
  //
  // 【動作】
  // 1. クリックイベントをキャンセル（preventDefault）
  // 2. フェードアウトアニメーションを開始
  // 3. 300ms後に要素を削除
  remove(event) {
    // デフォルトのイベント動作をキャンセル
    event.preventDefault();

    // フェードアウトアニメーション開始
    this.element.classList.add("fade-out");

    // アニメーション完了後に要素を削除
    setTimeout(() => {
      this.element.remove();
    }, 300);
  }

  // ========================================
  // 【発展編】Stimulusで使える機能
  // ========================================
  //
  // 1. Targets - 要素内の特定の子要素を取得
  //    static targets = ["title", "checkbox"]
  //    this.titleTarget → data-todo-item-target="title" の要素
  //
  // 2. Values - データをHTML属性から取得
  //    static values = { id: Number, completed: Boolean }
  //    this.idValue, this.completedValue でアクセス
  //
  // 3. Classes - CSSクラス名を外部から注入
  //    static classes = ["completed"]
  //    this.completedClass でアクセス
  //
  // 4. Actions - イベントハンドラ
  //    data-action="click->todo-item#toggle"
  //    クリック時に toggle() メソッドが呼ばれる
}
