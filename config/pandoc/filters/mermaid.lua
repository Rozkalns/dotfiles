-- Pandoc Lua filter: render mermaid code blocks to images using mmdc
-- Requires: npm install -g @mermaid-js/mermaid-cli

local system = require("pandoc.system")

local function mermaid(code, format)
    return system.with_temporary_directory("mermaid", function(dir)
        local input = pandoc.path.join({ dir, "input.mmd" })
        local output = pandoc.path.join({ dir, "output.png" })

        local f = io.open(input, "w")
        f:write(code)
        f:close()

        os.execute(string.format("mmdc -i %s -o %s -b transparent --scale 2", input, output))

        local img = io.open(output, "rb")
        if not img then
            io.stderr:write("WARNING: mermaid rendering failed\n")
            return nil
        end
        local data = img:read("*a")
        img:close()

        local mimetype = "image/png"
        local filename = "mermaid.png"

        return pandoc.Image({}, filename, "", { width = "100%" }),
            pandoc.mediabag.insert(filename, mimetype, data)
    end)
end

function CodeBlock(block)
    if block.classes[1] == "mermaid" then
        local img = mermaid(block.text, FORMAT)
        if img then
            return pandoc.Para({ img })
        end
    end
end
