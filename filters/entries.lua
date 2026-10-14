-- Group each CV entry into a single Div.
--
-- An entry is a definition-list row (title + right-aligned date), optionally
-- followed by an italic subtitle paragraph and a bullet list. Pandoc emits
-- these as three sibling blocks. Wrapping them in `::: {.entry}` gives the
-- entry a normal block context, which the print stylesheet relies on: the
-- inner <dl>'s width: 100% resolves against the full column (so the date
-- floats to the true right edge), and the entry paginates predictably
-- instead of as a flex item.
--
-- The CV body lives inside the `::: {.cv}` fenced div, so we recurse into
-- Divs before grouping. Used only by build_pdf.sh; the website build leaves
-- the blocks as-is.

local function group_entries(blocks)
    local out = pandoc.Blocks({})
    local i = 1
    while i <= #blocks do
        local b = blocks[i]
        if b.t == "DefinitionList" then
            local group = pandoc.Blocks({ b })
            local j = i + 1
            if j <= #blocks and blocks[j].t == "Para" then
                group:insert(blocks[j])
                j = j + 1
            end
            if j <= #blocks and blocks[j].t == "BulletList" then
                group:insert(blocks[j])
                j = j + 1
            end
            out:insert(pandoc.Div(group, pandoc.Attr("", { "entry" })))
            i = j
        else
            out:insert(b)
            i = i + 1
        end
    end
    return out
end

local function walk_blocks(blocks)
    for _, b in ipairs(blocks) do
        if b.t == "Div" then
            b.content = walk_blocks(b.content)
        end
    end
    return group_entries(blocks)
end

function Pandoc(doc)
    doc.blocks = walk_blocks(doc.blocks)
    return doc
end
