--[[
b_mutate        = false     -- false    it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
b_snap          = false     -- false    should we snap every sidechain to different positions
--#Mutating
b_m_new         = false     -- false    Will change _ALL_ mutatable, then wiggles out and then mutate again, could get some points for solo, at high evos it's not recommend
b_m_fuze        = true      -- true     fuze a change or just wiggling out (could get some more points but recipe needs longer)
--Mutating#
]]

--[[
snapping        = false
mutating        = false
]]

--#Compressor
function compress()
    p("Compressing Segment ", seg)
    sphere = {}
    range = 0
    repeat
        count = 0
        range = range + 2
        sphere = GetSphere(seg, range)
        for n = 1, #sphere - 1 do
            if sphere[n] > seg + range / 4 and sphere[n] + 1 ~= sphere[n + 1] or sphere[n] < seg - range / 4 and sphere[n] + 1 ~= sphere[n + 1] then
                count = count + 1
            end
        end
    until count > 4
    for n = 1, #sphere - 1 do
        if sphere[n] > seg + range / 4 and sphere[n] + 1 ~= sphere[n + 1] or sphere[n] < seg - range / 4 and sphere[n] + 1 ~= sphere[n + 1] then
            band_add_segment_segment(seg, sphere[n])
            local length = get_segment_distance(seg, sphere[n])
            repeat
                length = length * 7 / 8
            until length <= 5
            band_set_length(get_band_count(), length)
            band_set_strength(get_band_count(), length / 5)
        end
    end
    do_global_wiggle_backbone(1)
    band_delete()
    p("Compressing Segment ", seg, "-", r)
    sphere1 = {}
    sphere2 = {}
    range = 0
end
--Compressor#

--#Snapping
function snap(mutated)
    snapping = true
    snaps = RequestSaveSlot()
    c_snap = PuzzleScore(b_explore)
    cs = PuzzleScore(b_explore)
    quicksave(snaps)
    iii = get_sidechain_snap_count(seg)
    p("Snapcount: ", iii, " - Segment ", seg)
    if iii ~= 1 then
    snapwork = RequestSaveSlot()
        for ii = 1, iii do
            quickload(snaps)
            p("Snap ", ii, "/ ", iii)
            c_s = PuzzleScore(b_explore)
            select()
            do_sidechain_snap(seg, ii)
            p(PuzzleScore(b_explore) - c_s)
            c_s = PuzzleScore(b_explore)
            quicksave(snapwork)
            gd("s")
            gd("wa")
            gd("ws")
            gd("wb")
            gd("wl")
            if c_snap < PuzzleScore(b_explore) then
            c_snap = PuzzleScore(b_explore)
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
        s_snap = PuzzleScore(b_explore)
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

--#Mutate function
function mutate()
    mutating = true
    if b_mutate then
        if b_m_new then
            select(mutable)
            for i = 1, #amino do
                p("Mutating segment ", seg)
                sl_mut = RequestSaveSlot()
                quicksave(sl_mut)
                replace_aa(amino[i][1])
                fgain("wa")
                repeat
                    repeat
                        local mut_1 = PuzzleScore(b_explore)
                        do_mutate(1)
                    until PuzzleScore(b_explore) - mut_1 < 0.01
                    mut_1 = PuzzleScore(b_explore)
                    fgain("wa")
                until PuzzleScore(b_explore) - mut_1 < 0.01
                if PuzzleScore(b_explore) > c_s then
                    c_s = PuzzleScore(b_explore)
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
                    s_mut = PuzzleScore(b_explore)
                    p("Mutated: ", seg, " to ", amino[j][2], " - " , amino[j][3])
                    p(#amino - j, " mutations left...")
                    p(s_mut - c_s)
                    if b_m_fuze then
                        fuze(sl_mut)
                    else
                        set_behavior_clash_importance(0.1)
                        do_shake(1)
                        fgain("wa")
                    end
                    s_mut2 = PuzzleScore(b_explore)
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
                    s_mut2 = PuzzleScore(b_explore)
                end
            end
            ReleaseSaveSlot(sl_mut)
            quickload(overall)
        end
    end
    mutating = false
end
--Mutate#

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
        end -- if get_aa
    end -- for i
    replace_aa("q")                 -- all mutable segments are set to "q"
    for j = 1, #isG do
        i = isG[j]
        if get_aa(i) == "q" then    -- this segment is mutable
            mutable[#mutable + 1] = i
        end -- if get_aa
    end -- for j
    p(#mutable, " mutables found")
    quickload(mut)
    ReleaseSaveSlot(mut)
    deselect_all()
    return mutable
end -- function