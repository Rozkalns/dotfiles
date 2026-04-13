-- Pandoc Lua filter: render mermaid code blocks to images using mmdc
-- Requires: npm install -g @mermaid-js/mermaid-cli

local system = require("pandoc.system")
local diagram_count = 0

local function mermaid(code, attrs)
    diagram_count = diagram_count + 1
    return system.with_temporary_directory("mermaid", function(dir)
        local input = pandoc.path.join({ dir, "input.mmd" })
        local output = pandoc.path.join({ dir, "output.png" })

        local f = io.open(input, "w")
        f:write(code)
        f:close()

        local ok = os.execute(string.format(
            "mmdc -i %s -o %s -b transparent --scale 2 2>/dev/null", input, output))
        if not ok then
            io.stderr:write("WARNING: mermaid rendering failed\n")
            return nil
        end

        local img = io.open(output, "rb")
        if not img then
            io.stderr:write("WARNING: mermaid output not found\n")
            return nil
        end
        local data = img:read("*a")
        img:close()

        local filename = string.format("mermaid-%d.png", diagram_count)
        pandoc.mediabag.insert(filename, "image/png", data)

        -- Use width from code block attributes, default to 65%
        local width = attrs and attrs["width"] or "65%"
        return pandoc.Image({}, filename, "", { width = width })
    end)
end

function CodeBlock(block)
    if block.classes[1] == "mermaid" then
        local img = mermaid(block.text, block.attributes)
        if img then
            return {
                pandoc.RawBlock("latex", "\\begin{center}"),
                pandoc.Para({ img }),
                pandoc.RawBlock("latex", "\\end{center}"),
            }
        end
    end
end
