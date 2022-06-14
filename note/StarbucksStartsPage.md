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
  - これは starTemplate の中で、現在地を与えてやってもできる
    - が、クラスの役割的に startTemplate は start の外径の path だけを計算する処理にしたいので、現在地に移動する手段は canvas.translate を使用しているのだと感じた
- innter radius と outer radius の考えで多角形の描画ができる
  - バッジの表現などをこれでできる
- 初期化するための値が後で来る場合は、フラグ用意してクラスを管理する
- custom painter は Listenable を受け取ることができ、この状態が更新されたタイミングで repaint することができる
  - これって、customPainter の状態を changeNotifier とかで持った方がいいってことだな。
  - そうすれば、状態の管理と、描画処理を完全に分けることができる
    - カスタム Painter の処理がいかつくなってきたら、changeNotifier を使用するようにしよう
