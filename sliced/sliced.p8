pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- globals and menu state
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

function _init() menu_init() end

function menu_init() 
	_update=menu_update
	_draw=menu_draw
end

function menu_update()
	if (btnp(4)) game_init() --play the game
end

function menu_draw()
	cls(1)
	print("press 🅾️ button to play",20,60)
	print("hay que hacer graficos",20,80)
	print("para esto",20,90)
end
-->8
-- gameplay state
function game_init()
	make_pizza()
	utensils_init()
	_update=game_update
	_draw=game_draw
end

function game_update() 
	move_pizza()
	pizza_boundary_check()
	move_utensils()
	pizza_collision_chk()
	update_utensils()
	update_score()
	update_frame_count()
end

function game_draw() 
	cls(1)
	draw_pizza()
	draw_utensils()
	draw_score()
	debug()
end

-->8
-- tab 2 (game over state)
function gameover_update()    
    if (btnp(4)) then
        pizza={}
        utensils={}
        score=0
        game_over=false
        frame_count=0
        game_init() -- restart the game
    end
end

function gameover_draw()
    print("game over",44,64)
    print("press 🅾️ to try again",24,72)
end
-->8
-- tab 3
-->8
-- tab 4 (player functions)
function make_pizza()
	pizza.x=56
	pizza.y=56
	pizza.sprite=16
	pizza.speed=2
    pizza.vertices={}
    add(pizza.vertices, {x=1,y=1})
    add(pizza.vertices, {x=14,y=1})
    add(pizza.vertices, {x=7,y=14})
end

function draw_pizza()
	if(btn(0)) then pizza.sprite=18
	elseif(btn(1)) then pizza.sprite=20
	elseif(btn(2)) then pizza.sprite=22
	elseif(btn(3)) then pizza.sprite=24
	else pizza.sprite=16
	end

	spr(pizza.sprite,pizza.x,pizza.y,2,2)
end

function move_pizza()
	if (btn(0)) pizza.x-=pizza.speed
	if (btn(1)) pizza.x+=pizza.speed
	if (btn(2)) pizza.y-=pizza.speed
	if (btn(3)) pizza.y+=pizza.speed
end

function pizza_boundary_check()
	if (pizza.x<=0) pizza.x=0
	if (pizza.x>=112) pizza.x=112
	if (pizza.y<=0) pizza.y=0
	if (pizza.y>=112) pizza.y=112
end

function pizza_collision_chk()
	for enemy in all(utensils) do 
        local enemy_vertices={} -- vertices belonging to an enemy's hitbox
        add(enemy_vertices,{x=enemy.x+enemy.hitbox.xoff, y=enemy.y+enemy.hitbox.yoff})
        add(enemy_vertices,{x=enemy.x+enemy.hitbox.xoff+enemy.hitbox.w, y=enemy.y+enemy.hitbox.yoff})
        add(enemy_vertices,{x=enemy.x+enemy.hitbox.xoff, y=enemy.y+enemy.hitbox.yoff+enemy.hitbox.h})
        add(enemy_vertices,{x=enemy.x+enemy.hitbox.xoff+enemy.hitbox.w, y=enemy.y+enemy.hitbox.yoff+enemy.hitbox.h})

        for vertices in all(enemy_vertices) do
            if (is_inside_area(pizza.x+pizza.vertices[1].x,pizza.y+pizza.vertices[1].y,
                                pizza.x+pizza.vertices[2].x,pizza.y+pizza.vertices[2].y,
                                pizza.x+pizza.vertices[3].x,pizza.y+pizza.vertices[3].y,
                                vertices.x, vertices.y)) then
                game_over=true
		        break              
            end
        end

		if (game_over) then
            _update=gameover_update
	        _draw=gameover_draw
            break
        end
	end
end
-->8
-- tab 5 (enemy functions)
function utensils_init()
	local knife={}
	knife.sprite=2
	knife.x=-8
	knife.y=flr(rnd(120))  --60 es la mitad
	knife.speed=2
	knife.direction=right --first one goes right
	knife.hitbox={xoff=0,yoff=3,w=8,h=2}	
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
	-- check if i have to add a new utensil
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
        if (knife.direction==up or knife.direction==down) knife.hitbox={xoff=3,yoff=0,w=2,h=8}
		if (knife.direction==left or knife.direction==right) knife.hitbox={xoff=0,yoff=3,w=8,h=2}
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
-- tab 6 (gui functions)
function update_score()
	if (frame_count%59==0) score+=1	
end

function draw_score()
	print("score: "..score,44,0,7)
end

function debug()
	print("utensils: "..#utensils,0,0,10)
end
-->8
-- tab 7 (other functions)
-- checks if a point (ux,uy) is inside a triangle
function is_inside_area(px1,py1,px2,py2,px3,py3,ux,uy)
    local pizza_area=triangle_area(px1,py1,px2,py2,px3,py3)
    local sub1=triangle_area(ux,uy,px2,py2,px3,py3)
    local sub2=triangle_area(px1,py1,ux,uy,px3,py3)
    local sub3=triangle_area(px1,py1,px2,py2,ux,uy)
    return (pizza_area==sub1+sub2+sub3)
end

-- calculates the area of a triangle
function triangle_area(x1,y1,x2,y2,x3,y3)
    return abs((x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2))/2)
end

function update_frame_count()
	if (frame_count<32767) then frame_count+=1
	else frame_count=0
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044444444440000044444444455000000554444444440000044444444440000055555555555500000000000000000000000000000000000000000000000000
04444444444444400444444444444550055444444444444004499999999994400555555555555550000000000000000000000000000000000000000000000000
0449999999999440049999999994455005544999999999400a998899ffff99900444444444444440000000000000000000000000000000000000000000000000
0a998899f99f9990098899f99f99aa4004aa998899f9f9900a9887899ff993900444444444444440000000000000000000000000000000000000000000000000
0a9887899ff993900987829ff939aa4004aa2887999ff9900aa88889999939a004492299ffff9440000000000000000000000000000000000000000000000000
0a9888899999399000888299939aaa0000aa2888999993000aaa229999939a00099887899ff93990000000000000000000000000000000000000000000000000
00a988999993990000889999399aa400004aa98899993900004aa9399889a4000098888999939a00000000000000000000000000000000000000000000000000
00a999399889990000993988999aa400004aa999399889000004a3998888a4000009883999399000000000000000000000000000000000000000000000000000
000a3399888890000033998882aa40000004aa339288880000044aff8788a0000000339f9939a000000000000000000000000000000000000000000000000000
0000a99f878800000009f97882a4000000004aa99287800000004aa9922940000000a9f992290000000000000000000000000000000000000000000000000000
00000af998800000000f9988aa400000000004aa99988000000044aa999a4000000009f987880000000000000000000000000000000000000000000000000000
00000af999900000000f9999aa000000000000aa999990000000044aaaa4000000000a9f88880000000000000000000000000000000000000000000000000000
000000af990000000000f99aa00000000000000aa999000000000044aa4400000000009998800000000000000000000000000000000000000000000000000000
0000000a90000000000009aa0000000000000000aa9000000000000444400000000000a999900000000000000000000000000000000000000000000000000000
