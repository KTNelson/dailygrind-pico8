pico-8 cartridge // http://www.pico-8.com
version 5
__lua__

-------------------- startup

gamestate = "title"

framecount = 0
timertext = "7:0"
timervar = 0
timervarx = 119
active_task_countdown = 0.0
active_task_countup = 0
task_is_counting_down = false
task_is_counting_up = false
use_alternate_text = false

time_spent_brushing = 0
time_spent_watching_tv = 0

dog_fed = false
laundry_on = false

warning_index = 0


additional_objectives_text = {}
additional_objectives_text[1] = "you shouldn't go to work\
on an empty stomach"
additional_objectives_text[2] = "why not listen to the breakfast\
show?"
additional_objectives_text[3] = "your running low on pants"
additional_objectives_text[4] = "a dogs not just for christmas"
additional_objectives_text[5] = "whats on the idiot box?"
additional_objectives_text[6] = "that plants looking a bit brown"
additional_objectives_text[7] = "whats that smell..."
additional_objectives_text[8] = "don't get caught short"
additional_objectives_text[9] = "your dentist won't be happy"
additional_objectives_text[10] = "how about a little pick me up?"
additional_objectives_text[11] = "the developer has fucked up here"


task_complete_text = {}
task_complete_text[1] = "breakfast is served!"
task_complete_text[2] = ""
task_complete_text[3] = "dirty clothes vanquished\
laundry complete!"
task_complete_text[4] = "the dog will eat today."
task_complete_text[5] = "wow, tv is amazing"
task_complete_text[6] = "the plant will live another day"
task_complete_text[7] = "you smell...better"
task_complete_text[8] = "you feel relieved."
task_complete_text[9] = "clean and pearly white"
task_complete_text[10] = "what would you do without coffee?"

alternate_complete_text = {}
alternate_complete_text[1] = "you overbrushed, be more careful!"
alternate_complete_text[2] = "you rushed that a bit..."
alternate_complete_text[3] = "that was hardly worth the effort"
alternate_complete_text[4] = "oh no, you lost track of time"

task_active_text = {}
task_active_text[1] = "makin' breakfast!"
task_active_text[2] = ""
task_active_text[3] = "washing up!"
task_active_text[4] = ""
task_active_text[5] = "ah tv, soother of all problems"
task_active_text[6] = ""
task_active_text[7] = "scrub, scrub!"
task_active_text[8] = "..."
task_active_text[9] = "brush brush brush"
task_active_text[10] = "come on coffee!"

task_skill_upgrade_text = {}
task_skill_upgrade_text[1] = "making breakfast"
task_skill_upgrade_text[2] = "turning on the radio"
task_skill_upgrade_text[3] = "doing laundry"
task_skill_upgrade_text[4] = "feeding the dog"
task_skill_upgrade_text[5] = "watching tv"
task_skill_upgrade_text[6] = "watering the plant"
task_skill_upgrade_text[7] = "showering..."
task_skill_upgrade_text[8] = "you know, the bathroom"
task_skill_upgrade_text[9] = "brushing your teeth"
task_skill_upgrade_text[10] = "making coffee"

tasks = {}


function make_task(p_name, p_type, p_id, p_index, p_task_time, p_skill_target, p_warning_day, p_score_modifier)
    t = {}
    t.name = p_name
    t.type = p_type
    t.id = p_id
    t.complete = false
    t.index = p_index
    t.task_time = p_task_time
    t.task_skill = p_skill_target
    t.newly_skilled = false
    t.alternate_text = ""
    t.days_since_completion = 0
    t.warning_day = p_warning_day
    t.score_modifier = p_score_modifier
    add(tasks, t)
end

actor = {} --all actors in world

function make_actor(x, y)
 a={}
 a.x = x
 a.y = y
 a.dx = 0
 a.dy = 0
 a.spr = 16
 a.t = 0
 a.inertia = 0.6
 a.bounce  = 1
 
 -- half-width and half-height
 a.w = 0.2
 a.h = 0.2
 
 add(actor,a)
 
 return a
end

dog_waypoints = {}

function make_dog_waypoints(p_x, p_y)
 a={}
 a.x = p_x
 a.y = p_y
 add(dog_waypoints,a)
