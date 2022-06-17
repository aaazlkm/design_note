# lesson4

url : https://www.youtube.com/watch?v=QMqKAEjwEJc

## 学んだこと

- powでアニメーションの速度を遅らせることができる
  - powは冪乗計算
  - 0...1  ではlinearの変化よりも冪乗の変化の方が遅いので、これによりアニメーションの速度を遅らせることができる
    - 最終的な値は冪乗しても変わらないので使える
- アニメーションさせるときは、最大値=maxを決めて、max * percentでアニメーションさせる
  - maxを決めることで初めてアニメーションさせることができる
- 基準を定めるときは、base + max * percentにすると、baseを基準にアニメーションしてくれる
- iconを描画するときは、IconDataのfontFamilyをParagraphStyleに入れたりするといい感じ
  - iconはテキストの描画系を使用してるんだろうな
  - customPaintでもIconを使用できることは覚えておこう
- アニメーションをいくつかのフェイズに分割したいときは、if (percent < 0.5) percent / 0.5 みたいにすればいい感じ
  - persentで条件付けして その後 0.5とかで割れば、再度 0.0 - 1.0 で変化するようになるので問題ない
- custom paintで描画した要素は、touch detectionを持たないんため、その上にちょうどがボタンが来るように調整してtouch detectionをしないといけない
- 循環は%と相性がいい
  - index ++ % value でサイクルする
- Transformクラスめちゃ遊べそう
  - ページを捲る処理とか
  - カードをスタックで表示する処理とか
  - しかもWidigetなので、gestureDetectできそうでめちゃ便利そう
- 1 - percent はanimationを逆にする意味を持つ