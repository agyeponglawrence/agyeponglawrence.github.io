-- Post-render: writes the RSS feed (index.xml) for the shelf.
-- Quarto's own listing feed points link cards at the home page and picks up the tool
-- page, so the feed is built here instead: every notebook in shelf/*/ plus every analysis
-- piece (summary pages in analysis/, shelf/analysis.yml and the Substack posts in
-- shelf/substack.yml), newest first. Summaries link to their page here; the rest link to
-- where the piece lives.

local stringify = pandoc.utils.stringify
local sys = pandoc.system

local function read(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local s = f:read('a')
  f:close()
  return s
end

-- YAML is parsed as pandoc metadata; smart quotes and raw HTML off so titles stay as written.
local function meta_of(yaml)
  return pandoc.read('---\n' .. yaml .. '\n---\n', 'markdown-smart-raw_html').meta
end

local function str(v) return v and stringify(v) or nil end

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'))
end

local function rfc822(date)
  local y, m, d = tostring(date):match('^(%d%d%d%d)-(%d%d)-(%d%d)')
  if not y then return nil end
  local t = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
  return os.date('!%a, %d %b %Y 00:00:00 GMT', t)
end

local site = meta_of(read('_quarto.yml')).website
local base = str(site['site-url']):gsub('/$', '') .. '/'
local items = {}

local function add(m, link)
  if not (m.title and m.date) then return end
  local cats = {}
  for _, c in ipairs(m.categories or {}) do table.insert(cats, stringify(c)) end
  table.insert(items, {
    title = str(m.title), link = link, date = str(m.date),
    description = str(m.description) or str(m.subtitle), categories = cats,
  })
end

-- Analysis published elsewhere
for _, file in ipairs({ 'shelf/analysis.yml', 'shelf/substack.yml' }) do
  local links = read(file)
  if links then
    local indented = links:gsub('([^\n]*)', '  %1')
    for _, m in ipairs(meta_of('items:\n' .. indented).items or {}) do add(m, str(m.path)) end
  end
end

-- Summary pages: analysis/<name>.qmd ("_" files are never published)
local ok_dir, files = pcall(sys.list_directory, 'analysis')
for _, name in ipairs(ok_dir and files or {}) do
  if name:match('%.qmd$') and not name:match('^[_.]') then
    local yaml = (read('analysis/' .. name) or ''):match('^%-%-%-\n(.-)\n%-%-%-')
    if yaml then add(meta_of(yaml), base .. 'analysis/' .. name:gsub('%.qmd$', '.html')) end
  end
end

-- Notebooks and notes: shelf/<folder>/index.ipynb or index.qmd ("_" folders are never published)
for _, dir in ipairs(sys.list_directory('shelf')) do
  if not dir:match('^[_.]') then
    local nb, qmd = read('shelf/' .. dir .. '/index.ipynb'), read('shelf/' .. dir .. '/index.qmd')
    local yaml
    if nb then
      local cell = (pandoc.json.decode(nb, false).cells or {})[1]
      if cell and cell.cell_type == 'raw' then
        local src = type(cell.source) == 'table' and table.concat(cell.source) or cell.source
        yaml = src:match('^%s*%-%-%-\n(.-)\n%-%-%-')
      end
    elseif qmd then
      yaml = qmd:match('^%-%-%-\n(.-)\n%-%-%-')
    end
    if yaml then add(meta_of(yaml), base .. 'shelf/' .. dir .. '/') end
  end
end

table.sort(items, function(a, b) return a.date > b.date end)

local out = {
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">',
  '<channel>',
  '<title>' .. esc(str(site.title)) .. '</title>',
  '<link>' .. base .. '</link>',
  '<atom:link href="' .. base .. 'index.xml" rel="self" type="application/rss+xml"/>',
  '<description>' .. esc(str(site.description)) .. '</description>',
  '<language>en</language>',
}
if items[1] then table.insert(out, '<lastBuildDate>' .. rfc822(items[1].date) .. '</lastBuildDate>') end
for _, it in ipairs(items) do
  table.insert(out, '<item>')
  table.insert(out, '  <title>' .. esc(it.title) .. '</title>')
  table.insert(out, '  <link>' .. esc(it.link) .. '</link>')
  table.insert(out, '  <guid isPermaLink="true">' .. esc(it.link) .. '</guid>')
  if it.description then table.insert(out, '  <description>' .. esc(it.description) .. '</description>') end
  for _, c in ipairs(it.categories) do table.insert(out, '  <category>' .. esc(c) .. '</category>') end
  local date = rfc822(it.date)
  if date then table.insert(out, '  <pubDate>' .. date .. '</pubDate>') end
  table.insert(out, '</item>')
end
table.insert(out, '</channel>')
table.insert(out, '</rss>')

local dir = os.getenv('QUARTO_PROJECT_OUTPUT_DIR') or '_site'
local f = assert(io.open(dir .. '/index.xml', 'w'))
f:write(table.concat(out, '\n') .. '\n')
f:close()
