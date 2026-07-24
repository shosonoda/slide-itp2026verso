---
marp: true
# style: |
#   section {
#       justify-content: start;
#   }
paginate: true
theme: lean-rademacher
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

<!-- _class: title -->

## Lean Formalization of Generalization Error Bounds by Rademacher Complexity and Dudley's Entropy Integral

Sho Sonoda, Kazumi Kasaura, Yuma Mizuno, Kei Tsukamoto, Naoto Onda

**ITP 2026 · Lean 4 + Mathlib**

Presenter: Sho Sonoda, RIKEN AIP / CyberAgent Inc · 26 July 2026

---

## この発表で扱うこと

汎化誤差評価とは、有限個の訓練データに基づいて選んだ学習モデルが、
未知のデータにもどの程度性能を発揮しうるかを確率論的に評価することである。

本発表では、

- Rademacher 複雑度を用いた基本的な汎化評価
- 線形予測器・RKHS・Dudley entropy integral への応用
- それらを Lean 4 + Mathlib で形式化する際の工夫

を説明する。

---

## 機械学習は有限標本から予測則を選ぶ

- 未知の分布 $\mu$ から訓練データ $S=(z_1,\ldots,z_n)$ を得る。
- 学習アルゴリズムは標本を見て、関数クラス $\mathcal F$ から
  $\widehat f=A(S)$ を選ぶ。
- 本当に知りたいのは、訓練データ $S$ 上ではなく未知のデータ $Z \sim \mu$ 上での性能である。
- ただしこれは観測できない．そこで，確率論的に評価をする．

<!-- $$
\text{未知の分布}
\longrightarrow
\text{訓練標本 }S
\longrightarrow
\text{学習 }A
\longrightarrow
\widehat f
$$ -->

---

## 経験損失と期待損失

以後、仮説は実数値関数 $f:\mathcal Z\to\mathbb R$ とし、
$f(z)$ 自体をデータ点 $z$ における損失とみなす。
予測器 $g$ と損失関数 $\ell$ を分ける場合は、
$f(x,y)=\ell(g(x),y)$ と合成してから考える。

$$
\widehat L_S(f)
=\frac1n\sum_{k=1}^n f(z_k),
\qquad
L(f)
=\mathbb E_{Z\sim\mu}[f(Z)].
$$

- $\widehat L_S(f)$: 経験損失（訓練誤差）。訓練データから計算できる。
- $L(f)$: 期待損失（テスト誤差）。未知の分布に関する平均なので、直接は計算できない。
- 差 $\left|\widehat L_S(f)-L(f)\right|$ を汎化ギャップという。

---

## 汎化ギャップの一様評価

学習後の $\widehat f=A(S)$ は標本 $S$ に依存するので，
固定した各 $f$ に対する確率評価を、そのまま $\widehat f$ の評価には使えない。

$$
\Delta_n(S)
:=
\sup_{f\in\mathcal F}
\left|\widehat L_S(f)-L(f)\right|.
$$

一様偏差 $\Delta_n(S)$ を評価すれば、

$$
\left|\widehat L_S(\widehat f)-L(\widehat f)\right|
\le \Delta_n(S)
$$

が、標本を見た後に選んだモデルにも成立する。

---

## 一様偏差から学習結果の保証へ

$\widehat f$ が $\eta$-近似 ERM、すなわち

$$
\widehat L_S(\widehat f)
\le \widehat L_S(f)+\eta
\qquad(\forall f\in\mathcal F)
$$

を満たすとする。ここで $f^\star\in\mathcal F$ は任意に固定した比較対象である。
期待損失の最小化解が存在する場合には
$f^\star\in\operatorname*{argmin}_{f\in\mathcal F}L(f)$ と選べばよい。

> **定理（近似 ERM の決定論的 oracle inequality）**
>
> 任意の比較対象 $f^\star\in\mathcal F$ に対して、
>
> $$
> L(\widehat f)-L(f^\star)
> \le 2\Delta_n(S)+\eta.
> $$

Lean の定理も $f^\star$ が最小化解であることを仮定しない。

したがって、発表の中心的な課題は
$\Delta_n(S)$ を小さく抑えることである。

---

## Lean: 期待損失・経験損失・余剰損失

