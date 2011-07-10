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

function CompactContent(OS,E,AS)
 --[[
 Adds string AS to temporary output string OS and counts number of added AS in E.
 If OS contents 10 elements, line is printed out

 I only had to write this sub because there Lua standard library is not included.
 We neither can do some string manipulation nor use a print command without linebreaks at the moment :/
 ]]--

 local OS=OS -- Temporal string for output
 local AS=AS  -- String to add
 local E=E -- Element counter, how often AS was added

 E=E+1
 if AS<10 then -- Sorry for this, but there are no string operations possible at the moment
   OS=OS.."00"..AS
  elseif AS<100 then
   OS=OS.."0"..AS
  else
   OS=OS..AS
 end -- if AS

 if E<10 then -- If there are not 10 elements per line
   OS=OS.."   " -- add space
  else -- If there are 10 elements per line
   print(OS) -- print line out
   OS="" -- clear output string
   E=0 -- reset element counter
 end -- if E
 return OS,E
end -- function

function FillHerd(StartAt,EndAt,TimeStamp)
 local StartAt=StartAt -- First cluster index to generate (not cluster slot)
 if StartAt<=HerdSize then
  local EndAt=EndAt -- Last cluster index to generate (not cluster slot)
  local TimeStamp=TimeStamp -- "birth date"
  print("Generating Herd from ",StartAt," to ",EndAt)

  local k2
  for k2=StartAt,EndAt do
   print("Cluster: ",k2)
   local k=ClusterPointer[k2] -- Fetch cluster slot by cluster index
   ClusterScore[k]=0
   ClusterDrift[k]=random_direction() -- Create value -1 or 1

   if k2==1 and Mimic then
     ClusterType[k]="mimic"
    else
     ClusterType[k]="random"
   end -- if k2
   ClusterType[k]=ClusterType[k].."-"..TimeStamp

   if ClusterBands>0 then
   ClusterSegA[k]={}
   ClusterSegB[k]={}
   ClusterLength[k]={}
   ClusterStrength[k]={}

    local l
    for l=1,ClusterBands do
     if puzzle_is_ligand==false then -- If this is no ligand puzzle
       ClusterSegA[k][l]=random_segment() -- get random segment number
      else -- If this is a ligand puzzle
       ClusterSegA[k][l]=NumSegs+1 -- Segment A is always ligand
     end -- if puzzle_is_ligand

     if k2~=1 or Mimic==false then
      if random_flag(InvBProb)==1 then
       ClusterSegA[k][l]=-ClusterSegA[k][l]
      end -- if random_flag
     end -- if k2

     repeat
      ClusterSegB[k][l]=random_segment()
      local IDistance=index_distance(ClusterSegA[k][l],ClusterSegB[k][l]) -- fetch index distance
      local SDistance=get_segment_distance(abs(ClusterSegA[k][l]),ClusterSegB[k][l]) -- fetch spatial distance
     until IDistance>=MID_Game and SDistance<=MaxBL_Game
     -- Segments must have a minimum index distance
     -- and maximum spatial distance

     if k2==1 and Mimic then
       ClusterLength[k][l]=FactorByLength(ClusterSegA[k][l],ClusterSegB[k][l])
      else -- if k2
       ClusterLength[k][l]=frandom(MinBF,MaxBF,6)
     end -- if k2

     if k2==1 and Mimic then
      ClusterStrength[k][l]=MaxBS
      else
       ClusterStrength[k][l]=frandom(MinBS,MaxBS,3)
     end -- if k2

    end  -- l loop
   end -- if ClusterBands

   if ClusterFreezes>0 then
    ClusterFreeze[k]={}
    local l
    for l=1,ClusterFreezes do
     ClusterFreeze[k][l]=random_segment()
     if (k2==1 and Mimic) or random_flag(InvFProb)==1 then
      ClusterFreeze[k][l]=-ClusterFreeze[k][l]
     end -- if random_flag
    end -- l loop
   end -- if
  end -- k loop
 end -- if StartAt
end -- function

function ShowHerd()
 local k2
 local l

 print("Clusters are:")
 for k2=1,HerdSize do
  local k=ClusterPointer[k2]
  print("Cluster:",k2," score:",ClusterScore[k]," drift:",ClusterDrift[k])
  if ClusterBands>0 then
   local l
   for l=1,ClusterBands do
    print("Band ",l,": ",ClusterSegA[k][l]," to ",ClusterSegB[k][l])
   end
  end -- if ClusterBands

  if ClusterFreezes>0 then
   local l
   for l=1,ClusterFreezes do
   print("Freeze ",l,": ",ClusterFreeze[k][l])
   end -- l
  end -- if
 end -- k loop
end -- function

function ShowHerdShort()
 print("Clusters are:")

 local k2
 for k2=1,HerdSize do
  local k=ClusterPointer[k2]
  print("Cluster:",k2,"(",k,") score:",ClusterScore[k])
  print("Drift:",ClusterDrift[k])
 end -- k loop
end -- function

function ShowScoreList()
 local k2
 for k2=1,HerdSize do
  local k=ClusterPointer[k2]
  print("Cluster:",k2,"(",k,") delta:",ClusterScore[k])
 end -- k
end -- function

function SortHerd()
 -- As we use pointers, we only have to swap the cluster "adresses" instead of copying all band/freeze values
 local Finish=HerdSize-1
 local k
 for k=1,Finish do
  local start=k+1
  local l
  for l=start,HerdSize do
   if ClusterScore[ClusterPointer[l]]>ClusterScore[ClusterPointer[k]] then
    -- print("Swapping cluster ",k,"(",ClusterPointer[k],"):",l,"(",ClusterPointer[l],")")
    ClusterPointer[l],ClusterPointer[k]=ClusterPointer[k],ClusterPointer[l]
   end -- if
  end -- l
 end -- k
end -- function

function CreateCrossoverPoint(x)
 -- create random crossover point

  if x==0 then
    return 0
   else -- if x ~=0
    -- return random(0,x) -- create random value between 0 and x
    return random(1,x-1) -- create random value between 1 and x-1
  end -- if x
end -- function

