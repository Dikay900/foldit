-- This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
-- Thanks goes to Rav3n_pl, Tlaloc
-- Special Thanks goes to Gary Forbis for the great description of his Cookbookwork ;)

--#Settings
--#Working
maxiter     = 3         -- max. iterations an action will do
start_seg   = 283       -- the first segment to work with
end_seg     = 294       -- the last segment to work with
b_rebuild   = false     -- should we rebuild
b_mutate    = true      -- it's a mutating puzzle so we should mutate to get the best out of every single option
b_snap      = false     -- should we snap every sidechain to different positions
b_fuze      = true      -- should we fuze
--Working#

--#Scoring
step        = 0.05      -- an action tries to get this score, then it will repeat itself
gain        = 0.25      -- Score will get applied after the score changed this value
--Scoring#

--#Fuzing
fastfuze    = false     -- Every fuze will get tested and the best will be selected, then fuze again if false
--Fuzing#

--#Mutating
b_m_new     = true
--Mutating#

--#Rebuilding

--Rebuilding#
--Settings#

--#Game vars
Version     = "2.8.7.962"
numsegs     = get_segment_count()
s0          = get_score(true)
c_s          = s0
--Game vars#

--#Constants
saveSlots   = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
amino       = {
   {'a','Ala','Alanine'},
-- {'b','Asx','Asparagine or Aspartic acid' }, 
   {'c','Cys','Cysteine'},
   {'d','Asp','Aspartic acid'},
   {'e','Glu','Glutamic acid'},
   {'f','Phe','Phenylalanine'},
   {'g','Gly','Glycine'},
   {'h','His','Histidine'},
   {'i','Ile','Isoleucine'},
-- {'j','Xle','Leucine or Isoleucine' }, 
   {'k','Lys','Lysine'},
   {'l','Leu','Leucine'},
   {'m','Met','Methionine '},
   {'n','Asn','Asparagine'},
-- {'o','Pyl','Pyrrolysine' }, 
   {'p','Pro','Proline'},
   {'q','Gln','Glutamine'},
   {'r','Arg','Arginine'},
   {'s','Ser','Serine'},
   {'t','Thr','Threonine'},
-- {'u','Sec','Selenocysteine' }, 
   {'v','Val','Valine'},
   {'w','Trp','Tryptophan'},
-- {'x','Xaa','Unspecified or unknown amino acid' },
   {'y','Tyr','Tyrosine'},
-- {'z','Glx','Glutamine or glutamic acid' } 
}
--Constants#

--#Securing for changes that will be made at Fold.it
assert      = nil
error       = nil
--Securing#

