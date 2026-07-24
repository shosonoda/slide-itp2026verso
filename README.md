# Slides

This template creates a [`reveal.js`](https://revealjs.com) slide presentation using
[verso-slides](https://github.com/leanprover/verso-slides). It includes a title slide and a slide
that demonstrates Lean code with an info panel.

## Marp

`marp.config.cjs` registers Lean 4 syntax highlighting. Run Marp CLI from the
repository root so the configuration is loaded automatically:

```bash
marp src/draft.md -o output/draft.html
```

To export the Marp slides as PDF:

```bash
mkdir -p output/pdf
npx @marp-team/marp-cli --pdf src/draft.md -o output/pdf/draft.pdf
```

Lean code fences can stay as ```` ```lean ```` (or ```` ```lean4 ````).

Font sizes are defined in `themes/lean-rademacher.css`. Its current values
match Marp Core's built-in `default` theme. The theme is registered for Marp
CLI by `marp.config.cjs` and for VS Code preview by `.vscode/settings.json`.

## Building

To build the slides, run:
```
$ lake exe generate-slides
```

The output is written to the `_slides/` directory. Run a local web server to view the presentation.

## More Features

See the [`verso-slides` demo file](https://github.com/leanprover/verso-slides/blob/main/Demo.lean) for
a comprehensive showcase of all available features, including:

* Treating sections of code as [`reveal.js` fragments](https://revealjs.com/fragments/)
* Fragment animations (block and inline)
* Speaker notes
* Custom slide backgrounds and transitions
* Vertical slides
* Code blocks in other languages using `reveal.js`'s built-in syntax highlighting

---

- 手動で追加
  - serve.py
  - .gitignore
  - prepare-pages.sh
    ```bash
    chmod +x prepare-pages.sh && ls -l prepare-pages.sh # 権限変更
    ```

- ローカル実行
  ```bash
  curl -sSfL https://raw.githubusercontent.com/leanprover/verso-templates/main/verso-init.sh | sh

  lake build
  lake exe generate-slides

  python3 serve.py 8000
  ```
  - URL: http://localhost:8000/
  - pdf表示: http://localhost:8000/?print-pdf

- GitHub Pages
  ```bash
  ./prepare-pages.sh # (root)/docs に移動 + touch .nojekyll
  ```

---
- copied ``demo.lean`` from https://github.com/leanprover/verso-slides/blob/main/Demo.lean
