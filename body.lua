--[[
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions goes to Rav3n_pl, Tlaloc and Gary Forbis
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
Version     = "1"
Release     = false          -- if true this script is relatively safe ;)
numsegs     = get_segment_count()
--Game vars#

--#Settings: default
--#                  default     description
--Settings#

--#Constants
saveSlots       = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
fuzing          = false
--Constants#

--#Securing for changes that will be made at Fold.it
assert          = nil
error           = nil
debug           = nil
math            = nil
--Securing#

--#Optimizing
p               = print
--Optimizing#

--#Debug
local function _assert(b, m)
    if not b then
        p(m)
        error()
    end -- if
end -- function

local function _score()
    local s = 0
    if b_explore then
        for i = 1, numsegs do
            s = s + get_segment_score(i)
        end -- for
    else -- if
        s = get_score(true)
    end -- if
    return s
end -- function

debug =
{   assert  = _assert,
    score   = _score
}
--Debug#

--#External functions
--#Math library
--[[
The original random script this was ported from has the following notices:
Copyright (c) 2007 Richard L. Mueller
Hilltop Lab web site - http://www.rlmueller.net
Version 1.0 - January 2, 2007
You have a royalty-free right to use, modify, reproduce, and distribute this script file in any
way you find useful, provided that you agree that the copyright owner above has no warranty,
obligations, or liability for such use.
This function is not covered by the Creative Commons license given at the start of the script,
and is instead covered by the comment given here.
]]
lngX = 1000
lngC = 48313
local function _MWC()
    local A_Hi = 63551
    local A_Lo = 25354
    local M = 4294967296
    local H = 65536
    local S_Hi = math.floor(lngX / H)
    local S_Lo = lngX - (S_Hi * H)
    local C_Hi = math.floor(lngC / H)
    local C_Lo = lngC - (C_Hi * H)
    local F1 = A_Hi * S_Hi
    local F2 = (A_Hi * S_Lo) + (A_Lo * S_Hi) + C_Hi
    local F3 = (A_Lo * S_Lo) + C_Lo
    local T1 = math.floor(F2 / H)
    local T2 = F2 - (T1 * H)
    lngX = (T2 * H) + F3
    local T3 = math.floor(lngX / M)
    lngX = lngX - (T3 * M)
    lngC = math.floor((F2 / H) + F1)
    return lngX
end -- function

local function _floor(value)
    return value - (value % 1)
end -- function

local function _randomseed(x)
    lngX = x
end -- function

local function _random(m,n)
    if not n and m then
        n = m
        m = 1
    end -- if n
    if not m and not n then
        return _MWC() / 4294967296
    else -- if m
        if n < m then
            return nil
        end -- n < m
        return math.floor((_MWC() / 4294967296) * (n - m + 1)) + m
    end -- if m
end -- function

local function _abs(x)
    if x < 0 then
        return -x
    else -- if
        return x
    end -- if
end -- function

math =
{   floor       = _floor,
    random      = _random,
    randomseed  = _randomseed,
    abs         = _abs
}
--Math library#

--#Getters
local function _dists(seg)
    distances = {}
    local _start
    if seg then
        _start = seg
    else
        _start = 1
    end
    for i = _start, numsegs - 1 do
        distances[i] = {}
        for j = i + 1, numsegs do
            distances[i][j] = get_segment_distance(i, j)
        end -- for j
    end -- for i
end

local function _sphere(seg, radius)
    sphere = {}
    get.dists(seg)
    for i = 1, numsegs do
        if distances[seg][i] <= radius then
            sphere[#sphere + 1] = i
        end -- if get_
    end -- for i
    return sphere
end -- function

local function _center() -- by Rav3n_pl based on Tlaloc`s
    local minDistance = 100000.0
    local distance
    local indexCenter
    get.dists()
    for i = 1, numsegs do
        distance = 0
        for j = 1, numsegs do
            if i ~= j then
                local x = i
                local y = j
                if x > y then x, y = y, x end
                distance = distance + distances[x][y]
            end -- if i ~= j
        end -- for j
        if distance < minDistance then
            minDistance = distance
            indexCenter =  i
        end -- if distance
    end -- for i
    return indexCenter
end -- function

get =
{   dists   = _dists,
    sphere  = _sphere,
    center  = _center
}
--Getters#

--#Saveslot manager
local function _release(slot)
    saveSlots[#saveSlots + 1] = slot
end -- function

local function _request()
    debug.assert(#saveSlots > 0, "Out of save slots")
    local saveSlot = saveSlots[#saveSlots]
    saveSlots[#saveSlots] = nil
    return saveSlot
end -- function

sl =
{   release = _release,
    request = _request
}
--Saveslot manager#
--External functions#

--#Internal functions
--#Checks
--#Hydrocheck
local function _hydro()
    hydro = {}
    for i = 1, numsegs do
        hydro[i] = is_hydrophobic(i)
    end -- for i
end -- function
--Hydrocheck#

--#Ligand Check
local function _ligand()
    if get_ss(numsegs) == 'M' then
        numsegs = numsegs - 1
    end -- if get_ss
end -- function
--Ligand Check#

--#Structurecheck
--#Getting SS
local function _ss()
    ss = {}
    for i = 1, numsegs do
        ss[i] = get_ss(i)
    end -- for i
end -- function
--Getting SS#

--#Getting AA
local function _aa()
    aa = {}
    for i = 1, numsegs do
        aa[i] = get_aa(i)
    end -- for i
end -- function
--Getting AA#

local function _struct()
    check.ss()
    local helix
    local sheet
    local loop
    he = {}
    sh = {}
    lo = {}
    for i = 1, numsegs do
        if ss[i] == "H" and not helix then
            helix = true
            sheet = false
            loop = false
            he[#he + 1] = {}
        elseif ss[i] == "E" and not sheet then
            sheet = true
            loop = false
            helix = false
            sh[#sh + 1] = {}
        elseif ss[i] == "L" and not loop then
            loop = true
            helix = false
            sheet = false
            lo[#lo + 1] = {}
        end -- if ss
        if helix then
            if ss[i] == "H" then
                he[#he][#he[#he]+1] = i
            else -- if ss
                helix = false
            end -- if ss
        end -- if helix
        if sheet then
            if ss[i] == "E" then
                sh[#sh][#sh[#sh]+1] = i
            else -- if ss
                sheet = false
            end -- if ss
        end -- if sheet
        if loop then
            if ss[i] == "L" then
                lo[#lo][#lo[#lo]+1] = i
            else -- if ss
                loop = false
            end -- if ss
        end -- if loop
    end -- for
end -- function
--Structurecheck#

--#Fuzing
local function _loss(option, cl1, cl2)
    p("Fuzing Method ", option)
    p("cl1 ", cl1, ", cl2 ", cl2)
    if option == 3 then
        p("Pink Fuse cl1-s-cl2-wa")
        work.step("s", 1, cl1)
        work.step("wa", 1, cl2)
    elseif option == 4 then
        p("Pink Fuse cl1-wa-cl=1-wa-cl2-wa")
        work.step("wa", 1, cl1)
        work.step("wa", 1, 1)
        work.step("wa", 1, cl2)
    elseif option == 2 then
        p("Blue Fuse cl1-s; cl2-s;")
        work.step("s", 1, cl1)
        work.gain("wa", 1)
        local bf1 = get_score()
        reset_recent_best()
        work.step("s", 1, cl2)
        work.gain("wa", 1)
        local bf2 = get_score()
        if bf2 < bf1 then
            restore_recent_best()
        end -- if
        reset_recent_best()
        bf1 = get_score()
        work.step("s", 1, cl1 - 0.02)
        work.gain("wa", 1)
        bf2 = get_score()
        if bf2 < bf1 then
            restore_recent_best()
        end -- if
    elseif option == 5 then
        p("cl1-wa[-cl2-wa]")
        work.step("wa", 1, cl1)
    elseif option == 1 then
        local qs1 = get_score()
        reset_recent_best()
        p("qStab cl1-s-cl2-wa-cl=1-s")
        work.step("s", 1, cl1)
        work.step("wa", 1, cl2)
        work.step("s", 1, 1)
        work.gain("wa", 1)
        local qs2 = get_score()
        if qs2 < qs1 then
            restore_recent_best()
        else -- if
            fuze.loss(1, cl1, cl2)
        end -- if
    end -- if option
end -- function

local function _part(option, cl1, cl2)
    local s1_f = debug.score()
    fuze.loss(option, cl1, cl2)
    if option ~= 2 or option ~= 1 then
        work.gain("wa", 1)
    end -- if
    local s2_f = debug.score()
    if s2_f > s1_f then
        quicksave(sl_f1)
        p("+", s2_f - s1_f, "+")
    end -- if
    quickload(sl_f1)
end -- function

local function _start(slot)
    fuzing = true
    select_all()
    sl_f1 = sl.request()
    quicksave(sl_f1)
    fuze.part(1, 0.1, 0.4)
    fuze.part(2, 0.05, 0.07)
    fuze.part(3, 0.1, 0.7)
    fuze.part(3, 0.3, 0.6)
    fuze.part(4, 0.5, 0.7)
    fuze.part(4, 0.7, 0.5)
    fuze.part(5, 0.3)
    quickload(sl_f1)
    s_f = debug.score()
    sl.release(sl_f1)
    fuzing = false
    if s_f > c_s then
        quicksave(slot)
        s_fg = s_f - c_s
        p("+", s_fg, "+")
        c_s = s_f
        p("++", c_s, "++")
        if b_f_deep and s_fg > gain then
            fuze.again(slot)
        end -- if deep
    else -- if s_f
        quickload(slot)
    end -- if s_f
end -- function

local function _again(slot)
    fuze.start(slot)
end - function

fuze =
{   loss    =   _loss,
    part    =   _part,
    start   =   _start,
    again   =   _again
}
--Fuzing#

--#Universal select
local function _segs(sphered, start, _end, more)
    if not more then
        deselect_all()
    end -- if more
    if start then
        if sphered then
            if start ~= _end then
                local list1 = get.sphere(_end, 14)
                select.list(list1)
            end -- if ~= end
            local list1 = get.sphere(start, 14)
            select.list(list1)
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end -- if > end
            select_index_range(start, _end)
        elseif start ~= _end then
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end -- if > end
            select_index_range(start, _end)
        else -- if sphered
            select_index(start)
        end -- if sphered
    else -- if start
        select_all()
    end -- if start
end -- function

local function _list(list)
    if list then
        for i = 1, #list do
            select_index(list[i])
        end -- for
    end -- if list
end -- function

select =
{   segs    = _segs,
    list    = _list
}
--Universal select#

--#Freeze functions
function freeze(f)
    if not f then
        do_freeze(true, true)
    elseif f == "b" then
        do_freeze(true, false)
    elseif f == "s" then
        do_freeze(false, true)
    end -- if
end -- function
--Freeze functions#

--#Scoring
function score(g, slot)
    local more = s1 - c_s
    if more > i_score_gain then
        p("+", more, "+")
        p("++", s1, "++")
        c_s = s1
        quicksave(slot)
        work.flow("s")
    else -- if
        quickload(slot)
    end -- if
end -- function
--Scoring#

--#working
local function _gain(g, cl)
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = debug.score()
            if iter < i_maxiter then
                work.step(g, iter, cl)
            end -- if
            local s2_f = debug.score()
        until s2_f - s1_f < step
        local s3_f = debug.score()
        work.step("s")
        local s4_f = debug.score()
    until s4_f - s3_f < step
end

local function _step(_g, iter, cl)
    if cl then
        set_behavior_clash_importance(cl)
    end -- if
    if rebuilding and _g == "s" then
        select.segs(true, seg, r)
    else -- if rebuilding
        select.segs()
    end -- if rebuilding
    if _g == "wa" then
        do_global_wiggle_all(iter)
    elseif _g == "s" then
        do_shake(1)
    elseif _g == "wb" then
        do_global_wiggle_backbone(iter)
    elseif _g == "ws" then
        do_global_wiggle_sidechains(iter)
    elseif _g == "wl" then
        select.segs(false, seg, r)
        wl = sl.request()
        quicksave(wl)
        for i = iter, iter + 5 do
            local s_s1 = debug.score()
            do_local_wiggle(iter)
            local s_s2 = debug.score()
            if s_s2 > s_s1 then
                quicksave(wl)
            else -- if >
                quickload(wl)
            end -- if >
            if s_s2 == s_s1 then
                break
            end -- if ==
        end -- for
        sl.release(wl)
    end -- if _g
end -- function

local function _flow(g)
    local iter = 0
    if rebuilding then
        slot = sl_re
    elseif snapping then
        slot = snapwork
    else -- if
        slot = overall
    end -- if
    work_sl = sl.request()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            quicksave(work_sl)
        end -- if iter
        s1 = debug.score()
        if iter < i_maxiter then
            work.step(g, iter)
        end -- <
        s2 = debug.score()
    until s2 - s1 < (step * iter)
    if s2 < s1 then
        quickload(work_sl)
    else -- if <
        s1 = s2
    end -- if <
    sl.release(work_sl)
    deselect_all()
    score(g, slot)
end -- function

work =
{   gain    = _gain,
    step    = _step,
    flow    = _flow
}
--Working#