```lean
def populationRisk
    [MeasurableSpace Ω]
    (ℓ : H → 𝒵 → ℝ) (μ : Measure Ω)
    (Z : Ω → 𝒵) (h : H) : ℝ :=
  ∫ ω, ℓ h (Z ω) ∂μ

def empiricalRisk
    (n : ℕ) (ℓ : H → 𝒵 → ℝ)
    (S : Fin n → 𝒵) (h : H) : ℝ :=
  (n : ℝ)⁻¹ * ∑ k : Fin n, ℓ h (S k)

def excessRisk
    [MeasurableSpace Ω]
    (ℓ : H → 𝒵 → ℝ) (μ : Measure Ω)
    (Z : Ω → 𝒵) (h hstar : H) : ℝ :=
  populationRisk ℓ μ Z h - populationRisk ℓ μ Z hstar

def riskDeviation
    [MeasurableSpace Ω]
    (n : ℕ) (ℓ : H → 𝒵 → ℝ) (μ : Measure Ω)
    (Z : Ω → 𝒵) (S : Fin n → 𝒵) (h : H) : ℝ :=
  |empiricalRisk n ℓ S h - populationRisk ℓ μ Z h|
```

それぞれ $L(f)$、$\widehat L_S(f)$、
$L(\widehat f)-L(f^\star)$ に対応する。

---

## Lean: 近似 ERM と決定論的 oracle inequality

```lean
def IsApproxERM
    (η : ℝ) (n : ℕ) (ℓ : H → 𝒵 → ℝ)
    (S : Fin n → 𝒵) (hhat : H) : Prop :=
  ∀ h, empiricalRisk n ℓ S hhat ≤
    empiricalRisk n ℓ S h + η

theorem IsApproxERM.excessRisk_le_two_mul_uniformDeviation
    {ℓ : H → 𝒵 → ℝ} {Z : Ω → 𝒵} {S : Fin n → 𝒵}
    {hhat hstar : H} {η : ℝ}
    (hERM : IsApproxERM η n ℓ S hhat)
    (hbounded :
      BddAbove (Set.range fun h ↦ riskDeviation n ℓ μ Z S h)) :
    excessRisk ℓ μ Z hhat hstar ≤
      2 * uniformDeviation n ℓ μ Z S + η
```

数学上の $\widehat f,f^\star\in\mathcal F$ が、
Lean では添字 `hhat hstar : H` と評価写像 `ℓ : H → 𝒵 → ℝ`
で表される。

---

## Rademacher 複雑度の直観

標本 $S=(z_1,\ldots,z_n)$ を固定し、各点にランダムな符号 $\sigma_k\in\{-1,+1\}$ を付ける。

$$
\frac1n\sum_{k=1}^n \sigma_k f(z_k)
$$

を大きくできる $f\in\mathcal F$ を探す。

- 小さい: クラスはランダムなノイズに合わせにくい。
- 大きい: クラスは多くのパターンを表現でき、過学習しやすい。
- 「標本を見てから $f$ を選ぶ自由度」を測る量である。

---

## 経験 Rademacher 複雑度: 絶対値付き版と片側版

$$
\widehat{\mathfrak R}_n(\mathcal F;S)
:=
\mathbb E_\sigma
\left[
\sup_{f\in\mathcal F}
\left|
\frac1n\sum_{k=1}^n
\sigma_k f(z_k)
\right|
\right],
$$

$$
\widehat{\mathfrak R}^{\mathrm{one}}_n(\mathcal F;S)
:=
\mathbb E_\sigma
\left[
\sup_{f\in\mathcal F}
\frac1n\sum_{k=1}^n\sigma_k f(z_k)
\right].
$$

期待 Rademacher 複雑度は
$\mathfrak R_n(\mathcal F)
:=\mathbb E_S[\widehat{\mathfrak R}_n(\mathcal F;S)]$。

---

## Lean: 有限符号平均による二つの経験量

```lean
def Signs (n : ℕ) : Type := Fin n → ({-1, 1} : Finset ℤ)

def empiricalRademacherComplexity
    (n : ℕ) (f : ι → 𝒳 → ℝ) (S : Fin n → 𝒳) : ℝ :=
  (Fintype.card (Signs n) : ℝ)⁻¹ *
    ∑ σ : Signs n, ⨆ i,
      |(n : ℝ)⁻¹ * ∑ k : Fin n, (σ k : ℝ) * f i (S k)|

def empiricalRademacherComplexity_without_abs
    (n : ℕ) (f : ι → 𝒳 → ℝ) (S : Fin n → 𝒳) : ℝ :=
  (Fintype.card (Signs n) : ℝ)⁻¹ *
    ∑ σ : Signs n, ⨆ i,
      (n : ℝ)⁻¹ * ∑ k : Fin n, (σ k : ℝ) * f i (S k)
```

