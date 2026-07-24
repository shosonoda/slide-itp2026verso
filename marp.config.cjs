const lean = require('./vendor/highlightjs-lean/lean')

module.exports = {
  themeSet: './themes',
  engine: ({ marp }) => {
    marp.highlightjs.registerLanguage('lean', lean)
    marp.highlightjs.registerAliases('lean4', { languageName: 'lean' })
    return marp
  },
}
