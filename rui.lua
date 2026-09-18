-- rui / pwd.MAIN compact build | TARGET = da hood (local fixture)
local P,S,U,H=game:GetService("Players"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("HttpService")
local L,C,G=P.LocalPlayer,workspace.CurrentCamera,game:GetService("CoreGui")
local function N(c,p,t)local o=Instance.new(c)for k,v in pairs(p or{})do o[k]=v end o.Parent=t return o end
local function chr()return L.Character end
local function hum()local c=chr()return c and c:FindFirstChildOfClass("Humanoid")end
local function root()local c=chr()return c and c:FindFirstChild("HumanoidRootPart")end

-- config (all in one table)
local K={
 sil={on=false,fov=false,byp=false,wall=false,knock=false,r=100,sp=100,hit="Head"},
 cam={on=false,auto=false,rmb=false,key="C",mode="Toggle",hit="HumanoidRootPart",cp="Default",cps=0,r=1000,md=0,es="Quad",ed="Out",sm=0.180,ps=false,pb=0.001,pm=0.001,pr=false,px=0.001,py=0.001,pz=0.001,ff=false,vis=false,car=false,ko=false,self=false},
 zoom={on=false,zmin=5,zmax=25,smin=0.5,smax=0.5,f=2.0},
 set={key="RightShift",name="default",save=false},
 ui={open=true}
}

-- closest player / visibility
local function near(d)local c,t=nil,d or math.huge local r=root()if not r then return end
 for _,p in ipairs(P:GetPlayers())do if p~=L and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart")local u=p.Character:FindFirstChildOfClass("Humanoid")
  if h and u and u.Health>0 then local m=(h.Position-C.CFrame.Position).Magnitude if m<t then t,c=m,p end end end end return c end
local function vis(p)if not p or not p.Character then return false end
 local a=p.Character:FindFirstChild("Head")or p.Character:FindFirstChild("HumanoidRootPart")if not a then return false end
 local q=RaycastParams.new()q.FilterType=Enum.RaycastFilterType.Exclude q.FilterDescendantsInstances={L.Character,p.Character}
 return workspace:Raycast(C.CFrame.Position,(a.Position-C.CFrame.Position),q)==nil end

-- camlock + zoomrate + silent hook
local mt=getrawmetatable(game)local on=mt.__namecall setreadonly(mt,false)
mt.__namecall=newcclosure(function(s,...)local m=getnamecallmethod()
 if K.sil.on and m=="FindPartOnRayWithIgnoreList" then local t=near(K.sil.r>0 and K.sil.r or nil)
  if t and t.Character and not(K.sil.wall and not vis(t))then local a=t.Character:FindFirstChild(K.sil.hit)or t.Character:FindFirstChild("Head")
   if a then return a,a.Position end end end end return on(s,...)end)setreadonly(mt,true)

local fovc
local function drawfov()if not fovc then fovc=Drawing.new("Circle")fovc.Thickness=1 fovc.NumSides=64 fovc.Filled=false fovc.Color=Color3.fromRGB(200,200,200)fovc.Transparency=1 end
 fovc.Visible=K.sil.on and K.sil.fov fovc.Position=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2)fovc.Radius=K.sil.r end

local zph,zd,ofov=0,1,C.FieldOfView
local function zoom()if not K.zoom.on then C.FieldOfView=ofov return end
 zph=zph+K.zoom.f/60*zd if zph>1 then zph=1 zd=-1 end if zph<0 then zph=0 zd=1 end
 C.FieldOfView=K.zoom.zmin+(K.zoom.zmax-K.zoom.zmin)*zph end

local function cam()if not K.cam.on then return end local t=near(K.cam.md>0 and K.cam.md or nil)if not t or(K.cam.vis and not vis(t))then return end
 local a=t.Character:FindFirstChild(K.cam.hit)or t.Character:FindFirstChild("HumanoidRootPart")if not a then return end
 local g=CFrame.new(C.CFrame.Position,a.Position)
 if K.cam.pr then local v=a.AssemblyLinearVelocity or Vector3.zero g=CFrame.new(C.CFrame.Position,a.Position+v*Vector3.new(K.cam.px,K.cam.py,K.cam.pz))end
 C.CFrame=K.cam.sm>0 and C.CFrame:Lerp(g,K.cam.sm)or g end

S.RenderStepped:Connect(function()pcall(cam)pcall(drawfov)pcall(zoom)end)

-- config service
local function sCfg(n)writefile("rui_"..n..".json",H:JSONEncode(K))end
local function lCfg(n)if isfile("rui_"..n..".json")then for k,v in pairs(H:JSONDecode(readfile("rui_"..n..".json")))do K[k]=v end end end
local function dCfg(n)if isfile("rui_"..n..".json")then delfile("rui_"..n..".json")end end

