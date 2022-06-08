# NeonHorizonPage

- shader と widget で使用する gradient は種類が異なる
  - material と ui 系に分かれる
- deltaは変化量として使用される
- 縦に全て０−１で使ってしまうから、ループできないので、基準となる線をmod 0.1 で繰り返させる考え強すぎる
  - ちょっと後で見返した時に何書いてるかわからないそう
  - horizontal line を繰り返し下から上へ描画する時の話
- 累乗で幅をだんだん開ける表現をできる
  - sinも使用できる