---

## Lean: 期待量と一様偏差

```lean
def rademacherComplexity
    (n : ℕ) (f : ι → 𝒳 → ℝ)
    (μ : Measure Ω) (X : Ω → 𝒳) : ℝ :=
  μⁿ[fun ω : Fin n → Ω ↦
    empiricalRademacherComplexity n f (X ∘ ω)]

def uniformDeviation
    (n : ℕ) (f : ι → 𝒳 → ℝ)
    (μ : Measure Ω) (X : Ω → 𝒳)
    (S : Fin n → 𝒳) : ℝ :=
  ⨆ i, |(n : ℝ)⁻¹ * ∑ k : Fin n, f i (S k) -
    μ[fun ω' ↦ f i (X ω')]|
```

`f : ι → 𝒳 → ℝ` は $\mathcal F$ の列挙、
`i : ι` は一つの関数 $f_i\in\mathcal F$ に対応する。

---

## 基本定理: Rademacher 複雑度による汎化評価

関数クラス $\mathcal F$ が $|f(z)|\le b$
（すべての $f\in\mathcal F,z\in\mathcal Z$）を満たすとする。

> **定理（Rademacher 複雑度による基本汎化評価）**
>
> 適切な可測性・可分性・連続性の条件の下で、
>
> $$
> \mathbb E_S[\Delta_n(S)]
> \le 2\mathfrak R_n(\mathcal F),
> $$
>
> $$
> \Pr\left\{
> \Delta_n(S)
> \ge 2\mathfrak R_n(\mathcal F)+\varepsilon
> \right\}
> \le
> \exp\left(-\frac{n\varepsilon^2}{2b^2}\right).
> $$

$\varepsilon=b\sqrt{2\log(1/\delta)/n}$ とすれば、
確率 $1-\delta$ 以上で
$\Delta_n(S)<2\mathfrak R_n(\mathcal F)+\varepsilon$ が成り立つ。

---

## Lean: 可分クラスに対する基本定理の型

```lean
theorem uniform_deviation_tail_bound_separable_of_pos
    [MeasurableSpace 𝒳] [Nonempty 𝒳] [Nonempty H]
    [TopologicalSpace H] [SeparableSpace H]
    [FirstCountableTopology H] [IsProbabilityMeasure μ]
    (F : H → 𝒳 → ℝ) (hF_meas : ∀ h, Measurable (F h))
    (X : Ω → 𝒳) (hX : Measurable X)
    {b : ℝ} (hb : 0 < b)
    (hF_bound : ∀ h x, |F h x| ≤ b)
    (hF_cont : ∀ x : 𝒳, Continuous fun h ↦ F h x)
    {ε : ℝ} (hε : 0 ≤ ε) :
    (μⁿ {S |
      2 * rademacherComplexity n F μ X + ε ≤
        uniformDeviation n F μ X (X ∘ S)}).toReal ≤
      (-ε ^ 2 * n / (2 * b ^ 2)).exp
```

数学上の $\mathcal F$ を `H` で添字付けた `F` として表し、
可測性・一様有界性・添字方向の連続性を型に明示している。

---

## 証明スケッチ 1: symmetrization

