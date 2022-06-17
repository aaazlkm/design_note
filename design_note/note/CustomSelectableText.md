# CustomSelectableTextPage

- https://www.youtube.com/watch?v=77GyeN5lbR0

## メモ

- \_renderParagraph がテキストの描画関係の情報をたくさん持っていて便利そうだな
  - localPosition から text の位置を計算することができるし
  - carot の高さや offset も計算してくれるし
  - textSelection から Rects を計算して返してくれるし
- - \_renderParagraph.getPositionForOffset が肝
  - こいつがいるおかげで、localPosition から選択してる text の位置を計算することができている
- \_renderParagraph.getBoxesForSelection
  - こいつのおかげで、テキストの外形を計算することができる
  - TextSelection を全体にすれば、全体のテキストの外径がわかり、こいつにより、マウスのホバー処理できる
  - TextSelection を選択範囲にすれば、選択範囲の Rects を返しくてれて、選択状態を表現することができる
- 流れ
  - localPosition から、TextSelection の値を計算
  - TextSelection から、Rects を計算
    - 選択範囲を描画する
  - TextSelection .extent に基づいて、キャロットを計算する