-- compact UI
local gui=N("ScreenGui",{Name="rui",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
pcall(function()gui.Parent=G end)if not gui.Parent then gui.Parent=L:WaitForChild("PlayerGui")end
local T={bg=Color3.fromRGB(24,22,30),panel=Color3.fromRGB(32,30,40),side=Color3.fromRGB(28,26,36),row=Color3.fromRGB(40,38,50),soft=Color3.fromRGB(46,44,58),tx=Color3.fromRGB(235,230,245),td=Color3.fromRGB(150,145,165),ac=Color3.fromRGB(210,170,255),ac2=Color3.fromRGB(180,130,255),ln=Color3.fromRGB(55,52,68),tr=Color3.fromRGB(60,56,76)}
local main=N("Frame",{Size=UDim2.new(0,620,0,360),Position=UDim2.new(0.5,-310,0.5,-180),BackgroundColor3=T.bg,BorderSizePixel=0,Active=true,Draggable=true},gui)
N("UICorner",{CornerRadius=UDim.new(0,10)},main)N("UIStroke",{Color=T.ln,Thickness=1},main)
local side=N("Frame",{Size=UDim2.new(0,150,1,0),BackgroundColor3=T.side,BorderSizePixel=0},main)N("UICorner",{CornerRadius=UDim.new(0,10)},side)
N("TextLabel",{Text="  rui",BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=16,TextColor3=T.tx,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,6,0,10),Size=UDim2.new(1,-12,0,20)},side)
N("TextLabel",{Text="  enjoy :)",BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.td,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,6,0,28),Size=UDim2.new(1,-12,0,14)},side)
N("TextLabel",{Text="RShift   to hide",BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.td,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,10,1,-22),Size=UDim2.new(1,-20,0,14)},side)
local cont=N("Frame",{Size=UDim2.new(1,-150,1,0),Position=UDim2.new(0,150,0,0),BackgroundColor3=T.bg,BorderSizePixel=0},main)N("UICorner",{CornerRadius=UDim.new(0,10)},cont)
local ht=N("TextLabel",{Text="Home",BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=18,TextColor3=T.tx,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,18,0,12),Size=UDim2.new(1,-36,0,22)},cont)
local hs=N("TextLabel",{Text="",BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.td,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,18,0,32),Size=UDim2.new(1,-36,0,14)},cont)
local sc=N("ScrollingFrame",{Size=UDim2.new(1,-24,1,-62),Position=UDim2.new(0,12,0,52),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(0,0,0,600)},cont)
local function clr()for _,v in ipairs(sc:GetChildren())do v:Destroy()end end
local function sec(t,y)N("TextLabel",{Text=t,BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=T.td,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,4,0,y),Size=UDim2.new(1,-8,0,16)},sc)return y+18 end
local function row(l,y)local r=N("Frame",{Size=UDim2.new(1,-8,0,34),Position=UDim2.new(0,4,0,y),BackgroundColor3=T.row,BorderSizePixel=0},sc)N("UICorner",{CornerRadius=UDim.new(0,8)},r)
 N("TextLabel",{Text=l,BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.tx,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,14,0,0),Size=UDim2.new(0.6,0,1,0)},r)return r,y+40 end
local function tog(y,l,c,k)local r,ny=row(l,y)local b=N("Frame",{Size=UDim2.new(0,36,0,18),Position=UDim2.new(1,-48,0.5,-9),BackgroundColor3=c[k]and T.ac2 or T.tr,BorderSizePixel=0},r)N("UICorner",{CornerRadius=UDim.new(1,0)},b)
 local n=N("Frame",{Size=UDim2.new(0,14,0,14),Position=c[k]and UDim2.new(1,-16,0.5,-7)or UDim2.new(0,2,0.5,-7),BackgroundColor3=T.tx,BorderSizePixel=0},b)N("UICorner",{CornerRadius=UDim.new(1,0)},n)
 b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then c[k]=not c[k]b.BackgroundColor3=c[k]and T.ac2 or T.tr n.Position=c[k]and UDim2.new(1,-16,0.5,-7)or UDim2.new(0,2,0.5,-7)end end)return ny end
local function box(y,l,c,k)local r,ny=row(l,y)local b=N("TextBox",{Text=tostring(c[k]),Position=UDim2.new(1,-140,0.5,-9),Size=UDim2.new(0,126,0,18),BackgroundColor3=T.soft,TextColor3=T.td,Font=Enum.Font.Gotham,TextSize=11,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Center},r)
 N("UICorner",{CornerRadius=UDim.new(0,6)},b)N("UIStroke",{Color=T.ln,Thickness=1},b)b.FocusLost:Connect(function()c[k]=b.Text end)return ny end
