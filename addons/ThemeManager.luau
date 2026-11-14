local HttpService = game:GetService('HttpService')

local ThemeManager = {} do
    ThemeManager.Folder = 'UILibSettings'
    ThemeManager.Library = nil
    ThemeManager.DefaultTheme = 'awp'
    ThemeManager.Fields = { 'FontColor', 'MainColor', 'AccentColor', 'BackgroundColor', 'OutlineColor' }

    ThemeManager.BuiltInThemes = {
        ['awp']              = { 1, HttpService:JSONDecode('{"FontColor":"ececef","MainColor":"131316","AccentColor":"5a6ea8","BackgroundColor":"0a0a0c","OutlineColor":"26262b"}') },
        ['awp Old']          = { 2, HttpService:JSONDecode('{"FontColor":"e8e8ee","MainColor":"131317","AccentColor":"ad7038","BackgroundColor":"0c0c0f","OutlineColor":"25252d"}') },
        ['Nord']             = { 3, HttpService:JSONDecode('{"FontColor":"eceff4","MainColor":"3b4252","AccentColor":"88c0d0","BackgroundColor":"2e3440","OutlineColor":"4c566a"}') },
        ['Dracula']          = { 4, HttpService:JSONDecode('{"FontColor":"f8f8f2","MainColor":"343746","AccentColor":"bd93f9","BackgroundColor":"282a36","OutlineColor":"44475a"}') },
        ['Catppuccin Mocha'] = { 5, HttpService:JSONDecode('{"FontColor":"cdd6f4","MainColor":"1e1e2e","AccentColor":"cba6f7","BackgroundColor":"181825","OutlineColor":"45475a"}') },
        ['Gruvbox']          = { 6, HttpService:JSONDecode('{"FontColor":"ebdbb2","MainColor":"282828","AccentColor":"d79921","BackgroundColor":"1d2021","OutlineColor":"504945"}') },
        ['Rosé Pine']        = { 7, HttpService:JSONDecode('{"FontColor":"e0def4","MainColor":"1f1d2e","AccentColor":"c4a7e7","BackgroundColor":"191724","OutlineColor":"403d52"}') },
        ['One Dark']         = { 8, HttpService:JSONDecode('{"FontColor":"abb2bf","MainColor":"282c34","AccentColor":"61afef","BackgroundColor":"21252b","OutlineColor":"3e4451"}') },
        ['Monokai']          = { 9, HttpService:JSONDecode('{"FontColor":"f8f8f2","MainColor":"272822","AccentColor":"a6e22e","BackgroundColor":"1e1f1c","OutlineColor":"49483e"}') },
        ['Kanagawa']         = { 10, HttpService:JSONDecode('{"FontColor":"dcd7ba","MainColor":"1f1f28","AccentColor":"7e9cd8","BackgroundColor":"16161d","OutlineColor":"363646"}') },
        ['Everforest']       = { 11, HttpService:JSONDecode('{"FontColor":"d3c6aa","MainColor":"2d353b","AccentColor":"a7c080","BackgroundColor":"232a2e","OutlineColor":"475258"}') },
        ['Midnight']         = { 12, HttpService:JSONDecode('{"FontColor":"f0f0f0","MainColor":"0a0a0a","AccentColor":"3b82f6","BackgroundColor":"000000","OutlineColor":"1f1f1f"}') },
        ['Crimson']          = { 13, HttpService:JSONDecode('{"FontColor":"ecdcdc","MainColor":"160e10","AccentColor":"e11d48","BackgroundColor":"0d0809","OutlineColor":"2e1c20"}') },
        ['Linoria']          = { 14, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}') },
        ['BBot']             = { 15, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
        ['Fatality']         = { 16, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
        ['Jester']           = { 17, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
        ['Mint']             = { 18, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
        ['Tokyo Night']      = { 19, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
        ['Ubuntu']           = { 20, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
        ['Quartz']           = { 21, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
    }

    function ThemeManager:SetLibrary(lib)
        self.Library = lib
    end

    function ThemeManager:ThemesDir()
        return self.Folder .. '/themes'
    end

    function ThemeManager:BuildFolderTree()
        if self.Library then self.Library:EnsureFolder(self:ThemesDir()) end
    end

    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function ThemeManager:SetDefaultTheme(name)
        assert(not self.Built, '[lib] SetDefaultTheme has to run before ApplyToTab')
        self.DefaultTheme = name
    end

    function ThemeManager:GetCustomTheme(name)
        local clean = self.Library:SanitizeName(name)
        if not clean then return nil end

        local raw = self.Library.FS:Read(self:ThemesDir() .. '/' .. clean .. '.json')
        if not raw then return nil end

        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(decoded) == 'table' then return decoded end

        warn(("[lib] couldn't load theme '%s': file is corrupted"):format(clean))
    end

    function ThemeManager:ReloadCustomThemes()
        local out = {}

        for _, name in ipairs(self.Library.FS:List(self:ThemesDir(), 'json')) do
            if not self.BuiltInThemes[name] then table.insert(out, name) end
        end

        return out
    end

    function ThemeManager:GetThemeList()
        local list = {}
        for name in next, self.BuiltInThemes do table.insert(list, name) end
        table.sort(list, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

        for _, name in ipairs(self:ReloadCustomThemes()) do table.insert(list, name) end
        return list
    end

    function ThemeManager:ApplyTheme(theme)
        local builtin = self.BuiltInThemes[theme]
        local scheme = builtin and builtin[2] or self:GetCustomTheme(theme)
        if not scheme then return false end

        local colors = {}
        for _, field in ipairs(self.Fields) do
            if scheme[field] ~= nil then
                local ok, color = pcall(Color3.fromHex, scheme[field])
                if not ok then return false, ("[lib] theme '%s' has an invalid %s"):format(tostring(theme), field) end

                colors[field] = color
            end
        end

        self.Applying = true

        for _, field in ipairs(self.Fields) do
            if colors[field] then
                self.Library[field] = colors[field]
                if Options[field] then Options[field]:SetValueRGB(colors[field]) end
            end
        end

        self.Applying = false
        self:ThemeUpdate()
        return true
    end

    function ThemeManager:ThemeUpdate()
        local library = self.Library

        for _, field in ipairs(self.Fields) do
            if Options and Options[field] then
                library[field] = Options[field].Value
            end
        end

        library.AccentColorDark = library:GetDarkerColor(library.AccentColor)
        library:ApplyStyle()

        if library.Window then library.Window:UpdateGradient() end
    end

    function ThemeManager:GetDefault()
        local saved = self.Library.FS:Read(self:ThemesDir() .. '/default.txt')
        saved = saved and saved:gsub('%.json$', '')

        for _, name in ipairs({ saved or '', self.DefaultTheme, 'awp' }) do
            if self.BuiltInThemes[name] or (name ~= '' and self:GetCustomTheme(name)) then
                return name
            end
        end
    end

    function ThemeManager:LoadDefault()
        Options.ThemeManager_ThemeList:SetValue(self:GetDefault())
    end

    function ThemeManager:SaveDefault(theme)
        return self.Library.FS:Write(self:ThemesDir() .. '/default.txt', theme)
    end

    function ThemeManager:SaveCustomTheme(name)
        local clean, why = self.Library:SanitizeName(name)
        if not clean then return false, why end

        local theme = {}
        for _, field in ipairs(self.Fields) do
            theme[field] = Options[field].Value:ToHex()
        end

        return self.Library.FS:Write(self:ThemesDir() .. '/' .. clean .. '.json', HttpService:JSONEncode(theme))
    end

    function ThemeManager:DeleteCustomTheme(name)
        if self.BuiltInThemes[name] then return false, "[lib] built-in themes can't be deleted" end

        local clean, why = self.Library:SanitizeName(name)
        if not clean then return false, why end

        return self.Library.FS:Delete(self:ThemesDir() .. '/' .. clean .. '.json')
    end

    function ThemeManager:CreateThemeManager(groupbox)
        local library = self.Library
        self.Built = true

        groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = library.BackgroundColor, Transparency = false, Gradient = false })
        groupbox:AddLabel('Main color'):AddColorPicker('MainColor', { Default = library.MainColor, Transparency = false, Gradient = false })
        groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = library.AccentColor, Transparency = false, Gradient = false })
        groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = library.OutlineColor, Transparency = false, Gradient = false })
        groupbox:AddLabel('Font color'):AddColorPicker('FontColor', { Default = library.FontColor, Transparency = false, Gradient = false })

        groupbox:AddDivider()
        groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = self:GetThemeList(), Default = self:GetDefault(), Searchable = true })

        local function refresh(select)
            Options.ThemeManager_ThemeList:SetValues(self:GetThemeList())
            Options.ThemeManager_ThemeList:SetValue(select or self:GetDefault())
        end

        groupbox:AddButton('Set as default', function()
            local name = Options.ThemeManager_ThemeList.Value
            if not name then return end

            local ok, err = self:SaveDefault(name)
            if not ok then return library:Notify(tostring(err)) end

            library:Notify(string.format('Set default theme to %q', name))
        end)

        groupbox:AddDivider()
        groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })

        groupbox:AddButton('Save theme', function()
            local name = Options.ThemeManager_CustomThemeName.Value
            if self.BuiltInThemes[name] then return library:Notify('That name belongs to a built-in theme', 3) end

            local ok, err = self:SaveCustomTheme(name)
            if not ok then return library:Notify(tostring(err), 4) end

            refresh(library:SanitizeName(name))
        end):AddButton('Delete theme', function()
            local name = Options.ThemeManager_ThemeList.Value
            if not name or self.BuiltInThemes[name] then return library:Notify('Select a custom theme to delete', 3) end

            library:Dialog({
                Title = 'Delete theme',
                Description = string.format('Delete %q? This cannot be undone.', name),
                Buttons = {
                    { Text = 'Delete', Risky = true, Callback = function()
                        self:DeleteCustomTheme(name)
                        refresh()
                    end },
                    { Text = 'Cancel' },
                },
            })
        end)

        groupbox:AddButton('Refresh list', function() refresh(Options.ThemeManager_ThemeList.Value) end)

        Options.ThemeManager_ThemeList:OnChanged(function()
            self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
        end)

        local function UpdateTheme()
            if not self.Applying then self:ThemeUpdate() end
        end

        for _, field in ipairs(self.Fields) do
            Options[field]:OnChanged(UpdateTheme)
        end
    end

    function ThemeManager:CreateGroupBox(tab)
        assert(self.Library, '[lib] call ThemeManager:SetLibrary(Library) first')
        return tab:AddLeftGroupbox('Themes')
    end

    function ThemeManager:ApplyToTab(tab)
        assert(self.Library, '[lib] call ThemeManager:SetLibrary(Library) first')
        self:CreateThemeManager(self:CreateGroupBox(tab))
    end

    function ThemeManager:ApplyToGroupbox(groupbox)
        assert(self.Library, '[lib] call ThemeManager:SetLibrary(Library) first')
        self:CreateThemeManager(groupbox)
    end
end

return ThemeManager
