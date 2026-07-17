local lib = {}

local col = {
    bg = Color3.fromRGB(5,6,6),
    rail = Color3.fromRGB(14,15,17),
    top = Color3.fromRGB(8,9,9),
    panel = Color3.fromRGB(13,14,16),
    card = Color3.fromRGB(16,17,19),
    line = Color3.fromRGB(23,25,28),
    blue = Color3.fromRGB(8,108,255),
    blue2 = Color3.fromRGB(0,85,223),
    sel = Color3.fromRGB(9,24,45),
    text = Color3.fromRGB(231,233,237),
    mute = Color3.fromRGB(119,123,130),
    dim = Color3.fromRGB(53,58,66),
    off = Color3.fromRGB(10,11,12),
    green = Color3.fromRGB(87,211,154),
    red = Color3.fromRGB(198,80,88),
    yellow = Color3.fromRGB(217,168,60),
    border = Color3.fromRGB(58,61,66),
    borderhot = Color3.fromRGB(145,149,156),
    tabhot = Color3.fromRGB(38,41,46)
}

lib.Colors = col
lib.Images = {
    icon = "https://www.image2url.com/r2/default/images/1784262557130-49e4cc08-ce77-40e7-9ac3-d7e42abbeb07.jpg",
    visuals = "https://www.image2url.com/r2/default/images/1784262535153-e5e0c25d-2706-4ae2-b2ac-60541dee3311.png",
    tools = "https://cdn.phototourl.com/free/2026-07-17-70abd011-be6e-447e-8a2a-1487dcb12d25.png",
    settings = "https://www.image2url.com/r2/default/images/1784262532987-a9d4dc27-f316-4215-860b-f2e469ffed15.png",
    menu = "https://www.image2url.com/r2/default/images/1784262532170-7b7ee9c0-abb6-455a-a198-8be287153c9d.png",
    alerts = "https://www.image2url.com/r2/default/images/1784262684161-2de78d96-8823-496f-b4ae-a9feb83f0732.png",
    check = "https://cdn.phototourl.com/free/2026-07-17-5c4b0ecf-bdb4-4fae-b42f-63eaae3e31bf.png"
}

local cache = {}
local function clamp(v,a,b)
    return math.max(a,math.min(b,v))
end

local function mix(a,b,t)
    return a+(b-a)*t
end

local function mixc(a,b,t)
    return Color3.fromRGB(
        math.floor(mix(a.R,b.R,t)*255),
        math.floor(mix(a.G,b.G,t)*255),
        math.floor(mix(a.B,b.B,t)*255)
    )
end

local function ease(t)
    t=clamp(t,0,1)
    return 1-(1-t)^4
end

local function hit(mx,my,x,y,w,h)
    if type(mx)~="number" or type(my)~="number" or type(x)~="number" or type(y)~="number" or type(w)~="number" or type(h)~="number" then return false end
    return mx>=x and mx<=x+w and my>=y and my<=y+h
end

local function data(name)
    if cache[name]~=nil then return cache[name] or nil end
    local body=""
    pcall(function() body=game:HttpGet(lib.Images[name]) end)
    cache[name]=body~="" and body or false
    return cache[name] or nil
end

local function square(x,y,w,h,color,z,corner,filled)
    local d=Drawing.new("Square")
    d.Position=Vector2.new(x,y)
    d.Size=Vector2.new(w,h)
    d.Color=color
    d.Filled=filled~=false
    d.Transparency=1
    d.ZIndex=z or 1
    d.Visible=true
    if filled==false then d.Thickness=1 end
    if corner then pcall(function() d.Corner=corner end) end
    return d
end

local function text(value,x,y,size,color,z,center,bold)
    local d=Drawing.new("Text")
    d.Text=tostring(value or "")
    d.Position=Vector2.new(x,y)
    d.Color=color or col.text
    d.Size=size or 11
    d.Center=center or false
    d.Outline=false
    d.Font=Drawing.Fonts.Monospace
    d.Transparency=1
    d.ZIndex=z or 3
    d.Visible=true
    return d
end

local function image(name,x,y,w,h,z,round)
    local body=data(name)
    if not body then return nil end
    local d=Drawing.new("Image")
    d.Data=body
    d.Position=Vector2.new(x,y)
    d.Size=Vector2.new(w,h)
    d.Rounding=round or 0
    d.Transparency=1
    d.ZIndex=z or 4
    d.Visible=true
    return d
end

local names={
    [0x08]="Backspace",[0x09]="Tab",[0x0D]="Enter",[0x10]="Shift",[0x11]="Ctrl",[0x12]="Alt",[0x13]="Pause",[0x14]="Caps Lock",[0x1B]="Escape",[0x20]="Space",[0x21]="Page Up",[0x22]="Page Down",[0x23]="End",[0x24]="Home",[0x25]="Left",[0x26]="Up",[0x27]="Right",[0x28]="Down",[0x2D]="Insert",[0x2E]="Delete",[0x5B]="Left Windows",[0x5C]="Right Windows",[0x5D]="Menu",[0x90]="Num Lock",[0x91]="Scroll Lock",[0xBA]=";",[0xBB]="=",[0xBC]=",",[0xBD]="-",[0xBE]=".",[0xBF]="/",[0xC0]="`",[0xDB]="[",[0xDC]="\\",[0xDD]="]",[0xDE]="'"
}
for i=0x30,0x39 do names[i]=string.char(i) end
for i=0x41,0x5A do names[i]=string.char(i) end
for i=0x60,0x69 do names[i]="Numpad "..tostring(i-0x60) end
for i=0x70,0x87 do names[i]="F"..tostring(i-0x6F) end

