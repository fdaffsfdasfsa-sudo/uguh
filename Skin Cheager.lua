--[[
    YAYCAT SKIN CHEAGER - XENO EDITION (NO EXTERNAL LIB)
    Feito para rodar em executores com baixa UNC (Xeno, Solara, etc)
    Interface Nativa (Sem loadstring externo)
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- === CONFIGURAÇÕES & VARIÁVEIS ===
local targetInput = ""
local useLegacyR6 = false
local Favorites = {}
local FavoritesFile = "YayCatSkins_Favorites.json"

-- Auto Join Discord
task.spawn(function()
    pcall(function()
        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if req then
            req({
                Url = "http://127.0.0.1:6463/rpc?v=1",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json", ["Origin"] = "https://discord.com"},
                Body = HttpService:JSONEncode({
                    cmd = "INVITE_BROWSER",
                    args = {code = "JtVhF6U2Su"},
                    nonce = HttpService:GenerateGUID(false)
                })
            })
        end
    end)
end)

-- Carregar Favoritos
pcall(function()
    if isfile and isfile(FavoritesFile) then
        Favorites = HttpService:JSONDecode(readfile(FavoritesFile))
    end
end)

-- === FUNÇÕES LÓGICAS ===
local function Notify(title, msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = msg;
        Duration = 5;
    })
end

local function ApplySkin(target)
    local userId = nil
    if tonumber(target) then
        userId = tonumber(target)
    else
        pcall(function() userId = Players:GetUserIdFromNameAsync(target) end)
    end

    if not userId then
        Notify("Erro", "Usuário não encontrado!")
        return
    end

    local success, err = pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Resetar aparencia basica antes de aplicar para evitar bugs visuais
        if character:FindFirstChild("Humanoid") then character.Humanoid:RemoveAccessories() end

        if useLegacyR6 then
            local appearance = Players:GetCharacterAppearanceAsync(userId)
            if character then
                for _, v in pairs(character:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") or v:IsA("ShirtGraphic") then
                        v:Destroy()
                    end
                end
                if character:FindFirstChild("Head") and character.Head:FindFirstChild("face") then
                    character.Head.face:Destroy()
                end
                for _, v in pairs(appearance:GetChildren()) do
                    v.Parent = character
                end
            end
        else
            local description = Players:GetHumanoidDescriptionFromUserId(userId)
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ApplyDescription(description)
            end
        end
    end)

    if success then
        Notify("Sucesso", "Skin aplicada: " .. tostring(target))
    else
        Notify("Erro", "Falha ao aplicar skin.")
    end
end

-- === ANIMAÇÕES ===
local function AddButtonAnim(btn)
    local originalColor = btn.BackgroundColor3
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(math.min(originalColor.R*255+40, 255), math.min(originalColor.G*255+40, 255), math.min(originalColor.B*255+40, 255))}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = originalColor}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        local t = TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5})
        t:Play()
        t.Completed:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play() end)
    end)
end

-- === INTERFACE GRÁFICA (NATIVA) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YayCatUI_Xeno"
ScreenGui.ResetOnSpawn = false

-- Proteção de Parent
if gethui then
    ScreenGui.Parent = gethui()
elseif CoreGui then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.2 -- Fundo meio transparente
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BackgroundTransparency = 0.2
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame") -- Cobre a parte de baixo do corner
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleFix.BackgroundTransparency = 0.2
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "YayCat Skin Cheager"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() 
    -- Animação de Fechar
    local t = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
    t:Play()
    for _, v in pairs(MainFrame:GetDescendants()) do
        if v:IsA("GuiObject") then TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1}):Play() end
    end
    t.Completed:Wait()
    ScreenGui:Destroy() 
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 450, 0, 30)}):Play()
        MainFrame.ClipsDescendants = true
    else
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 450, 0, 300)})
        t:Play()
        t.Completed:Connect(function() MainFrame.ClipsDescendants = false end)
    end
end)

-- Container de Abas
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 35) -- Mudado para horizontal no topo
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabContainer.BackgroundTransparency = 0.3
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

-- Removido TabCorner antigo para ajustar ao novo layout ou ajustado
-- local TabCorner = Instance.new("UICorner") ... (Opcional, removendo para ficar clean no topo)

local TabFix = Instance.new("Frame")
TabFix.Size = UDim2.new(1, 0, 0, 5)
TabFix.Position = UDim2.new(0, 0, 1, -5) -- Fix na parte de baixo das abas
TabFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabFix.BackgroundTransparency = 0.3
TabFix.BorderSizePixel = 0
TabFix.Visible = false -- Desativado pois o design mudou
TabFix.Parent = TabContainer

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, 0, 1, -70) -- Ocupa o resto da tela abaixo das abas
Pages.Position = UDim2.new(0, 0, 0, 70)
Pages.BackgroundTransparency = 1
Pages.Parent = MainFrame

