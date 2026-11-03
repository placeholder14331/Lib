local X = {
    gethui = gethui or get_hidden_gui or gethiddengui or (syn and syn.gethui);
    cloneref = cloneref or clonereference or function(Item) return Item end;
    protect = protectgui or protect_gui or (syn and syn.protect_gui) or function() end;
    request = request or http_request or (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request);
    setclipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set);
    getcustomasset = getcustomasset or getsynasset;
    isfile = isfile;
    readfile = readfile;
    writefile = writefile;
    isfolder = isfolder;
    makefolder = makefolder;
    listfiles = listfiles;
    delfile = delfile;
    isrbxactive = isrbxactive or iswindowactive or function() return true end;
};

if typeof(X.gethui) ~= 'function' then
    warn("[lib] your executor doesn't support gethui, UI won't load");
end;

local Svc = setmetatable({}, { __index = function(Cache, Name) local Service = X.cloneref(game:GetService(Name)); Cache[Name] = Service; return Service end });

local ScreenGui = Instance.new('ScreenGui');
X.protect(ScreenGui);

ScreenGui.Name = 'UILib';
ScreenGui.IgnoreGuiInset = true;
ScreenGui.ResetOnSpawn = false;
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = X.gethui();

local Root = Instance.new('Frame');
Root.Name = 'Root';
Root.BackgroundTransparency = 1;
Root.BorderSizePixel = 0;
Root.Size = UDim2.fromScale(1, 1);
Root.Parent = ScreenGui;

local RootScale = Instance.new('UIScale');
RootScale.Parent = Root;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

local Library = {
    Registry = {};
    DetachedTabs = {};

    FontColor = Color3.fromRGB(232, 232, 238);
    MainColor = Color3.fromRGB(19, 19, 23);
    BackgroundColor = Color3.fromRGB(12, 12, 15);
    AccentColor = Color3.fromRGB(173, 112, 56);
    OutlineColor = Color3.fromRGB(37, 37, 45);
    PanelStrokeColor = Color3.fromRGB(37, 37, 45);
    RiskColor = Color3.fromRGB(255, 77, 94);

    Black = Color3.fromRGB(5, 5, 7);
    FontFace = Font.fromEnum(Enum.Font.Code);
    FontName = 'ProggyClean';

    CustomFonts = {
        ProggyClean = 'https://raw.githubusercontent.com/ocornut/imgui/b334d19b667958ed970000073644d911fae17e57/misc/fonts/ProggyClean.ttf';
    };

    PixelFonts = { ProggyClean = 12 };
    PreviewPitchLimit = 0.85;
    _fonts = {};

    OpenedFrames = {};
    Boxes = {};
    DependencyBoxes = {};

    Signals = {};
    UnloadCallbacks = {};
    Tweens = {};
    Toggles = Toggles;
    Options = Options;
    ScreenGui = ScreenGui;
    Root = Root;
    Scale = RootScale;
    SingleColumnWidth = 430;
    MobileSingleColumnWidth = 560;
    RoundEdges = false;
    Corners = {};
    NotifySide = 'Left';
    KeybindOpacity = 0;
    Offscreen = true;

    Style = 'Solid';
    GlassIntensity = 0.6;
    WindowTransparency = 0;
    PanelTransparency = 0;
    ElementTransparency = 0;
    NoTransparency = 0;
    PanelStrokeTransparency = 0;
    TextStroke = 0.5;
    Radius = 4;
    BackgroundImageActive = false;
    BlurSize = 16;
    UIBlurAmount = 0.5;
    UIBlurTint = 'Neutral';
    UIBlurTints = { Neutral = 'FontColor'; Main = 'MainColor' };
    Background = { Transparency = 0.3; Dim = 0.45 };
    IsMobile = false;
    ForceMobile = false;
    ViewportOverride = nil;
    ShowKeybindsOnMobile = true;
    RowHeight = 24;
    Tops = {};
    Searchables = {};

    Effects = {
        Animations = true;
        MenuFade = true;
        Shadow = true;
        SliderLerp = true;
        DragLerp = true;
        Glow = false;
        Blur = false;
        UIBlur = false;
    };

    BorderStyle = 'Animated';
    BorderUseTheme = true;
    BorderColor = Color3.fromRGB(173, 112, 56);
    BorderBase = Color3.fromRGB(37, 37, 45);
    BorderTransparency = 0;
    BorderSpeed = 0.2;

    Glow = { Size = 8; Color = Color3.fromRGB(173, 112, 56); Transparency = 0.5; UseTheme = false };

    _lerps = {};
    _glides = {};

    _renderConns = 0;
    _render = {};
    _rainbow = {};
    _textCache = {};
    _textCount = 0;
    _measures = 0;
    _drags = {};
    _claims = {};
    _flash = {};
    _flashBase = {};
    Binds = {};
    Outlines = {};
    _fits = {};
    _sizes = {};
    Bordered = {};
    _locks = {};
    _reported = {};
};

function Library:MousePos(Input)
    if Input and Input.UserInputType == Enum.UserInputType.Touch then
        return Vector2.new(Input.Position.X, Input.Position.Y);
    end;

    return Svc.UserInputService:GetMouseLocation() - Svc.GuiService:GetGuiInset();
end;

function Library:ToLocal(Pos)
    return (Pos - Library.Root.AbsolutePosition) / RootScale.Scale;
end;

function Library:KeepOnScreen(Pos, Size, Above)
    local View = Library:Viewport() / Library.Scale.Scale;
    local Y = (Above and Above >= 0 and Pos.Y + Size.Y > View.Y) and Above or Pos.Y;

    return UDim2.fromOffset(math.clamp(Pos.X, 0, math.max(View.X - Size.X, 0)), math.clamp(Y, 0, math.max(View.Y - Size.Y, 0)));
end;

function Library:IsInView(Gui)
    local Content = Library.Window and Library.Window.Content;

    if not (Content and Gui:IsDescendantOf(Content)) then return true end;

    local Center = Gui.AbsolutePosition + Gui.AbsoluteSize / 2;
    local From = Content.AbsolutePosition;
    local To = From + Content.AbsoluteSize;

    return Center.X >= From.X and Center.X <= To.X and Center.Y >= From.Y and Center.Y <= To.Y;
end;

Library.MouseKeys = { MB1 = Enum.UserInputType.MouseButton1; MB2 = Enum.UserInputType.MouseButton2; MB3 = Enum.UserInputType.MouseButton3 };

function Library:IsPress(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch;
end;

function Library:Gesture(Input)

    if Library._drags[Input] then return 'None' end;

    local Mouse = Input.UserInputType == Enum.UserInputType.MouseButton1;
    local Start, Began = Library:MousePos(Input), os.clock();
    local Page = Library.Window and Library.Window.CurrentTab and Library.Window.CurrentTab.Page;
    local Scroll = Page and Page.CanvasPosition;
    local Thread, Result = coroutine.running(), nil;
    local Changed, Ended;

    local function Finish(Intent)
        if Result then return end;

        Result = Intent;
        Changed:Disconnect();
        Ended:Disconnect();
        task.spawn(Thread);
    end;

    Changed = Svc.UserInputService.InputChanged:Connect(function(Moved)
        if Moved ~= Input and not (Mouse and Moved.UserInputType == Enum.UserInputType.MouseMovement) then return end;

        local Delta = Library:MousePos(Moved) - Start;

        if Delta.Magnitude >= 10 then Finish(math.abs(Delta.X) > math.abs(Delta.Y) and 'Sideways' or 'Scroll') end;
    end);

    Ended = Svc.UserInputService.InputEnded:Connect(function(Done)
        if Done ~= Input then return end;

        local Still = (Library:MousePos(Input) - Start).Magnitude < 10 and os.clock() - Began < 0.5 and not (Page and Page.CanvasPosition ~= Scroll);

        Finish(Still and 'Tap' or 'None');
    end);

    coroutine.yield();

    return Result;
end;

function Library:Covered(Input, Inst)
    local Pos = Library:MousePos(Input);

    for Frame in next, Library.OpenedFrames do
        if Frame.Parent and Frame.Visible and not (Inst and (Frame == Inst or Inst:IsDescendantOf(Frame))) and Library:IsMouseOverFrame(Frame, Pos) then
            return true;
        end;
    end;

    return false;
end;

function Library:IsClick(Input, Inst)
    if Library:Covered(Input, Inst) then return false end;

    if Input.UserInputType == Enum.UserInputType.Touch then return Library:Gesture(Input) == 'Tap' end;

    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return false end;

    Library._claims[Input] = true;

    return true;
end;

function Library:IsTap(Input, Inst)
    return Library:IsPress(Input) and not Library:Covered(Input, Inst) and Library:Gesture(Input) == 'Tap';
end;

function Library:UpdateMobile()
    Library.IsMobile = Library.ForceMobile or (Svc.UserInputService.TouchEnabled and not Svc.UserInputService.KeyboardEnabled);

    return Library.IsMobile;
end;

function Library:Viewport()
    if Library.ViewportOverride then return Library.ViewportOverride end;

    local Camera = workspace.CurrentCamera;

    return Camera and Camera.ViewportSize or Library.Root.AbsoluteSize;
end;

function Library:OnLongPress(Gui, Fn, Time)
    local Handle = { Token = 0 };

    function Handle.Release(Input)
        if Handle.Holding == Input then
            Handle.Holding = nil;
            Handle.Token = Handle.Token + 1;
        end;

        if Handle.Ended then
            Handle.Ended:Disconnect();
            Handle.Ended = nil;
        end;
    end;

    function Handle.Press(Input)
        if Library:Covered(Input, Gui) then return end;

        if Input.UserInputType == Enum.UserInputType.MouseButton2 then
            return Fn(Input);
        end;

        if Input.UserInputType ~= Enum.UserInputType.Touch or Library._drags[Input] then return end;

        Handle.Token = Handle.Token + 1;
        Handle.Holding = Input;

        local Mine, Start = Handle.Token, Library:MousePos(Input);

        if Handle.Ended then Handle.Ended:Disconnect() end;
        Handle.Ended = Svc.UserInputService.InputEnded:Connect(function(Done)
            if Done == Input then Handle.Release(Input) end;
        end);

        task.delay(Time or 0.5, function()
            if Handle.Token == Mine and Handle.Holding == Input and (Library:MousePos(Input) - Start).Magnitude < 12 then
                Handle.Holding = nil;
                Fn(Input);
            end;
        end);
    end;

    Gui.InputBegan:Connect(Handle.Press);

    return Handle;
end;

function Library:HitFrame(Parent, Size, ZIndex)
    return Library:Create('Frame', {
        Active = true;
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        Position = UDim2.fromScale(0.5, 0.5);
        Size = Size;
        ZIndex = ZIndex or 30;
        Parent = Parent;
    });
end;

function Library:BindRender(Name, Fn)
    if Library._render[Name] then return end;

    Library._render[Name] = Svc.RunService.RenderStepped:Connect(Fn);
    Library._renderConns = Library._renderConns + 1;
end;

function Library:UnbindRender(Name)
    local Conn = Library._render[Name];

    if Conn then
        Conn:Disconnect();
        Library._render[Name] = nil;
        Library._renderConns = Library._renderConns - 1;
    end;
end;

local function LerpStep(Delta)
    local On = Library.Effects.SliderLerp and Library.Effects.Animations;
    local Alpha = 1 - math.exp(-Delta * 16);

    for Slider in next, Library._lerps do
        local Shown = Slider._shown + (Slider._target - Slider._shown) * Alpha;

        if not On or math.abs(Slider._target - Shown) < 0.0005 then
            Shown = Slider._target;
            Library._lerps[Slider] = nil;
        end;

        Slider._shown = Shown;
        Slider._fill.Size = UDim2.new(Shown, 0, 1, 0);
    end;

    if not next(Library._lerps) then
        Library:UnbindRender('SliderLerp');
    end;
end;

function Library:LerpSlider(Slider, Fill, Target, Instant)
    Slider._fill, Slider._target = Fill, Target;

    if Instant or not (Library.Effects.SliderLerp and Library.Effects.Animations) or not Slider._shown then
        Slider._shown = Target;
        Library._lerps[Slider] = nil;
        Fill.Size = UDim2.new(Target, 0, 1, 0);
        return;
    end;

    Library._lerps[Slider] = true;
    Library:BindRender('SliderLerp', LerpStep);
end;

function Library:SetRainbow(Obj, On)
    Library._rainbow[Obj] = On or nil;

    if next(Library._rainbow) then
        if Library._render.Rainbow then return end;

        local Hue = 0;
        Library:BindRender('Rainbow', function(Delta)
            Hue = (Hue + Delta / 6.67) % 1;
            Library.CurrentRainbowHue = Hue;
            Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);

            for Obj in next, Library._rainbow do
                Obj:SetValueRGB(Library.CurrentRainbowColor, Obj.Transparency);
            end;
        end);
    else
        Library:UnbindRender('Rainbow');
    end;
end;

local function GetPlayersString()
    local PlayerList = Svc.Players:GetPlayers();

    for Index = 1, #PlayerList do
        PlayerList[Index] = PlayerList[Index].Name;
    end;

    table.sort(PlayerList, function(First, Second) return First < Second end);

    return PlayerList;
end;

local function GetTeamsString()
    local TeamList = Svc.Teams:GetTeams();

    for Index = 1, #TeamList do
        TeamList[Index] = TeamList[Index].Name;
    end;

    table.sort(TeamList, function(First, Second) return First < Second end);

    return TeamList;
end;

function Library:SafeCallback(Callback, ...)
    if not Callback then return end;

    local Ok, Message = pcall(Callback, ...);

    if Ok then return end;

    Message = tostring(Message);

    if Library.NotifyOnError then
        local _, Cut = Message:find(':%d+: ');

        Library:Notify(Cut and Message:sub(Cut + 1) or Message, 3);
    else
        warn(('[lib] callback error: %s'):format(Message));
    end;
end;

function Library:Format(Formatter, Fallback, ...)
    local Ok, Text = pcall(Formatter, ...);

    if Ok and Text ~= nil then return tostring(Text) end;

    if not Ok and not Library._reported[Formatter] then
        Library._reported[Formatter] = true;
        warn(('[lib] display formatter error: %s'):format(tostring(Text)));
    end;

    return Fallback;
end;

function Library:AttemptSave()
    if Library.SaveManager and not Library.Unloaded then
        Library.SaveManager:OnChange();
    end;
end;

function Library:PixelSize(Size)
    local Sharp = Library.FontApplied and Library.PixelFonts[Library.FontName];

    return Sharp and Sharp * math.max(1, math.floor(Size / Sharp + 0.5)) or Size;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;

    if type(Class) == 'string' then
        _Instance = Instance.new(Class);
    end;

    for Property, Value in next, Properties do
        _Instance[Property] = Value;
    end;

    if Properties.TextSize then
        if not Library._sizes[_Instance] then
            _Instance.Destroying:Once(function() Library._sizes[_Instance] = nil end);
        end;

        Library._sizes[_Instance] = Properties.TextSize;
        _Instance.TextSize = Library:PixelSize(Properties.TextSize);
    end;

    if _Instance:IsA('Frame') and Properties.BorderColor3 == Color3.new() and Properties.BackgroundColor3 == nil and Properties.BackgroundTransparency == nil then
        Library.Bordered[_Instance] = { Wrapper = true };
        Library:SyncWrapper(_Instance);
    end;

    if _Instance:IsA('TextBox') then
        Library.Boxes[_Instance] = true;
        _Instance.Destroying:Once(function() Library.Boxes[_Instance] = nil end);

        _Instance.InputBegan:Connect(function(Input)
            if Library:IsPress(Input) and not Library:Covered(Input, _Instance) then Library._claims[Input] = true end;
        end);

        if not Library._boxFx then
            Library._boxFx = true;

            Library:BindRender('BoxCover', function()
                local Open = next(Library.OpenedFrames) ~= nil;

                if not Open and not Library._boxOff then return end;

                local Pos = Library:MousePos();

                Library._boxOff = false;

                for Box in next, Library.Boxes do
                    local Off = Open and Box.Parent and Library:IsMouseOverFrame(Box, Pos) and Library:Covered(nil, Box);

                    Box.Interactable = not Off;
                    Library._boxOff = Library._boxOff or Off;
                end;
            end);
        end;
    end;

    if Library.Root and _Instance:IsA('Frame') and Properties.Parent == Library.Root and Properties.Active == nil
        and Properties.BackgroundTransparency ~= 1 then
        _Instance.Active = true;
    end;

    if _Instance:IsA('GuiObject') and Properties.BorderColor3 and Properties.BorderColor3 ~= Color3.new() and _Instance.BorderSizePixel > 0
        and not Library.Bordered[_Instance] then
        Library:RoundBorder(_Instance, 4);
    end;

    return _Instance;
end;

function Library:Tween(Inst, Props, Time, Style, Dir, Flag)
    if not Library.Effects[Flag or 'Animations'] or not Time or Time <= 0 then
        for Prop, Value in next, Props do
            Inst[Prop] = Value;
        end;

        return;
    end;

    local Goal = {};
    for Prop, Value in next, Props do
        if Prop == 'ZIndex' or typeof(Value) == 'boolean' or typeof(Value) == 'EnumItem' then
            Inst[Prop] = Value;
        else
            Goal[Prop] = Value;
        end;
    end;
    Props = Goal;

    local Tween = Svc.TweenService:Create(Inst, TweenInfo.new(Time, Style or Enum.EasingStyle.Quad, Dir or Enum.EasingDirection.Out), Props);

    Library.Tweens[Tween] = true;
    Tween.Completed:Once(function() Library.Tweens[Tween] = nil end);
    Tween:Play();

    return Tween;
end;

function Library:RoundBorder(Inst, Radius)
    local Stroke = Instance.new('UIStroke');
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
    Stroke.Thickness = Inst.BorderSizePixel;
    Stroke.Enabled = Inst.BorderSizePixel > 0;

    pcall(function()
        Stroke.BorderStrokePosition = Inst.BorderMode == Enum.BorderMode.Inset and Enum.BorderStrokePosition.Inner
            or Inst.BorderMode == Enum.BorderMode.Middle and Enum.BorderStrokePosition.Center or Enum.BorderStrokePosition.Outer;
    end);
    Stroke.Parent = Inst;

    Library:Round(Inst, Radius);
    Library.Bordered[Inst] = { Stroke = Stroke, Size = Inst.BorderSizePixel };
    Inst.BorderSizePixel = 0;

    local function Mirror()
        Stroke.Color = Inst.BorderColor3;
        Stroke.Transparency = Inst.BackgroundTransparency;
    end;

    Mirror();
    Inst:GetPropertyChangedSignal('BorderColor3'):Connect(Mirror);
    Inst:GetPropertyChangedSignal('BackgroundTransparency'):Connect(Mirror);
end;

function Library:SyncWrapper(Inst)
    Inst.BackgroundTransparency = Library.RoundEdges and 1 or 0;
end;

function Library:Round(Inst, Radius, StrokeColorName)
    Radius = Library.Radius;

    local Corner = Library:Create('UICorner', { CornerRadius = UDim.new(0, Library.RoundEdges and Radius or 0), Parent = Inst });
    Library.Corners[Corner] = Radius;

    if StrokeColorName then
        local Stroke = Library:Create('UIStroke', { Color = Library[StrokeColorName], Parent = Inst });
        Library:AddToRegistry(Stroke, { Color = StrokeColorName });
        return Stroke;
    end;
end;

function Library:Outline(Frame, Radius)
    Library:Round(Frame, Radius or 6);

    local Stroke = Library:Create('UIStroke', { Parent = Frame });

    Library.Outlines[Stroke] = { Gradient = Library:Create('UIGradient', { Enabled = false; Parent = Stroke }), Frame = Frame };
    Stroke.Destroying:Once(function() Library.Outlines[Stroke] = nil end);

    Library:StyleBorder(Stroke, Library.Outlines[Stroke].Gradient);

    return Stroke;
end;

function Library:Panel(Inst, Role, Radius, NoStroke)
    Radius = Library.Radius;

    Library:Round(Inst, Radius);

    local Reg = Library.Registry[Inst] or {};
    Reg.BackgroundTransparency = Role;
    Library.Registry[Inst] = Reg;

    if not NoStroke then

        local Stroke = Library:Create('UIStroke', {
            BorderStrokePosition = Enum.BorderStrokePosition.Inner;
            Color = Library.PanelStrokeColor;
            Transparency = Library.PanelStrokeTransparency;
            Parent = Inst;
        });
        Library:AddToRegistry(Stroke, { Color = 'PanelStrokeColor'; Transparency = 'PanelStrokeTransparency' });
    end;

    local function IsGlass() return Library.Style == 'Glass' end;

    local Sheen = Library:Create('UIGradient', {
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(185, 185, 185));
        Enabled = IsGlass();
        Rotation = 90;
        Parent = Inst;
    });

    local Top = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BackgroundTransparency = 0.86;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(Radius, 0);
        Size = UDim2.new(1, -2 * Radius, 0, 1);
        Visible = IsGlass();
        ZIndex = Inst.ZIndex + 1;
        Parent = Inst;
    });

    Library:AddToRegistry(Sheen, { Enabled = IsGlass });
    Library:AddToRegistry(Top, { Visible = IsGlass });
end;

function Library:ApplyStyle()
    local Glass = Library.Style == 'Glass';
    local Intensity = Library.GlassIntensity;
    local Image = Library.BackgroundImageActive;

    if Glass then
        Library.WindowTransparency = 0.08 + 0.42 * Intensity;
        Library.PanelTransparency = 0.2 + 0.45 * Intensity;
        Library.ElementTransparency = 0.25 + 0.4 * Intensity;
        Library.PanelStrokeColor = Color3.new(1, 1, 1);
        Library.PanelStrokeTransparency = 0.85;
    else
        Library.WindowTransparency = 0;
        Library.PanelTransparency = Image and 0.25 or 0;
        Library.ElementTransparency = Image and 0.2 or 0;
        Library.PanelStrokeColor = Library.OutlineColor;
        Library.PanelStrokeTransparency = 0;
    end;

    Library.TextStroke = Image and 0.4 or 0.5;

    if Library.Window then Library.Window:FinishFade() end;

    Library:UpdateColorsUsingRegistry();

    if Library.Window then Library.Window:UpdateGradient() end;

    Library:UpdateUIBlur();
end;

function Library:SetStyle(Style)
    if Style ~= 'Solid' and Style ~= 'Glass' then return end;

    Library.Style = Style;
    Library:ApplyStyle();

    if Options.UI_Style and Options.UI_Style.Value ~= Style then Options.UI_Style:SetValue(Style) end;
end;

function Library:SetGlassIntensity(Value)
    Library.GlassIntensity = math.clamp(Value, 0, 1);
    Library:ApplyStyle();
end;

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = Library.TextStroke;
end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        FontFace = Library.FontFace;
        TextColor3 = Library.FontColor;
        TextSize = 16;
        TextStrokeTransparency = Library.TextStroke;
    });

    Library:ApplyTextStroke(_Instance);

    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
        FontFace = 'FontFace';
        TextStrokeTransparency = 'TextStroke';
    }, IsHud);

    return Library:Create(_Instance, Properties);
end;

function Library:LockScroll(Page)
    local Lock = Library._locks[Page] or { Count = 0, Was = Page.ScrollingEnabled };

    Library._locks[Page] = Lock;
    Lock.Count = Lock.Count + 1;
    Page.ScrollingEnabled = false;
end;

function Library:UnlockScroll(Page)
    local Lock = Library._locks[Page];

    if not Lock then return end;

    Lock.Count = Lock.Count - 1;

    if Lock.Count <= 0 then
        Library._locks[Page] = nil;
        Page.ScrollingEnabled = Lock.Was;
    end;
end;

function Library:OverScrollbar(Root, Pos)
    for _, Gui in ipairs(Root:GetDescendants()) do
        if Gui:IsA('ScrollingFrame') and Gui.AbsoluteCanvasSize.Y > Gui.AbsoluteWindowSize.Y + 1 and Library:IsMouseOverFrame(Gui, Pos)
            and Pos.X >= Gui.AbsolutePosition.X + Gui.AbsoluteSize.X - (Gui.ScrollBarThickness + 6) * Library.Scale.Scale then
            local Shown, Up = true, Gui;

            while Up and Up ~= Root do
                if Up:IsA('GuiObject') and not Up.Visible then Shown = false break end;
                Up = Up.Parent;
            end;

            if Shown then return true end;
        end;
    end;

    return false;
end;

function Library:Drag(Input, OnMove, OnEnd)

    if Library._drags[Input] then return function() end end;

    local Changed, Ended;
    local Page = Library.Window and Library.Window.CurrentTab and Library.Window.CurrentTab.Page;
    local Stopped = false;

    if Page then Library:LockScroll(Page) end;

    Library._drags[Input] = true;

    local function Stop()
        if Stopped then return end;
        Stopped = true;
        Library._drags[Input] = nil;

        Library:RemoveSignal(Changed);
        Library:RemoveSignal(Ended);

        if Page then Library:UnlockScroll(Page) end;
        if OnEnd then OnEnd() end;
    end;

    Changed = Svc.UserInputService.InputChanged:Connect(function(Moved)
        if Moved.UserInputType == Enum.UserInputType.MouseMovement or Moved == Input then
            OnMove(Library:MousePos(Moved));
        end;
    end);

    Ended = Svc.UserInputService.InputEnded:Connect(function(Done)
        if Done == Input then Stop() end;
    end);

    Library:GiveSignal(Changed);
    Library:GiveSignal(Ended);
    OnMove(Library:MousePos(Input));

    return Stop;
end;

local function Toward(Gap, Alpha)
    local Step = Gap * Alpha;

    return math.abs(Step) < 1 and math.sign(Gap) or math.floor(Step + 0.5);
end;

local function GlideStep(Delta)
    local On = Library.Effects.DragLerp and Library.Effects.Animations;
    local Alpha = 1 - math.exp(-Delta * 25);

    for Frame, Target in next, Library._glides do
        local Now = Frame.Position;
        local GapX, GapY = Target.X.Offset - Now.X.Offset, Target.Y.Offset - Now.Y.Offset;

        if not On or (GapX == 0 and GapY == 0) or not Frame.Parent then
            Frame.Position = Target;
            Library._glides[Frame] = nil;
        else
            Frame.Position = UDim2.fromOffset(Now.X.Offset + Toward(GapX, Alpha), Now.Y.Offset + Toward(GapY, Alpha));
        end;
    end;

    if not next(Library._glides) then
        Library:UnbindRender('DragLerp');
    end;
end;

function Library:Glide(Frame, Shown)
    if not (Library.Effects.DragLerp and Library.Effects.Animations) then return end;

    Library._glides[Frame] = Frame.Position;
    Frame.Position = Shown;
    Library:BindRender('DragLerp', GlideStep);
end;

function Library:MakeDraggable(Instance, Cutoff, OnMoved)
    Instance.Active = true;

    local function Grab(Input, Start)
        local ObjPos = Start - Instance.AbsolutePosition;
        local Anchor = Vector2.new(Instance.AbsoluteSize.X * Instance.AnchorPoint.X, Instance.AbsoluteSize.Y * Instance.AnchorPoint.Y);

        local From = Library:ToLocal(Instance.AbsolutePosition + Anchor);
        Instance.Position = UDim2.fromOffset(From.X, From.Y);

        Library:Drag(Input, function(Pos)
            local New = Library:ToLocal(Pos - ObjPos + Anchor);
            local Shown = Instance.Position;

            Instance.Position = UDim2.fromOffset(New.X, New.Y);

            if OnMoved then OnMoved() end;

            Library:Glide(Instance, Shown);
        end);
    end;

    Instance.InputBegan:Connect(function(Input)
        if not Library:IsPress(Input) then return end;

        local Start = Library:MousePos(Input);

        if type(Cutoff) == 'function' then
            if not Cutoff(Start) then return end;
        elseif (Start - Instance.AbsolutePosition).Y / Library.Scale.Scale > (Cutoff or 40) then
            return;
        end;

        Grab(Input, Start);
    end);

    return Grab;
end;

function Library:GetTooltip()
    if Library.Tooltip then return Library.Tooltip end;

    local Frame = Library:Create('Frame', {
        Active = false;
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        ZIndex = 100;
        Parent = Library.Root;
        Visible = false;
    });

    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(3, 1);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 101;
        Parent = Frame;
    });

    Library:AddToRegistry(Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });
    Library.Tooltip = { Frame = Frame, Label = Label };

    return Library.Tooltip;
end;

function Library:AddToolTip(Info, HoverInstance)
    local Tip = { Text = Info };
    local Moving;

    local function Place(Pos)
        Pos = Library:ToLocal((Pos or Library:MousePos()) + Vector2.new(15, 12));

        local Frame = Library.Tooltip.Frame;
        local Size = Vector2.new(Frame.Size.X.Offset, Frame.Size.Y.Offset);

        Frame.Position = Library:KeepOnScreen(Pos, Size, Pos.Y - Size.Y - 24);
    end;

    local function Hide()
        if Moving then Moving:Disconnect(); Moving = nil end;
        if Library.Tooltip and Library.Tooltip.Owner == Tip then
            Library.Tooltip.Owner = nil;
            Library.Tooltip.Frame.Visible = false;
        end;
    end;

    local function Show(Pos)
        local Text = Tip.Text;

        for _ = 1, 3 do
            if type(Text) ~= 'function' then break end;

            local Ok, Result = pcall(Text);

            Text = Ok and Result or nil;
        end;

        if type(Text) == 'number' then Text = tostring(Text) end;

        if Tip.Disabled or type(Text) ~= 'string' or Text == '' or Library:MouseIsOverOpenedFrame() then
            return false;
        end;

        local T = Library:GetTooltip();
        local W, H = Library:GetTextBounds(Text, 14);

        T.Owner = Tip;
        T.Label.Text = Text;
        T.Label.Size = UDim2.fromOffset(W, H);
        T.Frame.Size = UDim2.fromOffset(W + 5, H + 4);
        Place(Pos);
        T.Frame.Visible = true;

        return true;
    end;

    if Library.IsMobile then
        Library:OnLongPress(HoverInstance, function(Input)
            if not Show(Library:MousePos(Input) - Vector2.new(0, 48)) then return end;

            local End; End = Svc.UserInputService.InputEnded:Connect(function(Done)
                if Done == Input then End:Disconnect(); Hide() end;
            end);
        end);
    else
        HoverInstance.MouseEnter:Connect(function()
            if not Show() then return end;

            if Moving then Moving:Disconnect() end;
            Moving = Svc.UserInputService.InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement then Place() end;
            end);
        end);

        HoverInstance.MouseLeave:Connect(Hide);
    end;

    HoverInstance.Destroying:Connect(Hide);

    return Tip;
end;

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    if Library.IsMobile then return end;

    local function Apply(Props)
        local Reg = Library.Registry[Instance];
        local Goal = {};

        for Property, ColorIdx in next, Props do
            Goal[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg[Property] then
                Reg[Property] = ColorIdx;
            end;
        end;

        Library:Tween(Instance, Goal, 0.1);
    end;

    HighlightInstance.MouseEnter:Connect(function() Apply(Properties) end);
    HighlightInstance.MouseLeave:Connect(function() Apply(PropertiesDefault) end);
end;

function Library:IsMouseOverFrame(Frame, Pos)
    Pos = Pos or Library:MousePos();

    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

    return Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
        and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y;
end;

function Library:MouseIsOverOpenedFrame()
    local Pos = Library:MousePos();

    for Frame in next, Library.OpenedFrames do
        if Frame.Parent and Frame.Visible and Library:IsMouseOverFrame(Frame, Pos) then
            return true;
        end;
    end;

    return false;
end;

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update();
    end;
end;

function Library:ClosePopups()
    for _, Option in next, Options do
        if type(Option) == 'table' and type(Option.CloseDropdown) == 'function' then
            pcall(Option.CloseDropdown, Option);
        end;
    end;

    local Frames = {};
    for Frame in next, Library.OpenedFrames do
        Frames[#Frames + 1] = Frame;
    end;
    table.clear(Library.OpenedFrames);

    for _, Frame in ipairs(Frames) do
        pcall(function() Frame.Visible = false end);
    end;

    pcall(Library.UpdateDependencyBoxes, Library);
end;

Library.HideUnboundKeybinds = false;
Library.KeybindFilter = {};
Library.KeybindShow = { Bar = true; Type = true; Border = false };
Library.KeybindRight = false;

function Library:RefreshKeybindFrame()
    for _, Option in next, Options do
        if type(Option) == 'table' and Option.Type == 'KeyPicker' and Option.Update then
            Option:Update();
        end;
    end;
end;

function Library:FitText(Label, Max, Min)
    local function Fit()
        local Room = Label.AbsoluteSize.X / Library.Scale.Scale - 8;
        local Size = Max;

        while Size > Min and Library:GetTextBounds(Label.Text, Size) > Room do Size = Size - 1 end;

        Label.TextSize = Library:PixelSize(Size);
    end;

    Label.TextTruncate = Enum.TextTruncate.AtEnd;
    Label:GetPropertyChangedSignal('Text'):Connect(Fit);
    Label:GetPropertyChangedSignal('AbsoluteSize'):Connect(Fit);
    Library._fits[Label] = Fit;
    Label.Destroying:Once(function() Library._fits[Label] = nil end);
    Fit();
end;

function Library:AddonRow(Label)
    local Pad = Library:Create('UIPadding', { Parent = Label });
    local Row = Library:Create('Frame', { BackgroundTransparency = 1; Size = UDim2.fromScale(1, 1); Parent = Label });

    local Layout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Row;
    });

    Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        local Width = Layout.AbsoluteContentSize.X / Library.Scale.Scale;
        local Room = Width > 0 and Width + 4 or 0;

        Pad.PaddingRight = UDim.new(0, Room);
        Row.Size = UDim2.new(1, Room, 1, 0);
    end);

    Label.TextTruncate = Enum.TextTruncate.AtEnd;

    return Row;
end;

function Library:GetTextBounds(Text, Size, Resolution)
    Text = tostring(Text);

    local Key = Text .. '\0' .. Size;
    local Hit = not Resolution and Library._textCache[Key];

    if not Hit then
        local Meter = Library._meter;

        if not Meter then
            Meter = Library:Create('TextLabel', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(-20000, -20000);
                TextTransparency = 1;
                Parent = Library.ScreenGui;
            });

            Library._meter = Meter;
        end;

        local Id;

        repeat
            Library._measures = Library._measures + 1;
            Id = Library._measures;

            Meter.FontFace = Library.FontFace;
            Meter.TextSize = Library:PixelSize(Size);
            Meter.TextWrapped = Resolution ~= nil and Resolution.X < math.huge;
            Meter.Size = UDim2.fromOffset(Resolution and math.min(Resolution.X, 20000) or 20000, 20000);
            Meter.Text = Text;

            Hit = { Meter.TextBounds.X, Meter.TextBounds.Y };
        until Library._measures == Id;

        if not Resolution then
            if Library._textCount > 2000 then
                table.clear(Library._textCache);
                Library._textCount = 0;
            end;

            Library._textCache[Key] = Hit;
            Library._textCount = Library._textCount + 1;
        end;
    end;

    return Hit[1], Hit[2];
end;

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end;
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties;
end;

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil;
end;

Library.Detached = {};

function Library:Detach(Instance)
    if not Library.Detached[Instance] then
        Library.Detached[Instance] = true;

        local Watch, Gone;

        local function Clear()
            Library.Detached[Instance] = nil;
            Watch:Disconnect();
            Gone:Disconnect();
        end;

        Watch = Instance:GetPropertyChangedSignal('Parent'):Connect(function()
            if Instance.Parent then Clear() end;
        end);
        Gone = Instance.Destroying:Connect(Clear);
    end;

    Instance.Parent = nil;
end;

function Library:UpdateColorsUsingRegistry(Only)
    for Instance, Properties in next, Library.Registry do
        for Property, ColorIdx in next, Properties do
            if not Only or Property == Only then
                if type(ColorIdx) == 'string' then
                    Instance[Property] = Library[ColorIdx];
                elseif type(ColorIdx) == 'function' then
                    Instance[Property] = ColorIdx();
                end;
            end;
        end;
    end;
end;

function Library:GiveSignal(Signal, Owner)
    table.insert(Library.Signals, Signal);

    if Owner then
        Owner.Destroying:Once(function() Library:RemoveSignal(Signal) end);
    end;

    return Signal;