> **定理（期待一様偏差の評価）**
>
> 独立な ghost sample $S'=(Z'_1,\ldots,Z'_n)$ を導入すると、
>
> $$
> \begin{aligned}
> \mathbb E_S[\Delta_n(S)]
> &\le
> \mathbb E_{S,S'}\sup_{f\in\mathcal F}
> \left|\frac1n\sum_k(f(Z_k)-f(Z'_k))\right| \\
> &=
> \mathbb E_{S,S',\sigma}\sup_{f\in\mathcal F}
> \left|\frac1n\sum_k\sigma_k(f(Z_k)-f(Z'_k))\right| \\
> &\le 2\mathfrak R_n(\mathcal F).
> \end{aligned}
> $$

Lean では、ghost sample の積測度、符号反転による積分の不変性、
supremum の三角不等式を順に合成する。

---

## Lean: symmetrization から期待値評価へ

```lean
theorem
    uniform_deviation_expectation_le_two_smul_rademacher_complexity
    [Nonempty ι] [Countable ι] [IsProbabilityMeasure μ]
    (hn : 0 < n) (X : Ω → 𝒳)
    (hf : ∀ i, Measurable (f i ∘ X))
    {b : ℝ} (hb : 0 ≤ b)
    (hf' : ∀ i x, |f i x| ≤ b) :
    μⁿ[fun ω : Fin n → Ω ↦
      uniformDeviation n f μ X (X ∘ ω)] ≤
      2 * rademacherComplexity n f μ X
```

`Countable ι` によって supremum の可測性を確保した形をまず証明し、
後で可分クラスへ持ち上げる。

---

## 証明スケッチ 2: McDiarmid

標本の一要素だけを $z_k$ から $z'_k$ に置き換える。

> **補題（一座標置換に対する感度）**
>
> $|f(z)|\le b$ なら、
> $\left|\Delta_n(S)-\Delta_n(S^{(k\leftarrow z'_k)})\right|
> \le 2b/n$。

McDiarmid の不等式から、

$$
\Pr\left\{
\Delta_n-\mathbb E[\Delta_n]\ge\varepsilon
\right\}
\le
\exp\left(-\frac{n\varepsilon^2}{2b^2}\right).
$$

期待値評価と合わせれば基本定理を得る。

Lean では標本を `Function.update S i x'` で一座標だけ置換し、
この感度評価を積測度版 McDiarmid の不等式へ渡す。

---

## Lean: 一様偏差の bounded difference

```lean
theorem uniformDeviation_bounded_difference
    [Nonempty ι] [IsProbabilityMeasure μ]
    (hn : 0 < n) (X : Ω → 𝒳)
    (hf : ∀ i, Measurable (f i ∘ X))
    {b : ℝ} (hf' : ∀ i z, |f i z| ≤ b)
    (i : Fin n) (S : Fin n → 𝒳) (x' : 𝒳) :
    |uniformDeviation n f μ X S -
      uniformDeviation n f μ X
        (Function.update S i x')| ≤
      (n : ℝ)⁻¹ * 2 * b
```

「一座標だけ違う標本」を `Function.update` で直接表すため、
McDiarmid の有界差分仮定と同じ形になる。

---

## 観測した複雑度を残す

$\mathfrak R_n(\mathcal F)$ は分布に依存し、直接は観測できない。
一方、$\widehat{\mathfrak R}_n(\mathcal F;S)$ は training 標本から計算できる量である．

経験 Rademacher 複雑度も一要素の置換に対する変化が
$2b/n$ 以下になる。下側集中を基本定理と union bound で合わせると、

$$
\Pr\left\{
\Delta_n(S)
\ge
2\widehat{\mathfrak R}_n(\mathcal F;S)+3\varepsilon
\right\}
\le
2\exp\left(-\frac{n\varepsilon^2}{2b^2}\right)
$$

を得る。これにより、経験 Rademacher 複雑度と期待 Rademacher 複雑度を接続できる。

---

## 形式化上の工夫: i.i.d. 標本の表現

一つの確率変数 $X:\Omega\to\mathcal Z$ と積測度
$\mu^n=\operatorname{Measure.pi}(\lambda\_\Rightarrow\mu)$ を使い、
$\omega:\operatorname{Fin}n\to\Omega$ に対して $S=X\circ\omega$ と表す。

別案は $n$ 個の確率変数 $X_1,\ldots,X_n$ と、
同分布性・独立性を毎回仮定する方法である。積測度表現なら、

- 各座標評価の分布が $\mu$ であること、
- 座標評価の族が独立であること、
- 各座標に同じ可測写像 $X$ を合成しても独立であること

を一度証明して再利用できる。さらに一座標置換が `Function.update`
となり、McDiarmid の仮定と直接対応する。

---

## 形式化上の工夫: Rademacher 符号の表現

$$
\operatorname{Signs}(n)
=\operatorname{Fin}n\to\{-1,+1\}
$$

を有限型とし、$2^n$ 個の符号列上の明示的な平均を取る。

他の表現との比較:

- `Fin n → Bool` では、$\pm1$ への変換と実数への coercion が毎回必要。
- 符号列を `List` や `Finset` に格納すると、長さ・値域・全列挙性を
  別々に証明する必要がある。
- 確率変数として定義すると、有限標本上の単純な平均にも
  可測性・積分の事務処理が入る。
- `Signs n` は長さと値域を型が保証する `Fintype` なので、
  `∑ σ : Signs n, ...`、符号反転、要素数 $2^n$ を直接扱える。

---

## 非可算な上限を可測にする

可算個の可測関数の上限は可測である。
しかし、非可算クラス $\mathcal F$ 上の supremum は一般には可測でない。
本形式化を通じて可測となる条件を明らかにした．

> **補題（可算稠密列上の上限）**
>
> 非空な可分パラメータ空間 $H$ 上の連続関数 $g:H\to\mathbb R$ と、
> 可算稠密列 $(h_m)_{m\in\mathbb N}$ に対して
>
> $$
> \sup_{h\in H}g(h)
> =
> \sup_{m\in\mathbb N}g(h_m).
> $$

応用では、各 $x$ に対する評価写像 $h\mapsto F(h,x)$ の連続性から
必要な $g$ の連続性を導く。

---

## Lean: `denseSeq` と可算稠密部分への制限

`denseSeq : ℕ → H` は Mathlib が選択公理で固定する列で、
`H` の任意の非空開集合にその項が入る。
計算用ではなく、非可算 supremum を可算化する証明装置である。

```lean
def denseSeq
    [TopologicalSpace H] [SeparableSpace H] [Nonempty H] : ℕ → H :=
  Classical.choose (exists_dense_seq H)

theorem denseRange_denseSeq
    [TopologicalSpace H] [SeparableSpace H] [Nonempty H] :
    DenseRange (denseSeq H)
```

`denseSeq H` は可分空間 `H` の可算稠密部分を列として選んだもの。
`DenseRange` は、空でない任意の開集合にその列の項が入ることを表す。

---

## Lean: 稠密列上の上限へ移す

```lean
noncomputable abbrev denseRestriction
    [TopologicalSpace H] [SeparableSpace H] [Nonempty H]
    (F : H → α) : ℕ → α :=
  F ∘ denseSeq H

theorem separableSpaceSup_eq_real
    [TopologicalSpace H] [SeparableSpace H] [Nonempty H]
    {g : H → ℝ} (hg : Continuous g) :
    ⨆ h : H, g h = ⨆ m : ℕ, g (denseSeq H m)
```

型が示すとおり、上限の一致には `Continuous g` が必要である。
この補題を用いて、経験複雑度・期待複雑度・一様偏差が稠密制限で変わらないことを示す。

---

## 応用の雛形: 標本ごとの評価から汎化保証へ

利用者は標本ごとの上界

$$
\widehat{\mathfrak R}_n(\mathcal F;S)\le C(S)
$$

だけを証明すればよい。次の基本汎化定理が、モデルに依存しない
確率論の部分を処理する。

> **定理（標本依存上界から得られる基本汎化評価）**
>
> $|f(z)|\le b$ と上の標本ごとの評価が成り立つなら、
>
> $$
> \Pr\left\{
> \Delta_n(S)
> \ge
> 2C(S)
> +3b\sqrt{\frac{2\log(2/\delta)}{n}}
> \right\}
> \le\delta.
> $$

---

## Lean: 標本依存上界を受け取る基本汎化定理

```lean
theorem
    uniform_deviation_tail_bound_separable_of_sample_empirical_le_delta
    [MeasurableSpace 𝒳] [Nonempty 𝒳] [Nonempty H]
    [TopologicalSpace H] [SeparableSpace H]
    [FirstCountableTopology H] [IsProbabilityMeasure μ]
    (hn : 0 < n)
    (F : H → 𝒳 → ℝ) (hF_meas : ∀ h, Measurable (F h))
    (X : Ω → 𝒳) (hX : Measurable X)
    (C : (Fin n → 𝒳) → ℝ)
    {b δ : ℝ} (hb : 0 < b)
    (hF_bound : ∀ h x, |F h x| ≤ b)
    (hF_cont : ∀ x, Continuous fun h ↦ F h x)
    (hC : ∀ S, empiricalRademacherComplexity n F S ≤ C S)
    (hδ : 0 < δ) (hδ_one : δ ≤ 1) :
    (μⁿ {S |
      2 * C (X ∘ S) +
        3 * (b * Real.sqrt (2 * Real.log (2 / δ) / n)) ≤
          uniformDeviation n F μ X (X ∘ S)}).toReal ≤ δ
```

`hC` だけがモデル固有で、残りの集中評価はこの定理が共通に処理する。

<!-- 応用の手順:

$$
\text{関数クラスを定義}
\to
\widehat{\mathfrak R}_n\le C(S)
\to
\text{基本汎化定理}
\to
\text{汎化・余剰誤差}
$$ -->

---

## 例1: $\ell_2$ 制約付き線形予測器

$$
f_w(x)=\langle w,x\rangle,
\qquad
\|w\|_2\le W.
$$

> **定理（$\ell_2$ 線形予測器の経験複雑度）**
>
> 固定標本 $S=(x_1,\ldots,x_n)$ に対して、
>
> $$
> \widehat{\mathfrak R}_n(\mathcal F;S)
> \le
> \frac{W}{n}
> \sqrt{\sum_{k=1}^n\|x_k\|_2^2}.
> $$

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

## Lean: $\ell_2$ 線形予測器の実装

```lean
noncomputable def linearPredictorL2
    {d : ℕ} {W X : ℝ}
    (w : Metric.closedBall
      (0 : EuclideanSpace ℝ (Fin d)) W)
    (x : Metric.closedBall
      (0 : EuclideanSpace ℝ (Fin d)) X) : ℝ :=
  @inner ℝ _ _
    (w : EuclideanSpace ℝ (Fin d))
    (x : EuclideanSpace ℝ (Fin d))
```

重みと入力を閉球の subtype として受け取り、実装本体は内積そのものである。

---

## Lean: 固定標本上の $\ell_2$ 評価

```lean
theorem linear_predictor_l2_empirical_bound_of_sample
    (d n : ℕ) (W X : ℝ) (hW : 0 ≤ W)
    (S : Fin n →
      Metric.closedBall
        (0 : EuclideanSpace ℝ (Fin d)) X) :
    empiricalRademacherComplexity n
        (linearPredictorL2 :
          Metric.closedBall
              (0 : EuclideanSpace ℝ (Fin d)) W →
            Metric.closedBall
              (0 : EuclideanSpace ℝ (Fin d)) X → ℝ) S
      ≤ W * (n : ℝ)⁻¹ *
        Real.sqrt
          (∑ k : Fin n,
            ‖(S k : EuclideanSpace ℝ (Fin d))‖ ^ 2)
```

右辺に観測標本のノルムを残したまま、基本汎化定理の `C S` に渡せる。

---

## $\ell_2$ の end-to-end 評価

$\|x_k\|\le X$ なら、関数値の上界は $b=XW$ である。
基本汎化定理に

$$
C(S)
=
\frac Wn\sqrt{\sum_k\|x_k\|_2^2}
$$

を代入する。

> **定理（$\ell_2$ 線形予測器の標本依存汎化評価）**
>
> 確率 $1-\delta$ 以上で、
>
> $$
> \Delta_n(S)<
> \frac{2W}{n}\sqrt{\sum_k\|x_k\|_2^2}
> +3XW\sqrt{\frac{2\log(2/\delta)}{n}}.
> $$

観測標本のノルムが小さければ、一様半径だけを使う評価より鋭くなる。

---

## Lean: $\ell_2$ の end-to-end 評価の型

```lean
theorem
    linear_predictor_l2_uniform_deviation_tail_bound_of_sample_delta
    [IsProbabilityMeasure μ]
    (d : ℕ) (W X : ℝ) (hn : 0 < n)
    (hX : 0 < X) (hW : 0 < W)
    (Z : Ω → Metric.closedBall
      (0 : EuclideanSpace ℝ (Fin d)) X)
    (hZ : Measurable Z)
    {δ : ℝ} (hδ : 0 < δ) (hδ_one : δ ≤ 1) :
    (μⁿ {S : Fin n → Ω |
      2 * (W * (n : ℝ)⁻¹ *
        Real.sqrt (∑ k : Fin n,
          ‖(Z (S k) : EuclideanSpace ℝ (Fin d))‖ ^ 2)) +
      3 * ((X * W) *
        Real.sqrt (2 * Real.log (2 / δ) / n)) ≤
      uniformDeviation n
        (linearPredictorL2 :
          Metric.closedBall
              (0 : EuclideanSpace ℝ (Fin d)) W →
            Metric.closedBall
              (0 : EuclideanSpace ℝ (Fin d)) X → ℝ)
        μ Z (Z ∘ S)}).toReal
      ≤ δ
```

---

## 例2: $\ell_1/\ell_\infty$ 線形予測器

$$
f_w(x)=\sum_{j=1}^d w_jx_j,
\qquad
\|w\|_1\le W.
$$

> **定理（$\ell_1/\ell_\infty$ 線形予測器の経験複雑度）**
>
> $d,n>0$ なら、固定標本 $S=(x_1,\ldots,x_n)$ に対して
>
> $$
> \widehat{\mathfrak R}_n(\mathcal F;S)
> \le WQ_\infty(S)\sqrt{2\log(2d)},
> \qquad
> Q_\infty(S)=\frac1n\sup_{j<d}
> \sqrt{\sum_k|x_{k,j}|^2}.
> $$

証明の要点:

- $\ell_1/\ell_\infty$ 双対性で、$2d$ 個の signed coordinate に帰着する。
- Massart の補題により $\sqrt{\log(2d)}$ が現れる。
- $|x_j|\le X_\infty$ なら $Q_\infty(S)\le X_\infty/\sqrt n$。

---

## 例3: RKHS は Hilbert 空間の証明を再利用する

特徴写像 $\Phi(x)\in\mathcal H$ と

$$
K(x,x')=\langle\Phi(x),\Phi(x')\rangle,
\qquad
f_w(x)=\langle w,\Phi(x)\rangle,
\qquad
\|w\|\le\Lambda
$$

を考える。

> **定理（RKHS 予測器の kernel trace 評価）**
>
> $\Lambda\ge0$ なら、固定標本 $S=(x_1,\ldots,x_n)$ に対して
>
> $$
> \widehat{\mathfrak R}_n(\mathcal F;S)
> \le
> \frac{\Lambda}{n}
> \sqrt{\sum_kK(x_k,x_k)}.
> $$

- 右辺は観測した kernel trace に依存する。
- $K(x,x)\le r^2$ なら $r\Lambda/\sqrt n$。
- 同じ基本汎化定理から、kernel trace を残した高確率評価を得る。

---

## 例4: Dudley entropy integral

標本 $S$ 上の関数間の擬距離を

$$
d_S(f,g)
=
\sqrt{
\frac1n\sum_k(f(x_k)-g(x_k))^2
}
$$

とする。半径 $u$ の球でクラス $\mathcal F$ を覆うために必要な個数を
$N(u,\mathcal F,d_S)$ とする。

> **定理（Dudley entropy integral）**
>
> $n>0$、$0<\alpha<c/2$、$\|f\|_S\le c$ と全有界性を仮定すると、
>
> $$
> \widehat{\mathfrak R}^{\mathrm{one}}_n(\mathcal F;S)
> \le
> 4\alpha
> +\frac{12}{\sqrt n}
> \int_\alpha^{c/2}
> \sqrt{\log N(u,\mathcal F,d_S)}\,du.
> $$

---

## Dudley の証明の流れ

証明の流れ:

1. 各スケールで有限被覆を取る。
2. 関数をスケール間の増分の和に分解する。
3. 各増分に Massart の補題を適用する。
4. 全スケールのコストを積分する。

---

## Dudley を基本定理につなぐ符号対称化

Dudley は片側 supremum、基本定理は絶対値付き複雑度を使う。

$$
\mathcal F^\pm=\mathcal F\cup(-\mathcal F)
$$

$$
\widehat{\mathfrak R}_n(\mathcal F;S)
=
\widehat{\mathfrak R}^{\mathrm{one}}_n(\mathcal F^\pm;S).
$$

```lean
def signSymmetrization
    (F : ι → 𝒳 → ℝ) : ι × Bool → 𝒳 → ℝ :=
  fun ib x ↦ if ib.2 then F ib.1 x else -F ib.1 x
```

Bool で $F i$ と $-F i$ を添字付ける実装である。
これにより、観測標本上の entropy integral $D_\alpha(S)$ を
基本汎化定理の $C(S)$ に代入できる。

---

## 予測器から損失、ERM まで

教師あり学習の損失クラスを

```lean
def supervisedLossClass
    {𝒳 𝒴 : Type*}
    (F : H → 𝒳 → ℝ) (loss : ℝ → 𝒴 → ℝ) :
    H → (𝒳 × 𝒴) → ℝ :=
  fun h z ↦ loss (F h z.1) z.2
```

と定義する。

> **定理（有限仮説型に対する contraction）**
>
> 損失が $\rho$-Lipschitz なら、
>
> $$
> \widehat{\mathfrak R}_n(\ell\circ\mathcal F;S)
> \le 2\rho\widehat{\mathfrak R}_n(\mathcal F;S).
> $$

---

## 損失クラスから余剰損失へ

> **定理（近似 ERM の余剰損失評価）**
>
> 基本汎化定理と決定論的 oracle inequality を合わせると、
> 確率 $1-\delta$ 以上で
>
> $$
> L(\widehat f)-L(f^\star)
> \le
> 4C(S)
> +6b\sqrt{\frac{2\log(2/\delta)}{n}}
> +\eta.
> $$

<!-- ---

## 論文から現在の `ss` ブランチまで

論文で扱う中心部分:

- Rademacher 複雑度、一様偏差、symmetrization
- McDiarmid と高確率汎化評価
- 可算クラスから可分クラスへの拡張
- $\ell_2$、$\ell_1/\ell_\infty$、Dudley

現在の `ss` ブランチで接続された部分:

- 任意の標本依存上界 $C(S)$ を受け取る基本汎化定理
- 信頼度 $\delta$ を直接受け取る API
- Hilbert 空間、kernel trace、RKHS
- ERM・近似 ERM と余剰誤差
- 有限クラスと一次元 Lipschitz 族の具体的被覆数

設計の中心:

> 各応用は固定標本上の複雑度だけを証明し、
> 確率論との接続は共通定理に任せる。 -->

---

## 現在の主な残課題

- 任意の positive semidefinite kernel から RKHS を構成するのではなく、
  特徴写像から誘導される kernel を扱う。
- 一般の非有限可分仮説型に対する contraction は未実装である。
- ERM の存在を構成するのではなく、
  ERM・近似 ERM の性質を述語として受け取る。
- 多次元 Lipschitz 族やニューラルネットワークの具体的被覆数評価は未実装である。

形式化により、数学的には暗黙になりやすい
可測性・可分性・有限性の必要箇所が明確になった。

---

## 関連研究: 汎化保証と確率論の形式化

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

## 関連研究: 現在の Lean 機械学習エコシステム

### Lean Machine Learning

- 機械学習理論の定義と定理を共有する Mathlib 上の curated library。
- アルゴリズム、性能指標、確率論、最適化の共通語彙を整備する。
- https://leanmachinelearning.org/

### Statistical Learning Theory in Lean 4

- Zhang, Lee, Liu による独立した大規模ライブラリ。
- Gaussian concentration、Dudley、局所化最小二乗法などを扱う。
- `lean-rademacher` の可分空間上の supremum を
  可算稠密列へ制限する議論を再利用している。
- https://github.com/YuanheZ/lean-stat-learning-theory

---

## まとめ

1. 学習済みモデルは訓練データに依存するので，その汎化は一様偏差を評価する。
2. Rademacher 複雑度は、関数クラスが標本上でノイズに合わせる能力を測る。
3. symmetrization と McDiarmid により、複雑度を高確率の汎化評価へ変換できる。
4. Lean では、非可算 supremum の可測性を稠密可算部分クラスで解決した。
5. 固定標本上の評価 $C(S)$ を証明すれば、
   同じ基本汎化定理から線形予測器、RKHS、Dudley、ERM の保証を得られる。

**再利用性の鍵:** モデル固有の幾何と共通の確率論を分離する。

資料:

- [Lean repository](https://github.com/auto-res/lean-rademacher)
- [Preprint](https://arxiv.org/abs/2503.19605) /
  [Published version](https://doi.org/10.4230/LIPIcs.ITP.2026.8)

---

<!-- _class: title -->

# 補足スライド候補

---

## 決定論的閾値と標本依存閾値

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

## Dudley に現れる三つの定数

- $b$:
  関数値の一様上界。McDiarmid の集中項に使う。
- $c$:
  経験ノルムの上界。Dudley 積分の上端 $c/2$ に使う。
- $C$ または $C(S)$:
  経験 Rademacher 複雑度の数値上界。汎化評価の複雑度項に使う。

これらは役割が異なるため、Lean の定理でも別の引数として明示する。

---

## $n=0$ と正値条件

- Lean の実数では $0^{-1}=0$ なので、中心定義は $n=0$ でも定義できる。
- 正規化、平方根、Dudley integral を使う応用定理では $0<n$ を明示する。
- 「定義を総関数にすること」と「意味のある統計的定理の仮定」を分離している。

---

## 片側版と絶対値付き版

$$
\widehat{\mathfrak R}^{\mathrm{one}}_n(\mathcal F;S)
=
\mathbb E_\sigma
\sup_{f\in\mathcal F}
\frac1n\sum_k\sigma_kf(z_k),
$$

$$
\widehat{\mathfrak R}_n(\mathcal F;S)
=
\mathbb E_\sigma
\sup_{f\in\mathcal F}
\left|
\frac1n\sum_k\sigma_kf(z_k)
\right|.
$$

- Massart と Dudley の自然な形は片側版。
- 二側の汎化ギャップには絶対値付き版を使う。
- 単純な不等式の向きでは接続できないため、
  $\mathcal F^\pm=\mathcal F\cup(-\mathcal F)$ による等式を使う。
