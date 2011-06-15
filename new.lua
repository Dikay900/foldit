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






--end of script\"\n \"type\" : \"script\"\n \"uses\" : \"9\"\n \"ver\" : \"0.3\"\n}\n"
