
- shows word-diff for filetypes `diff` and `gitcommit`
- uses `reverse` highlights

useful in following scenarios:
- you frequently work with diff files
- you use git add's to interactively editing patches
- useful in undo picker from [picker.nvim](https://github.com/santhosh-tekuri/picker.nvim)
  - note does not work with snacks undo picker as the preview filetype is not `diff`

## Plugin ID

```text
santhosh-tekuri/wordiff.nvim
https://github.com/santhosh-tekuri/wordiff.nvim
```

## Configuration

call `setup` function without any arguments

```lua
require("wordiff").setup()
```
