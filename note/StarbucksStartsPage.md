# StarbucksStartsPage

Saves a copy of the current transform and clip on the save stack.

- canvas.save で save stack に保存するらしい
  - そして、restore で save stack で pop するらしい
  - 何がしたくて、stack に入れてるのかよくわからん
  - canvas 上で複数のものを描画するときに使うんだな
    - save で canvas 上に新たに描画する場所を確保するイメージ
    - restore を呼ぶことで canvas に適用できるのかな
  - save layer
    - 描画したのものに合成できる
    - blende mode で指定できる
- innter radius と outer radius の考えで多角形の描画ができる
  - バッジの表現などをこれでできる
