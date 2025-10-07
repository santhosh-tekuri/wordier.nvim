<img width="2456" height="616" alt="image" src="https://github.com/user-attachments/assets/93fbd100-b416-4363-8277-22aa85d3b366" />


- shows word-diff for filetypes `diff` and `gitcommit`
- uses `reverse` highlights

useful in following scenarios:
- you frequently work with diff files
- you are using `git commit -v`
- you use `git add` to interactively editing patches
- useful in undo picker from [picker.nvim](https://github.com/santhosh-tekuri/picker.nvim)
  - unfortunately this does not work with snacks undo picker as the preview filetype is not `diff`

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
