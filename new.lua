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


function CreateBand()
    local start  = RandomInt(segCnt)
    local finish = RandomInt(segCnt)
    if  start~=finish and --not make band to same place
        math.abs(start-finish)>= minDist and --do not band if too close
        CanBeUsed(start,finish) and --at least one need to be in place
        get_segment_distance(start,finish) <= maxBandDist --not band if too far away
    then
        band_add_segment_segment(start, finish)
        local range    = Band.maxStrength - Band.minStrength
        local strength = (RandomFloat() * range) + Band.minStrength
        local n = get_band_count()
        if n > 0 then band_set_strength(n, strength) end
        
        local length = 3+ (RandomFloat() * (Band.maxLength-3)) --min len is 3
        
        if compressor then
            length = get_segment_distance(start,finish)-compressFrac --compressing
        else
            if push then
                local dist = get_segment_distance(start,finish)
                if dist >2 and dist <18 then length=dist*1.5 end
            end
            
            if hydroPull then
                if is_hydrophobic(start) and is_hydrophobic(finish)  then 
                    length=3 --always pull hydrophobic pair
                end
            end
        end
        if length >20 then length=20 end
        if length <0 then length=0 end
        if n > 0 then band_set_length(n, length) end                
    else
        CreateBand()
    end
end

function mkBand(a) --make band if found void in area of that segment
	p("Banding segment ", a)
	getDist()
	local t={}--there we store possible sehments
	for b=1,segCnt do --test all segments
		local ab=dist(a,b) --distance between segments
		if ab>minLenght then --no voind if less
			--p(a," ",b," ",ab)
			local void=true
			for c=1,segCnt do --searhing that is any segment between them				
				local ac=dist(a,c)
				local bc=dist(b,c)
				if ac~=0 and bc~=0 and ac<ab and bc<ab and ac>4 and bc>4 then
					if ac+bc<ab+1.5
						then void=false break --no void there for sure
					end
				end
			end
			if void==true then 
				if math.abs(a-b)>=minDist then
					t[#t+1]={a,b}
				end
			end
		end
	end
	if #t>0 then
		p("Found ",#t," possible bands across voids")
		for i=1,#t do
			band_add_segment_segment(t[i][1],t[i][2])
		end
	else
		p("No voids found")
	end
end

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