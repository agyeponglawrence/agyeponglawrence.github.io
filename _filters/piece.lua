-- Shelf pieces and analysis summaries: adds the key-points box at the top, then at the end
-- a "Read the full piece" button (summaries), the Replicate section (notebooks) and a
-- subscribe box. Built from the front matter (key-points, source, where, sources, notebook, excel).

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

-- Summaries of pieces published elsewhere: the button to the full piece.
local function read_full(m)
  if not m.source then return nil end
  local where = m.where and stringify(m.where) or 'the original site'
  return pandoc.RawBlock('html', '<p class="la-read-full"><a class="la-btn" href="' .. esc(stringify(m.source))
    .. '" target="_blank" rel="noopener">Read the full piece on ' .. esc(where) .. ' ↗</a></p>')
end

-- The ask comes after the reader has had the piece. subscribe-url is set in _quarto.yml.
local function subscribe(m)
  if not m['subscribe-url'] then return nil end
  return pandoc.RawBlock('html', '<section class="la-next" aria-label="Subscribe">'
    .. '<p class="la-next-lead">Liked this? Get the next one.</p>'
    .. '<p class="la-next-sub">New analysis, data tools and the methods behind them, in your inbox every couple of weeks.</p>'
    .. '<a class="la-btn la-btn-ghost" href="' .. esc(stringify(m['subscribe-url'])) .. '" target="_blank" rel="noopener">Subscribe on Substack ↗</a>'
    .. '</section>')
end

function Pandoc(doc)
  local m = doc.meta
  -- NB-005 marks a notebook on this site; a summary of a piece published elsewhere shows No. 005.
  if m.source and m.nb then m.nb = pandoc.MetaString((stringify(m.nb):gsub('^NB%-', 'No. '))) end
  local kp = key_points(m)
  if kp then table.insert(doc.blocks, 1, kp) end
  for _, make in ipairs({ read_full, replicate, subscribe }) do
    local block = make(m)
    if block then table.insert(doc.blocks, block) end
  end
  return doc
end
