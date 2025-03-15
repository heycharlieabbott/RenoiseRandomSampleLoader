--[[============================================================================
main.lua
============================================================================]] --

local gui = require "gui"

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

local function get_random_files(folder_path, num_files)
    -- Clean up the path (remove trailing spaces and slashes)
    folder_path = folder_path:gsub("^%s*(.-)%s*$", "%1")
    folder_path = folder_path:gsub("/$", "")

    -- Get all wav files in the folder
    local files = {}
    local valid_extensions = { ".wav", ".WAV", ".aif", ".AIF", ".aiff", ".AIFF" }

    print("Checking folder: " .. folder_path)

    -- Check if directory exists using test command
    local exists = os.execute('test -d "' .. folder_path .. '"')
    if not exists then
        renoise.app():show_warning("Directory does not exist or is not accessible: " .. folder_path)
        return {}
    end

    -- Get all files in directory using find command to handle spaces and special characters
    local entries = {}
    local cmd = string.format('find "%s" -maxdepth 1 -type f', folder_path)
    local handle = io.popen(cmd)
    if not handle then
        renoise.app():show_warning("Failed to read directory: " .. folder_path)
        return {}
    end

    for file in handle:lines() do
        -- Check file extension
        local ext = string.match(file, "%.%w+$")
        if ext then
            for _, valid_ext in ipairs(valid_extensions) do
                if ext:lower() == valid_ext:lower() then
                    table.insert(entries, file)
                    break
                end
            end
        end
    end
    handle:close()

    -- Randomly select files
    local selected_files = {}
    local files_count = #entries

    if files_count == 0 then
        return {}
    end

    -- Adjust num_files if we don't have enough files
    num_files = math.min(num_files, files_count)

    -- Initialize random seed
    math.randomseed(os.time())

    -- Randomly select files
    while #selected_files < num_files do
        local index = math.random(1, files_count)
        local file = entries[index]

        -- Check if file is already selected
        local already_selected = false
        for _, selected in ipairs(selected_files) do
            if selected == file then
                already_selected = true
                break
            end
        end

        if not already_selected then
            table.insert(selected_files, file)
        end
    end

    return selected_files
end

--------------------------------------------------------------------------------
-- Public Functions (used by gui.lua)
--------------------------------------------------------------------------------

function load_random_samples(folder_path, num_samples)
    local song = renoise.song()
    local instrument = song.selected_instrument

    if not instrument then
        renoise.app():show_warning("No instrument selected")
        return
    end

    -- Get random files
    local files = get_random_files(folder_path, num_samples)

    if #files == 0 then
        renoise.app():show_warning("No audio files found in the specified folder")
        return
    end

    -- Load each file into a new sample slot
    for _, file in ipairs(files) do
        local sample_index = instrument.samples[#instrument.samples + 1]
        if not sample_index then
            instrument:insert_sample_at(#instrument.samples + 1)
        end

        local sample = instrument.samples[#instrument.samples]

        -- Load the audio file
        local success = pcall(function()
            sample.sample_buffer:load_from(file)
        end)

        if not success then
            renoise.app():show_warning("Failed to load file: " .. file)
        end
    end
end

--------------------------------------------------------------------------------
-- Menu & Key Binding Registration
--------------------------------------------------------------------------------

-- Add menu entry
renoise.tool():add_menu_entry {
    name = "Main Menu:Tools:Random Sample Loader...",
    invoke = gui.show_random_sample_dialog
}

-- Add keybinding
renoise.tool():add_keybinding {
    name = "Global:Tools:Random Sample Loader",
    invoke = gui.show_random_sample_dialog
}
