---
marp: true
# style: |
#   section {
#       justify-content: start;
#   }
paginate: true
theme: default
size: 16:9
math: katex
---

<!-- # lean-rademacher ITP 2026 スライド構成案

スライドの流れを確認するための日本語ドラフト。
`---` ごとに一枚を想定し、デザインは指定しない。

基準:

- `lean-rademacher` の `ss` ブランチ、commit `34c42b4`
- `lean-rademacher/note/summary.md`（2026-07-24 更新）
- ITP 2026 論文
- 聴衆は統計的学習理論に必ずしも詳しくない -->

## Lean Formalization of Generalization Error Bounds by Rademacher Complexity and Dudley's Entropy Integral

**Presenter**: Sho Sonoda, RIKEN AIP / CyberAgent Inc
**Date**: 26 July 2026

---

## 1. タイトル

**Lean Formalization of Generalization Error Bounds by Rademacher Complexity**

- Sho Sonoda, Kazumi Kasaura, Yuma Mizuno, Kei Tsukamoto, Naoto Onda
- ITP 2026
- Lean 4 + Mathlib

この発表の問い:

> 有限個の訓練データから選んだモデルが未知のデータにも通用することを、
> Lean でどこまで証明できるか。

---

## 2. 機械学習は有限標本から予測則を選ぶ

- 未知の分布から訓練標本
  $S=(z_1,\ldots,z_n)$ を得る。
- 学習アルゴリズムは標本を見て
  $\widehat h=A(S)$ を選ぶ。
- 本当に知りたいのは、同じ標本上ではなく未知のデータ上の性能である。

$$
\text{未知の分布}
\longrightarrow
\text{訓練標本 }S
\longrightarrow
\text{学習 }A
\longrightarrow
\widehat h
$$

---

## 3. 訓練誤差と母集団誤差

損失を $\ell(h,z)$ とする。

$$
\widehat R_S(h)
=\frac1n\sum_{k=1}^n\ell(h,z_k),
\qquad
R(h)
=\mathbb E_{Z\sim\mu}[\ell(h,Z)].
$$

- $\widehat R_S(h)$: 訓練データから計算できる。
- $R(h)$: 未知の分布に関する平均なので、直接は計算できない。
- 両者の差
  $\left|\widehat R_S(h)-R(h)\right|$
  が汎化ギャップである。

---

## 4. なぜクラス全体を評価するのか

学習後の $\widehat h=A(S)$ は標本 $S$ に依存する。
固定した $h$ だけの確率評価を、そのまま $\widehat h$ には使えない。

$$
\Delta_n(S)
:=
\sup_{h\in H}
\left|\widehat R_S(h)-R(h)\right|.
$$

一様偏差 $\Delta_n(S)$ を評価すれば、

$$
\left|\widehat R_S(\widehat h)-R(\widehat h)\right|
\le \Delta_n(S)
$$

が、標本を見た後に選んだモデルにも成立する。

---

## 5. 一様偏差から学習結果の保証へ

$\widehat h$ が $\eta$-近似 ERM、すなわち

$$
\widehat R_S(\widehat h)
\le \widehat R_S(h)+\eta
\qquad(\forall h\in H)
$$

を満たすとする。比較対象を $h^\star$ とすると、

$$
\boxed{
R(\widehat h)-R(h^\star)
\le 2\Delta_n(S)+\eta
}
$$

となる。これは確率論を使わない決定論的不等式である。

したがって、発表の中心的な課題は
$\Delta_n(S)$ を小さく抑えることである。

Lean: `IsApproxERM.excessRisk_le_two_mul_uniformDeviation`

---

## 6. Rademacher 複雑度の直観

標本 $S=(z_1,\ldots,z_n)$ を固定し、各点にランダムな符号
$\sigma_k\in\{-1,+1\}$
を付ける。

$$
\frac1n\sum_{k=1}^n \sigma_k F_h(z_k)
$$

を大きくできる $h$ をクラスから探す。

- 小さい: クラスはランダムなノイズに合わせにくい。
- 大きい: クラスは多くのパターンを表現でき、過学習しやすい。
- 「標本を見てから $h$ を選ぶ自由度」を測る量である。

---

## 7. 経験 Rademacher 複雑度