function Breed(TimeStamp)
  -- Copy all clusters to another bank, same name for all cluster tables but with 2 at end
  -- Breed two clusters from bank 2 back to old bank to prevent breeding collision.
  -- If this wouldn't be done, and (for example) cluster 1 and 2 would be breeded to cluster 3,
  -- cluster 3 couldn't be used as breeding source again, as it would be overwritten already.

  local TimeStamp=TimeStamp -- "birth date"

  ClusterScore2={}
  -- ClusterType2={}
  ClusterDrift2={}

  ClusterSegA2={}
  ClusterSegB2={}
  ClusterLength2={}
  ClusterStrength2={}

  ClusterFreeze2={}

   local k
   for k=1,HerdSize do
    ClusterScore2[k]=ClusterScore[k]
    ClusterDrift2[k]=ClusterDrift[k]

    if ClusterBands>0 then
     ClusterSegA2[k]={}
     ClusterSegB2[k]={}
     ClusterLength2[k]={}
     ClusterStrength2[k]={}
     local l
     for l=1,ClusterBands do
       ClusterSegA2[k][l]=ClusterSegA[k][l]
       ClusterSegB2[k][l]=ClusterSegB[k][l]
       ClusterLength2[k][l]=ClusterLength[k][l]
       ClusterStrength2[k][l]=ClusterStrength[k][l]
     end -- l loop
    end -- if ClusterBands

     if ClusterFreezes>0 then
     ClusterFreeze2[k]={}
     local l
     for l=1,ClusterFreezes do
       ClusterFreeze2[k][l]=ClusterFreeze[k][l]
     end -- l loop
    end -- if ClusterFreezes
   end -- k loop

   FitnessOffset=ClusterScore[ClusterPointer[HerdSize]]
   -- Take worst cluster score as fitness offset reference
   -- By subtracting this score offset from each cluster score and adding 1,
   -- it is guaranteed that worst cluster score is always 1, all other scores are better.
   -- This will shift all cluster scores up, if worst cluster score is below 1, so there will be no values<1 for fitness calculation.
   -- It will pull all scores down, if worst cluster score is above 1, to guarantee maximum privilege by fitness.
   -- If all clusters would have similar big score values, they would be choosen equally.
   -- By shifting the scores making the last score be 1, other scores are always x-times higher than 1.

   Fitness=0
   local k
   for k=1,HerdSize do
    ClusterScore2[k]=ClusterScore2[k]-FitnessOffset+1 -- Shift cluster score copy by offset to met condition
   -- We can overwrite this table, because it is only needed for breeding, and it won't affect the original table.
   -- Original score will remain untouched.
    Fitness=Fitness+ClusterScore2[k] -- Calculate fitness by adding all scores (offset included)

   end -- k loop

   local k
   for k=BreedFirst,BreedLast do
    ClusterBreed(k,TimeStamp)
   end -- k loop
end -- function

function Roulette()
 -- Returns a random cluster index (not slot), the better their score, the more often they will appear
 local TValue=random()*(Fitness+1) -- Target fitness value, which will stop the wheel
 local CValue=0 -- Current value, where single cluster points will be added
 local Wheel=random(1,HerdSize) -- Random initial wheel position
 repeat
  Wheel=Wheel+1 -- Spin Wheel
  if Wheel>HerdSize then Wheel=1 end -- If Wheel made a full turn, it starts at 1 again
  CValue=CValue+ClusterScore2[ClusterPointer[Wheel]]
  -- Increase current value by score of cluster at wheel position
 until CValue>TValue
 return Wheel
end -- function