end

function init_tasks()
  make_task("make your breakfast", "set time", 17, 1, 5, 2, 5, 6)
  make_task("turn on/off the radio", "one shot", 33, 2, 0, 8, 10, 2)
  make_task("do your laundry", "set time", 65, 3, 10, 3, 6, 3)
  make_task("feed your dog", "one shot", 129, 4, 0, 9, 2, 6)
  make_task("watch the lovely tv", "continuous", 49, 5, 5, 5, 11, 2)
  make_task("water the hydrangea", "one shot", 81, 6, 0, 6, 3, 2)
  make_task("take a shower", "set time", 145, 7, 12, 4, 20, 8)
  make_task("relieve yourself", "set time", 113, 8, 4, 6, 6, 5)
  make_task("brush your teeth", "continuous", 177, 9, 3, 7, 20, 8)
  make_task("make a decent coffee", "set time", 241, 10, 8, 1, 20, 8)
  make_task("go to work", "one shot", 193, 2, 0, 99, 1, 0)
end

function reset_tasks()
  for tsk in all(tasks) do
       if tsk.complete then
         tsk.complete = false
         tsk.days_since_completion = 0
       else
         tsk.days_since_completion += 1;
       end
     end
end

function init_dog_waypoints()
  make_dog_waypoints(11.5,8.5)
  make_dog_waypoints(11.5,6.5)
  make_dog_waypoints(8,6.5)
  make_dog_waypoints(8,4)
  make_dog_waypoints(5.5,4)
end

dog = {}

function make_task_sprite(p_x, p_y, p_sprite)
  local ts = {}
  ts.x = p_x
  ts.y = p_y
  ts.spr = p_sprite
  return ts
end

function make_dog()
  dog.x = 13.5
  dog.y = 8.5
  dog.dx = 0
  dog.dy = 0
  dog.spr = 18
  dog.target_waypoint = 1
end

tv = {}
function make_tv()
  tv.x = 11.5
  tv.y = 10.5
  tv.spr = 44
end

washer = {}
function make_washer()
  washer.x = 1.5
  washer.y = 5.5
  washer.spr1 = 14
  washer.spr2 = 15
  washer.spr3 = 30
  washer.spr4 = 31
  washer.update = 0
end

function _init()
 -- make player top left
  pl = make_actor(2.6,11.5)
  pl.spr = 49
  
  make_dog()
  make_tv()
  make_washer()
  plant = make_task_sprite(10.5, 8.5, 27)
  cooker = make_task_sprite(6.5, 1.5, 23)
  sink = make_task_sprite(14.5, 3.5, 35)
  radio = make_task_sprite(8.5, 1.5, 25)
  init_tasks()
  init_dog_waypoints()
  music(0, 10)
end
--------------------------------------- collision

-- for any given point on the
-- map, true if there is wall
-- there.
task = false
current_task = nil
function solid(x, y)

 -- grab the cell value
 val=mget(x, y)
 
 -- check if flag 1 is set (the
 -- orange toggle button in the 
 -- sprite editor)

   if fget(val) > 1 then
       for tsk in all(tasks) do
         if tsk.id == fget(val) then
           task = true
           current_task = tsk
           current_task.x = pl.x
           current_task.y = pl.y
         end
       end
   end
   
 return fget(val, 0)
 
end

-- solid_area
-- check if a rectangle overlaps
-- with any walls

--(this version only works for
--actors less than one tile big)

function solid_area(x,y,w,h)

 return 
  solid(x-w,y-h) or
  solid(x+w,y-h) or
  solid(x-w,y+h) or
  solid(x+w,y+h)
end

-- checks both walls and tasks
function solid_a(a, dx, dy)
 if solid_area(a.x+dx,a.y+dy,
    a.w,a.h) then
    return true end
 return false
end

function move_actor(a)

 -- only move actor along x
 -- if the resulting position
 -- will not overlap with a wall

 if not solid_a(a, a.dx, 0) 
 then
  a.x += a.dx
 else   
  -- otherwise bounce
  a.dx *= -a.bounce

 end

 -- ditto for y

 if not solid_a(a, 0, a.dy) then
  a.y += a.dy
 else
  a.dy *= -a.bounce

 end
 
 -- apply inertia
 -- set dx,dy to zero if you
 -- don't want inertia
 
 a.dx *= a.inertia
 a.dy *= a.inertia

 a.t += 1
 
