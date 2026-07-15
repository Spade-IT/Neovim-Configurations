-- discipline.lua -- the classic "cowboy" habit trainer.
--
-- If you mash h / j / k / l / + / - more than 10 times in a row (without a count),
-- Neovim nags you ("Hold it, Cowboy!") instead of moving, so you learn to use real
-- motions (w, }, 5j, /search, etc.) instead of spamming arrows-by-another-name.
--
-- Called once from lua/config/keymaps.lua:  require("config.discipline").cowboy()

local M = {}

function M.cowboy()
  ---@type table?
  local id
  local ok = true
  -- h/l = left/right, j/k = down/up, +/- = down/up to first non-blank.
  for _, key in ipairs({ "h", "j", "k", "l", "+", "-" }) do
    local count = 0
    local timer = assert(vim.uv.new_timer())
    local map = key
    vim.keymap.set("n", key, function()
      -- A real count (e.g. 5j) is deliberate movement -> reset and allow.
      if vim.v.count > 0 then
        count = 0
      end
      if count >= 10 and vim.bo.buftype ~= "nofile" then
        ok, id = pcall(vim.notify, "Hold it Cowboy!", vim.log.levels.WARN, {
          icon = "🤠",
          id = id,
          keep = function()
            return count >= 10
          end,
        })
        if not ok then
          id = nil
          return map
        end
      else
        count = count + 1
        -- Reset the streak after 2s of not pressing the key.
        timer:start(2000, 0, function()
          count = 0
        end)
        return map
      end
    end, { expr = true, silent = true })
  end
end

return M
