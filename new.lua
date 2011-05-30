function Use_aa(UseList,AALetters,bool)
 -- In table "UseList", append or remove segments with amino-acid in table "AALetters"
 local UseList=UseList
 local AALetters=AALetters
 local bool=bool -- add or  remove

 if #AALetters>0 then -- Is there minimum one aa letter given?

  local k
  for k=1,NumSegs do -- Cycle through all segments
   local aa=get_aa(k) -- get current aa of segment index k

   local exit_condition=false
   local l=0
   repeat
    l=l+1 -- Cycle through all given aa letters
    if aa==AALetters[l] then -- If current segment k's aa is equal to AALetters[l]
     UseList=UseList_AR(UseList,k,bool)
     exit_condition=true -- l loop can end here
    end -- if aa
    if l==#AALetters then exit_condition=true end
   until exit_condition==true
  end -- k loop
 end -- if AALetters
 return UseList
end -- function

function Use_distance(UseList,MinDist,MaxDist,MinQuantity,MaxQuantity,bool)
 -- In table "UseList", append or remove segments which have
 -- MinQuantity to MaxQuantity neighbours within distance MinDist to MaxDist
 local MinDist=MinDist
 local MaxDist=MaxDist
 local MinQuantity=MinQuantity
 local MaxQuantity=MaxQuantity
 local bool=bool -- True=append, false=remove

 for k=1, NumSegs do -- Cycle through all segments
  local QCount=0
  for l=1,NumSegs do -- compare index k with all around
   if l~=k then -- Don't count segment itself, only neighbours
    local Distance=get_segment_distance(k,l) -- Measure distance from segment k to segment l
    if Distance>=MinDist then -- If equal or above min distance
     if Distance<=MaxDist then -- If equal or below max distance
      QCount=QCount+1 -- count this segment
     end -- if Distance
    end -- if Distance
   end -- if l
  end -- l loop
  if QCount<=MaxQuantity then -- If count is equal or below max quantity
   if QCount>=MinQuantity then -- If count is equal or above min quantity
    UseList=UseList_AR(UseList,k,bool) -- add or remove from list
   end -- if QCount
  end -- if QCount
 end -- k loop
 return UseList
end -- function

function Use_close_ligand(UseList,MaxDist,bool)
 -- In table "UseList", append or remove segments which have
 -- a spatial distance of MaxDist or closer to ligand.
 local UseList=UseList
 local MaxDist=MaxDist
 local bool=bool -- True=append, false=remove
 local LigandIdx=NumSegs+1 -- Ligand Index

 local k
 for k=1,NumSegs do -- Cycle with k through all segments but not ligand
  local Distance=get_segment_distance(k,LigandIdx) -- Check spatial distance of segment k to ligand
  if Distance<=MaxDist then -- If equal or below MaxDist
   UseList=UseList_AR(UseList,k,bool) -- add or remove from list
  end -- if
 end -- k loop
 return UseList
end -- function

