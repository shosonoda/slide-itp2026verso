このプロジェクトでは統計的学習理論の Lean 形式化プロジェクト lean-rademacher に関するスライドを作成します．

- Lean project:
  - 公開版: https://github.com/auto-res/lean-rademacher.git
    - 概要: note/summary.md
  - 開発版: https://github.com/auto-res/lean-project.git

- Paper:
  - GitHub: https://github.com/shosonoda/-draft-LeanRademacher.git
  - Preprint: https://arxiv.org/abs/2503.19605
  - Published version: https://drops.dagstuhl.de/storage/00lipics/lipics-vol382-itp2026/LIPIcs.ITP.2026.8/LIPIcs.ITP.2026.8.pdf

- lean-rademacher と preprint の GitHub リポジトリは ../ にクローンされています．
- published version と preprint の内容は同じです．
- 現在のリポジトリ（ lean-rademacher "ss" branch ）は，preprint よりも開発が進んでいます．その概要はリポジトリの note/summary.md に反映されています．
- スライドは最新の状況（ ss branch, summary.md）に基づいて作成します．

- このリポジトリでは Lean verso-slides がセットアップされています．
- こちらから指示するまでスライドのデザイン（マージン，フォントサイズなど）は修正しないでください．文字が溢れていても文量の調整で対応しますので，そのままにしてください．

- 聴衆は機械学習理論にあまり馴染みがないので，汎化（generalization）や， Rademacher 複雑度を用いて汎化誤差が評価できることを丁寧に説明する必要があります．主要な定理の証明スケッチと，定理の使い方を説明しながら，Lean code を紹介していくスタイルにします．

- スライドの基本的な流れ:
  - 汎化の基本的な考え方
  - 基本定理（Rademacher複雑度による汎化誤差評価）の主張と証明の概要
    - 形式化にあたっての技術的な工夫
  - 具体例
    - 形式化にあたっての技術的な工夫
  - 関連研究
    - preprint 参照
    - https://leanmachinelearning.org/
    - https://github.com/YuanheZ/lean-stat-learning-theory

- まずシンプルな日本語の markdown で src/draft.md に流れをドラフトしてください．