end

function distance(ax, ay, bx, by)
   delta_x = abs(ax-bx)
   delta_y = abs(ay-by)
   delta_x = delta_x * delta_x
   delta_y = delta_y * delta_y

   return sqrt(delta_x + delta_y)
end



function control_player(pl)

 -- how fast to accelerate
 accel = 0.1
 if (btn(0)) then
  pl.dx -= accel
  pl.spr = 51
 end 
 if (btn(1)) then
  pl.dx += accel
  pl.spr = 52
 end 
 if (btn(2)) then
  pl.dy -= accel
  pl.spr = 49
 end 
 if (btn(3)) then
  pl.dy += accel
  pl.spr = 50
 end 
 if task then 
   if distance(pl.x, pl.y, current_task.x, current_task.y) > 1 then
     task = false
     current_task = nil
     use_alternate_text = false
   end
 end
end
-----------------------------------------  tasks

function try_do_task()
  if current_task.complete == false then
    play_task_sfx(current_task.name)
    if current_task.type == "continuous" then
      task_is_counting_up = true
    end
    if current_task.type == "one shot" then
      if current_task.name == "feed your dog" then
        dog_fed = true
      end
      if current_task.name == "turn on/off the radio" then
        if btnp(5) then
          if current_task.complete == false then
            current_task.complete = true
            radio.spr = 63
            music(5, 10)
            current_task.task_skill -= 1
          else
            current_task.complete = false
            radio.spr = 25
            music(-1)
          end
        end
      else 
        current_task.complete = true
        current_task.task_skill -= 1
      end
      if current_task.task_skill == 0 then
        current_task.newly_skilled = true
      end
    end
    if current_task.type == "set time" then
      active_task_countdown = current_task.task_time
      task_is_counting_down = true
    end
    if current_task.name == "go to work" then
      tasks[11].days_since_completion = 0
      gamestate = "result"
      music(-1)
    end 
  end
end

function rate_dental_hygiene()
  
  if time_spent_brushing < current_task.task_time then
    current_task.complete = false  
  end
  local val = current_task.task_time - time_spent_brushing
  if val < 0 then
    use_alternate_text = true
    current_task.alternate_index = 1
  elseif val > 0 then  
    use_alternate_text = true
    current_task.alternate_index = 2
  end 
end

function rate_enjoyment_level()
  if time_spent_watching_tv < current_task.task_time then
    current_task.complete = false  
  end
  local val = current_task.task_time - time_spent_watching_tv
  if val > 0 then
    use_alternate_text = true
    current_task.alternate_index = 3
  elseif val < 0 then  
    use_alternate_text = true
    current_task.alternate_index = 4
  end 
end

function end_task()
  current_task.complete = true
  current_task.task_skill -= 1
  if current_task.task_skill == 0 then
    current_task.newly_skilled = true
  end
  if current_task.name == "brush your teeth" then
    time_spent_brushing = active_task_countup
    rate_dental_hygiene()
    sink.spr = 35
  elseif current_task.name == "watch the lovely tv" then
    time_spent_watching_tv = active_task_countup
    rate_enjoyment_level()
    tv.spr = 44
  end
  active_task_countup = 0
  task_is_counting_up = false
end

function any_skill_up()
  for tsk in all(tasks) do
    if tsk.newly_skilled == true then
        return task_skill_upgrade_text[tsk.index]
    end          
  end
  return "no skill up"
end

function play_task_sfx(task_name)
  if task_name == "make your breakfast" then
    sfx(17, 0)
  elseif task_name == "brush your teeth" and task_is_counting_up == false then
    sfx(12, 0)
  elseif task_name == "take a shower" then
    sfx(13, 0)
  elseif task_name == "feed your dog" then
    sfx(14, 0)
  elseif task_name == "watch the lovely tv" and task_is_counting_up == false then
    sfx(15, 0)
  elseif task_name == "do your laundry" then
    sfx(16, 0)
  elseif task_name == "make a decent coffee" then
    sfx(18, 0)
  elseif task_name == "go to work" then
    sfx(19, 0)
  elseif task_name == "relieve yourself" then
    sfx(20, 0)
  end