function UseList_Append(UseList,value)
 -- Adds content of "value" at end of UseList
 local UseList=UseList
 local value=value
 UseList[#UseList+1]=value
 return UseList
end -- function

function UseList_Remove(UseList,value)
 -- Creates new use list "UseList2" out of "UseList", but without all content of "value"
 local UseList=UseList
 local value=value
 local UseList2={} -- Initialize new uselist
 if #UseList>0 then -- if old
  for k=1,#UseList do -- Scan UseList
   if UseList[k]~=value then -- If "value" is not found
    UseList2[#UseList2+1]=UseList[k] -- append this content to new use list
   end -- if UseList
  end -- k loop
 end -- if UseList
 return UseList2
end -- function

 "_recipe_13547" : "{
 \"desc\" : \"This is a variant of step_walker by Datstandin. It backs up and re-irons the protein if a local wiggle increases points. Very good for end game point grinding.\"
 \"hidden\" : \"0\"
 \"mid\" : \"2655\"
 \"mrid\" : \"1064\"
 \"name\" : \"moon_walker\"
 \"parent\" : \"0\"
 \"parent_mrid\" : \"0\"
 \"player_id\" : \"167300\"
 \"script\" : \"
-- step walker refresh. Original ideas from Datstandin.

-- updated by smith92clone 31May2010

-- Perform a local wiggle /w campon for each segment, with 1, 2 and 3 segments selected
-- If a wiggle increases in points, backup one segment and wiggle again. Could run a long time.
-- (LF/TAB converted) 6June2010

g_segments = get_segment_count()

function reset_protein()
    set_behavior_clash_importance(1)
    deselect_all()
    do_unfreeze_all()
end

function get_protein_score(segment_count)
    if segment_count == nil then
        segment_count = get_segment_count()
    end
    -- need this function until Fold.it Lua returns negative numbers from get_score()
    local total = 0
    local index
    for index=1,segment_count do
        total = total + get_segment_score(index)
    end
    return total
end

function wiggle_it_out(wiggle_params)
    deselect_all()
    select_all()
    do_global_wiggle_sidechains(wiggle_params.sideChain_count)
    do_shake(wiggle_params.shake)
    do_global_wiggle_all(wiggle_params.all_count)
    restore_recent_best()
end

function do_the_local_wiggle_campon(first,last,wiggle_params)
    deselect_all()
    if last > g_segments then
        last = g_segments
    end
    select_index_range(first,last)
    local end_score = get_protein_score()
    local points_increased = false
    local beginning_score = end_score
    repeat
        start_score = end_score
        do_local_wiggle(wiggle_params.local_wiggle)
        restore_recent_best()
        end_score = get_protein_score()
        print("    start ",start_score," end ", end_score)
    until end_score < start_score + wiggle_params.local_tolerance
    if beginning_score + wiggle_params.local_tolerance < end_score then
        points_increased = true
    end
    --restore_recent_best()
    return points_increased
end

function step_wiggle(start,finish,wiggle_params)
    local i
    local reset
    local rewiggle_increment = 1 -- points
    local rewiggle_score = get_protein_score() + rewiggle_increment
    i = start
    while i <= finish do
        local j
        local saved_changed
        local points_changed = false
        for j = 1,3 do
            print("seg:",i," of ",finish," wiggle Length: ",j)
            saved_changed = do_the_local_wiggle_campon(i,i+j-1,wiggle_params)
            if saved_changed then
                points_changed = true
            end
        end
        if points_changed then
            reset = i - 1 -- we want to go back to the previous segment
            if reset < start then
                reset = start
            end
            for j=1,3 do
                print("retry seg:",reset," of ",finish," wiggle Length: ",j)
                do_the_local_wiggle_campon(reset,reset+j-1,wiggle_params)
            end
            reset = reset + 1
            if reset <= i then
                -- let's not get ahead of ourselves. Only really an issue when we are retrying 1
                for j=1,3 do
                    print("retry seg:",reset," of ",finish," wiggle Length: ",j)
                    do_the_local_wiggle_campon(reset,reset+j-1,wiggle_params)
                end
            end
        end
        local new_score = get_protein_score()
        if new_score > rewiggle_score then
            wiggle_it_out(wiggle_params)
            rewiggle_score = new_score + rewiggle_increment
        end
        i = i + 1
    end
end

reset_protein()
reset_recent_best()
wiggle_params = {}
wiggle_params.local_wiggle = 12
wiggle_params.local_tolerance = 0.00001
wiggle_params.sideChain_count = 15
wiggle_params.shake = 5
wiggle_params.all_count = 15

step_wiggle(1,g_segments,wiggle_params)
\"


function sidechain_tweak()
    P("Pass 1 of 3: Sidechain tweak")
    for i=1, g_segments do
        if usableAA(i) then
            deselect_all()  
            select_index(i)
            local ss=Score()
            g_total_score = Score()
            set_behavior_clash_importance(0)
            do_shake(2)
            set_behavior_clash_importance(1.)
            if(Score() > g_total_score -1.) then
                restore_recent_best()  
            else 
                P("Try sgmnt ", i)
                if(Score() > g_total_score - 30) then
                    SelectSphere(i, 10)
                    wiggle_out()  
                else
                    SelectSphere(i, 10)
                    deselect_index(i)
                    set_behavior_clash_importance(.75)
                    do_shake(2)
                    select_index(i)
                    wiggle_out()
                end
                Gain(ss)
            end
        end
    end
end

function sidechain_tweak_around()
    P("Pass 2 of 3: Sidechain tweak around")
    for i=1, g_segments do
        if usableAA(i) then
            deselect_all()
            for n=1, g_segments do
                g_score[n] = get_segment_score(n)
            end
            select_index(i)
            local ss=Score()
            g_total_score = Score()
            set_behavior_clash_importance(0)
            do_shake(2)
            set_behavior_clash_importance(1. )
            if(Score() > g_total_score -1.) then
                restore_recent_best()  
            else 
                P("Try sgmnt ", i)
                if(Score() > g_total_score - 30) then
                    SelectSphere(i,10)
                    wiggle_out()  
                else
                    deselect_all()
                    for n=1, g_segments do
                        if(get_segment_score(n) < g_score[n] - 1) then
                            select_index(n)
                        end
                    end
                    deselect_index(i)
                    set_behavior_clash_importance(0.1)
                    do_shake(2)
                    SelectSphere(i,10,true)
                    wiggle_out()
                end
                Gain(ss)
            end
        end
    end
end

function sidechain_manipulate()
    P("Last pass: Brute force sidechain manipulator")
    for i=1, g_segments do
        if usableAA(i) then
            deselect_all()
            rotamers = get_sidechain_snap_count(i)
            quicksave(4)
            if(rotamers > 1) then
                local ss=Score()
                P("Sgmnt: ", i," positions: ",rotamers)
                for x=1, rotamers do
                quickload(4)
                g_total_score = Score()
                do_sidechain_snap(i, x)
                set_behavior_clash_importance(1.)
                    if(Score() > g_total_score -1.) then
                        restore_recent_best()  
                    else 
                        if(Score() > g_total_score - 30) then
                            SelectSphere(i,10)
                            wiggle_out()  
                        else
                            SelectSphere(i,10)
                            deselect_index(i)
                            set_behavior_clash_importance(.75)
                            do_shake(2)
                            select_index(i)
                            wiggle_out()
                        end
                    end  
                end
                Gain(ss)
            end
        end
    end
end

 "_recipe_19718" : "{
 \"desc\" : \"Just does a lot of good  LUA walking scripts  for the endgame back to back. Could take a long time to run.\"
 \"hidden\" : \"1\"
 \"mid\" : \"15551\"
 \"mrid\" : \"18627\"
 \"name\" : \"LUA multiwalker forever\"
 \"parent\" : \"15000\"
 \"parent_mrid\" : \"17760\"
 \"player_id\" : \"174969\"
 \"script\" : \"--LUA multiwalker by PB
--just pasted together many LUA walkers I use back to back

function TotalLWS(threshold)
print("Starting Total LWS...")
--total lws
--totalLws(minlen,maxlen, minpp)
--minlen - minimum lenggh of sgmnts - if you have done lws by 1 and 2 you may want set it to 3
--maxlen - maximum lenght of sgments - more than 7 looks useless
--minppi - minimum gain per local wiggle iter

P=print --"quicker" print ;]

local function score() --score of puzzle
    return get_score(true)
end

function AllLoop()
    select_all()
    replace_ss("L")
end

function freeze(start, len)
    do_unfreeze_all()
    deselect_all()
    for f=start, maxs, len+1 do
        if f<= maxs then select_index(f) end
    end
    do_freeze(true, false)
end

function lw(minppi)
    local gain=true
    while gain do
        local ss=score()
        do_local_wiggle(2)
        local g=score()-ss
        if g<minppi then gain=false end
        if g<0 then restore_recent_best() end
    end
end

function wiggle(start, len,minppi)
    if start>1 then
        deselect_all()
        select_index_range(1,start-1)
        lw(minppi)
    end
    for i=start, maxs, len+1 do
        deselect_all()
        local ss = i+1
        local es=i+len
        if ss >= maxs then ss=maxs end
        if es >= maxs then es=maxs end
        select_index_range(ss,es)
        lw(minppi)
    end
end

function totalLws(minlen,maxlen, minppi)
    do_unfreeze_all()
    deselect_all()
    set_behavior_clash_importance(1)
    save_structure()
    AllLoop()
    maxs=get_segment_count()
    local ssc=score()
    P("Starting Total LWS: ",ssc)
    P("Lenght: ",minlen," to ",maxlen," ;minimum ppi: ",minppi)
    for l=minlen, maxlen do
        for s=1, l+1 do
            P("Len: ",l," ,start point: ",s)
            local sp=score()
            freeze(s,l)
            reset_recent_best()
            wiggle(s,l,minppi)
            P("Gained: ",score()-sp)
            quicksave(3)
        end
    end
    P("Finished! Total gain: ",score()-ssc)
    load_structure()
end

--totalLws(minlen,maxlen, minpp)
--minlen - minimum lenggh of sgmnts - if you have done lws by 1 and 2 you may want set it to 3
--maxlen - maximum lenght of sgments - more than 7 looks useless
--minppi - minimum gain per local wiggle iter
totalLws(1,7,threshold)
end

function M3wigglwSequence(threshold)
--
print("starting M3 Wiggle sequence...")
-- Foldit Script "Wiggle Sequence"
-- 01-09-2010
-- V1.0
-- MooMooMan

-- If 1 then wiggle sidechains.
sidechains_flag = 0

-- If 1 then shake
shake_flag = 0

-- Set number of wiggle cycles per iteration
wiggle_cycles = 5

-- Set number of iterations to gain points.
max_iterations = 10

-- Set termination threshold.
--threshold = 0.0001

-- Obtain the number of segments in the protein.
segments = get_segment_count()

-- Maximum number of segments to wiggle.
max_wiggle = 5

-- Get the starting score.
initial_score = get_score(true)

-- Print a title.
print("Wiggle Sequence")

-- Save the current structure in slot 10
quicksave(10)

-- Reset the recent best so we can use crtl N
reset_recent_best()

-- Loop for the wiggle length
for seq = 1, max_wiggle do
    
    -- Loop for the selected segments.
    for sel = 1, (segments-seq) do
    
        print("Seq ", seq, "/", max_wiggle, " : AA ", sel, "/", segments)
    
        -- Make sure nothing is selected.
        deselect_all()
        
        -- Iterate over the segments we want to select.
        for group = 0, seq do
            select_index(sel + group)
        end
        
        -- Get the score before changing.
        scoreBefore = get_score(true)
        scoreStart = get_score(true)
        scoreAfter = scoreBefore
        
        -- Now wiggle those segments selected.
        do_local_wiggle(wiggle_cycles)
        
        -- Shake if selected.
        if (shake_flag == 1) then
            do_shake(1)
        end
        
        -- Wiggle sidechains if selected
        if (sidechains_flag == 1) then
            do_global_wiggle_sidechains(1)
        end
        
        -- Get score after operations.
        scoreAfter = get_score(true)
        
        -- Check to see if we should iterate to get more points.
        
        iteration_count = 0
        while( ((scoreAfter - scoreBefore) > threshold) and (iteration_count < max_iterations)) do
            
            print ("Iterating... ", iteration_count, "/", max_iterations)
            
            -- Reset the recent best structure..
            reset_recent_best()
            
            -- Reset the before score.
            scoreBefore = scoreAfter
            
            -- Now wiggle those segments selected.
            do_local_wiggle(wiggle_cycles)
            
            -- Score after operations.
            scoreAfter = get_score(true)
            
            -- Test to see if we should keep the structure.
            if( (scoreAfter - scoreBefore) > threshold) then
                reset_recent_best()
            else
                restore_recent_best()
            end
            
            iteration_count = iteration_count + 1
                        
        end
        
        -- Shake if selected.
        if (shake_flag == 1) then
            do_shake(1)
        end
        
        -- Wiggle sidechains if selected
        if (sidechains_flag == 1) then
            do_global_wiggle_sidechains(1)
        end
        
        if ((get_score(true) - scoreStart) > threshold) then
            print("Gain +", get_score(true) - scoreStart)
        end
        
        restore_recent_best()
        
    end
end
end

function KrogWalkerV4(threshold)
--
print("Starting Krog walker V4")
-- *** SET OPTIONS HERE ***

-- How many segments to wiggle. Starts at min, stop at max. 
-- Krog recommends 1-4.
min_segs_to_wiggle = 1
max_segs_to_wiggle = 4

-- How much the score must improve at each iteration to try that section again. 
-- Krog recommends 0.01 for early, 0.001 mid and 0.0001 late - get all you can!
score_condition = threshold --0.001

-- If true, do a smoother, global wiggle - much slower but might squeeze extra points
should_global_wiggle = false

-- Set to true if you want it to run forever - good for overnighting
-- Krog recommends a SUPER low score condition if this is true.
should_run_forever = false

-- **********************************************************************
-- *** Dont edit below this line unless you know what you're doing :) ***
-- **********************************************************************

function wiggle_walk(section_size, score_thresh, global)
  total_gain = 0;
  reset_recent_best()
  set_behavior_clash_importance(1)
  deselect_all()
  do_unfreeze_all()
  segs = get_segment_count()
  for i = 1, section_size - 1 do
    select_index(i)
  end
  for i = section_size, segs do
    select_index(i)
    gain = score_thresh
    while gain >= score_thresh do
      last_score = get_score()
      if global then
        do_global_wiggle_all(40/section_size)
      else
        do_local_wiggle(8)
        restore_recent_best()
      end
      gain = get_score() - last_score
      total_gain = total_gain + gain
      print("Section ", i - section_size + 1, "/", segs - section_size + 1, "   Improvement: ", gain)
      print(" Total Improvement: ", total_gain)
    end
    deselect_index(i - section_size + 1)  
  end
end


run_condition = true
while run_condition do
  run_condition = should_run_forever
  for j = min_segs_to_wiggle, max_segs_to_wiggle do
    wiggle_walk(j, score_condition, should_global_wiggle)
  end
end
end

function WormLWS(threshold)
--
print("Starting worm LWS with ppi .0001")
--[[
Worm LWS
Performin "worm" LWS by given patterns, no freezing
]]--

p=print --"quicker" print ;]
segCount=get_segment_count()

local function Score() --Score of puzzle
    return get_score(true)
end
function round(x)
    return x-x%0.001
end

function AllLoop()
    local ok=false
    for i=1, segCount do
        local ss=get_ss(i)
        if ss~="L" then 
            save_structure()
            ok=true
            break
        end
    end
    if ok then
        select_all()
        replace_ss("L")
    end
end
function lw(minppi)
    local gain=true
    while gain do
        local ss=Score()
        do_local_wiggle(2)
        local g=Score()-ss
        if g<minppi then gain=false end
        if g<0 then restore_recent_best() end
    end