function ClusterBreed(indexClusterB,TimeStamp)
 local indexClusterB=indexClusterB -- Target cluster
 local TimeStamp=TimeStamp -- "birth date"

 local indexClusterA1 -- Source cluster 1
 if Parent1isRoulette==false then
   indexClusterA1=indexClusterB-BreedFirst+1 -- Choose best, starting with 1
  else
   indexClusterA1=Roulette() -- Choose one by fitness roulette, the better the score, the more often it can be chosen
 end -- if Parent1isRoulette

 local indexClusterA2 -- Source cluster 2
 if Parent2isRoulette==true then
   repeat
    indexClusterA2=Roulette() -- Choose one by fitness roulette, the better the score, the more often it can be chosen
   until indexClusterA2~=indexClusterA1 -- clusters must be different
  else
   indexClusterA2=indexClusterA1+1 -- Take next to Parent 1
   if indexClusterA2>HerdSize then indexClusterA2=1 end
 end -- if Parent2isRoulette

 local ClusterB=ClusterPointer[indexClusterB] -- Fetch save slot for target cluster
 local ClusterA1=ClusterPointer[indexClusterA1] -- Fetch load slot for source cluster 1
 local ClusterA2=ClusterPointer[indexClusterA2] -- Fetch load slot for source cluster 2

 print("Breeding ",indexClusterA1,"(",ClusterA1,") and ",indexClusterA2,"(",ClusterA2,") to ",indexClusterB,"(",ClusterB,")")

 ClusterType[ClusterB]="breeded".."-"..TimeStamp

 ClusterDrift[ClusterB]=ClusterDrift2[ClusterA1]

  if ClusterBands>0 then -- We only need to copy if there are any bands
   local CrossoverEnd
   if MultiCrossOver== false then
    CrossoverEnd=CreateCrossoverPoint(ClusterBands) -- Create
    print("Band crossover point: ",CrossoverEnd) -- and show crossover point
   end -- if MultiCrossOver

   ClusterSegA[ClusterB]={}
   ClusterSegB[ClusterB]={}
   ClusterLength[ClusterB]={}
   ClusterStrength[ClusterB]={}

   local BandsChild
   local l
   for l=1,ClusterBands do -- Is crossover point reached?
    if CrossOverCheck(CrossoverEnd,l) then
      BandsChild=ClusterA2 -- Take mom after crossover point
     else
      BandsChild=ClusterA1 -- Take dad until crossover point
    end -- if CrossoverEnd
    ClusterSegA[ClusterB][l]=ClusterSegA2[BandsChild][l]
    ClusterSegB[ClusterB][l]=ClusterSegB2[BandsChild][l]
    ClusterLength[ClusterB][l]=ClusterLength2[BandsChild][l]
    ClusterStrength[ClusterB][l]=ClusterStrength2[BandsChild][l]
   end -- l loop
  end -- if ClusterBands

  if ClusterFreezes>0 then -- We only need to copy if there are any freezes
  local CrossoverEnd
   if MultiCrossOver== false then
    CrossoverEnd=CreateCrossoverPoint(ClusterFreezes) -- Create
    print("Freeze crossover point: ",CrossoverEnd) -- and show crossover point
   end -- if MultiCrossOver

   ClusterFreeze[ClusterB]={}

   local FreezesChild
   local l
   for l=1,ClusterFreezes do -- For all freezes
    if CrossOverCheck(CrossoverEnd,l) then -- Is crossover point reached?
      FreezesChild=ClusterA2 -- Take mom after crossover point
     else
      FreezesChild=ClusterA1 -- Take dad until crossover point
    end -- if CrossoverEnd
    ClusterFreeze[ClusterB][l]=ClusterFreeze2[FreezesChild][l]
   end -- l loop
  end -- if ClusterFreezes

  -- Cluster mutating starts here
  -- Secondary cluster set not needed anymore
  -- Mutation is directly performed on target cluster

  if ClusterBands>0 then
  local l
   for l=1,ClusterBands do
    if puzzle_is_ligand==false then -- only on non-ligand-puzzles mutate segment A
     if random_flag(DriftProb)==1 then
      ClusterSegA[ClusterB][l]=add_drift(ClusterSegA[ClusterB][l],ClusterDrift[ClusterB])
     end -- if random_flag
    end -- if puzzle_is_ligand

    if random_flag(InvBProb)==1 then
     ClusterSegA[ClusterB][l]=-ClusterSegA[ClusterB][l] -- invert
    end -- if random_flag

    repeat
     if random_flag(DriftProb)==1 then
      ClusterSegB[ClusterB][l]=add_drift(ClusterSegB[ClusterB][l],ClusterDrift[ClusterB])
     end -- if random_flag
     local Distance=index_distance(ClusterSegA[ClusterB][l],ClusterSegB[ClusterB][l])
    until Distance>=MID_Game -- Segments must have a minimum index distance

    if random_flag(DriftProb)==1 then -- mutation allowed
     local Change=random_direction()*10^-random(1,3) -- generate random drift
     ClusterLength[ClusterB][l]=ClusterLength[ClusterB][l]+Change -- and add it
     if ClusterLength[ClusterB][l]<MinBF then ClusterLength[ClusterB][l]=ClusterLength[ClusterB][l]-2*Change end
     -- if too small, take opposite drift
     if ClusterLength[ClusterB][l]>MaxBF then ClusterLength[ClusterB][l]=ClusterLength[ClusterB][l]-2*Change end
     -- if too big, take opposite drift
     if ClusterLength[ClusterB][l]<MinBF then ClusterLength[ClusterB][l]=frandom(MinBF,MaxBF,6) end
     -- if still to small, take new random value
     if ClusterLength[ClusterB][l]>MaxBF then ClusterLength[ClusterB][l]=frandom(MinBF,MaxBF,6) end
     -- if still to big, take new random value
    end -- if random_flag

    if random_flag(DriftProb)==1 then
     local Change=random_direction()*10^-random(1,3) -- generate random drift
     ClusterStrength[ClusterB][l]=ClusterStrength[ClusterB][l]+Change
     if ClusterStrength[ClusterB][l]<MinBS then ClusterStrength[ClusterB][l]=ClusterStrength[ClusterB][l]-2*Change end
     if ClusterStrength[ClusterB][l]>MaxBS then ClusterStrength[ClusterB][l]=ClusterStrength[ClusterB][l]-2*Change end
     if ClusterStrength[ClusterB][l]<MinBS then ClusterStrength[ClusterB][l]=frandom(MinBS,MaxBS,3) end
     if ClusterStrength[ClusterB][l]>MaxBS then ClusterStrength[ClusterB][l]=frandom(MinBS,MaxBS,3) end
    end -- if random_flag
   end  -- l loop
  end -- if ClusterBands

  if ClusterFreezes>0 then
   local l
   for l=1,ClusterFreezes do
    if random_flag(DriftProb)==1 then
    ClusterFreeze[ClusterB][l]=add_drift(ClusterFreeze[ClusterB][l],ClusterDrift[ClusterB])
    end -- if random_flag

    if random_flag(InvFProb)==1 then
     ClusterFreeze[ClusterB][l]=-ClusterFreeze[ClusterB][l] -- invert
    end -- if random_flag
   end -- l loop
  end -- if
end -- function

function CrossOverCheck(CrossoverEnd,Pos)
 local CrossoverEnd=CrossoverEnd
 local Pos=Pos

 if MultiCrossOver then
   if random_flag(0.5)==1 then
     return true
    else
     return false
   end -- if random_flag
  else -- if MultiCrossOver is false
   if Pos>CrossoverEnd then
     return true
    else
     return false
   end -- if Pos
 end -- if
end -- function

function random_flag(Prob)
 -- Returns a random value; either 0 or 1, depending on probability Prob
 local Prob=Prob
 if Prob<=0 then
   return 0
  else -- If Prob~=0
   if random()<Prob then
     return 1
    else
     return 0
   end -- if random
 end -- if Prob
end -- function

function random_direction()
 return random_flag(0.5)*2-1
end -- function

function add_drift(Segment,Drift)
 local Seg1=Segment
 local Seg1sgn=sgn(Seg1)
 local Drift=Drift

 local Seg2=Seg1+Drift*Seg1sgn
 local Seg2abs=abs(Seg2)

 if Seg2abs<1 then
   Seg2=NumSegs*Seg1sgn
  elseif Seg2abs>NumSegs then
   Seg2=Seg1sgn
 end -- if Seg2abs
 return Seg2
end -- function

function band_delete_all()
 while get_band_count()>0 do band_delete(1) end
end -- function

function xtool(method,iter,tL2)
  -- unifies score-conditional shake and wiggle into one function
  local OS=""
  local iter=iter
  local tL2=tL2
  if iter>0 then
    OS="max iter:"..iter
  end -- if
  -- print("Method:",method," ",OS," threshold:",tL2)
  local curr_iter=0
  local exit_condition=false
  repeat
   curr_iter=curr_iter+1
   -- print(" Testing with iterations: ",curr_iter)
   local tempScore=get_score(true)
   if method=="s" then
     do_shake(curr_iter)
    elseif method=="wb" then
     do_global_wiggle_backbone(curr_iter)
    elseif method=="ws" then
     do_global_wiggle_sidechains(curr_iter)
    else
     do_global_wiggle_all(curr_iter)
   end -- if method
   local tempScore2=get_score(true)
   local rDelta=(tempScore2-tempScore)/curr_iter
   -- print(" Rel. change: ",rDelta," pts/iteration")
   if curr_iter==iter then exit_condition=true end
   if abs(rDelta)<tL2 then exit_condition=true end
  until exit_condition==true
end -- function

-- Inspired by vertex's blue fuse script
-- You may want to tweak this function