$$
\widehat{\mathfrak R}_n(F;S)
=
\mathbb E_\sigma
\left[
\sup_{h\in H}
\left|
\frac1n\sum_{k=1}^n
\sigma_kF_h(z_k)
\right|
\right].
$$

Lean では符号全体を有限型として表す。

```lean
def Signs (n : ℕ) : Type :=
  Fin n → ({-1, 1} : Finset ℤ)

def empiricalRademacherComplexity
    (n : ℕ) (F : H → X → ℝ) (S : Fin n → X) : ℝ :=
  (Fintype.card (Signs n) : ℝ)⁻¹ *
    ∑ σ : Signs n, ⨆ h,
      |(n : ℝ)⁻¹ * ∑ k,
        (σ k : ℝ) * F h (S k)|
```

標本についてさらに平均した量を
$\mathfrak R_n(F)=\mathbb E_S[\widehat{\mathfrak R}_n(F;S)]$
と書く。

---

## 8. 基本定理: Rademacher 複雑度による汎化評価

関数クラス $F=\{F_h\}_{h\in H}$ が
$|F_h(z)|\le b$
を満たすとする。適切な可測性条件の下で、

$$
\mathbb E_S[\Delta_n(S)]
\le 2\mathfrak R_n(F)
$$

かつ

$$
\boxed{
\Pr\left\{
\Delta_n(S)
\ge 2\mathfrak R_n(F)+\varepsilon
\right\}
\le
\exp\left(-\frac{n\varepsilon^2}{2b^2}\right)
}
$$

が成立する。

$\varepsilon=b\sqrt{2\log(1/\delta)/n}$ とすれば、
信頼度 $1-\delta$ の評価になる。

---

## 9. 証明スケッチ 1: symmetrization

独立な ghost sample
$S'=(Z'_1,\ldots,Z'_n)$
を導入する。