end;

function Library:RemoveSignal(Signal)
    local At = table.find(Library.Signals, Signal);

    if At then table.remove(Library.Signals, At) end;

    Signal:Disconnect();
end;

function Library:DestroyWith(Owner, ...)
    local Things = { ... };

    Owner.Destroying:Once(function()
        for _, Thing in ipairs(Things) do
            if type(Thing) == 'function' then
                Thing();
            else
                Library.OpenedFrames[Thing] = nil;
                Library.Detached[Thing] = nil;

                for _, Item in ipairs(Thing:GetDescendants()) do
                    Library.Registry[Item] = nil;
                    Library.Corners[Item] = nil;
                    Library.Bordered[Item] = nil;
                end;

                Library.Registry[Thing] = nil;
                Library.Corners[Thing] = nil;
                Library.Bordered[Thing] = nil;
                Thing:Destroy();
            end;
        end;
    end);
end;

function Library:OnUnload(Callback)
    table.insert(Library.UnloadCallbacks, Callback);
end;

function Library:Unload()
    if Library.Unloaded then return end;
    Library.Unloaded = true;

    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx);
        Connection:Disconnect();
    end;

    for Name in next, Library._render do
        Library:UnbindRender(Name);
    end;

    if Library.MenuOpen and Library.PrevIcon ~= nil then Svc.UserInputService.MouseIconEnabled = Library.PrevIcon end;

    for Tween in next, Library.Tweens do
        Tween:Cancel();
    end;
    table.clear(Library.Tweens);

    for _, Callback in ipairs(Library.UnloadCallbacks) do
        pcall(Callback);
    end;

    for TabFrame in next, Library.DetachedTabs do
        pcall(function() TabFrame:Destroy() end);
    end;
    table.clear(Library.DetachedTabs);

    if Library._blur then Library._blur:Destroy() end;
    if Library._glass then Library._glass.Folder:Destroy(); Library._glass.Dof:Destroy() end;

    ScreenGui:Destroy();

    if getgenv().Library == Library then getgenv().Library = nil end;
    if getgenv().Toggles == Toggles then getgenv().Toggles = nil end;
    if getgenv().Options == Options then getgenv().Options = nil end;
end;

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    local Walk = Instance;

    while Walk do
        if Library.Detached[Walk] then return end;

        Walk = Walk.Parent;
    end;

    Library:RemoveFromRegistry(Instance);
    Library.Corners[Instance] = nil;
    Library.Bordered[Instance] = nil;
end));

function Library:Mark(Container)
    local Set = {};

    for _, Child in ipairs(Container:GetChildren()) do
        Set[Child] = true;
    end;

    return Set;
end;

function Library:ApplyCommon(Element, Info, Parts)
    local Groupbox = Parts.Groupbox;
    local Roots = Parts.Roots;

    if not Roots then
        Roots = {};

        for _, Child in ipairs(Groupbox.Container:GetChildren()) do
            if Child:IsA('GuiObject') and not Parts.Mark[Child] then
                table.insert(Roots, Child);
            end;
        end;
    end;

    Element.Groupbox = Groupbox;
    Element.Top = Groupbox.Top or Groupbox;
    Element.Roots = Roots;
    Element.Disabled = Info.Disabled or false;
    Element.Visible = Info.Visible ~= false;
    Element.Risky = Info.Risky;
    Element.Filtered = false;
    Element.SearchText = Info.Text or (Parts.Text and Parts.Text.Text) or '';
    Element.FlashLabel = Parts.Text;

    function Element:Refresh(NoResize)
        local Show = Element.Visible and not Element.Filtered;

        for _, Root in ipairs(Roots) do
            Root.Visible = Show;
        end;

        if not NoResize then Groupbox:Resize() end;
    end;

    function Element:SetVisible(Bool)
        Element.Visible = not not Bool;
        Element:Refresh();
    end;

    function Element:SetDisabled(Bool)
        Element.Disabled = not not Bool;

        for _, Obj in ipairs(Parts.Dim or { Parts.Text }) do
            Obj.TextTransparency = Element.Disabled and 0.5 or 0;
        end;

        if Parts.OnDisabled then Parts.OnDisabled(Element.Disabled) end;
    end;

    if Element.Risky and Parts.Text then
        Parts.Text.TextColor3 = Library.RiskColor;
        Library.Registry[Parts.Text].TextColor3 = 'RiskColor';
    end;

    if (Info.Tooltip or Info.DisabledTooltip) and Parts.Hover then
        Element.Tip = Library:AddToolTip(function()
            if Element.Disabled and Info.DisabledTooltip then return Info.DisabledTooltip end;
            return Info.Tooltip;
        end, Parts.Hover);
    end;

    if Element.Disabled then Element:SetDisabled(true) end;
    if not Element.Visible then Element:Refresh() end;

    if not Parts.NoSearch then
        table.insert(Library.Searchables, Element);
    end;
end;

function Library:Ripple(Frame, Pos)
    local Rel = (( Pos or Library:MousePos()) - Frame.AbsolutePosition) / Library.Scale.Scale;
    local Radius = Frame.AbsoluteSize.Magnitude / Library.Scale.Scale;

    local Circle = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Color3.new(1, 1, 1);
        BackgroundTransparency = 0.8;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(Rel.X, Rel.Y);
        Size = UDim2.fromOffset(0, 0);
        ZIndex = Frame.ZIndex + 3;
        Parent = Frame;
    });

    Library:Create('UICorner', { CornerRadius = UDim.new(1, 0), Parent = Circle });

    Library:Tween(Circle, { Size = UDim2.fromOffset(Radius * 2, Radius * 2), BackgroundTransparency = 1 }, 0.45);
    task.delay(0.5, function() Circle:Destroy() end);
end;

local BaseAddons = {};

do
    local Funcs = {};

    function Funcs:AddColorPicker(Idx, Info)
        local ToggleLabel = self.TextLabel;

        assert(Info.Default, '[lib] color picker is missing its Default color');

        local HasAlpha = Info.Transparency ~= false;
        local HasGradient = Info.Gradient ~= false;
        local Targets = { 'Color' };

        for _, Name in ipairs({ 'Outline', 'Fill' }) do
            if Info[Name] then table.insert(Targets, Name) end;
        end;

        local HasTargets = #Targets > 1;

        local function AutoTitle()
            local Ok, Text = pcall(function() return (ToggleLabel.Text:gsub('<[^>]+>', '')):match('^%s*(.-)%s*$') end);

            return Ok and Text and Text ~= '' and (Text .. ' Color') or 'Color picker';
        end;

        local ColorPicker = {
            Value = Info.Default;
            Transparency = type(Info.Transparency) == 'number' and Info.Transparency or 0;
            Type = 'ColorPicker';
            Mode = 'Solid';
            Stops = {};
            Targets = Targets;
            Target = 'Color';
            Title = type(Info.Title) == 'string' and Info.Title or AutoTitle();
            Callback = Info.Callback or function() end;
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);

            ColorPicker.Hue = H;
            ColorPicker.Sat = S;
            ColorPicker.Vib = V;
        end;

        ColorPicker:SetHSVFromRGB(ColorPicker.Value);

        local function ToRGB(Color)
            return table.concat({ math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5) }, ', ');
        end;

        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.fromOffset(17, 17);
            ZIndex = 6;
            Parent = self.AddonRow or ToggleLabel;
        });

        Library:AddToRegistry(DisplayFrame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

        local DisplayFill = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderSizePixel = 0;
            Position = UDim2.fromOffset(2, 2);
            Size = UDim2.new(1, -4, 1, -4);
            ZIndex = 8;
            Parent = DisplayFrame;
        });

        Library:Round(DisplayFill, 2);

        local DisplayGradient = Library:Create('UIGradient', { Enabled = false; Parent = DisplayFill });
        local DisplayHit = Library:HitFrame(DisplayFrame, UDim2.new(1, 10, 0, Library.RowHeight), 30);

        Library:Round(Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Position = UDim2.fromOffset(2, 2);
            Size = UDim2.new(1, -4, 1, -4);
            ZIndex = 7;
            Image = 'http://www.roblox.com/asset/?id=12977615774';
            Visible = HasAlpha;
            Parent = DisplayFrame;
        }), 2);

        local PW, Pad = 284, 10;
        local ContentW = PW - Pad * 2;
        local MapY, MapH = HasTargets and 90 or 64, 128;
        local HueY = MapY + MapH + 8;
        local AlphaY = HueY + 12 + 8;
        local BoxY = (HasAlpha and AlphaY or HueY) + 12 + 8;
        local BaseHeight = BoxY + 22 + 10;
        local GradExtra = 60;

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.fromOffset(PW, BaseHeight);
            Visible = false;
            ZIndex = 15;
            Parent = Library.Root;
        });

        Library:AddToRegistry(PickerFrameOuter, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

        Library:Outline(PickerFrameOuter, 6);

        local function PlacePicker(Pos)
            Library._glides[PickerFrameOuter] = nil;
            PickerFrameOuter.Position = Library:KeepOnScreen(Pos, Vector2.new(PickerFrameOuter.Size.X.Offset, PickerFrameOuter.Size.Y.Offset));
        end;

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });

        local function Strip(Parent, X, Y, Width, Height)
            local Frame = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Position = UDim2.fromOffset(X, Y);
                Size = UDim2.fromOffset(Width, Height);
                ZIndex = 18;
                Parent = Parent;
            });

            Library:AddToRegistry(Frame, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

            return Frame;
        end;

        local function Inset(Parent)
            local Frame = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(1, 1, 1);
                BorderSizePixel = 0;
                Position = UDim2.fromOffset(1, 1);
                Size = UDim2.new(1, -2, 1, -2);
                ZIndex = 19;
                Parent = Parent;
            });

            Library:Round(Frame, 3);

            return Frame;
        end;

        local SatVibMapInner = Strip(PickerFrameInner, Pad, MapY, ContentW, MapH);

        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Position = UDim2.fromOffset(1, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 19;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapInner;
        });

        Library:Round(SatVibMap, 3);

        local CursorOuter = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Size = UDim2.fromOffset(12, 12);
            ZIndex = 21;
            Parent = SatVibMap;
        });

        Library:Create('UICorner', { CornerRadius = UDim.new(1, 0), Parent = CursorOuter });
        Library:Create('UIStroke', { Color = Color3.new(0, 0, 0); Thickness = 1.5; Parent = CursorOuter });

        local CursorRing = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.fromScale(0.5, 0.5);
            Size = UDim2.fromOffset(8, 8);
            ZIndex = 22;
            Parent = CursorOuter;
        });

        Library:Create('UICorner', { CornerRadius = UDim.new(1, 0), Parent = CursorRing });
        Library:Create('UIStroke', { Color = Color3.new(1, 1, 1); Thickness = 1.5; Parent = CursorRing });

        local HueSelectorOuter = Strip(PickerFrameInner, Pad, HueY, ContentW, 12);
        local HueSelectorInner = Inset(HueSelectorOuter);

        local function Marker(Parent)
            local Frame = Library:Create('Frame', {
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Color3.new(1, 1, 1);
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromScale(0, 0.5);
                Size = UDim2.new(0, 5, 1, 6);
                ZIndex = 21;
                Parent = Parent;
            });

            Library:RoundBorder(Frame, 2);

            return Frame;
        end;

        local HueCursor = Marker(HueSelectorInner);

        local function MakeBox(Position, Size)
            local Frame = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Position = Position;
                Size = Size;
                ZIndex = 18;
                Parent = PickerFrameInner;
            });

            local Box = Library:Create('TextBox', {
                BackgroundTransparency = 1;
                ClearTextOnFocus = false;
                Position = UDim2.fromOffset(6, 0);
                Size = UDim2.new(1, -8, 1, 0);
                FontFace = Library.FontFace;
                PlaceholderColor3 = Color3.fromRGB(150, 150, 150);
                Text = '';
                TextColor3 = Library.FontColor;
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 20;
                Parent = Frame;
            });

            Library:AddToRegistry(Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
            Library:AddToRegistry(Box, { TextColor3 = 'FontColor', FontFace = 'FontFace' });

            return Frame, Box;
        end;

        local HalfW = (ContentW - 8) / 2;
        local _, HueBox = MakeBox(UDim2.fromOffset(Pad, BoxY), UDim2.fromOffset(HalfW, 22));
        HueBox.PlaceholderText = 'Hex color';
        HueBox.Text = '#FFFFFF';

        local _, RgbBox = MakeBox(UDim2.fromOffset(Pad + HalfW + 8, BoxY), UDim2.fromOffset(HalfW, 22));
        RgbBox.PlaceholderText = 'RGB color';
        RgbBox.Text = '255, 255, 255';

        local TransparencyBoxInner, TransparencyCursor;

        if HasAlpha then
            local TransparencyBoxOuter = Strip(PickerFrameInner, Pad, AlphaY, ContentW, 12);

            TransparencyBoxInner = Inset(TransparencyBoxOuter);
            TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;

            Library:Round(Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = 'http://www.roblox.com/asset/?id=12978095818';
                ZIndex = 20;
                Parent = TransparencyBoxInner;
            }), 3);

            TransparencyCursor = Marker(TransparencyBoxInner);
        end;

        local DragArea = Library:Create('Frame', {
            Active = true;
            BackgroundTransparency = 1;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 16;
            Parent = PickerFrameInner;
        });

        local Header = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(Pad, 8);
            Size = UDim2.new(1, -Pad * 2, 0, 22);
            ZIndex = 16;
            Parent = PickerFrameInner;
        });

        local RightGroup = Library:Create('Frame', {
            AnchorPoint = Vector2.new(1, 0);
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundTransparency = 1;
            Position = UDim2.fromScale(1, 0);
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 16;
            Parent = Header;
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal;
            Padding = UDim.new(0, 8);
            SortOrder = Enum.SortOrder.LayoutOrder;
            VerticalAlignment = Enum.VerticalAlignment.Center;
            Parent = RightGroup;
        });

        local function HeaderButton(Parent, Text, Order)
            local Button = Library:CreateLabel({
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundColor3 = Library.MainColor;
                BackgroundTransparency = 0;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                LayoutOrder = Order;
                Size = UDim2.new(0, 0, 1, 0);
                Text = Text;
                TextSize = 13;
                ZIndex = 18;
                Parent = Parent;
            });

            Library:Create('UIPadding', { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = Button });

            local Reg = Library.Registry[Button];
            Reg.BackgroundColor3 = 'MainColor';
            Reg.BorderColor3 = 'OutlineColor';

            return Button;
        end;

        local ModeRow = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(Pad, 34);
            Size = UDim2.new(1, -Pad * 2, 0, 22);
            ZIndex = 16;
            Parent = PickerFrameInner;
        });

        local ModeLabels = {};

        if HasGradient then
            local ModeGroup = Library:Create('Frame', {
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 0, 1, 0);
                ZIndex = 16;
                Parent = ModeRow;
            });

            Library:Create('UIListLayout', { FillDirection = Enum.FillDirection.Horizontal; SortOrder = Enum.SortOrder.LayoutOrder; Parent = ModeGroup });

            for Index, Name in ipairs({ 'Solid', 'Gradient' }) do
                local Button = HeaderButton(ModeGroup, Name, Index);

                Button.InputBegan:Connect(function(Input)
                    if Library:IsTap(Input, Button) then
                        ColorPicker:SetMode(Name);
                        Library:AttemptSave();
                    end;
                end);

                ModeLabels[Name] = Button;
            end;
        end;

        function ColorPicker:Copy()
            Library.ColorClipboard = { ColorPicker.Value, ColorPicker.Transparency };
            if X.setclipboard then pcall(X.setclipboard, '#' .. ColorPicker.Value:ToHex()) end;
            Library:Notify('Copied color!', 2);
        end;

        function ColorPicker:Paste()
            if not Library.ColorClipboard then
                return Library:Notify('You have not copied a color!', 2);
            end;

            ColorPicker:SetValueRGB(Library.ColorClipboard[1], HasAlpha and Library.ColorClipboard[2] or 0);
            Library:AttemptSave();
        end;

        local ActionGroup = Library:Create('Frame', {
            AnchorPoint = Vector2.new(1, 0);
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundTransparency = 1;
            Position = UDim2.fromScale(1, 0);
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 16;
            Parent = ModeRow;
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal;
            Padding = UDim.new(0, 4);
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ActionGroup;
        });

        for Order, Name in ipairs({ 'Copy', 'Paste' }) do
            local Button = HeaderButton(ActionGroup, Name, Order);

            Library:OnHighlight(Button, Button, { BorderColor3 = 'AccentColor' }, { BorderColor3 = 'OutlineColor' });

            Button.InputBegan:Connect(function(Input)
                if Library:IsTap(Input, Button) then ColorPicker[Name](ColorPicker) end;
            end);
        end;

        local ResetLabel = HeaderButton(ActionGroup, 'Reset', 3);

        Library:OnHighlight(ResetLabel, ResetLabel, { BorderColor3 = 'AccentColor' }, { BorderColor3 = 'OutlineColor' });

        ResetLabel.InputBegan:Connect(function(Input)
            if Library:IsTap(Input, ResetLabel) then
                ColorPicker:Reset();
                Library:AttemptSave();
            end;
        end);

        local TabLabels = {};

        if HasTargets then
            local TabRow = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(Pad, 60);
                Size = UDim2.new(1, -Pad * 2, 0, 22);
                ZIndex = 16;
                Parent = PickerFrameInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal;
                Padding = UDim.new(0, 4);
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabRow;
            });

            for Index, Name in ipairs(Targets) do
                local Button = HeaderButton(TabRow, Name, Index);

                Button.InputBegan:Connect(function(Input)
                    if Library:IsTap(Input, Button) then ColorPicker:SetTarget(Name) end;
                end);

                TabLabels[Name] = Button;
            end;
        end;

        local CloseLabel = HeaderButton(RightGroup, 'X', 3);

        CloseLabel.AutomaticSize = Enum.AutomaticSize.None;
        CloseLabel.Size = UDim2.fromOffset(22, 22);
        CloseLabel.TextColor3 = Library.RiskColor;
        Library.Registry[CloseLabel].TextColor3 = 'RiskColor';

        Library:OnHighlight(CloseLabel, CloseLabel, { BorderColor3 = 'RiskColor' }, { BorderColor3 = 'OutlineColor' });

        CloseLabel.InputBegan:Connect(function(Input)
            if Library:IsTap(Input, CloseLabel) then ColorPicker:Hide() end;
        end);

        DragArea.InputBegan:Connect(function(Input)
            if not Library:IsPress(Input) or Library:Covered(Input, DragArea) then return end;

            local Grab = Library:ToLocal(Library:MousePos(Input)) - Vector2.new(PickerFrameOuter.Position.X.Offset, PickerFrameOuter.Position.Y.Offset);
            local Intent = Input.UserInputType == Enum.UserInputType.Touch and Library:Gesture(Input) or 'Sideways';

            if Intent ~= 'Sideways' and Intent ~= 'Scroll' then return end;

            task.wait();

            local Lifted = Input.UserInputState == Enum.UserInputState.End or Input.UserInputState == Enum.UserInputState.Cancel;

            if Library._drags[Input] or Library._claims[Input] or Lifted then return end;

            Library:Drag(Input, function(Pos)
                local Shown = PickerFrameOuter.Position;

                PlacePicker(Library:ToLocal(Pos) - Grab);
                Library:Glide(PickerFrameOuter, Shown);
            end);
        end);

        local DisplayLabel = Library:CreateLabel({
            BackgroundColor3 = Library.MainColor;
            BackgroundTransparency = 0;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, -30, 1, 0);
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            Text = ColorPicker.Title;
            TextTruncate = Enum.TextTruncate.AtEnd;
            TextWrapped = false;
            ZIndex = 18;
            Parent = Header;
        });

        Library:Create('UIPadding', { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = DisplayLabel });

        local TitleReg = Library.Registry[DisplayLabel];
        TitleReg.BackgroundColor3 = 'MainColor';
        TitleReg.BorderColor3 = 'OutlineColor';

        local GradSection = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(0, BaseHeight - 8);
            Size = UDim2.new(1, 0, 0, GradExtra + 8);
            Visible = false;
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local GradBarOuter = Strip(GradSection, Pad, 10, ContentW, 14);
        GradBarOuter.BackgroundColor3 = Color3.new(1, 1, 1);

        local GradBar = Inset(GradBarOuter);
        local BarGradient = Library:Create('UIGradient', { Parent = GradBar });

        Library:AddToolTip('Drag a handle to move it. The selected handle is the one you edit above.', GradBar);

        local MarkerArea = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(Pad + 1, 6);
            Size = UDim2.new(1, -(Pad + 1) * 2, 0, 22);
            ZIndex = 20;
            Parent = GradSection;
        });

        local StopLabel = Library:CreateLabel({
            Position = UDim2.fromOffset(Pad, 36);
            Size = UDim2.fromOffset(ContentW, 22);
            Text = '';
            TextSize = 13;
            TextTransparency = 0.25;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 18;
            Parent = GradSection;
        });

        local ContextMenu = {};
        do
            ContextMenu.Options = {};
            ContextMenu.Container = Library:Create('Frame', {
                BorderColor3 = Color3.new();
                ZIndex = 14;

                Visible = false;
                Parent = Library.Root;
            });

            ContextMenu.Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });

            Library:Create('UIListLayout', {
                Name = 'Layout';
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });

            Library:Create('UIPadding', {
                Name = 'Padding';
                PaddingLeft = UDim.new(0, 4);
                Parent = ContextMenu.Inner;
            });

            local function UpdateMenuPosition()
                if ContextMenu.Container.Visible and not Library:IsInView(DisplayFrame) then
                    ContextMenu:Hide();
                    return;
                end;

                local Pos = Library:ToLocal(DisplayFrame.AbsolutePosition + Vector2.new(DisplayFrame.AbsoluteSize.X + 4, 1));
                ContextMenu.Container.Position = Library:KeepOnScreen(Pos, Vector2.new(ContextMenu.Container.Size.X.Offset, ContextMenu.Container.Size.Y.Offset));
            end;

            local function UpdateMenuSize()
                local MenuWidth = 60;
                for _, Label in next, ContextMenu.Inner:GetChildren() do
                    if Label:IsA('TextLabel') then
                        MenuWidth = math.max(MenuWidth, Label.TextBounds.X);
                    end;
                end;

                ContextMenu.Container.Size = UDim2.fromOffset(
                    MenuWidth + 8,
                    ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                );

                UpdateMenuPosition();
            end;

            local MenuFollow;

            ContextMenu.Container:GetPropertyChangedSignal('Visible'):Connect(function()
                if ContextMenu.Container.Visible then
                    UpdateMenuPosition();
                    MenuFollow = MenuFollow or DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(UpdateMenuPosition);
                elseif MenuFollow then
                    MenuFollow:Disconnect();
                    MenuFollow = nil;
                end;
            end);
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(UpdateMenuSize);

            task.spawn(UpdateMenuPosition);
            task.spawn(UpdateMenuSize);

            Library:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            function ContextMenu:Show()
                self.Container.Visible = true;
            end;

            function ContextMenu:Hide()
                self.Container.Visible = false;
            end;

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end;
                end;

                local Button = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    TextXAlignment = Enum.TextXAlignment.Left;
                });

                Library:OnHighlight(Button, Button,
                    { TextColor3 = 'AccentColor' },
                    { TextColor3 = 'FontColor' }
                );

                Button.InputBegan:Connect(function(Input)
                    if not Library:IsTap(Input, Button) then
                        return
                    end;

                    Callback();
                    ContextMenu:Hide();
                end);
            end;

            ContextMenu:AddOption('Copy color', function() ColorPicker:Copy() end);

            ContextMenu:AddOption('Paste color', function() ColorPicker:Paste() end);

            ContextMenu:AddOption('Copy HEX', function()
                if X.setclipboard then pcall(X.setclipboard, '#' .. ColorPicker.Value:ToHex()) end;
                Library:Notify('Copied hex code to clipboard!', 2);
            end);

            ContextMenu:AddOption('Copy RGB', function()
                if X.setclipboard then pcall(X.setclipboard, ToRGB(ColorPicker.Value)) end;
                Library:Notify('Copied RGB values to clipboard!', 2);
            end);

            ContextMenu:AddOption('Toggle rainbow', function()
                ColorPicker:SetRainbow(not ColorPicker.Rainbow);
            end);

            ContextMenu:AddOption('Reset color', function()
                ColorPicker:Reset();
                Library:AttemptSave();
            end);
        end;

        local SequenceTable = {};

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;

        Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 0;
            Parent = HueSelectorInner;
        });

        local Markers = {};

        local function SortStops()
            table.sort(ColorPicker.Stops, function(A, B) return A.T < B.T end);
        end;

        function ColorPicker:GetGradient()
            if ColorPicker.Mode ~= 'Gradient' then return nil end;

            local Points = {};

            for _, Stop in ipairs(ColorPicker.Stops) do
                table.insert(Points, { T = Stop.T, Color = Stop.Color });
            end;

            if Points[1].T > 0 then table.insert(Points, 1, { T = 0, Color = Points[1].Color }) end;
            if Points[#Points].T < 1 then table.insert(Points, { T = 1, Color = Points[#Points].Color }) end;

            for Index = 2, #Points do
                Points[Index].T = math.max(Points[Index].T, Points[Index - 1].T + 1e-4);
            end;

            Points[#Points].T = 1;

            for Index = #Points - 1, 1, -1 do
                Points[Index].T = math.min(Points[Index].T, Points[Index + 1].T - 1e-4);
            end;

            Points[1].T = 0;

            local Keys = {};
            for _, Point in ipairs(Points) do
                table.insert(Keys, ColorSequenceKeypoint.new(math.clamp(Point.T, 0, 1), Point.Color));
            end;

            return ColorSequence.new(Keys);
        end;

        local function SelectStop(Stop)
            ColorPicker.SelectedStop = Stop;
            ColorPicker:SetHSVFromRGB(Stop.Color);
            ColorPicker:Display(true);
        end;

        local function GrabStop(Stop, Input)
            SelectStop(Stop);

            Library:Drag(Input, function(Pos)
                local Min, Size = GradBar.AbsolutePosition, GradBar.AbsoluteSize;

                Stop.T = math.clamp((Pos.X - Min.X) / math.max(Size.X, 1), 0, 1);
                SortStops();
                ColorPicker:Display();
            end, function() Library:AttemptSave() end);
        end;

        local function EnsureMarker(Stop)
            if Markers[Stop] then return end;

            local Marker = Library:Create('Frame', {
                Active = true;
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.fromOffset(Library.IsMobile and 11 or 7, 21);
                ZIndex = 21;
                Parent = MarkerArea;
            });

            Library:RoundBorder(Marker, 3);

            Marker.InputBegan:Connect(function(Input)
                if Library:IsPress(Input) then GrabStop(Stop, Input) end;
            end);

            Markers[Stop] = Marker;
        end;

        local function ClearMarkers()
            for _, Stop in ipairs(ColorPicker.Stops) do
                if Markers[Stop] then Markers[Stop]:Destroy(); Markers[Stop] = nil end;
            end;
        end;

        local function ShowMarkers()
            for Stop, Marker in next, Markers do
                Marker.Visible = ColorPicker.Mode == 'Gradient' and table.find(ColorPicker.Stops, Stop) ~= nil;
            end;
        end;

        local function EnterGradient()
            for _, Stop in ipairs(ColorPicker.Stops) do EnsureMarker(Stop) end;
            ColorPicker.SelectedStop = ColorPicker.SelectedStop or ColorPicker.Stops[1];
            ColorPicker:SetHSVFromRGB(ColorPicker.SelectedStop.Color);
        end;

        GradBar.InputBegan:Connect(function(Input)
            if not Library:IsPress(Input) then return end;

            local Min, Size = GradBar.AbsolutePosition, GradBar.AbsoluteSize;
            local T = math.clamp((Library:MousePos(Input).X - Min.X) / math.max(Size.X, 1), 0, 1);
            local Nearest;

            for _, Stop in ipairs(ColorPicker.Stops) do
                if not Nearest or math.abs(Stop.T - T) < math.abs(Nearest.T - T) then Nearest = Stop end;
            end;

            if Nearest then GrabStop(Nearest, Input) end;
        end);

        local function Resize()
            local Gradient = ColorPicker.Mode == 'Gradient';

            GradSection.Visible = Gradient;
            PickerFrameOuter.Size = UDim2.fromOffset(PW, BaseHeight + (Gradient and GradExtra or 0));

            if PickerFrameOuter.Visible then PlacePicker(Vector2.new(PickerFrameOuter.Position.X.Offset, PickerFrameOuter.Position.Y.Offset)) end;

            for Name, Button in next, ModeLabels do
                local Active = (Name == 'Gradient') == Gradient;
                local Reg = Library.Registry[Button];

                Reg.BackgroundColor3 = Active and 'AccentColor' or 'MainColor';
                Reg.TextColor3 = 'FontColor';
                Button.BackgroundColor3 = Library[Reg.BackgroundColor3];
                Button.TextColor3 = Library[Reg.TextColor3];
            end;
        end;

        function ColorPicker:Display(NoCallback)
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            local Gradient = ColorPicker.Mode == 'Gradient';

            if Gradient and ColorPicker.SelectedStop then
                ColorPicker.SelectedStop.Color = ColorPicker.Value;
            end;

            local Sequence = ColorPicker:GetGradient();

            if ColorPicker.Target == 'Color' then
                DisplayFill.BackgroundColor3 = Gradient and Color3.new(1, 1, 1) or ColorPicker.Value;
                DisplayFill.BackgroundTransparency = ColorPicker.Transparency;

                DisplayGradient.Enabled = Gradient;
                if Sequence then DisplayGradient.Color = Sequence end;
            end;

            if Sequence then
                BarGradient.Color = Sequence;

                for _, Stop in ipairs(ColorPicker.Stops) do
                    local Marker = Markers[Stop];
                    local Selected = Stop == ColorPicker.SelectedStop;

                    Marker.Position = UDim2.fromScale(Stop.T, 0);
                    Marker.BackgroundColor3 = Stop.Color;
                    Marker.BorderColor3 = Selected and Library.AccentColor or Color3.new(0, 0, 0);
                    Marker.ZIndex = Selected and 22 or 21;
                end;

                StopLabel.Text = table.find(ColorPicker.Stops, ColorPicker.SelectedStop) == 2 and 'Editing the end color' or 'Editing the start color';
            end;

            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0.5, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(ColorPicker.Hue, 0, 0.5, 0);

            HueBox.Text = '#' .. ColorPicker.Value:ToHex();
            RgbBox.Text = ToRGB(ColorPicker.Value);

            if NoCallback then return end;

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value, Sequence, ColorPicker.Target);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value, Sequence, ColorPicker.Target);
        end;

        function ColorPicker:SetMode(Mode)
            if not HasGradient and Mode == 'Gradient' then return end;
            if Mode ~= 'Solid' and Mode ~= 'Gradient' then return end;

            ColorPicker.Mode = Mode;

            if Mode == 'Gradient' then
                if ColorPicker.Target == 'Color' then ColorPicker:SetRainbow(false) end;

                if #ColorPicker.Stops < 2 then
                    ColorPicker.Stops = {
                        { T = 0, Color = ColorPicker.Value };
                        { T = 1, Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib * 0.35) };
                    };
                end;

                EnterGradient();
            end;

            ShowMarkers();
            Resize();
            ColorPicker:Display();
        end;

        function ColorPicker:SetGradient(Stops, Transparency)
            local Built = {};

            for _, Item in ipairs(Stops) do
                local T, Color = tonumber(Item.T or Item[1] or 0), Item.Color or Item[2];

                assert(T and typeof(Color) == 'Color3', '[lib] a gradient stop needs a position and a Color3');
                table.insert(Built, { T = math.clamp(T, 0, 1), Color = Color });
            end;

            assert(#Built >= 2, '[lib] a gradient needs 2 stops');

            table.sort(Built, function(A, B) return A.T < B.T end);

            if #Built > 2 then Built = { Built[1], Built[#Built] } end;

            ClearMarkers();

            ColorPicker.Stops = Built;
            SortStops();
            ColorPicker.Transparency = HasAlpha and (Transparency or 0) or 0;
            ColorPicker.SelectedStop = nil;
            ColorPicker.Mode = 'Solid';
            ColorPicker:SetMode('Gradient');
        end;

        local Fields = { 'Value', 'Hue', 'Sat', 'Vib', 'Transparency', 'Mode', 'Stops', 'SelectedStop' };
        local Saved, Defaults = {}, { Color = { Info.Default, ColorPicker.Transparency } };

        for _, Name in ipairs(Targets) do
            if Name ~= 'Color' then
                local Start = typeof(Info[Name]) == 'Color3' and Info[Name] or (Name == 'Outline' and Color3.new(0, 0, 0) or Info.Default);
                local H, S, V = Color3.toHSV(Start);

                Defaults[Name] = { Start, 0 };
                Saved[Name] = { Value = Start; Hue = H; Sat = S; Vib = V; Transparency = 0; Mode = 'Solid'; Stops = {} };
            end;
        end;

        local function Swap(Name)
            local Out = {};

            for _, Field in ipairs(Fields) do Out[Field] = ColorPicker[Field] end;

            Saved[ColorPicker.Target] = Out;

            for _, Field in ipairs(Fields) do ColorPicker[Field] = Saved[Name][Field] end;

            ColorPicker.Target = Name;
        end;

        local function StyleTabs()
            for Name, Button in next, TabLabels do
                local Reg = Library.Registry[Button];

                Reg.BackgroundColor3 = Name == ColorPicker.Target and 'AccentColor' or 'MainColor';
                Reg.TextColor3 = 'FontColor';
                Button.BackgroundColor3 = Library[Reg.BackgroundColor3];
                Button.TextColor3 = Library.FontColor;
            end;
        end;

        function ColorPicker:Get(Name)
            return Name == ColorPicker.Target and ColorPicker or Saved[Name];
        end;

        function ColorPicker:SetTarget(Name)
            if Name == ColorPicker.Target or not Saved[Name] then return end;

            Swap(Name);

            if ColorPicker.Mode == 'Gradient' then EnterGradient() end;

            ShowMarkers();
            StyleTabs();
            Resize();
            ColorPicker:Display(true);
        end;

        local Rainbow = setmetatable({}, { __index = function(_, Key)
            if Key == 'Transparency' then return ColorPicker:Get('Color').Transparency end;
        end });

        function Rainbow:SetValueRGB(Color, Alpha)
            local Back = ColorPicker.Target;

            if Back == 'Color' then return ColorPicker:SetValueRGB(Color, Alpha) end;

            Swap('Color');
            ColorPicker:SetValueRGB(Color, Alpha);
            Swap(Back);
            ColorPicker:Display(true);
        end;

        function ColorPicker:SetRainbow(On)
            ColorPicker.Rainbow = not not On;
            Library:SetRainbow(Rainbow, ColorPicker.Rainbow);
        end;

        function ColorPicker:Reset()
            local Default = Defaults[ColorPicker.Target];

            if ColorPicker.Target == 'Color' then ColorPicker:SetRainbow(false) end;

            ClearMarkers();

            ColorPicker.Stops = {};
            ColorPicker.SelectedStop = nil;
            ColorPicker.Mode = 'Solid';
            ColorPicker.Transparency = Default[2];
            ColorPicker:SetHSVFromRGB(Default[1]);

            Resize();
            ColorPicker:Display();
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Library:SafeCallback(Func, ColorPicker.Value, ColorPicker:GetGradient(), ColorPicker.Target);
        end;

        function ColorPicker:Show()
            for Frame in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            local Height = PickerFrameOuter.Size.Y.Offset;
            local Base = Library:ToLocal(DisplayFrame.AbsolutePosition);
            local Below = Base.Y + 18 + Height <= Library:Viewport().Y / Library.Scale.Scale;

            PlacePicker(Base + Vector2.new(0, Below and 18 or -Height - 4));
            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;
        end;

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
            Library.OpenedFrames[PickerFrameOuter] = nil;
        end;

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker:SetValueRGB(Color, Transparency);
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = HasAlpha and (Transparency or 0) or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        HueBox.FocusLost:Connect(function(EnterPressed)
            if EnterPressed then
                local Ok, Parsed = pcall(Color3.fromHex, HueBox.Text);
                if Ok and typeof(Parsed) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Parsed);
                end;
            end;

            ColorPicker:Display();
            Library:AttemptSave();
        end);

        RgbBox.FocusLost:Connect(function(EnterPressed)
            if EnterPressed then
                local Red, Green, Blue = RgbBox.Text:match('(%d+)%s*,%s*(%d+)%s*,%s*(%d+)');
                if Red and Green and Blue then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(math.min(tonumber(Red), 255), math.min(tonumber(Green), 255), math.min(tonumber(Blue), 255)));
                end;
            end;

            ColorPicker:Display();
            Library:AttemptSave();
        end);

        local function DragMap(Frame, OnPos)
            Frame.InputBegan:Connect(function(Input)
                if not Library:IsPress(Input) then return end;

                Library:Drag(Input, function(Pos)
                    local Min, Size = Frame.AbsolutePosition, Frame.AbsoluteSize;
                    OnPos(Vector2.new(
                        math.clamp((Pos.X - Min.X) / Size.X, 0, 1),
                        math.clamp((Pos.Y - Min.Y) / Size.Y, 0, 1)
                    ));
                    ColorPicker:Display();
                end);

                local End; End = Svc.UserInputService.InputEnded:Connect(function(Done)
                    if Done == Input then End:Disconnect(); Library:AttemptSave() end;
                end);
            end);
        end;

        DragMap(SatVibMap, function(P) ColorPicker.Sat = P.X; ColorPicker.Vib = 1 - P.Y end);
        DragMap(HueSelectorInner, function(P) ColorPicker.Hue = P.X end);

        if TransparencyBoxInner then
            DragMap(TransparencyBoxInner, function(P) ColorPicker.Transparency = 1 - P.X end);
        end;

        DisplayHit.InputBegan:Connect(function(Input)
            if Library:IsClick(Input) then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide();
                else
                    ContextMenu:Hide();
                    ColorPicker:Show();
                end;
            end;
        end);

        Library:OnLongPress(DisplayHit, function()
            if not Library:MouseIsOverOpenedFrame() then
                ContextMenu:Show();
                ColorPicker:Hide();
            end;
        end);

        Library:GiveSignal(Svc.UserInputService.InputBegan:Connect(function(Input)
            if Library:IsPress(Input) then
                if not Library:IsMouseOverFrame(ContextMenu.Container) then
                    ContextMenu:Hide();
                end;
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                    ContextMenu:Hide();
                end;
            end;
        end), DisplayFrame);

        Library:DestroyWith(DisplayFrame, PickerFrameOuter, ContextMenu.Container);

        Resize();
        StyleTabs();
        ColorPicker:Display(true);
        ColorPicker.DisplayFrame = DisplayFrame;
        ColorPicker.Frame, ColorPicker.DragArea, ColorPicker.CloseButton, ColorPicker.TitleLabel = PickerFrameOuter, DragArea, CloseLabel, DisplayLabel;
        ColorPicker.DisplayFill = DisplayFill;
        ColorPicker.Hit = DisplayHit;

        if self.Addons then table.insert(self.Addons, ColorPicker) end;

        Options[Idx] = ColorPicker;

        return self;
    end;

    local ModKeys = { Ctrl = { 'LeftControl', 'RightControl' }, Shift = { 'LeftShift', 'RightShift' }, Alt = { 'LeftAlt', 'RightAlt' } };
    local ModOf = {};

    for Mod, Keys in next, ModKeys do
        for _, Key in ipairs(Keys) do ModOf[Key] = Mod end;
    end;

    local function ModHeld(Mod)
        return Svc.UserInputService:IsKeyDown(Enum.KeyCode[ModKeys[Mod][1]]) or Svc.UserInputService:IsKeyDown(Enum.KeyCode[ModKeys[Mod][2]]);
    end;

    local function BuildKeybindPanel()
        local Panel = {};

        local Frame = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Size = UDim2.fromOffset(200, 96);
            Visible = false;
            ZIndex = 150;
            Parent = Library.Root;
        });

        Library:Outline(Frame, 6);
        Library:AddToRegistry(Frame, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

        local Title = Library:CreateLabel({
            Position = UDim2.fromOffset(8, 4);
            Size = UDim2.new(1, -16, 0, 16);
            TextSize = 13;
            TextTruncate = Enum.TextTruncate.AtEnd;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 151;
            Parent = Frame;
        });

        local function Button(Parent, Text, Position, Size)
            local Label = Library:CreateLabel({
                BackgroundColor3 = Library.MainColor;
                BackgroundTransparency = 0;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Position = Position;
                Size = Size;
                Text = Text;
                TextSize = 13;
                ZIndex = 152;
                Parent = Parent;
            });

            Library:Round(Label, 4);

            local Reg = Library.Registry[Label];
            Reg.BackgroundColor3 = 'MainColor';
            Reg.BorderColor3 = 'OutlineColor';

            return Label;
        end;

        local Key = Button(Frame, '', UDim2.fromOffset(8, 24), UDim2.new(1, -16, 0, 20));
        local Modes = Library:Create('Frame', { BackgroundTransparency = 1; Position = UDim2.fromOffset(8, 48); Size = UDim2.new(1, -16, 0, 18); ZIndex = 151; Parent = Frame });
        local Actions = Library:Create('Frame', { BackgroundTransparency = 1; Size = UDim2.new(1, -16, 0, 18); ZIndex = 151; Parent = Frame });

        Panel.Frame, Panel.Title, Panel.Key, Panel.Modes, Panel.Actions = Frame, Title, Key, Modes, Actions;
        Panel.ModeButtons = {
            Toggle = Button(Modes, 'Toggle', UDim2.new(), UDim2.new(0.5, -2, 1, 0));
            Hold = Button(Modes, 'Hold', UDim2.new(0.5, 2, 0, 0), UDim2.new(0.5, -2, 1, 0));
        };
        Panel.Reset = Button(Actions, 'Reset', UDim2.new(), UDim2.new(0.5, -2, 1, 0));
        Panel.Delete = Button(Actions, 'Delete', UDim2.new(0.5, 2, 0, 0), UDim2.new(0.5, -2, 1, 0));

        local Listening = {};

        local function StopListening()
            for _, Signal in ipairs(Listening) do Library:RemoveSignal(Signal) end;
            table.clear(Listening);

            task.delay(0.1, function() if #Listening == 0 then Library.PickingKey = false end end);
        end;

        function Panel:Close()
            StopListening();
            Frame.Visible = false;
        end;

        function Panel:ShowKey()
            local Picker = Panel.Target;

            if not Picker then return end;

            Key.Text = Picker.Value == 'None' and 'None' or Picker:KeyText();

            for Name, Label in next, Panel.ModeButtons do
                Label.Visible = table.find(Picker.Modes, Name) ~= nil;

                local Color = Picker.Mode == Name and 'AccentColor' or 'FontColor';
                Label.TextColor3 = Library[Color];
                Library.Registry[Label].TextColor3 = Color;
            end;

            local HasModes = Panel.ModeButtons.Toggle.Visible or Panel.ModeButtons.Hold.Visible;

            Modes.Visible = HasModes;
            Actions.Position = UDim2.fromOffset(8, HasModes and 70 or 48);
            Frame.Size = UDim2.fromOffset(200, HasModes and 94 or 72);
        end;

        function Panel:Listen()
            if Library.IsMobile or #Listening > 0 then return end;

            Library.PickingKey = true;
            Key.Text = 'Press a key...';

            local function Done(Name, Mods, Source)
                local Picker = Panel.Target;

                StopListening();
                Panel:Close();

                if Picker then Picker:Bind(Name, Mods, Source) end;
            end;

            local Started = os.clock();

            table.insert(Listening, Library:GiveSignal(Svc.UserInputService.InputBegan:Connect(function(Input)
                for Name, Type in next, Library.MouseKeys do
                    local Pos = Library:MousePos(Input);

                    if Input.UserInputType == Type and os.clock() - Started > 0.15
                        and (Name == 'MB3' or Library:IsMouseOverFrame(Key, Pos) or (Name == 'MB2' and Library:IsMouseOverFrame(Frame, Pos))) then
                        local Mods = {};

                        for _, Mod in ipairs({ 'Ctrl', 'Shift', 'Alt' }) do
                            if ModHeld(Mod) then table.insert(Mods, Mod) end;
                        end;

                        return Done(Name, Mods, Input.UserInputType);
                    end;
                end;

                if Input.UserInputType ~= Enum.UserInputType.Keyboard then return end;

                if Input.KeyCode == Enum.KeyCode.Escape then
                    Panel:Close();
                elseif not ModOf[Input.KeyCode.Name] then
                    local Mods = {};

                    for _, Mod in ipairs({ 'Ctrl', 'Shift', 'Alt' }) do
                        if ModHeld(Mod) then table.insert(Mods, Mod) end;
                    end;

                    Done(Input.KeyCode.Name, Mods, Input.KeyCode);
                end;
            end)));

            table.insert(Listening, Library:GiveSignal(Svc.UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard and ModOf[Input.KeyCode.Name] then
                    Done(Input.KeyCode.Name, {}, Input.KeyCode);
                end;
            end)));
        end;

        for Name, Label in next, Panel.ModeButtons do
            Label.InputBegan:Connect(function(Input)
                local Picker = Panel.Target;

                if not (Picker and Library:IsClick(Input, Label)) then return end;

                Picker.Mode = Name;
                Picker:Update();
                Panel:ShowKey();
                if #Listening > 0 then Key.Text = 'Press a key...' end;
                Library:AttemptSave();
            end);
        end;

        Panel.Reset.InputBegan:Connect(function(Input)
            local Picker = Panel.Target;

            if not (Picker and Library:IsTap(Input, Panel.Reset)) then return end;

            Panel:Close();
            Picker.Mode = Picker.Default[2];
            Picker:Bind(Picker.Default[1], table.clone(Picker.Default[3]), nil);
        end);

        Panel.Delete.InputBegan:Connect(function(Input)
            local Picker = Panel.Target;

            if not (Picker and Library:IsTap(Input, Panel.Delete)) then return end;

            Panel:Close();
            Picker:Bind('None', {}, nil);
        end);

        Key.InputBegan:Connect(function(Input)
            if not Panel.Target then return end;

            if Library:IsClick(Input, Key) or (Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:Covered(Input, Key)) then
                Panel:Listen();
            end;
        end);

        local Follow;

        local function Place()
            local Anchor = Panel.Anchor;

            if not (Anchor and Library:IsInView(Anchor)) then
                Panel:Close();
                return;
            end;

            local Size = Vector2.new(Frame.Size.X.Offset, Frame.Size.Y.Offset);
            local Pos = Library:ToLocal(Anchor.AbsolutePosition + Vector2.new(0, Anchor.AbsoluteSize.Y + 2));

            Frame.Position = Library:KeepOnScreen(Pos, Size, Pos.Y - Size.Y - Anchor.AbsoluteSize.Y / Library.Scale.Scale - 4);
        end;

        Panel.Place = Place;

        Frame:GetPropertyChangedSignal('Visible'):Connect(function()
            if Frame.Visible then return end;

            StopListening();
            Library.OpenedFrames[Frame] = nil;
            Panel.Target, Panel.Anchor = nil, nil;

            if Follow then Follow:Disconnect(); Follow = nil end;
        end);

        Library:GiveSignal(Svc.UserInputService.InputBegan:Connect(function(Input)
            if Frame.Visible and Library:IsPress(Input) and not Library:IsMouseOverFrame(Frame, Library:MousePos(Input)) then
                Panel:Close();
            end;
        end));

        function Panel:Open(Picker, Anchor)
            if Follow then Follow:Disconnect() end;

            Panel.Target, Panel.Anchor = Picker, Anchor;
            Title.Text = 'Keybind: ' .. tostring(Picker.Text or '');
            StopListening();
            Library.PickingKey = false;
            Panel:ShowKey();

            Frame.Visible = true;
            Library.OpenedFrames[Frame] = true;
            Place();
            Follow = Anchor:GetPropertyChangedSignal('AbsolutePosition'):Connect(Place);

        end;

        Library.KeybindPanel = Panel;

        return Panel;
    end;

    function Library:OpenKeybind(Picker, Anchor)
        if not Picker or Library.Unloaded or Library:Covered(nil, Anchor) then return end;

        local Open = Library.KeybindPanel;

        if Open and Open.Frame.Visible and Open.Target == Picker then return Open:Close() end;

        (Library.KeybindPanel or BuildKeybindPanel()):Open(Picker, Anchor);
    end;

    function Funcs:AddKeyPicker(Idx, Info)
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;

        Info.Default = Info.Default or 'None';
        Info.Text = Info.Text or ToggleLabel and ToggleLabel.Text or tostring(Idx);

        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Mode = Info.Mode or 'Toggle';
            Type = 'KeyPicker';
            Text = Info.Text;
            User = Info.User;
            Callback = Info.Callback or function() end;
            ChangedCallback = Info.ChangedCallback or function() end;

            SyncToggleState = Info.SyncToggleState or false;
            Modifiers = Info.Modifiers or Info.DefaultModifiers or {};
        };

        local function ModsOk()
            for _, Mod in ipairs(KeyPicker.Modifiers) do
                if not ModHeld(Mod) then return false end;
            end;

            return true;
        end;

        function KeyPicker:KeyText()
            return #KeyPicker.Modifiers > 0 and (table.concat(KeyPicker.Modifiers, '+') .. '+' .. KeyPicker.Value) or tostring(KeyPicker.Value);
        end;

        local function KeyMatches(Input)
            local Key = KeyPicker.Value;

            if Library.MouseKeys[Key] then return Input.UserInputType == Library.MouseKeys[Key] and ModsOk() end;

            return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key and ModsOk();
        end;

        if KeyPicker.SyncToggleState then
            Info.Modes = { 'Toggle', 'Hold' };
            if KeyPicker.Mode ~= 'Hold' then KeyPicker.Mode = 'Toggle' end;
        end;

        KeyPicker.Modes = Info.Modes or { 'Always', 'Toggle', 'Hold', 'Press' };
        KeyPicker.Default = { Info.Default, KeyPicker.Mode, table.clone(KeyPicker.Modifiers) };

        local PickOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = 6;
            Parent = self.AddonRow or ToggleLabel;
        });

        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 7;
            Parent = PickOuter;
        });

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = Info.Default;
            TextWrapped = true;
            ZIndex = 8;
            Parent = PickInner;
        });

        local PickHit = Library:HitFrame(PickOuter, UDim2.new(1, 10, 0, Library.RowHeight), 30);

        local function ShowKey()
            DisplayLabel.Text = KeyPicker:KeyText();
            PickOuter.Size = UDim2.new(0, math.max(28, Library:GetTextBounds(DisplayLabel.Text, 13) + 8), 0, 15);

            PickOuter.Visible = KeyPicker.Value ~= 'None' or (ParentObj.Type ~= 'Toggle' and ParentObj.Type ~= 'Button');

            if Library.KeybindPanel and Library.KeybindPanel.Target == KeyPicker then Library.KeybindPanel:ShowKey() end;
        end;

        ShowKey();

        local ContainerLabel = Library:CreateLabel({
            TextXAlignment = Enum.TextXAlignment.Left;
            Size = UDim2.new(1, 0, 0, 18);
            TextSize = 13;
            Visible = false;
            ZIndex = 110;
            Parent = Library.KeybindContainer;
        },  true);

        function KeyPicker:Update()
            if Info.NoUI then
                return;
            end;

            local State = KeyPicker:GetState();

            ContainerLabel.Text = Library.KeybindShow.Type and string.format('[%s] %s (%s)', KeyPicker:KeyText(), Info.Text, KeyPicker.Mode)
                or string.format('[%s] %s', KeyPicker:KeyText(), Info.Text);

            local Unbound = KeyPicker.Value == 'None' and (Library.HideUnboundKeybinds or KeyPicker.User or Library.KeybindFilter['Unbound keys']);

            ContainerLabel.Visible = not (Unbound or Library.KeybindFilter[KeyPicker.Mode .. ' keys']);
            ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;

            Library.Registry[ContainerLabel].TextColor3 = State and 'AccentColor' or 'FontColor';

            Library:SizeKeybindFrame();
        end;

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true;
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Held then return true end;

                if KeyPicker.Value == 'None' then
                    return false;
                end;

                local Key = KeyPicker.Value;

                if Library.MouseKeys[Key] then
                    return ModsOk() and Svc.UserInputService:IsMouseButtonPressed(Library.MouseKeys[Key]);
                else
                    return ModsOk() and Svc.UserInputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                end;
            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode, Mods = Data[1], Data[2], Data[3];

            if type(Key) == 'string' and (Key == 'None' or Library.MouseKeys[Key] or Enum.KeyCode:FromName(Key)) then
                KeyPicker.Value = Key;
            end;

            if type(Mods) == 'table' then
                KeyPicker.Modifiers = {};

                for _, Mod in ipairs(Mods) do
                    if ModKeys[Mod] and not table.find(KeyPicker.Modifiers, Mod) then table.insert(KeyPicker.Modifiers, Mod) end;
                end;
            end;

            if table.find(KeyPicker.Modes, Mode) then KeyPicker.Mode = Mode end;

            ShowKey();
            KeyPicker:Update();
        end;

        function KeyPicker:Bind(Key, Mods, Source)
            KeyPicker.Value = Key;
            KeyPicker.Modifiers = Mods or {};
            ShowKey();

            Library:SafeCallback(KeyPicker.ChangedCallback, Source);
            Library:SafeCallback(KeyPicker.Changed, Source);

            Library:AttemptSave();
            KeyPicker:Update();
        end;

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback;
        end;

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback;
            Library:SafeCallback(Callback, KeyPicker.Value);
        end;

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker);
        end;

        function KeyPicker:DoClick(State)
            if State == nil then State = KeyPicker.Toggled end;

            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                ParentObj:SetValue(KeyPicker.Mode == 'Toggle' and not ParentObj.Value or State);
            end;

            Library:SafeCallback(KeyPicker.Callback, State);
            Library:SafeCallback(KeyPicker.Clicked, State);
        end;

        function KeyPicker:Tap()
            if KeyPicker.Mode == 'Toggle' then
                KeyPicker.Toggled = not KeyPicker.Toggled;
                KeyPicker:DoClick(KeyPicker.Toggled);
            elseif KeyPicker.Mode == 'Press' then
                KeyPicker:DoClick(true);
            elseif KeyPicker.Mode == 'Hold' then
                KeyPicker.Held = not KeyPicker.Held;
                KeyPicker:DoClick(KeyPicker.Held);
            end;

            KeyPicker:Update();
        end;

        ContainerLabel.InputEnded:Connect(function(Input)
            if Library:IsPress(Input) and not Library._kbMoved and not Library:Covered(Input, ContainerLabel)
                and Library:IsMouseOverFrame(ContainerLabel, Library:MousePos(Input)) then
                KeyPicker:Tap();
            end;
        end);

        if Info.MobileButton and Library.IsMobile then
            Library.MobileKeyButtons = (Library.MobileKeyButtons or 0) + 1;

            local Button = Library:Create('TextButton', {
                AutoButtonColor = false;
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                Position = UDim2.fromOffset(12, 130 + (Library.MobileKeyButtons - 1) * 50);
                Size = UDim2.fromOffset(44, 44);
                Text = '';
                ZIndex = 240;
                Parent = Library.Root;
            });

            Library:AddToRegistry(Button, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });
            Library:CreateLabel({ Size = UDim2.fromScale(1, 1); Text = Info.Text or tostring(KeyPicker.Value); TextSize = 12; TextWrapped = true; ZIndex = 241; Parent = Button });

            Button.InputBegan:Connect(function(Input)
                if not Library:IsPress(Input) then return end;

                if KeyPicker.Mode == 'Hold' then
                    KeyPicker.Held = true;
                    KeyPicker:DoClick(true);
                    KeyPicker:Update();

                    local End; End = Svc.UserInputService.InputEnded:Connect(function(Done)
                        if Done ~= Input then return end;
                        End:Disconnect();
                        KeyPicker.Held = false;
                        KeyPicker:DoClick(false);
                        KeyPicker:Update();
                    end);
                else
                    KeyPicker:Tap();
                end;
            end);

            KeyPicker.MobileButton = Button;
            Library:DestroyWith(ToggleLabel, Button);
        end;

        KeyPicker.Hit = PickHit;

        PickHit.InputBegan:Connect(function(Input)
            if Library:IsClick(Input) then Library:OpenKeybind(KeyPicker, ToggleLabel) end;
        end);

        Library:GiveSignal(Svc.UserInputService.InputBegan:Connect(function(Input)
            if Library.PickingKey then return end;

            if KeyPicker.Value ~= 'None' and KeyMatches(Input) then
                if KeyPicker.Mode == 'Toggle' then
                    KeyPicker.Toggled = not KeyPicker.Toggled;
                    KeyPicker:DoClick(KeyPicker.Toggled);
                elseif KeyPicker.Mode == 'Press' then
                    KeyPicker:DoClick(true);
                elseif KeyPicker.Mode == 'Hold' then
                    KeyPicker.Held = true;
                    KeyPicker:DoClick(true);
                end;
            end;

            KeyPicker:Update();
        end), ToggleLabel);

        Library:GiveSignal(Svc.UserInputService.InputEnded:Connect(function(Input)
            if Library.PickingKey then return end;

            local Key = KeyPicker.Value;

            if KeyPicker.Held and (Input.KeyCode.Name == Key or (Library.MouseKeys[Key] and Input.UserInputType == Library.MouseKeys[Key])) then

                KeyPicker.Held = false;
                KeyPicker:DoClick(false);
            end;

            KeyPicker:Update();
        end), ToggleLabel);

        Library:DestroyWith(ToggleLabel, ContainerLabel);

        KeyPicker:Update();

        Options[Idx] = KeyPicker;

        return self;
    end;

    BaseAddons.__index = Funcs;
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...);
    end;
