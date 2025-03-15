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

--------------------------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------------------------

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
    local INPUT_WIDTH = 150 -- New consistent width for all inputs

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

    local samples_valuebox = vb:valuebox {
        min = 1,
        max = 100,
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
