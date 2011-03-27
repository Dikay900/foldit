--[[
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks goes to Rav3n_pl, Tlaloc
Special Thanks goes to Gary Forbis for the great description of his Cookbookwork ;)
]]

--#Game vars
Version     = "2.9.1.1024"
numsegs     = get_segment_count()
--Game vars#

--#Settings: default
--#Working                  default     description
maxiter         = 5         -- 5        max. iterations an action will do
start_seg       = 1         -- 1        the first segment to work with
end_seg         = numsegs   -- numsegs  the last segment to work with
start_walk      = 0         -- 0        with how many segs shall we work - Walker
end_walk        = 5         -- 3        starting at the current seg + start_walk to seg + end_walk
b_lws           = true      -- true     do local wiggle and rewiggle
b_pp            = false     -- false    push / pull together and alone then fuze see #Push Pull
b_rebuild       = false     -- false    rebuild see #Rebuilding
b_str_re        = false     -- false    rebuild based on structure (Implemented Helix only for now)
b_mutate        = false     -- false    it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
b_snap          = false     -- false    should we snap every sidechain to different positions
b_fuze          = false      -- true     should we fuze
--Working#

--#Push Pull
b_comp          = false     -- false
i_pp_trys       = 2         -- 2
--Push Pull#

--#Scoring
step            = 0.001      -- 0.01     an action tries to get this score, then it will repeat itself
gain            = 0.002      -- 0.02     Score will get applied after the score changed this value
--Scoring#

--#Fuzing
b_f_deep        = false
--Fuzing#

--#Mutating
b_m_new         = false     -- false    Will change _ALL_ mutatable, then wiggles out and then mutate again, could get some points for solo, at high evos it's not recommend
b_m_fuze        = true      -- true     fuze a change or just wiggling out (could get some more points but recipe needs longer)
--Mutating#

--#Snapping
--Snapping#

--#Rebuilding
max_rebuilds    = 5         -- 5
rebuild_str     = 1         -- 1
b_r_dist        = false     -- false
b_r_fuze        = true      -- true
b_r_deep        = false     -- false
i_deep_sc       = 10        -- 10
--Rebuilding#

--#Structed rebuilding
b_str_re_dist   = false     -- false
b_str_re_band   = false     -- false
--Structed rebuilding#
--Settings#

--#Constants
saveSlots       = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
amino           = {
                    {'a', 'Ala', 'Alanine'},
                 -- {'b', 'Asx', 'Asparagine or Aspartic acid'},
                    {'c', 'Cys', 'Cysteine'},
                    {'d', 'Asp', 'Aspartic acid'},
                    {'e', 'Glu', 'Glutamic acid'},
                    {'f', 'Phe', 'Phenylalanine'},
                    {'g', 'Gly', 'Glycine'},
                    {'h', 'His', 'Histidine'},
                    {'i', 'Ile', 'Isoleucine'},
                 -- {'j', 'Xle', 'Leucine or Isoleucine'},
                    {'k', 'Lys', 'Lysine'},
                    {'l', 'Leu', 'Leucine'},
                    {'m', 'Met', 'Methionine '},
                    {'n', 'Asn', 'Asparagine'},
                 -- {'o', 'Pyl', 'Pyrrolysine'},
                    {'p', 'Pro', 'Proline'},
                    {'q', 'Gln', 'Glutamine'},
                    {'r', 'Arg', 'Arginine'},
                    {'s', 'Ser', 'Serine'},
                    {'t', 'Thr', 'Threonine'},
                 -- {'u', 'Sec', 'Selenocysteine'},
                    {'v', 'Val', 'Valine'},
                    {'w', 'Trp', 'Tryptophan'},
                 -- {'x', 'Xaa', 'Unspecified or unknown amino acid'},
                    {'y', 'Tyr', 'Tyrosine'},
                 -- {'z', 'Glx', 'Glutamine or glutamic acid'}
                  }
snapping        = false
mutating        = false
--Constants#