end

function Worm()
    if sEnd==nil then sEnd=segCount end
    AllLoop()
    reset_recent_best()
    quicksave(3)
    local ss=Score()
    for w=1,#pattern do
        len=pattern[w]
        local sw=Score()
        p("Starting Worm of len ",len,", score: ",round(Score()))
        for s=sStart,sEnd-len+1 do
            deselect_all()
            select_index_range(s,s+len-1)
            lw(minppi)
        end
        p("Pattern gain: ",round(Score()-sw))
        quicksave(3)
    end
    deselect_all()
    load_structure()
    p("Total Worm gain: ",round(Score()-ss))
end

pattern={5,2,11,3,13,7,1} --how many segments at once to LWS
sStart=1 --from segment
sEnd=nil --to segment, nil=end of it
minppi=threshold -- 0.0001 --minimum point gain per 2 wiggles, ie 1 for fassst and 0.0001 for loooooooong

Worm()
end

function PiWalkerCamponV2(threshold)
--
print("Starting pi walker campon V2...")

-- rewrite of pi_walker_campon
-- author srssmith92 6June2010
-- (LF/TAB converted)

g_segments = get_segment_count()

function mynextmode(number,maximum)
    number = number + 1
    if number > maximum then
        number = 1
    end
    return number
end

function get_protein_score(segment_count)
return get_score(true)
end

function rotate_pattern(pattern_list)
    local last = #pattern_list
    local i
    if last > 1 then
        local pattern_save = pattern_list[1]
        for i = 1, last do
            pattern_list[i]  = pattern_list[i+1]
        end
        pattern_list[last] = pattern_save
    end
    return pattern_list
end

function unfreeze_protein()
    do_unfreeze_all()
end

function freeze_segments(start_index,pattern_list)
    unfreeze_protein()
    local pattern_length = #pattern_list
    local current_segment = start_index
    local current_pattern = 1
    deselect_all()
    while current_segment < g_segments do
        select_index(current_segment)
        current_segment = current_segment + pattern_list[current_pattern]
        current_pattern = mynextmode(current_pattern,pattern_length)
    end
    do_freeze(true,true)
end

function do_the_local_wiggle_campon(first,last,wiggle_params)
    deselect_all()
    select_index_range(first,last)
    local end_score = get_protein_score()
    local points_increased = false
    local beginning_score = end_score
    repeat
        start_score = end_score
        do_local_wiggle(wiggle_params.local_wiggle)
        restore_recent_best()
        end_score = get_protein_score()
        print("    start ",start_score," end ", end_score)
    until end_score < start_score + wiggle_params.local_campon_tolerance
    if beginning_score + wiggle_params.local_campon_tolerance < end_score then
        points_increased = true
    end
    --restore_recent_best()
    return points_increased
end

function do_a_local_wiggle(current_pattern, current_segment, end_segment, last_current_segment, last_end_segment, pattern_list, wiggle_params)
    local saved_changed
    saved_changed = do_the_local_wiggle_campon(current_segment, end_segment, wiggle_params)
    if saved_changed then
        -- now back up the pattern list
        if last_current_segment ~= nil then
            print("retry segs: ", last_current_segment, " to ", last_end_segment)
            do_the_local_wiggle_campon(last_current_segment, last_end_segment, wiggle_params)
            print("retry segs: ", current_segment, " to ", end_segment)
            do_the_local_wiggle_campon(current_segment, end_segment, wiggle_params)
        end
    end
    last_current_segment = current_segment
    last_end_segment = end_segment
    current_segment = end_segment + 2
    end_segment = current_segment + pattern_list[current_pattern] - 2
    current_pattern = mynextmode(current_pattern,pattern_length)
    return current_pattern, current_segment, end_segment, last_current_segment, last_end_segment
end

function local_wiggle_segments(first_frozen_segment,pattern_list,wiggle_params)
    local current_segment = 0
    local current_pattern = 1
    local end_segment
    local pattern_length = #pattern_list
    local last_current_segment, last_end_segment
    if first_frozen_segment == 1 then
        current_segment = 2
        end_segment =  current_segment + pattern_list[1]-2
        current_pattern = mynextmode(current_pattern,pattern_length)
    else
        current_segment = 1
        end_segment = first_frozen_segment - 1
    end
    local saved_changed
    repeat
        print("segs: ", current_segment, " to ", end_segment)
    current_pattern, current_segment, end_segment, last_current_segment, last_end_segment = do_a_local_wiggle(current_pattern, current_segment, end_segment, last_current_segment, last_end_segment, pattern_list, wiggle_params)
    until end_segment > g_segments

    if current_segment <= g_segments then
        print("last segs: ", current_segment, " to ", end_segment)
        do_a_local_wiggle(current_pattern, current_segment, g_segments, last_current_segment, last_end_segment, pattern_list, wiggle_params)
    end
end

function freeze_wiggle(pattern_list, wiggle_params)
    local i
    for i = 1,pattern_list[1] do
        freeze_segments(i, pattern_list)
        reset_recent_best()
        local_wiggle_segments(i, pattern_list, wiggle_params)
    end
end

function verify_pattern_list(pattern_list, maximum)
    if pattern_list == nil or maximum == nil then
        return false
    end
    local result = true
    pattern_length = # pattern_list
    local count = 0
    for count = 1, pattern_length do
        if pattern_list[count] == 1 or pattern_list[count] > maximum then
            result = false
            break
        end
    end
    return result
end

pattern_list = {2,3,3,4} -- distance between frozen segments. Change this to what you want. Experiment 2,2,3,3,4,4, whatever
pattern_length = #pattern_list
pattern_list_ok = verify_pattern_list(pattern_list,g_segments)

wiggle_params = {}
wiggle_params.local_wiggle = 12
wiggle_params.local_campon_tolerance = threshold
if pattern_list_ok then
    for pattern_count = 1, pattern_length do
        freeze_wiggle(pattern_list, wiggle_params)
    end
    unfreeze_protein()
else
    print("Pattern list contains a 1, or an element greater than ", g_segments, " quitting")
end
end
--
function MoonWalker(threshold)
print("Starting moon walker...")

-- step walker refresh. Original ideas from Datstandin.

-- updated by smith92clone 31May2010

-- Perform a local wiggle /w campon for each segment, with 1, 2 and 3 segments selected
-- If a wiggle increases in points, backup one segment and wiggle again. Could run a long time.

g_segments = get_segment_count()

function reset_protein()
   set_behavior_clash_importance(1)
   deselect_all()
   do_unfreeze_all()
end

function get_protein_score(segment_count)
    return get_score(true)
end

function wiggle_it_out(wiggle_params)
    deselect_all()
    select_all()
    do_global_wiggle_sidechains(wiggle_params.sideChain_count)
    do_shake(wiggle_params.shake)
    do_global_wiggle_all(wiggle_params.all_count)
    restore_recent_best()
end

function do_the_local_wiggle_campon(first,last,wiggle_params)
    deselect_all()
    if last > g_segments then
        last = g_segments
    end
    select_index_range(first,last)
    local end_score = get_protein_score()
    local points_increased = false
    local beginning_score = end_score
    repeat
        start_score = end_score
        do_local_wiggle(wiggle_params.local_wiggle)
        restore_recent_best()
        end_score = get_protein_score()
        print("    start ",start_score," end ", end_score)
    until end_score < start_score + wiggle_params.local_tolerance
    if beginning_score + wiggle_params.local_tolerance < end_score then
        points_increased = true
    end
    --restore_recent_best()
    return points_increased
end

function step_wiggle(start,finish,wiggle_params)
    local i
    local reset
    local rewiggle_increment = 1 -- points
    local rewiggle_score = get_protein_score() + rewiggle_increment
    i = start
    while i <= finish do
         local j
         local saved_changed
         local points_changed = false
         for j = 1,3 do
             print("seg:",i," of ",finish," wiggle Length: ",j)
             saved_changed = do_the_local_wiggle_campon(i,i+j-1,wiggle_params)
             if saved_changed then
                 points_changed = true
             end
         end
         if points_changed then
             reset = i - 1 -- we want to go back to the previous segment
             if reset < start then
                 reset = start
             end
             for j=1,3 do
                 print("retry seg:",reset," of ",finish," wiggle Length: ",j)
                do_the_local_wiggle_campon(reset,reset+j-1,wiggle_params)
             end
             reset = reset + 1
             if reset <= i then
                -- let's not get ahead of ourselves. Only really an issue when we are retrying 1
                for j=1,3 do
                    print("retry seg:",reset," of ",finish," wiggle Length: ",j)
                    do_the_local_wiggle_campon(reset,reset+j-1,wiggle_params)
                end
            end
         end
         local new_score = get_protein_score()
         if new_score > rewiggle_score then
            wiggle_it_out(wiggle_params)
            rewiggle_score = new_score + rewiggle_increment
         end
         i = i + 1
    end
end

reset_protein()
reset_recent_best()
wiggle_params = {}
wiggle_params.local_wiggle = 12
wiggle_params.local_tolerance = threshold
wiggle_params.sideChain_count = 15
wiggle_params.shake = 5
wiggle_params.all_count = 15

step_wiggle(1,g_segments,wiggle_params)
--
end

while true do --forever!
TotalLWS(0.0001)
M3wigglwSequence(0.0001)
KrogWalkerV4(0.0001)
WormLWS(0.0001)
PiWalkerCamponV2(0.0001)
MoonWalker(0.0001)
end

