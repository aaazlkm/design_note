# Mac Dock

## やること

- [x] リストで資格を表示する
- [x] DragUpdateDetail を調べる
  - localPosition と globalPositin を持つ
    - ここらへんの値は View からくる前提で考えて良さそう
  - offfset deleta の値がある
    - 前回の値からどれくらい動いたかのあたい
    - horizontalDragUpdate のコールバックでは値が入ってくる
- [x] localPosition とは？
  - View 内の位置を示す
  - gloabal Position は、画面全体の位置かな？
- [x] 現在の index を取得する
- [x] 現在の index のアイテムのサイズを大きくする
- [x] rightIn dex と leftIndex の間の percent を計算する
- [x] 現在の index のアイテムの大きさをアニメーションで変化させる
- [x] 選択してるitemだけを変化させるようにする
- [x] item の高さちゃんと計算しないと、いけない気がする
  - item の高さがまちまちになる
    - (View の幅 - 大きさが変わってる正方形の幅) / 残りの正方形の数　をしないといけないと思う
- [x] ドラックと最後ををアニメーションで変化させる
  - どうやればできるんだろう？
    - start で計算される Width をいきなり変更してしまってるのがまずい
      - ここの値をゆっくり変化させたいんだな
      - そのためには、start と end の値が必要になる
        - start は defaultItemWidth でわかる
        - end は計算できる
        - ここの値を start ドラッグの時に変化させる
  - start 用の AnimationControler を作成する
    - start のコントローラーがアニメーション中は、ドラッグのアニメーションさせない
- [ ] 周辺の正方形３つもサイズが変わるようにする
