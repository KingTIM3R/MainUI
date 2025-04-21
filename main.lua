--[[
ModernSystemUI Library - Revised Appearance
Author: Your Name/Assistant
Description: A simple UI library for Roblox with a modern aesthetic.
--]]

local ModernSystemUI = {}
ModernSystemUI.__index = ModernSystemUI

local MAX_DROPDOWN_HEIGHT = 160 -- Max pixels the dropdown option list can occupy before scrolling
local ELEMENT_SPACING = 5     -- Pixels between elements in layouts
local PADDING = 10            -- General padding for containers/elements

-- Helper function to create UI elements more robustly
local function createElement(type, properties, parent, children)
    local element = Instance.new(type)
    for property, value in pairs(properties) do
        -- Handle specific types like Color3, UDim2, etc. safely if needed,
        -- but Instance.new usually handles basic types well.
        pcall(function()
            element[property] = value
        end)
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = element
        end
    end
    if parent then
        element.Parent = parent
    end
    return element
end

-- Function to make a frame draggable
local function makeDraggable(frame, dragHandle)
    local isDragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position
            frame:TweenSize(frame.Size * 1.02, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true) -- Subtle lift effect

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                    frame:TweenSize(frame.Size / 1.02, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true) -- Drop effect
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                end
            end)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Ensure drag ends if mouse leaves the handle area (optional but good practice)
    -- dragHandle.MouseLeave:Connect(function()
    --  -- isDragging = false -- Can be disruptive, consider implications
    -- end)
end


-- Initialize the UI Library
function ModernSystemUI:CreateWindow(title)
    -- Check if UI already exists to prevent duplicates
    local existingGui = game:GetService("CoreGui"):FindFirstChild("ModernSystemUI_ScreenGui")
    if existingGui then
        -- Option 1: Destroy existing and create new (simple)
         existingGui:Destroy()
        -- Option 2: Return the existing ContentFrame (more complex state management)
        -- return existingGui.MainFrame.ContentFrame
    end

    local ScreenGui = createElement("ScreenGui", {
        Name = "ModernSystemUI_ScreenGui",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Use Sibling to allow layering if multiple ScreenGuis exist
    }, game:GetService("CoreGui")) -- Prefer CoreGui for essential UI

    local MainFrame = createElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 450, 0, 350), -- Slightly adjusted size
        Position = UDim2.new(0.5, 0, 0.5, 0), -- Center using AnchorPoint
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(45, 48, 54), -- Darker blue-grey
        BorderSizePixel = 0 -- Remove default border
    }, ScreenGui, {
        createElement("UICorner", { CornerRadius = UDim.new(0, 8) }),
        createElement("UIStroke", { -- Outline
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(80, 85, 94),
            Thickness = 1.5,
        })
    })

    local DragHandle = createElement("Frame", {
        Name = "DragHandle",
        Size = UDim2.new(1, 0, 0, 35), -- Slightly taller handle
        BackgroundColor3 = Color3.fromRGB(55, 58, 64), -- Slightly lighter handle color
        BorderSizePixel = 0
    }, MainFrame, {
        -- Round only top corners
        createElement("UICorner", { CornerRadius = UDim.new(0, 8) })
        -- Need to clip bottom corners somehow if separate; easier to round the whole frame
    })

    local Title = createElement("TextLabel", {
        Name = "Title",
        Text = title or "Modern System UI",
        Size = UDim2.new(1, -20, 1, 0), -- Padding on sides
        Position = UDim2.new(0.5, 0, 0.5, 0), -- Center using AnchorPoint
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(210, 210, 215), -- Lighter text
        Font = Enum.Font.SourceSansBold, -- Bolder font for title
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Center -- Center align text
    }, DragHandle)

    local ContentFrame = createElement("ScrollingFrame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, 0, 1, -DragHandle.Size.Y.Offset), -- Fill below handle
        Position = UDim2.new(0, 0, 0, DragHandle.Size.Y.Offset),
        BackgroundColor3 = Color3.fromRGB(45, 48, 54), -- Match main frame bg
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), -- Auto-managed by UIListLayout usually
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Color3.fromRGB(80, 85, 94),
        ClipsDescendants = true,
    }, MainFrame, {
        createElement("UIPadding", { -- Add padding inside the content frame
            PaddingTop = UDim.new(0, PADDING),
            PaddingBottom = UDim.new(0, PADDING),
            PaddingLeft = UDim.new(0, PADDING),
            PaddingRight = UDim.new(0, PADDING),
        }),
        createElement("UIListLayout", {
            Padding = UDim.new(0, ELEMENT_SPACING), -- Space between elements
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top -- Start elements from top
        })
    })

    -- Make the UI draggable
    makeDraggable(MainFrame, DragHandle)

    -- Store elements for potential future access (optional)
    self.ScreenGui = ScreenGui
    self.MainFrame = MainFrame
    self.ContentFrame = ContentFrame

    -- Return the container where elements should be added
    return ContentFrame