print("Done all walkers")\"
 \"type\" : \"script\"
 \"uses\" : \"0\"
 \"ver\" : \"0.3\"
}
"

function sidechain_tweak()
    p("Pass 1 of 3: Sidechain tweak")
    for i=1, g_segments do
        if usableAA(i) then
            deselect_all()  
            select_index(i)
            local ss=Score()
            g_total_score = Score()
            set_behavior_clash_importance(0)
            do_shake(2)
            set_behavior_clash_importance(1.)
            if(Score() > g_total_score -1.) then
                restore_recent_best()  
            else 
                p("Try sgmnt ", i)
                if(Score() > g_total_score - 30) then
                    SelectSphere(i, 12)
                    wiggle_out()  
                else
                    SelectSphere(i, 12)
                    deselect_index(i)
                    set_behavior_clash_importance(.75)
                    do_shake(2)
                    select_index(i)
                    wiggle_out()
                end
            end
        end
    end
end

function sidechain_tweak_around()
    p("Pass 2 of 3: Sidechain tweak around")
    for i=1, g_segments do
        if usableAA(i) then
            deselect_all()
            for n=1, g_segments do
                g_score[n] = get_segment_score(n)
            end
            select_index(i)
            local ss=Score()
            g_total_score = Score()
            set_behavior_clash_importance(0)
            do_shake(2)
            set_behavior_clash_importance(1. )
            if(Score() > g_total_score -1.) then
                restore_recent_best()  
            else 
                p("Try sgmnt ", i)
                if(Score() > g_total_score - 30) then
                    SelectSphere(i,12)
                    wiggle_out()  
                else
                    deselect_all()
                    for n=1, g_segments do
                        if(get_segment_score(n) < g_score[n] - 1) then
                            select_index(n)
                        end
                    end
                    deselect_index(i)
                    set_behavior_clash_importance(0.1)
                    do_shake(2)
                    SelectSphere(i,12,true)
                    wiggle_out()
                end
            end
        end
    end
end

function sidechain_manipulate()
    p("Last pass: Brute force sidechain manipulator")
    for i=1, g_segments do
        if usableAA(i) then
            deselect_all()
            rotamers = get_sidechain_snap_count(i)
            quicksave(4)
            if(rotamers > 1) then
                local ss=Score()
                p("Sgmnt: ", i," positions: ",rotamers)
                for x=1, rotamers do
                quickload(4)
                g_total_score = Score()
                do_sidechain_snap(i, x)
                set_behavior_clash_importance(1.)
                    if(Score() > g_total_score -1.) then
                        restore_recent_best()  
                    else 
                        if(Score() > g_total_score - 30) then
                            SelectSphere(i,12)
                            wiggle_out()  
                        else
                            SelectSphere(i,12)
                            deselect_index(i)
                            set_behavior_clash_importance(.75)
                            do_shake(2)
                            select_index(i)
                            wiggle_out()
                        end
                    end  
                end
            end
        end
    end
end

 "_recipe_2527" : "{
 \"desc\" : \"Some small changes.
See script link for details.\"
 \"hidden\" : \"0\"
 \"mid\" : \"12106\"
 \"mrid\" : \"13757\"
 \"name\" : \"Genetic Fuse V1.7\"
 \"parent\" : \"0\"
 \"parent_mrid\" : \"0\"
 \"player_id\" : \"119022\"
 \"script\" : \"--[[
Genetic Fuse by Crashguard303
]]--

-- Random Number Generator

-- Author: tlaloc (aka Greg Reddick)

-- This is a substitute for the math.random() and math.randomseed()
-- functions in the lua standard library. If they ever become available
-- this code can be removed and the standard functionality should work with
-- by only prefixing all the function names with 'math.'.


------------------------------------------------------------------------
-- random ([m [, n]])

-- When called without arguments, returns a uniform pseudo-random real number in the
-- range [0,1). When called with an integer number m, math.random returns a uniform
-- pseudo-random integer in the range [1, m]. When called with two integer numbers
-- m and n, math.random returns a uniform pseudo-random integer in the range [m, n].
------------------------------------------------------------------------
-- randomseed (x)

-- Sets x as the "seed" for the pseudo-random generator: equal seeds produce
-- equal sequences of numbers.
------------------------------------------------------------------------
-- getseed ()

-- This is a substitute for the os.time() lua function that is commonly
-- used to seed a random number generator.

-- It generates it from the least significant
-- digits of the current score. So if the score
-- doesn't change, then the number sequence will
-- be the same. However, *any* change to the score
-- will cause a different sequence.
-- If the score is 0, it performas a WiggleAll until a non-zero score
-- is generated, then restore the structure.
------------------------------------------------------------------------

-- This implementation uses the Multiply with Carry random number generator
-- Translated into Lua from the VBScript published at
-- http://www.rlmueller.net/Programs/MWC32.txt

------------------------------------------------------------------------
-- The original script has the following notices:
-- Copyright (c) 2007 Richard L. Mueller
-- Hilltop Lab web site - http://www.rlmueller.net
-- Version 1.0 - January 2, 2007
-- You have a royalty-free right to use, modify, reproduce, and
-- distribute this script file in any way you find useful, provided that
-- you agree that the copyright owner above has no warranty, obligations,
-- or liability for such use.
------------------------------------------------------------------------

function floor(value)
    return value - (value % 1)
end

function getseed()
    local score = abs(get_score(true)+RNDoffset)
    if score == 0 then
        quicksave(9)
        do_global_wiggle_all(1)
        score = abs(get_score(true)+RNDoffset)
        quickload(9)
    end
    local fraction = (score - floor(score)) * 1000
    local least = fraction - floor(fraction)
    local seed = floor(least * 100000)
    return seed
end

-- lngX = 1000
lngC = 48313

function MWC()
    local S_Hi
    local S_Lo
    local C_Hi
    local C_Lo
    local F1
    local F2
    local F3
    local T1
    local T2
    local T3

    local A_Hi = 63551
    local A_Lo = 25354
    local M = 4294967296

    local H = 65536

    local S_Hi = floor(lngX / H)
    local S_Lo = lngX - (S_Hi * H)
    local C_Hi = floor(lngC / H)
    local C_Lo = lngC - (C_Hi * H)

    local F1 = A_Hi * S_Hi
    local F2 = (A_Hi * S_Lo) + (A_Lo * S_Hi) + C_Hi
    local F3 = (A_Lo * S_Lo) + C_Lo

    local T1 = floor(F2 / H)
    local T2 = F2 - (T1 * H)
    lngX = (T2 * H) + F3
    local T3 = floor(lngX / M)
    lngX = lngX - (T3 * M)

    lngC = floor((F2 / H) + F1)

    return lngX
end

function randomseed(x)
    lngX = x
end

function random(m,n)
    local m=m
    local n=n
    if n == nil and m ~= nil then
        n = m
        m = 1
    end
    if (m == nil) and (n == nil) then
        return MWC() / 4294967296
    else
        if n < m then
            return nil
        end
        return floor((MWC() / 4294967296) * (n - m + 1)) + m
    end
end

function abs(x)
 local y=x
 if x<0 then y=-y end
 return y
end -- function

function sgn(x)
 local y=x
 if y>=0 then
   return 1
  else
   return -1
 end -- if y
end -- function

function CutOff(x,y)
 return floor(x*10^y)/10^y
end -- function

function Moebius(Min,Max,x)
 -- Moebius value
 -- preserves negative signum
 -- brings absolute values above Max+Difference to Min+Difference
 -- brings absolute values below Min-Difference to Max-Difference
 local s=sgn(x) -- fetch signum
 local y=x*s -- multiply with signum to get absolute value
 local Min=Min
 local Max=Max
 if y>Max then
   y=Min+(y-Max)
  elseif y<Min then
   y=Max+(y-Min)
 end -- if y
 return y*s -- multpily with signum to get non-absolute value again
end -- function

function FillHerd(StartIndex)
 local StartIndex=StartIndex
 local k
 for k=StartIndex,HerdSize do
  local IndiSlot=IndiPointer[k]
  print("Generating Individuum ",k,"(",IndiSlot,")")
  local l
  IndiType[IndiSlot]="random"
  for l=1,IndiLength do
   IndiCI[IndiSlot][l]=random()*(IndiCIMax-IndiCIMin)+IndiCIMin -- Random CI value

   IndiSiter[IndiSlot][l]=random(0,IndiSiterMax) -- Random iteration value for shakes
    if random_flag(InvertProb)==1 then IndiSiter[IndiSlot][l]=-IndiSiter[IndiSlot][l] end -- maybe invert it

   IndiWiter[IndiSlot][l]=random(0,IndiWiterMax) -- Random iteration value for shakes
   if random_flag(InvertProb)==1 then IndiWiter[IndiSlot][l]=-IndiWiter[IndiSlot][l] end -- maybe invert it

   -- print(" CI:",IndiCI[IndiSlot][l]," S-iters:",IndiSiter[IndiSlot][l]," W-iters:",IndiWiter[IndiSlot][l])
  end -- l loop
 end -- k loop
end -- function

function random_flag(x)
 local x=x
 -- Returns a random value; either  0 or 1, depending on mutation probability x
 local flag=random()
 if flag<x then
   return 1
  else
   return 0
 end -- if
end -- function

function random_direction()
 -- Returns random value; either -1 or +1
 return random_flag(0.5)*2-1
end -- function