--#Optimizing
p = print
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
function GetSphere(seg, radius)
    sphere={}
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
    p("Finding Mutable Segments -- Programm will get stuck a bit")
    mut = RequestSaveSlot()
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
    quickload(mut)
    p(#mutable, " mutables found")
    ReleaseSaveSlot(mut)
    return mutable
end
--External functions#

--#Internal functions

--#Ligand Check
if get_ss(numsegs) == 'M' then
    numsegs = numsegs - 1
end
--Ligand Check#

--#Fuzing Version = "1.0.3.135"
function fgain()
    set_behavior_clash_importance(1)
    select_all()
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = get_score(true)
            if iter < maxiter then
                do_global_wiggle_all(iter)
            end
            local s2_f = get_score(true)
        until s2_f - s1_f < step
        local s3_f = get_score(true)
        do_shake(1)
        local s4_f = get_score(true)
    until s4_f - s3_f < step
end

function fstruct(g, cl)
    set_behavior_clash_importance(cl)
    if g == "s" then
        do_shake(1)
    elseif g == "w" then
        do_global_wiggle_all(1)
    end
end

function floss(option, cl1, cl2)
    p("Fuzing Method ", option)
    p("cl1 ", cl1, ", cl2 ", cl2)
    if option == 1 then
        p("Pink Fuse cl1-s-cl2-wa")
        fstruct("s", cl1)
        fstruct("w", cl2)
    elseif option == 2 then
        p("Pink Fuse cl1-wa-cl=1-wa-cl2-wa")
        fstruct("w", cl1)
        fstruct("w", 1)
        fstruct("w", cl2)
    elseif option == 3 then
        p("cl1-s; cl2-s;")
        fstruct("s", cl1)
        fgain()
        fstruct("s", cl2)
    elseif option == 4 then
        p("cl1-wa[-cl2-wa]")
        fstruct("w", cl1)
        fstruct("w", cl2)
    elseif option == 5 then
        p("qStab cl1-s-cl2-wa-cl=1-s")
        fstruct("s", cl1)
        fstruct("w", cl2)
        fstruct("s", 1)
    end
end

function s_fuze(option, cl1, cl2)
    local s1_f = get_score(true)
    floss(option, cl1, cl2)
    fgain()
    local s2_f = get_score(true)
    if s2_f > s1_f then
        sl_f[#sl_f + 1] = RequestSaveSlot()
        quicksave(sl_f[#sl_f])
        p("+", s2_f - s1_f, "+")
    end
    quickload(sl_f[1])
end

function fuze(sl)
    if b_fuze == true then
        select_all()
        sl_f = {}
        sl_f[1] = RequestSaveSlot()
        quicksave(sl_f[1])
        s_fuze(1, 0.1, 0.7)
        s_fuze(1, 0.3, 0.6)
        s_fuze(2, 0.5, 0.7)
        s_fuze(2, 0.7, 0.5)
        s_fuze(3, 0.05, 0.07)
        s_fuze(4, 0.3, 0.3)
        s_fuze(5, 0.1, 0.4)
-------------------#
        local s_f = get_score()
        for i = 2, #sl_f do
            quickload(sl_f[i])
            s_f1 = get_score(true)
            if s_f1 > s_f then
                quicksave(sl_f[1])
                s_f = s_f1
            end
        end
        quickload(sl_f[1])
        if s_f > c_s then
            quicksave(sl)
            c_s = s_f
            p("++", c_s, "++")
            fuze(sl)
        end
        deselect_all()
        quickload(sl)
-------------------#
    end
end
--Fuzing#

--#Universal select function Version = "1.0.0.5"
function select(list, more)
    if not more then
        deselect_all()
    end
    if seg then
        if r and seg ~= r then
            if r < seg then
                _r = seg
                _seg = temp
            end
            select_index_range(_seg, _r)
        else
            select_index(seg)
        end
    else
        select_all()
    end
    if list then
        deselect_all()
        for i = 1, #list do
            select_index(list[i])
        end
    end
end
--Universal select function#

--Freezing functions
function freeze(f) -- f not used yet
    if f==nil then
        do_freeze(true, true)
    elseif f == "b" then
        do_freeze(true, false)
    elseif f == "s" then
        do_freeze(false, true)
    end
end
--Freezing functions#

--#Universal scoring function Version = "1.0.1.29"
function score(g, sl)
    local more = s1 - c_s
    if more > gain then
        p("+", more, "+")
        p("++", s1, "++")
        c_s = s1
        quicksave(sl)
        if more > step then
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
                gd("wl")
                gd("wa")
                p("Rework after sidechain wiggle gain ended.")
            end
        else
            select()
            f_sl=RequestSaveSlot()
            quicksave(f_sl)
            s1 = get_score(true)
            do_local_wiggle(1)
            s2 = get_score(true)
            quickload(f_sl)
            ReleaseSaveSlot(f_sl)
            if s2 == s1 then
                cfreezed = true
            end
            quickload(sl)
            if cfreezed then
                do_unfreeze_all()
                deselect_all()
                select()
                freeze()
            end
        end
    end
end
--Universal scoring function#

--#Snapping function Version = "1.0.2.169"
function _snap(mutated)
    snapping = 1
    snaps = RequestSaveSlot()
    quicksave(snaps)
    iii = get_sidechain_snap_count(seg)
    p("Snapcount: ", iii, " - Segment ", seg)
    if iii ~= 1 then
        for ii = 1, iii do
            quickload(snaps)
            p("Snap ", ii, "/ ", iii)
            c_s = get_score(true)
            select()
            do_sidechain_snap(seg, ii)
            p(get_score(true) - c_s)
            c_s = get_score(true)
            snapwork = RequestSaveSlot()
            quicksave(snapwork)
            freeze()
            gd("s")
            gd("wa")
            gd("ws")
            gd("wb")
            do_unfreeze_all()
            gd("wl")
            gd("wa")
            gd("s")
            gd("wl")
            gd("wa")
        end
        quickload(snaps)
        cs2 = get_score(true)
        quickload(snapwork)
        ReleaseSaveSlot(snapwork)
        cs3 = get_score(true)
        if cs3 > cs2 then
            quicksave(snaps)
        else
            quickload(snaps)
        end
    else
        p("Skipping...")
    end
    snapping = 0
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
--Snapping function#

--#Universal working function Version = "1.6.5.475"
function gd(g)
    local iter = 0
    if rebuild == 1 then
        sl = rebuild1
    elseif snapping == 1 then
        sl = snapwork
    else
        sl = overall
    end
    gsl = RequestSaveSlot()
    select_all()
    if g ~= "s" then
        if g == "wl" then
            select()
        end
    else
        local list1 = GetSphere(seg, 8)
        local list2 = GetSphere(r, 8)
    end
    repeat
        iter = iter + 1
        if iter ~= 1 then
            quicksave(gsl)
        end
        s1 = get_score(true)
        if iter < maxiter then
            if g == "s" then
                select(list1)
                select(list2,true)
                local s_s1 = s1
                do_shake(1)
                local s_s2 = get_score(true)
                if s_s2 > s_s1 then
                    s_s2 = get_score(true)
                    quicksave(sl)
                    p("+", s_s2 - s_s1, "+")
                    s1 = s_s2
                    c_s = s1
                end
            elseif g == "wb" then
                do_global_wiggle_backbone(iter)
            elseif g == "ws" then
                do_global_wiggle_sidechains(iter)
            elseif g == "wa" then
                do_global_wiggle_all(iter)
            elseif g == "wl" then
                wl = RequestSaveSlot()
                quicksave(wl)
                for i = iter, iter + 5 do
                    local s_s1 = get_score(true)
                    do_local_wiggle(iter)
                    local s_s2 = get_score(true)
                    if s_s2 > s_s1 then
                        quicksave(wl)
                    end
                    quickload(wl)
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

function _rebuild()
    rebuild = 1
    rebuild1 = RequestSaveSlot()
    rebuildsl = {}
    for i = 1, 4 do
        quickload(overall)
        do_unfreeze_all()
        quicksave(rebuild1)
        select()
        if r == seg then
            p("Rebuilding Segment ", seg)
        else
            p("Rebuilding Segment ", seg, "-", r)
        end
        p("Try ", i, "/4")
        c_s = get_score(true)
        cs0 = c_s
        do_local_rebuild(3 * i)
        p(get_score(true) - c_s)
        c_s = get_score(true)
        quicksave(rebuild1)
        mutate()
        select_all()
        gd("s")
        gd("ws")
        gd("wl")
        gd("s")
        gd("wa")
        quickload(rebuild1)
        rebuildsl[i] = RequestSaveSlot()
        quicksave(rebuildsl[i])
    end
    csr={}
    for i = 1, #rebuildsl do
        quickload(rebuildsl[i])
        csr[i] = get_score(true)
    end
    for i = 1, #csr do
        if csr[i] > c_s then
            c_s = csr[i]
            quickload(rebuildsl[i])
        end
    end
    p("+", c_s - cs0, "+")
    for i = 1, #rebuildsl do
        ReleaseSaveSlot(rebuildsl[i])
    end
    ReleaseSaveSlot(rebuild1)
    if c_s < cs0 then
        quickload(overall)
    else
        quicksave(overall)
    end
end

--#Mutate function Version = "1.0.1.128"
function mutate()
    if b_m_new == true then
        select(mutable)
        for i = 1, #amino do
            p("Mutating segment ", seg)
            sl_mut = RequestSaveSlot()
            quicksave(sl_mut)
            replace_aa(amino[i][1])
            fgain()
            repeat
            mut_1 = get_score(true)
            do_mutate(1)
            fgain()
            until get_score(true) - mut_1 < 0.01
            if get_score(true) > c_s then
                c_s = get_score(true)
                quicksave(overall)
            end
            quickload(sl_mut)
        end
    end
    if b_mutate == true then
        local _r = r
        r = nil
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
                    fuze(sl_mut)
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
        r = _r
    end
end

function all()
    overall = RequestSaveSlot()
    quicksave(overall)
    mutable = FindMutable()
    for i = start_seg, end_seg do
        seg = i
        r = nil
        c_s = get_score(true)
        mutate()
        --_snap(seg)
        for ii = 0, 4 do
            r = i + ii
            if r > numsegs then r = numsegs end
            p(Version)
            p(seg, "-", r)
            --_rebuild()
            gd("wl")
            gd("wb")
            gd("ws")
            gd("wa")
        end
    end
    if bfuze == true then
        fuze(sl)
    end
    quickload(overall)
    p("Overall Gain ", get_score(true) - s0)    
end

all()