end

-----------------------------------------  update
function capture_game_buttons()
  if task then
    if btn(5) then
      try_do_task()
    elseif task_is_counting_up then -- counting up but no button, must be a repeaat
      end_task()
    end
  end
end

function capture_menu_buttons()
  if btnp(4) then -- z button
    sfx(10, 1)
    if gamestate == "alarm" then
      gamestate = "game"
      music(-1)
    elseif gamestate == "title" then
      gamestate = "intro1"
    elseif gamestate == "intro1" then
      gamestate = "intro2"
    elseif gamestate == "intro2" then
      gamestate = "intro3"
    elseif gamestate == "intro3" then
      gamestate = "intro4"
    elseif gamestate == "intro4" then
      gamestate = "alarm"
    elseif gamestate == "result" then
      warning_index = 0
      reset_game()
      gamestate = "alarm"
      sfx(-1)
      sfx(0, 1)
      for tsk in all(tasks) do
      if tsk.newly_skilled == true then
          tsk.newly_skilled = false
      end          
    end
  end
    
  end
  if btnp(5) then
    if gamestate == "failure" then
      run()
    end
  end
end

function reset_game()
  timertext = "7:0"
  timervar = 0
  timervarx = 119
  framecount = 0
  pl.x = 2.6
  pl.y = 11.5
  current_task = nil
  task = false
  reset_tasks()
  dog_waypoints = {}
  init_dog_waypoints()
  make_dog()
  make_washer()
  radio = make_task_sprite(8.5, 1.5, 25)
  laundry_on = false
  use_alternate_text = false
end

function update_timer()
  if timervar == 60 then
    gamestate = "failure"
    music(-1)
  end

  if framecount % 15 == 0 and framecount ~= 0 then
    timervar += 1
  end
  if timervar >= 10 then
    timertext = "7:"
    timervarx = 115
  end
end

function countdown_task()
  if active_task_countdown <= 0 then
    task_is_counting_down = false
    current_task.complete = true
    current_task.task_skill -= 1
    if current_task.task_skill == 0 then
      current_task.task_time /= 2
      current_task.newly_skilled = true
    end
    if current_task.name == "do your laundry" then
      laundry_on = true
      washer.spr3 = 46
      washer.spr4 = 47
    end 
  elseif framecount % 15 == 0 and framecount ~= 0 then
    active_task_countdown -= 1
  end
end

function countup_task()
  if framecount % 15 == 0 and framecount ~= 0 then
    active_task_countup += 1
  end
end

function update_dog()
  local dog_acel = 0.1
  if dog_fed then
    if dog.x > dog_waypoints[dog.target_waypoint].x then
      dog.dx -= dog_acel
      dog.x += dog.dx
      dog.spr = 18
      if dog.x <= dog_waypoints[dog.target_waypoint].x then
        dog.dx = 0
        dog.target_waypoint += 1
        if dog.target_waypoint == 6 then
          dog_fed = false
          return
        end
      end
    end
    if dog.y > dog_waypoints[dog.target_waypoint].y then
      dog.dy -= dog_acel
      dog.y += dog.dy
      dog.spr = 20
      if dog.y <= dog_waypoints[dog.target_waypoint].y then
        dog.dy = 0
        dog.target_waypoint += 1
        if dog.target_waypoint == 6 then
          dog_fed = false
          return
        end
      end
    end
  end
end

function update_tv()
  if task then 
    if current_task.name == "watch the lovely tv" and not current_task.complete and active_task_countup > 0 then
      if tv.spr == 45 then
        tv.spr = 60
      else
        tv.spr = 45
      end
    end
  end
end

function update_laundry()
  if laundry_on then
    if washer.update <= 2 then
      washer.spr1 = 64
      washer.spr2 = 65
    else
      washer.spr1 = 80
      washer.spr2 = 81
    end
    washer.update += 1
    if washer.update == 6 then 
      washer.update = 0
    end
  end