function PinkFuse()
    quicksave(3) -- store state before fuse
     print("Release 1")
     set_behavior_clash_importance(0.1)
     xtool("s",Shakes,ScoreThreshold)
     BestScoreCheck()
      set_behavior_clash_importance(0.7)
      xtool("wa",Wiggles,ScoreThreshold)
      BestScoreCheck()
    FuseEnd()

    quickload(3) -- load state before fuse
     print("Release 2")
     set_behavior_clash_importance(0.3)
     xtool("s",Shakes,ScoreThreshold)
     BestScoreCheck()
      set_behavior_clash_importance(0.6)
      xtool("wa",Wiggles,ScoreThreshold)
      BestScoreCheck()
    FuseEnd()

    quickload(3) -- load state before fuse
     print("Release 3")
     set_behavior_clash_importance(0.5)
     xtool("wa",Wiggles,ScoreThreshold)
     BestScoreCheck()
      set_behavior_clash_importance(1)
      xtool("wa",Wiggles,ScoreThreshold)
      BestScoreCheck()
       set_behavior_clash_importance(0.7)
       xtool("wa",Wiggles,ScoreThreshold)
       BestScoreCheck()
    FuseEnd()

    quickload(3) -- load state before fuse
     print("Release 4")
     set_behavior_clash_importance(0.7)
     xtool("wa",Wiggles,ScoreThreshold)
     BestScoreCheck()
      set_behavior_clash_importance(1)
      xtool("wa",Wiggles,ScoreThreshold)
      BestScoreCheck()
       set_behavior_clash_importance(0.5)
       xtool("wa",Wiggles,ScoreThreshold)
       BestScoreCheck()
    FuseEnd()
end

function FuseEnd()
    -- Fuse try finishing with CI=1
    set_behavior_clash_importance(1)
    xtool("wa",Wiggles,ScoreThreshold)
    xtool("s",Shakes,ScoreThreshold)
    xtool("wa",Wiggles,ScoreThreshold)
    BestScoreCheck()
end -- function

function BestScoreCheck()
   local TempScore=get_score(true)

   if LastBest then
    if TempScore>ACS5 then
     quicksave(5) -- Set best cluster result for this generation
     ACS5=TempScore
     -- print("ACS5 is ",ACS5)
    end -- if TempScore
   end -- if LastBest

    if TempScore>ACS4 then
     quicksave(4) -- Set best cluster result for current cluster
     ACS4=TempScore
    end -- if TempScore

   if TempScore>BestScore then
    -- reset_recent_best()
    BestScore=TempScore
    print("New best total score: ",BestScore)
    BSChange=true
   end -- if
end -- function

function PullDownEqualResults()
 print("Checking for double results...")
 -- Compare all cluster points with next in list
 -- If next has the same score, move this cluster to end.

 local kEnd=HerdSize-1
 local k
 for k=1,kEnd do
  while ClusterScore[ClusterPointer[k]]==ClusterScore[ClusterPointer[k+1]] do
  -- If next has the same score
   ClusterScore[ClusterPointer[k+1]]=ClusterScore[ClusterPointer[HerdSize]]-1
   -- make its score more worse then the baddest cluster
   SortHerd() -- so it is placed at the end when sorting by score
  end -- while ClusterScore
 end -- k
end -- function

function InitializeClusterData()
 ClusterScore={}
 ClusterType={}
 ClusterDrift={}

  ClusterSegA={}
  ClusterSegB={}
  ClusterLength={}
  ClusterStrength={}

  ClusterFreeze={}

 ClusterPointer={}
 local k
 for k=1,HerdSize do
  ClusterPointer[k]=k
 end -- k
end -- function

function PrintStartingTests()
 print()
 local OS=" "
 if Runs==1 then
   OS=OS.."1 run"
  else
   if Runs>1 then
     OS=OS..Runs
    else
     OS=OS.."infinite"
   end -- if
   OS=OS.." runs"
 end -- if
 print("Starting cluster tests for ",OS,"...")
end -- function

function select_close_ligand()
 local LigandSegment=NumSegs+1
 local k
 for k=1,NumSegs do
  if get_segment_distance(k,LigandSegment)<=MutateLigandDistance then
   select_index(k)
   -- print(k," is close enough to ligand for mutating.")
  end -- if get_segment_distance
 end -- k loop
end -- function

function SetRebuildWorst()
 -- Acitvate rebuild worst if forced or condidtions are met
 if RebuildForce==nil then
   --[[
   if BSChange then
     RebuildWorst=false
    else
     RebuildWorst=true
   end -- if BSChange
   ]]--
   RebuildWorst=BSValueCheck()
  else
   RebuildWorst=RebuildForce
 end -- if RebuildForce
end -- function

function BSValueCheck()
 -- Returns true if current generation's best cluster didn't do much
 local ChangeTooSmall=false
 if BSValue>=0 then -- If last generation's best cluster score is better than at generation start
   if BSValue<SCPT then -- but below limit
    ChangeTooSmall=true
   end -- if BSValue
  else -- if BSValue<0  -- If last generation's best cluster score is not better than at generation start
   if BSValue>SCNT then  -- but above limit
    ChangeTooSmall=true
   end -- if BSValue
 end -- if BSValue
 return ChangeTooSmall
end -- function