local function drop(y,l,c,k,o)local r,ny=row(l,y)local b=N("TextButton",{Text=tostring(c[k]),Position=UDim2.new(1,-140,0.5,-9),Size=UDim2.new(0,126,0,18),BackgroundColor3=T.soft,TextColor3=T.td,Font=Enum.Font.Gotham,TextSize=11,BorderSizePixel=0},r)
 N("UICorner",{CornerRadius=UDim.new(0,6)},b)N("UIStroke",{Color=T.ln,Thickness=1},b)local i=table.find(o,c[k])or 1
 b.MouseButton1Click:Connect(function()i=i%#o+1 c[k]=o[i]b.Text=c[k]end)return ny end
local function sld(y,l,c,k,mn,mx,st)local r,ny=row(l,y)local bx=N("TextBox",{Text=string.format("%.3f",c[k]),Position=UDim2.new(1,-88,0.5,-9),Size=UDim2.new(0,74,0,18),BackgroundColor3=T.soft,TextColor3=T.td,Font=Enum.Font.Gotham,TextSize=11,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Center},r)
 N("UICorner",{CornerRadius=UDim.new(0,6)},bx)N("UIStroke",{Color=T.ln,Thickness=1},bx)
 local b=N("Frame",{Size=UDim2.new(0,180,0,3),Position=UDim2.new(0,14,0.5,10),BackgroundColor3=T.tr,BorderSizePixel=0},r)N("UICorner",{CornerRadius=UDim.new(1,0)},b)
 local f=N("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=T.ac,BorderSizePixel=0},b)N("UICorner",{CornerRadius=UDim.new(1,0)},f)
 local n=N("Frame",{Size=UDim2.new(0,10,0,10),BackgroundColor3=T.tx,BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0)},b)N("UICorner",{CornerRadius=UDim.new(1,0)},n)
 local function rf()local a=(c[k]-mn)/(mx-mn)f.Size=UDim2.new(a,0,1,0)n.Position=UDim2.new(a,0,0.5,0)bx.Text=string.format("%.3f",c[k])end rf()
 bx.FocusLost:Connect(function()local v=tonumber(bx.Text)if v then c[k]=math.clamp(v,mn,mx)rf()end end)
 local dr=false b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true end end)
 U.InputChanged:Connect(function(i)if dr and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local rel=math.clamp((i.Position.X-b.AbsolutePosition.X)/b.AbsoluteSize.X,0,1)c[k]=mn+rel*(mx-mn)if st then c[k]=math.floor(c[k]/st+0.5)*st end rf()end end)
 U.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)return ny end
local function act(y,l,d,cb)local r,ny=row(l,y)if d then local t=r:FindFirstChildOfClass("TextLabel")t.Text=""
 N("TextLabel",{Text=l,BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.tx,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,14,0,3),Size=UDim2.new(1,-28,0,14)},r)
 N("TextLabel",{Text=d,BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.td,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,14,0,17),Size=UDim2.new(1,-28,0,14)},r)end
 local b=N("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},r)b.MouseButton1Click:Connect(cb)return ny end

-- pages
local pg={}
function pg.Home()clr()ht.Text="Home"hs.Text=""local y=0
 local cd=N("Frame",{Size=UDim2.new(1,-8,0,54),Position=UDim2.new(0,4,0,y),BackgroundColor3=T.row,BorderSizePixel=0},sc)N("UICorner",{CornerRadius=UDim.new(0,8)},cd)
 N("TextLabel",{Text="Hello, "..L.Name,BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=T.tx,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,14,0,8),Size=UDim2.new(1,-28,0,16)},cd)
 N("TextLabel",{Text="Good afternoon.",BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.td,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,14,0,28),Size=UDim2.new(1,-28,0,14)},cd)
 y=y+64 y=sec("SYSTEM INFO",y)y=box(y,"FPS",{value=225},"value")y=box(y,"Ping",{value=math.floor(L:GetNetworkPing()*1000)},"value")y=box(y,"Executor",{value="Real"},"value")y=box(y,"Game",{value="[UPD] Da Hood"},"value")
 sc.CanvasSize=UDim2.new(0,0,0,y+10)end
function pg.SilentAim()clr()ht.Text="Silent Aim"hs.Text="targeting assistance"local y=0
 y=tog(y,"Silent Aim",K.sil,"on")y=tog(y,"Show FOV",K.sil,"fov")y=tog(y,"Revolver Bypass",K.sil,"byp")y=tog(y,"Wall Check",K.sil,"wall")y=tog(y,"Knock Check",K.sil,"knock")
 y=sld(y,"FOV Radius",K.sil,"r",0,1000,1)y=sld(y,"Bullet Spread",K.sil,"sp",0,100,1)y=drop(y,"Hit Part",K.sil,"hit",{"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm"})
 sc.CanvasSize=UDim2.new(0,0,0,y+10)end