$$
\begin{aligned}
\mathbb E_S[\Delta_n(S)]
&\le
\mathbb E_{S,S'}
\sup_h
\left|
\frac1n\sum_k
\bigl(F_h(Z_k)-F_h(Z'_k)\bigr)
\right| \\
&=
\mathbb E_{S,S',\sigma}
\sup_h
\left|
\frac1n\sum_k
\sigma_k\bigl(F_h(Z_k)-F_h(Z'_k)\bigr)
\right| \\
&\le 2\mathfrak R_n(F).
\end{aligned}
$$

Lean の中心的な補題:

- `abs_symmetrization_equation`
- `expectation_le_rademacher`
- `uniform_deviation_expectation_le_two_smul_rademacher_complexity`

---

## 10. 証明スケッチ 2: McDiarmid

標本の一要素だけを $z_k$ から $z'_k$ に置き換える。
$|F_h(z)|\le b$ なら、

$$
\left|
\Delta_n(S)
-\Delta_n(S^{(k\leftarrow z'_k)})
\right|
\le \frac{2b}{n}.
$$

McDiarmid の不等式から、

$$
\Pr\left\{
\Delta_n-\mathbb E[\Delta_n]\ge\varepsilon
\right\}
\le
\exp\left(-\frac{n\varepsilon^2}{2b^2}\right).
$$

期待値評価と合わせれば基本定理を得る。

Lean:

- `uniformDeviation_bounded_difference`
- `uniform_deviation_mcdiarmid_tail`

---

## 11. 観測した複雑度を残す

$\mathfrak R_n(F)$ は分布に依存し、直接は観測できない。
一方、
$\widehat{\mathfrak R}_n(F;S)$
は標本に依存する量である。

経験 Rademacher 複雑度も一要素の置換に対する変化が
$2b/n$ 以下になる。下側集中を基本定理と union bound で合わせると、

$$
\boxed{
\Pr\left\{
\Delta_n(S)
\ge
2\widehat{\mathfrak R}_n(F;S)+3\varepsilon
\right\}
\le
2\exp\left(-\frac{n\varepsilon^2}{2b^2}\right)
}
$$

を得る。これが現在の標本依存 API の基礎になる。

---

## 12. 形式化上の工夫: 標本と符号の表現

### i.i.d. 標本

- 一つの確率変数 $X:\Omega\to\mathcal X$
- 積測度
  $\mu^n=\operatorname{Measure.pi}(\lambda\_\Rightarrow\mu)$
- 積空間上の点
  $\omega:\operatorname{Fin}n\to\Omega$

を用いて、
$S=X\circ\omega$
と表す。i.i.d. 性は座標写像の性質として再利用する。

### Rademacher 符号

$$
\operatorname{Signs}(n)
=\operatorname{Fin}n\to\{-1,+1\}
$$

を有限型とし、$2^n$ 個の符号列上の明示的な平均を取る。

---

## 13. 形式化上の工夫: 非可算な上限の可測性

可算個の可測関数の上限は可測である。
しかし、非可算クラス $H$ 上の supremum は自動的には可測でない。

$H$ が可分で、$h\mapsto F_h(x)$ が連続なら、稠密列に制限する。

$$
\sup_{h\in H}g(h)
=
\sup_{m\in\mathbb N}
g(\operatorname{denseSeq}(H,m)).
$$

```lean
noncomputable abbrev denseRestriction
    [TopologicalSpace H] [SeparableSpace H] [Nonempty H]
    (F : H → X) : ℕ → X :=
  F ∘ denseSeq H
```

経験複雑度、期待複雑度、一様偏差の三つが、この制限で変わらないことを示す。

---

## 14. 利用者向けの共通 bridge

利用者は標本ごとの上界

$$
\widehat{\mathfrak R}_n(F;S)\le C(S)
$$

を証明すればよい。共通定理から

$$
\boxed{
\Pr\left\{
\Delta_n(S)
\ge
2C(S)
+3b\sqrt{\frac{2\log(2/\delta)}{n}}
\right\}
\le\delta
}
$$

を得る。

```lean
uniform_deviation_tail_bound_separable_of_sample_empirical_le_delta
```

応用の手順:

$$
\text{関数クラスを定義}
\to
\widehat{\mathfrak R}_n\le C(S)
\to
\text{共通 bridge}
\to
\text{汎化・余剰誤差}
$$

---

## 15. 例1: $\ell_2$ 制約付き線形予測器

$$
F_w(x)=\langle w,x\rangle,
\qquad
\|w\|_2\le W.
$$

固定標本上で、

$$
\boxed{
\widehat{\mathfrak R}_n(F;S)
\le
\frac{W}{n}
\sqrt{\sum_{k=1}^n\|x_k\|_2^2}
}
$$

を示す。

証明では、Cauchy--Schwarz で重み上の supremum を消し、
Rademacher 符号の直交性で非対角項を消す。

$$
\mathbb E_\sigma
\left\|\sum_k\sigma_kx_k\right\|
\le
\sqrt{\sum_k\|x_k\|^2}.
$$

一般 Hilbert 空間の定理を一度証明し、有限次元版を系として得る。

---

## 16. $\ell_2$ の end-to-end 評価

$\|x_k\|\le X$ なら、関数値の上界は $b=XW$ である。
共通 bridge に

$$
C(S)
=
\frac Wn\sqrt{\sum_k\|x_k\|_2^2}
$$

を代入すると、

$$
\Pr\left\{
\Delta_n(S)\ge
\frac{2W}{n}\sqrt{\sum_k\|x_k\|_2^2}
+3XW\sqrt{\frac{2\log(2/\delta)}{n}}
\right\}
\le\delta.
$$

Lean:

```lean
linear_predictor_l2_uniform_deviation_tail_bound_of_sample_delta
```

観測標本のノルムが小さければ、一様半径だけを使う評価より鋭くなる。

---

## 17. 例2: $\ell_1/\ell_\infty$ 線形予測器

$$
F_w(x)=\sum_{j=1}^d w_jx_j,
\qquad
\|w\|_1\le W.
$$

$$
\widehat{\mathfrak R}_n(F;S)
\le
WQ_\infty(S)\sqrt{2\log(2d)},
$$

$$
Q_\infty(S)
=
\frac1n\sup_{j<d}
\sqrt{\sum_k|x_{k,j}|^2}.
$$

証明の要点:

- $\ell_1/\ell_\infty$ 双対性で、$2d$ 個の signed coordinate に帰着する。
- Massart の補題により $\sqrt{\log(2d)}$ が現れる。
- $|x_j|\le X_\infty$ なら
  $Q_\infty(S)\le X_\infty/\sqrt n$。

---

## 18. 例3: RKHS は Hilbert 空間の証明を再利用する

特徴写像 $\Phi(x)\in\mathcal H$ と

$$
K(x,x')=\langle\Phi(x),\Phi(x')\rangle,
\qquad
F_w(x)=\langle w,\Phi(x)\rangle,
\qquad
\|w\|\le\Lambda
$$

を考える。

$$
\boxed{
\widehat{\mathfrak R}_n(F;S)
\le
\frac{\Lambda}{n}
\sqrt{\sum_kK(x_k,x_k)}
}
$$

- 右辺は観測した kernel trace に依存する。
- $K(x,x)\le r^2$ なら
  $r\Lambda/\sqrt n$。
- 同じ共通 bridge から、kernel trace を残した高確率評価を得る。

---

## 19. 例4: Dudley entropy integral

標本上の関数間の距離を

$$
d_S(f,g)
=
\sqrt{
\frac1n\sum_k(f(x_k)-g(x_k))^2
}
$$

とする。半径 $u$ の球でクラスを覆うために必要な個数を $N(u)$ とすると、

$$
\widehat{\mathfrak R}^{\mathrm{one}}_n(F;S)
\le
4\alpha
+\frac{12}{\sqrt n}
\int_\alpha^{c/2}
\sqrt{\log N(u)}\,du.
$$

証明の流れ:

1. 各スケールで有限被覆を取る。
2. 関数をスケール間の増分の和に分解する。
3. 各増分に Massart の補題を適用する。
4. 全スケールのコストを積分する。

---

## 20. Dudley を基本定理につなぐ符号対称化

Dudley の証明は片側 supremum を評価する。
一方、基本定理は絶対値付き複雑度を使う。

$$
F^\pm=F\cup(-F)
$$

とすると、

$$
\widehat{\mathfrak R}_n(F;S)
=
\widehat{\mathfrak R}^{\mathrm{one}}_n(F^\pm;S).
$$

```lean
def signSymmetrization
    (F : H → X → ℝ) : H × Bool → X → ℝ :=
  fun hb x ↦ if hb.2 then F hb.1 x else -F hb.1 x
```

この等式により、観測標本上の entropy integral
$D_\alpha(S)$
を、そのまま共通 bridge の $C(S)$ に代入できる。

---

## 21. 予測器から損失、ERM まで

教師あり学習の損失クラスを

```lean
def supervisedLossClass
    (F : H → X → ℝ) (loss : ℝ → Y → ℝ) :
    H → (X × Y) → ℝ :=
  fun h z ↦ loss (F h z.1) z.2
```

と定義する。

有限仮説型と $L$-Lipschitz loss に対する contraction:

$$
\widehat{\mathfrak R}_n(\ell\circ F;S)
\le 2L\widehat{\mathfrak R}_n(F;S).
$$

さらに近似 ERM の決定論的不等式と合わせると、確率 $1-\delta$ 以上で

$$
R(A(S))-R(h^\star)
\le
4C(S)
+6b\sqrt{\frac{2\log(2/\delta)}{n}}
+\eta
$$

を得る。

---

## 22. 論文から現在の `ss` ブランチまで

論文で扱う中心部分:

- Rademacher 複雑度、一様偏差、symmetrization
- McDiarmid と高確率汎化評価
- 可算クラスから可分クラスへの拡張
- $\ell_2$、$\ell_1/\ell_\infty$、Dudley

現在の `ss` ブランチで接続された部分:

- 任意の標本依存上界 $C(S)$ を受け取る共通 bridge
- 信頼度 $\delta$ を直接受け取る API
- Hilbert 空間、kernel trace、RKHS
- ERM・近似 ERM と余剰誤差
- 有限クラスと一次元 Lipschitz 族の具体的被覆数

設計の中心:

> 各応用は固定標本上の複雑度だけを証明し、
> 確率論との接続は共通定理に任せる。

---

## 23. 現在の主な制限

- 任意の positive semidefinite kernel から RKHS を構成するのではなく、
  特徴写像から誘導される kernel を扱う。
- 一般の非有限可分仮説型に対する contraction は未実装である。
- ERM の存在を構成するのではなく、
  `IsERM`、`IsApproxERM` という述語で受け取る。
- 多次元 Lipschitz 族やニューラルネットワークの具体的被覆数評価は未実装である。

形式化により、数学的には暗黙になりやすい
可測性・可分性・有限性の必要箇所が明確になった。

---

## 24. 関連研究: 汎化保証と確率論の形式化

- Bagnall and Stewart (2019), MLCERT:
  Rocq で有限仮説クラスの PAC 型汎化保証を形式化。
- Tassarotti et al. (2021):
  Lean 3 で decision stump の PAC 学習可能性を形式化。
- Karayel and Tan (2023):
  Isabelle/HOL で McDiarmid を含む集中不等式を形式化。
- Affeldt et al. (2025):
  Rocq で測度論的な集中不等式を形式化。

本研究では、実数値・非有限の関数クラスについて、
積測度、非可算 supremum、symmetrization、Dudley を
Lean + Mathlib 上の一つの経路として接続する。

---

## 25. 関連研究: 現在の Lean 機械学習エコシステム

### Lean Machine Learning

- 機械学習理論の定義と定理を共有する Mathlib 上の curated library。
- アルゴリズム、性能指標、確率論、最適化の共通語彙を整備する。
- https://leanmachinelearning.org/

### Statistical Learning Theory in Lean 4

- Zhang, Lee, Liu による独立した大規模ライブラリ。
- Gaussian concentration、Dudley、局所化最小二乗法などを扱う。
- `lean-rademacher` の
  `separableSpaceSup_eq_real`
  を再利用している。
- https://github.com/YuanheZ/lean-stat-learning-theory

目的と重点は異なるが、Lean 上の統計的学習理論の基盤を相補的に広げている。

---

## 26. まとめ

1. 汎化では、標本から選ばれたモデルを守るために一様偏差を評価する。
2. Rademacher 複雑度は、関数クラスが標本上でノイズに合わせる能力を測る。
3. symmetrization と McDiarmid により、複雑度を高確率の汎化評価へ変換できる。
4. Lean では、非可算 supremum の可測性を稠密可算部分クラスで解決した。
5. 固定標本上の評価 $C(S)$ を証明すれば、
   線形予測器、RKHS、Dudley、ERM の保証へ共通 API で接続できる。

> モデル固有の幾何と共通の確率論を分離したことが、
> 形式化を再利用可能にしている。

資料:

- Lean: https://github.com/auto-res/lean-rademacher
- Preprint: https://arxiv.org/abs/2503.19605
- Published: https://doi.org/10.4230/LIPIcs.ITP.2026.8

---

# 補足スライド候補

---

## A. 決定論的閾値と標本依存閾値

全標本で同じ $C$ を使う場合:

$$
\Pr\left\{
\Delta_n(S)
\ge
2C+b\sqrt{\frac{2\log(1/\delta)}{n}}
\right\}
\le\delta.
$$

標本依存の $C(S)$ を使う場合:

$$
\Pr\left\{
\Delta_n(S)
\ge
2C(S)+3b\sqrt{\frac{2\log(2/\delta)}{n}}
\right\}
\le\delta.
$$

- 標本依存版は観測データに適応できる。
- 二つの集中事象を union bound で合わせるため、定数が増える。

---

## B. Dudley に現れる三つの定数

- $b$:
  関数値の一様上界。McDiarmid の集中項に使う。
- $c$:
  経験ノルムの上界。Dudley 積分の上端 $c/2$ に使う。
- $C$ または $C(S)$:
  経験 Rademacher 複雑度の数値上界。汎化評価の複雑度項に使う。

これらは役割が異なるため、Lean の定理でも別の引数として明示する。

---

## C. $n=0$ と正値条件

- Lean の実数では $0^{-1}=0$ なので、中心定義は $n=0$ でも定義できる。
- 正規化、平方根、Dudley integral を使う応用定理では $0<n$ を明示する。
- 「定義を総関数にすること」と「意味のある統計的定理の仮定」を分離している。

---

## D. 片側版と絶対値付き版

$$
\widehat{\mathfrak R}^{\mathrm{one}}_n(F;S)
=
\mathbb E_\sigma
\sup_h
\frac1n\sum_k\sigma_kF_h(z_k),
$$

$$
\widehat{\mathfrak R}_n(F;S)
=
\mathbb E_\sigma
\sup_h
\left|
\frac1n\sum_k\sigma_kF_h(z_k)
\right|.
$$

- Massart と Dudley の自然な形は片側版。
- 二側の汎化ギャップには絶対値付き版を使う。
- 単純な不等式の向きでは接続できないため、
  $F^\pm=F\cup(-F)$ による等式を使う。
