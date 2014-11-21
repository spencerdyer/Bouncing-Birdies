local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local width = display.contentWidth
local height = display.contentHeight
-- Scaling Variables
local scaleX = display.contentScaleX
local scaleY = display.contentScaleY
local options = { effect = "zoomInOutFade", time = 400 }

function scene:createScene( event )
    local group = self.view
    local background = display.newImage("Background.png", width/2, height/2)
    background:scale(scaleX*.7,scaleY*.7)
    local begin = display.newImage("PlayButton.png", width*.85, height*.80)
    begin:scale(.5,.5)
    begin.alpha = 0.80
  	group:insert(background)   
  	group:insert(begin) 
  	local msg = display.newText ("Bouncing Birdies", width*.25, height*.1, font, 22)
	local msg2 = display.newText ("By Spencer Dyer & Nicholas Rebhun", width*.35, height*.18, font, 14)
  	group:insert (msg)
	group:insert (msg2)

  	local function beginListener (event)
 		if (event.phase == "began") then
 			storyboard.gotoScene ("lev1", options)
 		end
 		return true
 	end
 	begin:addEventListener ("touch", beginListener)
end

function scene:exitScene( event )
	Runtime:removeEventListener("enterFrame", self.onUpdate)
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "exitScene", scene)
return scene