local function keyname(key)
    return names[key] or string.format("VK %02X",key)
end

local function keychar(key,shift)
    if key>=0x41 and key<=0x5A then
        local s=string.char(key)
        return shift and s or s:lower()
    end
    if key>=0x30 and key<=0x39 then
        local plain="0123456789"
        local upper=")!@#$%^&*("
        local i=key-0x30+1
        return (shift and upper or plain):sub(i,i)
    end
    if key>=0x60 and key<=0x69 then return tostring(key-0x60) end
    if key==0x20 then return " " end
    if key==0xBD then return shift and "_" or "-" end
    if key==0xBE or key==0x6E then return "." end
    return nil
end

local function call(fn,...)
    if not fn then return true,nil end
    return pcall(fn,...)
end

function lib.Window(gamename)
    local win={}
    local player=game:GetService("Players").LocalPlayer
    local mouse=player:GetMouse()
    local realgame=tostring(gamename or "")
    pcall(function() if type(getgamename)=="function" then realgame=getgamename() end end)
    local realuser=tostring(player.Name or "User")
    local privacy=false
    local tabs={}
    local order={}
    local draws={}
    local base={}
    local nav={}
    local tabdraw={}
    local controls={}
    local current=nil
    local listen=nil
    local listenwait=false
    local typing=nil
    local menukey=0x70
    local keywas={}
    local open=true
    local target=1
    local alpha=1
    local load=0
    local splash=1
    local ready=false
    local opening=true
    local dead=false
    local down=false
    local drag=false
    local dragx=0
    local dragy=0
    local x=170
    local y=110
    local w=840
    local h=560
    pcall(function()
        local vp=game:GetService("Workspace").CurrentCamera.ViewportSize
        x=math.floor((vp.X-w)/2)
        y=math.floor((vp.Y-h)/2)
    end)
    local railw=66
    local top=55
    local pad=13
    local gap=11
    local colw=(w-railw-pad*3-gap)/2
    local activefade=1
    local oldtab=nil
    local loaditems={}
    local tip=nil
    local closehot=false
    local minhot=false
    local minimized=false

    local function add(d,list)
        if not d then return nil end
        table.insert(draws,d)
        if list then table.insert(list,d) end
        if opening and list~=loaditems then d.Transparency=0 end
        return d
    end

    local function vis(d,on,a)
        if not d then return end
        d.Visible=on
        d.Transparency=a or 1
    end

    local function clearlist(list)
        for _,d in ipairs(list) do pcall(function() d:Remove() end) end
    end

    local function tabicon(name)
        local n=name:lower()
        if n:find("setting") then return "settings" end
        if n:find("alert") or n:find("detect") or n:find("notif") then return "alerts" end
        if n:find("visual") or n:find("esp") then return "visuals" end
        if n:find("tool") or n:find("method") then return "tools" end
        return "menu"
    end

    local function newsection(tab,label)
        local sec={label=label,items={},col=(#tab.sections%2)+1,y=0,h=37,hover=0}
        table.insert(tab.sections,sec)
        return sec
    end

    local function newcontrol(tab,kind,label,value,fn,desc)
        local sec=tab.section or newsection(tab,"Controls")
        tab.section=sec
        local c={tab=tab,sec=sec,kind=kind,label=label,value=value,fn=fn,desc=desc,state=value,hover=0,anim=value and 1 or 0,draw={},h=31,open=false}
        table.insert(sec.items,c)
        table.insert(controls,c)
        sec.h=sec.h+c.h
        return c
    end

    local function dropitems(c)
        for _,o in ipairs(c.opt or {}) do
            pcall(function() o.bg:Remove() end);pcall(function() o.tx:Remove() end)
            for i=#c.draw,1,-1 do if c.draw[i]==o.bg or c.draw[i]==o.tx then table.remove(c.draw,i) end end
        end
        c.opt={}
        if #c.draw==0 then return end
        for _,v in ipairs(c.options or {}) do
            local bg=add(square(0,0,130,23,col.card,22,3),c.draw)
            local tx=add(text(tostring(v),0,0,12,col.text,23,false,false),c.draw)
            vis(bg,false,0);vis(tx,false,0)
            table.insert(c.opt,{bg=bg,tx=tx,value=v})
        end
    end

    local function api(tab)
        local a={}
        function a:Div(label)
            tab.section=newsection(tab,label)
            return #tab.sections
        end
        function a:Toggle(label,value,fn,desc)
            local c=newcontrol(tab,"toggle",label,value==true,fn,desc)
            return c
        end
        function a:Slider(label,min,max,value,fn,float,desc)
            local c=newcontrol(tab,"slider",label,value,fn,desc)
            c.min=min;c.max=max;c.float=float==true;c.h=45;c.sec.h=c.sec.h+14
            return c
        end
        function a:Button(label,color,fn,labelcolor)
            local c=newcontrol(tab,"button",label,false,fn)
            c.color=color;c.labelcolor=labelcolor
            return #controls
        end
        function a:SetButtonText(index,value)
            local c=controls[index]
            if c and c.kind=="button" then c.label=value end
        end
        function a:GetButtonText(index)
            local c=controls[index]
            return c and c.label or nil
        end
        function a:Dropdown(label,options,index,fn)
            local c=newcontrol(tab,"dropdown",label,index or 1,fn)
            c.options=options or {};c.index=index or 1
            c.h=59;c.sec.h=c.sec.h+28;c.dropanim=0
            function c:Update(newoptions,newindex)
                self.options=newoptions or self.options
                self.index=clamp(newindex or self.index or 1,1,math.max(1,#self.options))
                self.open=false;dropitems(self)
                return self
            end
            return c
        end
        function a:MultiDropdown(label,options,selected,fn)
            local c=newcontrol(tab,"multidropdown",label,false,fn)
            c.options=options or {};c.selected={}
            for _,v in ipairs(selected or {}) do c.selected[v]=true end
            c.h=59;c.sec.h=c.sec.h+28;c.dropanim=0
            function c:Update(newoptions,newselected)
                self.options=newoptions or self.options
                if newselected then
                    self.selected={}
                    for _,v in ipairs(newselected) do self.selected[v]=true end
                end
                self.open=false;dropitems(self)
                return self
            end
            return c
        end
        function a:Textbox(label,value,fn,placeholder,numeric)
            local c=newcontrol(tab,"textbox",label,tostring(value or ""),fn)
            c.text=tostring(value or "");c.placeholder=placeholder or "Enter value";c.numeric=numeric==true
            c.h=59;c.sec.h=c.sec.h+28
            return c
        end
        function a:Label(label,color,pulse)
            local c=newcontrol(tab,"label",label,false,nil)
            c.color=color or col.text;c.pulse=pulse==true
            return c
        end
        function a:Keybind(label,key,fn,desc)
            local c=newcontrol(tab,"keybind",label,key or 0,fn,desc)
            c.key=key or 0
            return c
        end
        function a:Log(lines)
            local c=newcontrol(tab,"log","",false,nil)
            c.lines=lines or {};c.h=math.max(31,#c.lines*17+10);c.sec.h=c.sec.h+c.h-31
            return c
        end
        return a
    end

    function win:Tab(name,group)
        if tabs[name] then return tabs[name].api end
        local tab={name=name,sections={},section=nil,icon=group or tabicon(name)}
        tab.api=api(tab)
        tabs[name]=tab
        table.insert(order,tab)
        if not current then current=tab end
        return tab.api
    end

    function win:SettingsTab(onclose)
        local a=win:Tab("Settings","settings")
        a:Div("Interface")
        local bind=a:Keybind("Menu Key",menukey,function(key) menukey=key end,"Changes menu key")
        bind.menu=true
        a:Toggle("Privacy Mode",false,function(state) win:SetPrivacy(state) end,"Hides the game name and username")
        win.credit=a:Label("Credits: hitechboi",Color3.fromRGB(112,73,154),true)
        a:Button("Destroy Menu",col.card,function()
            if onclose then call(onclose) end
            win:Destroy()
        end,col.red)
        return a
    end

    local function buildbase()
        add(square(x,y,w,h,col.bg,1,13),base)
        local frame=add(square(x,y,w,h,col.border,14,13,false),base)
        frame.Transparency=0.5
        add(square(x,y,railw,h,col.rail,2,13),base)
        add(square(x+railw-13,y,13,h,col.rail,2,0),base)
        add(square(x+railw,y,w-railw,top,col.rail,2,13),base)
        add(square(x+railw,y+top-13,w-railw,13,col.rail,2,0),base)
        add(square(x+railw,y+top-1,w-railw,1,col.line,3,0),base)
        add(square(x+railw-1,y,1,h,col.line,3,0),base)
        local logo=add(image("icon",x+13,y+12,40,40,5,11),base)
        local gx=x+w-305
        local green=Drawing.new("Circle")
        green.Position=Vector2.new(gx,y+27);green.Radius=3;green.NumSides=16;green.Filled=true;green.Color=col.green;green.ZIndex=5;green.Visible=true
        add(green,base)
        local game=add(text(realgame,gx+12,y+20,13,col.text,5,false,true),base)
        local user=add(text(realuser,gx+24+#realgame*7.5,y+20,13,Color3.fromRGB(105,190,255),5,false,true),base)
        win.logo=logo;win.gametext=game;win.usertext=user;win.green=green;win.frame=frame
        local side={{"menu",y+79},{"visuals",y+130},{"tools",y+181},{"alerts",y+232},{"settings",y+283}}
        for _,item in ipairs(side) do
            local name,ny=item[1],item[2]
            local bg=add(square(x+12,ny,42,42,col.rail,3,11),base)
            local img=add(image(name,x+23,ny+11,20,20,5,0),base)
            local bar=add(square(x+1,ny+10,3,22,col.blue,6,3),base)
            bar.Transparency=0
            table.insert(nav,{bg=bg,img=img,bar=bar,name=name,y=ny,hover=0})
        end
        local tbg=add(square(0,0,170,28,col.card,30,5))
        local ttx=add(text("",0,0,10,col.text,31,false,false))
        vis(tbg,false,0);vis(ttx,false,0)
        tip={bg=tbg,tx=ttx,alpha=0}
    end

    local function buildtabs()
        clearlist(tabdraw)
        tabdraw={}
        local pos={}
        for _,tab in ipairs(order) do
            local tx=pos[tab.icon] or x+railw+18
            local tw=math.max(104,#tab.name*8.5+36)
            local bg=add(square(tx,y+11,tw,33,tab==current and col.blue2 or col.rail,4,17),tabdraw)
            local ol=add(square(tx,y+11,tw,33,col.borderhot,5,17,false),tabdraw)
            ol.Transparency=0.18
            local lb=add(text(tab.name,tx+tw/2,y+27,14,tab==current and col.text or col.mute,6,true),tabdraw)
            tab.hit={x=tx,y=y+11,w=tw,h=33,bg=bg,ol=ol,lb=lb,hover=0}
            pos[tab.icon]=tx+tw+8
        end
    end

    local function showtabs(a,on)
        local count=0
        for _,tab in ipairs(order) do if current and tab.icon==current.icon then count=count+1 end end
        for _,tab in ipairs(order) do
            local show=on and count>1 and current and tab.icon==current.icon
            local ht=tab.hit
            if ht then vis(ht.bg,show,a);vis(ht.ol,show,a*0.5);vis(ht.lb,show,a) end
        end
    end

    local function controldraw(c)
        local d=c.draw
        if #d>0 then return end
        if c.kind=="log" then
            for i,line in ipairs(c.lines) do add(text(line,0,0,12,i==1 and col.text or col.mute,10),d) end
            return
        end
        add(text(c.label,0,0,13,col.text,10,false,false),d)
        if c.kind=="label" then
            d[1].Center=true
            d[1].Color=c.color
        elseif c.kind=="toggle" then
            add(square(0,0,17,17,col.off,7,4),d)
            add(text("✓",0,0,11,col.text,8,true,true),d)
        elseif c.kind=="slider" then
            add(text(tostring(c.value),0,0,12,col.text,10,false,false),d)
            add(square(0,0,100,4,col.line,7,3),d)
            add(square(0,0,20,4,col.blue,8,3),d)
            local knob=Drawing.new("Circle")
            knob.Radius=7;knob.NumSides=20;knob.Filled=true;knob.Color=col.blue;knob.ZIndex=9;knob.Visible=true
            add(knob,d)
        elseif c.kind=="button" then
            add(square(0,0,100,25,c.color or col.off,7,3),d)
            local ol=add(square(0,0,100,25,col.border,8,3,false),d)
            ol.Transparency=0.3
            d[1].Center=true;d[1].ZIndex=10
        elseif c.kind=="dropdown" or c.kind=="multidropdown" or c.kind=="keybind" or c.kind=="textbox" then
            add(square(0,0,128,24,col.off,7,4),d)
            add(text("",0,0,12,col.mute,10,false,false),d)
            c.fieldol=add(square(0,0,128,24,col.border,9,4,false),d)
            c.fieldol.Transparency=0.3
            if c.kind=="dropdown" or c.kind=="multidropdown" then
                dropitems(c)
            end
        end
    end

    local function sectiondraw(sec)
        if not sec.bg then sec.bg=add(square(0,0,colw,sec.h,col.panel,4,6)) end
        if not sec.outline then
            sec.outline=add(square(0,0,colw,sec.h,col.border,5,6,false))
            sec.outline.Transparency=0.25
        end
        if not sec.title then sec.title=add(text(sec.label,0,0,13,col.text,10,false,true)) end
        if not sec.line then sec.line=add(square(0,0,colw-20,1,col.line,6,0)) end
        for i,c in ipairs(sec.items) do
            controldraw(c)
            if c.kind=="toggle" and not c.check then
                pcall(function() c.draw[3]:Remove() end)
                table.remove(c.draw,3)
                c.tol=add(square(0,0,17,17,col.border,8,4,false),c.draw)
                c.tol.Transparency=0.45
                c.check=image("check",0,0,13,13,9,2) or text("+",0,0,10,col.text,9,true,true)
                add(c.check,c.draw)
            end
            if i<#sec.items and not c.sep then
                c.sep=add(square(0,0,colw-20,1,col.line,6,0),c.draw)
                c.sep.Transparency=0.55
            end
        end
    end

    local function layout(tab,off)
        local ys={y+top+pad,y+top+pad}
        for _,sec in ipairs(tab.sections) do
            sectiondraw(sec)
            local sx=x+railw+pad+(sec.col-1)*(colw+gap)
            local sy=ys[sec.col]+off
            local lift=(sec.hover or 0)*2
            local py=sy-lift
            sec.x=sx;sec.y=py
            local ex=(sec.hover or 0)*2
            sec.bg.Position=Vector2.new(sx-ex,py-ex);sec.bg.Size=Vector2.new(colw+ex*2,sec.h+ex*2)
            sec.outline.Position=Vector2.new(sx-ex,py-ex);sec.outline.Size=Vector2.new(colw+ex*2,sec.h+ex*2)
            sec.title.Position=Vector2.new(sx+10,py+10)
            sec.line.Position=Vector2.new(sx+10,py+31);sec.line.Size=Vector2.new(colw-20,1)
            local cy=py+34
            for _,c in ipairs(sec.items) do
                c.x=sx+10;c.y=cy;c.w=colw-20
                local d=c.draw
                if c.kind=="log" then
                    for i,line in ipairs(d) do line.Position=Vector2.new(c.x,cy+(i-1)*17) end
                else
                    d[1].Position=Vector2.new(c.x,cy+10)
                    if c.kind=="label" then
                        d[1].Position=Vector2.new(c.x+c.w/2,cy+12)
                    elseif c.kind=="toggle" then
                        d[1].Position=Vector2.new(c.x,cy+7)
                        d[2].Position=Vector2.new(c.x+c.w-17,cy+5)
                        c.tol.Position=Vector2.new(c.x+c.w-17,cy+5)
                        c.check.Position=Vector2.new(c.x+c.w-15,cy+7)
                    elseif c.kind=="slider" then
                        local p=clamp((c.value-c.min)/(c.max-c.min),0,1)
                        d[2].Text=c.float and string.format("%.2f",c.value) or tostring(math.floor(c.value+0.5))
                        d[2].Position=Vector2.new(c.x+c.w-42,cy+10)
                        d[3].Position=Vector2.new(c.x,cy+30);d[3].Size=Vector2.new(c.w,4)
                        d[4].Position=Vector2.new(c.x,cy+30);d[4].Size=Vector2.new(c.w*p,4)
                        d[5].Position=Vector2.new(c.x+c.w*p,cy+32)
                    elseif c.kind=="button" then
                        d[2].Position=Vector2.new(c.x,cy+3);d[2].Size=Vector2.new(c.w,25)
                        d[3].Position=Vector2.new(c.x,cy+3);d[3].Size=Vector2.new(c.w,25)
                        d[1].Position=Vector2.new(c.x+c.w/2,cy+16);d[1].Color=c.labelcolor or col.text
                    elseif c.kind=="dropdown" or c.kind=="multidropdown" then
                        d[2].Position=Vector2.new(c.x,cy+28);d[2].Size=Vector2.new(c.w,25)
                        c.fieldol.Position=Vector2.new(c.x,cy+28);c.fieldol.Size=Vector2.new(c.w,25)
                        if c.kind=="dropdown" then
                            d[3].Text=tostring(c.options[c.index] or "None")
                        else
                            local pick={}
                            for _,v in ipairs(c.options) do if c.selected[v] then table.insert(pick,tostring(v)) end end
                            d[3].Text=#pick>0 and table.concat(pick,", ") or "None"
                        end
                        d[3].Position=Vector2.new(c.x+9,cy+36)
                        c.ox=c.x;c.oy=cy+55;c.ow=c.w
                        for i,o in ipairs(c.opt or {}) do
                            o.bg.Position=Vector2.new(c.ox,c.oy+(i-1)*24);o.bg.Size=Vector2.new(c.w,23)
                            o.tx.Position=Vector2.new(c.ox+9,c.oy+7+(i-1)*24)
                        end
                    elseif c.kind=="keybind" then
                        d[2].Position=Vector2.new(c.x+c.w-130,cy+3);d[2].Size=Vector2.new(130,24)
                        c.fieldol.Position=Vector2.new(c.x+c.w-130,cy+3);c.fieldol.Size=Vector2.new(130,24)
                        d[3].Text=listen==c and "Press any key" or keyname(c.key);d[3].Position=Vector2.new(c.x+c.w-120,cy+10)
                    elseif c.kind=="textbox" then
                        d[2].Position=Vector2.new(c.x,cy+28);d[2].Size=Vector2.new(c.w,25)
                        c.fieldol.Position=Vector2.new(c.x,cy+28);c.fieldol.Size=Vector2.new(c.w,25)
                        d[3].Text=c.text~="" and c.text or c.placeholder
                        d[3].Color=c.text~="" and col.text or col.mute
                        d[3].Position=Vector2.new(c.x+9,cy+36)
                    end
                end
                if c.sep then c.sep.Position=Vector2.new(c.x,cy+c.h-1);c.sep.Size=Vector2.new(c.w,1) end
                cy=cy+c.h
            end
            ys[sec.col]=ys[sec.col]+sec.h+gap
        end
    end

    local function setpage(tab,on,a)
        if not tab then return end
        for _,sec in ipairs(tab.sections) do
            vis(sec.bg,on,a);vis(sec.outline,on,a);vis(sec.title,on,a);vis(sec.line,on,a)
            for _,c in ipairs(sec.items) do for _,d in ipairs(c.draw) do vis(d,on,a) end end
        end
    end

    local function switch(tab)
        if not tab or tab==current then return end
        oldtab=current
        current=tab
        activefade=0
    end

    local function findside(name)
        for _,tab in ipairs(order) do if tab.icon==name then return tab end end
    end

    local function clickcontrol(c,mx,my)
        if not hit(mx,my,c.x,c.y,c.w,c.h) then return false end
        if c.kind~="textbox" then typing=nil end
        if c.kind=="toggle" then
            local old=c.state;c.state=not c.state
            local ok=call(c.fn,c.state)
            if not ok then c.state=old end
        elseif c.kind=="button" then
            c.press=1
            call(c.fn)
        elseif c.kind=="dropdown" or c.kind=="multidropdown" then
            c.open=not c.open
        elseif c.kind=="keybind" then
            listen=c
            listenwait=true
            typing=nil
        elseif c.kind=="textbox" then
            typing=c
            listen=nil
        elseif c.kind=="slider" then
            local p=clamp((mx-c.x)/c.w,0,1)
            local v=c.min+(c.max-c.min)*p
            c.value=c.float and math.floor(v*100+0.5)/100 or math.floor(v+0.5)
            call(c.fn,c.value)
        end
        return true
    end

    local function reposition(dx,dy)
        x=x+dx;y=y+dy
        local off=Vector2.new(dx,dy)
        for _,d in ipairs(draws) do
            pcall(function()
                local p=d.Position
                d.Position=Vector2.new(p.X+off.X,p.Y+off.Y)
            end)
        end
        for _,tab in ipairs(order) do
            local ht=tab.hit
            if ht then ht.x=ht.x+dx;ht.y=ht.y+dy end
            for _,sec in ipairs(tab.sections) do
                sec.x=sec.x and sec.x+dx or nil
                sec.y=sec.y and sec.y+dy or nil
                for _,c in ipairs(sec.items) do
                    c.x=c.x and c.x+dx or nil
                    c.y=c.y and c.y+dy or nil
                end
            end
        end
        for _,n in ipairs(nav) do n.y=n.y and n.y+dy or nil end
    end

    local function loading()
        local lw=w-72
        local lh=h-72
        local s1=add(square(x+w/2,y+h/2,1,1,col.bg,18),loaditems)
        local s2=add(square(x+w/2,y+h/2,1,1,col.bg,18),loaditems)
        local cs={}
        for i=1,4 do
            local c=Drawing.new("Circle")
            c.Position=Vector2.new(x+w/2,y+h/2)
            c.Radius=1;c.NumSides=32;c.Filled=true;c.Color=col.bg;c.Transparency=1;c.ZIndex=18;c.Visible=true
            add(c,loaditems);cs[i]=c
        end
        local logo=add(image("icon",x+w/2-37,y+h/2-84,74,74,20,18),loaditems)
        local titleload=add(text("hitechui",x+w/2,y+h/2+5,21,col.text,20,true,true),loaditems)
        local status=add(text("Preparing interface",x+w/2,y+h/2+34,13,col.mute,20,true),loaditems)
        local track=add(square(x+w/2-105,y+h/2+57,210,3,col.line,20,3),loaditems)
        local fill=add(square(x+w/2-105,y+h/2+57,0,3,col.blue,21,3),loaditems)
        local content={logo,titleload,status,track,fill}
        for _,d in ipairs(content) do vis(d,true,0) end
        local moves={
            {d=logo,x=x+w/2-37,y=y+h/2-84,off=-18},
            {d=titleload,x=x+w/2,y=y+h/2+5,off=14},
            {d=status,x=x+w/2,y=y+h/2+34,off=14},
            {d=track,x=x+w/2-105,y=y+h/2+57,off=14},
            {d=fill,x=x+w/2-105,y=y+h/2+57,off=14}
        }
        for _,m in ipairs(moves) do m.d.Position=Vector2.new(m.x,m.y+m.off) end
        local function shape(cw,ch)
            local r=math.min(13,cw/2,ch/2)
            local cx=x+w/2-cw/2
            local cy=y+h/2-ch/2
            s1.Position=Vector2.new(cx+r,cy);s1.Size=Vector2.new(math.max(0,cw-r*2),ch)
            s2.Position=Vector2.new(cx,cy+r);s2.Size=Vector2.new(cw,math.max(0,ch-r*2))
            cs[1].Position=Vector2.new(cx+r,cy+r)
            cs[2].Position=Vector2.new(cx+cw-r,cy+r)
            cs[3].Position=Vector2.new(cx+r,cy+ch-r)
            cs[4].Position=Vector2.new(cx+cw-r,cy+ch-r)
            for _,c in ipairs(cs) do c.Radius=math.max(1,r) end
        end
        shape(2,2)
        return {shape=shape,content=content,moves=moves,status=status,fill=fill,w=lw,h=lh}
    end

    function win:Init(default)
        if default and tabs[default] then current=tabs[default] end
        buildbase();buildtabs()
        local ld=loading()
        for _,d in ipairs(base) do vis(d,true,0) end
        for _,d in ipairs(tabdraw) do vis(d,true,0) end
        local loadstart=tick()
        local loadmenu=false
        local render
        render=game:GetService("RunService").RenderStepped:Connect(function(dt)
                if dead then return end
                dt=clamp(dt or 0.016,0,0.05)
                if opening then
                    local t=tick()-loadstart
                    if t<0.7 then
                        local e=ease(clamp(t/0.7,0,1))
                        ld.shape(math.max(2,ld.w*e),math.max(2,ld.h*e))
                    elseif t<1.25 then
                        ld.shape(ld.w,ld.h)
                        local e=ease(clamp((t-0.7)/0.55,0,1))
                        for _,d in ipairs(ld.content) do vis(d,true,e) end
                        for _,m in ipairs(ld.moves) do m.d.Position=Vector2.new(m.x,m.y+m.off*(1-e)) end
                    elseif t<3.45 then
                        ld.shape(ld.w,ld.h)
                        for _,d in ipairs(ld.content) do vis(d,true,1) end
                        for _,m in ipairs(ld.moves) do m.d.Position=Vector2.new(m.x,m.y) end
                        local p=clamp((t-1.25)/2.2,0,1)
                        ld.fill.Size=Vector2.new(210*ease(p),3)
                        ld.status.Text=p<0.34 and "Preparing interface" or p<0.68 and "Loading controls" or p<0.94 and "Applying visuals" or "Welcome, "..tostring(player.Name)
                    elseif t<4.05 then
                        if not loadmenu then
                            ld.fill.Size=Vector2.new(210,3)
                            layout(current,0)
                            setpage(current,true,0)
                            ready=true
                            loadmenu=true
                        end
                        local e=ease(clamp((t-3.45)/0.6,0,1))
                        for _,d in ipairs(loaditems) do vis(d,true,1-e) end
                        for _,d in ipairs(base) do vis(d,true,e) end
                        win.frame.Transparency=e*0.5
                        showtabs(e,true)
                        layout(current,(1-e)*14)
                        setpage(current,true,e)
                    else
                        for _,d in ipairs(loaditems) do vis(d,false,0) end
                        for _,d in ipairs(base) do vis(d,true,1) end
                        win.frame.Transparency=0.5
                        showtabs(1,true)
                        layout(current,0)
                        setpage(current,true,1)
                        activefade=1
                        ready=true
                        opening=false
                    end
                    return
                end
                local mx,my=mouse.X,mouse.Y
                local press=ismouse1pressed()
                local tapped=press and not down
                down=press

                local key=iskeypressed(menukey)
                if key and not keywas[menukey] and not listen then
                    open=not open;target=open and 1 or 0
                end
                keywas[menukey]=key

                if typing then
                    local shift=iskeypressed(0x10)
                    for vk=0x08,0xDE do
                        local held=iskeypressed(vk)
                        if held and not keywas[vk] then
                            if vk==0x08 then
                                typing.text=typing.text:sub(1,math.max(0,#typing.text-1))
                                call(typing.fn,typing.text)
                            elseif vk==0x0D or vk==0x1B then
                                typing=nil
                            else
                                local ch=keychar(vk,shift)
                                if ch and (not typing.numeric or ch:match("[%d%.%-]")) then
                                    typing.text=typing.text..ch
                                    call(typing.fn,typing.text)
                                end
                            end
                        end
                        keywas[vk]=held
                    end
                elseif listen then
                    if listenwait then
                        if not press then listenwait=false end
                    else
                        for vk=1,254 do
                            local held=iskeypressed(vk)
                            if held and not keywas[vk] then
                                listen.key=vk
                                if listen.menu then menukey=vk end
                                call(listen.fn,vk)
                                listen=nil
                                break
                            end
                            keywas[vk]=held
                        end
                    end
                end

                for _,c in ipairs(controls) do
                    if c.kind=="keybind" and c.key and c.key>0 and c~=listen and not c.menu then
                        local held=iskeypressed(c.key)
                        if held and not c.was then call(c.fn,c.key) end
                        c.was=held
                    end
                end

                alpha=mix(alpha,target,clamp(dt*10,0,1))
                local show=alpha>0.02
                local oy=(1-alpha)*10

                if not opening then
                    local ma=ready and alpha or 0
                    for _,d in ipairs(base) do vis(d,show or not ready,ma) end
                    win.frame.Transparency=ma*0.5
                    showtabs(ma,show or not ready)
                end

                if ready and not opening then
                    local tiptext=nil
                    activefade=clamp(activefade+dt*5,0,1)
                    if oldtab then
                        setpage(oldtab,activefade<1,alpha*(1-activefade*0.25))
                        layout(oldtab,-activefade*3+oy)
                        if activefade>=1 then setpage(oldtab,false,0);oldtab=nil end
                    end
                    layout(current,(1-ease(activefade))*8+oy)
                    setpage(current,show,alpha*ease(activefade))

                    local groupcount=0
                    for _,tab in ipairs(order) do if tab.icon==current.icon then groupcount=groupcount+1 end end
                    for _,tab in ipairs(order) do
                        local ht=tab.hit
                        local eligible=groupcount>1 and tab.icon==current.icon
                        local hov=eligible and hit(mx,my,ht.x,ht.y,ht.w,ht.h) and 1 or 0
                        ht.hover=mix(ht.hover,hov,clamp(dt*12,0,1))
                        local ex=ht.hover*2
                        ht.bg.Position=Vector2.new(ht.x-ex,ht.y-ex);ht.bg.Size=Vector2.new(ht.w+ex*2,ht.h+ex*2)
                        ht.ol.Position=Vector2.new(ht.x-ex,ht.y-ex);ht.ol.Size=Vector2.new(ht.w+ex*2,ht.h+ex*2)
                        ht.ol.Transparency=alpha*(0.18+ht.hover*0.5)
                        ht.bg.Color=tab==current and col.blue2 or mixc(col.rail,col.tabhot,ht.hover)
                        ht.lb.Color=tab==current and col.text or mixc(col.mute,col.text,ht.hover)
                        if eligible and tapped and hov==1 then switch(tab) end
                    end

                    for _,n in ipairs(nav) do
                        if n.name then
                            local hov=hit(mx,my,x+12,n.y,42,42) and 1 or 0
                            n.hover=mix(n.hover,hov,clamp(dt*12,0,1))
                            local selected=current and current.icon==n.name
                            n.bg.Color=selected and col.sel or mixc(col.rail,col.card,n.hover*0.7)
                            n.bg.Position=Vector2.new(x+12,n.y-n.hover)
                            if n.img then n.img.Position=Vector2.new(x+23,n.y+11-n.hover) end
                            n.bar.Transparency=alpha*(selected and 1 or n.hover*0.25)
                            if hov==1 then tiptext=n.name:sub(1,1):upper()..n.name:sub(2) end
                            if tapped and hov==1 then switch(findside(n.name)) end
                        end
                    end

                    for _,sec in ipairs(current.sections) do
                        local hov=hit(mx,my,sec.x,sec.y,colw,sec.h) and 1 or 0
                        sec.hover=mix(sec.hover,hov,clamp(dt*9,0,1))
                        if sec.outline then
                            sec.outline.Color=mixc(col.border,col.borderhot,sec.hover)
                            sec.outline.Transparency=alpha*(0.25+sec.hover*0.5)
                        end
                    end

                    local consumed=false
                    for _,c in ipairs(controls) do
                        if c.tab==current then
                            local hov=hit(mx,my,c.x,c.y,c.w,c.h) and 1 or 0
                            c.hover=mix(c.hover,hov,clamp(dt*13,0,1))
                            if c.sep then c.sep.Transparency=alpha*(0.35+c.hover*0.2) end
                            if c.fieldol then
                                c.fieldol.Color=mixc(col.border,col.borderhot,c.hover)
                                c.fieldol.Transparency=alpha*(0.3+c.hover*0.45)
                            end
                            if hov==1 and c.desc and c.desc~="" then tiptext=c.desc end
                            if c.kind=="dropdown" or c.kind=="multidropdown" then
                                c.dropanim=mix(c.dropanim or 0,c.open and 1 or 0,clamp(dt*9,0,1))
                                local de=ease(c.dropanim)
                                for i,o in ipairs(c.opt or {}) do
                                    local ip=clamp(c.dropanim*1.25-(i-1)*0.07,0,1)
                                    local oy=c.oy+(i-1)*24*de
                                    local oh=ip>0.75 and hit(mx,my,c.ox,oy,c.ow,23*ip)
                                    o.bg.Position=Vector2.new(c.ox,oy);o.bg.Size=Vector2.new(c.ow,23*ip)
                                    o.tx.Position=Vector2.new(c.ox+9,oy+7)
                                    vis(o.bg,ip>0.02,alpha*ip*(oh and 1 or 0.96))
                                    vis(o.tx,ip>0.08,alpha*ip)
                                    o.bg.Color=oh and col.tabhot or col.card
                                    if c.kind=="multidropdown" and c.selected[o.value] then o.tx.Color=col.blue else o.tx.Color=col.text end
                                    if c.open and tapped and oh then
                                        consumed=true
                                        if c.kind=="dropdown" then
                                            c.index=i;c.open=false;call(c.fn,o.value)
                                        else
                                            c.selected[o.value]=not c.selected[o.value]
                                            local selected={}
                                            for _,v in ipairs(c.options) do if c.selected[v] then table.insert(selected,v) end end
                                            call(c.fn,selected)
                                        end
                                    end
                                end
                            end
                            if c.kind=="toggle" and c.draw[2] and c.tol and c.check then
                                c.anim=mix(c.anim,c.state and 1 or 0,clamp(dt*14,0,1))
                                c.draw[2].Color=mixc(col.off,col.blue,c.anim)
                                c.tol.Color=mixc(col.border,col.borderhot,c.hover)
                                c.tol.Transparency=alpha*(0.38+c.hover*0.3)
                                c.check.Transparency=alpha*c.anim
                            elseif c.kind=="slider" and c.draw[5] then
                                c.draw[5].Radius=7+c.hover*1.3
                            elseif c.kind=="button" and c.draw[2] and c.draw[3] then
                                c.press=mix(c.press or 0,0,clamp(dt*18,0,1))
                                c.draw[2].Color=mixc(c.color or col.off,col.sel,c.hover)
                                local ex=c.hover*1.5-c.press*0.8
                                c.draw[2].Position=Vector2.new(c.x-ex,c.y+3-ex)
                                c.draw[2].Size=Vector2.new(c.w+ex*2,25+ex*2)
                                c.draw[3].Position=Vector2.new(c.x-ex,c.y+3-ex)
                                c.draw[3].Size=Vector2.new(c.w+ex*2,25+ex*2)
                                c.draw[3].Color=mixc(col.border,col.borderhot,c.hover)
                                c.draw[3].Transparency=alpha*(0.3+c.hover*0.45)
                            elseif c.kind=="textbox" and c.draw[2] then
                                c.draw[2].Color=typing==c and col.sel or mixc(col.off,col.card,c.hover)
                            elseif c.kind=="label" and c.pulse and c.draw[1] then
                                local cp=(math.sin(tick()*1.35)+1)/2
                                c.draw[1].Color=mixc(Color3.fromRGB(105,62,145),Color3.fromRGB(185,215,255),cp)
                            end
                            if press and c.kind=="slider" and hov==1 then clickcontrol(c,mx,my) end
                            if tapped and not consumed and c.kind~="slider" and hov==1 then clickcontrol(c,mx,my) end
                        end
                    end

                    local ta=tiptext and 1 or 0
                    tip.alpha=mix(tip.alpha,ta,clamp(dt*12,0,1))
                    if tiptext then
                        local tw=clamp(#tiptext*5.5+20,90,280)
                        tip.tx.Text=tiptext
                        tip.bg.Position=Vector2.new(mx+14,my+16);tip.bg.Size=Vector2.new(tw,28)
                        tip.tx.Position=Vector2.new(mx+23,my+25)
                    end
                    vis(tip.bg,tip.alpha>0.02,alpha*tip.alpha*0.92)
                    vis(tip.tx,tip.alpha>0.02,alpha*tip.alpha)

                    local pulse=(math.sin(tick()*1.8)+1)/2
                    win.gametext.Color=mixc(Color3.fromRGB(255,145,48),col.text,pulse)
                    win.usertext.Color=mixc(Color3.fromRGB(95,185,255),col.text,pulse)

                    if tapped and hit(mx,my,x+railw,y,w-railw,top) then
                        drag=true;dragx=mx;dragy=my
                    end
                    if drag and press then
                        local dx,dy=mx-dragx,my-dragy
                        if math.abs(dx)+math.abs(dy)>0 then reposition(dx,dy);dragx=mx;dragy=my end
                    elseif drag and not press then drag=false end
                end
        end)
        win.render=render
        return win
    end

    function win:SetMenuKey(key)
        menukey=clamp(math.floor(key),1,254)
        return menukey
    end

    function win:GetMenuKey()
        return menukey
    end

    function win:SetPrivacy(state)
        privacy=state==true
        local gn=privacy and "Private" or realgame
        local un=privacy and "Private" or realuser
        win.gametext.Text=gn
        win.usertext.Text=un
        local gx=x+w-305
        win.gametext.Position=Vector2.new(gx+12,y+20)
        win.usertext.Position=Vector2.new(gx+24+#gn*7.5,y+20)
        return privacy
    end

    function win:Toggle(state)
        open=state==nil and not open or state
        target=open and 1 or 0
        return open
    end

    function win:Destroy()
        if dead then return end
        dead=true
        pcall(function() if win.render then win.render:Disconnect() end end)
        clearlist(draws)
        draws={}
    end

    return win
end

_G.UILib=lib
