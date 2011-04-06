--[[
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions goes to Rav3n_pl, Tlaloc and Gary Forbis
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
Version     = "1058"
Release     = true          -- if true this script is relatively safe ;)
numsegs     = get_segment_count()
--Game vars#

--#Settings: default
--#Working                  default     description
maxiter         = 5         -- 5        max. iterations an action will do
start_seg       = 1         -- 1        the first segment to work with
end_seg         = numsegs   -- numsegs  the last segment to work with
start_walk      = 0         -- 0        with how many segs shall we work - Walker
end_walk        = 3         -- 3        starting at the current seg + start_walk to seg + end_walk
b_lws           = false     -- false    do local wiggle and rewiggle
b_rebuild       = true      -- false    rebuild see #Rebuilding
--[[v=v=v=v=v=NO=WALKING=HERE=v=v=v=v=v=v]]--
b_pp            = false     -- false    pull of hydrophobic in different modes then fuze see #Pull
b_str_re        = false     -- false    working based on structure (Implemented Helix only for now)
b_fuze          = false     -- false    should we fuze
-- TEMP
b_explore       = false     -- false    Exploration Puzzle
--Working#

--#Scoring
step            = 0.001     -- 0.001    an action tries to get this score, then it will repeat itself
gain            = 0.002     -- 0.002    Score will get applied after the score changed this value
--Scoring#

--#Pull
b_comp          = false     -- false    try a pull of the two segments which have the biggest distance in between
i_pp_trys       = 2         -- 2        how often should the pull start over?
--Pull#

--#Fuzing
b_f_deep        = false     -- false
--Fuzing#

--#Rebuilding
b_worst_rebuild = true      -- false    rebuild worst scored parts of the protein
max_rebuilds    = 2         -- 2        max rebuilds till best rebuild will be chosen 
rebuild_str     = 1         -- 1        the iterations a rebuild will do at default, automatically increased if no change in score
b_r_dist        = false     -- false    start pull see #Pull after a rebuild
--Rebuilding#

--#Structed rebuilding
i_str_re_max_re = 2         -- 2        same as max_rebuilds at #Rebuilding
i_str_re_re_str = 2         -- 2        same as rebuild_str at #Rebuilding
b_str_re_dist   = false     -- false    same as b_r_dist at #Rebuilding
b_str_re_fuze   = false     -- true
--Structed rebuilding#

--[[
b_mutate        = false     -- false    it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
b_snap          = false     -- false    should we snap every sidechain to different positions
--#Mutating
b_m_new         = false     -- false    Will change _ALL_ mutatable, then wiggles out and then mutate again, could get some points for solo, at high evos it's not recommend
b_m_fuze        = true      -- true     fuze a change or just wiggling out (could get some more points but recipe needs longer)
--Mutating#
]]
--Settings#

--#Constants
saveSlots       = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
--[[
snapping        = false
mutating        = false
rebuilding      = false
]]
fuzing          = false
sc_changed      = true
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
    end -- if b
end -- function

local function _score()
    local s = 0
    if b_explore then
        for i = 1, numsegs do
            s = s + get_segment_score(i)
        end --for
    else -- if b_explore
        s = get_score(true)
    end --if
    return s
end --function

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

math =
{   floor       = _floor,
    random      = _random,
    randomseed  = _randomseed
}
--Math library#

--#Getters
local function _dists()
    distances = {}
    for i = 1, numsegs - 1 do
        distances[i] = {}
        for j = i + 1, numsegs do
            distances[i][j] = get_segment_distance(i, j)
        end -- for j
    end -- for i
end

local function _sphere(seg, radius)
    sphere = {}
    for i = 1, numsegs do
        if get_segment_distance(seg, i) <= radius then
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
            else -- ss
                sheet = false
            end
        end
        if loop then
            if ss[i] == "L" then
                lo[#lo][#lo[#lo]+1] = i
            else
                loop = false
            end
        end
    end
end
--Structurecheck#

check =
{   ss      = _ss,
    aa      = _aa,
    ligand  = _ligand,
    hydro   = _hydro,
    struct  = _struct
}
--Checks#

--#Bonding
--#Center
local function _cp(locally)
    local indexCenter = get.center()
    local start
    local _end
    if locally then
        start = seg
        _end = r
    else
        start = start_seg
        _end = end_seg
    end
    for i = start, _end do
        if i ~= indexCenter then
            if hydro[i] then
                band_add_segment_segment(i, indexCenter)
            end
        end
    end
end
--Center#

--#Pull
local function _p(locally, bandsp)
    if locally then
        start = seg
        _end = r
    else
        start = start_seg
        _end = end_seg
    end
    get.dists()
    for x = start, _end - 2 do
        if hydro[x] then
            for y = x + 2, numsegs do
                math.randomseed(distances[x][y])
                if hydro[y] and math.random() < bandsp then
                    maxdistance = distances[x][y]
                    band_add_segment_segment(x, y)
                repeat
                    maxdistance = maxdistance * 3 / 4
                until maxdistance <= 20
                local band = get_band_count()
                band_set_strength(band, maxdistance / 15)
                band_set_length(band, maxdistance)
                end
            end
        end
    end
end
--Pull#

--#BandMaxDist
local function _maxdist()
    get.dists()
    local maxdistance = 0
    for i = start_seg, end_seg do
        for j = start_seg, end_seg do
            if i ~= j then
                local x = i
                local y = j
                if x > y then
                    x, y = y, x
                end
                if distances[x][y] > maxdistance then
                    maxdistance = distances[x][y]
                    maxx = i
                    maxy = j
                end
            end
        end
    end
    band_add_segment_segment(maxx, maxy)
    repeat
        maxdistance = maxdistance * 3 / 4
    until maxdistance <= 20
    band_set_strength(get_band_count(), maxdistance / 15)
    band_set_length(get_band_count(), maxdistance)
end
--BandMaxDist#

bonding =
{   centerpull  = _cp,
    pull        = _p,
    maxdist     = _maxdist
}
--Bonding#

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
        end
        reset_recent_best()
        bf1 = get_score()
        work.step("s", 1, cl1 - 0.02)
        work.gain("wa", 1)
        bf2 = get_score()
        if bf2 < bf1 then
            restore_recent_best()
        end
    elseif option == 5 then
        p("cl1-wa[-cl2-wa]")
        work.step("wa", 1, cl1)
    elseif option == 1 then
        p("qStab cl1-s-cl2-wa-cl=1-s")
        work.step("s", 1, cl1)
        work.step("wa", 1, cl2)
        work.step("s", 1, 1)
    end
end

local function _part(option, cl1, cl2)
    local s1_f = debug.score()
    fuze.loss(option, cl1, cl2)
    if option ~= 2 then
        work.gain("wa", 1)
    end
    local s2_f = debug.score()
    if s2_f > s1_f then
        quicksave(sl_f1)
        p("+", s2_f - s1_f, "+")
    end
    quickload(sl_f1)
end

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
        end
    else
        quickload(slot)
    end
end

local function _again(slot)
    fuze.start(slot)
end

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
    end
    if start then
        if sphered then
            if start ~= _end then
                local list1 = get.sphere(_end, 14)
                select.list(list1)
            end
            local list1 = get.sphere(start, 14)
            select.list(list1)
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end
            select_index_range(start, _end)
        elseif start ~= _end then
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end
            select_index_range(start, _end)
        else
            select_index(start)
        end
    else
        select_all()
    end
end

local function _list(list)
    if list then
        for i = 1, #list do
            select_index(list[i])
        end
    end
end

select =
{   segs    = _segs,
    list    = _list
}
--Universal select#

--#Freezing functions
function freeze(f)
    if not f then
        do_freeze(true, true)
    elseif f == "b" then
        do_freeze(true, false)
    elseif f == "s" then
        do_freeze(false, true)
    end
end
--Freezing functions#

--#Scoring
function score(g, slot)
    local more = s1 - c_s
    if more > gain then
        sc_changed = true
        p("+", more, "+")
        p("++", s1, "++")
        c_s = s1
        quicksave(slot)
        work.flow("s")
    else
        quickload(slot)
    end
end
--Scoring#

--#working
local function _gain(g, cl)
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = debug.score()
            if iter < maxiter then
                work.step(g, iter, cl)
            end
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
    end
    if rebuilding and _g == "s" then
        select.segs(true, seg, r)
    else
        select.segs()
    end
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
        if b_fast_lws then
            repeat
                local s_s1 = debug.score()
                do_local_wiggle(iter)
                local s_s2 = debug.score()
            until s_s1 > s_s2
        else
            for i = iter, iter + 5 do
                local s_s1 = debug.score()
                do_local_wiggle(iter)
                local s_s2 = debug.score()
                if s_s2 > s_s1 then
                    quicksave(wl)
                else
                    quickload(wl)
                end
                if s_s2 == s_s1 then
                    break
                end
            end
        end
        sl.release(wl)
    end
end

local function _flow(g)
    local iter = 0
    if rebuilding then
        slot = sl_re
    elseif snapping then
        slot = snapwork
    else
        slot = overall
    end
    gsl = sl.request()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            quicksave(gsl)
        end
        s1 = debug.score()
        if iter < maxiter then
            work.step(g, iter)
        end
        s2 = debug.score()
    until s2 - s1 < (step * iter)
    if s2 < s1 then
        quickload(gsl)
    else
        s1 = s2
    end
    sl.release(gsl)
    deselect_all()
    score(g, slot)
end

work =
{   gain    = _gain,
    step    = _step,
    flow    = _flow
}
--Working#

--#Rebuilding
function rebuild()
    rebuilding = true
    sl_re = sl.request()
    sl_best = sl.request()
    quickload(overall)
    quicksave(sl_re)
    select.segs(false, seg, r)
    if r == seg then
        p("Rebuilding Segment ", seg)
    else
        p("Rebuilding Segment ", seg, "-", r)
    end
    for i = 1, max_rebuilds do
        p("Try ", i, "/", max_rebuilds)
        cs_0 = debug.score()
        set_behavior_clash_importance(0.01)
        do_local_rebuild(rebuild_str * i)
        while debug.score() == cs_0 do
            do_local_rebuild(rebuild_str * i * iter)
            iter = iter + i
        end
        if re_sc or re_sc < str_rs then
            re_sc = str_rs
            quicksave(sl_re)
        end
    end
    set_behavior_clash_importance(1)
    p(debug.score() - cs_0)
    c_s = debug.score()
    quicksave(sl_re)
    if b_mutate then
        mutate()
    end
    if b_r_dist then
        dists()
    end
    if b_r_fuze then
        fuze.start(sl_re)
    end
    quickload(sl_re)
    if csr and csr < debug.score() then
        local csr = debug.score()
        quicksave(sl_best)
    end
    if csr then
        c_s = csr
    end
    quickload(sl_best)
    sl.release(sl_best)
    p("+", c_s - cs_0, "+")
    sl.release(sl_re)
    if c_s < cs_0 then
        quickload(overall)
    else
        quicksave(overall)
    end
    rebuilding = false
end
--Rebuilding#

--#Pull
function dists()
    pp = sl.request()
    quicksave(pp)
    s_dist = get_score()
    if b_comp then
        bonding.maxdist()
        select_all()
        set_behavior_clash_importance(0.7)
        do_global_wiggle_backbone(1)
        band_delete()
        fuze.start(pp)
        if get_score() < s_dist then
            quickload(overall)
        end
    end
    bonding.pull(false, 0.05)
    select_all()
    set_behavior_clash_importance(0.4)
    do_global_wiggle_backbone(1)
    band_delete()
    fuze.start(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
    bonding.centerpull()
    select_all()
    set_behavior_clash_importance(0.4)
    do_global_wiggle_backbone(1)
    band_delete()
    fuze.start(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
end
--Pull#

--#struct rebuild
function struct_rebuild()
    check.struct()
    p("Found ", #he, " Helixes ", #sh, " Sheets and ", #lo, " Loops")
    local iter = 1
    for i = 1, #he do
        deselect_all()
        str_rs = debug.score()
        seg = he[i][1] - 3
        if seg < 1 then
            seg = 1
        end
        r = he[i][#he[i]] + 3
        if r > numsegs then
            r = numsegs
        end
        --Save structures and replace with loop for better rebuilding
        local tempss = {}
        local temp = he[i][1] - 1
        if temp < 1 then
            temp = 1
        end
        for ii = seg, temp do
            tempss[#tempss + 1] = get_ss(ii)
        end
        select_index_range(seg, temp)
        temp = he[i][#he[i]] + 1
        if temp > numsegs then
            temp = he[i][#he[i]]
        end
        for ii = temp, r do
            tempss[#tempss + 1] = get_ss(ii)
        end
        select_index_range(temp, r)
        replace_ss("L")
        deselect_all()
        --Saved structures
        for ii = he[i][1], he[i][#he[i]] - 4, 4 do
            band_add_segment_segment(ii, ii + 4)
        end
        for ii = he[i][1] + 1, he[i][#he[i]] - 4, 4 do
            band_add_segment_segment(ii, ii + 4)
        end
        for ii = he[i][1] + 2, he[i][#he[i]] - 4, 4 do
            band_add_segment_segment(ii, ii + 4)
        end
        for ii = he[i][1] + 3, he[i][#he[i]] - 4, 4 do
            band_add_segment_segment(ii, ii + 4)
        end
        if get_band_count() < 3 then
        for ii = he[i][1], he[i][#he[i]] - 3, 3 do
            band_add_segment_segment(ii, ii + 3)
        end
        for ii = he[i][1] + 1, he[i][#he[i]] - 3, 3 do
            band_add_segment_segment(ii, ii + 3)
        end
        for ii = he[i][1] + 2, he[i][#he[i]] - 3, 3 do
            band_add_segment_segment(ii, ii + 3)
        end
        for ii = he[i][1] + 3, he[i][#he[i]] - 3, 3 do
            band_add_segment_segment(ii, ii + 3)
        end
        end
        deselect_all()
        select_index_range(seg, r)
        set_behavior_clash_importance(0.05)
        best = sl.request()
        quicksave(best)
        for i = 1, i_str_re_max_re do
            while debug.score() == str_rs do
                do_local_rebuild(iter)
                iter = iter + 1
                if iter > maxiter then
                    iter = maxiter
                end
            end
            iter = 1
            str_rs = debug.score()
            if not str_sc or str_sc < str_rs then
                str_sc = str_rs
                quicksave(best)
            end
        end
        str_sc = nil
        quickload(best)
        band_delete()
        seg = he[i][1] - 1
        if seg < 1 then
            seg = 1
        end
        r = he[i][#he[i]] + 1
        if r > numsegs then
            r = numsegs
        end
        deselect_all()
        select_index_range(seg, r)
        for i = 1, i_str_re_max_re do
            while debug.score() == str_rs do
                do_local_rebuild(iter * i_str_re_re_str)
                iter = iter + 1
                if iter > maxiter then
                    iter = maxiter
                end
            end
            iter = 1
            str_rs = debug.score()
            if not str_sc or str_sc < str_rs then
                str_sc = str_rs - ((str_rs ^ 2)^(1/2))/2
                quicksave(best)
            end
        end
        quickload(best)
        seg = he[i][1] - 3
        if seg < 1 then
            seg = 1
        end
        r = he[i][1] - 1
        if r < 1 then
            r = 1
        end
        deselect_all()
        select_index_range(seg, r)
        seg = he[i][#he[i]] + 1
        if seg < 1 then
            seg = 1
        end
        r = he[i][#he[i]] + 3
        if r > numsegs then
            r = numsegs
        end
        select_index_range(seg, r)
        for i = 1, i_str_re_max_re do
            while debug.score() == str_rs do
                do_local_rebuild(iter * i_str_re_re_str)
                iter = iter + 1
                if iter > maxiter then
                    iter = maxiter
                end
            end
            iter = 1
            str_rs = debug.score()
            if not str_sc or str_sc < str_rs then
                str_sc = str_rs - ((str_rs ^ 2)^(1/2))/2
                quicksave(best)
            end
        end
        quickload(best)
        seg = he[i][1] - 2
        if seg < 1 then
            seg = 1
        end
        r = he[i][#he[i]] + 2
        if r > numsegs then
            r = numsegs
        end
        set_behavior_clash_importance(1)
        -- Restore structures saved before
        temp = he[i][#he[i]] + 1
        if temp > numsegs then
            temp = numsegs
        end
        for ii = r, temp, -1 do
            select_index(ii)
            replace_ss(tempss[#tempss])
            tempss[#tempss] = nil
        end
        temp = he[i][1] - 1
        if temp < 1 then
            temp = 1
        end
        for ii = temp, seg, -1 do
            select_index(ii)
            replace_ss(tempss[#tempss])
            tempss[#tempss] = nil
        end
        quicksave(best)
        -- Restored structures
        if b_str_re_dist then
            dists()
        elseif b_str_re_fuze then
            rebuilding = true
            fuze.start(best)
            rebuilding = false
        end
        str_sc = nil
        str_rs = nil
        sl.release(best)
    end
end
--struct rebuild#

function all()
    p("v", Version)
    if b_pp then
        for i = 1, i_pp_trys do
            dists()
        end
    end
    if b_predict_ss then
        predict_ss()
    end
    if b_str_re then
        struct_rebuild()
    end
    if b_mutate then
        mutable = FindMutable()
    end
    for i = start_seg, end_seg do
        seg = i
        c_s = debug.score()
        if b_mutate then
            mutate()
        end
        if b_snap then
            snap()
        end
        for ii = start_walk, end_walk do
            r = i + ii
            if r > numsegs then
                r = numsegs
                break
            end
            if b_rebuild then
                if b_worst_rebuild then
                    local worst = 1000
                    for iii = 1, numsegs do
                        local s = get_segment_score(iii)
                        if s < worst then
                            seg = iii
                        end
                    end
                    r = seg + ii
                end
                rebuild()
            end
            if b_lws then
                p(seg, "-", r)
                work.flow("wl")
                if sc_changed then
                    work.flow("wb")
                    work.flow("ws")
                    work.flow("wa")
                    sc_changed = false
                end
            end
        end
    end
    if b_fuze then
        fuze.start(overall)
    end
end

s_0 = debug.score()
c_s = s_0
check.aa()
check.ligand()
check.hydro()
p("Starting Score: ", c_s)
overall = sl.request()
quicksave(overall)
all()
quickload(overall)
s_1 = debug.score()
p("+++ Overall Gain +++")
p("+++", s_1 - s_0, "+++")