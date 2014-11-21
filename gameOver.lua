local storyboard = require( "storyboard" )
storyboard.purgeOnSceneChange = true

local scene = storyboard.newScene()
local width = display.contentWidth
local height = display.contentHeight
local bg

function scene:createScene( event )
	local group = self.view
	bg = display.newImage ("end.png", width/2, height/2)
	bg:scale(.3,.3)
	bg.alpha = .9
	local msg = display.newText ("Final Score: " .. event.params.curScoree, width/2, height*.85, font, 20)
	local gameover = display.newText ("GAME OVER", width/2, height*.4, font, 66)
 	msg:setFillColor( 0, 1, 1 )
	gameover:setFillColor(1, 1, 0)
	group:insert(bg)
	group:insert(msg)
	group:insert(gameover)
end

scene:addEventListener ( "createScene", scene)
return scene