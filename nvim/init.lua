-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.g.lazyvim_check_order = false

vim.keymap.set("n", "<F5>", function()
  local file = vim.fn.expand("%:p") -- Đường dẫn đầy đủ
  local dir = vim.fn.expand("%:p:h") -- Thư mục chứa file
  local filename = vim.fn.expand("%:t:r") -- Tên không có phần mở rộng
  local ext = vim.fn.expand("%:e") -- Phần mở rộng (.cpp, .py, ...)
  local is_windows = vim.fn.has("win32") == 1
  local term_cmd = "" -- Lệnh cuối cùng để chạy trong terminal

  -- Nếu là C++
  if ext == "cpp" then
    local exe = is_windows and (filename .. ".exe") or ("./" .. filename)
    local exe_path = dir .. "/" .. (is_windows and (filename .. ".exe") or filename)

    local src_time = vim.fn.getftime(file)
    local exe_time = vim.fn.getftime(exe_path)
    local compile_needed = exe_time < src_time or exe_time == -1

    local compile_cmd
    if compile_needed then
      if is_windows then
        compile_cmd = string.format('cd /d "%s" && echo Compiling... && g++ "%s" -o "%s"', dir, file, filename)
      else
        compile_cmd = string.format('cd "%s" && echo "Compiling..." && g++ "%s" -o "%s"', dir, file, filename)
      end
    end

    local run_cmd = is_windows and string.format('"%s"', exe) or string.format("%s", exe)

    if compile_needed then
      term_cmd = compile_cmd .. " && echo Running... && " .. run_cmd
    else
      term_cmd = string.format('cd "%s" && echo "Running existing build..." && %s', dir, run_cmd)
    end

  -- Nếu là Python
  elseif ext == "py" then
    local py_cmd = is_windows and "python" or "python3"
    term_cmd = string.format('cd "%s" && echo "Running Python script..." && %s "%s"', dir, py_cmd, file)

  -- Nếu là loại file khác
  else
    vim.notify("⚠️ File này không hỗ trợ chạy bằng F5!", vim.log.levels.WARN)
    return
  end

  -- Mở terminal bên phải và thực thi
  vim.cmd("vsplit | vertical resize 50 | terminal " .. term_cmd)
end, { desc = "Smart Run (C++/Python)", noremap = true, silent = true })
