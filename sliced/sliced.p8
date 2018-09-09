pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- globals
pizza={}
utensils={}
score=0
game_over=false
frame_count=0
spawn_utensil=false

-- setup stuff
function _init()
	make_pizza()
	utensils_init()
end

-- update logic
function _update()
	if not (game_over) then
 	move_pizza()
 	pizza_boundary_check()
 	move_utensils()
 	pizza_collision_chk()
 	update_utensils()
 	update_score()
	end
end

-- update graphics on screen
function _draw()
	cls()
	draw_pizza()
	draw_utensils()
	draw_score()
	debug()
end

-->8
-- player functions
function make_pizza()
	pizza.x=60
	pizza.y=60
	pizza.sprite=1
	pizza.speed=2
	pizza.hitboxes={}
	add(pizza.hitboxes,{x=0,y=0,w=8,h=5})
	add(pizza.hitboxes,{x=3,y=6,w=4,h=3})
end

function draw_pizza()
	spr(pizza.sprite,pizza.x,pizza.y)
end

function move_pizza()
	if (btn(0)) pizza.x-=pizza.speed
	if (btn(1)) pizza.x+=pizza.speed
	if (btn(2)) pizza.y-=pizza.speed
	if (btn(3)) pizza.y+=pizza.speed
end

function pizza_boundary_check()
	if (pizza.x<=0) pizza.x=0
	if (pizza.x+8>=128) pizza.x=120
	if (pizza.y<=0) pizza.y=0
	if (pizza.y+8>=128) pizza.y=120
end

function pizza_collision_chk()
	for enemy in all(utensils) do
		for hit in all(pizza.hitboxes) do
			if (overlap_exists(pizza.x,pizza.y,hit,enemy.x,enemy.y,enemy.hitbox)) then
				game_over=true
				break
			end			
		end
		
		if (game_over) break
	end
end
-->8
-- enemy functions
function utensils_init()
	local knife={}
	knife.sprite=2
	knife.x=-8
	knife.y=60  --flr(rnd(128))
	knife.speed=2
	knife.hitbox={x=0,y=2,w=8,h=3}
	
	add(utensils,knife)
end

function move_utensils()
	for ut in all(utensils) do
		ut.x+=ut.speed
		if (ut.x>=128) del(utensils,ut)
	end
end

function update_utensils()
	if (#utensils<20 and spawn_utensil) then
		local knife={}
 	knife.sprite=2
 	knife.x=-8
 	knife.y=flr(rnd(128))
 	knife.speed=2
 	add(utensils,knife)
	end
end

function draw_utensils()
	for ut in all(utensils) do
		spr(ut.sprite,ut.x,ut.y)
	end
end
-->8
-- gui functions
function update_score()
	if (frame_count==59) then
		score+=1
		frame_count=0
	end
	if (frame_count<59) frame_count+=1
end

function draw_score()
	print("score: "..score,44,0,7)
end

function debug()
	print("utensils: "..#utensils,0,0,10)
	print("game_over: "..tostr(game_over),0,10,10)
	print("pizza hitboxes: "..#pizza.hitboxes,0,20,10)
end
-->8
-- other functions
function overlap_exists(player_x,player_y,player_hb,enemy_x,enemy_y,enemy_hb)
	if (
					player_x+player_hb.x<=enemy_x+enemy_hb.x+enemy_hb.w
					and player_x+player_hb.x+player_hb.w>=enemy_x+enemy_hb.x
					and player_y+player_hb.y<=enemy_y+enemy_hb.y+enemy_hb.h
					and player_y+player_hb.y+player_hb.h>=enemy_y+enemy_hb.y+enemy_hb.h
					) then
		return true
	end
	
	return false	
end
__gfx__
00000000044444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000449399440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700a98899990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000a98899394445555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000a999990fff5556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000a988000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000b988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