function random_direction2(x)
 local x=x
 -- Returns random value; either -1 or +1, but only if mutation allows it, else 0
 if random_flag(x)==0 then
   return 0
  else
  return random_direction()
 end -- if
end -- function

function CrossOverCheck(Pos,Target)
 if MultipleCrossOver then
    if random_flag(0.5)==1 then
      return true
     else
      return false
    end -- if random_flag
   else
    if Pos>Target then
       return true
      else
       return false
    end -- if Pos
 end -- if MultipleCrossOver
end -- function

function CrossOver(Source1,Source2,Target)
 local So1=Source1   -- Parent (source) Indi index 1
 local So2=Source2   -- Parent (source) Indi index 2
 local Ta=Target         -- Destination (target) Indi index
 local So1P=IndiPointer[So1] -- Fetch Indi 1 address
 local So2P=IndiPointer[So2] -- Fetch Indi 2 address
 local TaP=IndiPointer[Ta] -- Fetch Indi destination address

 print("Breeding ",So1,"(",So1P,") and ",So2,"(",So2P,") to ",Ta,"(",TaP,")")

 local CrossOverPoint
 if MultipleCrossOver==false then -- If we use multi crossover, we don't need to
  CrossOverPoint=random(0,IndiLength) -- generate random crossover point
  -- CrossOverPoint=random(CrossOverPoint,IndiLength)
  -- As the random number generator tends to create small values, you can use this to pull value randomly up
  print("Crossover point:",CrossOverPoint)
 end -- if MultipleCrossOver

 local k
 for k=1,IndiLength do -- Go through Chromosome length
  local SoT
  if CrossOverCheck(k,CrossOverPoint) then -- If crossover point is exceeded, take So2 Indi chromosomes
    SoT=So2P
   else -- If crossover point is not exceeded, take So1 Indi chromosomes
    SoT=So1P
  end -- if
  IndiCI[TaP][k]=IndiCI2[SoT][k]
  IndiSiter[TaP][k]=IndiSiter2[SoT][k]
  IndiWiter[TaP][k]=IndiWiter2[SoT][k]

  -- Mutating starts here
  local Change=random_direction2(MutProb)*MutCIDigit^(-random(MutCIMin,MutCIMax)) -- Change random digit of CI, or not if no mutation
  IndiCI[TaP][k]=Moebius(0,1,IndiCI[TaP][k]+Change)
  if IndiCI[TaP][k]<IndiCIMin or IndiCI[TaP][k]>IndiCIMax then IndiCI[TaP][k]=random()*(IndiCIMax-IndiCIMin)+IndiCIMin end
  if random_flag(InvertProb)==1 then IndiCI[TaP][k]=1-IndiCI[TaP][k] end -- if random_flag, invert

  -- print("Mutated CI: ",Temp," by ",CIChange," to ",IndiCI[TaP][k])

  IndiSiter[TaP][k]=MutateIter(IndiSiter[TaP][k],IndiSiterMax) -- Mutate shake iterations, inclusive inverting
  IndiWiter[TaP][k]=MutateIter(IndiWiter[TaP][k],IndiWiterMax) -- Mutate wiggle iterations, inclusive inverting
 end -- k loop
end -- function

function MutateIter(Value,Max)
    local Value=Value
    local Max=Max
    local Change=random_direction2(MutProb) -- change shakes by -1 or 1, or not if no mutation
    Value=Moebius(0,Max,Value+Change)
    if random_flag(InvertProb)==1 then Value=-Value end -- if random_flag, invert
    return Value
end -- function

function Roulette()
 local RouletteTarget=random()*(Fitness+1)
 local RouletteValue=0
 local Wheel=random(1,HerdSize)
 repeat
  Wheel=Wheel+1
  if Wheel>HerdSize then Wheel=1 end
  RouletteValue=RouletteValue+IndiScore2[IndiPointer[Wheel]]
 until RouletteValue>RouletteTarget
 return Wheel
end -- function

function CopyHerd()
  -- Copy all Indis to extra table
 IndiCI2={}
 IndiSiter2={}
 IndiWiter2={}
 IndiScore2={}

 local k
 for k=1,HerdSize do -- Cycle through complete herd
  IndiCI2[k]={}
  IndiSiter2[k]={}
  IndiWiter2[k]={}
  IndiScore2[k]=IndiScore[k]
  local l
  for l=1,IndiLength do -- and Indi contents
   IndiCI2[k][l]=IndiCI[k][l]
   IndiSiter2[k][l]=IndiSiter[k][l]
   IndiWiter2[k][l]=IndiWiter[k][l]
  end -- l
 end -- k
end -- function

function Breed2()
 CopyHerd() -- Create Indi2 tables out of Indi tables
 local FitnessWorst=IndiScore2[IndiPointer[HerdSize]] -- Check worst points
 Fitness=0 -- initialize Fitness
 local k
 for k=1,HerdSize do -- We don't need the pointer here, beacuse we change all score values
  -- if FitnessWorst<0 then -- If worst Fitness<0
   IndiScore2[k]=IndiScore2[k]-FitnessWorst+1 -- Adapt all scores, so that last Fitness is 1. Needed for negative values
  -- end -- if
  Fitness=Fitness+IndiScore2[k] -- Calculate Fitness by summing all new Indi fitnesses
 end -- k

 local Target
 for Target=BreedFirst,BreedLast do

  local Source1
  if Source1isRoulette then -- If Roulette
    Source1=Roulette() -- Select a random parent, prefering fit ones
   else -- If not
    Source1=Target-BreedFirst+1 -- Parent 1 is one of the best
  end -- if Source1isRoulette

  local Source2
  if Source2isRoulette then -- If Roulette
    repeat
     Source2=Roulette()  -- Select a different random parent, prefering fit ones
    until Source2~=Source1 -- but not the same as Source2
   else -- If not
    Source2=Source1+1 -- Parent2 is 1 behind Parent 1
    if Source2>HerdSize then Source2=1 end -- if last one exceeded, start with first again
  end -- if Source1isRoulette

  CrossOver(Source1,Source2,Target)
  IndiType[IndiPointer[Target]]="breeded"
 end -- Target
end -- function

function Breed()
 -- sorting
 local KFinish=HerdSize-1
 local k
 for k=1,KFinish do
  LStart=k+1
  local l
  for l=LStart,HerdSize do
   if IndiScore[IndiPointer[k]]<IndiScore[IndiPointer[l]] then
    IndiPointer[k],IndiPointer[l]=IndiPointer[l],IndiPointer[k]
   end -- if
  end -- l
 end -- k
 print()
 print ("Score:")
 for k=1,HerdSize do
  print(k,"(",IndiPointer[k],"): ",IndiScore[IndiPointer[k]])
 end -- k

 Breed2()

 if FillPoint<=HerdSize then
  FillHerd(FillPoint) -- Replace last Indis by random new ones, if needed
 end -- if
end -- function

function BestScoreCheck(BestScore)
 local BestScore=BestScore
 local TempScore=get_score(true)
 if TempScore>BestScore then BestScore=TempScore end
 return BestScore
end --function

function Genetic_Fuse()
 FillPoint=BreedLast+1
 randomseed(getseed())  -- initialize random seed
 IndiScore={}
 IndiType={}
 IndiCI={}
 IndiSiter={}
 IndiWiter={}

 IndiPointer={}

 local k
 for k=1,HerdSize do  -- for complete herdsize, initialize:
  IndiPointer[k]=k    -- Index slot pointer (required for fast result sorting)
  -- IndiScore[k]=0
  IndiCI[k]={}           -- CI table
  IndiSiter[k]={}       -- Shake iteration table
  IndiWiter[k]={}      -- Wiggle iteration table
 end -- k

 FillHerd(1) -- Generate complete random herd

 select_all() -- Select all segments to make shake/wiggle effect on them

 if UseRecentBest==false then -- do we use recent best?
   quicksave(1) -- This will be the initial state for each generation
  else
   reset_recent_best() -- set initial puzzle stae as recent best
   ExecuteCluster=true -- perform Indi test always
 end -- if UseRecentBest

 print()
 print("Starting Genetic fuse...")

 local Generation=0
 repeat
  Generation=Generation+1

  if UseRecentBest then
   restore_recent_best() -- take best result so far
   -- print("RRB")
   quicksave(1) -- and save it for each try of this generation
   -- print("QS 1")
  end -- if UseRecentBest

  local BestScore
  local k
  for k=1,HerdSize do -- Cycle through all Indis
   ExecuteCluster=true
   if Generation>1 then
    if UseRecentBest==false then -- Do we use recent best? If not,
     if k<BreedFirst then
      ExecuteCluster=false -- we don't need to perform the good solutions again
     end -- if k
    end -- if UseRecentBest
   end -- if Generation
   -- Check if this Indi (try) has to be processed or just shown
   if ExecuteCluster then -- if Indi is not just to be shown, but tested
    quickload(1) -- load this for each Indi of herd
    -- print("QL 1")
    BestScore=get_score(true) -- Reset best score for this try
   end -- if ExecuteCluster
   local IndiSlot=IndiPointer[k] -- Fetch slot (house) number, where the Indi lives
   print("Gen:",Generation," Indi:",k,"(",IndiSlot,")/",HerdSize," type:",IndiType[IndiSlot])
   -- Show Indi number(and address), herdsize and type
   local l
   for l=1,IndiLength do -- Cycle through complete chromosome
    print("  CI:",CutOff(IndiCI[IndiSlot][l],3)," S-iters:",IndiSiter[IndiSlot][l]," W-iters:",IndiWiter[IndiSlot][l])
    if ExecuteCluster then -- If needed
     set_behavior_clash_importance(IndiCI[IndiSlot][l]) -- perform CI change
     if IndiSiter[IndiSlot][l]>0 then
      do_shake(IndiSiter[IndiSlot][l]) -- perform shake
      BestScore=BestScoreCheck(BestScore)
     end -- if
     if IndiWiter[IndiSlot][l]>0 then
      do_global_wiggle_all(IndiWiter[IndiSlot][l]) -- perform wiggle
      BestScore=BestScoreCheck(BestScore)
     end -- if
    end -- if ExecuteCluster
   end -- l loop
   print("  CI:1 S-iters:",IndiSiterMax," W-iters:",IndiWiterMax) -- Finish try with
   if ExecuteCluster then
    set_behavior_clash_importance(1) -- CI=1
    do_shake(IndiSiterMax) -- maximum shake
    do_global_wiggle_all(IndiWiterMax) -- maximum wiggle
    IndiScore[IndiSlot]=BestScoreCheck(BestScore) -- get Indi score
   end -- if ExecuteCluster
   print("    Score:",IndiScore[IndiSlot]) -- and show score
  end -- k
  Breed() -- Roulette, crossover, mutate and fill
 until Generation==Generations
 -- Repeat until target generation number is reached exactly
 -- If target is below 1, it can never be reached exactly
 restore_recent_best() -- fetch best state
