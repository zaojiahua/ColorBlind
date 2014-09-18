require "Cocos2d"

--模块的结构和WelcomeScene的结构是相同的，所有的模块都是这么写
local AboutScene = class("AboutScene",
    function ()
        return cc.Scene:create()
    end
)

function AboutScene:ctor()
    self.size = cc.Director:getInstance():getWinSize()
end

function AboutScene:createScene()
    --和WelcomeScene类似
    local aboutScene = AboutScene:new()
    local layer = aboutScene:createLayer()
    aboutScene:addChild(layer)

    return aboutScene
end

function AboutScene:createLayer()
    local layer = cc.Layer:create()
    
    --背景
    local background = cc.Sprite:create("background.png")
    background:setPosition(self.size.width/2,self.size.height/2)
    layer:addChild(background)
    
    
    
    
    
    
    
    
    
    --监听手机返回键
    self:return_key(layer)
    
    return layer
end

function AboutScene:return_key(layer)
    --监听手机返回键
    local key_listener = cc.EventListenerKeyboard:create()
    --返回键回调
    local function key_return()
        cc.Director:getInstance():popScene();
    end
    --lua中得回调，分清谁绑定，监听谁，事件类型是什么
    key_listener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = layer:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,layer)
end

return AboutScene