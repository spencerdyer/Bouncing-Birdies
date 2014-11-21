local storyboard = require( "storyboard" )
fsm = require("fsm")
local scene = storyboard.newScene()
local width = display.contentWidth
local height = display.contentHeight
local scaleX = display.contentScaleX
local scaleY = display.contentScaleY
--storyboard.purgeOnSceneChange = true

-------------------------------------------------------- VARIABLES -------------------------------------------------------
local group, bg, plank, plank2, pig, pig2, ground, bird, tapMsg, score_msg, nextLevel, backButton, backButtonText, slingshot, startTime
local velocityModifier = 5
local numThrows = 0
local score = 0
local maxTaps = 1
local tapCount = 0
local pigCount = 1

local originX
local originY

local sound = audio.loadSound("pop.wav")

local pigSpriteSheet = {
	{sheet = graphics.newImageSheet( "pighappy.png", { width=64, height=55, numFrames=1})},
	{sheet = graphics.newImageSheet( "pigsad.png", { width=64, height=69, numFrames=1})}
}

local pigSeqData = {
	  { name="seq1", sheet=pigSpriteSheet[1].sheet, start=1, count=1, time=1, loopCount=0 },
      { name="seq2", sheet=pigSpriteSheet[2].sheet, start=1, count=1, time=1, loopCount=0 }
}

happyState = {}
sadState = {}
pigTable = {}

---------------------------------------------------------- PHYSICS -------------------------------------------------------
local physics = require("physics")
physics.start()
--physics.setDrawMode ("hybrid")

--------------------------------------------------------- MAIN -----------------------------------------------------------
function scene:createScene( event ) 
	startTime=0
 	group = self.view
	score_msg = display.newText("Score: " .. score, width*.2, height*.05, font, 16)
	score_msg:setFillColor( 0, 0, 0 )
 	placeObjects() 
 	physicsAdding()
 	originX = slingshot.x
	originY = slingshot.y*.8


	
	local function backListener ( event )
		if (event.phase == "ended") then
			storyboard.gotoScene("Start", options)
		end
		return true
	end
	
 	local function goToSceneListener ( event )
 		if (event.phase == "began") then
 			audio.dispose(sound)
			sound = nil
			storyboard.gotoScene("lev3", { effect = "zoomInOutFade", time = 400, params = {curScoree = score}})
 		end
 		return true
 	end
	bird:addEventListener("touch", launchBirdListener)
 	nextLevel:addEventListener ("touch", goToSceneListener)
	backButton:addEventListener("touch", backListener)
end 

------------------------------------------------------ PLACE OBJECTS --------------------------------------------------- 
function placeObjects()
	-- Background and floor objects
	bg = display.newImage ("Background2.png", width/2, height/2)
	bg:scale(scaleX*.7,scaleY*.7)
	floorBox = display.newRect(width/2,height*.9,width*1.5,height*.001)
	floorBox.name = "floor"
	
	-- collision objects
 	plank = display.newImageRect("Plank2.png", 15, 150)
	plank.x = width*.45
	plank.y = height*.55
 	plank2 = display.newImageRect("Plank2.png", 15, 150)
	plank2.x = width*.75
	plank2.y = height*.55
	plank3 = display.newImageRect("Plank.png", 220, 20)
	plank3.x = width*.6
	plank3.y = height*.3
	
	-- slingshot
	slingshot = display.newImage("SlingShot.png", width*.2, height*.75)
	slingshot:scale(scaleX*.6,scaleY*.6)
	
	-- pigs
 	pig = createPig(width*.80, height*.7)  
 	pig2 = createPig(width*.55, height*.7)
	pig3 = createPig(width*.35, height*.7)
	
	-- bird
 	bird =  display.newImageRect("blackbird.png", 32, 32)
	bird.x = slingshot.x
	bird.y = slingshot.y*.8
 	bird.startTime = -1 
	bird.name = "bird"
	
	-- next level button
 	nextLevel = display.newImage("arrow.png", width*.50, height*.50)
	nextLevel:scale(scaleX, scaleY)
	nextLevel.alpha = 0
	
	-- back button + text
	backButton = display.newImage("backArrow.png", width*.07, height*.12)
	backButton:scale(scaleX*.7,scaleY*.7)
	
 	group:insert(bg)
	group:insert(score_msg)
	group:insert(floorBox)
	group:insert(slingshot)
 	group:insert(plank)
 	group:insert(plank2)
	group:insert(plank3)
 	group:insert(pig)
 	group:insert(pig2)
	group:insert(pig3)
 	group:insert(bird)
 	group:insert(nextLevel)
 	group:insert(backButton)