end -- function

Generations=50
                                   -- Number of Generations, when this script has to end, integer value>=0
                                     -- Set this to 0 to run infinitely
BreedFirst=3
                                      -- First Individuum index to replaced by breeded one, integer value>=1
                                        -- For example, if 3, first 2 good solutions will be kept.
BreedLast=5
                                      -- Last Individuum index to replaced by breeded one, integer value >=BreedFirst and <=HerdSize
                                        -- if <HerdSize, rest of herd (BreedLast+1 to HerdSize) is filled with random indiviuums per generation
HerdSize=8
                                   -- Number of solutions (Individuums) to try per generation
IndiLength=6
                                      -- Chomosome length.
                                        --Number of CI changes, shakes and wiggles per try, integer value>0
MutProb=.3
                                   -- Mutation probability, float value >=0 and <=1
                                      -- Mutation effects CI, shakes and wiggles
                                      -- If 0, no mutation is performed, only crossover
                                      -- if 1, mutation is always performed
InvertProb=.2
                                   -- Invert probability, folat value >=0 and <=1
                                     -- If 0, inversion is turned off
                                     -- If 1, inversion is always on (not recommended)
MultipleCrossOver=true
                                   -- Multiple crossover point flag, boolean value
                                     -- If false (default), crossover works only at one point
                                     -- If ftrue, each single gene can be from one of both partents
Source1isRoulette=true
                                   -- Roulette flag for parent 1, boolean value
                                     -- if false (default), breeding starts with parent 1 as source and downwards
                                     -- if true, parent is selected by fitness roulette, good solutions appear more often than bad ones
Source2isRoulette=true
                                  -- Roulette flag for parent 2, boolean value
                                     -- if false, breeding starts with parent 1+1 as source and downwards
                                     -- if true (default), parent is selected by fitness roulette, good solutions appear more often than bad ones
IndiCIMin=0
                                      -- Minimum possible CI, float value
IndiCIMax=1
                                      -- Maximum possible CI, float value
MutCIMin=1
                                      -- First possible CI digit to change when mutating, integer value>0
MutCIMax=3
                                      -- Last possible CI digit to change when mutating, integer value>0, >=MutCIMin
MutCIDigit=10
                                      -- Digit base of CI mutating, integer value
                                        -- 2 will change CI by (+or-)2^-(MutCIMin..MutCIMax), quasi binary change
                                        -- 10 will change CI by (+or-)10^-(MutCIMin..MutCIMax), quasi decimal change
IndiSiterMax=2
                                      -- Maximum iterations for shake
IndiWiterMax=12
                                      -- Minimum iterations for shake
UseRecentBest=false
                                    -- If true, load recent best state for each generation
                                      -- not recommended, you can stuck on local maximum
                                      -- Use only if you want to squeeze out what is possible
                                    -- If false, load initial puzzle state for each Indi

RNDoffset=0
                                     -- Random offset, float value >=0 to <1
                                       -- As we can't randomize random seed with a timer, use this to try other values
                                       -- when you have loaded the same puzzle state

Genetic_Fuse()    -- Launch script with parameters\"
 \"type\" : \"script\"
 \"uses\" : \"11\"
 \"ver\" : \"0.3\"
}


-- ST - mini rosetta energy model v1.0.0.0.
-- Quickly scores a fold based on compactness, hiding, clashing, and disulfide bridges. recommended for Puzzles ( Exploration, Design, Multi-start, Freestyle ) + combinations, thereof. Rosetta 3 is a library based object-oriented software suite which provides a robust system for predicting and designing protein structures, protein folding mechanisms, and protein-protein interactions. The library contains the various tools that Rosetta uses, such as Atom, ResidueType, Residue, Conformation, Pose, ScoreFunction, ScoreType, and so forth. These components provide the data and services Rosetta uses to carry out its computations.[1]

REFERENCES
1. Rosetta 3.0 User-guide - http://www.rosettacommons.org/manuals/rosetta3_user_guide/index.html

Copyright (C) 2011 Seagat2011 <http://fold.it/port/user/1992490>
Copyright (C) 2011 thom001 <http://fold.it/port/user/172510>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

$Id$

------------------------------------------------------------------------------------------------]]--

--#Global functions
local function _abs (x)
    if x < 0 then
        x = -x
    end 
    return x
end -- function _abs

local function _factorial (n)

    local t
    t = n

    for i = n,2,-1 do
    t = t * (i-1)
    end

    return t

end -- function _factorial 

-- For cosine (), we will use a non-converging Talyor series approximation ( n = 15 terms ) - http://en.wikipedia.org/wiki/Taylor_series
-- cosine (x) = sum [ ((-1 ^ n) / _factorial (2 * n))  *  x ^ (2* n) ]
local function _cosine (x)

    local nterms
    nterms = 15

    -- calculate first term
    x =  ((-1 ^ 0) / _factorial (2 * 0)) * ( x ^ (2 * 0) ) -- i.e. equals one (1)
    -- calculate other terms..
    for n = 1,nterms do
    x = x + ((-1 ^ n) / _factorial (2 * n)) * ( x ^ (2 * n) )
    end

    return x

end -- function _cosine 

local function _floor ( n,r )
	return n - n%r
end -- function _floor

local math = {
    abs = _abs,
    cosine = _cosine,
    factorial =  _factorial,
    floor = _floor,
}
--Math library#

local function math_floor ( n )
	return math.floor ( n,1e-4)
end -- function math_floor 

--#Game vars
local numsegs = get_segment_count ()

-- Amino Acid library
local amino_segs
local amino_part 
local amino_table

amino_segs     = {'a', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'y'}
amino_part      = { short = 1, abbrev = 2, longname = 3, hydro = 4, scale = 5, pref = 6, mol = 7, pl = 8, vdw_vol = 9 }
amino_table     = {
                  --  {short, abbrev, 	longname, 	hydro, 	scale, 	pref, 	mol wt, 	     isoelectric point (pl), 	van der waals volume}
                    ['a'] = {'a', 'Ala', 	'Alanine',       	'phobic',	-1.6,   	'H',    	89.09404,    6.01, 			67    },
                    ['c'] = {'c', 'Cys', 	'Cysteine',         	'phobic', 	-17,    	'E',    	121.15404,  5.05, 	 		86    },
                    ['d'] = {'d', 'Asp', 	'Aspartic acid',   	'philic',   	 6.7,    	'L',    	133.10384,  2.85,  			91    },
                    ['e'] = {'e', 'Glu', 	'Glutamic acid',    	'philic',   	 8.1,    	'H',    	147.13074,  3.15,  			109  },
                    ['f'] = {'f', 'Phe', 	'Phenylalanine',    	'phobic',  -6.3,   	'E',    	165.19184,  5.49,  			135  },
                    ['g'] = {'g', 'Gly', 	'Glycine',          	'phobic', 	 1.7,    	'L',    	75.06714,    6.06,  			48    },
                    ['h'] = {'h', 'His', 	'Histidine',        	'philic',   	-5.6,   	'L',    	155.15634,  7.60,  			118  },--Note: Histidine has no conformational 'pref'
                    ['i'] = {'i', 'Ile', 	'Isoleucine',       	'phobic',  -2.4,   	'E',    	131.17464,  6.05,  			124  },
                    ['k'] = {'k', 'Lys', 	'Lysine',           	'philic',   	 6.5,    	'H',    	146.18934,  9.60,  			135  },
                    ['l'] = {'l', 'Leu', 	'Leucine',          	'phobic',   1,      	'H',    	131.17464,  6.01,  			124  },
                    ['m'] = {'m', 'Met',	'Methionine',       	'phobic',   3.4,    	'H',    	149.20784,  5.74,  			124  },
                    ['n'] = {'n', 'Asn', 	'Asparagine',       	'philic',     8.9,    	'L',    	132.11904,  5.41,  			96    },
                    ['p'] = {'p', 'Pro', 	'Proline',          	'phobic',  -0.2,   	'L',    	115.13194,  6.30,  			90    },
                    ['q'] = {'q', 'Gln', 	'Glutamine',        	'philic',     9.7,    	'H',    	146.14594,  5.65,  			114  },
                    ['r'] = {'r', 'Arg', 	'Arginine',         	'philic',     9.8,    	'H',    	174.20274,  10.76,  			148  },
                    ['s'] = {'s', 'Ser', 	'Serine',           	'philic',     3.7,    	'L',    	105.09344,  5.68,  			73    },
                    ['t'] = {'t', 'Thr', 	'Threonine',        	'philic',     2.7,    	'E',    	119.12034,  5.60,  			93    },
                    ['v'] = {'v', 'Val', 	'Valine',           	'phobic',   -2.9,   	'E',    	117.14784,  6.00,  			105  },
                    ['w'] = {'w', 'Trp', 	'Tryptophan',       	'phobic',   -9.1,   	'E',    	204.22844,  5.89,  			163  },
                    ['y'] = {'y', 'Tyr', 	'Tyrosine',         	'phobic',   -5.1,   	'E',    	181.19124,  5.64,  			141  },
              --[[ ['b'] = {'b', 'Asx', 	'Asparagine or Aspartic acid'},
                    ['j'] = {'j', 'Xle', 	'Leucine or Isoleucine'},
                    ['o'] = {'o', 'Pyl', 	'Pyrrolysine'},
                    ['u'] = {'u', 'Sec', 	'Selenocysteine'},
                    ['x'] = {'x', 'Xaa', 	'Unspecified or unknown amino acid'},
                    ['z'] = {'z', 'Glx', 	'Glutamine or glutamic acid'},
                ]]--

}