end


-- Add a Button
function ModernSystemUI:AddButton(parent, text, callback)
    local Button = createElement("TextButton", {
        Name = "Button",
        Text = text or "Button",
        Size = UDim2.new(1, -PADDING * 2, 0, 35), -- Use padding var, slightly shorter
        LayoutOrder = 1, -- Ensure consistent layout order if mixing element types later
        BackgroundColor3 = Color3.fromRGB(66, 70, 77), -- Button color
        TextColor3 = Color3.fromRGB(220, 221, 222), -- Button text color
        Font = Enum.Font.SourceSansSemiBold,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = false -- Disable default color change on hover/press for custom effects later if needed
    }, parent, {
        createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
        createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(90, 95, 104),
            Thickness = 1,
        })
    })

    -- Basic Hover/Press effect (optional)
    Button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(76, 80, 87)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(66, 70, 77)}):Play()
    end)
    Button.MouseButton1Down:Connect(function()
         game:GetService("TweenService"):Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(56, 60, 67)}):Play()
    end)
     Button.MouseButton1Up:Connect(function()
         game:GetService("TweenService"):Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(76, 80, 87)}):Play() -- Return to hover state if mouse still over
     end)


    Button.MouseButton1Click:Connect(function()
        if callback then
            -- Use spawn or task.spawn for safety if callback might error or yield
            task.spawn(callback)
        end
    end)

    return Button -- Return the element for potential further customization
end


