# lesson6

url : https://www.youtube.com/watch?v=X8Zx9E3IR8A

## 学んだこと

- 回転を表現するときは、Offsetに決まった関数をかけてやればできる
- canvas.clipPathで描画領域を指定することができる
  - これによってshadowを表現することができる
- シャドウなどの表現はImageFilter.blurで指定することができる
  - Paint()..imageFilter = ImageFilter.blur(sigmaX: 2, sigmaY: 2, tileMode: TileMode.decal)
- animationをさせるには、startの値とendの値を決める必要がある