--[[
Amino Acid		Abbrev.		Remarks
------------------------------------------------------------------------------
Alanine			A	Ala	Very abundant, very versatile. More stiff than glycine, but small enough to pose only small steric limits for the protein conformation. It behaves fairly neutrally, and can be located in both hydrophilic regions on the protein outside and the hydrophobic areas inside.
Asparagine or aspartic acid	B	Asx	A placeholder when either amino acid may occupy a position.
Cysteine			C	Cys	The sulfur atom bonds readily to heavy metal ions. Under oxidizing conditions, two cysteines can join together in a disulfide bond to form the amino acid cystine. When cystines are part of a protein, insulin for example, the tertiary structure is stabilized, which makes the protein more resistant to denaturation; therefore, disulfide bonds are common in proteins that have to function in harsh environments including digestive enzymes (e.g., pepsin and chymotrypsin) and structural proteins (e.g., keratin). Disulfides are also found in peptides too small to hold a stable shape on their own (eg. insulin).
Aspartic acid		D	Asp	Behaves similarly to glutamic acid. Carries a hydrophilic acidic group with strong negative charge. Usually is located on the outer surface of the protein, making it water-soluble. Binds to positively-charged molecules and ions, often used in enzymes to fix the metal ion. When located inside of the protein, aspartate and glutamate are usually paired with arginine and lysine.
Glutamic acid		E	Glu	Behaves similar to aspartic acid. Has longer, slightly more flexible side chain.
Phenylalanine		F	Phe	Essential for humans. Phenylalanine, tyrosine, and tryptophan contain large rigid aromatic group on the side-chain. These are the biggest amino acids. Like isoleucine, leucine and valine, these are hydrophobic and tend to orient towards the interior of the folded protein molecule. Phenylalanine can be converted into Tyrosine.
Glycine			G	Gly	Because of the two hydrogen atoms at the alpha carbon, glycine is not optically active. It is the smallest amino acid, rotates easily, adds flexibility to the protein chain. It is able to fit into the tightest spaces, e.g., the triple helix of collagen. As too much flexibility is usually not desired, as a structural component it is less common than alanine.
Histidine			H	His	In even slightly acidic conditions protonation of the nitrogen occurs, changing the properties of histidine and the polypeptide as a whole. It is used by many proteins as a regulatory mechanism, changing the conformation and behavior of the polypeptide in acidic regions such as the late endosome or lysosome, enforcing conformation change in enzymes. However only a few histidines are needed for this, so it is comparatively scarce.
Isoleucine		I	Ile	Essential for humans. Isoleucine, leucine and valine have large aliphatic hydrophobic side chains. Their molecules are rigid, and their mutual hydrophobic interactions are important for the correct folding of proteins, as these chains tend to be located inside of the protein molecule.
Leucine or isoleucine	J	Xle	A placeholder when either amino acid may occupy a position
Lysine			K	Lys	Essential for humans. Behaves similarly to arginine. Contains a long flexible side-chain with a positively-charged end. The flexibility of the chain makes lysine and arginine suitable for binding to molecules with many negative charges on their surfaces. E.g., DNA-binding proteins have their active regions rich with arginine and lysine. The strong charge makes these two amino acids prone to be located on the outer hydrophilic surfaces of the proteins; when they are found inside, they are usually paired with a corresponding negatively-charged amino acid, e.g., aspartate or glutamate.
Leucine			L	Leu	Essential for humans. Behaves similar to isoleucine and valine. See isoleucine.
Methionine		M	Met	Essential for humans. Always the first amino acid to be incorporated into a protein; sometimes removed after translation. Like cysteine, contains sulfur, but with a methyl group instead of hydrogen. This methyl group can be activated, and is used in many reactions where a new carbon atom is being added to another molecule.
Asparagine		N	Asn	Similar to aspartic acid. Asn contains an amide group where Asp has a carboxyl.
Pyrrolysine		O	Pyl	Similar to lysine, with a pyrroline ring attached.
Proline			P	Pro	Contains an unusual ring to the N-end amine group, which forces the CO-NH amide sequence into a fixed conformation. Can disrupt protein folding structures like alpha helix or beta sheet, forcing the desired kink in the protein chain. Common in collagen, where it often undergoes a posttranslational modification to hydroxyproline.
Glutamine			Q	Gln	Similar to glutamic acid. Gln contains an amide group where Glu has a carboxyl. Used in proteins and as a storage for ammonia. The most abundant Amino Acid in the body.
Arginine			R	Arg	Functionally similar to lysine.
Serine			S	Ser	Serine and threonine have a short group ended with a hydroxyl group. Its hydrogen is easy to remove, so serine and threonine often act as hydrogen donors in enzymes. Both are very hydrophilic, therefore the outer regions of soluble proteins tend to be rich with them.
Threonine		T	Thr	Essential for humans. Behaves similarly to serine.
Selenocysteine		U	Sec	Selenated form of cysteine, which replaces sulfur.
Valine			V	Val	Essential for humans. Behaves similarly to isoleucine and leucine. See isoleucine.
Tryptophan		W	Trp	Essential for humans. Behaves similarly to phenylalanine and tyrosine (see phenylalanine). Precursor of serotonin. Naturally fluorescent.
Unknown			X	Xaa	Placeholder when the amino acid is unknown or unimportant.
Tyrosine			Y	Tyr	Behaves similarly to phenylalanine (precursor to Tyrosine) and tryptophan (see phenylalanine). Precursor of melanin, epinephrine, and thyroid hormones. Naturally fluorescent, although fluorescence is usually quenched by energy transfer to tryptophans.
Glutamic acid or glutamine	Z	Glx	A placeholder when either amino acid may occupy a position.
]]--

local function _hscale(seg)
    return amino_table[seg][amino_part.scale]
end -- function _hscale

local function _mol(seg)
    return amino_table[seg][amino_part.mol]
end -- function _mol

local function _pl(seg)
    return amino_table[seg][amino_part.pl]
end -- function _pl

local amino = 
{   
    abbrev_to_short       	= _abbrev_to_short,
    longname_to_short 	= _longname_to_short,
    abbrev      		= _abbrev,
    longname    		= _long,
    hydro       		= _h,
    hydroscale  		= _hscale,
    preffered   		= _pref,
    size        		= _mol,
    charge      		= _pl,
    vdw_radius 		= _vdw_radius,
} -- object amino

local function is_ligand ( seg,seg2 )

	local val = false

	if ((get_ss(seg) == 'M') and (get_ss(seg2) == 'M')) then
		val = true
	end

	return val

end -- function is_ligand 

--#Calculations
local function _HCI(seg_a, seg_b) -- hydropathy
    return 20 - math.abs((amino.hydroscale(seg_a) - amino.hydroscale(seg_b)) * 19/10.6)
end -- function _HCI

local function _SCI(seg_a, seg_b) -- size
    return 20 - math.abs((amino.size(seg_a) + amino.size(seg_b) - 123) * 19/135)
end -- function _SCI

local function _CCI(seg_a, seg_b) -- charge
    return 11 - (amino.charge(seg_a) - 7) * (amino.charge(seg_b) - 7) * 19/33.8
end -- function _CCI

local function _DCI( r,idx,idx2 ) -- disulfides

	-- test for ligand to prevent crash
	if ( is_ligand (idx,idx2) == false ) then

		local seg
		local seg2

		seg = get_aa (idx)
		seg2 = get_aa (idx2)

		-- disulfide linkages - cysteine/methionine/selenocysteine
		if ((( seg == 'c' ) or ( seg == 'm' ) or ( seg == 'u' )) and ( get_segment_score_part ( "disulfides",idx ) ~= 0 )) then

			r.num_disulfide_contacts = r.num_disulfide_contacts + 1

			if ((( seg2 == 'c' ) or ( seg2 == 'm' ) or ( seg2 == 'u' )) and ( get_segment_score_part ( "disulfides",idx2 ) ~= 0 )) then

				r.num_disulfide_contacts_made = r.num_disulfide_contacts_made + 1 -- (forming cystine)

			end

		elseif ((( seg2 == 'c' ) or ( seg2 == 'm' ) or ( seg2 == 'u' )) and ( get_segment_score_part ( "disulfides",idx2 ) ~= 0 )) then

			-- at this point, we know that only half the disulfide linkage was found
			r.num_disulfide_contacts = r.num_disulfide_contacts + 1

		end -- disulfide linkages 

	end -- test for ligand

	return r

