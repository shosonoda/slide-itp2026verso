良いですね．このまま marp で進めます．
draft.md について，以下の項目に対応してください．

- 期待損失・経験損失の記号は $R$ ではなく $L$ にしてください．Rademacher と紛らわしいので．

- lean 実装および preprint にあわせて，仮説と仮説空間を $f \in \mathcal F$ にしてください

- $F_h$ は分かりにくいので，$h$ 自体を単に実数値関数として扱ってください．

- Lean の定理名を引用している箇所では，定理名だけではほとんど何も分からないので，主張の type signature までください．def の場合は実装まで書いてください．

- l.119 $h^\star$ の定義が分かりません
- l.302 別の実装法と比較して何が嬉しいか説明できますか
- l.310 他の有限集合を表す方法と比較して何が嬉しいか説明できますか
- denseSeq とは何か説明してください
- $\widehat{\mathfrak R}^{\mathrm{one}}$ の定義を与えてください

---

- 共通 bridge という言い方はあまり分からないので，共通定理とか基本汎化評価とか雛形（template）とかいう言い方を検討してください
- marp には，定理環境のようなものはありますか．なければ作成してください．
- \boxed は使わないでください．
- 表紙（title page）を統合してください
- スライドタイトルに番号は不要ですので外してください

---
- スライドタイトルの位置を1行分上に広げて余白を確保してください
- 例2,3,4 なども定理環境で主張を述べてください

---

- draft.md を draft-jp.md に変更しました
- draft-jp.md を英訳して draft-en.md を作成してください
- 文字の溢れなどはこちらで調整するので，まずは確認しなくてよいです

- スライドタイトルと本文が同じ色だと読みにくいので， default theme を参考にして色を変えてください

- Lean公式ページ（ https://lean-lang.org/ ） で採用されている配色を模倣できますか． lean-rademacher.css と比較できるように，別の css として準備してください．

- lean-rademacher-lean.css ではなく lean-web.css という名前に修正してください．

---
note
- l.60 に pics/hankagosa-yoko 追加
- l. 377 McDiarmid's inequality を一般の statement にしてください
- predictor と hypothesis が混在しています．使い分けはありますか．なければ hypothesis に統一してください．
- l. 116 oracle inequality for approximate ERM をどう使うか見えない．もう少し詳しく説明してください．
- ι と H が混在している

- hypothesis f に損失も含めるという説明に関し，lean 実装もそうなっていますか
- measure.pi $\lambda$ 不要
  ```lean
  local notation "μⁿ" => Measure.pi (fun _ ↦ μ)
  ```
- empirical/population loss は， lean 実装にあわせると risk
- talk 消す
- l.457 denseSeq を使ってどのように拡張したか説明する
- Example 3-4, lean

- 冒頭に動機付けを追記しました．英語で整えてください．また，画像を読み込んでください．出典 https://papercopilot.com/statistics/neurips-statistics/ を示してください．
