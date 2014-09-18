require "Cocos2d"

--模块的结构和WelcomeScene的结构是相同的，所有的模块都是这么写
local GameScene = class("GameScene",
    function ()
        return cc.Scene:create()
    end
)

--GameScene调用new的时候会调用这个函数
function GameScene:ctor()
    --定义都有哪些颜色的文本值
    self.colorLabel = {"红","橙","黄","绿","蓝","紫","黑"}
    --初始化颜色的RGB值
    self.color = {
        {r=255,g=0,b=0},{r=255,g=97,b=0},{r=255,g=255,b=0},
        {r=0,g=255,b=0},{r=0,g=0,b=255},{r=128,g=0,b=128},{r=0,g=0,b=0}
    }
    --初始化屏幕大小
    self.size = cc.Director:getInstance():getWinSize()
    --这几个值都作为GameScene的成员，应该叫做表里边的项
    self.manu = true
    --操作数据的成员
    self.dealData = require("DealData"):getInstance()
end

function GameScene:createScene()
    --和WelcomeScene类似
    local gameScene = GameScene:new()
    local layer = gameScene:createLayer()
    gameScene:addChild(layer)
    
    return gameScene
end

--创建一个主游戏层
function GameScene:createLayer()
    local layer = cc.Layer:create()
    
    --创建背景
    local bg = cc.Sprite:create("game_bg.png")
    bg:setPosition(self.size.width/2,self.size.height/2)
    layer:addChild(bg)
    
    --显示上边的ui
    self:show_ui(layer)
    
    --播放游戏开始之前的动画
    self:beginAnimation(layer)
    
    --开始游戏的主逻辑
    self:mainLogic(layer)
    
    --监听手机返回键
    self:return_key(layer)
    
    --添加俩个button
    self:addButton(layer)
    
    return layer
end

--用户选择正确以后的回调函数
function GameScene:correct_callback()
    --如果是通过按钮调用的schedule_callback函数，则设置manu为真
    self.manu = true
    --设置得分
    self.score_callback()
    --设置速率
    self.rate_callback()
    --立刻出现下一个文本
    self.schedule_callback()
    --重新设置schedule函数
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleLogicID)
    self.scheduleLogicID= cc.Director:getInstance():getScheduler():scheduleScriptFunc(self.schedule_callback,self.dealData.rate,false)
end

--用户选择错误以后的回调函数
function GameScene:wrong_callback()
    --停止调用周期性的回调函数
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleLogicID)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleTimerID)
    --切换场景
    local scene = require("GameOverScene")
    cc.Director:getInstance():replaceScene(scene:createScene())
end