end -- function _DCI

local function _CLCI ( r,seg,seg2 ) -- clashing

	local val
	local val2
	local ct

	ct 	= r.clashing_tolerance
	val	= get_segment_score_part ( "clashing", seg )
	val2	= get_segment_score_part ( "clashing", seg2 )

	if ( val > ct ) then
		val = 1
	else
		val = 0
	end

	if ( val2 > ct ) then
		val2 = 1
	else
		val2 = 0
	end

	return val + val2

end -- function _CLCI 

local function _HDCI ( r,seg,seg2 ) -- hiding

	local val
	local val2

	-- test for ligand to prevent crash
	if ( is_ligand (seg,seg2) == false ) then

		val   = -get_segment_score_part ( "hiding", seg ) 
		val2 = -get_segment_score_part ( "hiding", seg2 )

	else

		val = 0
		val2 = 0

	end

	return val + val2

end -- function _HDCI 

local calc =
{   
	hci = _HCI, 	-- hydropathy
	sci = _SCI, 	-- size 
	cci = _CCI, 	-- charge
	dci = _DCI, 	-- disulfides
	clci = _CLCI, 	-- clashing
	hdci = _HDCI,	-- hiding
}

local function find_contacts ( r )

	local k
	local mindist

	k 	= r.k
	mindist 	= r.mindist

	-- locate contacts
	for j = 1,k do

		local b
		local seg
		local seg2

		b 	= 1e2
		seg 	= j
		seg2 	= 1

		for i = 1,k do

			local a

			a = get_segment_distance ( i,j )

			if ((a < b) and ((i > j + mindist) or (i < j - mindist))) then -- get shortest distance, but dont form contacts with self

				b = a
				seg2 = i

			end

		end

		if (r.contact_matrix [ seg ] ~= seg2) and (r.contact_matrix [ seg2 ] ~= seg) then -- no (L to R), (R to L) duplicate contacts

			-- include a distance bonus ?
			if ( math.abs ( b ) <= r.segment_distance ) then
			r.distance_bonus = r.distance_bonus + 1
			end

			-- note new contacts
			r.num_contacts = r.num_contacts + 1

			-- save location
			r.contact_matrix [ seg ] = seg2
			r.contact_matrix [ seg2 ] = seg

			if ( is_ligand ( seg,seg2 ) == false ) then

				local aa
				local aa2

				aa = get_aa ( seg )	
				aa2 = get_aa ( seg2 )

				-- score compatibility index terms
				r.max_hci = r.max_hci + calc.hci ( aa,aa2 ) 
				r.max_sci = r.max_sci + calc.sci ( aa,aa2 ) 
				r.max_cci = r.max_cci + calc.cci ( aa,aa2 ) 

				-- note disulfide linkages - cysteine/methionine/selenocysteine
				r = calc.dci ( r,seg,seg2 ) 

				-- score clashing terms
				r.max_clashing  = r.max_clashing + calc.clci ( r,seg,seg2 ) 

				-- score hiding terms 
				r.max_hiding = r.max_hiding + calc.hdci ( r,seg,seg2 ) 

				-- show contacting segments ?
				if ( r.show_contacting_segments == true ) then
				band_add_segment_segment ( seg,seg2 ) 
				end

			end -- test for ligand

		end

	end -- for j = 1,k do

	if ( r.show_contacting_segments == true ) then
	band_disable () -- bands are for aesthetic purpose only. they indicate contacting segments
	end

	-- score packing terms
	r.max_packing = r.distance_bonus * r.theoretical_multiplier

	-- score disulfide linkages - cysteine/methionine/selenocysteine
	r.max_disulfides = r.num_disulfide_contacts_made * r.theoretical_multiplier 

	return r

end -- function find_contacts

local function _score_contacts ( r )

	local _hci
	local _sci
	local _cci
	local _clashing
	local _hiding
	local _packing
	local _disulfides

	local _score
	local _theoretical_score
	local _grade

	print ( "ST - mini rosetta energy model" )

	if ( r.show_contacting_segments == true ) then
	print ( "Step 1: Using bands to indicate contacting segments.. " )	
	else
	print ( "Step 1: Locating contacting segments.. " )	
	end

	r = find_contacts ( r )

	print ( "Step 2: Tabulating score.. " )

	r.theoretical_max_score_term 		= r.num_contacts * r.theoretical_multiplier
	r.theoretical_max_clashing_score_term 	= r.num_contacts * r.theoretical_multiplier 
	r.theoretical_max_hiding_score_term 	= r.num_contacts * r.theoretical_hiding_multiplier  
	r.theoretical_max_packing_score_term 	= (r.num_contacts * r.packing_factor) * r.theoretical_multiplier -- Top score should have atleast 75% (1- 0.25) of segments with some form of contacting
	r.theoretical_max_disulfide_score_term 	= (r.num_disulfide_contacts % 2) * r.theoretical_multiplier 

	_hci 	= math_floor (r.max_hci / r.theoretical_max_score_term) * 100
	_sci 	= math_floor (r.max_sci / r.theoretical_max_score_term) * r.sci_weight * 100
	_cci 	= math_floor (r.max_cci / r.theoretical_max_score_term) * 100
	_clashing  = math_floor (r.max_clashing / r.theoretical_max_clashing_score_term) * 100
	_hiding 	= math_floor (r.max_hiding / r.theoretical_max_hiding_score_term) * 500 
	_packing 	= math_floor (r.max_packing / r.theoretical_max_packing_score_term) * 100

	if ( r.theoretical_max_disulfide_score_term <= 0 ) then -- do not penalize if available disulfides < 2
		_disulfides = 100 
	else
		_disulfides = math_floor (r.max_disulfides / r.theoretical_max_disulfide_score_term) * 100
	end

	_score = _hci + (_sci * r.sci_weight * 7.5) + _cci + (_clashing * r.clashing_weight ) + (_hiding * r.hiding_weight )  + (_packing * r.packing_weight ) + ( _disulfides * r.disulfide_weight )
	_theoretical_score = (r.theoretical_max_score_term * (r.num_terms)) + r.theoretical_max_clashing_score_term + r.theoretical_max_hiding_score_term + r.theoretical_max_packing_score_term + r.theoretical_max_disulfide_score_term -- add new terms as needed.

	_grade = math_floor ( _score/_theoretical_score ) * 100

	print ( "Correct Hydropathy matching: ", _hci, "%" )
	print ( "Size matching: ", _sci, "%" )
	print ( "Charge matching: ", _cci, "%" )
	print ( "Clash avoidance: ", _clashing, "%" )
	print ( "Hiding: ", _hiding, "%" )
	print ( "Packing: ", _packing, "%" )
	print ( "Conserved disulfide bridges: ", _disulfides, "%n" )
	print ( "Score: ",  _score, " / ",  _theoretical_score, " (", _grade, "%)" )

	print ( "done." )

end -- function _score_contacts ( r )

-- Main
do 

	local r

	r = {
	
		mindist 	= 1,
		maxdist 	= 0,
		max_hci 	= 0,
		max_sci 	= 0,
		max_cci 	= 0,
		max_clashing 	= 0,
		max_hiding 	= 0,
		max_packing 	= 0,
		max_disulfides 	= 0,	
		theoretical_multiplier 	= 20,	-- highest possible score per term
		theoretical_max_score_term 	= 0,
		theoretical_hiding_multiplier  	= 200,	-- ideal hiding value for each residue ( multiplier )
		theoretical_max_clashing_score_term 	= 0,
		theoretical_max_hiding_score_term 	= 0,
		theoretical_max_packing_score_term 	= 0,
		theoretical_max_disulfide_score_term 	= 0,
		segment_distance 	= get_segment_distance (1,2) * 1.15,
		score_helices 	= true,
		score_loops 	= true,
		score_sheets 	= true,
		contact_matrix 	= {},
		num_terms 	= 3,	-- #num of (xCI) score terms : hci, sci, cci
		num_contacts 	= 0,
		num_disulfide_contacts 	= 0,
		num_disulfide_contacts_made 	= 0,
		show_contacting_segments 	= true,	-- use bands to indicate contacting segments
		clashing_tolerance = -1e3,	-- minimum allowed clashing acceptance (comparative)
		hiding_tolerance = 0,	-- minimum allowed hiding threshold (comparative)
		hci_weight = 1,		-- default value: 1
		sci_weight = 10,		-- default value: 1
		cci_weight = 1,		-- default value: 1
		clashing_weight = 1,		-- default value: 1
		hiding_weight = 75,		-- default value: 75 -- give the greatest magnitude, because we believe this is an important value
		packing_weight = 1,		-- default value: 1
		disulfide_weight = 1,	-- default value: 1
		distance_bonus = 0,	
		packing_factor = 3,		-- minimum allowed packing density (multiplier)		
		precision = 1e-4,		-- rounding precision
		k = numsegs,

	}

	_score_contacts ( r )

end -- do
"
