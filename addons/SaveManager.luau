local HttpService = game:GetService('HttpService')

local SaveManager = {} do
    SaveManager.Folder = 'UILibSettings'
    SaveManager.SubFolder = ''
    SaveManager.Ignore = {}
    SaveManager.Loading = false

    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = 'Toggle', idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                if Toggles[idx] and type(data.value) == 'boolean' then
                    Toggles[idx]:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = 'Slider', idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue(data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = 'Dropdown', idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue(data.value)
                end
            end,
        },
        List = {
            Save = function(idx, object)
                return { type = 'List', idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                local function pack(state)
                    local data = { value = state.Value:ToHex(), transparency = state.Transparency, mode = state.Mode }

                    if state.Mode == 'Gradient' then
                        data.stops = {}
                        for _, stop in ipairs(state.Stops) do
                            table.insert(data.stops, { t = stop.T, color = stop.Color:ToHex() })
                        end
                    end

                    return data
                end

                local data = pack(object:Get('Color'))
                data.type, data.idx, data.rainbow = 'ColorPicker', idx, object.Rainbow or false

                if #object.Targets > 1 then
                    data.targets = {}
                    for _, name in ipairs(object.Targets) do
                        if name ~= 'Color' then data.targets[name] = pack(object:Get(name)) end
                    end
                end

                return data
            end,
            Load = function(idx, data)
                local picker = Options[idx]
                if not picker then return end

                local function color(hex)
                    local ok, result = pcall(Color3.fromHex, hex)
                    return ok and result or nil
                end

                local function apply(data, main)
                    local transparency = tonumber(data.transparency)
                    transparency = transparency and math.clamp(transparency, 0, 1) or picker.Transparency

                    local stops = {}
                    if data.mode == 'Gradient' and type(data.stops) == 'table' then
                        for _, stop in ipairs(data.stops) do
                            local position, stopColor = type(stop) == 'table' and tonumber(stop.t), type(stop) == 'table' and color(stop.color)
                            if position and stopColor then table.insert(stops, { T = position, Color = stopColor }) end
                        end
                    end

                    if #stops >= 2 then
                        if main then picker:SetRainbow(false) end
                        picker:SetGradient(stops, transparency)
                        return
                    end

                    local solid = color(data.value)
                    if not solid then return end

                    if main then picker:SetRainbow(false) end
                    if picker.Mode == 'Gradient' then picker:SetMode('Solid') end
                    picker:SetValueRGB(solid, transparency)
                    if main and data.rainbow == true then picker:SetRainbow(true) end
                end

                local back = picker.Target
                picker:SetTarget('Color')
                apply(data, true)

                if type(data.targets) == 'table' then
                    for _, name in ipairs(picker.Targets) do
                        if name ~= 'Color' and type(data.targets[name]) == 'table' then
                            picker:SetTarget(name)
                            apply(data.targets[name], false)
                        end
                    end
                end

                picker:SetTarget(back)
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value, modifiers = object.Modifiers }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue({ data.key, data.mode, data.modifiers })
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = 'Input', idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                if Options[idx] and type(data.text) == 'string' then
                    Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    function SaveManager:SetLibrary(library)
        self.Library = library
        library.SaveManager = self
        library.AssetFolder = self.Folder
    end

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in next, list do
            self.Ignore[key] = true
        end
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            'BackgroundColor', 'MainColor', 'AccentColor', 'OutlineColor', 'FontColor',
            'ThemeManager_ThemeList', 'ThemeManager_CustomThemeName',
        })
    end

    function SaveManager:IgnoreUISettings()
        self:SetIgnoreIndexes(self.Library.UIIndexes)
        self:SetIgnoreIndexes(self.Library.UITransient)
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        if self.Library then self.Library.AssetFolder = folder end
        self:BuildFolderTree()
    end

    function SaveManager:SetSubFolder(name)
        self.SubFolder = name or ''
        self:BuildFolderTree()
    end

    function SaveManager:SettingsDir()
        return self.Folder .. (self.SubFolder ~= '' and ('/' .. self.SubFolder) or '') .. '/settings'
    end

    function SaveManager:BuildFolderTree()
        local library = self.Library
        if not library then return end

        library:EnsureFolder(self.Folder .. '/themes')
        library:EnsureFolder(self:SettingsDir())
    end

    function SaveManager:CloseOpenPopups()
        if self.Library then self.Library:ClosePopups() end
    end

    function SaveManager:Serialize(filter, extra)
        local objects = {}

        for idx, toggle in next, Toggles do
            if filter(idx) and self.Parser[toggle.Type] then
                table.insert(objects, self.Parser[toggle.Type].Save(idx, toggle))
            end
        end

        for idx, option in next, Options do
            if filter(idx) and self.Parser[option.Type] then
                table.insert(objects, self.Parser[option.Type].Save(idx, option))
            end
        end

        local data = { version = 1, objects = objects }
        for key, value in next, extra or {} do data[key] = value end

        return HttpService:JSONEncode(data)
    end

    function SaveManager:Save(name)
        if (not name) then
            return false, "[lib] couldn't save config: no name given"
        end

        local clean, why = self.Library:SanitizeName(name)
        if not clean then return false, why end

        local ok, encoded = pcall(self.Serialize, self, function(idx) return not self.Ignore[idx] end)
        if not ok then
            return false, ("[lib] couldn't save config '%s': encoding failed"):format(clean)
        end

        return self.Library.FS:Write(self:SettingsDir() .. '/' .. clean .. '.json', encoded)
    end

    function SaveManager:Decode(raw)
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok then return nil, '[lib] config file is corrupted' end
        if type(decoded) ~= 'table' or type(decoded.objects) ~= 'table' then
            return nil, "[lib] config file isn't a valid config"
        end

        return decoded.objects, decoded
    end

    function SaveManager:Apply(objects)
        for _, option in next, objects do
            local parser = type(option) == 'table' and self.Parser[option.type]
            local made = option.type == 'KeyPicker' and self.Library and self.Library.Binds[option.idx]
            local object = parser and (Toggles[option.idx] or Options[option.idx] or (made and made()))
            if object and object.Type == option.type then
                local ok, err = pcall(parser.Load, option.idx, option)
                if not ok then
                    warn(("[lib] couldn't apply '%s' (%s): %s")
                        :format(tostring(option.idx), tostring(option.type), tostring(err)))
                end
            end
        end
    end

    function SaveManager:Load(name)
        if (not name) then
            return false, "[lib] couldn't load config: none selected"
        end
        if self.Loading then
            return false, '[lib] a config is still loading, try again in a second'
        end

        local clean, why = self.Library:SanitizeName(name)
        if not clean then return false, why end

        local raw = self.Library.FS:Read(self:SettingsDir() .. '/' .. clean .. '.json')
        if not raw then return false, ("[lib] couldn't load config '%s': file not found"):format(clean) end

        local objects, err = self:Decode(raw)
        if not objects then return false, err end

        self:CloseOpenPopups()
        self.Loading = true

        task.spawn(function()
            local objs = {}
            for _, option in next, objects do
                if not (type(option) == 'table' and self.Ignore[option.idx]) then
                    table.insert(objs, option)
                end
            end

            self:Apply(objs)

            self.Loading = false
            self:CloseOpenPopups()
        end)

        return true
    end

    function SaveManager:Delete(name)
        local clean, why = self.Library:SanitizeName(name)
        if not clean then return false, why end

        local path = self:SettingsDir() .. '/' .. clean .. '.json'
        if not self.Library.FS:Exists(path) then return false, ("[lib] couldn't delete config '%s': file not found"):format(clean) end

        self.Library.FS:Delete(path)

        if self:GetAutoload() == clean then self:ClearAutoload() end
        return true
    end

    function SaveManager:RefreshConfigList()
        return self.Library.FS:List(self:SettingsDir(), 'json')
    end

    function SaveManager:GetAutoload()
        local raw = self.Library.FS:Read(self:SettingsDir() .. '/autoload.txt')
        return raw and raw ~= '' and raw or nil
    end

    function SaveManager:SetAutoload(name)
        local clean, why = self.Library:SanitizeName(name)
        if not clean then return false, why end

        return self.Library.FS:Write(self:SettingsDir() .. '/autoload.txt', clean)
    end

    function SaveManager:ClearAutoload()
        self.Library.FS:Delete(self:SettingsDir() .. '/autoload.txt')
    end

    function SaveManager:LoadAutoloadConfig()
        if not self.UILoaded then self:LoadUISettings() end

        local name = self:GetAutoload()
        if not name then return end

        local success, err = self:Load(name)
        if not success then
            return self.Library:Notify(err, 4)
        end

        self.Library:Notify(string.format('Auto loaded config %q', name))
    end

    function SaveManager:UIPath()
        return self.Folder .. '/ui.json'
    end

    function SaveManager:SaveUI()
        local ui = {}
        for _, idx in ipairs(self.Library.UIIndexes) do ui[idx] = true end

        local pos = self.Library.MobileButtonPos
        local extra = {}
        if pos then extra.mobileButton = { x = pos.X, y = pos.Y } end

        local window = self.Library.Window
        if window then
            extra.sizes = {}
            for layout, size in next, window.Sizes do extra.sizes[layout] = { x = size.X.Offset, y = size.Y.Offset } end
        end

        local ok, encoded = pcall(self.Serialize, self, function(idx) return ui[idx] end, extra)
        if ok then return self.Library.FS:Write(self:UIPath(), encoded) end

        return false, "[lib] couldn't save ui settings: encoding failed"
    end

    function SaveManager:LoadUISettings()
        self.UILoaded = true
        self.UIEnabled = true

        local raw = self.Library.FS:Read(self:UIPath())
        local objects, whole
        if raw then objects, whole = self:Decode(raw) end

        if objects then
            self.Library:ClosePopups()

            local library = self.Library

            local sizes = type(whole.sizes) == 'table' and whole.sizes or { [library.Window and library.Window.Layout or 1] = whole.customSize }
            for layout, size in next, sizes do
                if type(size) == 'table' and tonumber(size.x) and tonumber(size.y) and library.Window then
                    library.Window:SetSize(tonumber(size.x), tonumber(size.y), layout)
                end
            end

            self:Apply(objects)

            local mobile = whole.mobileButton
            if type(mobile) == 'table' and tonumber(mobile.x) and tonumber(mobile.y) then
                self.Library:SetMobileButtonPos(tonumber(mobile.x), tonumber(mobile.y))
            end
        end

        return objects ~= nil
    end

    function SaveManager:OnChange()
        if not self.UIEnabled or self.UIQueued then return end
        self.UIQueued = true

        task.delay(1, function()
            self.UIQueued = false
            if not self.Library.Unloaded then self:SaveUI() end
        end)
    end

    function SaveManager:BuildConfigSection(tab)
        local library = self.Library
        assert(library, '[lib] call SaveManager:SetLibrary(Library) first')

        self:BuildFolderTree()

        local section = tab:AddRightGroupbox('Configuration')

        section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })
        section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true, Searchable = true })

        section:AddDivider()

        local function refresh()
            Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            Options.SaveManager_ConfigList:SetValue(nil)
        end

        local autoloadLabel
        local function showAutoload()
            autoloadLabel:SetText('Current autoload config: ' .. (self:GetAutoload() or 'none'))
        end

        section:AddButton('Create config', function()
            local name = Options.SaveManager_ConfigName.Value

            local success, err = self:Save(name)
            if not success then
                return library:Notify(err)
            end

            library:Notify(string.format('Created config %q', name))
            refresh()
        end):AddButton('Load config', function()
            local name = Options.SaveManager_ConfigList.Value

            local success, err = self:Load(name)
            if not success then
                return library:Notify(err)
            end

            library:Notify(string.format('Loaded config %q', name))
        end)

        section:AddButton('Overwrite config', function()
            local name = Options.SaveManager_ConfigList.Value

            local success, err = self:Save(name)
            if not success then
                return library:Notify(err)
            end

            library:Notify(string.format('Overwrote config %q', name))
        end)

        section:AddButton({ Text = 'Delete config', Risky = true, Func = function()
            local name = Options.SaveManager_ConfigList.Value
            if not name then return library:Notify('Select a config first', 2) end

            library:Dialog({
                Title = 'Delete config',
                Description = string.format('Delete %q? This cannot be undone.', name),
                Buttons = {
                    { Text = 'Delete', Risky = true, Callback = function()
                        local success, err = self:Delete(name)
                        if not success then return library:Notify(err) end

                        library:Notify(string.format('Deleted config %q', name))
                        refresh()
                        showAutoload()
                    end },
                    { Text = 'Cancel' },
                },
            })
        end })

        section:AddButton('Refresh list', refresh)

        section:AddButton('Set as autoload', function()
            local name = Options.SaveManager_ConfigList.Value
            local success, err = self:SetAutoload(name)
            if not success then return library:Notify(err) end

            showAutoload()
            library:Notify(string.format('Set %q to auto load', name))
        end):AddButton('Clear autoload', function()
            self:ClearAutoload()
            showAutoload()
        end)

        autoloadLabel = section:AddLabel('Current autoload config: none', true)
        showAutoload()

        self:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
    end
end

return SaveManager