end

----------------------------------------------------- ADD PHYSICS ----------------------------------------------------------
function physicsAdding()
 	physics.addBody(plank)
 	physics.addBody(plank2)
	physics.addBody(plank3)
 	physics.addBody(pig, {radius = 26, friction = .5})
 	physics.addBody(pig2, {radius = 26, friction = .5})
	physics.addBody(pig3, {radius = 26, friction = .5})
 	physics.addBody(floorBox, "static")
 	physics.addBody(bird, "static", {bounce = 0.5})
end

---------------------------------------------------- TIME KEEPER -------------------------------------------------------

function countDown() 
	local currentTime = system.getTimer()
	if (currentTime - startTime > 1) then
		nextLevel.alpha = 1
	end
end

---------------------------------------------------------------------------------------------------------------------

function onCollision(event)
	if event.object1.name ~= "floor" and (event.object2.name == "pig2" or event.object2.name == "pig1" or event.object2.name == "pig3") and event.phase == "ended" then
		audio.play(sound)
		if numThrows == 0 then 
			event.object2:setSequence("seq2")
			event.object2.numHits = 1
			score = score + 50 
		else 
			event.object2:removeSelf()
			event.object2.numHits = 2
			score = score + 100 
		end
		score_msg.text = "Score: " .. score
		numThrows = numThrows + 1
	end
end

--------------------------------------------------------- CREATE PIGS ------------------------------------------------------

function createPig(x, y)
	local pigObject = display.newSprite(pigSpriteSheet[1].sheet, pigSeqData)
	pigObject.homex = x
	pigObject.homey = y
	pigObject.fsm = fsm.new(pigObject)
	pigObject.fsm:changeState ( happyState )
	pigObject.name = "pig" .. pigCount
	pigObject.numHits = 0 
	pigCount = pigCount + 1
	table.insert(pigTable, pigObject)
	return pigObject
end

-------------------------------------------------------- FSM LOGIC --------------------------------------------------------

function happyState:enter(owner)
	owner.x = owner.homex
	owner.y = owner.homey
end

function happyState:execute(owner)
	if owner.numHits == 2 then
		owner.fsm:changeState(sadState)
	end 
end

function happyState:exit(owner)
end

function sadState:enter(owner) 
	Runtime:removeEventListener( "collision", onCollision )
end

function sadState:execute(owner)
end

function sadState:exit(owner)
	Runtime:removeEventListener( "collision", onCollision )
end

---------------------------------------------------------------------------------------------------------------------

function update ( event )
	for i = 1, #pigTable do
		pigTable[i].fsm:update(event)
	end
end

scene:addEventListener( "createScene", scene )
Runtime:addEventListener("collision", onCollision)
Runtime:addEventListener("enterFrame", update)

----------------- New Shit---------------------

function launchBirdListener(event)
	
	local deltaX = 1
	local deltaY = 1

	local distanceFromOrig = 120 
	if (event.phase == "began") or (event.phase == "moved") then
		deltaX = originX - event.x
		deltaY = originY - event.y
		if math.floor(math.sqrt(deltaX*deltaX + deltaY*deltaY)) < distanceFromOrig then
			bird.x = event.x
			bird.y = event.y
		else
			bird.x = originX + 20*math.cos(event.x)
			bird.y = originY + 20*math.sin(event.y)
		end
	end
	if (event.phase == "ended") then
		startTime = system.getTimer()
		deltaX = originX - event.x
		deltaY = originY - event.y
		bird.bodyType = "dynamic"
		bird:setLinearVelocity(deltaX * velocityModifier, deltaY * velocityModifier)
		timer.performWithDelay(2000, countDown, 0)
	end
end
---------------------------------------------------------------------------------------------------------------------

return scene