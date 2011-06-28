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


GA Mutate v1.0 by Grom.

Trying to use genetic algorythm to find best aa structure on mutable puzzles:
1. Create initial population by known structures and random ones.
2. Check the score of each one.
3. Make new population:
  1) Choose top 3 solutions.
  2) Create 5 solutions as crossover of top 3.
  3) Create 2 solutions as mutation of top 2.
  4) Create 1 solution as do_mutate(1) of 4th of top.
  5) Create 1 solution randomly (special for Luckiest people in the world).
4. Go to point 2.
]]

fsl={}      -- Foldit special library
math={}     -- the lua standard library luaopen_math
table={}    -- the lua standard library luaopen_table

-- configuration
mutationRate = 0.1
populationSize = 12
maxGenerations = 50
seed = nil

-- commented out residues not in Foldit (as of Nov 15, 2010)
fsl.aminosLetterIndex=1
fsl.aminosShortIndex=2
fsl.aminosLongIndex=3
fsl.aminosPolarityIndex=4
fsl.aminosAcidityIndex=5
fsl.aminosHydropathyIndex=6
fsl.aminos = {
   {'a','Ala','Alanine',      'nonpolar','neutral',   1.8},
-- {'b','Asx','Asparagine or Aspartic acid' }, 
   {'c','Cys','Cysteine',     'nonpolar','neutral',   2.5},
   {'d','Asp','Aspartic acid',   'polar','negative', -3.5},
   {'e','Glu','Glutamic acid',   'polar','negative', -3.5},
   {'f','Phe','Phenylalanine','nonpolar','neutral',   2.8},
   {'g','Gly','Glycine',      'nonpolar','neutral',  -0.4},
   {'h','His','Histidine',       'polar','neutral',  -3.2},
   {'i','Ile','Isoleucine',   'nonpolar','neutral',   4.5},
-- {'j','Xle','Leucine or Isoleucine' }, 
   {'k','Lys','Lysine',          'polar','positive', -3.9},
   {'l','Leu','Leucine',      'nonpolar','neutral',   3.8},
   {'m','Met','Methionine ',  'nonpolar','neutral',   1.9},
   {'n','Asn','Asparagine',      'polar','neutral',  -3.5},
-- {'o','Pyl','Pyrrolysine' }, 
   {'p','Pro','Proline',     'nonpolar','neutral',   -1.6},
   {'q','Gln','Glutamine',      'polar','neutral',   -3.5},
   {'r','Arg','Arginine',       'polar','positive',  -4.5},
   {'s','Ser','Serine',         'polar','neutral',   -0.8},
   {'t','Thr','Threonine',      'polar','neutral',   -0.7},
-- {'u','Sec','Selenocysteine' }, 
   {'v','Val','Valine',      'nonpolar','neutral',    4.2},
   {'w','Trp','Tryptophan',  'nonpolar','neutral',   -0.9},
-- {'x','Xaa','Unspecified or unknown amino acid' },
   {'y','Tyr','Tyrosine',       'polar','neutral',   -1.3},
-- {'z','Glx','Glutamine or glutamic acid' } 
}

function math.abs(x)
  if x < 0 then
    return -x
  else
    return x
  end
end

function math.floor(x)
  return x - (x%1)
end

function math.min(x,...)
  local min=x
  local args={...}
  for i=1,#args do
    if args[i]<min then
      min=args[i]
    end
  end
  return min
end

function math.max(x,...)
  local max=x
  local args={...}
  for i=1,#args do
    if args[i]>max then
      max=args[i]
    end
  end
  return max
end

math.randLngX = 1000    -- nonstandard variable needed by math.random
math.randLngC = 48313   -- nonstandard variable needed by math.random
function math.random(m,n) 
    local MWC = function()
    local A_Hi = 63551
    local A_Lo = 25354
    local M = 4294967296
    local H = 65536
    local S_Hi = math.floor(math.randLngX / H)
    local S_Lo = math.randLngX - (S_Hi * H)
    local C_Hi = math.floor(math.randLngC / H)
    local C_Lo = math.randLngC - (C_Hi * H)
    local F1 = A_Hi * S_Hi
    local F2 = (A_Hi * S_Lo) + (A_Lo * S_Hi) + C_Hi
    local F3 = (A_Lo * S_Lo) + C_Lo
    local T1 = math.floor(F2 / H)
    local T2 = F2 - (T1 * H)
    math.randLngX = (T2 * H) + F3
    local T3 = math.floor(math.randLngX / M)
    math.randLngX = math.randLngX - (T3 * M)
    math.randLngC = math.floor((F2 / H) + F1)
    return math.randLngX
  end

  if n == nil and m ~= nil then
    n = m
    m = 1
  end
  if (m == nil) and (n == nil) then
    return MWC() / 4294967296
  else
    m, n = math.min(m,n),math.max(m,n)
    return math.floor((MWC() / 4294967296) * (n - m + 1)) + m
  end
end

function math.randomseed(seed)
  if seed == nil then -- use the game score to generate a large number
    math.randLngX=1/((math.abs(get_score(true)%0.0001)*1000)%0.001)
    while math.randLngX < 10000000 do
      math.randLngX = math.randLngX * 10
    end
    math.randLngX = math.floor(math.randLngX) -- is an integer required? 
  else
    math.randLngX = seed
  end
  math.randLngC = 48313  -- restore to original
