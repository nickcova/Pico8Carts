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
spawn_wait=75 -- 2.5 segundos
max_utensils=1

up=0
down=1
right=2
left=3

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
		update_frame_count()
	end
end

-- update graphics on screen
function _draw()
	cls(1)
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
	knife.y=flr(rnd(120))  --60 es la mitad
	knife.speed=2
	knife.direction=right --first one goes right
	knife.hitbox={x=0,y=2,w=8,h=3}	
	add(utensils,knife)
end

function move_utensils()
	for ut in all(utensils) do
		if (ut.direction==right) ut.x+=ut.speed
		if (ut.direction==left) ut.x-=ut.speed
		if (ut.direction==up) ut.y-=ut.speed
		if (ut.direction==down) ut.y+=ut.speed

		if (ut.x>=128 or ut.x<=-9) del(utensils,ut)
		if (ut.y>=128 or ut.y<=-9) del(utensils,ut)
	end
end

function update_utensils()
	-- Check if I have to add a new utensil
	if (#utensils<=max_utensils) then
		if (frame_count>0 and frame_count%spawn_wait==0) spawn_utensil=true
	end	

	if (spawn_utensil) then
		local starting_position = getStartingPosition()

		local knife={}
		knife.sprite=starting_position.sprite
		knife.x=starting_position.x
		knife.y=starting_position.y
		knife.speed=2
		knife.direction=starting_position.direction
		knife.hitbox={x=0,y=2,w=8,h=3}
		add(utensils,knife)

		spawn_utensil = false
	end
end

function getStartingPosition()
	local position = {}

	local direction = flr(rnd(4))

	if (direction==up) then
		position.sprite=3
		position.direction=up
		position.y=127
		position.x=flr(rnd(120))
	end

	if (direction==down) then
		position.sprite=3
		position.direction=down
		position.y=-8
		position.x=flr(rnd(120))
	end

	if (direction==right) then
		position.sprite=2
		position.direction=right
		position.y=flr(rnd(120))
		position.x=-8
	end

	if (direction==left) then
		position.sprite=2
		position.direction=left
		position.y=flr(rnd(120))
		position.x=127
	end

	return position
end

function draw_utensils()
	for ut in all(utensils) do
		if (ut.direction==right) spr(ut.sprite,ut.x,ut.y)
		if (ut.direction==left) spr(ut.sprite,ut.x,ut.y,1,1,true)
		if (ut.direction==up) spr(ut.sprite,ut.x,ut.y,1,1,false,true)
		if (ut.direction==down) spr(ut.sprite,ut.x,ut.y)
	end
end
-->8
-- gui functions
function update_score()
	if (frame_count%59==0) score+=1	
end

function draw_score()
	print("score: "..score,44,0,7)
end

function debug()
	print("utensils: "..#utensils,0,0,10)
	--print("game_over: "..tostr(game_over),0,10,10)
	--print("pizza hitboxes: "..#pizza.hitboxes,0,20,10)
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

function update_frame_count()
	if (frame_count<32767) then
		frame_count+=1
	else
		frame_count=0
	end
end
__gfx__
000000000444444000000000000f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004493994400000000000f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700a988999900000000000f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000a98899394445555600655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000a999990fff5556000655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000a988000006660000655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000b988000000000000065000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a90000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
