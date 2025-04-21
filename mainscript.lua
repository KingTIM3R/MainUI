-- Assuming the library script above is accessible (e.g., via require or loadstring)
-- local ModernSystemUI = require(Path.To.Your.Library)
-- or
-- local ModernSystemUI = loadstring(game:HttpGet("URL/To/Your/Library.lua"))()

-- Create the main window
local MainUIContent = ModernSystemUI:CreateWindow("My Awesome App") -- Returns the ContentFrame

-- Add UI Elements to the ContentFrame returned by CreateWindow
ModernSystemUI:AddLabel(MainUIContent, "This is a label:") -- Example Label

ModernSystemUI:AddButton(MainUIContent, "Click Me!", function()
    print("Button was clicked!")
end)

ModernSystemUI:AddButton(MainUIContent, "Another Button", function()
    print("Second button pressed.")
end)

ModernSystemUI:AddDropdown(MainUIContent, "Choose Fruit", {"Apple", "Banana", "Orange", "Grape", "Mango", "Pear"}, function(selectedFruit)
    print("Selected fruit:", selectedFruit)
end)

ModernSystemUI:AddDropdown(MainUIContent, "Settings", {"Low", "Medium", "High", "Ultra"}, function(setting)
    print("Setting changed to:", setting)
end)
