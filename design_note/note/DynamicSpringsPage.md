# DynamicSpringsPage

- AnnotatedRegion面白いな
  - appbarがない時とは、このクラスからステータスバーのアイコンを変更するらしい
  - appbarがあるときは、appBarから変更することができる
  - appbarのステータス変更以外にも使われてそうなクラスだけど、他にも何かあるのかしら？
- image assetでcolorBlendeModeが使える
- SpringSimulationでばねのシミュレーションができる
- ばねが動かなくなる時間が事前に与えた定数と、引っ張った距離によって異なるため、AnimationControllerのように事前にアニメーションの時間が決まったものは使えない
  - そのために今回はTickerを使用してるのだと感じてる