-- Função para criar Abas
local currentTab = nil
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 1, -4) -- Tamanho horizontal
    TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabBtn.BackgroundTransparency = 0.2
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 12
    TabBtn.Parent = TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = TabBtn
    
    local PageFrame = Instance.new("ScrollingFrame")
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false -- Começa invisivel
    PageFrame.ScrollBarThickness = 4
    PageFrame.Parent = Pages
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.Parent = PageFrame
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingLeft = UDim.new(0, 5)
    Padding.Parent = PageFrame
    
    TabBtn.MouseButton1Click:Connect(function()
        if currentTab then currentTab.Visible = false end
        PageFrame.Visible = true
        currentTab = PageFrame
    end)
    
    -- Layout automático para botões
    local list = TabContainer:FindFirstChild("UIListLayout") or Instance.new("UIListLayout", TabContainer)
    list.Padding = UDim.new(0, 5)
    list.FillDirection = Enum.FillDirection.Horizontal -- Horizontal
    list.HorizontalAlignment = Enum.HorizontalAlignment.Left
    local pad = TabContainer:FindFirstChild("UIPadding") or Instance.new("UIPadding", TabContainer)
    pad.PaddingLeft = UDim.new(0, 5)
    pad.PaddingTop = UDim.new(0, 2)
    
    AddButtonAnim(TabBtn)
    return PageFrame
end

-- === ELEMENTOS DA UI ===
local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.BackgroundTransparency = 0.2
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
    AddButtonAnim(Btn)
    return Btn
end

local function CreateInput(parent, placeholder, callback)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -10, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Box.BackgroundTransparency = 0.2
    Box.Text = ""
    Box.PlaceholderText = placeholder
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 12
    Box.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Box
    
    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
    return Box
end