end;

local BaseGroupbox = {};

do
    local Funcs = {};

    function Funcs:SetVisible(Bool)
        local Top = self.Top or self;

        Top.BoxOuter.Visible = not not Bool;
        if Bool then
            Top.BoxInner.Parent = Top.BoxOuter;
        else
            Library:Detach(Top.BoxInner);
        end;
    end;

    function Funcs:AddBlank(Size)
        return Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = 1;
            Parent = self.Container;
        });
    end;

    function Funcs:AddLabel(Text, DoesWrap)
        local Info = {};

        if type(Text) == 'table' then
            Info = Text;
        elseif type(DoesWrap) == 'table' then
            Info = DoesWrap;
        else
            Info = { Text = Text, DoesWrap = DoesWrap };
        end;

        DoesWrap = Info.DoesWrap;

        local Label = { Type = 'Label' };

        local Groupbox = self;
        local Container = Groupbox.Container;
        local Mark = Library:Mark(Container);

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = 14;
            RichText = true;
            Text = Info.Text or '';
            TextWrapped = DoesWrap or false;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        if DoesWrap then
            TextLabel.TextYAlignment = Enum.TextYAlignment.Top;

            local function Fit()
                local Width = TextLabel.AbsoluteSize.X / Library.Scale.Scale;
                if Width <= 0 then return end;

                local _, Height = Library:GetTextBounds((TextLabel.Text:gsub('<[^>]+>', '')), 14, Vector2.new(Width, math.huge));
                Height = math.max(Height, 15);

                if TextLabel.Size.Y.Offset ~= Height then
                    TextLabel.Size = UDim2.new(1, -4, 0, Height);
                    Groupbox:Resize();
                end;
            end;

            TextLabel:GetPropertyChangedSignal('AbsoluteSize'):Connect(Fit);
            TextLabel:GetPropertyChangedSignal('Text'):Connect(Fit);
            TextLabel:GetPropertyChangedSignal('FontFace'):Connect(Fit);
            task.defer(Fit);
        else
            Label.AddonRow = Library:AddonRow(TextLabel);
        end;

        Label.TextLabel = TextLabel;
        Label.Container = Container;

        function Label:SetText(NewText)
            TextLabel.Text = NewText;
            Label.SearchText = NewText;
        end;

        if (not DoesWrap) then
            setmetatable(Label, BaseAddons);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Library:ApplyCommon(Label, Info, { Groupbox = Groupbox, Mark = Mark, Text = TextLabel, Hover = TextLabel });

        return Label;
    end;

    function Funcs:AddButton(...)
        local Button = { Type = 'Button' };

        local function ProcessButtonParams(Obj, ...)
            local Props = select(1, ...);
            if type(Props) == 'string' and type(select(2, ...)) == 'table' then Props = select(2, ...) end;
            local Info = type(Props) == 'table' and Props or { Text = select(1, ...), Func = select(2, ...) };

            Obj.Text = Info.Text;
            Obj.Func = Info.Func or Info.Callback;
            Obj.DoubleClick = Info.DoubleClick;
            Obj.Tooltip = Info.Tooltip;

            assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');

            return Info;
        end;

        local Info = ProcessButtonParams(Button, ...);

        local Groupbox = self;
        local Container = Groupbox.Container;
        local Mark = Library:Mark(Container);

        local function CreateBaseButton(Btn)
            local Outer = Library:Create('Frame', {
                BackgroundTransparency = 1;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, Library.RowHeight);
                ZIndex = 5;
            });

            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                ClipsDescendants = true;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = Outer;
            });

            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 14;
                Text = Btn.Text;
                ZIndex = 6;
                Parent = Inner;
            });

            Library:FitText(Label, 14, 11);

            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black';
            });

            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor';
                BackgroundTransparency = 'ElementTransparency';
                BorderColor3 = 'OutlineColor';
            });

            Library:OnHighlight(Outer, Outer,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            return Outer, Inner, Label;
        end;

        local function InitEvents(Btn)
            local function Disarm()
                Btn.Armed = false;
                Btn.Label.Text = Btn.Text;

                local Name = Btn.Risky and 'RiskColor' or 'FontColor';
                Btn.Label.TextColor3 = Library[Name];
                Library.Registry[Btn.Label].TextColor3 = Name;
            end;

            function Btn:Click()
                if Btn.Disabled then return end;

                if Btn.DoubleClick and not Btn.Armed then
                    Btn.Armed = true;
                    Btn.Label.Text = 'Are you sure?';
                    Btn.Label.TextColor3 = Library.AccentColor;
                    Library.Registry[Btn.Label].TextColor3 = 'AccentColor';

                    task.delay(2, function()
                        if Btn.Armed then Disarm() end;
                    end);

                    return;
                end;

                if Btn.Armed then Disarm() end;

                Library:Ripple(Btn.Inner);
                Library:SafeCallback(Btn.Func);
            end;

            function Btn:SetText(NewText)
                Btn.Text = NewText;
                Btn.Label.Text = NewText;
                Btn.SearchText = NewText;
            end;

            Btn.Outer.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                    if not Btn.Disabled then Library:OpenKeybind(Btn:GetBind(), Btn.Outer) end;
                elseif Library:IsClick(Input) then
                    Btn:Click();
                end;
            end);

            local Id, Count = 'Button_' .. tostring(Btn.Text), 1;

            while Library.Binds[Id] do
                Count += 1;
                Id = 'Button_' .. tostring(Btn.Text) .. '_' .. Count;
            end;

            function Btn:GetBind()
                if Btn.Bind then return Btn.Bind end;

                local Holder = Library:Create('Frame', { BackgroundTransparency = 1; Size = UDim2.new(1, -4, 1, 0); ZIndex = 7; Parent = Btn.Inner });

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Holder;
                });

                setmetatable({ TextLabel = Holder, Type = 'Button' }, BaseAddons):AddKeyPicker(Id, {
                    Default = 'None'; Mode = 'Press'; Modes = { 'Press' }; Text = Btn.Text; User = true;
                    Callback = function() Btn:Click() end;
                });

                Btn.Bind = Options[Id];

                return Btn.Bind;
            end;

            Library.Binds[Id] = function() return Btn:GetBind() end;
        end;

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button);
        Button.Outer.Parent = Container;

        InitEvents(Button);

        function Button:AddTooltip(tooltip)
            if type(tooltip) == 'string' then
                Library:AddToolTip(tooltip, self.Outer);
            end;
            return self;
        end;

        function Button:AddButton(...)
            local SubButton = { Type = 'Button' };

            local SubInfo = ProcessButtonParams(SubButton, ...);

            self.Outer.Size = UDim2.new(0.5, -4, 0, Library.RowHeight);

            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton);

            SubButton.Outer.Position = UDim2.new(1, 4, 0, 0);
            SubButton.Outer.Size = UDim2.new(1, 0, 1, 0);
            SubButton.Outer.Parent = self.Outer;

            function SubButton:AddTooltip(tooltip)
                if type(tooltip) == 'string' then
                    Library:AddToolTip(tooltip, self.Outer);
                end;
                return SubButton;
            end;

            InitEvents(SubButton);

            Library:ApplyCommon(SubButton, SubInfo, {
                Groupbox = Groupbox, Roots = { SubButton.Outer }, Text = SubButton.Label, Hover = SubButton.Outer, NoSearch = true;
            });

            return SubButton;
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Library:ApplyCommon(Button, Info, { Groupbox = Groupbox, Mark = Mark, Text = Button.Label, Hover = Button.Outer });

        return Button;
    end;

    function Funcs:AddDivider()
        local Groupbox = self;
        local Container = self.Container;

        local Divider = {
            Type = 'Divider';
        };

        Groupbox:AddBlank(2);
        local DividerOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 5);
            ZIndex = 5;
            Parent = Container;
        });

        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DividerOuter;
        });

        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black';
        });

        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor';
            BackgroundTransparency = 'ElementTransparency';
            BorderColor3 = 'OutlineColor';
        });

        Groupbox:AddBlank(9);
        Groupbox:Resize();

        return Divider;
    end;

    function Funcs:AddInput(Idx, Info)
        local Textbox = {
            Value = Info.Default or '';
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Type = 'Input';
            Callback = Info.Callback or function() end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;
        local Mark = Library:Mark(Container);

        local InputLabel;

        if Info.Text then
            InputLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(1);
        end;

        local TextBoxOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, Library.RowHeight);
            ZIndex = 5;
            Parent = Container;
        });

        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = TextBoxOuter;
        });

        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor';
            BackgroundTransparency = 'ElementTransparency';
            BorderColor3 = 'OutlineColor';
        });

        Library:OnHighlight(TextBoxOuter, TextBoxOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        local BoxClip = Library:Create('Frame', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;

            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);

            ZIndex = 7;
            Parent = TextBoxInner;
        });

        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1;

            Position = UDim2.fromOffset(0, 0);
            Size = UDim2.fromScale(5, 1);

            ClearTextOnFocus = Info.ClearTextOnFocus ~= false;
            FontFace = Library.FontFace;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = Info.Placeholder or '';

            Text = Info.Default or '';
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;

            ZIndex = 7;
            Parent = BoxClip;
        });

        Library:ApplyTextStroke(Box);

        function Textbox:SetValue(Text)
            Text = tostring(Text);

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value;
                end;
            end;

            Textbox.Value = Text;
            Box.Text = Text;

            Library:SafeCallback(Textbox.Callback, Textbox.Value);
            Library:SafeCallback(Textbox.Changed, Textbox.Value);
        end;

        if Textbox.Finished then
            Box.FocusLost:Connect(function(EnterPressed)
                if not EnterPressed then return end;

                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end);
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end);
        end;

        local function Update()
            local Padding = 2;
            local Reveal = BoxClip.AbsoluteSize.X;

            if not Box:IsFocused() or Box.TextBounds.X <= Reveal - 2 * Padding then
                Box.Position = UDim2.new(0, Padding, 0, 0);
            else
                local Cursor = Box.CursorPosition;
                if Cursor ~= -1 then
                    local Subtext = string.sub(Box.Text, 1, Cursor-1);
                    local Width = Library:GetTextBounds(Subtext, Box.TextSize, Vector2.new(math.huge, math.huge));

                    local CursorPosition = Box.Position.X.Offset + Width;

                    if CursorPosition < Padding then
                        Box.Position = UDim2.fromOffset(Padding-Width, 0);
                    elseif CursorPosition > Reveal - Padding - 1 then
                        Box.Position = UDim2.fromOffset(Reveal-Width-Padding-1, 0);
                    end;
                end;
            end;
        end;

        task.spawn(Update);

        Box:GetPropertyChangedSignal('Text'):Connect(Update);
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update);
        Box.FocusLost:Connect(Update);
        Box.Focused:Connect(function()
            if Library:MouseIsOverOpenedFrame() then Box:ReleaseFocus() return end;

            Update();
        end);

        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor';
            FontFace = 'FontFace';
        });

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func;
            Library:SafeCallback(Func, Textbox.Value);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Options[Idx] = Textbox;

        Library:ApplyCommon(Textbox, Info, {
            Groupbox = Groupbox, Mark = Mark, Text = InputLabel or Box, Hover = TextBoxOuter, Dim = { Box };
            OnDisabled = function(Disabled) Box.TextEditable = not Disabled end;
        });

        return Textbox;
    end;

    function Funcs:AddToggle(Idx, Info)
        assert(Info.Text, '[lib] toggle is missing its Text');

        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';
            Style = Info.Style == 'Switch' and 'Switch' or 'Checkbox';

            Callback = Info.Callback or function() end;
            Addons = {};
        };

        local Groupbox = self;
        local Container = Groupbox.Container;
        local Mark = Library:Mark(Container);
        local Switch = Toggle.Style == 'Switch';

        local ToggleOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderColor3 = Color3.new(0, 0, 0);
            Size = Switch and UDim2.fromOffset(26, 13) or UDim2.fromOffset(13, 13);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black';
        });

        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ToggleOuter;
        });

        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor';
            BackgroundTransparency = 'ElementTransparency';
            BorderColor3 = 'OutlineColor';
        });

        local CheckGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(165, 165, 165));
            Enabled = false;
            Rotation = 90;
            Parent = ToggleInner;
        });

        local Knob;
        if Switch then
            Knob = Library:Create('Frame', {
                AnchorPoint = Vector2.new(0, 0.5);
                BackgroundColor3 = Color3.new(1, 1, 1);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 2, 0.5, 0);
                Size = UDim2.fromOffset(7, 7);
                ZIndex = 7;
                Parent = ToggleInner;
            });

            Library:Round(Knob, 2);
        end;

        local ToggleLabel = Library:CreateLabel({
            Size = UDim2.new(0, 216, 1, 0);
            Position = UDim2.new(1, 6, 0, 0);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = ToggleInner;
        });

        Toggle.AddonRow = Library:AddonRow(ToggleLabel);

        local ToggleRegion = Library:Create('Frame', {
            Active = true;
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0.5, -10);
            Size = UDim2.new(0, 170, 0, 20);
            ZIndex = 8;
            Parent = ToggleOuter;
        });

        local function FitRow()
            local Width = Container.AbsoluteSize.X / Library.Scale.Scale - 4;

            if Width <= 0 then return end;

            ToggleLabel.Size = UDim2.new(0, Width - ToggleOuter.Size.X.Offset - 6, 1, 0);
            ToggleRegion.Size = UDim2.new(0, Width, 0, 20);
        end;

        Container:GetPropertyChangedSignal('AbsoluteSize'):Connect(FitRow);
        FitRow();

        Library:OnHighlight(ToggleRegion, ToggleOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        function Toggle:UpdateColors()
            Toggle:Display();
        end;

        function Toggle:Display()
            local Reg = Library.Registry[ToggleInner];
            local On = Toggle.Value;

            CheckGradient.Enabled = On;

            Reg.BackgroundColor3 = On and 'AccentColor' or 'MainColor';
            Reg.BackgroundTransparency = On and 'NoTransparency' or 'ElementTransparency';
            ToggleInner.BackgroundTransparency = On and 0 or Library.ElementTransparency;
            Reg.BorderColor3 = On and 'AccentColorDark' or 'OutlineColor';

            Library:Tween(ToggleInner, {
                BackgroundColor3 = On and Library.AccentColor or Library.MainColor;
                BorderColor3 = On and Library.AccentColorDark or Library.OutlineColor;
            }, 0.1);

            if Knob then
                Library:Tween(Knob, { Position = On and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }, 0.12);
            end;
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Library:SafeCallback(Func, Toggle.Value);
        end;

        function Toggle:SetValue(Bool)
            Bool = (not not Bool);

            Toggle.Value = Bool;
            Toggle:Display();

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool;
                    Addon:Update();
                end;
            end;

            Library:SafeCallback(Toggle.Callback, Toggle.Value);
            Library:SafeCallback(Toggle.Changed, Toggle.Value);
            Library:UpdateDependencyBoxes();
        end;

        function Toggle:Click()
            if Toggle.Disabled then return end;

            Toggle:SetValue(not Toggle.Value);
            Library:AttemptSave();
        end;

        ToggleRegion.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                if not Toggle.Disabled then Library:OpenKeybind(Toggle:GetBind(), ToggleRegion) end;
            elseif Library:IsPress(Input) and Toggle:OverAddon(Input) then
                return;
            elseif Library:IsClick(Input) then
                Toggle:Click();
            end;
        end);

        function Toggle:OverAddon(Input)
            local Pos = Library:MousePos(Input);

            for _, Addon in ipairs(Toggle.Addons) do
                local Hit = Addon.Hit;

                if Hit and Hit.Parent and Hit.Parent.Visible and Library:IsMouseOverFrame(Hit, Pos) then return true end;
            end;

            return false;
        end;

        function Toggle:GetBind()
            for _, Addon in ipairs(Toggle.Addons) do
                if Addon.Type == 'KeyPicker' then return Addon end;
            end;

            Toggle:AddKeyPicker(Idx .. '_Bind', { Default = 'None', Mode = 'Toggle', SyncToggleState = true, Text = Info.Text, User = true });

            return Options[Idx .. '_Bind'];
        end;

        Library.Binds[Idx .. '_Bind'] = function() return Toggle:GetBind() end;

        Toggle:Display();
        Groupbox:AddBlank(Info.BlankSize or 5 + 2);
        Groupbox:Resize();

        Toggle.TextLabel = ToggleLabel;
        Toggle.Hit = ToggleRegion;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);

        Toggles[Idx] = Toggle;

        Library:ApplyCommon(Toggle, Info, { Groupbox = Groupbox, Mark = Mark, Text = ToggleLabel, Hover = ToggleRegion });
        Library:UpdateDependencyBoxes();

        return Toggle;
    end;

    function Funcs:AddSlider(Idx, Info)
        assert(Info.Default, '[lib] slider is missing its Default value');
        assert(Info.Text, '[lib] slider is missing its Text');
        assert(Info.Min, '[lib] slider is missing its Min');
        assert(Info.Max, '[lib] slider is missing its Max');
        Info.Rounding = Info.Rounding or 0;

        local Slider = {
            Value = Info.Default;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = Info.Rounding;
            Type = 'Slider';
            Callback = Info.Callback or function() end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;
        local Mark = Library:Mark(Container);

        local TitleLabel;

        if not Info.Compact then
            TitleLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextTruncate = Enum.TextTruncate.AtEnd;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end;

        local SliderOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 14);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black';
        });

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = SliderOuter;
        });

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor';
            BackgroundTransparency = 'ElementTransparency';
            BorderColor3 = 'OutlineColor';
        });

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Info.Color or Library.AccentColor;
            BorderColor3 = Info.Color and Library:GetDarkerColor(Info.Color) or Library.AccentColorDark;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderInner;
        });

        if not Info.Color then
            Library:AddToRegistry(Fill, {
                BackgroundColor3 = 'AccentColor';
                BorderColor3 = 'AccentColorDark';
            });
        end;

        Library:Create('UIGradient', {
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(165, 165, 165));
            Rotation = 90;
            Parent = Fill;
        });

        local function HiddenWhenRound() return Library.RoundEdges and 1 or 0 end;

        local HideBorderRight = Library:Create('Frame', {
            BackgroundColor3 = Info.Color or Library.AccentColor;
            BackgroundTransparency = HiddenWhenRound();
            BorderSizePixel = 0;
            Position = UDim2.new(1, 0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 8;
            Parent = Fill;
        });

        Library:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = not Info.Color and 'AccentColor' or nil;
            BackgroundTransparency = HiddenWhenRound;
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = 'Infinite';
            ZIndex = 9;
            Parent = SliderInner;
        });

        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        local Edit = Library:Create('TextBox', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            ClearTextOnFocus = false;
            FontFace = Library.FontFace;
            Size = UDim2.new(1, 0, 1, 0);
            Text = '';
            TextColor3 = Library.FontColor;
            TextSize = 14;
            Visible = false;
            ZIndex = 12;
            Parent = SliderInner;
        });

        Library:Round(Edit, 4);
        Library:AddToRegistry(Edit, { BackgroundColor3 = 'MainColor'; TextColor3 = 'FontColor'; FontFace = 'FontFace' });

        local SliderHit = Library:HitFrame(SliderOuter, UDim2.new(1, 0, 0, Library.RowHeight), 30);

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
            Fill.BorderColor3 = Library.AccentColorDark;
        end;

        function Slider:Display(Instant)
            local Suffix = Info.Suffix or '';
            local Ratio = Slider.Max == Slider.Min and 0 or (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min);

            if Info.FormatDisplayValue then
                DisplayLabel.Text = Library:Format(Info.FormatDisplayValue, tostring(Slider.Value) .. Suffix, Slider, Slider.Value);
            elseif Info.Compact then
                DisplayLabel.Text = Info.Text .. ': ' .. Slider.Value .. Suffix;
            elseif Info.HideMax then
                DisplayLabel.Text = string.format('%s', Slider.Value .. Suffix);
            else
                DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix);
            end;

            Library:LerpSlider(Slider, Fill, Ratio, Instant);

            HideBorderRight.Visible = not (Ratio <= 0 or Ratio >= 1);
        end;

        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Library:SafeCallback(Func, Slider.Value);
        end;

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value);
            end;

            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value));
        end;

        function Slider:SetValue(Str)
            local Num = tonumber(Str);

            if (not Num) or Num ~= Num then
                return;
            end;

            Slider.Value = Round(math.clamp(Num, Slider.Min, Slider.Max));
            Slider:Display();

            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
        end;

        local LastClick = 0;
        local StopDrag, PressStart;

        local function Commit()
            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
        end;

        local function OpenEdit()
            if Slider.Disabled or Library:MouseIsOverOpenedFrame() then return end;

            if PressStart and Slider.Value ~= PressStart then Slider:SetValue(PressStart) end;
            if StopDrag then StopDrag() end;

            Edit.Text = '';
            Edit.Visible = true;
            DisplayLabel.Visible, Fill.Visible = false, false;
            SliderHit.Visible = false;
            Edit:CaptureFocus();
        end;

        local function Slide(Pos)
            local Ratio = math.clamp((Pos.X - SliderInner.AbsolutePosition.X) / math.max(SliderInner.AbsoluteSize.X, 1), 0, 1);
            local NewValue = Round(Slider.Min + (Slider.Max - Slider.Min) * Ratio);

            if NewValue ~= Slider.Value then
                Slider.Value = NewValue;
                Slider:Display();

                if not Info.OnRelease then Commit() end;
            end;
        end;

        local function Release()
            local Start = PressStart;

            StopDrag, PressStart = nil, nil;

            if Info.OnRelease and Slider.Value ~= Start then Commit() end;

            Library:AttemptSave();
        end;

        SliderHit.InputBegan:Connect(function(Input)
            if not Library:IsPress(Input) or Slider.Disabled or Library:MouseIsOverOpenedFrame() then
                return;
            end;

            local Intent = Input.UserInputType == Enum.UserInputType.Touch and Library:Gesture(Input);

            if Intent == 'Scroll' or Intent == 'None' then return end;

            if Input.UserInputType == Enum.UserInputType.Touch then
                local Now = os.clock();

                if Now - LastClick < 0.35 then
                    LastClick = 0;
                    OpenEdit();
                    return;
                end;

                LastClick = Now;
            end;

            PressStart = Slider.Value;

            if Intent == 'Tap' then
                Slide(Library:MousePos(Input));
                Release();
                return;
            end;

            StopDrag = Library:Drag(Input, Slide, Release);
        end);

        Slider.Hold = Library:OnLongPress(SliderHit, OpenEdit);

        Edit.FocusLost:Connect(function()
            Edit.Visible = false;
            DisplayLabel.Visible, Fill.Visible = true, true;
            SliderHit.Visible = true;
            Slider:SetValue(Edit.Text);
            Library:AttemptSave();
        end);

        Slider.Edit, Slider.Hit, Slider.ValueLabel, Slider.Fill = Edit, SliderHit, DisplayLabel, Fill;

        Slider:Display(true);
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();

        Options[Idx] = Slider;

        Library:ApplyCommon(Slider, Info, {
            Groupbox = Groupbox, Mark = Mark, Text = TitleLabel or DisplayLabel, Hover = SliderOuter, Dim = { DisplayLabel, TitleLabel };
        });

        return Slider;
    end;

    function Funcs:AddDropdown(Idx, Info)
        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString();
            Info.AllowNull = true;
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString();
            Info.AllowNull = true;
        end;

        local function Filter(Values)
            if Info.ExcludeLocalPlayer and Info.SpecialType == 'Player' then
                local Name = Svc.Players.LocalPlayer.Name;
                Values = table.clone(Values);
                local At = table.find(Values, Name);
                if At then table.remove(Values, At) end;
            end;

            return Values;
        end;

        Info.Values = Info.Values and Filter(Info.Values);

        assert(Info.Values, '[lib] dropdown is missing its Values list');
        assert(Info.AllowNull or Info.Default, '[lib] dropdown has no Default; set AllowNull = true if that is on purpose');

        if (not Info.Text) then
            Info.Compact = true;
        end;

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType;
            DisabledValues = Info.DisabledValues or {};
            Callback = Info.Callback or function() end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;
        local Mark = Library:Mark(Container);

        local DropdownLabel;

        if not Info.Compact then
            DropdownLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                TextTruncate = Enum.TextTruncate.AtEnd;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end;

        local DropdownOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, Library.RowHeight);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(DropdownOuter, {
            BorderColor3 = 'Black';
        });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        });

        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor';
            BackgroundTransparency = 'ElementTransparency';
            BorderColor3 = 'OutlineColor';
        });

        local DropdownArrow = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -16, 0.5, 0);
            Size = UDim2.new(0, 12, 0, 12);
            Image = 'http://www.roblox.com/asset/?id=6282522798';
            ZIndex = 8;
            Parent = DropdownInner;
        });

        local ItemList = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            TextSize = 14;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 7;
            Parent = DropdownInner;
        });

        Library:FitText(ItemList, 14, 11);

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        local MaxItems = Info.MaxVisibleDropdownItems or 8;
        local Row = Library.RowHeight;
        local SearchHeight = Info.Searchable and Row or 0;
        local Query = '';

        local ListOuter = Library:Create('Frame', {
            Active = true;
            BackgroundTransparency = 1;
            BorderColor3 = Color3.new(0, 0, 0);
            ZIndex = 20;
            Visible = false;
            Parent = Library.Root;
        });

        local function RecalculateListPosition()
            if ListOuter.Visible and not Library:IsInView(DropdownOuter) then
                Dropdown:CloseDropdown();
                return;
            end;

            local Size = Vector2.new(ListOuter.Size.X.Offset, ListOuter.Size.Y.Offset);

            local Below = Library:ToLocal(DropdownOuter.AbsolutePosition + Vector2.new(Library.Scale.Scale, DropdownOuter.AbsoluteSize.Y + Library.Scale.Scale));
            local Above = Library:ToLocal(DropdownOuter.AbsolutePosition).Y - Size.Y - 1;

            ListOuter.Position = Library:KeepOnScreen(Below, Size, Above);
        end;

        local ListHeight = SearchHeight + MaxItems * Row + 2;
        local Entries = {};

        local function RecalculateListSize(YSize)
            ListHeight = YSize or ListHeight;

            local Width = DropdownOuter.AbsoluteSize.X / Library.Scale.Scale;
            local Widest = 0;

            for _, Entry in ipairs(Entries) do Widest = math.max(Widest, Library:GetTextBounds(Entry.Text, 14)) end;

            ListOuter.Size = UDim2.fromOffset(math.max(Width - 2, math.min(Widest + 20, 320), 20), ListHeight);

            if ListOuter.Visible then RecalculateListPosition() end;
        end;

        RecalculateListSize();

        local ListFollow;

        ListOuter:GetPropertyChangedSignal('Visible'):Connect(function()
            if ListOuter.Visible then
                RecalculateListSize();
                RecalculateListPosition();
                ListFollow = ListFollow or DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);
            elseif ListFollow then
                ListFollow:Disconnect();
                ListFollow = nil;
            end;
        end);

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
        });

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Outline(ListInner, 4);

        local function CornerGap() return UDim.new(0, Library.RoundEdges and 2 or 0) end;
        local ListPadding = Library:Create('UIPadding', {
            PaddingTop = CornerGap(); PaddingBottom = CornerGap(); PaddingLeft = CornerGap(); PaddingRight = CornerGap();
            Parent = ListInner;
        });

        Library:AddToRegistry(ListPadding, { PaddingTop = CornerGap; PaddingBottom = CornerGap; PaddingLeft = CornerGap; PaddingRight = CornerGap });

        local SearchBox;

        if Info.Searchable then
            SearchBox = Library:Create('TextBox', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderSizePixel = 0;
                ClearTextOnFocus = false;
                FontFace = Library.FontFace;
                PlaceholderColor3 = Color3.fromRGB(150, 150, 150);
                PlaceholderText = 'Search...';
                Size = UDim2.new(1, 0, 0, Row);
                Text = '';
                TextColor3 = Library.FontColor;
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 24;
                Parent = ListInner;
            });

            Library:Round(SearchBox, 3);
            Library:Create('UIPadding', { PaddingLeft = UDim.new(0, 6), Parent = SearchBox });
            Library:AddToRegistry(SearchBox, { BackgroundColor3 = 'BackgroundColor'; TextColor3 = 'FontColor'; FontFace = 'FontFace' });
        end;

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Position = UDim2.fromOffset(0, SearchHeight);
            Size = UDim2.new(1, 0, 1, -SearchHeight);
            ZIndex = 21;
            Parent = ListInner;

            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png';
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png';

            ScrollBarThickness = 3;
            ScrollBarImageColor3 = Library.AccentColor;
        });

        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor';
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        local function Fmt(Value)
            if Info.FormatDisplayValue then
                return Library:Format(Info.FormatDisplayValue, tostring(Value), Value);
            end;

            return tostring(Value);
        end;

        function Dropdown:Display()
            local Values = Dropdown.Values;
            local Str = '';

            if Info.Multi then
                for _, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Fmt(Value) .. ', ';
                    end;
                end;

                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value and Fmt(Dropdown.Value) or '';
            end;

            ItemList.Text = (Str == '' and '--' or Str);
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};

                for Value in next, Dropdown.Value do
                    table.insert(T, Value);
                end;

                return T;
            else
                return Dropdown.Value and 1 or 0;
            end;
        end;

        local function ApplyQuery()
            local Count = 0;

            for _, Entry in ipairs(Entries) do
                local Show = Query == '' or Fmt(Entry.Value):lower():find(Query, 1, true) ~= nil;
                Entry.Frame.Visible = Show;
                if Show then Count = Count + 1 end;
            end;

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * Row) + 1);
            RecalculateListSize(SearchHeight + math.clamp(Count * Row, 0, MaxItems * Row) + 1);
        end;

        if SearchBox then
            SearchBox:GetPropertyChangedSignal('Text'):Connect(function()
                Query = SearchBox.Text:lower();
                ApplyQuery();
            end);
        end;

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values;

            for _, Entry in ipairs(Entries) do
                Entry.Frame:Destroy();
            end;

            table.clear(Entries);

            for _, Value in next, Values do
                local Table = { Value = Value, Text = Fmt(Value) };
                local Locked = table.find(Dropdown.DisabledValues, Value) ~= nil;

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Middle;
                    Size = UDim2.new(1, 1, 0, Row);
                    ZIndex = 23;
                    Active = true;
                    Parent = Scrolling;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                    BorderColor3 = 'OutlineColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, -4, 1, 0);
                    Position = UDim2.new(0, 4, 0, 0);
                    TextSize = 14;
                    Text = Fmt(Value);
                    TextTransparency = Locked and 0.6 or 0;
                    TextTruncate = Enum.TextTruncate.AtEnd;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 25;
                    Parent = Button;
                });

                local Selected;

                if not Library.IsMobile then
                    Button.MouseEnter:Connect(function()
                        if not Locked then Library:Tween(ButtonLabel, { TextColor3 = Library.AccentColor }, 0.1) end;
                    end);

                    Button.MouseLeave:Connect(function()
                        Library:Tween(ButtonLabel, { TextColor3 = Selected and Library.AccentColor or Library.FontColor }, 0.1);
                    end);
                end;

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value];
                    else
                        Selected = Dropdown.Value == Value;
                    end;

                    ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
                    Library.Registry[ButtonLabel].TextColor3 = Selected and 'AccentColor' or 'FontColor';
                end;

                ButtonLabel.InputBegan:Connect(function(Input)
                    if Library:IsClick(Input, ButtonLabel) and not Locked then
                        local Try = not Selected;

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value[Value] = true;
                                else
                                    Dropdown.Value[Value] = nil;
                                end;
                            else
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value = Value;
                                else
                                    Dropdown.Value = nil;
                                end;

                                for _, Other in ipairs(Entries) do
                                    Other:UpdateButton();
                                end;
                            end;

                            Table:UpdateButton();
                            Dropdown:Display();

                            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
                            Library:UpdateDependencyBoxes();

                            Library:AttemptSave();
                        end;
                    end;
                end);

                Table.Frame = Button;
                Table:UpdateButton();
                table.insert(Entries, Table);
            end;

            Dropdown:Display();
            ApplyQuery();
        end;

        function Dropdown:SetValues(NewValues)
            Dropdown:CloseDropdown();

            if NewValues then
                Dropdown.Values = Filter(NewValues);
            end;

            Dropdown:BuildDropdownList();
        end;

        function Dropdown:SetDisabledValues(List)
            Dropdown.DisabledValues = List or {};
            Dropdown:BuildDropdownList();
        end;

        function Dropdown:RefreshSpecial()
            Dropdown:SetValues(Dropdown.SpecialType == 'Player' and GetPlayersString() or GetTeamsString());
        end;

        function Dropdown:OpenDropdown()
            if Dropdown.Disabled then return end;

            if SearchBox then SearchBox.Text = '' end;

            RecalculateListSize();
            RecalculateListPosition();
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;
            DropdownArrow.Rotation = 180;
        end;

        function Dropdown:CloseDropdown()
            ListOuter.Visible = false;
            Library.OpenedFrames[ListOuter] = nil;
            DropdownArrow.Rotation = 0;
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Library:SafeCallback(Func, Dropdown.Value);
        end;

        function Dropdown:SetValue(Val)
            Dropdown:CloseDropdown();

            if Dropdown.Multi then
                local NewTable = {};
                Val = type(Val) == 'table' and Val or {};

                for Value in next, Val do
                    if table.find(Dropdown.Values, Value) then
                        NewTable[Value] = true;
                    end;
                end;

                Dropdown.Value = NewTable;
            else
                if (not Val) then
                    Dropdown.Value = nil;
                elseif table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val;
                end;
            end;

            Dropdown:BuildDropdownList();

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
            Library:UpdateDependencyBoxes();
        end;

        DropdownOuter.InputBegan:Connect(function(Input)
            if Library:IsClick(Input) then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown();
                else
                    Dropdown:OpenDropdown();
                end;
            end;
        end);

        Library:GiveSignal(Svc.UserInputService.InputBegan:Connect(function(Input)
            if Library:IsPress(Input) and ListOuter.Visible then
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;
                local Mouse = Library:MousePos(Input);

                if (Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y) and not Library:IsMouseOverFrame(DropdownOuter, Mouse) then

                    Dropdown:CloseDropdown();
                end;
            end;
        end), DropdownOuter);

        Library:DestroyWith(DropdownOuter, ListOuter);

        Dropdown:BuildDropdownList();

        local Defaults = {};

        if type(Info.Default) == 'string' then
            local Idx = table.find(Dropdown.Values, Info.Default);
            if Idx then
                table.insert(Defaults, Idx);
            end;
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Idx = table.find(Dropdown.Values, Value);
                if Idx then
                    table.insert(Defaults, Idx);
                end;
            end;
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default);
        end;

        if next(Defaults) then
            for _, Index in ipairs(Defaults) do
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true;
                else
                    Dropdown.Value = Dropdown.Values[Index];
                end;

                if (not Info.Multi) then break end;
            end;

            Dropdown:BuildDropdownList();
        end;

        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        Dropdown.Field, Dropdown.Shown = DropdownOuter, ItemList;

        Options[Idx] = Dropdown;

        Library:ApplyCommon(Dropdown, Info, {
            Groupbox = Groupbox, Mark = Mark, Text = DropdownLabel or ItemList, Hover = DropdownOuter, Dim = { ItemList, DropdownLabel };
            OnDisabled = function(Disabled) if Disabled then Dropdown:CloseDropdown() end end;
        });

        return Dropdown;
    end;

    function Funcs:AddList(Idx, Info)
        local Select = Info.Select or 'None';

        assert(Select == 'None' or Select == 'Single' or Select == 'Multi', '[lib] list Select must be None, Single or Multi');

        local function Source()
            local Values = Info.Values;

            if Info.SpecialType == 'Player' then
                Values = GetPlayersString();

                if Info.ExcludeLocalPlayer then
                    local At = table.find(Values, Svc.Players.LocalPlayer.Name);
                    if At then table.remove(Values, At) end;
                end;
            elseif Info.SpecialType == 'Team' then
                Values = GetTeamsString();
            end;

            return Values and table.clone(Values);
        end;

        local function KeyOf(Value)
            return tostring(type(Value) == 'table' and Value[Info.KeyColumn or 1] or Value);
        end;

        local List = {
            Values = Source();
            Value = Select == 'Multi' and {} or nil;
            Multi = Select == 'Multi';
            Select = Select;
            Type = 'List';
            SpecialType = Info.SpecialType;
            Callback = Info.Callback or function() end;
        };

        assert(List.Values, '[lib] list is missing its Values');

        local Groupbox = self;
        local Container = Groupbox.Container;
        local Mark = Library:Mark(Container);

        local ListLabel;

        if Info.Text then
            ListLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 14;
                TextTruncate = Enum.TextTruncate.AtEnd;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(1);
        end;

        local Row = Library.RowHeight;
        local Selectable = Select ~= 'None';
        local HeadH = Info.Columns and Row or 0;
        local FootH = (Info.Counter ~= false and List.Multi) and Row or 0;
        local MarkW = List.Multi and 20 or 0;
        local NumW = Info.Numbered and 26 or 0;
        local Lead = MarkW + NumW;

        local ListOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, (Info.Rows or 6) * Row + HeadH + FootH + 2);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(ListOuter, {
            BorderColor3 = 'Black';
        });

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ListOuter;
        });

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor';
            BackgroundTransparency = 'ElementTransparency';
            BorderColor3 = 'OutlineColor';
        });

        local function Strip(Position, Parent)
            local Line = Library:Create('Frame', {
                BackgroundColor3 = Library.OutlineColor;
                BorderSizePixel = 0;
                Position = Position;
                Size = UDim2.new(1, 0, 0, 1);
                ZIndex = 9;
                Parent = Parent;
            });

            Library:AddToRegistry(Line, { BackgroundColor3 = 'OutlineColor' });

            return Line;
        end;

        local function Text(Parent, Position, Size, Align)
            return Library:CreateLabel({
                Active = false;
                Position = Position;
                Size = Size;
                TextSize = 14;
                RichText = true;
                TextTruncate = Enum.TextTruncate.AtEnd;
                TextXAlignment = Align or Enum.TextXAlignment.Left;
                ZIndex = 9;
                Parent = Parent;
            });
        end;

        local HeadBody, Counter;

        if HeadH > 0 then
            local Head = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderSizePixel = 0;
                Position = UDim2.fromOffset(0, 1);
                Size = UDim2.new(1, -4, 0, HeadH);
                ZIndex = 8;
                Parent = ListInner;
            });

            Library:AddToRegistry(Head, { BackgroundColor3 = 'BackgroundColor' });
            Library:Round(Head);
            Strip(UDim2.new(0, 0, 1, -1), Head);

            HeadBody = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(Lead, 0);
                Size = UDim2.new(1, -Lead, 1, 0);
                ZIndex = 9;
                Parent = Head;
            });

            if Info.Numbered then
                local Hash = Text(Head, UDim2.fromOffset(MarkW + 6, 0), UDim2.new(0, NumW - 6, 1, 0));
                Hash.Text = '#';
                Hash.TextTransparency = 0.4;
            end;
        end;

        if FootH > 0 then
            local Foot = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 1, -1 - FootH);
                Size = UDim2.new(1, 0, 0, FootH);
                ZIndex = 8;
                Parent = ListInner;
            });

            Library:AddToRegistry(Foot, { BackgroundColor3 = 'BackgroundColor' });
            Library:Round(Foot);
            Strip(UDim2.new(0, 0, 0, 0), Foot);

            Counter = Text(Foot, UDim2.fromOffset(6, 0), UDim2.new(1, -12, 1, 0), Enum.TextXAlignment.Right);
            Counter.TextTransparency = 0.4;
        end;

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Position = UDim2.fromOffset(0, 1 + HeadH);
            Size = UDim2.new(1, 0, 1, -2 - HeadH - FootH);
            ZIndex = 7;
            Parent = ListInner;

            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png';
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png';

            ScrollBarThickness = 3;
            ScrollBarImageColor3 = Library.AccentColor;
        });

        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor';
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        local Empty = Library:CreateLabel({
            Position = UDim2.fromOffset(0, 1 + HeadH);
            Size = UDim2.new(1, 0, 0, Row);
            TextSize = 14;
            Text = Info.EmptyText or 'No entries';
            TextTransparency = 0.5;
            Visible = false;
            ZIndex = 9;
            Parent = ListInner;
        });

        local Entries = {};

        local function Shade(Entry)
            local Target = Entry.On and 0.8 or Entry.Hover and 0.9 or 1;
            Library:Tween(Entry.Tint, { BackgroundTransparency = Target }, 0.1);
        end;

        local function Paint(Entry)
            local On;

            if List.Multi then
                On = List.Value[Entry.Key] == true;
            else
                On = List.Value == Entry.Key;
            end;

            Entry.On = On;
            Entry.Bar.Visible = On;

            if Entry.Check then Entry.Check.Visible = On end;

            for _, Cell in ipairs(Entry.Cells) do
                Cell.TextColor3 = On and Library.AccentColor or Library.FontColor;
                Library.Registry[Cell].TextColor3 = On and 'AccentColor' or 'FontColor';
            end;

            Shade(Entry);
        end;

        local function Refresh()
            local Count = 0;

            for _, Entry in ipairs(Entries) do
                Paint(Entry);
                if Entry.On then Count += 1 end;
            end;

            if Counter then Counter.Text = Count .. ' selected / ' .. #Entries end;
        end;

        local function Pick(Entry)
            if not Selectable or List.Disabled then return end;

            if List.Multi then
                List.Value[Entry.Key] = (not List.Value[Entry.Key]) or nil;
            else
                List.Value = List.Value ~= Entry.Key and Entry.Key or nil;
            end;

            Refresh();

            Library:SafeCallback(List.Callback, List.Value);
            Library:SafeCallback(List.Changed, List.Value);
            Library:UpdateDependencyBoxes();

            Library:AttemptSave();
        end;

        local Cells, Natural, Cols = {}, {}, 1;

        local function Layout()
            local Room = Scrolling.AbsoluteSize.X / Library.Scale.Scale - 4 - Lead;

            if Room <= 0 then return end;

            local Width, Left, From = {}, {}, 0;

            if Info.ColumnWidths then
                local Total = 0;

                for Column = 1, Cols do Total += Info.ColumnWidths[Column] or 1 end;
                for Column = 1, Cols do Width[Column] = Room * (Info.ColumnWidths[Column] or 1) / Total end;
            else
                local Sum, Least, Floor, Widest = 0, 0, {}, 1;

                for Column = 1, Cols do
                    Natural[Column] = Natural[Column] or 10;
                    Floor[Column] = math.min(Natural[Column], 36);
                    Sum, Least = Sum + Natural[Column], Least + Floor[Column];

                    if Natural[Column] > Natural[Widest] then Widest = Column end;
                end;

                local Keep = Sum > Least and math.clamp((Room - Least) / (Sum - Least), 0, 1) or 0;

                for Column = 1, Cols do Width[Column] = Floor[Column] + (Natural[Column] - Floor[Column]) * Keep end;

                if Sum < Room then Width[Info.Elastic or Widest] += Room - Sum end;
            end;

            for Column = 1, Cols do Left[Column], From = From, From + Width[Column] end;

            for _, Item in ipairs(Cells) do
                local Room = math.max(math.floor(Width[Item.Column]) - 6, 0);

                Item.Label.Position = UDim2.fromOffset(math.floor(Left[Item.Column]) + 6, 0);
                Item.Label.Size = UDim2.new(0, Room, 1, 0);
                Item.Cut = Item.Full > Room;

                if Item.Entry and Item.Cut and not Item.Entry.Tip then
                    local Entry = Item.Entry;

                    Entry.Tip = Library:AddToolTip(function()
                        local Mouse = Library:MousePos();

                        for _, Other in ipairs(Entry.Items) do
                            if Other.Cut and Library:IsMouseOverFrame(Other.Label, Mouse) then return Other.Text end;
                        end;
                    end, Entry.Frame);
                end;
            end;
        end;

        Scrolling:GetPropertyChangedSignal('AbsoluteSize'):Connect(Layout);

        function List:BuildList()
            for _, Entry in ipairs(Entries) do
                Entry.Frame:Destroy();
            end;

            table.clear(Entries);

            table.clear(Cells);
            table.clear(Natural);

            Cols = Info.Columns and #Info.Columns or 1;

            for _, Value in ipairs(List.Values) do
                if type(Value) == 'table' then Cols = math.max(Cols, #Value) end;
            end;

            local function Measure(Column, Value)
                local Wide = Library:GetTextBounds((tostring(Value):gsub('<[^>]+>', '')), 14);

                Natural[Column] = math.max(Natural[Column] or 0, Wide + 10);

                return Wide;
            end;

            if HeadBody then
                HeadBody:ClearAllChildren();

                for Column, Name in ipairs(Info.Columns) do
                    local Cell = Text(HeadBody, UDim2.new(), UDim2.new());

                    Cell.Text = tostring(Name);
                    Cell.TextTransparency = 0.4;

                    table.insert(Cells, { Label = Cell, Column = Column, Full = Measure(Column, Name) });
                end;
            end;

            for Index, Value in ipairs(List.Values) do
                local Entry = { Key = KeyOf(Value), Cells = {} };

                Entry.Frame = Library:Create('Frame', {
                    Active = true;
                    BackgroundColor3 = Library.BackgroundColor;
                    BackgroundTransparency = Index % 2 == 0 and 0.5 or 1;
                    BorderSizePixel = 0;
                    LayoutOrder = Index;
                    Size = UDim2.new(1, -4, 0, Row);
                    ZIndex = 8;
                    Parent = Scrolling;
                });

                Library:AddToRegistry(Entry.Frame, { BackgroundColor3 = 'BackgroundColor' });
                Library:Round(Entry.Frame);

                Entry.Tint = Library:Create('Frame', {
                    BackgroundColor3 = Library.AccentColor;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 1, 0);
                    ZIndex = 8;
                    Parent = Entry.Frame;
                });

                Entry.Bar = Library:Create('Frame', {
                    BackgroundColor3 = Library.AccentColor;
                    BorderSizePixel = 0;
                    Size = UDim2.new(0, 2, 1, 0);
                    Visible = false;
                    ZIndex = 10;
                    Parent = Entry.Frame;
                });

                Library:AddToRegistry(Entry.Tint, { BackgroundColor3 = 'AccentColor' });
                Library:Round(Entry.Tint);
                Library:AddToRegistry(Entry.Bar, { BackgroundColor3 = 'AccentColor' });

                if List.Multi then
                    local Box = Library:Create('Frame', {
                        AnchorPoint = Vector2.new(0, 0.5);
                        BackgroundColor3 = Library.MainColor;
                        BorderColor3 = Library.OutlineColor;
                        BorderMode = Enum.BorderMode.Inset;
                        Position = UDim2.new(0, 6, 0.5, 0);
                        Size = UDim2.fromOffset(10, 10);
                        ZIndex = 9;
                        Parent = Entry.Frame;
                    });

                    Library:AddToRegistry(Box, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

                    Entry.Check = Library:Create('Frame', {
                        BackgroundColor3 = Library.AccentColor;
                        BorderSizePixel = 0;
                        Position = UDim2.fromOffset(2, 2);
                        Size = UDim2.new(1, -4, 1, -4);
                        Visible = false;
                        ZIndex = 10;
                        Parent = Box;
                    });

                    Library:AddToRegistry(Entry.Check, { BackgroundColor3 = 'AccentColor' });
                    Library:Round(Entry.Check);
                end;

                if Info.Numbered then
                    local Number = Text(Entry.Frame, UDim2.fromOffset(MarkW + 6, 0), UDim2.new(0, NumW - 6, 1, 0));
                    Number.Text = tostring(Index);
                    Number.TextTransparency = 0.4;
                end;

                local Body = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    Position = UDim2.fromOffset(Lead, 0);
                    Size = UDim2.new(1, -Lead, 1, 0);
                    ZIndex = 9;
                    Parent = Entry.Frame;
                });

                local Texts = type(Value) == 'table' and Value or { Value };

                Entry.Items = {};

                for Column, Cell in ipairs(Texts) do
                    local Label = Text(Body, UDim2.new(), UDim2.new());

                    Label.Text = tostring(Cell);
                    table.insert(Entry.Cells, Label);

                    local Item = { Label = Label, Column = Column, Entry = Entry, Full = Measure(Column, Cell), Text = (tostring(Cell):gsub('<[^>]+>', '')) };

                    table.insert(Entry.Items, Item);
                    table.insert(Cells, Item);
                end;

                if not Library.IsMobile and Selectable then
                    Entry.Frame.MouseEnter:Connect(function()
                        Entry.Hover = true;
                        Shade(Entry);
                    end);

                    Entry.Frame.MouseLeave:Connect(function()
                        Entry.Hover = false;
                        Shade(Entry);
                    end);
                end;

                Entry.Frame.InputBegan:Connect(function(Input)
                    if Library:IsClick(Input) then Pick(Entry) end;
                end);

                table.insert(Entries, Entry);
            end;

            Scrolling.CanvasSize = UDim2.fromOffset(0, #Entries * Row);
            Empty.Visible = #Entries == 0;

            Layout();
            Refresh();
        end;

        function List:SetValues(NewValues)
            List.Values = NewValues and table.clone(NewValues) or Source() or List.Values;
            List:BuildList();
        end;

        function List:RefreshSpecial()
            List:SetValues(Source());
        end;

        function List:SetValue(Val)
            if List.Multi then
                local NewTable = {};

                for Key in next, type(Val) == 'table' and Val or {} do
                    for _, Value in ipairs(List.Values) do
                        if KeyOf(Value) == tostring(Key) then NewTable[tostring(Key)] = true end;
                    end;
                end;

                List.Value = NewTable;
            else
                List.Value = nil;

                for _, Value in ipairs(List.Values) do
                    if Val ~= nil and KeyOf(Value) == tostring(Val) then List.Value = KeyOf(Value) end;
                end;
            end;

            Refresh();

            Library:SafeCallback(List.Callback, List.Value);
            Library:SafeCallback(List.Changed, List.Value);
            Library:UpdateDependencyBoxes();
        end;

        function List:OnChanged(Func)
            List.Changed = Func;
            Library:SafeCallback(Func, List.Value);
        end;

        function List:GetEntry(Key)
            Key = Key or (not List.Multi and List.Value) or nil;

            for _, Value in ipairs(List.Values) do
                if Key ~= nil and KeyOf(Value) == tostring(Key) then return Value end;
            end;
        end;

        function List:AddValue(Entry)
            if List:GetEntry(KeyOf(Entry)) ~= nil then return false end;

            table.insert(List.Values, Entry);
            List:BuildList();

            return true;
        end;

        function List:RemoveValue(Key)
            Key = tostring(Key);

            for At, Value in ipairs(List.Values) do
                if KeyOf(Value) == Key then
                    table.remove(List.Values, At);

                    if List.Multi then List.Value[Key] = nil elseif List.Value == Key then List.Value = nil end;

                    List:BuildList();

                    return true;
                end;
            end;

            return false;
        end;

        if Selectable and Info.Default ~= nil then
            local Defaults = type(Info.Default) == 'table' and Info.Default or { Info.Default };

            for _, Default in ipairs(Defaults) do
                local At = type(Default) == 'number' and List.Values[Default];
                local Key = At ~= nil and At ~= false and KeyOf(At) or tostring(Default);

                if List.Multi then List.Value[Key] = true else List.Value = Key end;

                if not List.Multi then break end;
            end;
        end;

        List:BuildList();

        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        List.Field, List.Cells = ListOuter, Cells;

        Options[Idx] = List;

        Library:ApplyCommon(List, Info, {
            Groupbox = Groupbox, Mark = Mark, Text = ListLabel, Hover = ListOuter, Dim = { ListLabel };
        });

        return List;
    end;

    function Funcs:AddDependencyBox()
        local Depbox = {
            Dependencies = {};
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, 0);
            Visible = false;
            Parent = Container;
        });

        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Visible = true;
            Parent = Holder;
        });

        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Frame;
        });

        function Depbox:Resize()
            Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y);
            Groupbox:Resize();
        end;

        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Depbox:Resize();
        end);

        Holder:GetPropertyChangedSignal('Visible'):Connect(function()
            Depbox:Resize();
        end);

        local function DependencyMet(Dependency)
            if type(Dependency) == 'function' then
                local Ok, Met = pcall(Dependency);

                return Ok and Met and true or false;
            end;

            local Elem = Dependency[1];
            local Value = Dependency[2];

            if Elem.Type == 'Toggle' then
                return Elem.Value == Value;
            end;

            if Elem.Type == 'Dropdown' and not Elem.Multi then
                if type(Value) == 'table' then
                    return table.find(Value, Elem.Value) ~= nil;
                end;
                return Elem.Value == Value;
            end;

            return true;
        end;

        function Depbox:Update()

            local Any = Depbox.Dependencies.Any == true;
            local Met = not Any;

            for _, Dependency in ipairs(Depbox.Dependencies) do
                if Any then
                    if DependencyMet(Dependency) then
                        Met = true;
                        break;
                    end;
                elseif not DependencyMet(Dependency) then
                    Met = false;
                    break;
                end;
            end;

            if Met then
                Frame.Parent = Holder;
            else
                Library:Detach(Frame);
            end;
            Holder.Visible = Met;
            Depbox:Resize();
        end;

        function Depbox:SetupDependencies(Dependencies)

            for _, Dependency in ipairs(Dependencies) do
                if type(Dependency) ~= 'function' then
                    assert(type(Dependency) == 'table', '[lib] a dependency has to be a { element, value } table or a function');
                    assert(Dependency[1], '[lib] a dependency is missing its element (first item)');
                    assert(Dependency[2] ~= nil, '[lib] a dependency is missing its value (second item)');
                end;
            end;

            Depbox.Dependencies = Dependencies;
            Depbox:Update();
        end;

        Depbox.Container = Frame;
        Depbox.Holder = Holder;
        Depbox.Top = Groupbox.Top or Groupbox;

        setmetatable(Depbox, BaseGroupbox);

        table.insert(Library.DependencyBoxes, Depbox);

        Library:DestroyWith(Holder, Frame, function()
            local At = table.find(Library.DependencyBoxes, Depbox);

            if At then table.remove(Library.DependencyBoxes, At) end;
        end);

        return Depbox;
    end;

    BaseGroupbox.__index = Funcs;
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...);
    end;
