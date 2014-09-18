require "Cocos2d"

local GameOverScene = class("LoadingScene",
    function ()
        return cc.Scene:create()
    end
)

function GameOverScene:ctor()

end

local createLayer

function GameOverScene:createScene()
    local gameScene = GameOverScene:new()
    local layer = gameScene:createLayer()
    gameScene:addChild(layer)
    return gameScene
end

function GameOverScene:createLayer()
    local layer = cc.Layer:create()

    self.size = cc.Director:getInstance():getWinSize()
    
    --bg
    local bg = cc.Sprite:create("game_bg.png")
    bg:setPosition(self.size.width/2,self.size.height/2)
    layer:addChild(bg)
    
    --添加游戏结束的文本信息
    local game_over = cc.Label:createWithTTF("Game Over","fonts/menu.ttf",30)
    game_over:setPosition(self.size.width/2,self.size.height*0.8)
    layer:addChild(game_over)
    
    --添加俩个按钮
    self:addButton(layer)

    return layer
end

function GameOverScene:addButton(layer)
    --定义菜单项的回调函数
    local function item1_callback()
        --切换场景
        local welcomeScene = require("WelcomeScene")
        cc.Director:getInstance():replaceScene(welcomeScene:createScene())
    end
    local function item2_callback()
        --分享游戏
        
    end
    local item1 = cc.MenuItemLabel:create(cc.Label:createWithTTF("回到游戏","fonts/menu.ttf",42))
    item1:registerScriptTapHandler(item1_callback)
    local item2 = cc.MenuItemLabel:create(cc.Label:createWithTTF("分享得分","fonts/menu.ttf",42))
    item2:registerScriptTapHandler(item2_callback)
    --创建菜单
    local menu = cc.Menu:create(item1,item2)
    menu:setPositionY(self.size.height*0.35)
    menu:alignItemsHorizontallyWithPadding(self.size.height*0.1)
    
    layer:addChild(menu)
end


return GameOverScene