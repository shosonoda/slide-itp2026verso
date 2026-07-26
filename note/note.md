# 発表・議論メモ

## 可算クラスから separable + first-countable なクラスへの拡張

### `denseSeq` と各仮定の役割

`denseSeq H : ℕ → H` は、値域が `H` で稠密になるように選ばれた列である。
可算稠密集合を列として表現したものであり、重複は許され、列の順序自体に
意味はない。

`denseSeq` を得るために使われる仮定は `SeparableSpace H` である。各
`x` に対して `h ↦ F h x` が連続ならば、連続関数の上限は稠密部分だけで
計算できるので、

$$
\sup_{h\in H} g(h)
=
\sup_{m\in\mathbb N} g(\operatorname{denseSeq}(H,m))
$$

とできる。Lean では `denseRestriction F = F ∘ denseSeq H` と定義し、
非可算な添字型 `H` を可算な添字型 `ℕ` に置き換える。

`FirstCountableTopology H` は `denseSeq` の構成には使われない。また、
それ自体が可測性を直接保証する仮定でもない。この仮定は、支配収束型の定理
`MeasureTheory.continuous_of_dominated` を使って

$$
h\longmapsto \int F(h,X(\omega))\,d\mu(\omega)
$$

の連続性を示す箇所で使われる。この連続性が得られると、population risk を
含む uniform deviation についても、`H` 上の上限を `denseSeq H` 上の上限へ
制限できる。

したがって、仮定の役割は次のように整理できる。

- `SeparableSpace H`: 可算稠密列を選び、連続な上限を可算部分へ制限する。
- `FirstCountableTopology H`: パラメータ付き積分の連続性を支配収束から導く。
- `∀ h, Measurable (F h)`: 稠密列へ制限した各関数の可測性を保証する。
- 添字が `ℕ` であること: 可算個の可測関数の上限として、supremum の可測性を
  得る。

特に、empirical Rademacher complexity の稠密列への制限では有限和の
連続性だけで足りるため、`SeparableSpace H` は必要だが
`FirstCountableTopology H` は現れない。一方、uniform deviation には
population expectation が含まれるため、そのパラメータ連続性を示すために
`FirstCountableTopology H` が追加される。

## 関連プロジェクトとの棲み分け

以下は、2026年7月時点の公開内容に基づく整理である。各プロジェクトには
重複する基礎事項もあるが、主目的と成果物の粒度が異なる。

### `lean-rademacher`（本プロジェクト）

中心課題は、Mathlib の測度論的確率論の上で、Rademacher 複雑度による
有限標本の汎化保証を一続きの定理として形式化することである。

- empirical / expected Rademacher complexity、symmetrization、
  McDiarmid の不等式を高確率の uniform-deviation bound へ接続する。
- countable class の定理を、`denseRestriction` により separable class へ
  持ち上げる。
- モデル固有の samplewise complexity bound と、共通の確率論的議論を
  分離する。
- $\ell_2$、$\ell_1/\ell_\infty$ 線形予測、feature-map から定めた RKHS、
  Dudley entropy integral、有限クラス、一次元 Lipschitz family に適用する。
- approximate ERM、loss contraction、excess-risk bound まで接続する。

したがって本プロジェクトの強みは、Rademacher 複雑度を中心に、
「固定標本上の幾何的評価 → 高確率の汎化保証 → 学習則の excess risk」
という再利用可能な縦の経路を提供する点にある。

### Statistical Learning Theory in Lean 4

`YuanheZ/lean-stat-learning-theory` は、経験過程論と高次元統計を広く
形式化するプロジェクトである。公開 README では、Gaussian Lipschitz
concentration、sub-Gaussian process に対する Dudley の定理、Efron--Stein、
Gaussian Poincaré、log-Sobolev 型不等式、局所 Gaussian complexity、
least-squares regression の sharp rate などを主要成果としている。

本プロジェクトとの棲み分けは次のように考えられる。

- `lean-rademacher`: Rademacher 複雑度に基づく汎化保証と、具体的な
  hypothesis class・ERM への end-to-end な適用を主眼とする。
- Statistical Learning Theory in Lean 4: Gaussian / sub-Gaussian 過程、
  localized empirical process、高次元統計の評価をより広く扱う。

Dudley entropy integral、covering number、supremum の可測性などには重複が
ある。ただし同プロジェクトは、`lean-rademacher` の
`separableSpaceSup_eq_real` を利用していることを README で明記している。
したがって競合する別実装と見るより、`lean-rademacher` の可算化補題を
Gaussian・局所経験過程側へ再利用する関係と捉えるのがよい。今後は、共通する
covering-number・concentration・separable-supremum の補題を Mathlib 寄りの
層へ整理し、双方から利用できる形にすることが望ましい。

### Lean Machine Learning

Lean Machine Learning は、個別の統計学習定理を一つずつ完結させることより、
機械学習理論全体で共有する定義とインターフェースを整備することを主目的とする。
公式サイトでは、algorithm、performance measure、確率論・最適化の基礎、
stochastic algorithm を記述・解析する枠組み、AI が再利用できる共通語彙の
構築を掲げている。現在の公開 exposition では、sequential learning、
online learning、multi-armed bandit のアルゴリズムと regret 解析が主要な
具体例になっている。

本プロジェクトとの棲み分けは次のように考えられる。

- `lean-rademacher`: Rademacher 複雑度、uniform deviation、具体的モデルの
  complexity bound など、統計的学習理論の専門定理を供給する。
- Lean Machine Learning: algorithm、environment、risk / performance、
  stochastic process などを共通の語彙で表すための横断的基盤を供給する。

長期的には、`lean-rademacher` 独自の risk、ERM、learner、loss-class の定義を
Lean Machine Learning の共通 API と対応づけるのが自然である。一般性の高い
確率論・位相・測度論の補題は Mathlib に、機械学習の共通インターフェースは
Lean Machine Learning に、Rademacher 複雑度を用いた専門的な定理と具体例は
`lean-rademacher` に置く、という三層構造が一つの目安になる。

## 参照

- `lean-rademacher`: <https://github.com/auto-res/lean-rademacher>
- Statistical Learning Theory in Lean 4:
  <https://github.com/YuanheZ/lean-stat-learning-theory>
- Lean Machine Learning: <https://leanmachinelearning.org/>
- Lean Machine Learning exposition:
  <https://leanmachinelearning.org/LML/exposition/>