end;

do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 100;
        Parent = Library.Root;
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.NotificationArea;
    });

    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = Library.Root;
    });

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });

    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor';
    });

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    });

    Library:Round(InnerFrame, 3);

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor));
            ColorSequenceKeypoint.new(1, Library.MainColor);
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor));
                ColorSequenceKeypoint.new(1, Library.MainColor);
            });
        end;
    });

    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.fromOffset(8, 0);
        Size = UDim2.new(1, -16, 1, 0);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    });

    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = WatermarkLabel;
    Library:MakeDraggable(Library.Watermark);

    function Library:SizeWatermark()
        local Bounds = WatermarkLabel.TextBounds / Library.Scale.Scale;

        WatermarkOuter.Size = UDim2.fromOffset(math.ceil(Bounds.X) + 18, math.ceil(Bounds.Y * 1.5) + 3);
    end;

    WatermarkLabel:GetPropertyChangedSignal('TextBounds'):Connect(Library.SizeWatermark);

    local KeybindOuter = Library:Create('Frame', {
        Active = true;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.fromOffset(100, 20);
        Visible = false;
        ZIndex = 100;
        Parent = Library.Root;
    });

    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BackgroundTransparency = 1;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        ZIndex = 101;
        Parent = KeybindOuter;
    });

    local KeybindStroke = Library:Create('UIStroke', { Parent = KeybindInner });

    Library:Round(KeybindInner, 4);
    Library.Outlines[KeybindStroke] = { Gradient = Library:Create('UIGradient', { Enabled = false; Parent = KeybindStroke }), Frame = KeybindInner };
    KeybindStroke.Destroying:Once(function() Library.Outlines[KeybindStroke] = nil end);

    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local KeybindBar = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(0, 3, 1, 0);
        ZIndex = 102;
        Parent = KeybindInner;
    });

    Library:AddToRegistry(KeybindBar, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        ZIndex = 1;
        Parent = KeybindInner;
    });

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    });

    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5);
        Parent = KeybindContainer;
    });

    Library.KeybindFrame = KeybindOuter;
    Library.KeybindContainer = KeybindContainer;
    Library.Keybind = { Outer = KeybindOuter, Inner = KeybindInner, Bar = KeybindBar, Container = KeybindContainer, Stroke = KeybindStroke };

    KeybindOuter.InputBegan:Connect(function(Input)
        if not Library:IsPress(Input) or Library:Covered(Input, KeybindOuter) then return end;

        Library._kbMoved = false;

        local Intent = Input.UserInputType == Enum.UserInputType.Touch and Library:Gesture(Input) or 'Sideways';

        if Intent ~= 'Sideways' and Intent ~= 'Scroll' then return end;

        if Input.UserInputState == Enum.UserInputState.End or Input.UserInputState == Enum.UserInputState.Cancel then return end;

        local Start = Library:ToLocal(Library:MousePos(Input));
        local Origin = Vector2.new(KeybindOuter.Position.X.Offset, KeybindOuter.Position.Y.Offset);

        Library:Drag(Input, function(Pos)
            local Delta = Library:ToLocal(Pos) - Start;

            if Delta.Magnitude > 4 then Library._kbMoved = true end;

            Library:MoveKeybindList(Origin.X + Delta.X, Origin.Y + Delta.Y);
        end);
    end);
