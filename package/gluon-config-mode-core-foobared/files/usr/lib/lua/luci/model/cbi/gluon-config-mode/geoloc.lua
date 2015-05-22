local wizard_dir = "/lib/gluon/config-mode/geoloc/"
local i18n = luci.i18n
local uci = luci.model.uci.cursor()
local fs = require "luci.fs"
local f, s

local geoloc = {}
local files = fs.dir(wizard_dir)

table.sort(files)

for _, entry in ipairs(files) do
  if entry:sub(1, 1) ~= '.' then
    table.insert(geoloc, dofile(wizard_dir .. '/' .. entry))
  end
end

f = SimpleForm("geoloc")
f.reset = false
f.template = "gluon/cbi/geoloc"

for _, s in ipairs(geoloc) do
  s.section(f)
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    for _, s in ipairs(geoloc) do
      s.handle(data)
    end

    luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode", "wizard2"))
  end

  return true
end

return f