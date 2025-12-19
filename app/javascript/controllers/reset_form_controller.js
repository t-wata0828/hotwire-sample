import { Controller } from "@hotwired/stimulus";

// ========================================
// reset_form_controller.js - フォームリセット用のStimulusコントローラー
// ========================================
// 【このコントローラーの役割】
// - フォーム送信後、入力フィールドを自動的にクリア
// - エラー時はリセットしない（ユーザーが入力した内容を保持）
//
// 【使用場所】
// index.html.erb の新規Todo作成フォーム
// data-controller="reset-form"
// data-action="turbo:submit-end->reset-form#reset"
//
// 【重要なポイント】
// - turbo:submit-end イベント: Turboフォーム送信完了時に発火
// - event.detail.success: 送信が成功したかどうかを判定
// - this.element.reset(): フォームの全フィールドをリセット

export default class extends Controller {
  // ========================================
  // reset() - フォームリセット処理
  // ========================================
  // 【イベントの流れ】
  // 1. ユーザーがフォームを送信
  //    ↓
  // 2. Turboがフォームを送信（非同期）
  //    ↓
  // 3. サーバーからレスポンスが返る
  //    ↓
  // 4. turbo:submit-end イベントが発火
  //    ↓
  // 5. このreset()メソッドが呼ばれる
  //    ↓
  // 6. 成功していればフォームをリセット
  //
  // 【event.detail の内容】
  // - success: true/false （リクエストが成功したか）
  // - fetchResponse: サーバーからのレスポンス
  reset(event) {
    // Turbo Streamのレスポンスが成功した場合のみリセット
    // エラーの場合は、ユーザーが入力した内容を保持する
    if (event.detail.success) {
      // this.element は data-controller が指定された要素（<form>）を指す
      // reset() はHTMLフォームの標準メソッド
      this.element.reset();
    }
  }

  // ========================================
  // 【補足】なぜこのコントローラーが必要か
  // ========================================
  //
  // Turbo Streamsを使う場合、create.turbo_stream.erb でフォームを
  // 置き換える方法もありますが、このStimulusコントローラーを使うと:
  //
  // 1. シンプル: サーバー側でフォームのHTMLを再生成する必要がない
  // 2. 軽量: ネットワーク転送量が減る
  // 3. 高速: クライアント側だけで処理が完結
  //
  // ただし、このサンプルでは両方を実装しています（学習目的）:
  // - Stimulus: フォーム入力値のリセット
  // - Turbo Stream: フォーム全体の置き換え
  //
  // 実際のプロジェクトでは、どちらか一方を選択すると良いでしょう
}