end;

function Library:MoveKeybindList(X, Y)
    local Outer = Library.KeybindFrame;
    local View = Library:Viewport() / Library.Scale.Scale;
    local Size = Vector2.new(Outer.Size.X.Offset, Outer.Size.Y.Offset);

    X = math.clamp(X, 0, math.max(View.X - Size.X, 0));
    Y = math.clamp(Y, 0, math.max(View.Y - Size.Y, 0));
    Outer.Position = UDim2.fromOffset(X, Y);

    local Right = X + Size.X / 2 > View.X / 2;

    if Right ~= Library.KeybindRight then
        Library.KeybindRight = Right;
        Library:UpdateKeybindList(true);
    end;
end;

function Library:SnapKeybindList(Right)
    local Outer = Library.KeybindFrame;
    local View = Library:Viewport() / Library.Scale.Scale;
    local Width, Height = Outer.Size.X.Offset, Outer.Size.Y.Offset;

    local Y = Library._kbPlaced and Outer.Position.Y.Offset or (View.Y - Height) / 2;

    Library._kbPlaced = true;
    Library:MoveKeybindList(Right and View.X - Width or 0, Y);
end;

function Library:SizeKeybindFrame()
    local Outer = Library.KeybindFrame;
    local Width, Height = 0, 0;

    for _, Label in next, Library.KeybindContainer:GetChildren() do
        if Label:IsA('TextLabel') then
            Label.TextXAlignment = Library.KeybindRight and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left;

            if Label.Visible then
                Height = Height + 18;
                Width = math.max(Width, Label.TextBounds.X);
            end;
        end;
    end;

    local Old = Outer.Size.X.Offset;

    Library.Keybind.Inner.Visible = Height > 0;
    Outer.Active = Height > 0;
    Outer.Size = UDim2.fromOffset(Width + 18, Height + 6);

    if Library._kbPlaced then
        Library:MoveKeybindList(Outer.Position.X.Offset + (Library.KeybindRight and Old - Outer.Size.X.Offset or 0), Outer.Position.Y.Offset);
    end;
end;

function Library:UpdateKeybindList(NoSize)
    local K = Library.Keybind;
    local Right = Library.KeybindRight;
    local Show = Library.KeybindShow;
    local Bar = Show.Bar and 3 or 0;

    K.Inner.BackgroundTransparency = 1 - Library.KeybindOpacity;
    K.Stroke.Enabled = Show.Border;

    if Show.Border then Library:StyleBorder(K.Stroke, Library.Outlines[K.Stroke].Gradient) end;

    for _, Label in next, Library.KeybindContainer:GetChildren() do
        if Label:IsA('TextLabel') then Label.TextXAlignment = Right and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left end;
    end;

    K.Bar.Visible = Show.Bar;
    K.Bar.AnchorPoint = Vector2.new(Right and 1 or 0, 0);
    K.Bar.Position = UDim2.fromScale(Right and 1 or 0, 0);
    K.Container.Position = UDim2.fromOffset(Right and 0 or Bar, 3);
    K.Container.Size = UDim2.new(1, -Bar, 1, -6);
    K.Container:FindFirstChildOfClass('UIPadding').PaddingRight = UDim.new(0, Right and 5 or 0);

    if not NoSize then Library:SizeKeybindFrame() end;
end;

function Library:SetKeybindFilter(Value)
    Library.KeybindFilter = type(Value) == 'table' and table.clone(Value) or {};
    Library:RefreshKeybindFrame();
end;

function Library:SetKeybindShow(Value)
    Value = type(Value) == 'table' and Value or {};
    Library.KeybindShow = { Bar = Value.Bar == true; Type = Value.Type == true; Border = Value.Border == true };
    Library:UpdateKeybindList();
    Library:RefreshKeybindFrame();
end;

function Library:SetKeybindOpacity(Value)
    Library.KeybindOpacity = math.clamp(Value, 0, 1);
    Library:UpdateKeybindList();
end;

Library.KeybindRight = Library.NotifySide == 'Right';
Library:UpdateKeybindList();
Library:SnapKeybindList(Library.KeybindRight);

Library._born = os.clock();
Library._fps = 0;

Library.WatermarkParts = {
    { Key = 'Script', Label = 'Script name',
        Get = function() return Library.WatermarkString or '' end },
    { Key = 'User', Label = 'Username',
        Get = function() local Player = Svc.Players.LocalPlayer; return Player and Player.Name or '' end },
    { Key = 'Fps', Label = 'FPS',
        Get = function() return Library._fps > 0 and ('%d fps'):format(Library._fps) or '-- fps' end },
    { Key = 'Ping', Label = 'Ping',
        Get = function()
            local Ok, Ms = pcall(function() return Svc.Stats.Network.ServerStatsItem['Data Ping']:GetValue() end);

            return Ok and type(Ms) == 'number' and ('%d ms'):format(math.floor(Ms + 0.5)) or '-- ms';
        end },
    { Key = 'Session', Label = 'Session time',
        Get = function()
            local Seconds = math.floor(os.clock() - Library._born);

            return ('%d:%02d:%02d'):format(Seconds // 3600, Seconds % 3600 // 60, Seconds % 60);
        end },
    { Key = 'Time', Label = 'Clock (24h)',
        Get = function() return os.date('%H:%M') end },
    { Key = 'Time12', Label = 'Clock (12h)',
        Get = function() return (os.date('%I:%M %p'):gsub('^0', '')) end },
    { Key = 'Players', Label = 'Players',
        Get = function() return ('%d/%d players'):format(#Svc.Players:GetPlayers(), Svc.Players.MaxPlayers) end },
    { Key = 'Game', Label = 'Game name',
        Get = function()
            if not Library._gameName then
                Library._gameName = game.Name;

                task.spawn(function()
                    local Ok, Info = pcall(function() return Svc.MarketplaceService:GetProductInfo(game.PlaceId) end);

                    if Ok and type(Info) == 'table' and type(Info.Name) == 'string' then Library._gameName = Info.Name end;
                end);
            end;

            return Library._gameName;
        end },
};

Library.WatermarkItems = { Script = true; User = false; Fps = true; Ping = true; Session = false; Time = false; Time12 = false; Players = false; Game = false };

function Library:UpdateWatermark()
    local Parts = {};

    for _, Part in ipairs(Library.WatermarkParts) do
        local Text = Library.WatermarkItems[Part.Key] and Part.Get();

        if Text and Text ~= '' then table.insert(Parts, Text) end;
    end;

    Library.WatermarkText.Text = table.concat(Parts, ' | ');
end;

function Library:RefreshWatermark()
    Library:UpdateWatermark();

    local Live = false;

    for Key, On in next, Library.WatermarkItems do Live = Live or (On and Key ~= 'Script') end;

    if not (Library.Watermark.Visible and Live) then
        Library:UnbindRender('Watermark');
        return;
    end;

    local Frames, Elapsed = 0, 0;

    Library:BindRender('Watermark', function(Delta)
        Frames += 1;
        Elapsed += Delta;

        if Elapsed >= 0.5 then
            Library._fps = math.floor(Frames / Elapsed + 0.5);
            Frames, Elapsed = 0, 0;
            Library:UpdateWatermark();
        end;
    end);
end;

function Library:SetWatermarkItem(Key, On)
    if Library.WatermarkItems[Key] == nil then return end;

    Library.WatermarkItems[Key] = not not On;

    local Dropdown = Options.UI_Watermark;

    if Dropdown then
        for _, Part in ipairs(Library.WatermarkParts) do
            if Part.Key == Key and (Dropdown.Value[Part.Label] == true) ~= Library.WatermarkItems[Key] then
                local Map = table.clone(Dropdown.Value);

                Map[Part.Label] = Library.WatermarkItems[Key] or nil;
                Dropdown:SetValue(Map);
            end;
        end;
    end;

    Library:RefreshWatermark();
end;

function Library:SetWatermarkItems(Map)
    for _, Part in ipairs(Library.WatermarkParts) do
        Library.WatermarkItems[Part.Key] = Map[Part.Label] == true;
    end;

    Library:RefreshWatermark();
end;

function Library:SetWatermarkVisibility(Bool)
    Library.Watermark.Visible = Bool;
    Library:RefreshWatermark();
end;

function Library:SetWatermark(Text)
    Library.WatermarkString = Text;
    Library:SetWatermarkVisibility(true);
end;

function Library:SetNotifySide(Side)
    Library.NotifySide = Side == 'Right' and 'Right' or 'Left';

    local Right = Library.NotifySide == 'Right';
    local Area = Library.NotificationArea;

    Area.AnchorPoint = Vector2.new(Right and 1 or 0, 0);
    Area.Position = UDim2.new(Right and 1 or 0, 0, 0, 40);
    Area.UIListLayout.HorizontalAlignment = Right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left;

    Library:SnapKeybindList(Right);
end;

function Library:Notify(Info, Time)
    if Library.Unloaded then return end;

    if type(Info) ~= 'table' then
        Info = { Description = tostring(Info), Time = Time };
    end;

    local Title, Desc = Info.Title, Info.Description or Info.Text or '';
    local Duration = Info.Time or 5;
    local Right = Library.NotifySide == 'Right';

    local TW, TH = 0, 0;
    if Title then
        TW, TH = Library:GetTextBounds(Title, 14);
    end;

    local DW, DH = Library:GetTextBounds(Desc, 14, Vector2.new(280, math.huge));
    local W = math.min(math.max(TW, DW), 280) + 16;
    local H = (Title and TH + 2 or 0) + DH + 11;

    local Outer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.fromOffset(0, H);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });

    local Inner = Library:Create('Frame', {
        Active = true;
        AnchorPoint = Vector2.new(Right and 1 or 0, 0);
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.fromScale(Right and 1 or 0, 0);
        Size = UDim2.fromOffset(W, H);
        ZIndex = 101;
        Parent = Outer;
    });

    Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

    local Gap = Library.RoundEdges and 3 or 0;

    local Bar = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(0, Gap);
        Size = UDim2.new(0, 2, 1, -2 * Gap);
        ZIndex = 103;
        Parent = Inner;
    });

    Library:Round(Bar, 1);
    Library:AddToRegistry(Bar, { BackgroundColor3 = 'AccentColor' });

    local Y = 3;
    if Title then
        local TitleLabel = Library:CreateLabel({
            Position = UDim2.fromOffset(8, Y);
            Size = UDim2.fromOffset(W - 12, TH);
            Text = Title;
            TextColor3 = Library.AccentColor;
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 103;
            Parent = Inner;
        });

        Library.Registry[TitleLabel].TextColor3 = 'AccentColor';
        Y = Y + TH + 2;
    end;

    Library:CreateLabel({
        Position = UDim2.fromOffset(8, Y);
        Size = UDim2.fromOffset(W - 12, DH);
        Text = Desc;
        TextSize = 14;
        TextWrapped = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Top;
        ZIndex = 103;
        Parent = Inner;
    });

    local Progress;
    if Library.Effects.Animations then
        Progress = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            AnchorPoint = Vector2.new(0, 1);
            Position = UDim2.new(0, Gap, 1, 0);
            Size = UDim2.new(1, -2 * Gap, 0, 2);
            ZIndex = 104;
            Parent = Inner;
        });

        Library:Round(Progress, 1);
        Library:AddToRegistry(Progress, { BackgroundColor3 = 'AccentColor' });
        Library:Tween(Progress, { Size = UDim2.new(0, 0, 0, 2) }, Duration, Enum.EasingStyle.Linear);
    end;

    Library:Tween(Outer, { Size = UDim2.fromOffset(W, H) }, 0.3);

    task.delay(Duration, function()
        if not Outer.Parent then return end;

        Library:Tween(Outer, { Size = UDim2.fromOffset(0, H) }, 0.3);
        task.delay(Library.Effects.Animations and 0.3 or 0, function() Outer:Destroy() end);
    end);
end;

