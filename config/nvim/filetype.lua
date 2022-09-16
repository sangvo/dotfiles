vim.filetype.add({
  extension = {
    ejs = "html",
    hbs = "handlebars",
    svx = "markdown",
    mdx = "markdown",
    rasi = "css",
    norg = "norg", -- TreeSitter
    patch = "patch",
    tsx = "typescriptreact",
    jsx = "typescriptreact",
  },
  filename = {
    [".prettierrc"] = "jsonc",
    [".eslintrc"] = "jsonc",
    ["tsconfig.json"] = "jsonc",
    ["jsconfig.json"] = "jsonc",
  },
})