--添加按钮
function GameScene:addButton(layer)
    --创建button
    local function scale9_normal()
        return cc.Scale9Sprite:create("buttonBackground.png")
    end
    local function scale9_press() 
        return cc.Scale9Sprite:create("buttonHighlighted.png")
    end
    --文本信息
    self.button1_label = cc.Label:createWithTTF("Ready","fonts/label.TTF",32)
    self.button2_label = cc.Label:createWithTTF("Ready","fonts/label.TTF",32)
    self.button3_label = cc.Label:createWithTTF("Ready","fonts/label.TTF",32)
    --button1
    local button1 = cc.ControlButton:create(self.button1_label,scale9_normal())
    button1:setBackgroundSpriteForState(scale9_press(),cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    button1:setTag(1)
    button1:setPosition(self.size.width*0.2,self.size.height*0.2)
    --button2
    local button2 = cc.ControlButton:create(self.button2_label,scale9_normal())
    button2:setBackgroundSpriteForState(scale9_press(),cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    button2:setTag(2)
    button2:setPosition(self.size.width*0.5,self.size.height*0.2)
    --button3
    local button3 = cc.ControlButton:create(self.button3_label,scale9_normal())
    button3:setBackgroundSpriteForState(scale9_press(),cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    button3:setTag(3)
    button3:setPosition(self.size.width*0.8,self.size.height*0.2)
   
    --设置button的回调函数
    local button_callback = function (ref,button)
        --如果正确跟新分数
        if self.correct == ref:getTag() then
            self:correct_callback()
        else
            self:wrong_callback()
        end
    end

    --设置回调函数
    button1:registerControlEventHandler(button_callback,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
    button2:registerControlEventHandler(button_callback,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
    button3:registerControlEventHandler(button_callback,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
    
    --添加到层中
    layer:addChild(button1)
    layer:addChild(button2)
    layer:addChild(button3)
end

--游戏的主逻辑
function GameScene:mainLogic(layer)
    --该函数完成游戏的主要逻辑，每隔一段时间调用改变文本信息
    self.schedule_callback = function (time)
        --如果是系统自己调用的这个函数，说明时间已经过去，则游戏结束
        if self.manu == false then
            self:wrong_callback()
        end
        --如果层上有字，则移除
        if(layer:getChildByTag(10) ~= nil) then
            local move = cc.MoveBy:create(0.2,{x=-self.size.width/2,y=0})
            local clear = cc.RemoveSelf:create()
            --移除动画
            layer:getChildByTag(10):runAction(cc.Sequence:create(move,clear))
        end

        --以下是lua中设置随机数的方法
        math.randomseed(os.time())
        --俩个参数代表的是范围，包括起始值和结束值
        local x = math.random(1,7)
        --根据返回的随机的值创建一个文本字体
        local label = cc.Label:createWithTTF(self.colorLabel[x],"fonts/label.TTF",40)
        label:setPosition(self.size.width+label:getContentSize().width/2,self.size.height*0.6)
        layer:addChild(label)
        --需要给文本设置一个颜色，颜色也是随机的，但是和文本内容表示的颜色不同
        local y = math.random(1,7)
        while x == y do
            y = math.random(1,7)
        end
        label:setColor(self.color[y])
        --执行从左到右的动作
        local move = cc.MoveBy:create(0.2,{x=-self.size.width/2-label:getContentSize().width/2,y=0})
        --设置Label的tag
        label:setTag(10)
        label:runAction(move)
        --设置第三个按钮的文本信息，和前俩个都不一样
        local z = math.random(1,7)
        while z == x or z == y do
            z = math.random(1,7)
        end
        
        --设置底下按钮的文本信息，同样是随机的 产生一个随机的值，代表哪个按钮的内容是正确的
        self.correct = math.random(1,3)
        if self.correct == 1 then
            --将第一个按钮显示的文本设置为正确的答案 correct等于1，代表第一个按钮的内容是正确的
            self.button1_label:setString(self.colorLabel[x])
            --将另外俩个按钮的文本信息进行随机的设置
            if math.random(1,2) == 1 then
                self.button2_label:setString(self.colorLabel[y])
                self.button3_label:setString(self.colorLabel[z])
            else
                self.button2_label:setString(self.colorLabel[z])
                self.button3_label:setString(self.colorLabel[y])
            end
        elseif self.correct == 2 then
            self.button2_label:setString(self.colorLabel[x])
            --将另外俩个按钮的文本信息进行随机的设置
            if math.random(1,2) == 1 then
                self.button1_label:setString(self.colorLabel[y])
                self.button3_label:setString(self.colorLabel[z])
            else
                self.button1_label:setString(self.colorLabel[z])
                self.button3_label:setString(self.colorLabel[y])
            end
        else
            self.button3_label:setString(self.colorLabel[x])
            --将另外俩个按钮的文本信息进行随机的设置
            if math.random(1,2) == 1 then
                self.button1_label:setString(self.colorLabel[y])
                self.button2_label:setString(self.colorLabel[z])
            else
                self.button1_label:setString(self.colorLabel[z])
                self.button2_label:setString(self.colorLabel[y])
            end
        end
        
        self.manu = false
    end
end

--游戏开始之前的动画
function GameScene:beginAnimation(layer)
    --游戏开始之前的文本说明
    local instruction = cc.Label:createWithTTF("请选择文本内容所代表的颜色","fonts/label.TTF",24)
    instruction:setPosition(self.size.width/2,self.size.height/2)
    layer:addChild(instruction)
    --ready文本
    local ready = cc.Label:createWithTTF("Ready","fonts/label.TTF",40)
    ready:setPosition(self.size.width/2,self.size.height*0.6)
    ready:setVisible(false)
    layer:addChild(ready)
    --go文本
    local go = cc.Label:createWithTTF("Go!","fonts/label.TTF",40)
    go:setPosition(self.size.width/2,self.size.height*0.6)
    go:setVisible(false)
    layer:addChild(go)
    
    --ready和go的回调函数 函数可以有俩个参数，第一个代表接受动作的对象，就是谁执行了动作，第二个是传过来的参数，全部放到了表中
    local go_action = function(actionSelf,tab)
        go:setVisible(true)
        local spawn = cc.Spawn:create(cc.ScaleBy:create(0.4,1.5),cc.FadeOut:create(0.5))
        --执行一个动作序列
        local action = cc.Sequence:create(spawn,cc.RemoveSelf:create(),
        cc.CallFunc:create(
        function()
                    --保存schedule的ID，场景跳转的时候记得要停掉schedule
            self.scheduleTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(self.timer_callback,1,false)
            --调用主逻辑函数，实现程序的主逻辑
            self.schedule_callback()
            self.scheduleLogicID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(self.schedule_callback,self.dealData.rate,false)
            --关闭触摸屏蔽
            local eventDispatch = layer:getEventDispatcher()
            eventDispatch:removeEventListener(self.listener_touch)
        end)
        )
        --执行动画完毕，开启时钟计时
        go:runAction(action)
    end
    local  ready_action = function()
       ready:setVisible(true)
       local action = cc.Sequence:create(cc.ScaleBy:create(0.2,1.4),
                                            cc.ScaleBy:create(0.2,0.6),
                                            cc.ScaleBy:create(0.1,1.1),
                                            cc.ScaleBy:create(0.1,1),
                                            cc.CallFunc:create(go_action),
                                            cc.RemoveSelf:create())                                
       ready:runAction(action)
    end
    
    --动画
    local spawn = cc.Spawn:create(cc.MoveTo:create(1,{x=self.size.width/2,y=self.size.height*0.8}),cc.FadeOut:create(2))
    local sequence = cc.Sequence:create(cc.FadeIn:create(2),spawn,cc.CallFunc:create(ready_action),cc.RemoveSelf:create())
    instruction:runAction(sequence)
    
    --在游戏开始之前屏蔽触摸
    self.listener_touch = cc.EventListenerTouchOneByOne:create()
    --吞噬触摸
    self.listener_touch:setSwallowTouches(true)
    self.listener_touch:registerScriptHandler(function()return true end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatch = layer:getEventDispatcher()
    eventDispatch:addEventListenerWithFixedPriority(self.listener_touch,-1)
end

--显示主游戏场景上边的UI
function GameScene:show_ui(layer)
    --做一个时钟，显示在右上角
    local time = self.dealData.time
    local time_label
    self.timer_callback = function()
        time = time-1
        time_label:setString("Time:"..time)
        --时间到，游戏结束
        if time == -1 then
        --先关闭定时器
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleTimerID)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleLogicID)
        --跳转场景
        cc.Director:getInstance():replaceScene(require("GameOverScene"):createScene())
        end
    end
    time_label = cc.Label:createWithTTF("Time:"..time,"fonts/label.TTF",25)
    time_label:setPosition(self.size.width*0.85,self.size.height*0.9)
    layer:addChild(time_label)

    --做一个速率，显示在左上角
    local rate = self.dealData.rate
    local rate_label
    self.rate_callback = function()
        --速率是由分数来控制的
        if rate ~= self.dealData.rate then
            rate = self.dealData.rate
        else
            return
        end
        rate_label:setString("Rate:"..rate)
        local sequence = cc.Sequence:create(
            cc.ScaleTo:create(0.1,1.3),
            cc.ScaleTo:create(0.2,0.8),
            cc.ScaleTo:create(0.1,1.1),
            cc.ScaleTo:create(0.1,1))
        rate_label:runAction(sequence)
    end
    rate_label = cc.Label:createWithTTF("Rate:"..rate,"fonts/label.TTF",25)
    rate_label:setPosition(self.size.width*0.15,self.size.height*0.9)
    layer:addChild(rate_label)
    
    --分数，显示在中间
    local score = self.dealData.score
    local score_label
    self.score_callback = function()
        --改变玩家的游戏得分
        score = score + self.dealData.addScore
        self.dealData:setScore(score)
        score_label:setString(score)
        --执行动作
        local sequence = cc.Sequence:create(
            cc.ScaleTo:create(0.1,1.3),
            cc.ScaleTo:create(0.1,0.7),
            cc.ScaleTo:create(0.1,1.2),
            cc.ScaleTo:create(0.1,1))
        score_label:runAction(sequence)
    end
    score_label = cc.Label:createWithBMFont("fonts/futura-48.fnt",score)
    score_label:setPosition(self.size.width*0.5,self.size.height*0.9)
    layer:addChild(score_label)
end

--监听手机返回键
function GameScene:return_key(layer)
    --监听手机返回键
    local key_listener = cc.EventListenerKeyboard:create()
    --返回键回调
    local function key_return()
        local scene = require("WelcomeScene")
        cc.Director:getInstance():replaceScene(scene:createScene())
        --关闭触摸屏蔽
        local eventDispatch = layer:getEventDispatcher()
        eventDispatch:removeEventListener(self.listener_touch)
    end
    --lua中得回调，分清谁绑定，监听谁，事件类型是什么
    key_listener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = layer:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,layer)
end

--返回模块
return GameScene