local heading_stack = {}

-- Helper to get the output filename (without extension)
local function get_filename()
  local out = pandoc.state.output_file
  if out then
    return out:match("(.+)%..+") or out
  end
  return "note"
end

function Header(el)
  heading_stack[el.level] = pandoc.utils.stringify(el.content)
  for i = el.level + 1, 10 do heading_stack[i] = nil end

  if el.level > 6 then
    local prefix_parts = {}
    for i = 6, el.level - 1 do
      if heading_stack[i] and heading_stack[i] ~= "" then
        table.insert(prefix_parts, heading_stack[i])
      end
    end

    if #prefix_parts == 0 then
      for i = 5, 1, -1 do
        if heading_stack[i] and heading_stack[i] ~= "" then
          table.insert(prefix_parts, heading_stack[i])
          break 
        end
      end
    end
    
    local new_title = (#prefix_parts > 0 and table.concat(prefix_parts, " | ") .. " | " or "") .. pandoc.utils.stringify(el.content)
    return pandoc.Header(6, pandoc.Str(new_title), pandoc.Attr())
  end
  return el
end

function Image(el)
  -- Rewrites path from 'media/image1.png' to 'assets/FILENAME/image1.png'
  local filename = get_filename()
  local img_name = el.src:match("([^/]+)$")
  el.src = "assets/" .. filename .. "/" .. img_name
  return el
end
