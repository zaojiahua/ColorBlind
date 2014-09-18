require "Cocos2d"

local DealData = {}

function DealData:ctor()
    --玩家的得分
    self.score = 0
    --玩家的最高得分
    self.highScore = 0
    --游戏加分
    self.addScore = 100
    --游戏的速率
    self.rate = 10
    --游戏的限制时间
    self.time = 200
end

--Lua单例
function DealData:getInstance()
    local dealData = {}

    --设置元表
    self:ctor()
    local DealData_mt = {__index = self}
    setmetatable(dealData,DealData_mt)

    return dealData
end

--设置以下几个成员变量的值
function DealData:setScore(score)
    self.score = score
    --分数设置完毕设置速率
    self:setRate()
end

--根据分数值来设置rate
function DealData:setRate()
    local rate
    if self.score < 1000 then
        rate = 3
    elseif self.score >= 1000 and self.score < 2000 then
        rate = 2
    elseif self.score >= 2000 and self.score < 3000 then
        rate = 1.8
    elseif self.score >= 3000 and self.score < 3500 then
        rate = 1.5
    elseif self.score >= 3500 and self.score < 4000 then
        rate = 1.3
    elseif self.score >= 4000 and self.score < 5000 then
        rate = 1
    else
        rate = 0.8
    end
    self.rate = rate
end


return DealData