--#Securing for changes that will be made at Fold.it
assert          = nil
error           = nil
--Securing#

--#Optimizing
p               = print
--Optimizing#

--#Debug
function assert(b, m)
    if not b then
        p(m)
        error()
    end
end
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
end

local function _floor(value)
    return value - (value % 1)
end

local function _randomseed(x)
    lngX = x
end

local function _random(m,n)
    if not n and m then
        n = m
        m = 1
    end
    if not m and not n then
        return _MWC() / 4294967296
    else
        if n < m then
            return nil
        end
        return math.floor((_MWC() / 4294967296) * (n - m + 1)) + m
    end
end

math=
{   floor       = _floor,
    random      = _random,
    randomseed  = _randomseed
}
--Math library#

function GetDistances()
    distances = {}
    for i = 1, numsegs - 1 do
        distances[i] = {}
        for j = i + 1, numsegs do
            distances[i][j] = get_segment_distance(i , j)
        end
    end
    return distances
end

function GetSphere(seg, radius)
    sphere = {}
    for i = 1, numsegs do
        if get_segment_distance(seg, i) <= radius then
            sphere[#sphere + 1] = i
        end
    end
    return sphere
end

--#Saveslot manager
function ReleaseSaveSlot(slot)
    saveSlots[#saveSlots + 1] = slot
end

function RequestSaveSlot()
    assert(#saveSlots > 0, "Out of save slots")
    local saveSlot = saveSlots[#saveSlots]
    saveSlots[#saveSlots] = nil
    return saveSlot
end
--Saveslot manager#

function FindMutable()
    p("Finding mutable segments -- programm will get stuck a bit")
    local mut = RequestSaveSlot()
    quicksave(mut)
    local mutable = {}
    local isG = {}
    local i
    select_all()
    replace_aa("g")                 -- all mutable segments are set to "g"
    for i = 1, numsegs do
        if get_aa(i) == "g" then    -- find the "g" segments
            isG[#isG + 1] = i
        end
    end
    replace_aa("q")                 -- all mutable segments are set to "q"
    for j = 1, #isG do
        i = isG[j]
        if get_aa(i) == "q" then    -- this segment is mutable
            mutable[#mutable + 1] = i
        end
    end
    p(#mutable, " mutables found")
    quickload(mut)
    ReleaseSaveSlot(mut)
    deselect_all()
    return mutable
end
--External functions#

--#Internal functions
--#Hydrocheck
hydro = {}
for i = 1, numsegs do
hydro[i] = is_hydrophobic(i)
end
--Hydrocheck#

--#Ligand Check
if get_ss(numsegs) == 'M' then
    numsegs = numsegs - 1
end
--Ligand Check#

--#rewritten foldit tools
function work(_g, iter, cl)
    if cl then
        set_behavior_clash_importance(cl)
    end
    if rebuilding and _g == "s" then
        select_segs(true, seg, r)
    else
        select_segs()
    end
    if not g then
        do_global_wiggle_all(iter)
    elseif _g == "s" then
    do_shake(1)
        if fuzing then
            repeat
                local sc1 = get_score()
                do_global_wiggle_backbone(1)
                do_shake(1)
                local sc2 = get_score()
            until sc2 - sc1 < gain
        end
    elseif _g == "wb" then
        do_global_wiggle_backbone(iter)
    elseif _g == "ws" then
        do_global_wiggle_sidechains(iter)
    elseif _g == "wl" then
        wl = RequestSaveSlot()
        quicksave(wl)
        for i = iter, iter + 5 do
            local s_s1 = get_score(true)
            do_local_wiggle(iter)
            local s_s2 = get_score(true)
            if s_s2 - s_s1 > step / 2 * i then
                quicksave(wl)
            end
            quickload(wl)
            if s_s2 == s_s1 then
                break
            end
        end
        ReleaseSaveSlot(wl)
    end
end
--Shake#

--#Fuzing
function fgain(g)
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = get_score(true)
            if iter < maxiter then
                work(g, iter)
            end
            local s2_f = get_score(true)
        until s2_f - s1_f < step
        local s3_f = get_score(true)
        work("s")
        local s4_f = get_score(true)
    until s4_f - s3_f < step
end

function floss(option, cl1, cl2)
    p("Fuzing Method ", option)
    p("cl1 ", cl1, ", cl2 ", cl2)
    if option == 1 then
        p("Pink Fuse cl1-s-cl2-wa")
        work("s", 1, cl1)
        work("wa", 1, cl2)
    elseif option == 2 then
        p("Pink Fuse cl1-wa-cl=1-wa-cl2-wa")
        work("wa", 1, cl1)
        work("wa", 1, 1)
        work("wa", 1, cl2)
    elseif option == 3 then
        p("Blue Fuse cl1-s; cl2-s;")
        work("s", 1, cl1)
        work("wa", 1, 1)
        work("s", 1, cl2)
        work("wa", 1, 1)
        work("s", 1, cl1 - 0.02)
    elseif option == 4 then
        p("cl1-wa[-cl2-wa]")
        work("wa", 1, cl1)
        work("wa", 1, cl2)
    elseif option == 5 then
        p("qStab cl1-s-cl2-wa-cl=1-s")
        work("s", 1, cl1)
        work("wa", 1, cl2)
        work("s", 1, 1)
    end
end

function s_fuze(option, cl1, cl2)
    local s1_f = get_score(true)
    floss(option, cl1, cl2)
    fgain()
    local s2_f = get_score(true)
    if s2_f > s1_f then
        quicksave(sl_f1)
        p("+", s2_f - s1_f, "+")
    end
    quickload(sl_f1)
end

function fuze(sl)
    fuzing = true
    select_all()
    quicksave(sl_f1)
    s_fuze(5, 0.1, 0.4)
    s_fuze(1, 0.1, 0.7)
    s_fuze(1, 0.3, 0.6)
    s_fuze(3, 0.05, 0.07)
    s_fuze(2, 0.5, 0.7)
    s_fuze(2, 0.7, 0.5)
    s_fuze(4, 0.3, 0.3)
    quickload(sl_f1)
    s_f = get_score(true)
    ReleaseSaveSlot(sl_f1)
    if s_f > c_s then
        quicksave(sl)
        s_fg = s_f - c_s
        p("+", s_fg, "+")
        c_s = s_f
        p("++", c_s, "++")
        if b_f_deep then
            r_fuze(sl)
        end
    else
        quickload(sl)
    end
    fuzing = false
end

function r_fuze(sl)
    fuze(sl)
end
--Fuzing#

--#CenterBands
function CreateBandsToCenter()
   local indexCenter = FastCenter()
   for i=start_seg,end_seg do
       if(i ~= indexCenter) then
           if hydro[i] then
               band_add_segment_segment(i,indexCenter)
           end
       end
   end
end
--CenterBands#

--#PushPull
function Pull()
    distances = GetDistances()
    for x = start_seg, end_seg - 2 do
        if hydro[x] then
            for y = x + 2, end_seg do
                math.randomseed(distances[x][y])
                if hydro[y] and math.random() < 0.03 then
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

function Push()
    distances = GetDistances()
    for x = start_seg, end_seg - 2 do
        if not hydro[x] then
            for y = x + 2, end_seg do
                math.randomseed(distances[x][y])
                if not hydro[y] and math.random() < 0.04 then
                    local distance = distances[x][y]
                    if distance <= 15 then
                        band_add_segment_segment(x, y)
                        local band = get_band_count()
                        band_set_strength(band, 2.0)
                        band_set_length(band, distance + 5)
                    end
                end
            end
        end
    end
end
--PushPull#

--#BandMaxDist
function BandMaxDist()
    distances = GetDistances()
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

--#Universal select
function select_segs(sphered, start, _end, more)
    local _start = start
    if not more or not _end then
        deselect_all()
        _end = _start
    end
    if start then
        if sphered then
            if _end and _start ~= _end then
                local list1 = GetSphere(_end, 10)
                select_list(list1)
            end
            local list1 = GetSphere(_start, 10)
            select_list(list1)
        elseif _end and _start ~= _end then
            if _start > _end then
                _start = _end
                _end = start
            end
            select_index_range(_start, _end)
        else
            select_index(_start)
        end
    else
        select_all()
    end
end

function select_list(list)
    if list then
        for i = 1, #list do
            select_index(list[i])
        end
    end
end
--Universal select#

--#Freezing functions
function freeze(f) -- f not used yet
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
--#Universal scoring
function score(g, sl)               -- TODO: need complete rewrite with gd (work) function
    local more = s1 - c_s
    if more > gain then
        p("+", more, "+")
        p("++", s1, "++")
        c_s = s1
        quicksave(sl)
        if g == "wb" then
            p("Rework after backbone wiggle gain.")
            gd("s")
            gd("ws")
            gd("wa")
            p("Rework after backbone wiggle gain ended.")
        elseif g == "ws" then
            p("Rework after sidechain wiggle gain.")
            gd("s")
            gd("wb")
            gd("wa")
            p("Rework after sidechain wiggle gain ended.")
        elseif g == "wl" then
            p("Rework after local wiggle gain.")
            gd("s")
            gd("wb")
            gd("ws")
            gd("wa")
            gd("wl")
            p("Rework after local wiggle gain ended.")
        end
    else
        quickload(sl)
    end
end
--Universal scoring#
--Scoring#

--#Universal working
function gd(g)                  -- TODO: need complete rewrite with score function
    local iter = 0
    if rebuilding then
        sl = sl_re
    elseif snapping then
        sl = snapwork
    else
        sl = overall
    end
    gsl = RequestSaveSlot()
    select(false, seg, r)            -- TODO: handle in select function wa wb ws
    if g ~= "s" then
        if g == "wl" then
            select_segs()
        end
    else
        deselect_all()
        list1 = GetSphere(seg, 10)
        list2 = GetSphere(r, 10)
    end
    repeat
        iter = iter + 1
        if iter ~= 1 then
            quicksave(gsl)
        end
        s1 = get_score(true)
        if iter < maxiter then
            if g == "s" then                -- TODO: Handle in score function
                select_list(list1)               -- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
                select_list(list2)
                local s_s1 = s1
                do_shake(1)
                local s_s2 = get_score(true)
                if s_s2 > s_s1 then
                    quicksave(sl)
                    p("+", s_s2 - s_s1, "+")
                    s1 = s_s2
                    c_s = s1
                end                         -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            elseif g == "wb" then
                do_global_wiggle_backbone(iter)
            elseif g == "ws" then
                do_global_wiggle_sidechains(iter)
            elseif g == "wa" then
                do_global_wiggle_all(iter)
            elseif g == "wl" then
                wl = RequestSaveSlot()
                quicksave(wl)
                for i = iter, iter + 5 do           -- TODO: Think of testing every iter before applying gain
                    if iter > 10 then break end
                    local s_s1 = get_score(true)
                    do_local_wiggle(iter)
                    local s_s2 = get_score(true)
                    if s_s2 - s_s1 > step / 2 * i then
                        quicksave(wl)
                    end
                    quickload(wl)
                    if s_s2 == s_s1 then
                        break
                    end
                end
                ReleaseSaveSlot(wl)
            end
        end
        s2 = get_score(true)
    until s2 - s1 < (step * iter)
    if s2 < s1 then
        quickload(gsl)
    else
        s1 = s2
    end
    ReleaseSaveSlot(gsl)
    deselect_all()
    score(g, sl)
end
--Working#

--#Snapping
function snap(mutated)         -- TODO: need complete rewrite
    snapping = true
    snaps = RequestSaveSlot()
    c_snap = get_score(true)
        cs = get_score(true)
    quicksave(snaps)
    iii = get_sidechain_snap_count(seg)
    p("Snapcount: ", iii, " - Segment ", seg)
    if iii ~= 1 then
    snapwork = RequestSaveSlot()
        for ii = 1, iii do
            quickload(snaps)
            p("Snap ", ii, "/ ", iii)
            c_s = get_score(true)
            select()
            do_sidechain_snap(seg, ii)
            p(get_score(true) - c_s)
            c_s = get_score(true)
            quicksave(snapwork)
            gd("s")
            gd("wa")
            gd("ws")
            gd("wb")
            gd("wl")
            if c_snap < get_score(true) then
            c_snap = get_score(true)
            end
        end
        quickload(snaps)
        quickload(snapwork)
        ReleaseSaveSlot(snapwork)
        if cs < c_snap then
            quicksave(snaps)
        else
            quickload(snaps)
        end
    else
        p("Skipping...")
    end
    snapping = false
    ReleaseSaveSlot(snaps)
    if mutated then
        s_snap = get_score(true)
        if s_mut < s_snap then
            quicksave(overall)
        else
            quickload(sl_mut)
        end
    else
        quicksave(overall)
    end
end
--Snapping#

--#Rebuilding
function rebuild()
    rebuilding = true
    sl_re = RequestSaveSlot()
    sl_best = RequestSaveSlot()
    for i = 1, max_rebuilds do
        quickload(overall)
        quicksave(sl_re)
        select_segs(false, seg, r)
        if r == seg then
            p("Rebuilding Segment ", seg)
        else
            p("Rebuilding Segment ", seg, "-", r)
        end
        p("Try ", i, "/", max_rebuilds)
        cs_0 = get_score(true)
        set_behavior_clash_importance(0.01)
        do_local_rebuild(rebuild_str * i)
        if get_score(true) == cs_0 then
        do_local_rebuild(rebuild_str * i * 2)
        end
        set_behavior_clash_importance(1)
        p(get_score(true) - cs_0)
        c_s = get_score(true)
        quicksave(sl_re)
        if b_mutate then
            mutate()
        end
        if b_r_dist then
            dists()
        end
        select_all()
        if b_r_fuze then
            fuze(sl_re)
        end
        gd("s")
        gd("ws")
        gd("wb")
        gd("wa")
        if b_r_deep or cs_0 - c_s < i_deep_sc then
            gd("wl")
        end
        quickload(sl_re)
        if csr and csr < get_score(true) then
            local csr = get_score(true)
            quicksave(sl_best)
        end
    end
    if csr then c_s = csr end
    quickload(sl_best)
    ReleaseSaveSlot(sl_best)
    p("+", c_s - cs_0, "+")
    quickload(sl_re)
    ReleaseSaveSlot(sl_re)
    if c_s < cs_0 then
        quickload(overall)
    else
        quicksave(overall)
    end
    rebuilding = false
end
--Rebuilding#

--#Mutate function
function mutate()          -- TODO: Test assert Saveslots
    mutating = true
    if b_mutate then
        if b_m_new then
            select(mutable)
            for i = 1, #amino do
                p("Mutating segment ", seg)
                sl_mut = RequestSaveSlot()
                quicksave(sl_mut)
                replace_aa(amino[i][1])
                fgain()
                repeat
                    repeat
                        local mut_1 = get_score(true)
                        do_mutate(1)
                    until get_score(true) - mut_1 < 0.01
                    mut_1 = get_score(true)
                    fgain()
                until get_score(true) - mut_1 < 0.01
                if get_score(true) > c_s then
                    c_s = get_score(true)
                    quicksave(overall)
                end
                quickload(sl_mut)
                ReleaseSaveSlot(sl_mut)
            end
        end
        b_mutating = false
        for l = 1, #mutable do
            if seg == mutable[l] then
                b_mutating = true
            end
        end
        if b_mutating then
            p("Mutating segment ", seg)
            sl_mut = RequestSaveSlot()
            quicksave(sl_mut)
            for j = 1, #amino do
                if get_aa(seg) ~= amino[j][1] then
                    select()
                    replace_aa(amino[j][1])
                    s_mut = get_score(true)
                    p("Mutated: ", seg, " to ", amino[j][2], " - " , amino[j][3])
                    p(#amino - j, " mutations left...")
                    p(s_mut - c_s)
                    if b_m_fuze then
                        fuze(sl_mut)
                    else
                        set_behavior_clash_importance(0.1)
                        do_shake(1)
                        fgain()
                    end
                    s_mut2 = get_score(true)
                    if s_mut2 > s_mut then
                        p("+", s_mut2 - s_mut, "+")
                    else
                        p(s_mut2 - s_mut)
                    end
                    p("~~~~~~~~~~~~~~~~")
                    if s_mut2 > c_s then
                        c_s = s_mut2
                        quicksave(overall)
                    end
                    quickload(sl_mut)
                    s_mut2 = get_score(true)
                end
            end
            ReleaseSaveSlot(sl_mut)
            quickload(overall)
        end
    end
    mutating = false
end
--Mutate#

--#Push Pull
function dists()
    pp = RequestSaveSlot()
    quicksave(pp)
    s_dist = get_score()
    if b_comp then
        BandMaxDist()
        select_all()
        set_behavior_clash_importance(0.7)
        do_global_wiggle_backbone(1)
        band_delete()
        fuze(pp)
        if get_score() < s_dist then
            quickload(overall)
        end
    end
    Push()
    Pull()
    select_all()
    set_behavior_clash_importance(0.8)
    do_global_wiggle_backbone(1)
    band_delete()
    fuze(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
    Pull()
    select_all()
    set_behavior_clash_importance(0.7)
    do_global_wiggle_backbone(1)
    band_delete()
    fuze(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
    Push()
    select_all()
    set_behavior_clash_importance(0.7)
    do_global_wiggle_backbone(1)
    band_delete()
    fuze(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
end
--Push Pull#

--#fast ss
ss = {}
for i = 1, numsegs do
    ss[i] = get_ss(i)
end
local i
he = {}
for i = 1, numsegs do
    if ss[i] == "H" and not helix then
        helix = true
        he[#he + 1] = {}
    end
    if helix then
        if ss[i] == "H" then
            he[#he][#he[#he]+1] = i
        else
            helix = false
        end
    end
end
--fastss#

--#struct rebuild
function struct_rebuild()
    p("Found ", #he, " Helixes")
    local iter = 1
    for i = 1, #he do
        deselect_all()
        str_rs = get_score(true)
        seg = he[i][1] - 1
        if seg <= 0 then
            seg = 1
        end
        r = he[i][#he[i]] + 1
        if r > numsegs then
            r = numsegs
        end
        if b_str_re_band then
        for ii = he[i][1], he[i][#he[i]] do
            for iii = he[i][1] + 3, he[i][#he[i]] do
                if iii > ii then
                    local len = 1.26 + (1.26 * (iii - ii))
                    if len > 20 then
                        len = 20
                    end
                    if len > 0 then
                        band_add_segment_segment(ii, iii)
                    end
                    band_set_length(get_band_count(), len)
                    local pp = get_segment_distance(ii, iii)
                    while pp > 1 do
                        pp = pp /5
                    end
                    while pp < 1 do
                        pp = pp * 2
                    end
                    band_set_strength(get_band_count(), pp)
                end
            end
        end
        select_all()
        do_global_wiggle_all(1)
        band_delete()
        end
        deselect_all()
        select_index_range(seg, r)
        set_behavior_clash_importance(0)
        for i = 1, 5 do
        while get_score(true) == str_rs do
            do_local_rebuild(iter)
            iter = iter + i
        end
        str_rs = get_score(true)
        end
        set_behavior_clash_importance(1)
        if b_str_re_dist then
            dists()
        else
            rebuilding = true
            fuze(overall)
        end
    end
    rebuilding = false
end
--struct rebuild#

--#Compressor
function compress()
p("Compressing Segment ",seg)
sphere={}
range=0
repeat
count=0
range=range+2
sphere=fsl.GetSphere(seg,range)
for n=1,#sphere-1 do
if sphere[n]>seg+range/4 and sphere[n]+1~=sphere[n+1] or sphere[n]<seg-range/4 and sphere[n]+1~=sphere[n+1] then
count=count+1
end
end
until count>4
for n=1,#sphere-1 do
if sphere[n]>seg+range/4 and sphere[n]+1~=sphere[n+1] or sphere[n]<seg-range/4 and sphere[n]+1~=sphere[n+1] then
band_add_segment_segment(seg,sphere[n])
local length=get_segment_distance(seg,sphere[n])
repeat
length=length*7/8
until length<=5
band_set_length(get_band_count(),length)
band_set_strength(get_band_count(),length/5)
end
end
do_global_wiggle_backbone(1)
band_delete()
p("Compressing Segment ",seg,"-",r)
sphere1={}
sphere2={}
range=0
end
--Compressor#

--#Bands
function bands()
_numsegs=get_segment_count()
p(_numsegs)
i=1
select_all()
replace_ss("L")
deselect_all()
function Round(x)--cut all afer 3-rd place
	return x-x%1.
end
numsegs=Round(_numsegs/2)
p(numsegs)
while i<numsegs do
band_add_segment_segment(numsegs-i,numsegs+i)
band_set_strength(i,10)
band_set_length(i,0)
i=i+1
end
band_add_segment_segment(numsegs,_numsegs)
band_add_segment_segment(numsegs,1)
bands=get_band_count()
for i=bands-1,bands do
band_set_strength(i,10)
band_set_length(i,0)
end
band_add_segment_segment(numsegs/2,_numsegs)
band_add_segment_segment(numsegs+numsegs/2,_numsegs)
band_add_segment_segment(numsegs/2,1)
band_add_segment_segment(numsegs+numsegs/2,1)
band_add_segment_segment(numsegs/4,numsegs+numsegs/4)
band_add_segment_segment(numsegs/4,numsegs-numsegs/4)
band_add_segment_segment(numsegs+numsegs*3/4,numsegs+numsegs/4)
band_add_segment_segment(numsegs+numsegs*3/4,numsegs-numsegs/4)
for i=bands+1,bands+8 do
band_set_strength(i,0.01)
band_set_length(i,20)
end
bands=get_band_count()
select_all()
do_global_wiggle_all(1)
do_shake(1)
for i=1,bands do
band_set_strength(i,5)
band_set_length(i,5)
end
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
for i=1,bands do
band_set_strength(i,2)
band_set_length(i,5)
end
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
for i=1,bands do
band_set_strength(i,1)
band_set_length(i,4)
end
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
for i=1,bands do
band_set_strength(i,0.01)
end
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
band_delete()
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
end
--Bands#

function all()
    if b_pp then
        for i = 1, i_pp_trys do
            dists()
        end
    end
    if b_str_re then
        struct_rebuild()
    end
    if b_mutate then
        mutable = FindMutable()
    end
    for i = start_seg, end_seg do
        p(Version)
        seg = i
        c_s = get_score(true)
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
            p(seg, "-", r)
            if b_rebuild then
                rebuild()
            end
            if b_lws then
                gd("wl")
                gd("wb")
                gd("ws")
                gd("wa")
            end
        end
    end
    if b_fuze then
        fuze(overall)
    end
end

s_0 = get_score(true)
c_s = s_0
p("Starting Score: ", c_s)
overall = RequestSaveSlot()
quicksave(overall)
all()
quickload(overall)
s_1 = get_score(true)
p("+++ Overall Gain +++")
p("+++", s_1 - s_0, "+++")