function SetLSC(LSC)
 -- Changes first cluster to trest if forced or conditions are met
 local LSC=LSC
 if LSCForce==nil then
   if BSChange or BSValueCheck()==false then -- If there was a considerable change
     LSC=1 -- check all clusters again in next generation
    else -- If there was no considerable change
     LSC=LSC+1 -- increase start cluster for this generation (don't test best again)
     if LSC>BreedFirst then LSC=BreedFirst end -- but not further than BreedFirst
   end -- if BSChange
  else -- if LSCForce not nil
   LSC=LSCForce
 end -- if LSCForce
 return LSC
end -- function

function GAB()
 -- quickload(1): Puzzle state at GAB Start
 -- quickload(2): Puzzle state at generation start
 -- quickload(3): Puzzle state at fuse start
 -- quickload(4): Best result for current cluster
 -- quickload(5): Best result for current generation

 print("Starting GAB-III...")
 print ("Minimum allowed bandlength: ",MinBL_Game)
 print ("Maximum allowed bandlength: ",MaxBL_Game)
 
 randomseed(getseed())  -- initialize random seed

 UseList=CheckUselist(UseList)
 shuffle2(ShuffleProb) -- Shuffle UseList and reset pointer

 InitializeClusterData()

 FillHerd(1,HerdSize,1) -- From 1 to HerdSize

 -- ShowHerd()

 band_delete_all() -- clean bands
 do_unfreeze_all() -- and freezes
 set_behavior_clash_importance(1)
 deselect_all()
 reset_recent_best()

 quicksave(1) -- Save initial puzzle state
 BestScore=get_score(true) -- initialize best score (ACS1)

 PrintStartingTests(Runs)

 local LSC=1
 CRun=0 -- set CRun to 0, counting up after each cluster generation
 repeat
  CRun=CRun+1 -- Increase current run value
  if CRun>1 then
    if RecentHybrid>0 then -- If RecentHybrid>0, tweak RecentUse
     if (CRun-1)%RecentHybrid==0 then -- Each RecentHybrid runs
       RecentUse=true -- use recent best
      else -- If not
       RecentUse=false -- don't use recent best
     end -- if CRun
    end -- if RecentHybrid
    if LastBest==false then
      if RecentUse then
        print("Loaded recent best.")
        restore_recent_best() -- Load best result so far
       else
        print("Loaded initial state.")
        quickload(1) -- Load initial state
      end -- if RecentUse
     else -- if LastBest is true
      print("Loaded last generation's best.")
      quickload(5) -- Load best cluster result of last generation
    end -- if LastBest
    SetRebuildWorst()
    LSC=SetLSC(LSC)
  end -- if CRun

  if RebuildWorstGen then -- If rebuild is requestet at geneartion start
   rebuild_worst() -- do it
  end

  BSChange=false -- Reset improvement information

  quicksave(2) -- Set this state as start state for current generation
  ACS2=get_score(true) -- Get score at start for this generation
  print()
  print("Score now: ",ACS2)

  local k2
  for k2=LSC,HerdSize do
   local k=ClusterPointer[k2] -- fetch content of cluster slot from pointer
   print()
   print("Gen.:",CRun," cluster:",k2,"(",k,")/",HerdSize," drift:",ClusterDrift[k]," type:",ClusterType[k])

   if k2>LSC then
      -- print("Loaded Quicksave 1.")
      quickload(2)
   end -- if k2

   band_delete_all() -- remove all bands, because recent best can contain some
   do_unfreeze_all() -- and freezing to apply others

   if ClusterBands>0 then
    local l
    for l=1,ClusterBands do
     if ClusterSegA[k][l]>0 then
       band_add_segment_segment(ClusterSegA[k][l],ClusterSegB[k][l])
       local TempBandCount=get_band_count()
       -- fetch current band number index to make setting its length and strength possible

       local Length=LengthWithFactor(ClusterSegA[k][l],ClusterSegB[k][l],ClusterLength[k][l])

       local BandDisabled=false
       local BLClamped=false

       if Length>MaxBL_Game then
         Length=MaxBL_Game
         BLClamped=true
        elseif Length<MinBL_Game then
         Length=MinBL_Game
         BLClamped=true
       end

       if BLClamped and BLdisable then
          band_disable(TempBandCount)
          BandDisabled=true
       end -- BLClamped and BLdisable

       local Length1R=CutOff(ClusterLength[k][l],3) -- Cut after 3 decimal digits before displaying
       local Length2R=CutOff(Length,3) -- Cut after 3 decimal digits before displaying

       local OS="Band "..l..": "..ClusterSegA[k][l]..":"..ClusterSegB[k][l]
       OS=OS.." L:"..Length1R.."="..Length2R
       if ShowBF then
        print(OS," S:",ClusterStrength[k][l])
       end -- if
       
       if BLClamped then
        OS="Band is "
        if BandDisabled then
          OS=OS.."disabled"
         else
          OS=OS.."clamped"
        end -- if BandDisabled
        print(OS," because length is out of boundary ",MinBL_Game," to ",MaxBL_Game)
       end -- if BLClamped

       band_set_length(TempBandCount,Length) -- Set current band length
       band_set_strength(TempBandCount,ClusterStrength[k][l]) -- Set current band strength

      else -- if ClusterSegA[k][l] is <0, which means band is deactivated
      if ShowBF then
       print("Band ",l,": off")
      end -- if
     end -- if ClusterSegA
    end -- l loop
   end -- if ClusterBands

   if RebuildWorstGen==false then rebuild_worst() end

   deselect_all() -- Before freezing, so we can select segments to freeze

   if ClusterFreezes>0 then -- if there are segments to freeze
    local l
    for l=1,ClusterFreezes do  -- select all segments to freeze
     if ClusterFreeze[k][l]>0 then
       if ShowBF then
        print("Freeze ",l,": ",ClusterFreeze[k][l])
       end -- if
       select_index(ClusterFreeze[k][l])
      else
      if ShowBF then
       print("Freeze ",l,": off")
      end -- if
     end -- if ClusterFreez
    end -- l loop
   end -- if ClusterFreezes

   if puzzle_is_ligand then -- if this is a ligand puzzle
     select_index(NumSegs+1) --  select ligand for freezing
     do_freeze(true,true) -- freeze backbone and sidechains
    else -- if this is not a ligand puzzle
      if ClusterFreezes>0 then -- but there are segments to freeze
       do_freeze(true,false) -- freeze backbone only
      end -- if ClusterFreezes
   end -- if puzzle_is_ligand

   if ConstantBands==true then
    add_constant_bands() -- You can add some bands or freezes in this routine, which should appear each try
   end -- if

   print("Pulling...")
   set_behavior_clash_importance(CI_pull)
   select_all() -- Select all segments to wiggle
   do_global_wiggle_all(PWiggles) -- Just a small pull

   band_delete_all() -- clean up bands before saving
   do_unfreeze_all() -- clean up freezes before saving

   if LastBest then -- If LastBest Mode
    if k2==LSC then -- and this is the first try of current generation
     ACS5=get_score(true)
     -- initialize current generation best score
    end -- if k2
   end -- if LastBest

   quicksave(4) -- Initialize this state as reference for current cluster best score
   ACS4=get_score(true) -- and initialize current cluster best score
   BestScoreCheck() -- raise BestScore ACS4, if result is better

   xMutate(Mutating1) -- including BestScoreCheck

   Release() -- including Fuse and BestScoreCheck

   xMutate(Mutating2) -- including BestScoreCheck

   ClusterScore[k]=ACS4-ACS2 -- Store best score minus start score for this try as cluster score
   print("Difference to start: ",ClusterScore[k])
  end -- k loop, take next cluster

  print()
  print("Sorting Cluster list by score...")
  SortHerd() -- Sort herd by score difference
  ShowScoreList()

  BSValue=ClusterScore[ClusterPointer[1]] -- Fetch best score difference

  PullDownEqualResults() -- Move duplicate results to end of herd

  Breed(CRun+1) -- Range: BreedFirst to BreedLast

  if BSValueCheck() or BSValue<=0 then -- If generation's best cluster has low or negative score difference
   print("No or few improvement for this generation.")
   if HerdSize<IncHerdSize then -- and herd size increasing is allowed
    print("Increasing herd size.")
    local k
    for k=1,2 do -- Increase herd size by 2 individuums
     HerdSize=HerdSize+1 -- Increase herd size
     ClusterPointer[HerdSize]=HerdSize -- and number of cluster save slots; set them to its own value
    end -- k loop
    BreedLast=BreedLast+1 -- Increase breed slots by 1
   end -- if incHerdSize
  end -- if BSChange

  FillHerd(BreedLast+1,HerdSize,CRun+1)
  -- generate random clustes behind breeded ones
  -- ShowHerdShort()

 until CRun==Runs
end -- function GAB

function FactorByLength(SegA,SegB)
 -- As mimic doesn't use random band lengths (with random factor) but tries to imitate current puzzle state,
 -- we have not to generate but to calculate the factor value
 -- This is the opposite of function LengthWithFactor

 local SegA=SegA
 local SegB=SegB

 local Min=SpatMin(SegA,SegB)
 
 return (get_segment_distance(SegA,SegB)-Min)/(SpatMax(SegA,SegB)-Min)
end -- function

function LengthWithFactor(SegA,SegB,Factor)
 -- Apply length factor to range between minimum allowed band length and maximum allowed band length
 -- Factor=0 results minimum allowed band length
 -- Factor=1 results maximum allowed band length

 local SegA=SegA
 local SegB=SegB
 local Factor=Factor
 
 local Min=SpatMin(SegA,SegB)
 
 return Factor*(SpatMax(SegA,SegB)-Min)+Min
end -- function

function SpatMin(SegA,SegB)
 -- Fetch minimum allowed band length, used when BandFactor is 0
 -- If this is a ligand puzzle, fetch it by segment spatial distance
 -- If this is no ligand puzzle, fetch it by segment index/spatial distance

 local SegA=SegA
 local SegB=SegB

 local TDistVal

    if BLbyIndex==false or puzzle_is_ligand then -- if this is a ligand puzzle or using bandlength by index is deactivated
      TDistVal=get_segment_distance(SegA,SegB)-BLchangeDown -- fetch segment spatial distance and subtract maximum change value
     else
      TDistVal=MinBL_Game
      -- take this minimum length value to prevent excessive puzzle crunching
    end -- if BLbyIndex

  -- if TDistVal<MinBL_Game then TDistVal=MinBL_Game end
  -- if the calculated value is too low, set it to minimum allowed value

 -- print("Minimum: ",TDistVal)

 return TDistVal
end -- function

function SpatMax(SegA,SegB)
 -- Fetch maximum allowed band length, used when BandFactor is 1
 -- If this is a ligand puzzle, fetch it by segment spatial distance
 -- If this is no ligand puzzle, fetch it by segment index/spatial distance

 local SegA=SegA
 local SegB=SegB

 local TDistVal

    if BLbyIndex==false or puzzle_is_ligand then -- if this is a ligand puzzle or using bandlength by index is deactivated
      TDistVal=get_segment_distance(SegA,SegB)+BLchangeUp -- fetch segment spatial distance and add maximum change value
     else
      TDistVal=3.8*index_distance(SegA,SegB)+.1 -- fetch segment index distance and multiply it with 3.8
      -- take this maximum length value depending on index distance to prevent excessive puzzle stretching
    end -- if BLbyIndex

 -- if TDistVal>MaxBL_Game then TDistVal=MaxBL_Game end
 -- if the calculated value exceeds, set it to maximum allowed value

 -- print("Maximum: ",TDistVal)

 return TDistVal
end -- function

function index_distance(SegA,SegB)
 -- Fetch segment index distance
 
 local SegA=SegA
 local SegB=SegB
 
 return abs(abs(SegA)-SegB)
end -- function

function Release()
  if Releasing then
    -- print("Score after pulling: ",ACS4)
    print("Releasing...")
    quickload(4) -- load best cluster result so far
    select_all()
    if Fuse then
      PinkFuse() -- quicksave(4), raise BestScore and ACS4, if result is better
     else
      set_behavior_clash_importance(1)
      do_shake(1)
      do_global_wiggle_all(12)
      BestScoreCheck() -- quicksave(4), raise BestScore and ACS4, if result is better
    end -- if fuse
   end -- if Releasing
end -- function

function rebuild_worst()
 if RebuildWorst then
  print("Rebuilding worst...")
  deselect_all()
  local WorstScore
  local SegmentIndex
  local k
  for k=1,NumSegs do
   local SegmentScore=get_segment_score(k)
   if k==1 or SegmentScore<WorstScore then
    WorstScore=SegmentScore
    SegmentIndex=k
   end -- if SegmentScore
  end -- k
  local SegA=SegmentIndex-RebuildRange
  local SegB=SegmentIndex+RebuildRange
  while SegA<1 do
   SegA=SegA+1
   SegB=SegB+1
  end -- while SegA
  while SegB>NumSegs do
   SegA=SegA-1
   SegB=SegB-1
  end -- while SegA
  for k=SegA,SegB do
   select_index(k)
  end -- k loop
  do_local_rebuild(RebuildIter)
 end -- if RebuildWorst
end -- function

function xMutate(Mutating)
   if Mutating then
    quickload(4) -- load best result for this cluster so far
    print("Mutating...")
    if puzzle_is_ligand then
      deselect_all() -- clear selection
      select_close_ligand() -- select all segments close as MutateLigandDistance or less to ligand
     else
      select_all()
    end -- if puzzle_is_ligand
    do_mutate(1)
    BestScoreCheck() -- Check if it made an improvement
   end -- if Mutating
end -- function

function detect_ligand(flag)
 --[[
 ligand puzzle detection
 normally, segments have a secondary structure of "E", "H" or "L"
 and they always have a spatial distance of about 3.75 to 3.85 to their next index neighbour.
 a ligand is more far away.

 this function should respond true if this is a ligand puzzle, and false if it is not.
 if flag is nil, ligand auto-detection is enabled, distance of last two segments is checked
 if flag is not nil, ligand auto-detection is disabled, result is flag

 It also returns the last segment index which is no ligand
 ]]--

 local flag=flag

 local LastPos=get_segment_count() -- fetch very last segment index number

 if flag==nil then -- Only if flag is nil, detect if there is a ligand and change flag
   print("Detecting if there is a ligand.")
   local ss=get_ss(LastPos)
   flag=not(ss=="L" or ss=="H" or ss=="E" )
   -- if last segment's ss is neither "l" nor "h" nor "e"
   flag=flag or (get_segment_distance(LastPos-1,LastPos)>=3.9)
   -- or distance to second last segment is bigger or equal than 3.9
 end -- if

 local os="This should be "
 if flag then
   os=os.."a"
   LastPos=LastPos-1
  else
   os=os.."no"
 end -- if flag
 print(os," ligand puzzle.")

 return flag,LastPos
end -- function

function create_UseList(flag)
 -- Creates segment use list depending on which puzzle-type is there

 local flag=flag

 UseList={}
                      -- Initialize list of segments to use
                      -- UseList extensions (true) are applied to list, so multiple selected segments will appear more often
 if flag==false then -- If this is no ligand puzzle
   UseList=UseSegIRange(UseList,1,NumSegs,1,true)
                      -- Set every segment index from 1 to puzzle size as bandable
   UseList=Use_distance(UseList,0,8,10,1200,false)
                      -- Consider all segments which have min 10 to max 1200 neighbours
                      -- over a distance of 0 to 8 as non-solitary and remove them from list
   UseList=UseSegIRange(UseList,1,NumSegs,1,true)
                      -- Add a complete segment set again to make sure that distance check didn't erase all
   UseList=Use_ss(UseList,"L",true)
                      -- Add segments with this secondary structure
                        -- "L"=loop
                        -- "H"=helix
                        -- "E"=sheet
   -- UseList=UseSegIRange(UseList,1,NumSegs,2,false)
                      -- Set every 2nd segment index between 1 to puzzle size as not bandable, example
   -- UseList=UseSegIValues(UseList,{1;3;9},true)
                      -- Include these single segments as bandable, example
   -- UseList=UseSegIValues(UseList,{2;5;10},false)
                      -- Exclude these single segments as bandable, example
   -- UseList=Use_aa(UseList,{"g";"a"},true)
                      -- Set this amino acid as bandable, example
  else -- If this is a ligand puzzle
   UseList=Use_close_ligand(UseList,20,true)
                      -- Set segments which have a maximum spatial distance of 20 to ligand as bandable
 end -- if flag
end -- function

function LastBandLengthStrength(Length,Strength)
 -- sets length and strength of the very last band to default values
 local TempBandCount=get_band_count()
 band_set_length(TempBandCount,Length)
 band_set_strength(TempBandCount,Strength)
end -- function

function add_constant_bands()
 -- Add some constant bands to fix parts of the puzzle here
 -- and/or freeze some parts

 band_add_segment_segment(40,15)
 LastBandLengthStrength(5,0.1)

 --[[
 deselect_all()
 for k=10,11 do
  select_index(k)
 end -- k
 do_freeze(true,false)
 ]]--
end -- function

 Runs=0
                     -- Number of runs (generations), integer value
                       -- Set to <1 to run infinitely
 puzzle_is_ligand,NumSegs=detect_ligand()
                     -- puzzle_is_ligand: Ligand flag, boolean value
                       -- true for ligand puzzle
                       -- false for non-ligand-puzzle
                     -- NumSegs: Last segment index which is no ligand, integer value
                     -- detect_ligand(): Ligand auto detection.
                       -- If it fails, use detect_ligand(true) to declare that this is a ligand puzzle
                       -- and detect_ligand(false) to declare that this is a no ligand puzzle
 create_UseList(puzzle_is_ligand)
                      -- Initialize segment working list
                      -- Depending on puzzle type
 MID_Game=3
                       -- Minimum index distance of segment indices, integer value >=2
                       -- As the game doesn't allow banding the segments with themselves or the nearest neighbour,
                       -- This value is needed to prevent game errors,
                       -- but you can also use it to prevent sharp backbone turns.
 MinBF=0
                      -- Minimum length factor per random band, float value >=0 <MaxBF <=1
 MaxBF=1
                      -- Maximum length factor per random band, float value >=0 >MinBF <=1

                      -- Script creates a random factor between MinBF and MaxBF for each random band.
                      -- A random value of 0 creates a band with minimum bandlength,
                      -- A random value of 1 creates a band with maximum bandlength
                      -- Minimum and maximum random bandlengths are specified by BLbyIndex, BLchangeDown and BLchangeUp
 MinBL_Game=3.8
                       -- Minimum band length limiter, float value >=0 and <=MaxBL_Game
                       -- Opposite of MaxBL_Game
                       -- Prevents bands getting too short
 MaxBL_Game=10000
                       -- Maximum band length limiter, float value <=10000 and >=MinBL_Game
                       -- In rough, values about 20 or lower tend to compress the puzzle, values above 20 allow decompressing (stretching)
                       -- Maximum expedient value for a puzzle is about (number of segments-1)*3.8,
                        -- which would stretch the region between connected segments completely out.
 BLdisable=false
                       -- Bandlength disabling flag, boolean value
                        -- true: if calculated bandlength gets under MinBL_Game or exceeds MaxBL_Game,
                         -- bands are deactivated
                        -- other value: band length is adapted to minimum/maximum,
                         -- but bands are still active (length clamping)
 BLchangeDown=3.8
                       -- Maximum band change down, float value >=0
                       -- Generated bands are maximum this value shorter than spatial distance of banded segments
 BLchangeUp=3.8
                       -- Maximum band change up, float value >=0
                       -- Generated bands are maximum this value longer than spatial distance of banded segments
 BLbyIndex=false
                       -- Use index distance for calculating band length, boolean value
                        -- false: new behaviour. When applying bands, BLchangeUp and BLchangeDown are used to create bands, dependend on spatial segment distance
                        -- other values: old behaviour: BLchangeUp and BLchangeDown are ignored to create bands, band length is dependend on segment index distance
 BreedFirst=3
                      -- First cluster to change by breeding, integer value
                      -- All clusters before this index will be kept as good solution and as potential parents for breeding new solutions
                        -- Setting this to 1 is not a good idea, because you will loose good clusters
 BreedLast=5
                      -- Last cluster to change by breeding, integer value >=BreedFirst and <=HerdSize
                        -- Will be increased if no better solution was found
 HerdSize=8
                      -- Number of clusters, integer value >=BreedLast
                        -- Will be increased if no better solution was found
 IncHerdSize=16
                      -- Increase herdsize, integer value
                        -- Allows increasing the herdsize if no better solution was found (will generate more clusters)
                        -- if >HerdSize, allow increasing herdsize until this amount
                        -- if <=HerdSize, no increasing
 ShowBF=true
                      -- Shows band and freeze details, boolean value
                        -- if true (default), segments which are banded or frozen are shown by text
 ClusterBands=4
                      -- Maximum Bands to create per cluster, integer value >=0
 ClusterFreezes=3
                      -- Maximum segments to freeze by random, integer value >=0
 MinBS=0.8
                      -- Minimum strength per (random chosen) band, float value
                        -- Use decimal number between .1 and 10
 MaxBS=1.2
                      -- Minimum strength per (random chosen) band, float value
                        -- Use decimal number between .1 and 10 and >=MinBS
 Shakes=1
                      -- Number of iterations for fuse-shake, integer value
 Wiggles=4
                      -- Number of iterations for fuse-wiggle, integer value
 PWiggles=1
                      -- Number of iterations for pulling, integer value
 CI_pull=1
                      -- Clashing importance for pulling, float value >=0 and <=1
                        -- Default is 1
                        -- Reduce this to make pulling more drastic
 Releasing=true
                      -- Release flag, boolean value
                        -- true (default)= After pulling, releasing is performed.
                        -- false= releasing is skipped
 Fuse=true
                      -- Fuse flag, boolean value
                        -- true  (default)= After pulling, Fuse is performed.
                        -- false= after pulling, just a shake(1) and wiggle_all(12) with CI=1 is performed
 MutateLigandDistance=15
                      -- Radius length for selection sphere around ligand, where mutating is performed.
                        -- Selects only segments which are this or more close to the ligand for mutating.
 ScoreThreshold=0.5
                      -- Threshold value for shake and wiggles, float value >=0
                        -- This won't repeat some w/s, if absolute score change per itertation is below this
 MultiCrossOver=true
                      -- Multi crossover flag, boolean value
                        -- false (default)= One crossover point for each breeding is generated.
                        -- true= Each gene can be from mom or dad
 Parent1isRoulette=false
                      -- Roulette flag for breeding parent 1, boolean value
                        -- if false (default), parent is cluster with best score and downwards
                          -- use this to force good clusters for breeding
                        -- if true, parent is chosen by fitness roulette
 Parent2isRoulette=true
                      -- Roulette flag for breeding parent 2, boolean value
                      -- if true (default), parent is chosen by fitness roulette
                      -- if false, parent is next to parent 1
                        -- use this to force good clusters for breeding
 DriftProb=0.3
                      -- band drift (cluster mutation) probability, float value >=0 and <1
                        -- Probability, if drift is added or not
 InvBProb=0.2
                      -- Inverting (deactivating/reactivating) probability for bands, float value >=0 and <1
                        -- Makes inversion happen depending on this probability value
 InvFProb=0.3
                      -- Inverting (deactivating/reactivating) probability for freezes, float value >=0 and <1
                        -- Makes inversion happen depending on this probability value
 ShuffleProb=0.9
                      -- Shuffle rate, float value >=0 and <=1
                        -- Used to scramble random segment list, where bands are applied
                        -- 0 lets the list be as it is
                        -- 1 swaps all list entries with a random one behind them in list
 RecentUse=true
                        -- recent best flag, boolean value
                          -- true= recent best is used for each generation
                          -- false= initial state is used for each generation
                            -- prevents getting stuck on local maximum (recommended for endgame)
                          -- If using RecentHybrid or LastBest, this value is ignored
 RecentHybrid=0
                        -- Hybrid behaviour between RecentUse=false/true, integer value >=0
                          -- If ==0, regular behaviour as set in RecentUse
                          -- If >0, recent best is used only all RecentHybrid's generations
                           -- (counting from generation 2)
                          -- 1 would have the same effect as RecentUse=true
                          -- I recommend values>=2 when using it
 LastBest=false
                        -- Flag for using best cluster of current generation, boolean value
                        -- Default is false
                        -- If true, neither recent best nor initial puzzle state are loaded, but best result of current generation,
                        -- allowing unimproving the puzzle to get out of local maximum
                        -- Try this, you are really stuck on a puzzle.
 LSCForce=nil
                       -- Loop start cluster force flag, integer value
                         -- If nil (default), best clusters will only be tested again
                           -- if there was an improvement in last generation
                         -- If >0, start at this cluster after first generation
                           -- If 1, test all clusters again (also good ones)
                           -- If BreedFirst, test only new generated clusters
 SCPT=1
                        -- Score change positive tolerance, float value >=0
                          -- Activates rebuild (if allowed)
                          -- if current generation start score and best cluster score difference
                          -- is below this positive value (not good enough)
 SCNT=-10
                        -- Score change negative tolerance, float value <=0
                          -- Activates rebuild (if allowed)
                          -- if current generation start score and best cluster score difference
                          -- is above this negative value (not bad enough)
 RebuildWorstGen=true
                        -- Rebuild worst at generation start flag, boolean value
                          -- If true, rebuild worst is executed once for current generation
                          -- If false, rebuild worst is executed for each cluster (not recommended)
                          -- If nil, rebuild is never executed.
 RebuildWorst=false
                        -- Rebuild flag at script start, boolean value
                          -- If true,
                          -- rebuild is executed in first generation
 RebuildForce=nil
                        -- Force RebuildWorst, boolean value
                        -- Sets how RebuildWorst is changed.
                          -- If nil (default), worst segment is only rebuilt
                            -- if there was no improvement in last generation
                          -- If true, worst segment is always rebuilt before pulling
                          -- If false, worst segment is never rebuilt before pulling
 RebuildRange=2
                        -- Rebuild range, integer value>=1
                          -- For example, if 1 and worst segment is 3, segments from 2 to 4 are rebuilt.
                          -- if 2 and worst segment is 3, segments from 1 to 5 are rebuilt.
 RebuildIter=1
                      -- Iterations for rebuild worst, integer value>0
 Mutating1=puzzle_is_ligand
                      -- if true, puzzle segment mutating after pulling is performed
 Mutating2=false
                      -- if true, puzzle segment mutating after releasing is performed
 ConstantBands=false
                      -- Add constant bands flag, boolean value
                        -- if true, adds user-defined bands and freezes of add_constant_bands function above
                        -- before regular test-cluster is applied
 Mimic=false
                        -- Mimic flag, boolean value
                          -- if true, first cluster tries to imitate initial puzzle state
 RNDoffset=0
                      -- Random offset, integer value
                        -- As the puzzle score are a reference for the "random" bands and freezes to create,
                        -- you can change this value to change the seed
                        -- useful if you want to restart with other bands, but at the same score.
GAB()