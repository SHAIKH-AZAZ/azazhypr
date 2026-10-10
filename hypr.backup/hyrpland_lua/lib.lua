local M = {}

local function quote(value)
  value = tostring(value)
  if value:find("[%s#]") or value:find("^https?://") then
    return '"' .. value:gsub('"', '\\"') .. '"'
  end
  return value
end

function M.lines(items)
  local out = {}
  for _, item in ipairs(items) do
    if type(item) == "string" then
      table.insert(out, item)
    elseif item.kind == "comment" then
      table.insert(out, "# " .. item.text)
    elseif item.kind == "blank" then
      table.insert(out, "")
    elseif item.kind == "source" then
      table.insert(out, "source = " .. item.path)
    elseif item.kind == "var" then
      table.insert(out, item.name .. " = " .. item.value)
    elseif item.kind == "env" then
      table.insert(out, "env = " .. item.name .. "," .. item.value)
    elseif item.kind == "exec_once" then
      table.insert(out, "exec-once = " .. item.command)
    elseif item.kind == "bind" then
      local bind_type = item.bind_type or "bindd"
      local desc = item.description and (", " .. item.description) or ""
      table.insert(out, string.format("%s = %s, %s%s, %s%s",
        bind_type,
        item.mod or "",
        item.key,
        desc,
        item.dispatcher,
        item.arg and (", " .. item.arg) or ""
      ))
    elseif item.kind == "rule" then
      table.insert(out, item.rule_type .. " = " .. item.value)
    elseif item.kind == "block" then
      table.insert(out, item.name .. " {")
      for key, value in pairs(item.values) do
        table.insert(out, "  " .. key .. " = " .. tostring(value))
      end
      table.insert(out, "}")
    end
  end
  return table.concat(out, "\n") .. "\n"
end

function M.write_file(path, content)
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

function M.source(path)
  return { kind = "source", path = path }
end

function M.var(name, value)
  return { kind = "var", name = name, value = value }
end

function M.env(name, value)
  return { kind = "env", name = name, value = value }
end

function M.exec_once(command)
  return { kind = "exec_once", command = command }
end

function M.bind(item)
  item.kind = "bind"
  return item
end

function M.rule(rule_type, value)
  return { kind = "rule", rule_type = rule_type, value = value }
end

function M.comment(text)
  return { kind = "comment", text = text }
end

function M.blank()
  return { kind = "blank" }
end

M.quote = quote

return M