function pg.Camlock()clr()ht.Text="Camlock"hs.Text="settings & info"local y=0
 y=tog(y,"Camlock",K.cam,"on")y=tog(y,"Auto Toggle",K.cam,"auto")y=tog(y,"Use RMB",K.cam,"rmb")y=box(y,"Toggle Key",K.cam,"key")
 y=drop(y,"Mode",K.cam,"mode",{"Toggle","Hold"})y=drop(y,"Hit Part",K.cam,"hit",{"HumanoidRootPart","Head","UpperTorso","LowerTorso"})y=drop(y,"CP Mode",K.cam,"cp",{"Default","Center","Edge"})
 y=sld(y,"CP Scale",K.cam,"cps",0,1,0.001)y=sld(y,"FOV Radius",K.cam,"r",0,1000,1)y=sld(y,"Max Distance",K.cam,"md",0,1000,1)
 y=drop(y,"Easing Style",K.cam,"es",{"Quad","Linear","Sine","Back"})y=drop(y,"Easing Dir",K.cam,"ed",{"Out","In","InOut"})y=sld(y,"Smoothness",K.cam,"sm",0,1,0.001)
 y=sec("PULL STRENGTH",y)y=tog(y,"Pull Strength",K.cam,"ps")y=sld(y,"Pull Base",K.cam,"pb",0,1,0.001)y=sld(y,"Pull Move",K.cam,"pm",0,1,0.001)
 y=sec("PREDICTION",y)y=tog(y,"Prediction",K.cam,"pr")y=sld(y,"Pred X",K.cam,"px",0,1,0.001)y=sld(y,"Pred Y",K.cam,"py",0,1,0.001)y=sld(y,"Pred Z",K.cam,"pz",0,1,0.001)
 y=sec("CONDITIONS",y)y=tog(y,"FF Check",K.cam,"ff")y=tog(y,"Vis Check",K.cam,"vis")y=tog(y,"Carried Check",K.cam,"car")y=tog(y,"Knocked Check",K.cam,"ko")y=tog(y,"Self KO Check",K.cam,"self")
 sc.CanvasSize=UDim2.new(0,0,0,y+10)end
function pg.Zoom()clr()ht.Text="Zoomrate"hs.Text="zoom level control"local y=0
 y=tog(y,"Zoomrate",K.zoom,"on")y=sld(y,"Zoom Min",K.zoom,"zmin",0,100,1)y=sld(y,"Zoom Max",K.zoom,"zmax",0,100,1)
 y=sld(y,"Stay Min",K.zoom,"smin",0,5,0.1)y=sld(y,"Stay Max",K.zoom,"smax",0,5,0.1)y=sld(y,"Frequency",K.zoom,"f",0,10,0.1)
 sc.CanvasSize=UDim2.new(0,0,0,y+10)end
function pg.Settings()clr()ht.Text="Settings"hs.Text=""local y=0
 y=box(y,"Toggle UI",K.set,"key")y=sec("CONFIGS",y)y=box(y,"Config name",K.set,"name")
 y=act(y,"Save","Writes every flagged element to the selected name",function()sCfg(K.set.name)end)
 y=act(y,"Load",nil,function()lCfg(K.set.name)end)y=act(y,"Delete",nil,function()dCfg(K.set.name)end)
 y=tog(y,"Auto save",K.set,"save")y=act(y,"Unload",nil,function()gui:Destroy()end)
 sc.CanvasSize=UDim2.new(0,0,0,y+10)end

-- nav
local items={{"Home",pg.Home},{"Silent Aim",pg.SilentAim},{"Camlock",pg.Camlock},{"Zoomrate",pg.Zoom},{"Settings",pg.Settings}}
local btns={}local yy=60
for _,it in ipairs(items)do local b=N("TextButton",{Text="  "..it[1],BackgroundColor3=T.side,BorderSizePixel=0,TextColor3=T.td,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,8,0,yy)},side)
 N("UICorner",{CornerRadius=UDim.new(0,8)},b)b.MouseButton1Click:Connect(function()for _,o in ipairs(btns)do o.BackgroundColor3=T.side end b.BackgroundColor3=T.row it[2]()end)table.insert(btns,b)yy=yy+34 end

U.InputBegan:Connect(function(i,g)if g then return end
 if i.KeyCode==Enum.KeyCode.RightShift then K.ui.open=not K.ui.open main.Visible=K.ui.open end
 if i.KeyCode==Enum.KeyCode.C then K.cam.on=not K.cam.on end end)

pg.Home()print("rui loaded")