end

function table.insert(tab,val)
  tab[#tab+1]=val
end

function table.my_sort(x,z,ind)
 local j
 local v
 local vz
 local vi
   comp=function(x,y) return x>y end
 for i = #x-1,1,-1 do
   v=x[i]
   vz=z[i]
   vi=ind[i]
   j=i
   while (j<#x) and (comp(x[j+1],v)) do
     x[j]=x[j+1]
     z[j]=z[j+1]
     ind[j]=ind[j+1]
     j=j+1
   end
   x[j]=v
   z[j]=vz
   ind[j]=vi
 end
end

function tune(tune_type)
  if tune_type == 1 then
    select_all()
    do_shake(1)
    do_global_wiggle_all(10)
    deselect_all()
  end
  if tune_type == 2 then
    select_all()
    do_shake(1)
    deselect_all()
  end
end

function crossover(a, b) 
    local cut = math.random(#a-1)
    local s = {}
    for i=1, cut do
        s[i] = a[i]
    end
    for i=cut+1, #b do
        s[i] = b[i]
    end        
    return s
end

function mutation(bitstring)
    local s = {}
    for i=1, #bitstring do
        if math.random() < mutationRate then    
            s[i] = fsl.aminos[math.random(20)][fsl.aminosLetterIndex]        
        else s[i] = bitstring[i] end
    end
    return s
end

function equal(str1,str2)
    local c=true
    for i=1,#str1 do
        if str1[i]~=str2[i] then c=false end
    end
    return c
end


function try_mutate_2(save)
    quickload(indx[save])
    select_all()
    do_mutate(1)
    do_global_wiggle_all(10)
    strt = {}
    for i=1,#mutable do
        strt[i] = get_aa(mutable[i])
    end
    return strt
end

function reproduce(selected)
    local pop = {}
    pop[1]=selected[1]
    pop[2]=selected[2]
    pop[3]=selected[3]
    pop[4]=crossover(selected[1],selected[2])
    pop[5]=crossover(selected[2],selected[3])
    pop[6]=crossover(selected[1],selected[3])
    pop[7]=crossover(selected[2],selected[1])
    pop[8]=crossover(selected[3],selected[2])
    pop[9]=mutation(selected[1])
    pop[10]=mutation(selected[2])
    pop[11]=try_mutate_2(4)
    pop[12]=random_bitstring(problemSize)
    
    for i=1,#pop-1 do
        for j=i+1,#pop do
            if equal(pop[i],pop[j]) then 
                pop[j]=mutation(pop[j])
            end
        end
    end
    
    return pop
end

function fitness(bitstring)
    local cost = 0
    for i=1, #bitstring do
        if get_aa(mutable[i])~=bitstring[i] then 
        deselect_all()
        select_index(mutable[i])
        replace_aa(bitstring[i])
        end
    end
    tune(1)
    cost = get_score()
    return cost
end

function random_bitstring(length)
    local s = {}
    local i = 1
    while #s < length do
        s[i] = fsl.aminos[math.random(20)][fsl.aminosLetterIndex]
        i=i+1
    end 
    return s
end

function evolve()
    local population = {}
    local bestString = nil
    local outp = ""
    reset_recent_best()
	-- Insert starting sequence as first species
    strt = {}
    for i=1,#mutable do
    strt[i] = get_aa(mutable[i])
    end
    table.insert(population, strt)
	
	-- Add known sequences
	--[[
	strt = {'k','l','v','e','d','h','g','f','e','l','a','l','e','m','d','d','n','r','p','n','k','f','k','e','i','a','k','f','v','k'}
	table.insert(population, strt)
	strt = {'r','l','m','e','d','w','g','f','k','l','a','l','e','r','d','e','n','r','p','n','r','f','k','e','i','a','k','f','v','k'}
	table.insert(population, strt)
	]]
	
    -- initialize the population random pool
    for i=#population+1, populationSize do
        table.insert(population, random_bitstring(problemSize))
    end
    -- optimize the population (fixed duration)
    for i=1, maxGenerations do
        -- evaluate
        fitnesses = {}
        restore_recent_best()
        for i=1,#mutable do
        strt[i] = get_aa(mutable[i])
        end
        table.insert(fitnesses, get_score())
        outp=""
        for z=1,#strt do
            outp = outp .. strt[z]
        end
        print(outp..", "..fitnesses[1])
        quicksave(1)
        for j=2, #population do
            restore_recent_best()
            table.insert(fitnesses, fitness(population[j]))
            quicksave(j)
            -- print population and score
            outp=""
            for z=1,#population[j] do
            outp = outp .. population[j][z]
            end
            print(outp..", "..fitnesses[j])
        end
        
        indx={}
        for j=1,#population do indx[j]=j end
        
        -- Sort population
        table.my_sort(fitnesses,population,indx)
        
        -- Print current population
        print("Generation "..i..". Current population:")
        for i=1,#population do
        outp = i..","..indx[i]..","..fitnesses[i]..","
            for j=1, #population[i] do
            outp = outp .. population[i][j]
            end
        print(outp)
        end

        -- Create new population
        tmpPop = population
        population = reproduce(tmpPop)
    end    
    return population[1]
end

function fsl.FindMutableSegments()
  print("Finding Mutable Segments -- don't kill during this routine")
  quicksave(10)
  local mutable={}
  local isG={}
  local i
  select_all()
  replace_aa('g')                  -- all mutable segments are set to 'g'
  for i=1,get_segment_count() do
    if get_aa(i) == 'g' then        -- find the 'g' segments
      isG[#isG + 1] = i
    end
  end
  replace_aa('q')                  -- all mutable segments are set to 'q'
  for j=1,#isG do
    i=isG[j]
    if get_aa(i) == 'q' then        -- this segment is mutable
      mutable[#mutable + 1] = i
    end
  end
  quickload(10)
  print("Mutables found -- OK to kill if desired")
  return mutable
end

---------------------
-- run

-- turn letter into alternative direct index
for i=1,#fsl.aminos do
  fsl.aminos[fsl.aminos[i][fsl.aminosLetterIndex]] = fsl.aminos[i]
end

mutable=fsl.FindMutableSegments()
problemSize = #mutable

math.randomseed(seed)
best = evolve()
print("Finished!")


----------------------\"\n \"type\" : \"script\"\n \"uses\" : \"0\"\n \"ver\" : \"0.3\"\n}\n"
 "_recipe_29360" : "{\n \"desc\" : \"Generic Aglorythm on Bands. Changed  length of band generating method.\"\n \"hidden\" : \"0\"\n \"mid\" : \"28974\"\n \"mrid\" : \"43111\"\n \"name\" : \"GA Bands 2.5  loss\"\n \"parent\" : \"26864\"\n \"parent_mrid\" : \"36194\"\n \"player_id\" : \"174969\"\n \"script\" : \"--GA Bands by Cartoon Villain 
--modded many times by rav3n_pl

normal=true --set false for Xploration puzzle !!!

--[[
    Beware: Ugly code ahead. And I mean it!
    
    A _primative_ genetic algorithm on bands.

    Run this in the early to mid game, after you have
    a general structure but long before you do your tweaks
    to get the last few fractions of a point.

    A brief overview:

    1) [Optional] Create some bands that you think may help the fold.
       The bands that you create will not be modified.  Note, that the
       bands that you create do not have to be anchored at both ends.

    2) This script will fill in random bands to make a enuf bands so that
       the genetic algorithm can run smoothly.  These bands will be
       anchored and they may be deleted by the script.

    3) The script generates a "herd" of random critters, a critter is a
       subset of all of the bands both user and script generated.

    4) Score how well each critter (band subset) does.

    5) Keep the best critters and kill the rest.

    6) "Breed" the critters you kept by mixing rougly half of the bands
       from the "mom" with half of the bands from the "dad" critter. Do
       this until you have filled the herd back up.

    7) Some critters are mutated during breeding. A mutation is
       the replacement of one of the critter's bands with another
       randomly chosen band.

    8) If the scores aren't going anywhere after a few generations
       start over with a new herd and a new set of script generated
       bands, step 2.

    9) Repeat from the scoring step (4) until the max generation is
       reached or we can't lock the script generated bands.

    This is a greedy GA, we keep score increases as soon as they occur.
    If it's half way thru scoring a generation then so be it. This is why
    we use relative improvements as a critter score.