function Library:Dialog(Info)
    if Library.Unloaded then return end;

    Library:ClosePopups();

    local Blocker = Library:Create('TextButton', {
        AutoButtonColor = false;
        BackgroundColor3 = Color3.new(0, 0, 0);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        Text = '';
        ZIndex = 300;
        Parent = Library.Root;
    });

    local _, DH = Library:GetTextBounds(Info.Description or '', 14, Vector2.new(260, math.huge));
    local Box = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.fromOffset(284, 24 + DH + 14 + 24 + 12);
        ZIndex = 301;
        Parent = Blocker;
    });

    Library:AddToRegistry(Box, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'AccentColor' });

    Library:CreateLabel({
        Position = UDim2.fromOffset(12, 6);
        Size = UDim2.new(1, -24, 0, 16);
        Text = Info.Title or '';
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 302;
        Parent = Box;
    });

    Library:CreateLabel({
        Position = UDim2.fromOffset(12, 28);
        Size = UDim2.fromOffset(260, DH);
        Text = Info.Description or '';
        TextSize = 14;
        TextWrapped = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Top;
        ZIndex = 302;
        Parent = Box;
    });

    local Dialog = {};

    function Dialog:Close()
        Blocker:Destroy();
    end;

    local Buttons = Info.Buttons or { { Text = 'OK' } };
    local BW = (260 - (#Buttons - 1) * 6) / #Buttons;

    for Idx, Data in ipairs(Buttons) do
        local Button = Library:Create('TextButton', {
            AutoButtonColor = false;
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Position = UDim2.new(0, 12 + (Idx - 1) * (BW + 6), 1, -34);
            Size = UDim2.fromOffset(BW, 24);
            Text = '';
            ZIndex = 302;
            Parent = Box;
        });

        Library:AddToRegistry(Button, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

        local Label = Library:CreateLabel({
            Size = UDim2.fromScale(1, 1);
            Text = Data.Text or 'OK';
            TextSize = 14;
            ZIndex = 303;
            Parent = Button;
        });

        if Data.Risky then
            Label.TextColor3 = Library.RiskColor;
            Library.Registry[Label].TextColor3 = 'RiskColor';
        end;

        Library:OnHighlight(Button, Button, { BorderColor3 = 'AccentColor' }, { BorderColor3 = 'OutlineColor' });

        Button.MouseButton1Click:Connect(function()
            Dialog:Close();
            Library:SafeCallback(Data.Callback);
        end);
    end;

    return Dialog;
end;

function Library:SetDPIScale(Percent)
    local Scale = math.clamp((Percent or 100) / 100, 0.5, 2);

    local Old = Library.Scale.Scale;

    Library:ClosePopups();
    Library.Scale.Scale = Scale;
    Library.Root.Size = UDim2.fromScale(1 / Scale, 1 / Scale);

    if Library.Window and Library.Window.Outer then Library.Window:Rescale(Old) end;

    if Library.SizeWatermark then Library:SizeWatermark() end;
end;

function Library:SetBorderStyle(Style)
    if Style ~= 'None' and Style ~= 'Static' and Style ~= 'Animated' then return end;

    Library.BorderStyle = Style;

    if Options.UI_BorderStyle and Options.UI_BorderStyle.Value ~= Style then
        Options.UI_BorderStyle:SetValue(Style);
    end;

    if Library.Window then Library.Window:UpdateGradient() end;
end;

function Library:SetRoundEdges(On)
    Library.RoundEdges = not not On;

    for Corner, Radius in next, Library.Corners do
        Corner.CornerRadius = UDim.new(0, Library.RoundEdges and Radius or 0);
    end;

    for Inst, Link in next, Library.Bordered do
        if Link.Wrapper then Library:SyncWrapper(Inst) end;
    end;

    Library:ApplyStyle();
end;

function Library:SetEffect(Name, Value)
    Value = not not Value;
    Library.Effects[Name] = Value;

    local Toggle = Toggles['UI_Fx_' .. Name];
    if Toggle and Toggle.Value ~= Value then
        Toggle:SetValue(Value);
    end;

    if (Name == 'SliderLerp' or Name == 'Animations') and next(Library._lerps) then
        LerpStep(0);
    end;

    local Window = Library.Window;
    if Window then
        if Name == 'Shadow' then
            Window.Shadow.Visible = Value;
        elseif Name == 'Blur' then
            Library:UpdateBlur();
        elseif Name == 'UIBlur' then
            Library:UpdateUIBlur();
        elseif Name == 'Glow' then
            Window:UpdateGlow();
        end;
    end;
end;

function Library:EnsureFolder(Path)
    if not (X.isfolder and X.makefolder) then return false end;

    local Current = '';
    for Part in Path:gmatch('[^/\\]+') do
        Current = Current == '' and Part or (Current .. '/' .. Part);

        if not X.isfolder(Current) then
            if not pcall(X.makefolder, Current) then return false end;
        end;
    end;

    return true;
end;

function Library:GetAsset(Url)
    if type(Url) ~= 'string' or Url == '' then return end;
    if not Url:find('^https?://') or Url:find('roblox%.com/asset') then
        if Url:find('^https?://') then return Url end;
        return Url:find('^rbx') and Url or Url:match('^%d+$') and ('rbxassetid://' .. Url) or nil;
    end;

    Library.AssetCache = Library.AssetCache or {};
    if Library.AssetCache[Url] then return Library.AssetCache[Url] end;

    if not (X.request and X.writefile and X.isfile and X.getcustomasset) then return end;

    local Folder = (Library.AssetFolder or 'UILib') .. '/assets';
    local Path = Folder .. '/' .. (Url:match('([^/?]+)$') or 'asset'):gsub('[^%w%._%-]', '');

    if not X.isfile(Path) then
        local Ok, Res = pcall(X.request, { Url = Url, Method = 'GET' });
        if not (Ok and Res and Res.StatusCode == 200) then
            warn(("[lib] couldn't download '%s' (%s)"):format(Url, Ok and Res and tostring(Res.StatusCode) or 'request failed'));
            return;
        end;

        Library:EnsureFolder(Folder);
        if not pcall(X.writefile, Path, Res.Body) then
            warn(("[lib] couldn't cache '%s' on disk"):format(Path));
            return;
        end;
    end;

    local Ok, Asset = pcall(X.getcustomasset, Path);
    Library.AssetCache[Url] = Ok and Asset or nil;

    return Library.AssetCache[Url];
end;

Library.FS = { Mem = {} };

function Library.FS:Real()
    return X.isfile and X.readfile and X.writefile and X.isfolder and X.makefolder and X.listfiles and true or false;
end;

function Library.FS:Warn()
    if not self.Warned and not self:Real() then
        self.Warned = true;
        Library:Notify('[lib] your executor has no file api, so configs only live in memory until you leave', 5);
    end;
end;

function Library.FS:Exists(Path)
    if self:Real() then return X.isfile(Path) end;
    return self.Mem[Path] ~= nil;
end;

function Library.FS:Read(Path)
    if self:Real() then
        local Ok, Data = pcall(X.readfile, Path);
        return Ok and Data or nil;
    end;

    return self.Mem[Path];
end;

function Library.FS:Write(Path, Data)
    if not self:Real() then
        self:Warn();
        self.Mem[Path] = Data;
        return true;
    end;

    Library:EnsureFolder(Path:match('^(.*)[/\\][^/\\]+$') or '');

    local Ok, Err = pcall(X.writefile, Path, Data);
    if not Ok then return false, ("[lib] couldn't write '%s': %s"):format(Path, tostring(Err)) end;

    return true;
end;

function Library.FS:Delete(Path)
    if self:Real() and X.delfile then
        return pcall(X.delfile, Path);
    end;

    self.Mem[Path] = nil;
    return true;
end;

function Library.FS:List(Dir, Ext)
    local Out, Seen = {}, {};

    if self:Real() then
        if not X.isfolder(Dir) then return Out end;

        local Ok, Files = pcall(X.listfiles, Dir);
        for _, File in ipairs(Ok and Files or {}) do
            local Name = File:match('([^/\\]+)%.' .. Ext .. '$');
            if Name then table.insert(Out, Name) end;
        end;
    else
        for Path in next, self.Mem do
            local Name = Path:match('^' .. Dir:gsub('%p', '%%%0') .. '/([^/]+)%.' .. Ext .. '$');
            if Name and not Seen[Name] then Seen[Name] = true; table.insert(Out, Name) end;
        end;
    end;

    table.sort(Out);
    return Out;
end;

function Library:SanitizeName(Name)
    Name = tostring(Name or ''):gsub('[/\\:%*%?"<>|%c]', ''):gsub('^%s+', ''):gsub('%s+$', '');

    if Name == '' or Name:match('^%.+$') then
        return nil, '[lib] that name is empty or has no valid characters';
    end;

    return Name;
end;

Library.UIIndexes = { 'UI_Layout', 'UI_DPI', 'UI_NotifySide', 'UI_KeybindList', 'UI_KeybindOpacity', 'UI_KeybindFilter', 'UI_KeybindShow', 'UI_ESPPreview', 'UI_MenuKeybind', 'UI_RoundEdges', 'UI_BorderStyle', 'UI_BorderSpeed', 'UI_BorderTheme', 'UI_BorderColor', 'UI_BorderBase', 'UI_GlowSize', 'UI_GlowColor', 'UI_GlowTheme';
    'UI_Style', 'UI_GlassIntensity', 'UI_BlurSize', 'UI_UIBlurAmount', 'UI_UIBlurTint', 'UI_Offscreen', 'UI_BgSource', 'UI_BgTransparency', 'UI_BgDim' };

Library.UITransient = { 'UI_BgFile' };

local EffectLabels = {
    Animations = 'Animations'; MenuFade = 'Menu fade'; Shadow = 'Window shadow';
    SliderLerp = 'Slider lerp'; DragLerp = 'Drag lerp'; Glow = 'Window glow'; Blur = 'Camera blur'; UIBlur = 'Blur';
};

for Name in next, EffectLabels do
    table.insert(Library.UIIndexes, 'UI_Fx_' .. Name);
end;

table.insert(Library.UIIndexes, 'UI_Watermark');

function Library:UpdateBlur()
    local On = Library.Effects.Blur and Library.MenuOpen;

    if On and not Library._blur then
        Library._blur = Library:Create('BlurEffect', { Size = Library.BlurSize; Parent = workspace.CurrentCamera });
    elseif not On and Library._blur then
        Library._blur:Destroy();
        Library._blur = nil;
    end;
end;

function Library:SetUIBlurAmount(Value)
    Library.UIBlurAmount = math.clamp(Value, 0, 1);
    Library:UpdateUIBlur();
end;

local BlurRows = 4;

function Library:UpdateUIBlur()
    local Window = Library.Window;

    if not Window then return end;

    local On = Library.Effects.UIBlur and Library.Style == 'Glass';
    local Name = Library.UIBlurTints[Library.UIBlurTint];
    local Amount = Library.UIBlurAmount;
    local Rig = Library._glass;

    Library.Registry[Window.Tint].BackgroundColor3 = Name;
    Window.Tint.BackgroundColor3 = Library[Name];
    Window.Tint.BackgroundTransparency = 1 - Amount * (Library.UIBlurTint == 'Main' and 0.55 or 0.16);
    Window.Tint.Visible = On;

    if not (On and Library.MenuOpen and Amount > 0) then
        if Rig then
            Library:UnbindRender('GlassBlur');
            Rig.Folder:Destroy();
            Rig.Dof:Destroy();
            Library._glass = nil;
        end;

        return;
    end;

    if not Rig then
        local Folder = Library:Create('Folder', { Name = 'Glass'; Parent = workspace.CurrentCamera });
        local Panes = {};

        for Index = 1, 2 * BlurRows + 1 do
            Panes[Index] = Library:Create('Part', {
                Name = 'Pane'; Material = Enum.Material.Glass; Color = Color3.new(0, 0, 0); Transparency = Index == BlurRows + 1 and 0.98 or 1;
                Anchored = true; CanCollide = false; CanQuery = false; CanTouch = false; CastShadow = false; Locked = true;
                Size = Vector3.new(1, 1, 0.001); Parent = Folder;
            });
        end;

        Rig = {
            Folder = Folder; Panes = Panes; Pane = Panes[BlurRows + 1]; Dist = 0.02; Bleed = 0.013;
            Dof = Library:Create('DepthOfFieldEffect', { Name = 'GlassDof'; FarIntensity = 0; FocusDistance = 0.05; InFocusRadius = 50; Parent = workspace.CurrentCamera });
        };
        Library._glass = Rig;

        Library:BindRender('GlassBlur', function()
            local Camera, Canvas = workspace.CurrentCamera, Library.Window and Library.Window.Canvas;

            if not (Camera and Canvas) then return end;

            if Folder.Parent ~= Camera then Folder.Parent = Camera; Rig.Dof.Parent = Camera end;

            local Look = Camera.CFrame;
            local Bleed = Camera.ViewportSize.Y * Rig.Bleed;
            local Pos, Size = Canvas.AbsolutePosition + Vector2.one * Bleed, Canvas.AbsoluteSize - Vector2.one * 2 * Bleed;
            local Corner = Canvas:FindFirstChildOfClass('UICorner');
            local Radius = math.min(math.max((Corner and Corner.CornerRadius.Offset * Library.Scale.Scale or 0) - Bleed, 0), Size.X / 2, Size.Y / 2);
            local Key = Rig.Key;

            if Key and Key[1] == Look and Key[2] == Pos and Key[3] == Size and Key[4] == Radius then return end;

            Rig.Key = { Look, Pos, Size, Radius };

            local function Plane(Point)
                local Ray = Camera:ScreenPointToRay(Point.X, Point.Y);

                return Ray.Origin + Ray.Direction * (Rig.Dist / Ray.Direction:Dot(Look.LookVector));
            end;

            local From, To = Plane(Pos), Plane(Pos + Size);
            local Delta = To - From;
            local Across, Down = Delta:Dot(Look.RightVector), -Delta:Dot(Look.UpVector);

            local function Place(Pane, X, Y, Width, Height)
                local Center = From + Look.RightVector * (Across * (X + Width / 2) / Size.X) - Look.UpVector * (Down * (Y + Height / 2) / Size.Y);

                Pane.Size = Vector3.new(Across * Width / Size.X, Down * Height / Size.Y, 0.001);
                Pane.CFrame = CFrame.new(Center) * Look.Rotation;
            end;

            local Rounded = Radius > 0;

            Place(Panes[BlurRows + 1], 0, Radius, Size.X, Size.Y - 2 * Radius);

            for Row = 1, BlurRows do
                local Top, Step = (Row - 1) * Radius / BlurRows, Radius / BlurRows;

                local Inset = Radius - math.sqrt(Radius * Radius - (Radius - Top) ^ 2);

                for _, Pane in ipairs({ Panes[Row], Panes[BlurRows + 1 + Row] }) do
                    local Shown = Pane.Transparency < 1;

                    if Shown ~= Rounded then Pane.Transparency = Rounded and 0.98 or 1 end;
                end;

                if Rounded then
                    Place(Panes[Row], Inset, Top, Size.X - 2 * Inset, Step);
                    Place(Panes[BlurRows + 1 + Row], Inset, Size.Y - Top - Step, Size.X - 2 * Inset, Step);
                end;
            end;

        end);
    end;

    Rig.Dof.NearIntensity = Amount;
end;

function Library:SetUIBlurTint(Name)
    if not Library.UIBlurTints[Name] then return end;

    Library.UIBlurTint = Name;
    Library:UpdateUIBlur();
end;

function Library:SetBlurSize(Value)
    Library.BlurSize = math.clamp(Value, 0, 56);

    if Library._blur then Library._blur.Size = Library.BlurSize end;
end;

Library.BackgroundFolder = 'awp_backgrounds';

function Library:ListBackgrounds()
    local Dir = Library.BackgroundFolder;
    local List = {};

    if not (X.isfolder and X.listfiles) then return List end;

    Library:EnsureFolder(Dir);

    local Ok, Files = pcall(X.listfiles, Dir);

    for _, File in ipairs(Ok and Files or {}) do
        local Name = File:match('([^/\\]+)$');
        local Lower = Name and Name:lower();

        if Lower and (Lower:match('%.png$') or Lower:match('%.jpe?g$')) then table.insert(List, Name) end;
    end;

    table.sort(List);
    return List;
end;

function Library:ResolveBackground(Source)
    if Source:match('^%d+$') then
        return 'rbxassetid://' .. Source;
    end;

    if Source:match('^https?://') then
        local Asset = Library:GetAsset(Source);

        return Asset, not Asset and "[lib] couldn't load the image from that url" or nil;
    end;

    local Lower = Source:lower();

    if Source:find('[/\\]') or not (Lower:match('%.png$') or Lower:match('%.jpe?g$')) then
        return nil, '[lib] a background has to be an asset id, an image url, or a png/jpg/jpeg in the backgrounds folder';
    end;

    local Path = Library.BackgroundFolder .. '/' .. Source;

    if not (X.getcustomasset and Library.FS:Exists(Path)) then
        return nil, ("[lib] couldn't find '%s' in the backgrounds folder"):format(Source);
    end;

    local Ok, Asset = pcall(X.getcustomasset, Path);

    return Ok and Asset or nil, not Ok and ("[lib] couldn't read '%s'"):format(Source) or nil;
end;

function Library:UpdateBackground()
    local Window, Active = Library.Window, Library.BackgroundImageActive;

    if not Window then return end;

    Window.BgImage.Image = Active and Library.BackgroundAsset or '';
    Window.BgImage.ImageTransparency = Library.Background.Transparency;
    Window.BgImage.Visible = Active;
    Window.BgDim.BackgroundTransparency = 1 - Library.Background.Dim;
    Window.BgDim.Visible = Active;
end;

function Library:SetBackground(Source)
    Source = (Source or ''):match('^%s*(.-)%s*$');

    local Asset, Err;

    if Source ~= '' then
        Asset, Err = Library:ResolveBackground(Source);
    end;

    Library.BackgroundAsset = Asset;
    Library.BackgroundImageActive = Asset ~= nil;
    Library:UpdateBackground();
    Library:ApplyStyle();

    if Source ~= '' and not Asset then
        Library:Notify(Err, 5);
        return false, Err;
    end;

    return true;
end;

function Library:BuildUISettings(Target)
    local Count, Boxes = 0, {};

    local function Section(Name, Side)
        Count = Count + 1;

        if Target.AddLeftTabbox then
            local Key = Side == 'Right' and 'Right' or 'Left';

            Boxes[Key] = Boxes[Key] or (Key == 'Right' and Target:AddRightTabbox('Style') or Target:AddLeftTabbox('Interface'));

            return Boxes[Key]:AddTab(Name);
        end;

        if Count > 1 then Target:AddDivider() end;
        Target:AddLabel(Name);

        return Target;
    end;

    local Window = Section('Window');

    Window:AddDropdown('UI_Layout', {
        Text = 'Layout'; Values = { 'Horizontal', 'Vertical' };
        Default = Library.Window and Library.Window.Layout or 'Horizontal';
        Callback = function(Value)
            if Value and Library.Window then Library.Window:SetLayout(Value) end;
        end;
    });

    Window:AddButton({
        Text = 'Reset window size';
        Func = function() if Library.Window then Library.Window:ResetSize() end end;
    });

    Window:AddSlider('UI_DPI', {
        Text = 'DPI scale'; Min = 100; Max = 150; Default = math.clamp(math.floor(Library.Scale.Scale * 100 + 0.5), 100, 150); Rounding = 0; Suffix = '%'; OnRelease = true;
        Callback = function(Value) Library:SetDPIScale(Value) end;
    });

    Window:AddDropdown('UI_NotifySide', {
        Text = 'Notification side'; Values = { 'Left', 'Right' }; Default = Library.NotifySide;
        Callback = function(Value) if Value then Library:SetNotifySide(Value) end end;
    });

    Window:AddToggle('UI_Offscreen', {
        Text = 'Allow window off screen'; Default = Library.Offscreen;
        Callback = function(Value)
            Library.Offscreen = Value;
            if Library.Window then Library.Window:Clamp() end;
        end;
    });

    Window:AddToggle('UI_RoundEdges', {
        Text = 'Round edges'; Default = Library.RoundEdges;
        Callback = function(Value) Library:SetRoundEdges(Value) end;
    });

    Window:AddLabel({ Text = 'Menu keybind' })
        :AddKeyPicker('UI_MenuKeybind', { Default = 'RightShift'; NoUI = true; Text = 'Menu keybind'; Mode = 'Toggle' });
    Library.ToggleKeybind = Options.UI_MenuKeybind;

    local Look = Section('Style');

    Look:AddDropdown('UI_Style', {
        Text = 'Style'; Values = { 'Solid', 'Glass' }; Default = Library.Style;
        Callback = function(Value) if Value then Library:SetStyle(Value) end end;
    });

    local GlassBox = Look:AddDependencyBox();

    GlassBox:AddSlider('UI_GlassIntensity', {
        Text = 'Glass intensity'; Min = 0; Max = 100; Default = math.floor(Library.GlassIntensity * 100 + 0.5); Rounding = 0; Suffix = '%';
        Callback = function(Value) Library:SetGlassIntensity(Value / 100) end;
    });

    GlassBox:AddToggle('UI_Fx_UIBlur', {
        Text = 'Blur'; Default = Library.Effects.UIBlur;
        Callback = function(Value) Library:SetEffect('UIBlur', Value) end;
    });

    local BlurBox = GlassBox:AddDependencyBox();

    BlurBox:AddSlider('UI_UIBlurAmount', {
        Text = 'Blur amount'; Min = 0; Max = 100; Default = math.floor(Library.UIBlurAmount * 100 + 0.5); Rounding = 0; Suffix = '%';
        Callback = function(Value) Library:SetUIBlurAmount(Value / 100) end;
    });

    BlurBox:AddDropdown('UI_UIBlurTint', {
        Text = 'Blur tint'; Values = { 'Neutral', 'Main' }; Default = Library.UIBlurTint;
        Callback = function(Value) if Value then Library:SetUIBlurTint(Value) end end;
    });

    BlurBox:SetupDependencies({ { Toggles.UI_Fx_UIBlur, true } });

    GlassBox:SetupDependencies({ { Options.UI_Style, 'Glass' } });

    local Image = Section('Background');

    Image:AddInput('UI_BgSource', {
        Text = 'Image'; Default = ''; Placeholder = 'asset id, url or file name'; Finished = true;
        Callback = function(Value) Library:SetBackground(Value) end;
    });

    Image:AddDropdown('UI_BgFile', {
        Text = 'Backgrounds folder'; Values = Library:ListBackgrounds(); AllowNull = true; Searchable = true;
        Callback = function(Value) if Value then Options.UI_BgSource:SetValue(Value) end end;
    });

    Image:AddButton({ Text = 'Refresh', Func = function()
        Options.UI_BgFile:SetValues(Library:ListBackgrounds());
        Options.UI_BgFile:SetValue(nil);
    end }):AddButton({ Text = 'Clear', Func = function()
        Options.UI_BgSource:SetValue('');
        Options.UI_BgFile:SetValue(nil);
    end });

    Image:AddSlider('UI_BgTransparency', {
        Text = 'Image transparency'; Min = 0; Max = 100; Default = math.floor(Library.Background.Transparency * 100 + 0.5); Rounding = 0; Suffix = '%';
        Callback = function(Value) Library.Background.Transparency = Value / 100; Library:UpdateBackground() end;
    });

    Image:AddSlider('UI_BgDim', {
        Text = 'Dim'; Min = 0; Max = 100; Default = math.floor(Library.Background.Dim * 100 + 0.5); Rounding = 0; Suffix = '%';
        Callback = function(Value) Library.Background.Dim = Value / 100; Library:UpdateBackground() end;
    });

    local Border = Section('Border', 'Right');

    Border:AddDropdown('UI_BorderStyle', {
        Text = 'Window border'; Values = { 'None', 'Static', 'Animated' }; Default = Library.BorderStyle;
        Callback = function(Value) if Value then Library:SetBorderStyle(Value) end end;
    });

    local SpeedBox = Border:AddDependencyBox();

    SpeedBox:AddSlider('UI_BorderSpeed', {
        Text = 'Border speed'; Min = 10; Max = 400; Default = math.floor(Library.BorderSpeed * 100 + 0.5); Rounding = 0; Suffix = '%';
        Callback = function(Value) Library.BorderSpeed = Value / 100 end;
    });

    SpeedBox:SetupDependencies({ { Options.UI_BorderStyle, 'Animated' } });

    Border:AddToggle('UI_BorderTheme', {
        Text = 'Border uses theme colors'; Default = Library.BorderUseTheme;
        Callback = function(Value)
            Library.BorderUseTheme = Value;
            if Library.Window then Library.Window:UpdateGradient() end;
        end;
    });

    Border:AddLabel({ Text = 'Border color' }):AddColorPicker('UI_BorderColor', {
        Default = Library.BorderColor; Title = 'Border color'; Gradient = false;
        Callback = function(Value)
            Library.BorderColor = Value;
            Library.BorderTransparency = Options.UI_BorderColor.Transparency;
            if Library.Window then Library.Window:UpdateGradient() end;
        end;
    });

    Border:AddLabel({ Text = 'Border base color' }):AddColorPicker('UI_BorderBase', {
        Default = Library.BorderBase; Title = 'Border base color'; Gradient = false; Transparency = false;
        Callback = function(Value)
            Library.BorderBase = Value;
            if Library.Window then Library.Window:UpdateGradient() end;
        end;
    });

    local Effects = Section('Effects', 'Right');

    for _, Name in ipairs({ 'Animations', 'MenuFade', 'Shadow', 'SliderLerp', 'DragLerp' }) do
        Effects:AddToggle('UI_Fx_' .. Name, {
            Text = EffectLabels[Name]; Default = Library.Effects[Name];
            Callback = function(Value) Library:SetEffect(Name, Value) end;
        });
    end;

    Effects:AddToggle('UI_Fx_Glow', {
        Text = EffectLabels.Glow; Default = Library.Effects.Glow;
        Callback = function(Value) Library:SetEffect('Glow', Value) end;
    });

    local GlowBox = Effects:AddDependencyBox();

    GlowBox:AddSlider('UI_GlowSize', {
        Text = 'Glow size'; Min = 1; Max = 15; Default = Library.Glow.Size; Rounding = 0; Suffix = 'px';
        Callback = function(Value)
            Library.Glow.Size = Value;
            if Library.Window then Library.Window:UpdateGlow() end;
        end;
    });

    GlowBox:AddToggle('UI_GlowTheme', {
        Text = 'Glow uses accent color'; Default = Library.Glow.UseTheme;
        Callback = function(Value)
            Library.Glow.UseTheme = Value;
            if Library.Window then Library.Window:UpdateGlow() end;
        end;
    });

    GlowBox:AddLabel({ Text = 'Glow color' }):AddColorPicker('UI_GlowColor', {
        Default = Library.Glow.Color; Title = 'Glow color'; Transparency = Library.Glow.Transparency; Gradient = false;
        Callback = function(Value)
            Library.Glow.Color = Value;
            Library.Glow.Transparency = Options.UI_GlowColor.Transparency;
            if Library.Window then Library.Window:UpdateGlow() end;
        end;
    });

    GlowBox:SetupDependencies({ { Toggles.UI_Fx_Glow, true } });

    Effects:AddToggle('UI_Fx_Blur', {
        Text = EffectLabels.Blur; Default = Library.Effects.Blur;
        Callback = function(Value) Library:SetEffect('Blur', Value) end;
    });

    local CameraBox = Effects:AddDependencyBox();

    CameraBox:AddSlider('UI_BlurSize', {
        Text = 'Camera blur amount'; Min = 0; Max = 56; Default = Library.BlurSize; Rounding = 0;
        Callback = function(Value) Library:SetBlurSize(Value) end;
    });

    CameraBox:SetupDependencies({ { Toggles.UI_Fx_Blur, true } });

    local Hud = Section('HUD', 'Right');

    Hud:AddToggle('UI_KeybindList', {
        Text = 'Show keybind list'; Default = Library.KeybindFrame.Visible;
        Callback = function(Value) Library.KeybindFrame.Visible = Value end;
    });

    Hud:AddToggle('UI_ESPPreview', {
        Text = 'Show ESP preview'; Default = true;
        Callback = function(Value)
            for Preview in next, Library.ESPPreviews do
                if Preview.Shown ~= Value then Preview:SetVisible(Value) end;
            end;
        end;
    });

    Hud:AddSlider('UI_KeybindOpacity', {
        Text = 'Keybind list opacity'; Min = 0; Max = 100; Default = math.floor(Library.KeybindOpacity * 100 + 0.5); Rounding = 0; Suffix = '%';
        Callback = function(Value) Library:SetKeybindOpacity(Value / 100) end;
    });

    Hud:AddDropdown('UI_KeybindFilter', {
        Text = 'Filter'; Values = { 'Unbound keys', 'Hold keys', 'Toggle keys', 'Press keys' }; Default = {}; Multi = true; AllowNull = true;
        Callback = function(Value) Library:SetKeybindFilter(Value) end;
    });

    Hud:AddDropdown('UI_KeybindShow', {
        Text = 'Show'; Values = { 'Bar', 'Type', 'Border' }; Default = { 'Bar', 'Type' }; Multi = true; AllowNull = true;
        Callback = function(Value) Library:SetKeybindShow(Value) end;
    });

    local Labels, Shown = {}, {};

    for _, Part in ipairs(Library.WatermarkParts) do
        table.insert(Labels, Part.Label);

        if Library.WatermarkItems[Part.Key] then table.insert(Shown, Part.Label) end;
    end;

    Hud:AddDropdown('UI_Watermark', {
        Text = 'Watermark shows'; Values = Labels; Default = Shown; Multi = true; AllowNull = true;
        Callback = function(Value) Library:SetWatermarkItems(Value) end;
    });
end;

function Library:LoadFont(Name)
    if Library._fonts[Name] ~= nil then return Library._fonts[Name] or nil end;

    local Face;

    if Library.CustomFonts[Name] then
        Face = Library:LoadCustomFont(Name, Library.CustomFonts[Name]);
    else
        local Ok, Item = pcall(function() return Enum.Font[Name] end);
        Face = Ok and Item and Font.fromEnum(Item) or nil;
    end;

    Library._fonts[Name] = Face or false;

    return Face;
end;

function Library:LoadCustomFont(Name, Url)
    local Ttf = Library:GetAsset(Url);

    if not Ttf then return end;

    local Path = (Library.AssetFolder or 'UILib') .. '/assets/' .. Name .. '.json';
    local Family = Svc.HttpService:JSONEncode({ name = Name; faces = { { name = 'Regular'; weight = 400; style = 'normal'; assetId = Ttf } } });

    if not pcall(X.writefile, Path, Family) then return end;

    local Ok, Asset = pcall(X.getcustomasset, Path);
    local Face = Ok and Asset and Font.new(Asset) or nil;

    if Face then
        local Params = Instance.new('GetTextBoundsParams');
        Params.Text = 'a';
        Params.Font = Face;
        Params.Size = 14;
        pcall(Svc.TextService.GetTextBoundsAsync, Svc.TextService, Params);
    end;

    return Face;
end;

function Library:RefreshText()
    local Window = Library.Window;

    if Window then
        for _, Info in ipairs(Window.TabButtons) do
            Info.Width = Library:GetTextBounds(Info.Name, 16) + 12 + (Info.Icon and 20 or 0);
        end;

        Window:ApplyLayout();

        for _, Top in ipairs(Library.Tops) do
            if Top.Resize then Top:Resize() end;

            for _, Tab in next, Top.Tabs or {} do Tab:Resize() end;
        end;
    end;

    for _, Option in next, Options do
        if type(Option) == 'table' and Option.Type == 'KeyPicker' then
            Option:SetValue({ Option.Value, Option.Mode, Option.Modifiers });
        end;
    end;

    Library:UpdateWatermark();
end;

function Library:SetFont(Name)
    local Face = Library:LoadFont(Name);

    if not Face then
        warn(("[lib] the %s font isn't available, using Code instead"):format(Name));

        Name = 'Code';
        Face = Library:LoadFont(Name);
    end;

    Library.FontApplied = true;
    Library.FontName = Name;
    Library.FontFace = Face;

    table.clear(Library._textCache);
    Library._textCount = 0;
    Library:UpdateColorsUsingRegistry('FontFace');
    for Inst, Size in next, Library._sizes do Inst.TextSize = Library:PixelSize(Size) end;
    Library:RefreshText();

    for _, Fit in next, Library._fits do Fit() end;
end;

local WindowBase = {};
WindowBase.__index = WindowBase;

local TabBase = {};
TabBase.__index = TabBase;

local TabBarHeight = 24;

local function FadeProps(Desc)
    if Desc:IsA('ImageLabel') then
        return { 'ImageTransparency', 'BackgroundTransparency' };
    elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') or Desc:IsA('TextButton') then
        return { 'TextTransparency', 'TextStrokeTransparency', 'BackgroundTransparency' };
    elseif Desc:IsA('ScrollingFrame') then
        return { 'BackgroundTransparency', 'ScrollBarImageTransparency' };
    elseif Desc:IsA('Frame') then
        return { 'BackgroundTransparency' };
    elseif Desc:IsA('UIStroke') then
        return { 'Transparency' };
    end;
end;

function Library:CreateWindow(...)
    local Arguments = { ... };
    local Config = { AnchorPoint = Vector2.zero };

    if type(Arguments[1]) == 'table' then
        Config = Arguments[1];
    else
        Config.Title = Arguments[1];
        Config.AutoShow = Arguments[2] or false;
    end;

    if type(Config.Title) ~= 'string' then Config.Title = 'No title' end;
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 4 end;
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end;

    Library:UpdateMobile();
    if not Library.FontApplied then Library:SetFont(Library.FontName) end;

    Config.AnchorPoint = Config.AnchorPoint or Vector2.zero;
    Config.MinSize = Config.MinSize or Vector2.new(360, 300);

    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end;
    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 600) end;
    if typeof(Config.VerticalSize) ~= 'UDim2' then Config.VerticalSize = UDim2.fromOffset(700, 480) end;

    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5);
        Config.Position = UDim2.fromScale(0.5, 0.5);
    end;

    local Layout = (Config.Layout == 'Vertical' or (Library.IsMobile and Config.Layout == nil)) and 'Vertical' or 'Horizontal';

    local Window = setmetatable({
        Config = Config;
        Tabs = {};
        TabButtons = {};
        Layout = Layout;
        Sizes = { Horizontal = Config.Size, Vertical = Config.VerticalSize };
        SidebarWidth = 150;
        Fade = {};
    }, WindowBase);

    Library.Window = Window;

    if Library.IsMobile then
        if Library.ShowKeybindsOnMobile then Library.KeybindFrame.Visible = true end;
    end;

    if Library.IsMobile then Window:AutoScale() end;

    local View, Start = Library:Viewport() / Library.Scale.Scale, Window:FitSize(Window.Sizes[Layout]);
    local Left = Config.Position.X.Scale * View.X + Config.Position.X.Offset - Config.AnchorPoint.X * Start.X.Offset;
    local Top = Config.Position.Y.Scale * View.Y + Config.Position.Y.Offset - Config.AnchorPoint.Y * Start.Y.Offset;

    Config.AnchorPoint = Vector2.zero;

    local Outer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(math.floor(Left + 0.5), math.floor(Top + 0.5));
        Size = Start;
        Visible = false;
        ZIndex = 1;
        Parent = Library.Root;
    });

    Window.Outer = Outer;
    Window.Stroke = Library:Round(Outer, 8, 'OutlineColor');
    Window.StrokeGradient = Library:Create('UIGradient', { Enabled = false; Parent = Window.Stroke });

    local Grab = Library:MakeDraggable(Outer, function(Pos)
        return (Pos.Y - Outer.AbsolutePosition.Y) / Library.Scale.Scale <= 25 or Library.IsMobile and Library:IsMouseOverFrame(Window.TabBar, Pos);
    end, function() Window:Clamp() end);

    Library:GiveSignal(Svc.UserInputService.InputBegan:Connect(function(Input)
        if not Library:IsPress(Input) or Library.Window ~= Window or not Outer.Visible then return end;

        local Start = Library:MousePos(Input);

        if not Library:IsMouseOverFrame(Outer, Start) or Library:MouseIsOverOpenedFrame() then return end;

        for _, Child in ipairs(Library.Root:GetChildren()) do
            if Child ~= Outer and Child:IsA('GuiObject') and Child.Visible and Child.ZIndex > Outer.ZIndex
                and Child.BackgroundTransparency < 1 and Library:IsMouseOverFrame(Child, Start) then return end;
        end;

        local Page = Window.CurrentTab and Window.CurrentTab.Page;
        local CanScroll = Page and Library:IsMouseOverFrame(Page, Start) and Page.AbsoluteCanvasSize.Y > Page.AbsoluteWindowSize.Y + 1;

        if Library:OverScrollbar(Outer, Start) then return end;

        local Intent = Input.UserInputType == Enum.UserInputType.Touch and Library:Gesture(Input) or 'Sideways';

        if Intent ~= 'Sideways' and Intent ~= 'Scroll' then return end;

        task.wait();

        local Scrolls = Input.UserInputType == Enum.UserInputType.Touch and CanScroll;
        local Lifted = Input.UserInputState == Enum.UserInputState.End or Input.UserInputState == Enum.UserInputState.Cancel;

        if Library._drags[Input] or Library._claims[Input] or Lifted or (Intent == 'Scroll' and Scrolls) then return end;

        Grab(Input, Start);
    end), Outer);

    Library:GiveSignal(Svc.UserInputService.InputEnded:Connect(function(Input) Library._claims[Input] = nil end), Outer);

    Window.GlowFrame = Library:Create('Frame', { BackgroundTransparency = 1; BorderSizePixel = 0; Size = UDim2.fromScale(1, 1); Visible = false; ZIndex = 0; Parent = Outer });
    Window.GlowStrokes = {};

    for Index = 1, 8 do
        local Layer = Library:Create('Frame', { BackgroundTransparency = 1; BorderSizePixel = 0; Size = UDim2.fromScale(1, 1); ZIndex = 0; Parent = Window.GlowFrame });

        Library:Round(Layer, 8);
        Window.GlowStrokes[Index] = Library:Create('UIStroke', { Parent = Layer });
    end;

    Window.Shadow = Library:Create('ImageLabel', {
        BackgroundTransparency = 1;
        Image = 'rbxassetid://6014261993';
        ImageColor3 = Color3.new(0, 0, 0);
        ImageTransparency = 0.5;
        Position = UDim2.fromOffset(-24, -24);
        Size = UDim2.new(1, 48, 1, 48);
        ScaleType = Enum.ScaleType.Slice;
        SliceCenter = Rect.new(49, 49, 450, 450);
        Visible = Library.Effects.Shadow;
        ZIndex = 0;
        Parent = Outer;
    });

    Window.Canvas = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Size = UDim2.fromScale(1, 1);
        ZIndex = 1;
        Parent = Outer;
    });

    Library:AddToRegistry(Window.Canvas, { BackgroundColor3 = 'BackgroundColor' });
    Library:Panel(Window.Canvas, 'WindowTransparency', 8, true);

    Window.BgImage = Library:Create('ImageLabel', {
        BackgroundTransparency = 1;
        ScaleType = Enum.ScaleType.Crop;
        Size = UDim2.fromScale(1, 1);
        Visible = false;
        ZIndex = 1;
        Parent = Window.Canvas;
    });

    Window.BgDim = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        Visible = false;
        ZIndex = 1;
        Parent = Window.Canvas;
    });

    Window.Tint = Library:Create('Frame', {
        BackgroundColor3 = Library.FontColor;
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        Visible = false;
        ZIndex = 1;
        Parent = Window.Canvas;
    });

    Library:AddToRegistry(Window.Tint, { BackgroundColor3 = 'FontColor' });

    for _, Layer in ipairs({ Window.BgImage, Window.BgDim, Window.Tint }) do Library:Round(Layer, 8) end;

    local Inner = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        ZIndex = 1;
        Parent = Window.Canvas;
    });

    Window.AccentBar = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(0, 25);
        Size = UDim2.new(1, 0, 0, 1);
        ZIndex = 3;
        Parent = Inner;
    });

    Window.Gradient = Library:Create('UIGradient', { Parent = Window.AccentBar });

    for Side = 0, 1 do
        local Fade = Library:Create('Frame', {
            AnchorPoint = Vector2.new(Side, 0);
            BackgroundColor3 = Library.BackgroundColor;
            BorderSizePixel = 0;
            Position = UDim2.new(Side, 0, 0, 25);
            Size = UDim2.fromOffset(120, 1);
            ZIndex = 4;
            Parent = Inner;
        });

        Library:Create('UIGradient', {
            Transparency = NumberSequence.new(Side, 1 - Side);
            Parent = Fade;
        });

        Library:AddToRegistry(Fade, { BackgroundColor3 = 'BackgroundColor' });
    end;

    Window.Title = Library:CreateLabel({
        Position = UDim2.new(0, Config.TitlePosition == 'Left' and 8 or 0, 0, 0);
        Size = UDim2.new(1, Config.TitlePosition == 'Left' and -8 or 0, 0, 25);
        Text = Config.Title or '';
        TextXAlignment = Config.TitlePosition == 'Left' and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center;
        ZIndex = 1;
        Parent = Inner;
    });

    if typeof(Config.TitleColor) == 'Color3' then
        Window.Title.TextColor3 = Config.TitleColor;
        Library.Registry[Window.Title].TextColor3 = nil;
    end;

    Window.Footer = Library:CreateLabel({
        AnchorPoint = Vector2.new(1, 0);
        Position = UDim2.new(1, -140, 0, 0);
        Size = UDim2.fromOffset(200, 25);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Right;
        ZIndex = 1;
        Parent = Inner;
    });

    Window.FooterGradient = Library:Create('UIGradient', { Enabled = false; Parent = Window.Footer });

    Window:SetFooter({
        Texts = Config.Footer; Color = Config.FooterColor; Style = Config.FooterStyle;
        Interval = Config.FooterInterval; Order = Config.FooterOrder; Gradient = Config.FooterGradient;
        Speed = Config.FooterSpeed; Transition = Config.FooterTransition;
    });

    Window.Search = Library:Create('TextBox', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        ClearTextOnFocus = false;
        FontFace = Library.FontFace;
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150);
        PlaceholderText = 'Search';
        Position = UDim2.new(1, -132, 0, 3);
        Size = UDim2.fromOffset(124, 19);
        Text = '';
        TextColor3 = Library.FontColor;
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 2;
        Parent = Inner;
    });

    Library:AddToRegistry(Window.Search, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
        TextColor3 = 'FontColor';
        FontFace = 'FontFace';
    });

    Library:Create('UIPadding', { PaddingLeft = UDim.new(0, 5), Parent = Window.Search });

    Window.Search:GetPropertyChangedSignal('Text'):Connect(function()
        Library:Search(Window.Search.Text, Window);
    end);

    Library:GiveSignal(Svc.UserInputService.InputBegan:Connect(function(Input)
        if Input.KeyCode == Enum.KeyCode.Escape and Window.Search:IsFocused() then
            Window.Search.Text = '';
            Window.Search:ReleaseFocus();
        end;
    end), Outer);

    local Main = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 8, 0, 25);
        Size = UDim2.new(1, -16, 1, -33);
        ZIndex = 1;
        Parent = Inner;
    });

    Window.TabBar = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 8, 0, 8);
        Size = UDim2.new(1, -16, 0, TabBarHeight);
        ZIndex = 1;
        Parent = Main;
    });

    Window.Content = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 8, 0, 30);
        Size = UDim2.new(1, -16, 1, -38);
        ZIndex = 2;
        Parent = Main;
    });

    Library:AddToRegistry(Window.Content, { BackgroundColor3 = 'MainColor' });
    Library:Panel(Window.Content, 'PanelTransparency', 6);

    Window.SubBar = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.fromOffset(8, 8);
        Size = UDim2.fromOffset(0, TabBarHeight);
        Visible = false;
        ZIndex = 1;
        Parent = Main;
    });

    Window.Results = Library:Create('ScrollingFrame', {
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png';
        CanvasSize = UDim2.new();
        ScrollBarImageColor3 = Library.AccentColor;
        ScrollBarThickness = 2;
        ScrollingDirection = Enum.ScrollingDirection.Y;
        Size = UDim2.fromScale(1, 1);
        TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png';
        Visible = false;
        ZIndex = 3;
        Parent = Window.Content;
    });

    Library:AddToRegistry(Window.Results, { ScrollBarImageColor3 = 'AccentColor' });

    Library:Create('UIPadding', {
        PaddingTop = UDim.new(0, 7); PaddingBottom = UDim.new(0, 7);
        PaddingLeft = UDim.new(0, 7); PaddingRight = UDim.new(0, 9);
        Parent = Window.Results;
    });

    Library:Create('UIListLayout', { Padding = UDim.new(0, 4); SortOrder = Enum.SortOrder.LayoutOrder; Parent = Window.Results });

    local Grip = Library:Create('Frame', {
        AnchorPoint = Vector2.new(1, 1);
        BackgroundTransparency = 1;
        Position = UDim2.fromScale(1, 1);
        Size = UDim2.fromOffset(14, 14);
        ZIndex = 13;
        Active = true;
        Parent = Window.Canvas;
    });

    for _, Pos in ipairs({ Vector2.new(9, 11), Vector2.new(11, 9), Vector2.new(11, 11) }) do
        local Dot = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.fromOffset(Pos.X, Pos.Y);
            Size = UDim2.fromOffset(2, 2);
            ZIndex = 13;
            Parent = Grip;
        });

        Library:AddToRegistry(Dot, { BackgroundColor3 = 'AccentColor' });
    end;

    Window.Grip = Grip;

    local GripHit = Library:HitFrame(Grip, UDim2.fromOffset(Library.IsMobile and 36 or 16, Library.IsMobile and 36 or 16), 13);

    GripHit.InputBegan:Connect(function(Input)
        if not Library:IsPress(Input) then return end;

        local Start, Layout = Library:MousePos(Input), Window.Layout;
        local Size0 = Vector2.new(Outer.Size.X.Offset, Outer.Size.Y.Offset);

        Library:Drag(Input, function(Pos)
            if Window.Layout ~= Layout then return end;

            local Delta = (Pos - Start) / Library.Scale.Scale;

            Window:SetSize(Size0.X + Delta.X, Size0.Y + Delta.Y);
        end);
    end);

    Outer:GetPropertyChangedSignal('Size'):Connect(function()
        Window:ApplyLayout();
    end);

    Window.Modal = Library:Create('TextButton', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 0);
        Visible = true;
        Text = '';
        Modal = false;
        Parent = Library.Root;
    });

    if Library.IsMobile then
        Window:AddMobileButton();
    end;

    local function Track(Desc)
        local Props = FadeProps(Desc);
        if Props then Window.Fade[Desc] = Props end;
    end;

    for _, Desc in ipairs(Outer:GetDescendants()) do Track(Desc) end;
    Outer.DescendantAdded:Connect(Track);
    Outer.DescendantRemoving:Connect(function(Desc) Window.Fade[Desc] = nil end);

    Library:GiveSignal(Library.Root:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() Window:Clamp() end), Outer);

    Window:UpdateGradient();
    Window:ApplyLayout();
    Window:Clamp();
    Library:UpdateUIBlur();

    if Config.AutoShow then task.spawn(Library.Toggle) end;

    Window.Holder = Outer;

    return Window;
end;

function Library.Toggle()
    if Library.Window then
        return Library.Window:Toggle();
    end;
end;

Library:GiveSignal(Svc.UserInputService.InputBegan:Connect(function(Input, Processed)
    if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
            task.spawn(Library.Toggle);
        end;
    elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
        task.spawn(Library.Toggle);
    end;
end));

function WindowBase:Destroy()
    for _, List in ipairs({ Library.Tops, Library.Searchables }) do
        for Idx = #List, 1, -1 do
            local Top = List[Idx].Top;
            if (Top and Top.Tab or List[Idx].Tab).Window == self then
                table.remove(List, Idx);
            end;
        end;
    end;

    for _, Tab in next, self.Tabs do
        local Page = Tab.Page;

        Library.DetachedTabs[Page] = nil;
        Library.Registry[Page] = nil;

        for _, Item in ipairs(Page:GetDescendants()) do
            Library.Registry[Item] = nil;
            Library.Corners[Item] = nil;
        end;

        Page:Destroy();
    end;

    for _, Obj in ipairs({ self.Outer, self.Modal, self.MobileButton }) do
        if Obj then Obj:Destroy() end;
    end;

    if Library.Window == self then Library.Window = nil end;
end;

local function FooterSequence(Style, Phase, Pair)
    local Points = {};

    for Step = 0, 6 do
        local T = Step / 6;
        local Color;

        if Style == 'Rainbow' then
            Color = Color3.fromHSV((T * 0.6 - Phase) % 1, 0.8, 1);
        else
            local A, B = Pair and Pair[1] or Library.AccentColor, Pair and Pair[2] or Library.AccentColorDark;

            Color = A:Lerp(B, (math.sin((T * 0.5 - Phase) * math.pi * 2) + 1) / 2);
        end;

        Points[#Points + 1] = ColorSequenceKeypoint.new(T, Color);
    end;

    return ColorSequence.new(Points);
end;

function WindowBase:SetFooter(Info)
    local Label = self.Footer;
    local Texts = {};

    for _, Text in ipairs(type(Info.Texts) == 'table' and Info.Texts or { Info.Texts or '' }) do
        Texts[#Texts + 1] = tostring(Text);
    end;

    local Style = (Info.Style == 'Gradient' or Info.Style == 'Rainbow') and Info.Style or 'None';
    local Interval = math.max(tonumber(Info.Interval) or 3, 0.5);
    local Speed = math.clamp(tonumber(Info.Speed) or 0.005, 0.001, 1);
    local Fades = Info.Transition == 'Fade';
    local Random = Info.Order == 'Random';
    local Index = Random and #Texts > 0 and math.random(#Texts) or 1;
    local Reg = Library.Registry[Label];

    Library:UnbindRender('Footer');

    Label.Text = Texts[Index] or '';
    self.FooterGradient.Enabled = Style ~= 'None';

    if Style ~= 'None' then
        Label.TextColor3 = Color3.new(1, 1, 1);
        Label.TextTransparency = 0;
        Reg.TextColor3 = nil;
    elseif typeof(Info.Color) == 'Color3' then
        Label.TextColor3 = Info.Color;
        Label.TextTransparency = 0;
        Reg.TextColor3 = nil;
    else
        Label.TextColor3 = Library.FontColor;
        Label.TextTransparency = 0.4;
        Reg.TextColor3 = 'FontColor';
    end;

    if Style == 'None' and #Texts < 2 then return end;

    local Elapsed, Phase, Base = 0, 0, Label.TextTransparency;
    local Stage, Progress = nil, 0;

    Library:BindRender('Footer', function(Delta)
        if not self.Outer.Visible or next(Library._drags) then return end;

        Elapsed += Delta;

        if #Texts > 1 and not Stage and Elapsed >= Interval then
            Elapsed = 0;

            if Random then
                local Next = math.random(#Texts - 1);

                Index = Next >= Index and Next + 1 or Next;
            else
                Index = Index % #Texts + 1;
            end;

            if Fades then
                Stage, Progress = 'Out', 0;
            else
                Label.Text = Texts[Index];
            end;
        end;

        if Stage then
            Progress = math.min(Progress + Delta / 0.3, 1);

            if Stage == 'Out' then
                Label.TextTransparency = Base + (1 - Base) * Progress;

                if Progress >= 1 then
                    Label.Text = Texts[Index];
                    Stage, Progress = 'In', 0;
                end;
            else
                Label.TextTransparency = 1 - (1 - Base) * Progress;

                if Progress >= 1 then Stage = nil end;
            end;
        end;

        if Style ~= 'None' then
            Phase = (Phase + Delta * Speed) % 1;
            self.FooterGradient.Color = FooterSequence(Style, Phase, Info.Gradient);
        end;
    end);
end;

function WindowBase:SetWindowTitle(Title)
    self.Title.Text = Title;
end;

function WindowBase:FitSize(Size)
    local View = Library:Viewport() / Library.Scale.Scale;

    return UDim2.fromOffset(math.min(Size.X.Offset, math.max(View.X - 8, 100)), math.min(Size.Y.Offset, math.max(View.Y - 8, 100)));
end;

function WindowBase:Clamp()
    local Outer, Anchor = self.Outer, self.Config.AnchorPoint;
    local View = Library:Viewport() / Library.Scale.Scale;

    local Size = Vector2.new(Outer.Size.X.Offset, Outer.Size.Y.Offset);
    local Fit = self:FitSize(self.Sizes[self.Layout]);
    local NewSize = Vector2.new(Fit.X.Offset, Fit.Y.Offset);

    local Pos = Outer.Position;
    local Left = Pos.X.Scale * View.X + Pos.X.Offset - Anchor.X * NewSize.X;
    local Top = Pos.Y.Scale * View.Y + Pos.Y.Offset - Anchor.Y * NewSize.Y;

    local Free, Keep = Library.Offscreen, 48;
    local ClampedLeft = Free and math.clamp(Left, Keep - NewSize.X, View.X - Keep) or math.clamp(Left, 0, math.max(View.X - NewSize.X, 0));
    local ClampedTop = Free and math.clamp(Top, 0, View.Y - Keep) or math.clamp(Top, 0, math.max(View.Y - NewSize.Y, 0));

    ClampedLeft, ClampedTop = math.floor(ClampedLeft + 0.5), math.floor(ClampedTop + 0.5);

    if NewSize ~= Size then Outer.Size = Fit end;

    if ClampedLeft ~= Left or ClampedTop ~= Top then
        Outer.Position = UDim2.fromOffset(ClampedLeft + Anchor.X * NewSize.X, ClampedTop + Anchor.Y * NewSize.Y);
    end;

    self:KeepMobileButton();
end;

function WindowBase:SetSize(Width, Height, Layout)
    Layout = Layout or self.Layout;

    if not self.Sizes[Layout] then return end;

    local Outer, Anchor, Min = self.Outer, self.Config.AnchorPoint, self.Config.MinSize;
    local Size = UDim2.fromOffset(math.max(Width, Min.X), math.max(Height, Min.Y));

    if Layout ~= self.Layout then
        self.Sizes[Layout] = Size;
        return;
    end;

    local Fit = self:FitSize(Size);
    local Old = Outer.Size;

    Outer.Size = Fit;
    Outer.Position += UDim2.fromOffset((Fit.X.Offset - Old.X.Offset) * Anchor.X, (Fit.Y.Offset - Old.Y.Offset) * Anchor.Y);
    self.Sizes[Layout] = Fit;
    self:Clamp();
end;

function WindowBase:ResetSize()
    local Default = self.Layout == 'Vertical' and self.Config.VerticalSize or self.Config.Size;

    self:SetSize(Default.X.Offset, Default.Y.Offset);
    Library:AttemptSave();
end;

function WindowBase:Rescale(OldScale)
    local Outer, Anchor = self.Outer, self.Config.AnchorPoint;
    local Viewport = Library:Viewport();
    local Before, After = Viewport / OldScale, Viewport / Library.Scale.Scale;
    local Size, Pos = Vector2.new(Outer.Size.X.Offset, Outer.Size.Y.Offset), Outer.Position;
    local Left = Pos.X.Scale * Before.X + Pos.X.Offset - Anchor.X * Size.X;
    local Top = Pos.Y.Scale * Before.Y + Pos.Y.Offset - Anchor.Y * Size.Y;
    local Center = Vector2.new((Left + Size.X / 2) / Before.X, (Top + Size.Y / 2) / Before.Y);
    local Fit = self:FitSize(self.Sizes[self.Layout]);

    Outer.Size = Fit;
    Outer.Position = UDim2.fromOffset(
        Center.X * After.X - Fit.X.Offset / 2 + Anchor.X * Fit.X.Offset,
        Center.Y * After.Y - Fit.Y.Offset / 2 + Anchor.Y * Fit.Y.Offset
    );

    self:ApplyLayout();
    self:Clamp();
end;

function WindowBase:AutoScale()
    local View, Size = Library:Viewport(), self.Sizes[self.Layout];
    local Scale = math.min(1, (View.X - 16) / Size.X.Offset, (View.Y - 16) / Size.Y.Offset);

    Library:SetDPIScale(math.max(Scale, 0.6) * 100);
end;

function Library:SetMobileButtonPos(X, Y)
    Library.MobileButtonPos = Vector2.new(X, Y);

    if Library.Window and Library.Window.MobileButton then
        Library.Window.MobileButton.Position = UDim2.fromOffset(X, Y);
    end;
end;

function WindowBase:KeepMobileButton()
    local Button = self.MobileButton;

    if not Button then return end;

    local View = Library:Viewport() / Library.Scale.Scale;
    local P = Button.Position;

    Button.Position = UDim2.fromOffset(math.clamp(P.X.Offset, 0, View.X - 44), math.clamp(P.Y.Offset, 0, View.Y - 44));
end;

function WindowBase:AddMobileButton()
    local Pos = Library.MobileButtonPos or Vector2.new(12, 80);

    local Button = Library:Create('TextButton', {
        AutoButtonColor = false;
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        Position = UDim2.fromOffset(Pos.X, Pos.Y);
        Size = UDim2.fromOffset(44, 44);
        Text = '';
        ZIndex = 250;
        Parent = Library.Root;
    });

    Library:AddToRegistry(Button, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'AccentColor' });
    Library:CreateLabel({ Size = UDim2.fromScale(1, 1); Text = 'UI'; ZIndex = 251; Parent = Button });

    Library:MakeDraggable(Button, 100, function() self:KeepMobileButton() end);

    Button.InputBegan:Connect(function(Input)
        if not Library:IsPress(Input) then return end;

        local Start = Library:MousePos(Input);
        local End; End = Svc.UserInputService.InputEnded:Connect(function(Done)
            if Done ~= Input then return end;
            End:Disconnect();

            if (Library:MousePos(Done) - Start).Magnitude < 6 then
                task.spawn(Library.Toggle);
            else
                Library.MobileButtonPos = Vector2.new(Button.Position.X.Offset, Button.Position.Y.Offset);
                Library:AttemptSave();
            end;
        end);
    end);

    self.MobileButton = Button;
end;

function Library:StyleBorder(Stroke, Gradient)
    local Accent, Outline = Library.AccentColor, Library.OutlineColor;

    local Style = Library.BorderStyle;

    local Color = Library.BorderUseTheme and Accent or Library.BorderColor;
    local Base = Library.BorderUseTheme and Outline or Library.BorderBase;

    Gradient.Enabled = Style == 'Animated';
    Stroke.Color = Style == 'None' and Outline or (Style == 'Static' and Color or Color3.new(1, 1, 1));
    Stroke.Transparency = Style == 'None' and 0 or Library.BorderTransparency;
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Base);
        ColorSequenceKeypoint.new(0.4, Base);
        ColorSequenceKeypoint.new(0.5, Color);
        ColorSequenceKeypoint.new(0.6, Base);
        ColorSequenceKeypoint.new(1, Base);
    });

    return Style;