local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BackgroundTransparency = 0.2
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Check = Instance.new("TextButton")
    Check.Size = UDim2.new(0, 25, 0, 25)
    Check.Position = UDim2.new(1, -30, 0.5, -12.5)
    Check.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(60, 60, 60)
    Check.Text = ""
    Check.Parent = Frame
    
    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 4)
    CheckCorner.Parent = Check
    
    local state = default
    Check.MouseButton1Click:Connect(function()
        state = not state
        Check.BackgroundColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- === CONSTRUINDO AS PÁGINAS ===

-- Lista de IDs Ricos (Movido para cima para uso na MainTab)
local RichIDs = {
    120132828, 49475623, 25247897, 13416513, 1615964, 23526635, 
    48669438, 6966378, 1563995, 20418400, 38376839, 17260230,
    1697238, 5318562, 1161416, 2609886, 19056396, 30403860
    , 1, 156, 2207291, 261, 339310190, 2021312016, 80254, 
    1288530, 961533, 1066925, 1670764, 87496, 6059601,
    2039659, 223439, 137326, 24163996, 367025, 1493588,
    611693, 16019842, 299645, 16135369, 12901
}

-- Página Principal
local MainTab = CreateTab("Principal")
if MainTab then MainTab.Visible = true; currentTab = MainTab end -- Selecionar primeira aba

local InputBox = CreateInput(MainTab, "Nick ou ID do Jogador", function(text)
    targetInput = text
end)

-- Container para botões lado a lado
local ActionContainer = Instance.new("Frame")
ActionContainer.Size = UDim2.new(1, -10, 0, 35)
ActionContainer.BackgroundTransparency = 1
ActionContainer.Parent = MainTab

local GenBtn = CreateButton(ActionContainer, "Gerar ID Raro", function()
    local randomId = RichIDs[math.random(1, #RichIDs)]
    if randomId then
        targetInput = tostring(randomId)
        InputBox.Text = targetInput
        Notify("Gerado", "ID na busca: " .. targetInput)
    end
end)
GenBtn.Size = UDim2.new(0.5, -5, 1, 0)

local ApplyBtn = CreateButton(ActionContainer, "Aplicar", function()
    if targetInput ~= "" then
        ApplySkin(targetInput)
    else
        Notify("Aviso", "Digite um Nick ou ID!")
    end
end)
ApplyBtn.Size = UDim2.new(0.5, -5, 1, 0)
ApplyBtn.Position = UDim2.new(0.5, 5, 0, 0)

-- Botão Visualizar na TitleBar
local PreviewBtn = Instance.new("TextButton")
PreviewBtn.Size = UDim2.new(0, 80, 0, 20)
PreviewBtn.Position = UDim2.new(1, -150, 0, 5) -- Ajustado para caber o Minimizar
PreviewBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PreviewBtn.Text = "Visualizar"
PreviewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PreviewBtn.Font = Enum.Font.GothamBold
PreviewBtn.TextSize = 10
PreviewBtn.Parent = TitleBar
local PVC = Instance.new("UICorner"); PVC.CornerRadius = UDim.new(0, 4); PVC.Parent = PreviewBtn
AddButtonAnim(PreviewBtn)

-- Preview Frame
local PreviewFrame = Instance.new("Frame")
PreviewFrame.Size = UDim2.new(0, 100, 0, 100)
PreviewFrame.Position = UDim2.new(1, -110, 0, 40)
PreviewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PreviewFrame.Visible = false
PreviewFrame.Parent = MainFrame
local PFC = Instance.new("UICorner"); PFC.CornerRadius = UDim.new(0, 8); PFC.Parent = PreviewFrame
local PreviewImage = Instance.new("ImageLabel")
PreviewImage.Size = UDim2.new(1, 0, 1, 0); PreviewImage.BackgroundTransparency = 1; PreviewImage.Parent = PreviewFrame

PreviewBtn.MouseButton1Click:Connect(function()
    if targetInput == "" then Notify("Erro", "Sem ID!"); return end
    local uid = tonumber(targetInput) or 1
    PreviewImage.Image = Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    PreviewFrame.Visible = not PreviewFrame.Visible
end)

-- Client Tab
local ClientTab = CreateTab("Client Side")

CreateToggle(ClientTab, "Modo R6 / Legacy", false, function(state)
    useLegacyR6 = state
end)

CreateButton(ClientTab, "Resetar Personagem", function()
    if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
end)

CreateButton(ClientTab, "Copiar Random Player", function()
    local players = Players:GetPlayers()
    local randomPlayer = players[math.random(1, #players)]
    if randomPlayer then
        targetInput = tostring(randomPlayer.UserId)
        InputBox.Text = targetInput
        Notify("Copiado", randomPlayer.Name)
    end
end)

-- Página Favoritos
local FavTab = CreateTab("Favoritos")
local favName = ""

CreateInput(FavTab, "Nome para Salvar", function(text)
    favName = text
end)

CreateButton(FavTab, "Salvar Skin Atual", function()
    if favName ~= "" and targetInput ~= "" then
        Favorites[favName] = targetInput
        if writefile then
            pcall(function() writefile(FavoritesFile, HttpService:JSONEncode(Favorites)) end)
        end
        Notify("Salvo", "Favorito salvo: " .. favName)
        -- Atualizar lista (Simples refresh recriando botões seria ideal, mas aqui vamos simplificar)
    else
        Notify("Erro", "Defina um nome e um alvo primeiro.")
    end
end)

local FavListContainer = Instance.new("Frame")
FavListContainer.Size = UDim2.new(1, -10, 0, 150)
FavListContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FavListContainer.BackgroundTransparency = 0.3
FavListContainer.Parent = FavTab
local FLC_Corner = Instance.new("UICorner"); FLC_Corner.CornerRadius = UDim.new(0, 6); FLC_Corner.Parent = FavListContainer
local FLC_Scroll = Instance.new("ScrollingFrame")
FLC_Scroll.Size = UDim2.new(1, -10, 1, -10)
FLC_Scroll.Position = UDim2.new(0, 5, 0, 5)
FLC_Scroll.BackgroundTransparency = 1
FLC_Scroll.Parent = FavListContainer
local FLC_Layout = Instance.new("UIListLayout"); FLC_Layout.Parent = FLC_Scroll; FLC_Layout.Padding = UDim.new(0, 2)

local function RefreshFavs()
    for _, v in pairs(FLC_Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for name, id in pairs(Favorites) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.BackgroundTransparency = 0.2
        btn.Text = name .. " (" .. tostring(id) .. ")"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Parent = FLC_Scroll
        btn.MouseButton1Click:Connect(function()
            targetInput = id
            ApplySkin(id)
        end)
    end
    FLC_Scroll.CanvasSize = UDim2.new(0, 0, 0, FLC_Layout.AbsoluteContentSize.Y)
end

CreateButton(FavTab, "Atualizar Lista", RefreshFavs)

local function FetchRichPlayers()
    Notify("Sistema", "Buscando +1000 IDs de Ricos... (Aguarde)")
    task.spawn(function()
        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if not req then Notify("Erro", "Executor sem suporte HTTP"); return end
        
        local groups = {4199740, 650266} -- Video Stars, Trade
        local count = 0
        
        for _, gid in pairs(groups) do
            local cursor = ""
            for i = 1, 10 do -- 10 paginas = ~1000 ids por grupo
                local url = "https://groups.roblox.com/v1/groups/" .. gid .. "/users?sortOrder=Desc&limit=100&cursor=" .. cursor
                local s, response = pcall(function() return req({Url = url, Method = "GET"}) end)
                if s and response and response.Body then
                    local s2, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
                    if s2 and data and data.data then
                        for _, user in pairs(data.data) do
                            if user.user and user.user.userId then
                                table.insert(RichIDs, user.user.userId)
                                count = count + 1
                            end
                        end
                        cursor = data.nextPageCursor or ""
                        if cursor == "" then break end
                    end
                end
                task.wait(0.1)
            end
        end
        Notify("Sucesso", "Adicionados " .. count .. " IDs à lista!")
    end)
end

CreateButton(ClientTab, "SCAN: Buscar +1000 IDs", FetchRichPlayers)

-- Inicializar
-- Animação de Abertura
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 300), BackgroundTransparency = 0.2}):Play()

RefreshFavs()
Notify("Carregado", "Interface Nativa para Xeno carregada!")