-- Add Dropdown
function ModernSystemUI:AddDropdown(parent, text, options, callback)
    local options = options or {}
    local dropdownHeight = 35 -- Match button height
    local optionHeight = 30   -- Height of each item in the list

    local DropdownContainer = createElement("Frame", { -- Use a container to manage layout better
        Name = "DropdownContainer",
        Size = UDim2.new(1, -PADDING * 2, 0, dropdownHeight), -- Size based on button appearance
        LayoutOrder = 2,
        BackgroundTransparency = 1, -- Container is invisible
        ClipsDescendants = false, -- Allow option frame to show outside bounds initially (it gets clipped later)
    }, parent)

    local DropdownButton = createElement("TextButton", {
        Name = "DropdownButton",
        Text = text or "Select an Option",
        Size = UDim2.new(1, 0, 1, 0), -- Fill container
        BackgroundColor3 = Color3.fromRGB(66, 70, 77),
        TextColor3 = Color3.fromRGB(220, 221, 222),
        Font = Enum.Font.SourceSansSemiBold,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 2 -- Ensure button is above option frame initially
    }, DropdownContainer, {
        createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
        createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(90, 95, 104),
            Thickness = 1,
        })
    })

    local OptionFrame = createElement("ScrollingFrame", {
        Name = "OptionFrame",
        Size = UDim2.new(1, 0, 0, 0), -- Initially zero height
        Position = UDim2.new(0, 0, 1, ELEMENT_SPACING), -- Position below the button with spacing
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Color3.fromRGB(55, 58, 64), -- Options background
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false, -- Start hidden
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(80, 85, 94),
        ZIndex = 10, -- Make sure options appear above other elements in the main content frame
        CanvasSize = UDim2.new(0,0,0,0) -- Will be set later
    }, DropdownContainer, { -- Parent to container for positioning
        createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
        createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(90, 95, 104),
            Thickness = 1,
        }),
        createElement("UIListLayout", {
            Padding = UDim.new(0, 2), -- Minimal padding between options
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top
        }),
        createElement("UIPadding", { -- Padding inside the options frame
             PaddingTop = UDim.new(0, 4),
             PaddingBottom = UDim.new(0, 4),
             PaddingLeft = UDim.new(0, 4),
             PaddingRight = UDim.new(0, 4),
         })
    })

    local totalContentHeight = 0
    local listLayout = OptionFrame:FindFirstChildOfClass("UIListLayout")
    local internalPadding = OptionFrame:FindFirstChildOfClass("UIPadding")

    -- Calculate total content height for CanvasSize
    local topBottomPad = (internalPadding and internalPadding.PaddingTop.Offset + internalPadding.PaddingBottom.Offset) or 0
    local listPadding = (listLayout and listLayout.Padding.Offset) or 0
    totalContentHeight = (#options * optionHeight) + (math.max(0, #options - 1) * listPadding) + topBottomPad


    for _, optionText in ipairs(options) do
        local OptionButton = createElement("TextButton", {
            Name = "Option",
            Text = optionText,
            Size = UDim2.new(1, -8, 0, optionHeight), -- Adjust size based on internal padding
            BackgroundColor3 = Color3.fromRGB(55, 58, 64), -- Match OptionFrame bg initially
            TextColor3 = Color3.fromRGB(200, 200, 205),
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, OptionFrame, {
             createElement("UICorner", { CornerRadius = UDim.new(0, 4) }) -- Slightly rounded options
        })

        OptionButton.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 75, 82)}):Play()
        end)
        OptionButton.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 58, 64)}):Play()
        end)

        OptionButton.MouseButton1Click:Connect(function()
            if callback then task.spawn(callback, optionText) end
            DropdownButton.Text = optionText -- Update display text
            -- Animate closing
            game:GetService("TweenService"):Create(OptionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.delay(0.2, function()
                 if OptionFrame and OptionFrame.Parent then -- Check exists before hiding
                    OptionFrame.Visible = false
                 end
            end)
            -- Update container size back to normal AFTER animation might be needed if layout shifts
             DropdownContainer.Size = UDim2.new(1, -PADDING * 2, 0, dropdownHeight)
             DropdownContainer.ClipsDescendants = false -- Reset clipping state maybe? Or handle differently. Let's keep it simple.
        end)
    end

    -- Set CanvasSize based on calculated total height
    OptionFrame.CanvasSize = UDim2.new(0, 0, 0, totalContentHeight)


    -- Dropdown Button Toggle Logic
    DropdownButton.MouseButton1Click:Connect(function()
        local isVisible = OptionFrame.Visible
        local targetHeight = math.min(totalContentHeight, MAX_DROPDOWN_HEIGHT) -- Use calculated height, capped

        if isVisible then
            -- Animate closing
            game:GetService("TweenService"):Create(OptionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
             task.delay(0.2, function()
                 if OptionFrame and OptionFrame.Parent then
                     OptionFrame.Visible = false
                 end
             end)
            DropdownContainer.Size = UDim2.new(1, -PADDING * 2, 0, dropdownHeight) -- Reset container size
            DropdownContainer.ClipsDescendants = false -- Disable clipping while closed
        else
            -- Make visible before animating size
            OptionFrame.Visible = true
             DropdownContainer.ClipsDescendants = true -- Enable clipping when open
            -- Animate opening
            game:GetService("TweenService"):Create(OptionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
            -- Adjust container size if needed (e.g., if options list pushes other elements) - often handled by parent layout automatically
            -- DropdownContainer.Size = UDim2.new(1, -PADDING * 2, 0, dropdownHeight + ELEMENT_SPACING + targetHeight) -- Example if needed, but usually better handled by parent UIListLayout adjusting space
        end
    end)

    -- Basic Hover/Press effect for Dropdown Button
    DropdownButton.MouseEnter:Connect(function() game:GetService("TweenService"):Create(DropdownButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(76, 80, 87)}):Play() end)
    DropdownButton.MouseLeave:Connect(function() game:GetService("TweenService"):Create(DropdownButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(66, 70, 77)}):Play() end)
    DropdownButton.MouseButton1Down:Connect(function() game:GetService("TweenService"):Create(DropdownButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(56, 60, 67)}):Play() end)
    DropdownButton.MouseButton1Up:Connect(function() game:GetService("TweenService"):Create(DropdownButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(76, 80, 87)}):Play() end)


    return DropdownContainer -- Return the main container
end

-- Example of adding other element types (placeholder)
function ModernSystemUI:AddLabel(parent, text)
    local Label = createElement("TextLabel", {
        Name = "Label",
        Text = text or "Label",
        Size = UDim2.new(1, -PADDING * 2, 0, 25),
        LayoutOrder = 0, -- Example layout order
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(180, 180, 185), -- Slightly dimmer text for labels
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    return Label
end


return ModernSystemUI