end;

function WindowBase:UpdateGradient()
    local Accent, Dark = Library.AccentColor, Library.AccentColorDark;
    local Line, Border = self.Gradient, self.StrokeGradient;

    Library:UnbindRender('WindowFx');

    Line.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Accent);
        ColorSequenceKeypoint.new(0.25, Dark);
        ColorSequenceKeypoint.new(0.5, Accent);
        ColorSequenceKeypoint.new(0.75, Dark);
        ColorSequenceKeypoint.new(1, Accent);
    });
    Line.Offset = Vector2.zero;

    local Style = Library:StyleBorder(self.Stroke, Border);

    for Stroke, Item in next, Library.Outlines do Library:StyleBorder(Stroke, Item.Gradient) end;

    self:UpdateGlow();

    local LineMoves = Library.MenuOpen;
    local BorderMoves = LineMoves and Style == 'Animated';
    if LineMoves or BorderMoves then
        local T, Odd = 0, false;

        Library:BindRender('WindowFx', function(Delta)
            if next(Library._drags) then return end;

            T = (T + Delta * 0.25) % 1;

            self.BorderAngle = ((self.BorderAngle or 0) + Delta * 90 * Library.BorderSpeed) % 360;

            if LineMoves then Line.Offset = Vector2.new(T - 0.5, 0) end;

            if BorderMoves then
                Border.Rotation = self.BorderAngle;
                Odd = not Odd;

                if Odd then
                    for _, Item in next, Library.Outlines do
                        if Item.Frame.Visible then Item.Gradient.Rotation = self.BorderAngle end;
                    end;
                end;
            end;
        end);
    end;
end;

function WindowBase:UpdateGlow()
    local Glow, Strokes = Library.Glow, self.GlowStrokes;
    local Size = math.clamp(Glow.Size, 1, 15);

    self.GlowFrame.Visible = Library.Effects.Glow;

    for Index, Stroke in ipairs(Strokes) do

        Stroke.Thickness = Size * (Index / #Strokes) ^ 2;
        Stroke.Color = Glow.UseTheme and Library.AccentColor or Glow.Color;

        Stroke.Transparency = Glow.Transparency ^ (1 / #Strokes);
    end;
end;

function WindowBase:Toggle()
    if self.Fading then
        return;
    end;

    local Outer = self.Outer;
    local FadeTime = self.Config.MenuFadeTime;
    local Fade = Library.Effects.MenuFade;

    self.Fading = true;
    Library.MenuOpen = not Library.MenuOpen;
    self.Modal.Modal = Library.MenuOpen;

    if Library.MenuOpen then
        Library.PrevIcon = Svc.UserInputService.MouseIconEnabled;
        Library:BindRender('Cursor', function() Svc.UserInputService.MouseIconEnabled = true end);
    else
        Library:UnbindRender('Cursor');
        if Library.PrevIcon ~= nil then Svc.UserInputService.MouseIconEnabled = Library.PrevIcon end;
    end;
    Library:UpdateBlur();
    Library:UpdateUIBlur();

    local Opening = Library.MenuOpen;

    if Opening then
        Outer.Visible = true;
    else
        Library:ClosePopups();
    end;

    self:UpdateGradient();

    if Fade then
        local Items = {};

        for Desc, Props in next, self.Fade do
            for _, Prop in ipairs(Props) do
                local Normal = Desc[Prop];

                if Normal < 1 then table.insert(Items, { Desc, Prop, Normal }) end;
            end;
        end;

        local Current = { Items = Items, Opening = Opening };
        self.ActiveFade = Current;

        local Start = os.clock();

        Library:BindRender('MenuFade', function()
            local Progress = math.clamp((os.clock() - Start) / math.max(FadeTime, 0.01), 0, 1);
            local Visible = Opening and Progress or (1 - Progress);

            for _, Item in ipairs(Items) do
                Item[1][Item[2]] = 1 - (1 - Item[3]) * Visible;
            end;
        end);

        task.wait(FadeTime);

        if self.ActiveFade == Current then self:FinishFade() end;

        return;
    end;

    Outer.Visible = Opening;
    self.Fading = false;
end;

function WindowBase:FinishFade()
    local Fade = self.ActiveFade;

    if not Fade then return end;

    self.ActiveFade = nil;
    Library:UnbindRender('MenuFade');

    for _, Item in ipairs(Fade.Items) do Item[1][Item[2]] = Item[3] end;

    self.Outer.Visible = Fade.Opening;
    self.Fading = false;
end;

function WindowBase:SelectTab(Name)
    local Tab = self.Tabs[Name];
    if Tab then Tab:ShowTab() end;
end;

function WindowBase:SetLayout(Name)
    if (Name ~= 'Horizontal' and Name ~= 'Vertical') or Name == self.Layout then
        return;
    end;

    Library:ClosePopups();

    local Outer = self.Outer;
    local Old = Vector2.new(Outer.Size.X.Offset, Outer.Size.Y.Offset);

    self.Layout = Name;

    local New = self:FitSize(self.Sizes[Name]);
    local Anchor = self.Config.AnchorPoint;

    local Pos = Outer.Position + UDim2.fromOffset((Anchor.X - 0.5) * (New.X.Offset - Old.X), (Anchor.Y - 0.5) * (New.Y.Offset - Old.Y));

    self:ApplyLayout();
    Library:Tween(Outer, { Size = New, Position = Pos }, 0.2);
    task.delay(Library.Effects.Animations and 0.25 or 0, function() if Outer.Parent then self:Clamp() end end);

    if Options.UI_Layout and Options.UI_Layout.Value ~= Name then Options.UI_Layout:SetValue(Name) end;
end;

function WindowBase:GetContentWidth()
    local Width = self.Outer.Size.X.Offset - 32;

    if self.Layout == 'Vertical' then
        Width = Width - self.SidebarWidth - 16;
    end;

    return Width;
end;

local function PlaceButtons(Infos, AreaWidth, Pad)
    local Rows, Row, RowSum = {}, {}, 0;

    for _, Info in ipairs(Infos) do
        local Need = Info.Width + 8;

        if #Row > 0 and RowSum + Need + Pad * #Row > AreaWidth then
            table.insert(Rows, Row);
            Row, RowSum = {}, 0;
        end;

        table.insert(Row, Info);
        RowSum = RowSum + Need;
    end;

    if #Row > 0 then table.insert(Rows, Row) end;

    for RowIdx, Items in ipairs(Rows) do
        local Sum = 0;
        for _, Info in ipairs(Items) do Sum = Sum + Info.Width + 8 end;

        local Free, Taken, Cursor = AreaWidth - Pad * (#Items - 1), 0, 0;

        for Idx, Info in ipairs(Items) do
            Taken = Taken + Info.Width + 8;
            local Right = math.floor(Free * Taken / Sum + 0.5) + Pad * (Idx - 1);

            Info.Button.Position = UDim2.fromOffset(Cursor, (RowIdx - 1) * (TabBarHeight + Pad));
            Info.Button.Size = UDim2.fromOffset(Right - Cursor, TabBarHeight);
            Cursor = Right + Pad;
        end;
    end;

    return #Rows * TabBarHeight + math.max(#Rows - 1, 0) * Pad;
end;

function WindowBase:ApplyLayout()
    if self.Applying then return end;
    self.Applying = true;

    local Buttons = self.TabButtons;
    local Pad = self.Config.TabPadding;
    local Vertical = self.Layout == 'Vertical';
    local TabBar, Content = self.TabBar, self.Content;

    local Compact = Library.IsMobile and Vertical and self.Outer.Size.X.Offset * Library.Scale.Scale < 560;

    local IconsOnly, Longest = Compact, 0;

    for _, Info in ipairs(Buttons) do
        IconsOnly = IconsOnly and Info.Icon ~= nil;
        Longest = math.max(Longest, Info.Width + 8);
    end;

    self.Compact = Compact;
    self.SidebarWidth = IconsOnly and 44 or Compact and math.min(Longest, 150) or 150;

    table.sort(Buttons, function(A, B)
        if A.Button.LayoutOrder == B.Button.LayoutOrder then
            return A.Index < B.Index;
        end;

        return A.Button.LayoutOrder < B.Button.LayoutOrder;
    end);

    if Vertical then
        local W, H = self.SidebarWidth, 24;

        TabBar.Position = UDim2.new(0, 8, 0, 8);
        TabBar.Size = UDim2.new(0, W, 1, -16);

        Content.Position = UDim2.new(0, 24 + W, 0, 8);
        Content.Size = UDim2.new(1, -(32 + W), 1, -16);

        for Idx, Info in ipairs(Buttons) do
            Info.Button.Position = UDim2.fromOffset(0, (Idx - 1) * (H + Pad));
            Info.Button.Size = UDim2.fromOffset(W, H);
        end;
    else

        local AreaWidth = math.max(self.Outer.Size.X.Offset + TabBar.Parent.Size.X.Offset - 16, 1);

        local BarHeight = PlaceButtons(Buttons, AreaWidth, Pad);

        TabBar.Position = UDim2.new(0, 8, 0, 8);
        TabBar.Size = UDim2.new(1, -16, 0, BarHeight);
        Content.Position = UDim2.new(0, 8, 0, 8 + BarHeight + 4);
        Content.Size = UDim2.new(1, -16, 1, -(8 + BarHeight + 4 + 8));
    end;

    local Subs = self.CurrentTab and self.CurrentTab.SubInfos;

    if Subs and #Subs > 0 then
        local Area = math.max(self.Outer.Size.X.Offset - 16 + Content.Size.X.Offset, 1);
        local SubHeight = PlaceButtons(Subs, Area, Pad);
        local Top = Vertical and 8 or TabBar.Position.Y.Offset + TabBar.Size.Y.Offset + 4;

        self.SubBar.Position = UDim2.fromOffset(Vertical and 24 + self.SidebarWidth or 8, Top);
        self.SubBar.Size = UDim2.fromOffset(Area, SubHeight);
        self.SubBar.Visible = true;

        Content.Position = UDim2.new(0, Content.Position.X.Offset, 0, Top + SubHeight + 4);
        Content.Size = UDim2.new(Content.Size.X.Scale, Content.Size.X.Offset, 1, -(Top + SubHeight + 4 + 8));
    else
        self.SubBar.Visible = false;
    end;

    for _, Info in ipairs(Buttons) do
        Info.Label.Text = IconsOnly and '' or Info.Name;

        local Left = (Info.Icon and not IconsOnly) and ((Vertical and 8 or 0) + 22) or 0;
        Info.Label.Position = UDim2.new(0, Left, 0, 0);
        Info.Label.Size = UDim2.new(1, -Left, 1, 0);

        if Info.Icon then
            Info.Icon.AnchorPoint = IconsOnly and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5);
            Info.Icon.Position = IconsOnly and UDim2.fromScale(0.5, 0.5) or UDim2.new(0, Vertical and 8 or 6, 0.5, 0);
        end;
    end;

    local Single;

    if Library.IsMobile then
        Single = self:GetContentWidth() * Library.Scale.Scale < Library.MobileSingleColumnWidth;
    else
        Single = self:GetContentWidth() < Library.SingleColumnWidth;
    end;

    self.Single = Single;

    local Inner = self:GetContentWidth() - 14 - 8;

    for _, Tab in next, self.Tabs do
        Tab:SetColumns(Single, math.floor(Inner / 2), Inner - math.floor(Inner / 2));

        for _, Sub in ipairs(Tab.SubTabs or {}) do
            Sub:SetColumns(Single, math.floor(Inner / 2), Inner - math.floor(Inner / 2));
        end;
    end;

    self.Applying = false;
end;

function Library:TabButton(Parent, Name, IconId)
    local Width = Library:GetTextBounds(Name, 16) + 8 + 4 + (IconId and 20 or 0);

    local Button = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.fromOffset(Width, TabBarHeight);
        ZIndex = 1;
        Parent = Parent;
    });

    Library:AddToRegistry(Button, { BackgroundColor3 = 'MainColor'; BackgroundTransparency = 'PanelTransparency'; BorderColor3 = 'OutlineColor' });

    local Label = Library:CreateLabel({
        Size = UDim2.fromScale(1, 1);
        Text = Name;
        TextTruncate = Enum.TextTruncate.AtEnd;
        ZIndex = 1;
        Parent = Button;
    });

    local Icon;

    if IconId then
        Icon = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            Image = IconId;
            Size = UDim2.fromOffset(16, 16);
            ZIndex = 2;
            Parent = Button;
        });
    end;

    return { Button = Button; Label = Label; Icon = Icon; Name = Name; Width = Width };
end;

local function BuildPage(Tab, Window)
    local Page = Library:Create('ScrollingFrame', {
        Name = 'TabFrame';
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png';
        CanvasSize = UDim2.new();
        ScrollBarImageColor3 = Library.AccentColor;
        ScrollBarThickness = 2;
        ScrollingDirection = Enum.ScrollingDirection.Y;
        Size = UDim2.fromScale(1, 1);
        TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png';
        Visible = false;
        ZIndex = 2;
        Parent = Window.Content;
    });

    Library:AddToRegistry(Page, { ScrollBarImageColor3 = 'AccentColor' });
    Library:Create('UIPadding', {
        PaddingTop = UDim.new(0, 7); PaddingBottom = UDim.new(0, 7);
        PaddingLeft = UDim.new(0, 7); PaddingRight = UDim.new(0, 7);
        Parent = Page;
    });

    Tab.Page = Page;
    Tab.PageLayout = Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Horizontal;
        Padding = UDim.new(0, 8);
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Page;
    });

    for _, Side in ipairs({ 'Left', 'Right' }) do
        local Column = Library:Create('Frame', {
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            LayoutOrder = Side == 'Left' and 1 or 2;
            Size = UDim2.new(0.5, -4, 0, 0);
            ZIndex = 2;
            Parent = Page;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Column;
        });

        Tab[Side] = Column;
    end;
end;

function WindowBase:AddTab(Name, Icon)
    local Window = self;

    local Tab = setmetatable({
        Window = Window;
        Name = Name;
        Groupboxes = {};
        Tabboxes = {};
    }, TabBase);

    local Info = Library:TabButton(Window.TabBar, Name, Icon and Library:GetAsset(Icon));
    Info.Index = #Window.TabButtons + 1;

    local Button = Info.Button;

    Tab.Info = Info;
    Tab.Button = Button;

    table.insert(Window.TabButtons, Info);

    if Library.IsMobile then Library:AddToolTip(Name, Button) end;

    BuildPage(Tab, Window);

    Button.InputBegan:Connect(function(Input)
        if Library:IsClick(Input) then
            Tab:ShowTab();
        end;
    end);

    Window.Tabs[Name] = Tab;
    Window:ApplyLayout();

    if not Window.CurrentTab then
        Tab:ShowTab();
    end;

    return Tab;
end;

function TabBase:SetColumns(Single, LeftWidth, RightWidth)
    local Layout = self.PageLayout;

    Layout.FillDirection = Single and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal;
    self.Left.Size = Single and UDim2.new(1, 0, 0, 0) or UDim2.fromOffset(LeftWidth, 0);
    self.Right.Size = Single and UDim2.new(1, 0, 0, 0) or UDim2.fromOffset(RightWidth, 0);
end;

local function ShowPage(Page, Window)
    Page.Parent = Window.Content;
    Library.DetachedTabs[Page] = nil;
    Page.Visible = true;

    Page.Position = UDim2.fromOffset(0, 8);
    Library:Tween(Page, { Position = UDim2.fromOffset(0, 0) }, 0.15);
end;

local function HidePage(Page)
    Page.Visible = false;

    Library:Detach(Page);
    Library.DetachedTabs[Page] = true;
end;

function TabBase:ShowTab()
    local Window = self.Window;
    local Top = self.Parent or self;

    if Top.SubTabs then Top.ActiveSub = self.Parent and self or Top.ActiveSub or Top.SubTabs[1] end;

    local Page = Top.ActiveSub and Top.ActiveSub.Page or Top.Page;

    if Window.CurrentTab ~= Top then Library:ClosePopups() end;

    for _, Tab in next, Window.Tabs do
        if Tab ~= Top then Tab:HideTab() end;
    end;

    if Top.Page ~= Page then HidePage(Top.Page) end;

    Top.Page = Page;
    Window.CurrentTab = Top;

    Top:Highlight(true);

    for _, Sub in ipairs(Top.SubTabs or {}) do Sub:Highlight(Sub == Top.ActiveSub) end;

    for _, Tab in next, Window.Tabs do
        for _, Info in ipairs(Tab.SubInfos or {}) do Info.Button.Visible = Tab == Top end;
    end;

    ShowPage(Page, Window);
    Window:ApplyLayout();

    if Window.Search.Text ~= '' then Window.Search.Text = '' end;
end;

function TabBase:Highlight(Open)
    local Label = self.Info.Label;

    Label.TextColor3 = Open and Library.AccentColor or Library.FontColor;
    Library.Registry[Label].TextColor3 = Open and 'AccentColor' or 'FontColor';
end;

function TabBase:HideTab()
    self:Highlight(false);
    HidePage(self.Page);
end;

function TabBase:AddSubTab(Name)
    local Window, Top = self.Window, self;

    assert(not Top.Parent, '[lib] a sub tab cannot have sub tabs of its own');

    local Sub = setmetatable({ Window = Window; Name = Name; Parent = Top; Groupboxes = {}; Tabboxes = {} }, TabBase);
    local Info = Library:TabButton(Window.SubBar, Name);

    Top.SubInfos = Top.SubInfos or {};
    Top.SubTabs = Top.SubTabs or {};

    Info.Index = #Top.SubInfos + 1;
    Info.Button.Visible = Window.CurrentTab == Top;

    Sub.Info = Info;
    Sub.Button = Info.Button;

    table.insert(Top.SubInfos, Info);
    table.insert(Top.SubTabs, Sub);

    BuildPage(Sub, Window);

    Info.Button.InputBegan:Connect(function(Input)
        if Library:IsClick(Input) then
            Sub:ShowTab();
        end;
    end);

    Sub:Highlight(false);

    if Window.CurrentTab == Top and #Top.SubTabs == 1 then
        Sub:ShowTab();
    else
        Window:ApplyLayout();
    end;

    return Sub;
end;

function TabBase:SetLayoutOrder(Position)
    self.Button.LayoutOrder = Position;
    self.Window:ApplyLayout();
end;

local function CreateBox(Tab, Side, Height)
    local Outer = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, Height);
        ZIndex = 2;
        Parent = Side == 1 and Tab.Left or Tab.Right;
    });

    Library:AddToRegistry(Outer, { BackgroundColor3 = 'BackgroundColor' });
    Library:Panel(Outer, 'PanelTransparency', 6);

    local Inner = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.new(1, -2, 1, -2);
        Position = UDim2.new(0, 1, 0, 1);
        ZIndex = 4;
        Parent = Outer;
    });

    return Outer, Inner;
end;

function TabBase:AddGroupbox(Info)
    local Groupbox = { Tab = self; Elements = {} };
    Groupbox.Top = Groupbox;

    local BoxOuter, BoxInner = CreateBox(self, Info.Side, 509);

    Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 18);
        Position = UDim2.new(0, 8, 0, 3);
        TextSize = 14;
        Text = Info.Name;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = BoxInner;
    });

    local TitleLine = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 0.55;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 8, 0, 22);
        Size = UDim2.new(1, -16, 0, 1);
        ZIndex = 5;
        Parent = BoxInner;
    });

    Library:AddToRegistry(TitleLine, { BackgroundColor3 = 'AccentColor' });

    Library:Create('UIGradient', {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1);
            NumberSequenceKeypoint.new(0.2, 0);
            NumberSequenceKeypoint.new(0.8, 0);
            NumberSequenceKeypoint.new(1, 1);
        });
        Parent = TitleLine;
    });

    local Container = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 8, 0, 26);
        Size = UDim2.new(1, -12, 1, -26);
        ZIndex = 1;
        Parent = BoxInner;
    });

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Container;
    });

    function Groupbox:Resize()
        local Size = 0;

        for _, Element in next, Container:GetChildren() do
            if Element:IsA('GuiObject') and Element.Visible then
                Size = Size + Element.Size.Y.Offset;
            end;
        end;

        BoxOuter.Size = UDim2.new(1, 0, 0, 26 + Size + 2 + 2);
    end;

    Groupbox.BoxOuter, Groupbox.BoxInner = BoxOuter, BoxInner;
    Groupbox.Container = Container;
    setmetatable(Groupbox, BaseGroupbox);

    Groupbox:AddBlank(3);
    Groupbox:Resize();

    table.insert(Library.Tops, Groupbox);
    self.Groupboxes[Info.Name] = Groupbox;

    return Groupbox;
end;

function TabBase:AddLeftGroupbox(Name)
    return self:AddGroupbox({ Side = 1; Name = Name; });
end;

function TabBase:AddRightGroupbox(Name)
    return self:AddGroupbox({ Side = 2; Name = Name; });
end;

function TabBase:AddTabbox(Info)
    local Tabbox = { Tabs = {}; Elements = {}; Tab = self };
    Tabbox.Top = Tabbox;

    local BoxOuter, BoxInner = CreateBox(self, Info.Side, 0);

    local TabboxButtons = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 1);
        Size = UDim2.new(1, 0, 0, 18);
        ZIndex = 5;
        Parent = BoxInner;
    });

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Left;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabboxButtons;
    });

    function Tabbox:AddTab(Name)
        local Tab = { Top = Tabbox };

        local Button = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Size = UDim2.new(0.5, 0, 1, 0);
            ZIndex = 6;
            Parent = TabboxButtons;
        });

        Library:Round(Button, 5);
        Library:AddToRegistry(Button, { BackgroundColor3 = 'MainColor'; BackgroundTransparency = 'PanelTransparency' });

        Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = Name;
            TextXAlignment = Enum.TextXAlignment.Center;
            ZIndex = 7;
            Parent = Button;
        });

        local Block = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, 0);
            Size = UDim2.new(1, 0, 0, 1);
            Visible = false;
            ZIndex = 9;
            Parent = Button;
        });

        Library:AddToRegistry(Block, { BackgroundColor3 = 'BackgroundColor' });

        local Container = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 8, 0, 24);
            Size = UDim2.new(1, -12, 1, -24);
            ZIndex = 1;
            Visible = false;
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Container;
        });

        Library:Detach(Container);
        Library:DestroyWith(BoxOuter, Container);

        function Tab:Show()
            for _, Other in next, Tabbox.Tabs do
                Other:Hide();
            end;

            Container.Parent = BoxInner;
            Container.Visible = true;
            Block.Visible = true;

            Button.BackgroundColor3 = Library.BackgroundColor;
            Library.Registry[Button].BackgroundColor3 = 'BackgroundColor';

            Tab:Resize();
        end;

        function Tab:Hide()
            Container.Visible = false;
            Library:Detach(Container);
            Block.Visible = false;

            Button.BackgroundColor3 = Library.MainColor;
            Library.Registry[Button].BackgroundColor3 = 'MainColor';
        end;

        function Tab:Resize()
            local TabCount = 0;

            for _ in next, Tabbox.Tabs do
                TabCount = TabCount + 1;
            end;

            for _, B in next, TabboxButtons:GetChildren() do
                if B:IsA('GuiObject') then
                    B.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                end;
            end;

            if (not Container.Visible) then
                return;
            end;

            local Size = 0;

            for _, Element in next, Container:GetChildren() do
                if Element:IsA('GuiObject') and Element.Visible then
                    Size = Size + Element.Size.Y.Offset;
                end;
            end;

            BoxOuter.Size = UDim2.new(1, 0, 0, 24 + Size + 2 + 2);
        end;

        Button.InputBegan:Connect(function(Input)
            if Library:IsClick(Input) then
                Tab:Show();
            end;
        end);

        Tab.Container = Container;
        Tabbox.Tabs[Name] = Tab;

        setmetatable(Tab, BaseGroupbox);

        Tab:AddBlank(3);
        Tab:Resize();

        if #TabboxButtons:GetChildren() == 2 then
            Tab:Show();
        end;

        return Tab;
    end;

    Tabbox.BoxOuter, Tabbox.BoxInner = BoxOuter, BoxInner;
    table.insert(Library.Tops, Tabbox);
    self.Tabboxes[Info.Name or ''] = Tabbox;

    return Tabbox;
end;

function TabBase:AddLeftTabbox(Name)
    return self:AddTabbox({ Name = Name, Side = 1; });
end;

function TabBase:AddRightTabbox(Name)
    return self:AddTabbox({ Name = Name, Side = 2; });
end;

function Library:Flash(Element)
    local Label = Element.FlashLabel;
    if not Label or not Label.Parent then return end;

    local Box = rawget(Element.Groupbox, 'Show');
    if Box then Element.Groupbox:Show() end;

    task.delay(0.2, function()
        if not Label.Parent or Library.Unloaded then return end;

        local Page = Label:FindFirstAncestorOfClass('ScrollingFrame');

        if Page then
            Page.CanvasPosition = Vector2.new(0, math.max(Page.CanvasPosition.Y + Label.AbsolutePosition.Y - Page.AbsolutePosition.Y - 20, 0));
        end;

        local Token = (Library._flash[Label] or 0) + 1;
        local Base = Library._flashBase[Label] or Label.TextColor3;

        Library._flash[Label] = Token;
        Library._flashBase[Label] = Base;

        Library:Tween(Label, { TextColor3 = Library.AccentColor }, 0.25);

        task.delay(0.7, function()
            if Library._flash[Label] ~= Token then return end;

            Library:Tween(Label, { TextColor3 = Base }, 0.6);
            Library._flash[Label] = nil;
            Library._flashBase[Label] = nil;
        end);
    end);
end;

function WindowBase:AddResult(Text, Tab, Element)
    local Path = Tab.Parent and (Tab.Parent.Name .. ' > ' .. Tab.Name) or Tab.Name;

    local Row = Library:Create('Frame', {
        Active = true;
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 0, 20);
        ZIndex = 4;
        Parent = self.Results;
    });

    Library:AddToRegistry(Row, { BackgroundColor3 = 'MainColor'; BackgroundTransparency = 'PanelTransparency'; BorderColor3 = 'OutlineColor' });

    Library:CreateLabel({
        Position = UDim2.fromOffset(6, 0);
        Size = UDim2.new(0.6, -6, 1, 0);
        Text = Text;
        TextSize = 14;
        TextTruncate = Enum.TextTruncate.AtEnd;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = Row;
    });

    local PathLabel = Library:CreateLabel({
        AnchorPoint = Vector2.new(1, 0);
        Position = UDim2.new(1, -6, 0, 0);
        Size = UDim2.new(0.4, -6, 1, 0);
        Text = Path;
        TextSize = 14;
        TextTruncate = Enum.TextTruncate.AtEnd;
        TextXAlignment = Enum.TextXAlignment.Right;
        ZIndex = 5;
        Parent = Row;
    });

    PathLabel.TextColor3 = Library.AccentColor;
    Library.Registry[PathLabel].TextColor3 = 'AccentColor';

    Library:OnHighlight(Row, Row, { BorderColor3 = 'AccentColor' }, { BorderColor3 = 'OutlineColor' });

    Row.InputBegan:Connect(function(Input)
        if Library:IsClick(Input, Row) then
            Tab:ShowTab();
            Library:Flash(Element);
        end;
    end);
end;

function Library:Search(Query, Window)
    Window = Window or Library.Window;
    if not Window or not Window.Results then return end;

    Query = Query:lower();

    local Results, Page = Window.Results, Window.CurrentTab and Window.CurrentTab.Page;

    for _, Child in ipairs(Results:GetChildren()) do
        if Child:IsA('GuiObject') then Child:Destroy() end;
    end;

    Results.Visible = Query ~= '';
    if Page then Page.Visible = Query == '' end;

    if Query == '' then return end;

    local Count = 0;

    for _, Element in ipairs(Library.Searchables) do
        local Tab = Element.Top and Element.Top.Tab;

        if Tab and Tab.Window == Window and Element.Visible and Element.SearchText:lower():find(Query, 1, true) then
            Count = Count + 1;
            if Count > 60 then break end;

            Window:AddResult((Element.SearchText:gsub('<[^>]+>', '')), Tab, Element);
        end;
    end;

    if Count == 0 then
        Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 20);
            Text = 'No results';
            TextSize = 14;
            ZIndex = 4;
            Parent = Results;
        });
    end;
end;

Library.ESPPreviews = {};

function Library:ESPTint(Config)
    local Rainbow = Config.Rainbow;

    if not (Rainbow and Rainbow.Enabled) then return nil end;

    local Hue = (os.clock() * (Rainbow.Speed or 0.15)) % 1;

    if Rainbow.Mode == 'Pastel' then return Color3.fromHSV(Hue, 0.55, 0.9) end;

    return Color3.fromHSV(Hue, 1, 1);
end;

