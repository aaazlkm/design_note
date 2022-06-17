# lesson3

url: https://www.youtube.com/watch?v=gYekEaDo91s

## 学んだこと

- 以下で他のアニメーションからdelayしてアニメーションを開始することができる
  - 0.3引いてdelayにして、
    - そのままだとminusの値になるので、clampで0-1にして
    - このままだと最大値が0.7になってるので、それを防ぐために0.7で割る
  - (transitionPercent - 0.3).clamp(0, 1.0) / 0.7
- 2倍速は以下でやる
  - (transitionPercent / 0.5).clamp(0, 1)
- アニメーションの速度を変更するときは、値調整後にclampで値を収めるようにするのがコツだな
- custom painterで大きさを指定しない時は、座標の中身が(0.0,0.0)になる
- 以下で重なってるパスを排除できる
  - fillType = PathFillType.evenOdd
  - 今回はこれでoulineを作成した
- customPsianterを使用する際は、centerとtotalwitdhを計算するのが大事かもな
  - center = size.center(Offset.zero) で計算出来る