local ns = vim.api.nvim_create_namespace("word_diff")

local function diff_nodes(bufnr, del, add)
    local a = vim.treesitter.get_node_text(del, bufnr)
    local b = vim.treesitter.get_node_text(add, bufnr)
    local hunks = vim.diff(
        table.concat(vim.split(a, ""), "\n"),
        table.concat(vim.split(b, ""), "\n"),
        { result_type = "indices" }) --[[@as integer[][]?]]
    assert(hunks and #hunks > 1)
    for _, h in ipairs(hunks) do
        if h[2] == 0 then
            h[1] = h[1] + 1
        end
        if h[4] == 0 then
            h[3] = h[3] + 1
        end
    end

    -- merge nearby hunks to reduce noise
    local mhunks = { hunks[2] }
    for j = 2, #hunks do
        local m, n = mhunks[#mhunks], hunks[j]
        if n[3] - m[3] - m[4] < 5 then
            m[4] = n[3] + n[4] - m[3]
            m[2] = n[1] + n[2] - m[1]
        else
            table.insert(mhunks, n)
        end
    end

    -- set extmark highlights
    local drow = del:start()
    local arow = add:start()
    for _, h in ipairs(mhunks) do
        vim.api.nvim_buf_set_extmark(bufnr, ns, drow, h[1] - 1, {
            end_col = h[1] - 1 + h[2],
            hl_group = "Reverse",
            strict = false,
            priority = 900,
        })
        vim.api.nvim_buf_set_extmark(bufnr, ns, arow, h[3] - 1, {
            end_col = h[3] - 1 + h[4],
            hl_group = "Reverse",
            strict = false,
            priority = 900,
        })
    end
end

local function apply_diff_highlights(bufnr, root)
    local query = vim.treesitter.query.parse("diff", "(changes) @changes")
    for _, ch in query:iter_captures(assert(root)) do
        local del = ch:child(0)
        while del do
            while del and del:type() ~= "deletion" do
                del = del:next_sibling()
            end
            if not del then
                goto next_change
            end
            local add = del --[[@as TSNode?]]
            while add and add:type() == "deletion" do
                add = add:next_sibling()
            end
            if not add then
                goto next_change
            end
            if add:type() ~= "addition" then
                del = add
                goto next_hunk
            end

            while del and add and del:type() == "deletion" and add:type() == "addition" do
                diff_nodes(bufnr, del, add)
                del = del:next_sibling()
                add = add:next_sibling()
            end
            del = add
            ::next_hunk::
        end
        ::next_change::
    end
end

local function apply_highlights(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local parser = vim.treesitter.get_parser(bufnr)
    if not parser then
        return
    end
    local trees = parser:parse(true)
    if not trees or #trees == 0 then
        return
    end
    local root = trees[1]:root()
    if vim.bo[bufnr].filetype == "diff" then
        apply_diff_highlights(bufnr, root)
    else
        parser:for_each_tree(function(_, ltree)
            for _, child in pairs(ltree:children()) do
                for _, tree in pairs(child:trees()) do
                    apply_diff_highlights(bufnr, tree:root())
                end
            end
        end)
    end
end

local function define_hl()
    vim.api.nvim_set_hl(0, "Reverse", { reverse = true, default = true })
end

local function setup()
    define_hl()
    local group = vim.api.nvim_create_augroup("Wordiff", {})
    vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = define_hl })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "diff", "gitcommit" },
        callback = function(ctx)
            apply_highlights(ctx.buf)
            vim.api.nvim_buf_attach(ctx.buf, false, {
                on_lines = function()
                    vim.schedule_wrap(apply_highlights)(ctx.buf)
                end
            })
        end
    })
end

return { setup = setup }