end

function update_plant()
  if tasks[6].days_since_completion > 3 and not tasks[6].complete then
    plant.spr = 61
  else
    plant.spr = 27
  end
end

function update_cooker()
  if task then
    if current_task.name == "make your breakfast" and task_is_counting_down then
      cooker.spr = 62
    else
      cooker.spr = 23
    end
  end
end

function update_sink()
  if task then 
    if current_task.name == "brush your teeth"  and not current_task.complete and active_task_countup > 0 then
      if sink.spr == 67 then
        sink.spr = 68
      else
        sink.spr = 67
      end
    end
  end
end

function update_tasks()
  update_dog()
  update_tv()
  update_laundry()
  update_plant()
  update_cooker()
  update_sink()
end


function _update()
  if gamestate == "game" then
    if task_is_counting_down == true then
      countdown_task()
    elseif task_is_counting_up == true then
      countup_task()
      capture_game_buttons()
    else
  	   control_player(pl)
       foreach(actor, move_actor)
  	   capture_game_buttons()
    end
    update_timer()
    update_tasks()
    framecount+=1
  end

  if gamestate == "failure" or gamestate == "alarm" or gamestate == "title" or gamestate == "intro1" or gamestate == "intro2" or gamestate == "intro3" or gamestate == "intro4" or gamestate == "result" then
    capture_menu_buttons()
  end

end

function check_primary_objectives()
    if tasks[7].complete and tasks[9].complete and tasks[10].complete then
      return true
    end
    return false
end

------------------------ draw
function draw_actor(a)
 local sx = (a.x * 8) - 4
 local sy = (a.y * 8) - 4
 spr(a.spr, sx, sy)
end


function draw_washer()
  local sx = (washer.x * 8) - 4
  local sy = (washer.y * 8) - 4
  spr(washer.spr1, sx, sy)
  spr(washer.spr2, sx + 8, sy)
  spr(washer.spr3, sx, sy + 8)
  spr(washer.spr4, sx + 8, sy + 8)
end

