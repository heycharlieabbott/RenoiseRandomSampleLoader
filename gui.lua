--[[============================================================================
gui.lua
============================================================================]] --

local gui = {}

--------------------------------------------------------------------------------
-- Local Functions & States
--------------------------------------------------------------------------------

-- status
local current_folder = ""
local current_samples = 1
local current_dialog = nil
local saved_paths = {}
local SAVED_PATHS_FILE = "saved_paths.txt"

--------------------------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------------------------

local function load_saved_paths()
    local file = io.open(SAVED_PATHS_FILE, "r")
    if file then
        saved_paths = {}
        for line in file:lines() do
            -- Trim whitespace and skip empty lines
            line = line:match("^%s*(.-)%s*$")
            if line ~= "" then
                table.insert(saved_paths, line)
            end
        end
        file:close()
    end
end

local function save_path(path)
    if path == "" then return end


    -- Check if path already exists
    for _, saved_path in ipairs(saved_paths) do
        if saved_path == path then
            return
        end
    end

    -- Add new path
    table.insert(saved_paths, path)

    -- Save to file
    local file = io.open(SAVED_PATHS_FILE, "w")
    if file then
        for _, saved_path in ipairs(saved_paths) do
            -- Ensure proper line endings and handle spaces
            file:write(saved_path .. "\n")
        end
        file:close()
    end
end

local function invoke_current_random()
    if current_folder ~= "" then
        load_random_samples(current_folder, current_samples)
    else
        renoise.app():show_warning("Please specify a folder path")
    end
end

--------------------------------------------------------------------------------
-- Public functions
--------------------------------------------------------------------------------

function gui.show_random_sample_dialog()
    -- Load saved paths
    load_saved_paths()

    -- check for already opened dialogs
    if (current_dialog and current_dialog.visible) then
        current_dialog:show()
        return
    end

    -- create and show a new dialog
    local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
    local CONTROL_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
    local DIALOG_BUTTON_HEIGHT = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
    local TEXT_WIDTH = 100
    local CONTROL_WIDTH = 200
    local INPUT_WIDTH = 150

    local vb = renoise.ViewBuilder()

    local folder_textfield = vb:textfield {
        width = INPUT_WIDTH,
        value = current_folder,
        notifier = function(value)
            current_folder = value
        end
    }

    local browse_button = vb:button {
        text = "Browse",
        width = INPUT_WIDTH,
        height = DIALOG_BUTTON_HEIGHT,
        notifier = function()
            local path = renoise.app():prompt_for_path("Select Sample Folder")
            if path and path ~= "" then
                current_folder = path
                folder_textfield.value = path
            end
        end
    }

    local saved_paths_popup = vb:popup {
        width = INPUT_WIDTH,
        items = saved_paths,
        notifier = function(index)
            if index > 0 then
                current_folder = saved_paths[index]
                folder_textfield.value = current_folder
            end
        end
    }

    local save_path_button = vb:button {
        text = "Save Path",
        width = INPUT_WIDTH,
        height = DIALOG_BUTTON_HEIGHT,
        notifier = function()
            if current_folder ~= "" then
                save_path(current_folder)
                -- Refresh the popup with new saved paths
                saved_paths_popup.items = saved_paths
            else
                renoise.app():show_warning("No path to save")
            end
        end
    }

    local samples_valuebox = vb:valuebox {
        min = 1,
        max = 120,
        value = current_samples,
        width = INPUT_WIDTH,
        notifier = function(value)
            current_samples = value
        end
    }

    local process_button = vb:button {
        text = "Load Random Samples",
        width = CONTROL_WIDTH,
        height = DIALOG_BUTTON_HEIGHT,
        notifier = invoke_current_random
    }

    local content_view = vb:column {
        uniform = true,
        margin = DIALOG_MARGIN,
        spacing = CONTROL_SPACING,

        vb:horizontal_aligner {
            mode = "justify",
            width = TEXT_WIDTH + INPUT_WIDTH + CONTROL_SPACING,

            vb:column {
                vb:text {
                    width = TEXT_WIDTH,
                    text = "Folder Path:"
                }
            },

            vb:column {
                folder_textfield
            }
        },

        vb:horizontal_aligner {
            mode = "justify",
            width = TEXT_WIDTH + INPUT_WIDTH + CONTROL_SPACING,

            vb:column {
                vb:text {
                    width = TEXT_WIDTH,
                    text = "Browse:"
                }
            },

            vb:column {
                browse_button
            }
        },

        vb:horizontal_aligner {
            mode = "justify",
            width = TEXT_WIDTH + INPUT_WIDTH + CONTROL_SPACING,

            vb:column {
                vb:text {
                    width = TEXT_WIDTH,
                    text = "Save Path:"
                }
            },

            vb:column {
                save_path_button
            }
        },

        vb:horizontal_aligner {
            mode = "justify",
            width = TEXT_WIDTH + INPUT_WIDTH + CONTROL_SPACING,

            vb:column {
                vb:text {
                    width = TEXT_WIDTH,
                    text = "Saved Paths:"
                }
            },

            vb:column {
                saved_paths_popup
            }
        },

        vb:horizontal_aligner {
            mode = "justify",
            width = TEXT_WIDTH + INPUT_WIDTH + CONTROL_SPACING,

            vb:column {
                vb:text {
                    width = TEXT_WIDTH,
                    text = "Number of Samples:"
                }
            },

            vb:column {
                samples_valuebox
            }
        },

        vb:horizontal_aligner {
            mode = "center",
            process_button
        }
    }

    local function key_handler(dialog, key)
        if (key.name == "esc") then
            dialog:close()
        elseif (key.name == "return") then
            invoke_current_random()
        else
            return key
        end
    end

    current_dialog = renoise.app():show_custom_dialog(
        "Random Sample Loader", content_view, key_handler)
end

return gui
