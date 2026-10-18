-- Shelf pieces: adds the key-points box at the top and the Replicate section at the end,
-- both built from the notebook's first cell (key-points, sources, notebook, excel).

local stringify = pandoc.utils.stringify

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'))
end

local function as_blocks(v)
  local t = pandoc.utils.type(v)
  if t == 'Inlines' then return { pandoc.Plain(v) } end
  if t == 'Blocks' then return v end
  return { pandoc.Plain(pandoc.Str(stringify(v))) }
end

local function key_points(m)
  if not m['key-points'] then return nil end
  local label = m['key-points-title'] and stringify(m['key-points-title'])
    or (m.type and stringify(m.type) == 'tutorial' and "What you'll learn" or 'Key points')
  local items = {}
  for _, kp in ipairs(m['key-points']) do table.insert(items, as_blocks(kp)) end
  return pandoc.Div({
    pandoc.Header(2, label, pandoc.Attr('key-points', { 'unnumbered', 'la-kp-title' })),
    pandoc.BulletList(items),
  }, pandoc.Attr('', { 'la-keypoints' }))
end

local function replicate(m)
  local nbf = m.notebook and stringify(m.notebook)
  local xl = m.excel and stringify(m.excel)
  if not (nbf or xl or m.sources) then return nil end
  local out = { pandoc.Header(2, 'Replicate this', pandoc.Attr('replicate', { 'unnumbered' })) }
  local how = {}
  if nbf then table.insert(how, 'Download the notebook and run it top to bottom in Jupyter (Python 3 with pandas and plotly).') end
  if xl then table.insert(how, 'Or open the Excel workbook: the same steps as formulas, no code needed.') end
  if #how > 0 then table.insert(out, pandoc.Para(pandoc.Str(table.concat(how, ' ')))) end
  local cards = {}
  if nbf then
    table.insert(cards, '<a class="la-file" href="' .. esc(nbf) .. '?download" download="' .. esc(nbf) .. '"><span class="kind">python</span><span class="name">' .. esc(nbf) .. '</span><span class="what">The full analysis, code and charts.</span></a>')
  end
  if xl then
    table.insert(cards, '<a class="la-file" href="' .. esc(xl) .. '" download><span class="kind">excel</span><span class="name">' .. esc(xl) .. '</span><span class="what">Every step as formulas you can click.</span></a>')
  end
  if #cards > 0 then
    table.insert(out, pandoc.RawBlock('html', '<div class="la-files-grid">' .. table.concat(cards) .. '</div>'))
  end
  if m.sources then
    table.insert(out, pandoc.Header(3, 'Sources', pandoc.Attr('sources', { 'unnumbered' })))
    local items = {}
    for _, s in ipairs(m.sources) do
      if pandoc.utils.type(s) == 'table' and s.name then
        local name = stringify(s.name)
        if s.url then
          table.insert(items, { pandoc.Plain({ pandoc.Link(name, stringify(s.url)) }) })
        else
          table.insert(items, { pandoc.Plain(pandoc.Str(name)) })
        end
      else
        table.insert(items, as_blocks(s))
      end
    end
    table.insert(out, pandoc.BulletList(items))
  end
  return pandoc.Div(out, pandoc.Attr('', { 'la-replicate' }))
end

function Pandoc(doc)
  local kp = key_points(doc.meta)
  if kp then table.insert(doc.blocks, 1, kp) end
  local rep = replicate(doc.meta)
  if rep then table.insert(doc.blocks, rep) end
  return doc
end