function Library:CreateESP(Parent, Config, Base)
    Base = Base or 0;

    local Drawer = { Shown = false };
    local E, All, Memo, Empty = {}, {}, {}, {};
    local Black, White = Color3.new(0, 0, 0), Color3.new(1, 1, 1);
    local Miter, Inner = Enum.LineJoinMode.Miter, Enum.BorderStrokePosition.Inner;
    local Bar = 2;
    local Face = Library:LoadFont('ProggyClean') or Library.FontFace;
    local Sharp = Library.PixelFonts.ProggyClean or 12;

    local function Crisp(Size)
        return Sharp * math.max(1, math.floor(Size / Sharp + 0.5));
    end;

    local function Put(Obj, Name, Value)
        local Seen = Memo[Obj];

        if not Seen then
            Seen = {};
            Memo[Obj] = Seen;
        end;

        if Seen[Name] ~= Value then
            Seen[Name] = Value;
            Obj[Name] = Value;
        end;
    end;

    local function Make(Class, Props, Z, Group)
        local Obj = Instance.new(Class);

        for Key, Value in next, Props do Obj[Key] = Value end;

        if Z then
            Obj.ZIndex = Base + Z;
            Obj.Visible = false;
            Obj.BorderSizePixel = 0;
            table.insert(All, Obj);
            table.insert(Group.Frames, Obj);
        end;

        Obj.Parent = Props.Parent or Parent;

        return Obj;
    end;

    local function Group(Name, Build)
        local G = E[Name];

        if not G then
            G = { Frames = {} };
            E[Name] = G;
            Build(G);
        end;

        G.On = true;

        return G;
    end;

    local function Off(G)
        if G and G.On then
            G.On = false;

            for _, Frame in ipairs(G.Frames) do Put(Frame, 'Visible', false) end;
        end;
    end;

    local function Words(G)
        G.Label = Make('TextLabel', {
            BackgroundTransparency = 1;
            FontFace = Face;
            Text = '';
            TextColor3 = White;
            TextStrokeColor3 = Black;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Top;
        }, 5, G);

        G.Gradient = Make('UIGradient', { Enabled = false; Parent = G.Label });
    end;

    local Advance = {};

    local function FastWidth(G, Text, Pixel)
        local Step = Advance[Pixel];

        if Step == nil then
            G.Label.TextSize = Pixel;
            G.Label.Text = 'iiii';

            local Narrow = G.Label.TextBounds.X;

            G.Label.Text = 'WWWW';
            Step = Narrow == G.Label.TextBounds.X and Narrow / 4 or false;
            Advance[Pixel] = Step;
        end;

        if Step and not Text:find('[\128-\255]') then return math.ceil(#Text * Step) end;
    end;

    local function Say(G, Text, Pixel, Mode, X, Y)
        local Key = Text .. '\0' .. Pixel;

        if G.Key ~= Key then
            G.Key = Key;

            local Fast = FastWidth(G, Text, Pixel);

            G.Label.Text = Text;
            G.Label.TextSize = Pixel;
            G.Width = Fast or math.ceil(G.Label.TextBounds.X);
        end;

        local Left = Mode == 'Center' and X - math.floor(G.Width / 2) or Mode == 'Left' and X - G.Width or X;

        Put(G.Label, 'Size', UDim2.fromOffset(G.Width, Pixel + 2));
        Put(G.Label, 'Position', UDim2.fromOffset(Left, Y));
        Put(G.Label, 'Visible', true);
    end;

    local Spreads, SpreadColor, SpreadSequence = {}, nil, nil;

    local function Spread(Color)
        if Color ~= SpreadColor then
            local Key = Color:ToHex();

            SpreadSequence = Spreads[Key];

            if not SpreadSequence then
                SpreadSequence = ColorSequence.new(Color, Color:Lerp(White, 0.5));
                Spreads[Key] = SpreadSequence;
            end;

            SpreadColor = Color;
        end;

        return SpreadSequence;
    end;

    local function Tone(Obj, Prop, Gradient, Tint, Color, Sequence, Mine)
        if Mine and not Tint then
            if Sequence then
                Put(Gradient, 'Enabled', true);
                Put(Gradient, 'Color', Spread(Mine));
                Put(Obj, Prop, White);
            else
                Put(Gradient, 'Enabled', false);
                Put(Obj, Prop, Mine);
            end;
        elseif Sequence and not Tint then
            Put(Gradient, 'Enabled', true);
            Put(Gradient, 'Color', Sequence);
            Put(Obj, Prop, White);
        else
            Put(Gradient, 'Enabled', false);
            Put(Obj, Prop, Tint or Color or White);
        end;
    end;

    local function Line(Frame, From, To)
        local Mid, Delta = (From + To) / 2, To - From;

        Put(Frame, 'Position', UDim2.fromOffset(math.floor(Mid.X + 0.5), math.floor(Mid.Y + 0.5)));
        Put(Frame, 'Size', UDim2.fromOffset(math.ceil(Delta.Magnitude), Frame.Size.Y.Offset));
        Put(Frame, 'Rotation', math.deg(math.atan2(Delta.Y, Delta.X)));
    end;

    local HealthRamp = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0)),
    });

    local function SampleSequence(Sequence, Time)
        local Points = Sequence.Keypoints;

        for Index = 1, #Points - 1 do
            local From, To = Points[Index], Points[Index + 1];

            if Time <= To.Time then
                local Span = To.Time - From.Time;

                return From.Value:Lerp(To.Value, Span > 0 and (Time - From.Time) / Span or 0);
            end;
        end;

        return Points[#Points].Value;
    end;

    local function Shade(G, Cfg, Tint, Mine)
        Tone(G.Label, 'TextColor3', G.Gradient, Tint, Cfg.Color, Cfg.Sequence, Mine);
        Put(G.Label, 'TextTransparency', Cfg.Transparency or 0);
        Put(G.Label, 'TextStrokeTransparency', Cfg.Outline ~= false and (Cfg.Transparency or 0) or 1);
    end;

    function Drawer:Draw(Info)
        local Pixel = Crisp(Config.TextSize or 12);
        local Row = Pixel + 2;
        local Tint = Library:ESPTint(Config);
        local Boxes, Names, Dist = Config.Boxes or Empty, Config.Names or Empty, Config.Distance or Empty;
        local Health, Trace, Tags = Config.Health or Empty, Config.Tracers or Empty, Config.Tags or Empty;
        local Override = Tint or Info.Color;
        local Has = Info.Health ~= nil and Info.MaxHealth ~= nil;
        local X, Y, W, H = Info.X, Info.Y, Info.W, Info.H;
        local CX, CY = X + math.floor(W / 2), Y + math.floor(H / 2);
        local Edge = 0;

        Drawer.Shown = true;

        if Boxes.Enabled then
            local G = Group('Box', function(G)
                G.Fill = Make('Frame', { BackgroundColor3 = White }, 1, G);
                G.FillGradient = Make('UIGradient', { Rotation = 90; Enabled = false; Parent = G.Fill });
                G.Out = Make('Frame', { BackgroundTransparency = 1 }, 2, G);
                Make('UIStroke', { Color = Black; LineJoinMode = Miter; Parent = G.Out });
                G.In = Make('Frame', { BackgroundTransparency = 1 }, 2, G);
                Make('UIStroke', { Color = Black; LineJoinMode = Miter; BorderStrokePosition = Inner; Parent = G.In });
                G.Main = Make('Frame', { BackgroundTransparency = 1 }, 3, G);
                G.Stroke = Make('UIStroke', { LineJoinMode = Miter; BorderStrokePosition = Inner; Parent = G.Main });
                G.Gradient = Make('UIGradient', { Rotation = 90; Enabled = false; Parent = G.Stroke });
            end);

            local T = math.max(Boxes.Thickness or 1, 1);
            local Ring = Boxes.Outline ~= false;

            Edge = Ring and 1 or 0;

            Put(G.Main, 'Visible', true);
            Put(G.Main, 'Position', UDim2.fromOffset(X, Y));
            Put(G.Main, 'Size', UDim2.fromOffset(W, H));
            Put(G.Stroke, 'Thickness', T);
            Put(G.Stroke, 'Transparency', Boxes.Transparency or 0);
            Tone(G.Stroke, 'Color', G.Gradient, Tint, Boxes.Color, Boxes.Sequence, Info.Color);

            Put(G.Out, 'Visible', Ring);
            Put(G.In, 'Visible', Ring);

            if Ring then
                Put(G.Out, 'Position', UDim2.fromOffset(X, Y));
                Put(G.Out, 'Size', UDim2.fromOffset(W, H));
                Put(G.In, 'Position', UDim2.fromOffset(X + T, Y + T));
                Put(G.In, 'Size', UDim2.fromOffset(math.max(W - 2 * T, 0), math.max(H - 2 * T, 0)));
            end;

            Put(G.Fill, 'Visible', Boxes.FillEnabled == true);

            if Boxes.FillEnabled then
                Put(G.Fill, 'Position', UDim2.fromOffset(X, Y));
                Put(G.Fill, 'Size', UDim2.fromOffset(W, H));
                Put(G.Fill, 'BackgroundTransparency', Boxes.FillTransparency or 0.6);
                Tone(G.Fill, 'BackgroundColor3', G.FillGradient, Tint, Boxes.FillColor, Boxes.FillSequence, Info.Color);
            end;
        else
            Off(E.Box);
        end;

        local Level = Drawer.Level;

        if Has then
            local Percent = math.clamp(Info.Health / (Info.MaxHealth > 0 and Info.MaxHealth or 100), 0, 1);

            if Health.Lerp then
                Drawer.Level = (Drawer.Level or Percent) + (Percent - (Drawer.Level or Percent)) * 0.18;
            else
                Drawer.Level = Percent;
            end;

            Level = Drawer.Level;
        end;

        local Up, Down = Y - Edge - 2, Y + H + Edge + 2;
        local ShowBar = Has and Health.Enabled and (Health.Mode == 'Health Bar' or Health.Mode == 'Both');
        local ShowText = Has and Health.Enabled and (Health.Mode == 'Health Text' or Health.Mode == 'Both');
        local Side = Health.Side or 'Left';

        if ShowBar then
            local G = Group('Bar', function(G)
                G.Back = Make('Frame', { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }, 2, G);
                G.Stroke = Make('UIStroke', { Color = Black; LineJoinMode = Miter; Parent = G.Back });
                G.Fill = Make('Frame', { BackgroundColor3 = White; ClipsDescendants = true; Parent = G.Back }, 3, G);
                G.Gradient = Make('UIGradient', { Enabled = false; Parent = G.Fill });
                G.Ramp = Make('Frame', { BackgroundColor3 = White; Parent = G.Fill }, 4, G);
                G.RampGradient = Make('UIGradient', { Color = HealthRamp; Parent = G.Ramp });
            end);

            local Gap = Edge + 3;
            local BX, BY, BW, BH;

            if Side == 'Right' then
                BX, BY, BW, BH = X + W + Gap, Y, Bar, H;
            elseif Side == 'Top' then
                BX, BY, BW, BH = X, Y - Gap - Bar, W, Bar;
                Up = BY - 2;
            elseif Side == 'Bottom' then
                BX, BY, BW, BH = X, Y + H + Gap, W, Bar;
                Down = BY + Bar + 2;
            else
                BX, BY, BW, BH = X - Gap - Bar, Y, Bar, H;
            end;

            Put(G.Back, 'Visible', true);
            Put(G.Fill, 'Visible', true);
            Put(G.Back, 'Position', UDim2.fromOffset(BX, BY));
            Put(G.Back, 'Size', UDim2.fromOffset(BW, BH));
            local Ramped = Health.HealthBased and not Tint;
            local Spanned = Ramped and Health.Sequence and true or false;
            local Part = math.max(Level, 0.001);

            Put(G.Stroke, 'Enabled', Health.Outline ~= false);
            Put(G.Stroke, 'Color', Health.OutlineColor or Black);
            Put(G.Stroke, 'Transparency', Health.OutlineTransparency or Health.Transparency or 0);
            Put(G.Fill, 'BackgroundTransparency', Spanned and 1 or (Health.Transparency or 0));
            Put(G.Ramp, 'Visible', Spanned);
            Put(G.Ramp, 'BackgroundTransparency', Health.Transparency or 0);

            if Side == 'Top' or Side == 'Bottom' then
                Put(G.Fill, 'Position', UDim2.fromScale(0, 0));
                Put(G.Fill, 'Size', UDim2.fromScale(Level, 1));
                Put(G.Gradient, 'Rotation', 0);
                Put(G.Gradient, 'Offset', Vector2.new(1 - Level, 0));
                Put(G.Ramp, 'Position', UDim2.fromScale(0, 0));
                Put(G.Ramp, 'Size', UDim2.fromScale(1 / Part, 1));
                Put(G.RampGradient, 'Rotation', 0);
            else
                Put(G.Fill, 'Position', UDim2.fromScale(0, 1 - Level));
                Put(G.Fill, 'Size', UDim2.fromScale(1, Level));
                Put(G.Gradient, 'Rotation', -90);
                Put(G.Gradient, 'Offset', Vector2.new(0, 1 - Level));
                Put(G.Ramp, 'Position', UDim2.fromScale(0, -(1 - Level) / Part));
                Put(G.Ramp, 'Size', UDim2.fromScale(1, 1 / Part));
                Put(G.RampGradient, 'Rotation', -90);
            end;

            Tone(G.Fill, 'BackgroundColor3', G.Gradient, Tint, Ramped and SampleSequence(HealthRamp, Level) or Health.Color or Color3.new(0, 1, 0), not Health.HealthBased and Health.Sequence or nil);
        else
            Off(E.Bar);
        end;

        if ShowText then
            local G = Group('HealthText', Words);
            local Where = Health.TextSide or 'Bottom';
            local Beside = Edge + ((ShowBar and Side == Where) and Bar + 3 or 0) + 2;

            Put(G.Label, 'TextTransparency', Health.Transparency or 0);
            Put(G.Label, 'TextStrokeColor3', Health.OutlineColor or Black);
            Put(G.Label, 'TextStrokeTransparency', Health.Outline ~= false and (Health.OutlineTransparency or Health.Transparency or 0) or 1);

            if Health.HealthBased and not Tint then
                Put(G.Gradient, 'Enabled', false);
                Put(G.Label, 'TextColor3', SampleSequence(HealthRamp, Level));
            else
                Tone(G.Label, 'TextColor3', G.Gradient, Tint, Health.Color or Color3.new(0, 1, 0), Health.Sequence);
            end;

            local Text = tostring(math.floor(Info.Health));

            if Where == 'Top' then
                Up = Up - Row;
                Say(G, Text, Pixel, 'Center', CX, Up);
                Up = Up - 2;
            elseif Where == 'Left' then
                Say(G, Text, Pixel, 'Left', X - Beside, CY - math.floor(Row / 2));
            elseif Where == 'Right' then
                Say(G, Text, Pixel, 'Right', X + W + Beside, CY - math.floor(Row / 2));
            else
                Say(G, Text, Pixel, 'Center', CX, Down);
                Down = Down + Row;
            end;
        else
            Off(E.HealthText);
        end;

        if Names.Enabled then
            local G = Group('Name', Words);
            local Format = Names.Format;
            local Display = Info.DisplayName or Info.Name;

            Shade(G, Names, Tint, Info.Color);

            Up = Up - Row;
            Say(G, Format == 'Username' and Info.Name or Format == 'Both' and (Display .. ' (@' .. Info.Name .. ')') or Display, Pixel, 'Center', CX, Up);
        else
            Off(E.Name);
        end;

        if Tags.Enabled and Info.Tag then
            local G = Group('Tag', Words);

            Shade(G, Tags, Tint, Info.Color);

            Up = Up - Row;
            Say(G, Info.Tag, Pixel, 'Center', CX, Up);
        else
            Off(E.Tag);
        end;

        if Dist.Enabled and Info.Distance then
            local G = Group('Distance', Words);
            local Text = math.floor(Info.Distance) .. 'm';

            Shade(G, Dist, Tint, Info.Color);
            Say(G, Dist.Brackets and ('[' .. Text .. ']') or Text, Pixel, 'Center', CX, Down);
        else
            Off(E.Distance);
        end;

        if Trace.Enabled and Info.From then
            local G = Group('Tracer', function(G)
                G.Main = Make('Frame', { AnchorPoint = Vector2.new(0.5, 0.5); BackgroundColor3 = White; Size = UDim2.fromOffset(0, 1) }, 2, G);
                G.Gradient = Make('UIGradient', { Enabled = false; Parent = G.Main });
                G.Stroke = Make('UIStroke', { ApplyStrokeMode = Enum.ApplyStrokeMode.Border; BorderStrokePosition = Enum.BorderStrokePosition.Outer; Color = Black; Thickness = 1; Parent = G.Main });
            end);

            Put(G.Main, 'Visible', true);
            Put(G.Main, 'BackgroundTransparency', Trace.Transparency or 0);
            Put(G.Stroke, 'Enabled', Trace.Outline ~= false);
            Put(G.Stroke, 'Color', Trace.OutlineColor or Black);
            Put(G.Stroke, 'Transparency', Trace.OutlineTransparency or Trace.Transparency or 0);
            Tone(G.Main, 'BackgroundColor3', G.Gradient, Override, Trace.Color, Trace.Sequence);
            Line(G.Main, Info.From, Info.To);
        else
            Off(E.Tracer);
        end;
    end;

    function Drawer:Hide()
        if not Drawer.Shown then return end;

        Drawer.Shown = false;

        for _, G in next, E do Off(G) end;
    end;

    function Drawer:Destroy()
        for _, Obj in ipairs(All) do Obj:Destroy() end;

        table.clear(All);
        table.clear(E);
        table.clear(Memo);
    end;

    Drawer.E = E;

    return Drawer;
end;

function Library:ESPPreview(Info)
    Info = Info or {};

    if Info.Visible == nil and Toggles.UI_ESPPreview then
        Info.Visible = Toggles.UI_ESPPreview.Value;
    end;

    Library.ESPCount = (Library.ESPCount or 0) + 1;

    local Id = 'ESPPreview' .. Library.ESPCount;
    local White = Color3.new(1, 1, 1);

    local Preview = { Tab = Info.Tab; Shown = Info.Visible ~= false; Yaw = Info.Yaw or 0.4; Pitch = Info.Pitch or 0.08; AnimateHealth = Info.AnimateHealth ~= false; HealthPeriod = Info.HealthPeriod or 7; };

    local function Defaults()
        return {
            TextSize = 12;
            Boxes = { Enabled = true; Outline = true; Thickness = 1; Color = White; Sequence = false; Transparency = 0; FillEnabled = false; FillColor = White; FillSequence = false; FillTransparency = 0.6 };
            Names = { Enabled = true; Outline = true; Format = 'Display Name'; Color = White; Sequence = false; Transparency = 0 };
            Health = { Enabled = true; Mode = 'Health Bar'; Side = 'Left'; TextSide = 'Bottom'; HealthBased = false; Lerp = false; Outline = true; Color = Color3.new(0, 1, 0); Sequence = false; Transparency = 0 };
            Distance = { Enabled = true; Outline = true; Brackets = false; Color = White; Sequence = false; Transparency = 0 };
            Tags = { Enabled = true; Outline = true; Color = White; Sequence = false; Transparency = 0 };
            Tracers = { Enabled = false; Outline = true; Color = White; Sequence = false; Transparency = 0; Origin = 'Bottom'; Target = 'Torso' };
            Skeleton = { Enabled = false; Color = White };
            Chams = { Enabled = false; Color = White; Transparency = 0; Material = 'SmoothPlastic' };
        };
    end;

    local Cfg = Info.Config or Defaults();
    local Empty = {};

    Preview.Config = Cfg;
    Preview.Sample = { Name = 'player', DisplayName = 'Player', Tag = '[Tag]', Health = 100, MaxHealth = 100, Distance = 12 };

    for Key, Value in next, Info.Sample or {} do Preview.Sample[Key] = Value end;

    local Title = 22;
    local Pad = 4;
    local Width = Info.Size and Info.Size.X or 340;
    local Height = Info.Size and Info.Size.Y or 460;
    local VW, VH = Width - 2 * Pad, Height - Title - 1 - Pad;
    local Screen = Library:Viewport() / Library.Scale.Scale;
    local At = Info.Position or Vector2.new(Screen.X - Width - 20, 80);

    local Outer = Library:Create('Frame', {
        Active = true;
        BackgroundColor3 = Library.MainColor;
        BorderSizePixel = 0;
        Position = Library:KeepOnScreen(At, Vector2.new(Width, Height));
        Size = UDim2.fromOffset(Width, Height);
        Visible = false;
        ZIndex = 60;
        Parent = Library.Root;
    });

    Library:AddToRegistry(Outer, { BackgroundColor3 = 'MainColor' });
    Library:Outline(Outer, 4);

    local TitleLabel = Library:CreateLabel({
        Position = UDim2.fromOffset(8, 0);
        Size = UDim2.new(1, -34, 0, Title);
        Text = Info.Title or 'ESP Preview';
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 61;
        Parent = Outer;
    });

    local Close = Library:CreateLabel({
        Active = true;
        Position = UDim2.new(1, -Title, 0, 0);
        Size = UDim2.fromOffset(Title, Title);
        Text = 'X';
        TextColor3 = Library.RiskColor;
        TextSize = 14;
        ZIndex = 61;
        Parent = Outer;
    });

    Library.Registry[Close].TextColor3 = 'RiskColor';

    local Line = Library:Create('Frame', {
        BackgroundColor3 = Library.OutlineColor;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(0, Title);
        Size = UDim2.new(1, 0, 0, 1);
        ZIndex = 61;
        Parent = Outer;
    });

    Library:AddToRegistry(Line, { BackgroundColor3 = 'OutlineColor' });

    local Grid = Library:Create('Frame', {
        BackgroundColor3 = Color3.fromRGB(70, 72, 80);
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(Pad, Title + 1);
        Size = UDim2.fromOffset(VW, VH);
        ZIndex = 62;
        Parent = Outer;
    });


    for At = 20, math.max(VW, VH), 20 do
        for _, Vertical in ipairs({ true, false }) do
            if At < (Vertical and VW or VH) then
                local Cell = Library:Create('Frame', {
                    BackgroundColor3 = White;
                    BackgroundTransparency = 0.9;
                    BorderSizePixel = 0;
                    Position = Vertical and UDim2.fromOffset(At, 0) or UDim2.fromOffset(0, At);
                    Size = Vertical and UDim2.new(0, 1, 1, 0) or UDim2.new(1, 0, 0, 1);
                    ZIndex = 63;
                    Parent = Grid;
                });

            end;
        end;
    end;

    local Viewport = Library:Create('ViewportFrame', {
        Active = true;
        Ambient = Color3.fromRGB(85, 85, 92);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LightColor = Color3.fromRGB(215, 212, 206);
        LightDirection = Vector3.new(0.5, -0.7, -1);
        Position = UDim2.fromOffset(Pad, Title + 1);
        Size = UDim2.fromOffset(VW, VH);
        ZIndex = 64;
        Parent = Outer;
    });

    local BodyColor = Info.BodyColor or Color3.fromRGB(163, 162, 165);
    local Model = Instance.new('Model');
    local Bevel = 0.09;

    local function Piece(Parent, Shape, Size, At)
        local Part = Instance.new('Part');

        Part.Shape = Shape;
        Part.Anchored = true;
        Part.Color = BodyColor;
        Part.Material = Enum.Material.SmoothPlastic;
        Part.Size = Size;
        Part.CFrame = At;
        Part.Parent = Parent;
    end;

    local function Limb(Name, Size, Center)
        local Group = Instance.new('Model');
        local Dims = { Size.X, Size.Y, Size.Z };
        local Half = { Dims[1] / 2 - Bevel, Dims[2] / 2 - Bevel, Dims[3] / 2 - Bevel };
        local Turn = { CFrame.identity, CFrame.Angles(0, 0, math.pi / 2), CFrame.Angles(0, math.pi / 2, 0) };

        Group.Name = Name;

        for Axis = 1, 3 do
            local Cut = {};

            for Side = 1, 3 do Cut[Side] = Dims[Side] - (Side == Axis and 0 or 2 * Bevel) end;

            Piece(Group, Enum.PartType.Block, Vector3.new(Cut[1], Cut[2], Cut[3]), CFrame.new(Center));

            local A, B = Axis % 3 + 1, (Axis + 1) % 3 + 1;

            for _, SA in ipairs({ -1, 1 }) do
                for _, SB in ipairs({ -1, 1 }) do
                    local At = { 0, 0, 0 };

                    At[A], At[B] = SA * Half[A], SB * Half[B];

                    Piece(Group, Enum.PartType.Cylinder, Vector3.new(Dims[Axis] - 2 * Bevel, 2 * Bevel, 2 * Bevel), CFrame.new(Center + Vector3.new(At[1], At[2], At[3])) * Turn[Axis]);
                end;
            end;
        end;

        for _, SX in ipairs({ -1, 1 }) do
            for _, SY in ipairs({ -1, 1 }) do
                for _, SZ in ipairs({ -1, 1 }) do
                    Piece(Group, Enum.PartType.Ball, Vector3.new(2 * Bevel, 2 * Bevel, 2 * Bevel), CFrame.new(Center + Vector3.new(SX * Half[1], SY * Half[2], SZ * Half[3])));
                end;
            end;
        end;

        Group.Parent = Model;
    end;

    Limb('Torso', Vector3.new(2, 2, 1), Vector3.new(0, 0, 0));
    Limb('Left Arm', Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0));
    Limb('Right Arm', Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0));
    Limb('Left Leg', Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0));
    Limb('Right Leg', Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0));

    Piece(Model, Enum.PartType.Block, Vector3.new(2, 1, 1), CFrame.new(0, 1.5, 0));

    local Head = Model:FindFirstChildWhichIsA('Part');
    local Mesh = Instance.new('SpecialMesh');

    Head.Name = 'Head';
    Mesh.MeshType = Enum.MeshType.Head;
    Mesh.Scale = Vector3.new(1.25, 1.25, 1.25);
    Mesh.Parent = Head;

    Model.Parent = Viewport;

    local Pivot = Model:GetPivot();
    local Center = Vector3.new(0, -0.5, 0);
    local Distance = 9.5;
    local Camera = Instance.new('Camera');

    local function Aim()
        Camera.CFrame = CFrame.lookAt(Center + Vector3.new(0, 0, Distance), Center);
    end;

    Camera.FieldOfView = 50;
    Aim();
    Camera.Parent = Viewport;
    Viewport.CurrentCamera = Camera;

    local Tan = math.tan(math.rad(Camera.FieldOfView / 2));

    local function Project(Point)
        local Local = Camera.CFrame:PointToObjectSpace(Point);
        local Depth = -Local.Z;

        return Vector2.new((Local.X / (Depth * Tan * VW / VH) + 1) / 2 * VW, (1 - Local.Y / (Depth * Tan)) / 2 * VH);
    end;

    local Corners = {};

    for _, X in ipairs({ -1, 1 }) do
        for _, Y in ipairs({ -1, 1 }) do
            for _, Z in ipairs({ -1, 1 }) do
                table.insert(Corners, Vector3.new(2 * X, -0.5 + 2.5 * Y, 0.5 * Z));
            end;
        end;
    end;

    local Bones = {
        { Vector3.new(0, 1.5, 0), Vector3.new(0, -1, 0) },
        { Vector3.new(-1.5, 1, 0), Vector3.new(1.5, 1, 0) },
        { Vector3.new(-1.5, 1, 0), Vector3.new(-1.5, -1, 0) },
        { Vector3.new(1.5, 1, 0), Vector3.new(1.5, -1, 0) },
        { Vector3.new(-0.5, -1, 0), Vector3.new(0.5, -1, 0) },
        { Vector3.new(-0.5, -1, 0), Vector3.new(-0.5, -3, 0) },
        { Vector3.new(0.5, -1, 0), Vector3.new(0.5, -3, 0) },
    };

    local Overlay = Library:Create('Frame', {
        BackgroundTransparency = 1;
        ClipsDescendants = true;
        Size = UDim2.fromScale(1, 1);
        ZIndex = 65;
        Parent = Viewport;
    });

    local Drawer = Library:CreateESP(Overlay, Cfg, 65);
    local Lines = {};

    for Index = 1, #Bones do
        Lines[Index] = Library:Create('Frame', { AnchorPoint = Vector2.new(0.5, 0.5); BackgroundColor3 = White; BorderSizePixel = 0; Visible = false; ZIndex = 66; Parent = Overlay });
    end;

    local Pose, Rect = nil, nil;

    local BodyBase, ChamsSeen, BodyTextures = {}, {}, {};

    local function ClearTextures()
        for _, Texture in ipairs(BodyTextures) do Texture:Destroy() end;

        table.clear(BodyTextures);
    end;

    local function ApplyChams(Chams)
        local Wrapped = Chams.Enabled == true and Chams.Content ~= nil;

        if ChamsSeen.Enabled == (Chams.Enabled == true) and ChamsSeen.Color == Chams.Color
            and ChamsSeen.Transparency == Chams.Transparency and ChamsSeen.Material == Chams.Material
            and ChamsSeen.Tag == Chams.Tag and ChamsSeen.Wrapped == Wrapped then
            return;
        end;

        ChamsSeen.Enabled, ChamsSeen.Color = Chams.Enabled == true, Chams.Color;
        ChamsSeen.Transparency, ChamsSeen.Material = Chams.Transparency, Chams.Material;
        ChamsSeen.Tag, ChamsSeen.Wrapped = Chams.Tag, Wrapped;

        local Ok, Material = pcall(function() return Enum.Material[Chams.Material or 'SmoothPlastic'] end);

        ClearTextures();

        for _, Part in ipairs(Model:GetDescendants()) do
            if Part:IsA('BasePart') then
                local Base = BodyBase[Part];

                if not Base then
                    Base = { Part.Color, Part.Material, Part.Transparency };
                    BodyBase[Part] = Base;
                end;

                if Chams.Enabled then
                    Part.Color, Part.Material, Part.Transparency = Chams.Color or White, Ok and Material or Base[2], Chams.Transparency or 0;
                else
                    Part.Color, Part.Material, Part.Transparency = Base[1], Base[2], Base[3];
                end;

                if Wrapped then
                    for _, Face in ipairs(Enum.NormalId:GetEnumItems()) do
                        local Texture = Instance.new('Texture');
                        local Tile = Chams.TileStuds or 3;

                        Texture.Face = Face;
                        Texture.StudsPerTileU = Tile;
                        Texture.StudsPerTileV = Tile;
                        Texture.TextureContent = Chams.Content;
                        Texture.Parent = Part;

                        table.insert(BodyTextures, Texture);
                    end;
                end;
            end;
        end;
    end;

    function Preview:Draw()
        if not Rect then return end;

        local Trace, Skeleton, Sample = Cfg.Tracers or Empty, Cfg.Skeleton or Empty, Preview.Sample;

        ApplyChams(Cfg.Chams or Empty);
        local From, To;

        if Trace.Origin == 'Top' then
            From = Vector2.new(VW / 2, 0);
        elseif Trace.Origin == 'Center' then
            From = Vector2.new(VW / 2, VH / 2);
        elseif Trace.Origin == 'Cursor' then
            From = (Library:MousePos() - Viewport.AbsolutePosition) / Library.Scale.Scale;
        else
            From = Vector2.new(VW / 2, VH);
        end;

        if Trace.Target == 'Head' then
            To = Project(Pose * Vector3.new(0, 1.5, 0));
        elseif Trace.Target == 'Bottom' then
            To = Vector2.new(Rect.X + math.floor(Rect.W / 2), Rect.Y + Rect.H);
        else
            To = Project(Pose * Vector3.new(0, 0, 0));
        end;

        local Now = Sample.Health;

        if Preview.AnimateHealth then
            Now = math.floor(Sample.MaxHealth * (0.5 + 0.5 * math.cos(os.clock() * math.pi * 2 / Preview.HealthPeriod)) + 0.5);
        end;

        Drawer:Draw({
            X = Rect.X; Y = Rect.Y; W = Rect.W; H = Rect.H;
            Name = Sample.Name; DisplayName = Sample.DisplayName; Tag = Sample.Tag; Color = Sample.Color;
            Health = Now; MaxHealth = Sample.MaxHealth; Distance = Sample.Distance;
            From = From; To = To;
        });

        local On = Skeleton.Enabled == true;

        for Index, Bone in ipairs(Bones) do
            local Frame = Lines[Index];

            if Frame.Visible ~= On then Frame.Visible = On end;

            if On then
                local From, To = Project(Pose * Bone[1]), Project(Pose * Bone[2]);
                local Mid, Delta = (From + To) / 2, To - From;

                Frame.BackgroundColor3 = Skeleton.Color or White;
                Frame.Position = UDim2.fromOffset(math.floor(Mid.X + 0.5), math.floor(Mid.Y + 0.5));
                Frame.Size = UDim2.fromOffset(math.ceil(Delta.Magnitude), 1);
                Frame.Rotation = math.deg(math.atan2(Delta.Y, Delta.X));
            end;
        end;
    end;

    function Preview:Redraw()
        Pose = CFrame.new(Center) * CFrame.Angles(Preview.Pitch, 0, 0) * CFrame.Angles(0, Preview.Yaw, 0) * CFrame.new(-Center);

        Model:PivotTo(Pose * Pivot);

        local MinX, MinY, MaxX, MaxY = math.huge, math.huge, -math.huge, -math.huge;

        for _, Corner in ipairs(Corners) do
            local Point = Project(Pose * Corner);

            MinX, MinY = math.min(MinX, Point.X), math.min(MinY, Point.Y);
            MaxX, MaxY = math.max(MaxX, Point.X), math.max(MaxY, Point.Y);
        end;

        local X, Y = math.floor(MinX + 0.5), math.floor(MinY + 0.5);

        Rect = { X = X, Y = Y, W = math.floor(MaxX + 0.5) - X, H = math.floor(MaxY + 0.5) - Y };
        Preview.Rect = Rect;

        Preview:Draw();
    end;

    function Preview:Set(Path, Value)
        local Group, Key = Path:match('^(%w+)%.(%w+)$');
        local Target = Group and Cfg[Group] or Cfg;

        Key = Key or Path;

        assert(type(Target) == 'table' and Target[Key] ~= nil, '[lib] unknown esp preview setting ' .. tostring(Path));

        Target[Key] = Value;
    end;

    function Preview:Link(Path, Idx)
        local Option = Toggles[Idx] or Options[Idx];

        assert(Option, '[lib] esp preview link: no option named ' .. tostring(Idx));

        local Stem = Option.Type == 'ColorPicker' and (Path:gsub('Color$', ''));

        local function Apply(Value, Sequence)
            if Stem then
                Preview:Set(Stem .. 'Color', Value);
                pcall(Preview.Set, Preview, Stem .. 'Sequence', Sequence or false);
                Preview:Set(Stem .. 'Transparency', Option.Transparency);
            else
                Preview:Set(Path, Value);
            end;
        end;

        local Before = Option.Changed;

        Option.Changed = function(Value, Sequence)
            Apply(Value, Sequence);
            if Before then Before(Value, Sequence) end;
        end;

        Apply(Option.Value, Stem and Option:GetGradient() or nil);

        return Preview;
    end;

    function Preview:SetRotation(Yaw, Pitch)
        Preview.Yaw, Preview.Pitch = Yaw, math.clamp(Pitch or 0, -Library.PreviewPitchLimit, Library.PreviewPitchLimit);
        Preview:Redraw();
    end;

    function Preview:SetVisible(Bool)
        Preview.Shown = not not Bool;

        local Switch = Toggles.UI_ESPPreview;

        if Switch and Switch.Value ~= Preview.Shown then Switch:SetValue(Preview.Shown) end;
    end;

    function Preview:Toggle()
        Preview:SetVisible(not Preview.Shown);
    end;

    function Preview:Destroy()
        Library.ESPPreviews[Preview] = nil;
        Library:UnbindRender(Id);
        Outer:Destroy();
    end;

    Library:MakeDraggable(Outer, function(Start)
        return (Start.Y - Outer.AbsolutePosition.Y) / Library.Scale.Scale <= Title and not Library:IsMouseOverFrame(Close, Start);
    end);

    Close.InputBegan:Connect(function(Input)
        if Library:IsTap(Input, Close) then Preview:SetVisible(false) end;
    end);

    local Rest = { Yaw = Preview.Yaw, Pitch = Preview.Pitch, Distance = Distance };
    local LastPress = 0;

    Viewport.InputBegan:Connect(function(Input)
        if not Library:IsPress(Input) or Library:Covered(Input, Viewport) then return end;

        if os.clock() - LastPress < 0.3 then
            LastPress = 0;
            Preview.Yaw, Preview.Pitch, Distance = Rest.Yaw, Rest.Pitch, Rest.Distance;
            Aim();
            Preview:Redraw();

            return;
        end;

        LastPress = os.clock();

        local Last = Library:MousePos(Input);

        Library:Drag(Input, function(Pos)
            local Turn = Vector2.new(Pos.X - Last.X, Pos.Y - Last.Y) * 0.016;

            Preview.Yaw, Preview.Pitch = Preview.Yaw + Turn.X, math.clamp(Preview.Pitch + Turn.Y, -Library.PreviewPitchLimit, Library.PreviewPitchLimit);
            Last = Pos;
            Preview:Redraw();
        end);
    end);

    Viewport.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseWheel then return end;

        Distance = math.clamp(Distance - Input.Position.Z * 0.8, 5, 16);
        Aim();
        Preview:Redraw();
    end);

    Library:BindRender(Id, function()
        local Home, Window = Preview.Tab, Library.Window;
        local Here = not Home or Window and Window.CurrentTab == (Home.Parent or Home) and (not Home.Parent or Home.Parent.ActiveSub == Home);

        Outer.Visible = Preview.Shown and Library.MenuOpen == true and Here;

        if Outer.Visible then Preview:Draw() end;
    end);

    Preview.Outer, Preview.Viewport, Preview.Model, Preview.TitleLabel, Preview.Close = Outer, Viewport, Model, TitleLabel, Close;

    Preview.Drawer, Preview.Lines = Drawer, Lines;

    Library.ESPPreviews[Preview] = true;

    for Path, Value in next, Info.Settings or {} do Preview:Set(Path, Value) end;

    Preview:Redraw();

    return Preview;
end;

function Library:RefreshSpecialDropdowns()
    if Library.Unloaded then return end;

    for _, Value in next, Options do
        if type(Value) == 'table' and (Value.Type == 'Dropdown' or Value.Type == 'List') and Value.SpecialType then
            Value:RefreshSpecial();
        end;
    end;
end;

local PlayersDirty = false;

local function OnPlayerChange()
    if PlayersDirty then return end;
    PlayersDirty = true;

    task.defer(function()
        PlayersDirty = false;
        Library:RefreshSpecialDropdowns();
    end);
end;

Library:GiveSignal(Svc.Players.PlayerAdded:Connect(OnPlayerChange));
Library:GiveSignal(Svc.Players.PlayerRemoving:Connect(OnPlayerChange));

getgenv().Library = Library;
return Library
