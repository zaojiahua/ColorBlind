require "Cocos2d"
require "Cocos2dConstants"

local WelcomeScene = class("GameScene",
    function ()
        return cc.Scene:create()
    end
)

--构造函数 GameScene调用new的时候会调用这个函数
function WelcomeScene:ctor()
end

--create函数
function WelcomeScene:createScene()
    --创建一个场景和层，将层添加到场景中显示
    local welcomeScene = WelcomeScene:new()
    local layer = welcomeScene:createLayer()
    welcomeScene:addChild(layer)

    --最后返回这个场景
    return welcomeScene;
end

function WelcomeScene:createLayer()
    --创建一个层
    local layer = cc.Layer:create()

    local size = cc.Director:getInstance():getWinSize()
    
    --背景图片
    local bg = cc.Sprite:create("background.png")
    bg:setPosition(size.width/2,size.height/2)
    layer:addChild(bg)
    
    --定义菜单项的回调函数
    local function item1_callback()
        --切换场景
        local gameScene = require("GameScene")
        cc.Director:getInstance():replaceScene(gameScene:createScene())
    end
    local function item2_callback()
        --切换场景
        local aboutScene = require("AboutScene")
        cc.Director:getInstance():pushScene(aboutScene:createScene())
    end
    local item1 = cc.MenuItemLabel:create(cc.Label:createWithTTF("开始游戏","fonts/menu.ttf",42))
    item1:registerScriptTapHandler(item1_callback)
    local item2 = cc.MenuItemLabel:create(cc.Label:createWithTTF("关于游戏","fonts/menu.ttf",42))
    item2:registerScriptTapHandler(item2_callback)
    --创建菜单
    local menu = cc.Menu:create(item1,item2)
    menu:alignItemsVerticallyWithPadding(size.height*0.15)
    
    --添加菜单到游戏中
    layer:addChild(menu)
    
    --监听手机返回键
    local key_listener = cc.EventListenerKeyboard:create()
    
    --返回键回调
    local function key_return(keyCode)
        --结束游戏
        if keyCode == cc.KeyCode.KEY_BACK then
            cc.Director:getInstance():endToLua()
        end
    end
    --lua中得回调，分清谁绑定，监听谁，事件类型是什么
    key_listener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = layer:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,layer)
    
    --最后返回这个层
    return layer
end

--返回这个表，作为一个模块
return WelcomeScene