--]]

segCnt=get_segment_count()
p=print
CI=set_behavior_clash_importance

function round(x)--cut all afer 3-rd place
    return x-x%0.001
end
function down(x)
    return x-x%1
end

function Score()--return score, exploration too
    local s=0
    if normal==true then
        s=get_score(true)
    else
        s=get_ranked_score(true)
    end
    return s
end 

function Wiggle(how, iters, minppi)
    if how==nil then how="wa" end
    if iters==nil then iters=6 end
    if minppi==nil then minppi=0.1 end
    
    if iters>0 then
        iters=iters-1
        sp=Score()
        if how == "s" then do_shake(1)
            elseif how == "wb" then do_global_wiggle_backbone(2)
            elseif how == "ws" then do_global_wiggle_sidechains(2)
            elseif how == "wa" then do_global_wiggle_all(2) 
        end
        ep = Score()
        ig=ep-sp
        if how~="s" then
            if ig > minppi then return Wiggle(how, iters, minppi) end --tail call
        end
    end
end
function AllLoop() --turning entire structure to loops
    local ok=false
    for i=1, segCnt do
        local s=get_ss(i)
        if s~="L" then 
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

--[[
Tlaloc`s math library
------------------------------------------------------------------------
The original random script this was ported from has the following notices:
Copyright (c) 2007 Richard L. Mueller
Hilltop Lab web site - http://www.rlmueller.net
Version 1.0 - January 2, 2007
You have a royalty-free right to use, modify, reproduce, and
distribute this script file in any way you find useful, provided that
you agree that the copyright owner above has no warranty, obligations,
or liability for such use.
------------------------------------------------------------------------
]]--
local lngX = 1000
local lngC = 48313

local function _random(m,n)
    local A_Hi = 63551
    local A_Lo = 25354
    local M = 4294967296
    local H = 65536
    
    function _MWC()
        local S_Hi = math.floor(lngX / H)
        local S_Lo = lngX - (S_Hi * H)
        local C_Hi = math.floor(lngC / H)
        local F1 = A_Hi * S_Hi
        local F2 = (A_Hi * S_Lo) + (A_Lo * S_Hi) + C_Hi
     
        lngX = ((F2 - (math.floor(F2 / H) * H)) * H) + (A_Lo * S_Lo) + lngC - (C_Hi * H)
        lngX = lngX - (math.floor(lngX / M) * M)
        lngC = math.floor((F2 / H) + F1)

        return lngX
    end
    
    if n == nil and m ~= nil then
        n = m
        m = 1
    end
    if (m == nil) and (n == nil) then
        return _MWC() / M
    else
        if n < m then
            return nil
        end
        return math.floor((_MWC() / M) * (n - m + 1)) + m
    end
end

local function _abs(value)
    if value < 0 then
        return -value
    else
        return value
    end
end

local function _floor(value)
    return value - (value % 1)
end

local function _randomseed(s)
    if s==nil then 
        s=math.abs(Score())
        s=s%0.001
        s=1/s
        while s<10000 do s=s*1000 end
        s=s-s%1
    end
    lngX = s
end

math=
{
    abs = _abs,
    floor = _floor,
    random = _random,
    randomseed = _randomseed,
}
math.randomseed()
--[[ End math library ]]--

function CanBeUsed(sg1,sg2) --checking end of bands
    local ok=true
    if #DoNotUse>0 then --none of 2 can be in that area
        for i=1, #DoNotUse do
            local r=DoNotUse[i]
            for x=r[1],r[2] do
                if x==sg1 or x==sg2 then
                    ok=false
                    break
                end
            end
            if ok==false then break end
        end
    end
    if ok==false then 
        return false --if false can`t be used
    else
        ok=false
        if #AlwaysUse>0 then --at least one have to be there
            for i=1, #AlwaysUse do
                local r=AlwaysUse[i]
                for x=r[1],r[2] do
                    if x==sg1 or x==sg2 then
                        ok=true
                        break
                    end
                end
                if ok==true then break end
            end
        else
            ok=true
        end
        return ok --if true can be used
    end    
end

bestScore=Score()
function SaveBest()
    local g=Score()-bestScore
    if g>0 then
        if g>0.1 then p("Gained another ",round(g)," pts.") end
        bestScore=Score()
        quicksave(3)
    end
end
function SaveRB()
    if normal==false then return end --not in exploration
    quicksave(4)
    restore_recent_best()
    SaveBest()
    quickload(4)
end

function qStab()
    select_all()
    CI(0.1)
    Wiggle("s",1)
    if fastQstab==false then 
        CI(0.4)
        Wiggle("wa",1)
        CI(1)
        Wiggle("s",1)
    end
    CI(1)
    Wiggle()
end

function FuzeEnd()
    CI(1)
    Wiggle("wa",1)
    Wiggle("s",1)
    Wiggle()
    SaveBest()
end
function Fuze1(ci1,ci2)
    CI(ci1)
    Wiggle("s",1)
    CI(ci2)
    Wiggle("wa",1)
end
function Fuze2(ci1,ci2)
    CI(ci1)
    Wiggle("wa",1)
    CI(1)
    Wiggle("wa",1)
    CI(ci2)
    Wiggle("wa",1)
end
function reFuze(scr)
    local s=Score()
    if s<scr then 
        quickload(4)
    else
        scr=s
        quicksave(4)
    end
    return scr
end
function Fuze()
    local scr=Score()
    quicksave(4)
    select_all()
    Fuze1(0.3,0.6) FuzeEnd()
    scr=reFuze(scr)
    Fuze2(0.3,1) SaveBest()
    scr=reFuze(scr)
    Fuze1(0.05,1) SaveBest()
    scr=reFuze(scr)
    Fuze2(0.7,0.5) FuzeEnd()
    scr=reFuze(scr)
    Fuze1(0.07,1) SaveBest()
    reFuze(scr)
end

-- Per critter parameters
Critter = {
    idCounter = 0, -- Used to generate critter IDs
    minBands  = 3, -- Min number of bands
    maxBands  = 5, -- Max number of bands
    startScore=0, --starting score of critter (rav3n)
}

-- Parameters dealing with the herd
Herd = {
    keep           = 3,  -- This many survive to next generation
    breed          = 3,  -- Breed this many replacements
    generation     = 1,  -- What generation is this
    maxGeneration  = 20, -- Quit after this many generations
    improvementWas = 0,  -- How good did the last generation do
    scoreBefore    = 0,  -- Score at the start of a generation
    rebootLimit    = 2,  -- Reboot after this many 0 improvement generations
    rebootCount    = 0,  -- How close are we to the reboot limit
    mutateRate     = 4,  -- On average mutate 1 out this many new borns
    rebootScore    = 0.1, -- Only increment reboot count when below this
    startingScore  = Score(), -- Score at the start of the script
}
Herd.size = Herd.keep + Herd.breed

-- Parameters dealing with bands
Band = {
    userMade    = get_band_count(), -- How many bands did user enter
    maxLength   = 5, --max difference between position of segments and mand length
    minStrength = 0.1,
    maxStrength = 1,
    locked      = false, -- Were we able to lock the script generated bands
}

-- How many random bands to make
Band.scriptMade = (Herd.size * Critter.maxBands) - Band.userMade
if Band.scriptMade<0 then Band.scriptMade=1 end --if user made soooo many bands

-- A random float between [0, 1)
function RandomFloat()
    return math.random()
end

 -- A random int between [1, high]
function RandomInt(high)
    return math.random(high)
end

-- Generate a random band
function CreateBand()
    local start  = RandomInt(segCnt)
    local finish = RandomInt(segCnt)
    if  start~=finish and --not make band to same place
        math.abs(start-finish)>= minDist and --do not band if too close
        CanBeUsed(start,finish) --at least one need to be in place
    then
        band_add_segment_segment(start, finish)
        local range    = Band.maxStrength - Band.minStrength
        local strength = (RandomFloat() * range) + Band.minStrength
        local n = get_band_count()
        if n > 0 then band_set_strength(n, strength) end
        
        local length = get_segment_distance(start,finish)  -- +-2-maxLenght form curent segments distance
        local rn=0
        while true do
            rn=RandomFloat()*Band.maxLength*2-Band.maxLength
            if rn<=-3 or rn >=3 then break end
        end
        length=length+rn
        --3+ (RandomFloat() * (Band.maxLength-3)) --min len is 3
        --p(rn, " ",length) --debug
        if compressor then
            length = get_segment_distance(start,finish)-compressFrac --compressing
        else
            if push then
                local dist = get_segment_distance(start,finish)
                if dist >2 then length=dist*1.5 end
            end
            
            if hydroPull then
                if is_hydrophobic(start) and is_hydrophobic(finish)  then 
                    length=3 --always pull hydrophobic pair
                end
            end
        end
        --if length >20 then length=20 end
        if length <0 then length=0 end
        if n > 0 then band_set_length(n, length) end                
    else
        CreateBand()
    end
end

function CreateBands()
    local i
    p("Creating bands...")
    for i = 1, Band.scriptMade do
        CreateBand()
    end
end

function DeleteScriptMadeBands()
    if Band.userMade==0 then 
        band_delete() --if no user bands del them all
    else 
        local b
        for b = get_band_count(), Band.userMade + 1, -1 do
            band_delete(b)
        end
    end
end

function DisableAllBands()
    band_disable()
end

function EnableCritterBands(critter)
    local b
    for b = 1, critter.bands do
        band_enable(critter.band[b])
    end
end

-- Default critter constructor
function NewCritter()
    Critter.idCounter = Critter.idCounter + 1
    local critter = { bands = 0, score = -999999, age = 0, mutated = false, startScore = 0, }
    critter.id = Herd.generation .. "_" .. Critter.idCounter
    critter.band = {}
    return critter
end

-- Constructor for generating a completely random critter
function RandomCritter()
    local i
    local critter = NewCritter()
    critter.mutated = true
    critter.id = critter.id .. "r"
    critter.bands = RandomInt(Critter.maxBands - Critter.minBands)
                  + Critter.minBands
    local max = get_band_count()
    for i = 1, critter.bands do
        critter.band[i] = RandomInt(max)
    end

    return critter
end

-- Lock in the script generated bands so that they will
-- appear when we do a restore_abs_best()
-- I would love to replace this with a slotted recent best
function LockBands()
    CI(1)
    if Band.scriptMade <= 0 then
        Band.locked = true
        return
    end
    reset_recent_best() --save bands
    Band.locked = true
    quicksave(3) --to be 200% sure
    p("Bands locked")
end

-- Generate a random heard. This includes all new critters,
-- and a new set of script generated bands
function RandomHerd()
    local i
    DeleteScriptMadeBands()
    
    if Herd.generation>1 and randomOptions then --randomize push/pull
        local r=RandomInt(10)
        if r%2==0 then compressor=true p("Compressing.") else compressor=false end
        if compressor==false then
            local r=RandomInt(10)
            if r%2==0 then push=true p("Pushing.") else push=false end
            r=RandomInt(10)
            if r%2==0 then hydroPull=true p("Pulling hydros.") else hydroPull=false end
        end
    end
    
    CreateBands()
    DisableAllBands()
    LockBands()
    for i = 1, Herd.size do
        Herd[i] = RandomCritter()
        p("randomize: ", Herd[i].id)
    end
    
end

function ScoreHerd()
    local i
    local first = 1 
    local hs=Score()
    for i = 1, Herd.size do
        quicksave(5) --restore it if to much loss
        local label   = "  unchanged score: "
        local critter = Herd[i]
        
        if critter.startScore == Score() then
            first=first+1
        end
        
        if i >= first or critter.mutated then
            label = "  score: "
            local startingScore = Score()
            critter.startScore = startingScore
            
            DisableAllBands()
            EnableCritterBands(critter)
            select_all()
            local pullS=Score()
            CI(wiggleCI)
            do_global_wiggle_backbone(1)
            CI(1)
            DisableAllBands()
            SaveRB() --sometimes it wotks ;]
            if useQstab then
                if math.abs(Score()-pullS)>doQstab then
                    qStab()
                else 
                    Wiggle() 
                end
                
                if Score()>bestScore-doFuze and useFuze==true then
                    Fuze()
                end
            else
                Fuze() --run it when not using qStab
            end
            
            SaveBest() --if not use any fuze or so.
            
            critter.score = Score() - startingScore
            
            if critter.score<= 0.001 and critter.score>-0.1 then 
                critter.score=-999 --no change, we not need it
            end
            
            if loss==true then
                if critter.score<0-maxLoss then 
                    quickload(5) --too negative score
                end 
            else --next critter from best state
                quickload(3)
            end
        end

        critter.age = critter.age + 1
        critter.mutated = false
        p("critter: ", critter.id, label, round(critter.score))
    end
    quickload(3)
    if mutate and Score()-hs>1 then--if more than 1pt change
        select_all()
        CI(mutateCI)
        do_mutate(1)
        CI(1)
        qStab()
    end
end

function SwapCritter(a, b)
    Herd[a],Herd[b]=Herd[b],Herd[a]--yes! in LUA you can do that!
end

-- A quasi sort function. Only sort what is kept.
-- A small N means that I'm OK with this being a quadratic sort
function CullHerd()
    local weakest = 1 -- Survivor with the lowest score
    local i, j

    for i = 2, Herd.size do
        if Herd[i].score > Herd[weakest].score then
            SwapCritter(i, weakest)
            j = weakest
            while j > 1 and Herd[j].score > Herd[j-1].score do
                SwapCritter(j, j-1)
                j = j - 1
            end
        end
        weakest = weakest + 1
        if weakest > Herd.keep then weakest = Herd.keep end
    end

    for i = 1, Herd.keep do
        p("kept: ", Herd[i].id, "  score: ", round(Herd[i].score))
    end
end

-- Mix bands from the mom and dad critter, rougly half from each
function BreedPair(mom, dad)
    local kid = NewCritter()
    local k, i, b = 0, 0, 0

    -- Choose bands from the mom
    b = RandomInt(mom.bands)
    for i = 1, (mom.bands / 2) + 0.5 do
        k = k + 1
        kid.band[k] = mom.band[b]

        b = b + 1
        if b > mom.bands then b = 1 end
    end

    -- Choose bands from the dad
    b = RandomInt(dad.bands)
    for i = 1, dad.bands / 2 do
        k = k + 1
        kid.band[k] = dad.band[b]

        b = b + 1
        if b > dad.bands then b = 1 end
    end

    kid.bands = k
    return kid
end

-- Breed survivors with each other
-- 1st breeds w/ 2nd and 2nd w/ 3rd etc.
-- When that's done 1st breeds w/ 3rd and so on.
function BreedHerd()
    local mom, dad, kid = 0, 0, 0
    local step = 0 -- Dad is this far away from mom +1
    local keep = Herd.keep

    for kid = keep + 1, Herd.size do
        mom = mom + 1
        if mom > keep then
            mom = 1
            step = step + 1
        end
        dad = ((mom + step) % keep) + 1
        Herd[kid] = BreedPair(Herd[mom], Herd[dad])
        p("breeding:  mom: ", Herd[mom].id,
                       "  dad: ", Herd[dad].id,
                       "  kid: ", Herd[kid].id)
    end
end

-- Mutate a random selection of the new born critters. A mutation
-- is the replacement of one of the critter's randomly chosen bands
-- with another band randomly choosen from the entire band set.
function MutateHerd()
    local i, zap, new, mutate, max
    max = get_band_count()
    for i = Herd.keep + 1, Herd.size do
        mutate = RandomInt(Herd.mutateRate)
        if mutate == 1 then
            zap = RandomInt(Herd[i].bands)
            new = RandomInt(max)
            Herd[i].band[zap] = new
            Herd[i].mutated   = true
            Herd[i].id        = Herd[i].id .. "m"
            p("Mutating: ", Herd[i].id, "  zapped: ", zap)
        end
    end
end

function ga()
    Herd.size = Herd.keep + Herd.breed
    Band.scriptMade = (Herd.size * Critter.maxBands) - Band.userMade
    if Band.scriptMade<0 then Band.scriptMade=1 end --if user made soooo many bands
    
    p("Starting GA Bands v2.1 ...") 
    if normal==false then p("Using exploration puzzle settings.") end
    if allLoop then AllLoop() end
    quicksave(3)
    select_all()
    RandomHerd()

    while Band.locked and Herd.generation <= Herd.maxGeneration do
        p("")
        p("generation: ", Herd.generation," of ",Herd.maxGeneration, " Start score: ",round(Score()))

        if Herd.rebootCount >= Herd.rebootLimit then
            RandomHerd()
            Herd.rebootCount = 0
        end
        Herd.generation = Herd.generation + 1

        Herd.scoreBefore = Score()

        ScoreHerd()
        CullHerd()
        BreedHerd()
        MutateHerd()

        Herd.improvementWas = Score() - Herd.scoreBefore
        p("score: ",             round(Score()))
        p("improvement: ",       round(Herd.improvementWas))
        p("total improvement: ", round(Score() - Herd.startingScore))

        if Herd.improvementWas < Herd.rebootScore then
            Herd.rebootCount = Herd.rebootCount + 1
        else
            Herd.rebootCount = 0
        end
        p("reboot count: ", Herd.rebootCount, "  limit: ", Herd.rebootLimit)
        quickload(3) --every herd load best state
    end

    DeleteScriptMadeBands()
    quickload(3)--load best state
    if allLoop then load_structure() end
    LockBands()
end

-- V V V V V editable options below V V V V V
-- option to use normal or exploration puzze is ON TOP OF SCRIPT!

DoNotUse={--just comment lines below or add more areas to avoid
--{segCnt,segCnt}, --ligand cant be used
--{120,134},
--{1,10},
}
AlwaysUse={ --areas should be always used
--{segCnt,segCnt},--ligand need to be at one end
--{308,311}, --loopy
--{313,317}, --loopy
}

Herd.keep = 3  -- This many survive to next generation
Herd.breed = 6  -- Breed this many replacements
--3+6=9 critters in herd

Critter.minBands  = 4 -- Min number of bands
Critter.maxBands  = 7 -- Max number of bands    
    
Band.minStrength=0.3 --minimum band STR
Band.maxStrength=1.1 --maximum band STR
Band.maxLength = 7 --maximum distance of push/pull (min is 2)
minDist=down(segCnt/10)  --minimum dist (in segments) between banded segments

mutate=false --true --do mutate(1) + qstab each generation
mutateCI=0.1 --clash importance during mutate

useQstab=true --quick stabilize to see that fuze have any chance 
              --if false one (or both) of fuze/s are runned anyway
doQstab=10 --run qstab only if loss is more than that. othwewise only wiggle
fastQstab=true --false --if true only 1 shake and 1 wiggle as qstab

useFuze=true --run Fuze when condition below met or not using qstab
doFuze=-1 --how close to best score after stabilize to run PF

--options below are valid only until reboot. it might change every reboot.
compressor=false --true --making all bands shorter to compress protein OVERRIDES PUSH AND PULL!
compressFrac=4 --shorten by that much. looks like 4 is good value
push=false --always push when possible (hydros may be excluded)
hydroPull=false --always pul hydrophobic pair
randomOptions=false --true --randomizing push/pull/compressor options every reboot

allLoop=false --run in all-loop mode (sometimes works better!)

wiggleCI=0.9 --clash impotrance during push/pull
loss=true --false --true --do not reload best score between critters in herd if true
maxLoss=30 --maximum loss by criter, reloading last "good" herd position- not best total!

Herd.maxGeneration  = 200 --how many generations. More=longer run
Herd.rebootLimit = 2 --how many gens w/o improvement to random new bands 1-random after 1st bad one

--- end of options -------^^^

--main call
ga()


--[[
Genetic Bands III by Crashguard303

Inspired by cartoon Villain's Script, I created this one, including freezing.
This script also works on not-very-best puzzle-states.

DESCRIPTION for default parameters:

Random Creating:
 It creates a set of clusters (herd). Each cluster has a random set of bands,freezes and a drift value.
 There is a random list, which segments have already been banded or frozen, so it is guaranteed that all are tried.
 If all have been tried, this list is shuffled, all segments are tried again.
 The drift shows, in which directions banding or freezing segments can move.
 (-1 will increase current segment number by, +1 will increase segment number by 1, 0 won't exist)

Then, for this puzzle state, all clusters are tried.
This means:

Pulling:
 Bands and freezes are applied (plus constant bands, if you want), the puzzle is wiggled for one iteration.

Releasing:
 Bands and freezes are removed.
 4 different subroutines similar to blue fuse run.
 They test different clashing-importance shake/wiggle combinations.
The best result of the fuse is stored to the cluster score.

Sorting:
 If all clusters were tried, they are sorted by the scores they created, double score results are moved to the end of the list.
 The best cluster is on top, the worst or and equal cluster is on bottom at the list.

Breeding:
 All clusters from BreedFirst to BreedLast are breeded, first best  with other random clusters, preferring good ones
 The cluster with the most bands is mom, cluster with fewer bands is dad.
 Bands of mom and drift value are copied at first,
 then a random crossover point is generated within the length of dad's bands.
 Bands from 1 to inclusive crossover point from the new cluster are replaced by bands of dad, rest of mom
 The same happens to freezes.

Mutating:
 For each band or freeze:
  A random flag (Drift flag or multiplicator) (either 0 or 1)  is created, depending on mutation probability.
  If this flag is 1, drift value (-1 or +1) is added to the segment index, in other case, the segment index stays the same.
  Band length and strength are randomly changed between an amount of -0.1 to 0.1
  When mutating, all values are checked after they are changed, to guarantee that they don't leave a legal value range.

Inverting:
 For each band or freeze:
  A random flag (inversion flag) (either o or 1) is created, depending on inverting probability.
  If this flag is 1, segment values are inverted, which means multiplying them by -1
  Negative segment values results banding or freezing skip, they are deactivated.
  If a segment has a negative value and is inverted, the value is positive and activated again

Filling:
 The rest of the herd (BreedLast+1 to HerdSize) is replaced by new random clusters, as described in Random Creating.

Restart:
  When new clusters have been breeded or replaced, the recent best puzzle state is loaded.
  and pulling is performed again.

END OF MAIN DESCRIPTION
P.S.: If you find typos, you can keep them ;)
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

function abs(x)
 local y=x
 if y<0 then y=-y end
 return y
end -- function

function floor(value)
    return value - (value % 1)
end

function getseed()
    local score = abs(get_score(true))
    if score == 0 then
        quicksave(9)
        do_global_wiggle_all(1)
        score = abs(get_score(true))
        quickload(9)
    end
    local fraction = (score - floor(score)) * 1000
    local least = fraction - floor(fraction)
    local seed = floor(least * 100000)+floor(RNDoffset)
    print("Random seed is: ",seed)
    return seed
end

-- lngX = 1000 -- Don't needed, as we use getseed
lngC = 48313

function MWC()

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

function frandom(m,n,e)
 -- float random, e is number of remainin decimal digits
 local e2=10^e
 return random(m*e2,n*e2)/e2
end -- function

function sgn(x)
 -- Signum function

 if x==nil then
   return nil
  elseif x>0 then
   return 1
  elseif x<-0 then
   return -1
  else
   return x
 end -- if
end -- function

function CutOff(x,y)
 -- Keep only y digits after decimal point from x
 return floor(x*10^y)/10^y
end -- function

BoolString={}
BoolString[true]="In"
BoolString[false]="Ex"

function UseSegIRange(UseList,A,B,StepSize,bool)
 -- In table "UseList", append or remove segment range A to B
 local UseList=UseList
 local A=A -- range start
 local B=B -- range end
 if A>B then A,B=B,A end -- Swap range start and end, if values are not okay
 local StepSize=StepSize
 local bool=bool -- True=append, false=remove

 local k=A
 repeat
  UseList=UseList_AR(UseList,k,bool)
  k=k+StepSize -- increase k by StepSize
 until k>B -- until k exceeds B
 return UseList
end -- function

function UseSegIValues(UseList,field,bool)
 -- In table "UseList", append or remove segments listed in table "field"
 local UseList=UseList
 local field=field  -- table to add
 local bool=bool -- True=append, false=remove

 local k
 if #field>0 then -- If table to add is not empty
   for k=1,#field do -- cycle through all elements from table
    UseList=UseList_AR(UseList,field[k],bool)
   end -- k loop
 end -- if #field
 return UseList
end -- function

function Use_ss(UseList,SSLetter,bool)
 -- In table "UseList", append or remove segments with secondary structure "SSLetter"
 local UseList=UseList
 local SSLetter=SSLetter
 local bool=bool -- True=append, false=remove

 local k
 for k=1,NumSegs do -- Cycle through all segment indices
  if get_ss(k)==SSLetter then -- If current segment index has same ss as given
    UseList=UseList_AR(UseList,k,bool)
  end -- if get_ss
 end -- k loop
 return UseList
end -- function

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

function UseList_AR(UseList,value,bool)
 -- Append value "value" to UseList
 -- or remove all value's out of UseList, depending on bool
 local UseList=UseList
 local value=value
 local bool=bool -- True=append, false=remove
 -- print(BoolString[bool],"cluding segment index ",value)
   if bool==true then
      UseList=UseList_Append(UseList,value)
    else
      UseList=UseList_Remove(UseList,value)
    end -- if bool
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

function CheckUselist(UseList)
 -- If there are fewer than 3 specific segments to work on given, take all
 local UseList=UseList
 if #UseList<=3 then
  print("No or too few specific segments to work on given.")
  print("Banding and freezing will now manipulate all puzzle segments.")
  UseList={}
  local k
  for k=1,NumSegs do -- Cycle through all segments
   UseList[#UseList+1]=k -- extend UseList by 1 and add segment index
  end -- k loop
 end -- if UseList
 print("Segment list is now:")
 local OS="" -- Initialize output string
 local E=0 -- Initialize element counter
 local k
 for k=1,#UseList do
   OS,E=CompactContent(OS,E,UseList[k])
 end -- k
 if E>0 then
  print(OS)
 end
 return UseList
end -- function

function shuffle2(ShuffleProb)
 -- Scrambles segment use list depending on ShuffleProb
 print("Shuffling segment list")

 kend=#UseList-1
 local k
 for k=1,kend do -- Cycle through all UseList entries
  if random()<ShuffleProb then -- If random value<probability
  -- same as: if random_flag(ShuffleProb)==1 then
   local l=random(k+1,#UseList) -- pick random list entry behind k
   UseList[k],UseList[l]=UseList[l],UseList[k] -- swap values of UseList index k with UseList index l
  end -- if random
 end -- k loop
 UsedSegments=0 -- After Shuffling, set list pointer to 0
end

function random_segment()
 -- Gets a random segment index out of UseList which has not been used so far

 UsedSegments=UsedSegments+1 -- Increase UseList pointer
 local Seg_result=UseList[UsedSegments] -- fetch segment index
 if UsedSegments==#UseList then shuffle2(ShuffleProb) end
 -- If this was the last value of UseList, shuffle list and reset pointer

 return Seg_result -- return random segment number
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