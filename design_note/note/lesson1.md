# lesson1

url: https://www.youtube.com/watch?v=HjJHO0NXI10&t=362s

## 学んだこと

- textのstyleのforegroundを変更することで、fade in outを実現してる
- アニメーション完了時に、テキストを入れ替えることで、ループ構造にしてる
  - もっと複雑な描画になると思っていたが、そうでもない
  - animation　controllerは単純な動きしかしていなく、テキストを動的に入れ替えることでループ構造を表現してる
- baseのpositionを元に位置を計算したいときは、translateを使用する
- shaderはpaintクラス経由で適用すする
  - custompainterでは属性を入れたいときは、paintクラス経由で入れるようにしてるな
- LinearGradientからshaderを作成することができる