function print_warnings()
  local i = 1
  local late_tasks = {}
  for tsk in all(tasks) do
    if tsk.days_since_completion >= tsk.warning_day then
      add(late_tasks, i)
    end
    i += 1
  end
  if #late_tasks > 0 then
    if warning_index == 0 then
      warning_index = late_tasks[flr(rnd(#late_tasks)) + 1]
    end
    print(#late_tasks, 0, 90, 9)
    print(additional_objectives_text[warning_index], 0, 100, 9)
  end
end

function display_score(p_score)
  local result_string = ""
  
  if p_score < 10 then 
    result_string = "You were terrible"
  elseif p_score < 20 then
    result_string = "You were pretty awfull"
  elseif p_score < 30 then
    result_string = "You were pretty bad"
  elseif p_score < 40 then
    result_string = "You were poor"
  elseif p_score < 50 then 
    result_string = "You're getting there"
  elseif p_score < 60 then
    result_string = "Now you've got it"
  elseif p_score < 70 then
    result_string = "getting better"
  elseif p_score < 80 then
    result_string = "pretty good"
  elseif p_score < 90 then
    result_string = "awesome"
  elseif p_score == 100 then
    result_string = "winner"
  end  
  print(result_string, 0, 72, 7)
end

function _draw()
    cls()
    if gamestate == "game" then
    	map(0,0,0,0,64,64)	
        draw_actor(dog)
        draw_actor(tv)
        draw_washer()
        draw_actor(plant)
        draw_actor(cooker)
        draw_actor(sink)
        draw_actor(radio)
        foreach(actor,draw_actor)
        print("x "..dog.x,0,128,7)
        print("y "..dog.y,64,128,7)
        
        --print task
      if current_task ~= nil then
        if task and current_task.complete == false and task_is_counting_down == false then
          if current_task.type == "continuous" then
            if task_is_counting_up then
              print(task_active_text[current_task.index], 0, 120, 7)
              print(active_task_countup, 120, 120, 8)
            else
              print("hold x to "..current_task.name, 0, 120, 7)
            end
          else
            print("press x to "..current_task.name, 0, 120, 7)
          end
        elseif task_is_counting_down then
          print(task_active_text[current_task.index], 0, 120, 7)
          print(active_task_countdown, 100, 120, 8)
        else
          if use_alternate_text then
            print(alternate_complete_text[current_task.alternate_index], 0, 120, 7)
          else
            print(task_complete_text[current_task.index], 0, 120, 7)
          end
        end
      end
        
        print(timertext, 107, 1, 8)
        print(timervar, timervarx,1,8)
    end
    if gamestate == "result" then
        score = 50
        for tsk in all(tasks) do
            if tsk.complete then
                score += tsk.score_modifier
            else
              score -= tsk.score_modifier
            end          
        end
        
        if check_primary_objectives() then
            print("you were clean and caffeinated", 0, 52, 7)
        else
            print("you didn't get much done", 0, 52, 7)
        end
        
        print(score, 0, 64, 7)
        
        display_score(score)
        
        local skill_result = any_skill_up()
        if skill_result ~= "no skill up" then
          print("\
          your getting good at\
          "..skill_result, -40, 96, 11)

        end
    end
    if gamestate == "alarm" then
    	print("7:00 am", 50, 60, 8)
        print_warnings()
    end
    if gamestate == "failure" then
      print(print(endingstrings[1], 0, 32, 7))
    end
    if gamestate == "title" then
      print("-- the daily grind --", 20, 50, 7)
      print("press z to start", 32, 64, 7)
    end
    if gamestate == "intro1" then
      print("\
      this is guss\
      he has a very important\
      morning routine", 0, 32, 7)
      spr(50, 86, 42)
      print("press z to continue", 16, 96, 7)
    end
    if gamestate == "intro2" then
      print("\
      coffee\
      shower\
      brush your teeth", 0, 32, 7)
      print("press z to continue", 16, 96, 7)
    end
    if gamestate == "intro3" then
      print("\
      things you do\
      in the morning\
      affect your day", 0, 32, 7)
      print("press z to continue", 16, 96, 7)
    end
    if gamestate == "intro4" then
      print("\
      try to have a perfect morning\
      and have an amazing day", -16, 32, 7)
      print("press z to continue", 16, 96, 7)
    end

    
end

endingstrings = {}
endingstrings[1] = "you didn't leave for work\
before 8.\
you stupid dick.\
you got fired.\
the end."
endingstrings[2] = "you had a terrible day at work.\
you were fired."
endingstrings[3] = "you had a poor day at work.\
you were given an\
improvement plan."
endingstrings[4] = "you had a good day at work.\
well done."
endingstrings[5] = "you had an exceptional day at work\
in a shock result\
you were elected president."

endingstringsrubbish{}
endingstringsbelowpar{}
endingstringsabovepar{}
endingstringsnearperfect{}
endingstringsnearperfect[1] = "Youre a dynamo\
keep going."
endingstringsnearperfect[2] = "You got a standing\
ovation today.\
excellent."
endingstringsnearperfect[3] = "You exude near\
near perfection."
endingstringsnearperfect[4] = "Never has someone\
been more awesome.\
nearly perfect."
endingstringsnearperfect[5] = ""
__gfx__
0000000000000000000000006666666677777777555555555555ffffffffffffffffffff5555555500000000ffffffffbbbbbbbbfff44fffff666666666666ff
0000000000000000000000006666666674444447555555555555ffffffffffffffffffff5555555500000000ffffffffbbbbb4bbfff99fffff685555555556ff
0000000000000000000000007777777774444447555555555555ffffffffffffffffffff5555555500000000ffffffffbbbbbbbbfff49fffff6a5500000556ff
0000000000000000000000007770000774444447555555555555ffffffffffff44444444555555550000000049999444bbbbbbbbfff49fffff695000000056ff
0000000000000000000000007744440774444447555555555555ffffffffffff44444444ffffffff0000000049444444b4bbbbbbfff44fffff6b5500000556ff
0000000000000000000000007744440774444447555555555555ffffffffffff44444444ffffffff0000000044444444bbbbb4bbfff44fffff695555555556ff
0000000000000000000000007744400774444447555555555555ffffffffffff44444444ffffffff0000000044444444bbbbbbbbfff44fffff666666666666ff
0000000000000000000000007777777777777777555555555555ffffffffffff44444444ffffffff0000000044444444bbbbbbbbfff44fffff555555555555ff
fffffff444444444ffffffffffffffff00999900fffff9ff66666666669999667777777766606666ffffffffff3fff3fbbbbbbbbbbb88bbbff666666666666ff
ffffffff44444444ffffffffffffffff00999900ffff9fff66666666666666667777777766066666ff22222f3ff3f33fbbbbbbbbbb8888bbffffffffffffffff
ffffffff44444444999ffff99ffff99900999900fff99fff77777777070770707777777770777777f2222222f33333ffbbbbbbbbb888888bfff2222ffffaffff
ffffffff44444444919fff9ff9fff91900099000fff99fff77777777707887077777777770000007f22ee222ff333fffbbbbbbbbb888888bffff22ffffaaafff
ffffffff44444444999999ffff99999900099000fff99fff77777777070770707777777770000007f22eee22fff33fffbbbbbbbbb880088bffff22ffffffaaff
ffffffff44444444ff9999ffff9999ff00099000ff9999ff77777777070770705555555570666807f222eee2ff8888ffbbbbbbbbb440044bffffffffffffffff
fffffff944444444ff9ff9ffff9ff9ff00090000ff9999ff77777777707887077777777777777777ff222222ff8888ffbbbbbbbbb440044bffffffffffffffff
fffffff944444444ffffffffffffffff00900000ff9999ff7777777707077070ffff000f77777777fff2222fff8888ffbbbbbbbbbbbbbbbbffffffffffffffff
ffffffff4444444466666666fff77776ffffffffcccccccc666666664444444ffffffffffffffffffffffffffffffffff0fff0fff0fff0ffff666666666666ff
fffffff94444444466666666ff777776ff666fffc7cccc7c665555564004444fffffffffff5555ffffffffffffffffffff0f0fffff0f0fffffffffffffffffff
fffffff944444444ff7779afff777778f64446ffc7cccc7c677766564084444ffffffffff55ff55ffffffffffffffffffff00ffffff00fffffffffffffffffff
ffffffff44444444f777777fff777776f64446ffc7cc7c7c666666564084444ffffffffff5faaf5ffffffffffffffffff000000ff000000fffffffffffffffff
ffffffff44444444f777777fff777776f64446ffc7cc7c7c666666564004444ffffffffff5faaf5ffffffffffffffffff055550ff0c4320fffffffffffffffff
ffffffff44444444f777777fff77777cff666fffc7cc7ccc666666564444444ffffffffff55ff55ffffffffffffffffff055550ff0a3640fffffffffffffffff
ffffffff44444444ff7777ffff777776ffffffffcccccccc66666656ffffffffffffffffff5555ff88ffffffffffff88f000080ff0000b0fffffffffffffffff
fffffff444444444fff77ffffff77776ffffffffccccc7cc666666564fffffffffffffffffffffff888eeeeeeeeee888ffffffffffffffffffffffffffffffff
0000000000cccc0000cccc0000cccc0000cccc00ccccc7cc666666564777663333333333ffffffff888eeeeeeeeee888f0fff0ffffffffff6699996666606666
000000000cccccc00c1cc1c00c1c1cc00cc1c1c0cccccccc666666564777663333333333ff6666ff888eeeeeeeeee888ff0f0ffffff4f4446666666666066666
000000000cccccc00cccccc00cccccc00cccccc077777777777777774777663333333333f666666f888eeeeeeeeee888fff00ffff44444f40707705070777777
0000000000cccc0000cccc0000cccc0000cccc0077777777777777774777663333333333f665566f888eeeeeeeeee888f000000f4f444ff47078855570000007
0000000000022000000220000002200000022000777777777777777f4777663333333333f665566f888eeeeeeeeee888f0ac260ffff44fff0707755570000007
0000000000222200002222000022220000222200f77777777777777f4777663333333333f666666f88e8888888888e88f0c3b10fff8888ff0707705070666b07
000000000c0220c00c0220c000c220c00c022c00f97777777777779f4777663333333333ff6666ff8e888888888888e8f0000b0fff8888ff7078874777777777
00000000000110000001100000011000000110009f977777777779f94777663333333333ffffffffe88888888888888effffffffff8888ff0707704077777777
ff666666666666ff00000000fff77776fff777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff685555555556ff00000000ff777776ff7777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff6a5522222556ff00000000ff777778ff7777780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff69522000aa56ff00000000ff777776ff7777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff6b55aaaaa556ff00000000ff71cc76ff7777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff695555555556ff00000000ffcc1c1cffc7c1cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff666666666666ff00000000ff777776ff717c760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff555555555555ff00000000fff77776fff777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff666666666666ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff685555555556ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff6a55aaaaa556ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff695aa0002256ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff6b5522222556ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff695555555556ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff666666666666ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff555555555555ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
000000f101010100c10101c10005414100010000000001110121005100010000000171b181919101000100003131000000000000000101010101010131511121414100b1b10000000000000000000000414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1d0c1c0404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c1c0c0416031718191605220725260400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c1c0707070707070705070735360400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c1c0424070707073905070707230400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040405050607050505060705050400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040e0f0507070707070707070707070400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0407070907070707070707070707070400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0407070707070707070506070505050400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040505050505070707051b0707071a0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0429070707090707070507070707070400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04070707070707070705072c0707070400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04272810110507070705072a2b07070400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04373820210507070705073a3b07070400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040404040404080b080404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010a00002507025070250702507025070000000000000000250002507025070250702507025070000000000025000250002507025070250702507025070000002500025000250002507025070250702507025070
0110000010033100031f033180331000310003150031500310033100031f0331803310003100032103315003100331c0001f033180331000322000230001f000100331e0001f033180331000322000210331f000
01100000187311873018730187301c7311c7301c7301c7301f7311f7301f7301f730187311873018730187300f7310f7300f7300f730147311473014730147301873118730187301873014731147301473014730
011000001c7311c7321c7321c7321c7321c7321c7321c7321f7311f7321f7321f7321f7321f7321f7321f73221731217322173221732217322173221732217322473124732247322473224732247322473224732
0110000021031210322103221032210322103221032210321f0311f0321f0321f0321a0321a0321a0321a0321c0311c0321c0321c0321c0321c0321c0321c0321f0311f0321f0321f0321f0321f0321f0321f032
0110000010733112001073311200132001f7331f7331420010733112001073311200112001f7331d635142001073312200107330f200032001f7331f7330b200107330a200107330d2000d2001f7331d63510200
01100000107230e1071c7231d6151110618723187231510610723171061c7231d6150e1060f106101062010610723157061c7231d6150000018723187230000010723000001c7231d6151c7231d6151872300000
011000001c3241c3201c3201c3201c3201c3201c3201c3201f3201f3201f3201f3201e3201e3201e3201e320183201832018320183201832018320183201832018320183201b3201b3201c3201c3201c3201c320
011000001032410320103201032010320103201032010320133241332013320133200c3240c3200c3200c3200e3240e3200e3200e3200e3200e3200e3200e3200f3250f3250f3250f32512324123201532415320
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001d3301f33019300000001f3001f3001f30020300000002030000000203002130022300253002b30031300000000000000000000000000000000000000000000000000000000000000000000000000000
010f00003034032340343403534030300303403534034300353003430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01190000217411f741217411f741217411f741217411f741106001d60010600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002874128701287412870128741287012874128701287412870128741287012874128701287412870128741287012874128701287412870128741287012874128701287412870128741287012874128701
010d00003c3443c3443b3053930500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c3120e3120c3120e3120c3120e3120c3120e312000003470534705357053470532705347053570529705297052970529705000000000000000000000000000000000000000000000000000000000000
0123000010347113471034711347103471134710347113470030702307000000430704307073070b307093070c3070e3070000011307000000000000000000000000000000000000000000000000000000000000
011900000704504045060450704507045040450604507045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000106310c631106310c631100410e0411104110041100410e04111041100410000010345103451034500000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000046341060410634106041c634000002863400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001004104041100410404110041040410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424544
00 01024344
01 05020344
00 05020344
02 05020444
01 06074344
02 05084344
02 46484344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

