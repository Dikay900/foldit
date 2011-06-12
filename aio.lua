--[[#Header
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions and ideas goes to Rav3n_pl, Tlaloc and Gary Forbis
Special thanks goes to Seagat
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
Version = "1150"
Release = false             -- if true this script is probably safe ;)
numsegs = get_segment_count()
--Game vars#

--#Settings: default
--#Working                  default     description
i_maxiter       = 5         -- 5        max. iterations an action will do | use higher number for a better gain but script needs a longer time
i_start_seg     = 1         -- 1        the first segment to work with
i_end_seg       = numsegs   -- numsegs  the last segment to work with
i_start_walk    = 0         -- 0        with how many segs shall we work - Walker
i_end_walk      = 4         -- 4        starting at the current seg + i_start_walk to seg + i_end_walk
b_lws           = false     -- false    do local wiggle and rewiggle
b_rebuild       = false     -- false    rebuild | see #Rebuilding
b_pp            = false     -- false    pull hydrophobic amino acids in different modes then fuze | see #Pull
b_str_re        = true     -- false    rebuild the protein based on the secondary structures | see #Structed rebuilding
b_cu            = false     -- false    Do bond the structures and curl it, try to improve it and get some points
b_snap          = false     -- false    should we snap every sidechain to different positions
b_fuze          = false     -- false    should we fuze | see #Fuzing
b_mutate        = false     -- false    it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
b_predict       = false     -- false    reset and predict then the secondary structure based on the amino acids of the protein
b_sphered       = false     -- false    work with a sphere always, can be used on lws and rebuilding walker
b_explore       = false     -- false    if true then the overall score will be taken if a exploration puzzle, if false then just the stability score is used for the methods
--Working#

--#Scoring | adjust a lower value to get the lws script working on high evo- / solos, higher values are probably better rebuilding the protein
i_score_step    = 0.01      -- 0.01    an action tries to get this score, then it will repeat itself
i_score_gain    = 0.01      -- 0.01    Score will get applied after the score changed this value
--Scoring#

--#Mutating
b_m_new         = false     -- false    Will change _ALL_ mutatable, then wiggles out and then mutate again, could get some points for solo, at high evos it's not recommend
b_m_fuze        = false      -- true     fuze a change or just wiggling out (could get some more points but recipe needs longer)
b_m_fast        = false     -- false    will just change every seg to every mut without wiggling and see if there is a gain
b_m_through     = false
b_m_wiggle      = true
b_m_testall     = false
b_m_after       = true
i_m_cl_mut      = 1
i_m_cl_wig      = 0.7
--Mutating#

--#Pull
b_comp          = false     -- false    try a pull of the two segments which have the biggest distance in between
i_pp_trys       = 1         -- 1        how often should the pull start over?
i_pp_loss       = 5         -- 1        the score / 100 * i_pp_loss is the general formula for calculating the points we must lose till we fuze
b_pp_local      = false     -- false
b_pp_mutate     = false
b_solo_quake    = false     -- false    just one seg is used on every method and all segs are tested
b_pp_pre_strong = true      -- true     bands are created which pull segs together based on the size, charge and isoelectric point of the amino acids
b_pp_pre_local  = false     -- false
b_pp_pull       = true      -- true     hydrophobic segs are pulled together
b_pp_push       = true      -- true
i_pp_bandperc   = 0.04      -- 0.04
i_pp_expand     = 2         -- 2
b_pp_fixed      = false     -- false
i_pp_fix_start  = 0         -- 0
i_pp_fix_end    = 0         -- 0
b_pp_centerpull = true      -- true     hydrophobic segs are pulled to the center segment
b_pp_centerpush = true      -- true
b_pp_soft       = false
i_pp_soft_len   = 1.75
--Pull

--#Fuzing
b_fast_fuze     = false     -- false    not qstab is used here, a part of the Pink fuze which just loosen up the prot a bit and then wiggle it (faster than qstab, recommend for evo work where the protein is a bit stiff)
b_fuze_bf       = false     -- false    Bluefuse only!!! Only recommended at mutating puzzles
b_fuze_mut      = false
--Fuzing#

--#Snapping
--Snapping#

--#Rebuilding
--b_worst_rebuild = false     -- false    rebuild worst scored parts of the protein | NOT READY YET
i_max_rebuilds  = 2         -- 2        max rebuilds till best rebuild will be chosen 
i_rebuild_str   = 1         -- 1        the iterations a rebuild will do at default, automatically increased if no change in score
b_re_mutate     = true
--Rebuilding#

--#Predicting
b_predict_full  = true     -- try to detect the secondary structure between every segment, there can be less loops but the protein become impossible to rebuild
b_pre_add_pref  = true
b_pre_combine_structs = false
--Predicting#

--#Curler
b_cu_sh         = true      -- true
b_cu_he         = true      -- true
--Curler#

--#Structed rebuilding      default     description
i_str_re_max_re = 2         -- 2        same as i_max_rebuilds at #Rebuilding
i_str_re_re_str = 1         -- 1        same as i_rebuild_str at #Rebuilding
b_re_he         = true      -- true     should we rebuild helices
b_re_sh         = true      -- true     should we rebuild sheets
b_str_re_fuze   = false     -- false    should we fuze after one rebuild
--Structed rebuilding#
--Settings#

--#Constants | Game vars
sls         = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
rebuilding  = false
snapping    = false
b_mutating  = false
sc_changed  = true
--Constants | Game vars#

--#Securing for changes that will be made at Fold.it
assert  = nil
error   = nil
debug   = nil
math    = nil
table   = nil
--Securing#

--#Optimizing
p   = print

reset =
{   -- renaming
    best    = restore_abs_best,
    score   = reset_recent_best,
    recent  = restore_recent_best,
    puzzle  = reset_puzzle
}

band =
{   -- renaming
    add         = band_add_segment_segment,
    length      = band_set_length,
    strength    = band_set_strength,
    disable     = band_disable,
    enable      = band_enable,
    delete      = band_delete
}

wiggle =
{   -- renaming
    _local      = do_local_wiggle,
    all         = do_global_wiggle_all,
    sidechains  = do_global_wiggle_sidechains,
    backbone    = do_global_wiggle_backbone
}

deselect =
{   -- renaming
    index   = deselect_index,
    all     = deselect_all
}

set =
{   -- renaming
    cl  = set_behavior_clash_importance,
    ss  = replace_ss,
    aa  = replace_aa
}

score =
{   -- renaming
    stab    = get_score,
    rank    = get_ranked_score,
    expl    = get_exploration_score,
    seg     = get_segment_score,
    segp    = get_segment_score_part
}
--Optimizing#

--#Debug
local function _assert(b, m)
    if not b then
        p(m)
        error()
    end -- if
end -- function

debug =
{   assert  = _assert
}
--Debug#

--#Amino
local function _short(seg)
    return amino.table[aa[seg]][amino.part.short]
end

local function _abbrev(seg)
    return amino.table[aa[seg]][amino.part.abbrev]
end

local function _long(seg)
    return amino.table[aa[seg]][amino.part.longname]
end

local function _h(seg)
    return amino.table[aa[seg]][amino.part.hydro]
end

local function _hscale(seg)
    return amino.table[aa[seg]][amino.part.scale]
end

local function _pref(seg)
    return amino.table[aa[seg]][amino.part.pref]
end

local function _mol(seg)
    return amino.table[aa[seg]][amino.part.mol]
end

local function _pl(seg)
    return amino.table[aa[seg]][amino.part.pl]
end

local function _vdw_radius(seg)
    return (amino.table[aa[seg]][amino.part.vdw_vol] * 3 / 4 / 3.14159) ^ (1 / 3)
end

amino =
{   short       = _short,
    abbrev      = _abbrev,
    long        = _long,
    hydro       = _h,
    hydroscale  = _hscale,
    preffered   = _pref,
    size        = _mol,
    charge      = _pl,
    vdw_radius  = _vdw_radius,
    part        = {short = 0, abbrev = 1, longname = 2, hydro = 3, scale = 4, pref = 5, mol = 6, pl = 7, vdw_vol = 8},
    segs        = {'a', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'y'},
    table       = {
  -- short, {abbrev,longname,           hydrophobic,scale,  pref,   mol,        pl,     vdw }
    ['a'] = {'Ala', 'Alanine',          true,       -1.6,   'H',    89.09404,   6.01,   67  },
    ['c'] = {'Cys', 'Cysteine',         true,       -17,    'E',    121.15404,  5.05,   86  },
    ['d'] = {'Asp', 'Aspartic acid',    false,      6.7,    'L',    133.10384,  2.85,   91  },
    ['e'] = {'Glu', 'Glutamic acid',    false,      8.1,    'H',    147.13074,  3.15,   109 },
    ['f'] = {'Phe', 'Phenylalanine',    true,       -6.3,   'E',    165.19184,  5.49,   135 },
    ['g'] = {'Gly', 'Glycine',          true,       1.7,    'L',    75.06714,   6.06,   48  },
    ['h'] = {'His', 'Histidine',        false,      -5.6,   nil,    155.15634,  7.60,   118 },
    ['i'] = {'Ile', 'Isoleucine',       true,       -2.4,   'E',    131.17464,  6.05,   124 },
    ['k'] = {'Lys', 'Lysine',           false,      6.5,    'H',    146.18934,  9.60,   135 },
    ['l'] = {'Leu', 'Leucine',          true,       1,      'H',    131.17464,  6.01,   124 },
    ['m'] = {'Met', 'Methionine',       true,       3.4,    'H',    149.20784,  5.74,   124 },
    ['n'] = {'Asn', 'Asparagine',       false,      8.9,    'L',    132.11904,  5.41,   96  },
    ['p'] = {'Pro', 'Proline',          true,       -0.2,   'L',    115.13194,  6.30,   90  },
    ['q'] = {'Gln', 'Glutamine',        false,      9.7,    'H',    146.14594,  5.65,   114 },
    ['r'] = {'Arg', 'Arginine',         false,      9.8,    'H',    174.20274,  10.76,  148 },
    ['s'] = {'Ser', 'Serine',           false,      3.7,    'L',    105.09344,  5.68,   73  },
    ['t'] = {'Thr', 'Threonine',        false,      2.7,    'E',    119.12034,  5.60,   93  },
    ['v'] = {'Val', 'Valine',           true,       -2.9,   'E',    117.14784,  6.00,   105 },
    ['w'] = {'Trp', 'Tryptophan',       true,       -9.1,   'E',    204.22844,  5.89,   163 },
    ['y'] = {'Tyr', 'Tyrosine',         true,       -5.1,   'E',    181.19124,  5.64,   141 }
    }
}

--#Calculations
local function _HCI(a, b) -- hydropathy
    return 20 - math.abs((amino.hydroscale(a) - amino.hydroscale(b)) * 19 / 10.6)
end

local function _SCI(a, b) -- size
    return 20 - math.abs((amino.size(a) + amino.size(b) - 123) * 19 / 135)
end

local function _CCI(a, b) -- charge
    return 11 - (amino.charge(a) - 7) * (amino.charge(b) - 7) * 19 / 33.8
end

local function _calc()
    p("Calculating Scoring Matrix")
    local hci_table = {}
    local cci_table = {}
    local sci_table = {}
    for i = 1, #amino.segs do
        hci_table[amino.segs[i]] = {}
        cci_table[amino.segs[i]] = {}
        sci_table[amino.segs[i]] = {}
        for ii = 1, #amino.segs do
            hci_table[amino.segs[i]][amino.segs[ii]] = calc.hci(i, ii)
            cci_table[amino.segs[i]][amino.segs[ii]] = calc.cci(i, ii)
            sci_table[amino.segs[i]][amino.segs[ii]] = calc.sci(i, ii)
        end -- for ii
    end -- for i
    p("Getting Segment Score out of the Matrix")
    strength = {}
    for i = 1, numsegs do
        strength[i] = {}
        for ii = i + 2, numsegs - 2 do
            strength[i][ii] = (hci_table[aa[i]][aa[ii]] * 2) + (cci_table[aa[i]][aa[ii]] * 1.26 * 1.065) + (sci_table[aa[i]][aa[ii]])
        end  -- for ii
    end -- for i
end -- function

calc =
{   hci = _HCI,
    sci = _SCI,
    cci = _CCI,
    run = _calc
}
--Calculations#
--Amino#

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

local function _floor(value, _n)
    local n
    if _n then
        n = 1 * 10 ^ (-_n)
    else -- if
        n = 1
    end -- if
    return value - (value % n)
end -- function

local function _randomseed(x)
    if x then
        lngX = x
    end -- if
end -- function

local function _random(m, n)
    if not n and m then
        n = m
        m = 1
    end -- if n
    if not m and not n then
        return _MWC() / 4294967296
    else -- if m
        if n < m then
            n, m = m, n
        end -- if n < m
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

--#Saveslot manager
local function _release(slot)
    sls[#sls + 1] = slot
end -- function

local function _request()
    debug.assert(#sls > 0, "Out of save slots")
    local slot = sls[#sls]
    sls[#sls] = nil
    return slot
end -- function

sl =
{   release = _release,
    request = _request,
    -- renaming
    save    = quicksave,
    load    = quickload
}
--Saveslot manager#
--External functions#

--#Internal functions
--#Getters
local function _dists()
    distances = {}
    for i = 1, numsegs - 1 do
        distances[i] = {}
        for j = i + 1, numsegs do
            distances[i][j] = get.distance(i, j)
            if distances[i][j] > 20 then
                distances[i][j] = 20
            end
        end -- for j
    end -- for i
end -- function

local function _sphere(seg, radius)
    local sphere = {}
    for i = 1, numsegs do
        if get.distance(seg, i) <= radius then
            sphere[#sphere + 1] = i
        end -- if get_
    end -- for i
    return sphere
end -- function

local function _center()
    local minDistance = 10000
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

local function _segs(_local)
    if _local then
        start = seg
        _end = r
    else -- if
        start = i_start_seg
        _end = i_end_seg
    end -- if
end -- function

local function _increase(sc1, sc2, slot, step)
    if step then
        if sc2 - sc1 < step then
            sl.load(slot)
            return
        else
            sc_changed = true
        end
    end
    if sc2 > sc1 then
        sl.save(slot)
        p("+", sc2 - sc1, "+")
        local sc = get.score()
        p("==", sc, "==")
    else -- if
        sl.load(slot)
    end -- if
end

local function _mutable()
    reset.score()
    mutable = {}
    local isA = {}
    local i
    local j
    select.all()
    set.aa("a")
    get.aacid()
    for i = 1, numsegs do
        if aa[i] == "a" then
            isA[#isA + 1] = i
        end -- if aa
    end -- for i
    set.aa("g")
    get.aacid()
    for j = 1, #isA do
        i = isA[j]
        if aa[i] == "g" then
            mutable[#mutable + 1] = i
        end -- if aa
    end -- for j
    p(#mutable, " mutables found")
    if #mutable > 0 then
        b_mutable  = true
    end
    reset.recent()
    get.aacid()
    deselect.all()
end -- function

local function _score()
    local s = 0
    if b_explore then
        s = score.rank(true)
    else -- if
        s = score.stab(true)
    end -- if
    return s
end -- function

--#Hydrocheck
local function _hydro(s)
    if s then
        hydro[s] = get.hydrophobic(s)
    else -- if
        hydro = {}
        for i = 1, numsegs do
            hydro[i] = get.hydrophobic(i)
        end -- for i
    end -- if
end -- function
--Hydrocheck#

--#Ligand Check
local function _ligand()
    if get.ss(numsegs) == 'M' then
        numsegs = numsegs - 1
        if i_end_seg == numsegs + 1 then
            i_end_seg = numsegs
        end -- if i_end_seg
    end -- if get.ss
end -- function
--Ligand Check#

--#Structurecheck
local function _ss()
    ss = {}
    for i = 1, numsegs do
        ss[i] = get.ss(i)
    end -- for i
end -- function

local function _aa(s)
    if s then
        aa[s] = get.aa(s)
    else -- if
        aa = {}
        for i = 1, numsegs do
            aa[i] = get.aa(i)
        end -- for i
    end -- if
end -- function

local function _struct()
    get.secstr()
    p("Detecting structures of the protein")
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

local function _same(a, b)
    get.struct()
    local bool
    local a_s
    local b_s
    for i = 1, #he do
        for ii = he[i][1], he[i][#he[i]] do
            if a == ii then
                a_s = he[i][1]
            end
            if b == ii then
                b_s = he[i][1]
            end
            if a_s == b_s then
                p(a_s, b_s)
                p("true")
                return true
            end
        end
    end
    if not a_s and not b_s then
        for i = 1, #sh do
            for ii = sh[i][1], sh[i][#sh[i]] do
                if a == ii then
                    a_s = sh[i][1]
                end
                if b == ii then
                    b_s = sh[i][1]
                end
                if b_s == a_s then
                    return true
                end
            end
        end
    end
    return false
end -- function
--Structurecheck#

local function _void(a)
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

get =
{   dists       = _dists,
    sphere      = _sphere,
    center      = _center,
    segs        = _segs,
    increase    = _increase,
    mutated     = _mutable,
    score       = _score,
    secstr      = _ss,
    aacid       = _aa,
    ligand      = _ligand,
    hydro       = _hydro,
    struct      = _struct,
    same_struct = _same,
    voids       = _void,
    -- renaming
    distance    = get_segment_distance,
    ss          = get_ss,
    aa          = get_aa,
    segcount    = get_segment_count,
    bandcount   = get_band_count,
    hydrophobic = is_hydrophobic,
    snapcount   = get_sidechain_snap_count
}
--Getters#

--#Doers
local function _freeze(f)
    if f == "b" then
        do_freeze(true, false)
    elseif f == "s" then
        do_freeze(false, true)
    else -- if
        do_freeze(true, true)
    end -- if
end -- function

local function _mutate(mut, aa, more)
    local sc_mut1 = get.score()
    select.segs(false, mutable[mut])
    set.aa(amino.segs[aa])
    get.aacid()
    p(#amino.segs - aa, " Mutations left")
    p("Mutating seg ", mutable[mut], " to ", amino.long(mutable[mut]))
    if b_m_after then
        select.list(mutable)
        deselect_index(mutable[mut])
        for i = 1, #mutable do
            local temp = false
            if i ~= mut then
                if distances[mutable[i]][mutable[mut]] then
                    if distances[mutable[i]][mutable[mut]] > 10 then
                        temp = true
                    end
                elseif distances[mutable[mut]][mutable[i]] > 10 then
                    temp = true
                end
                if temp then
                    deselect_index(mutable[i])
                end
            end
        end
        set.cl(i_m_cl_mut)
        do_mutate(1)
        set.cl(1)
        select_index(mutable[mut])
        do_shake(2)
    end
    select.segs()
    if b_m_fuze then
        fuze.start(sl_mut)
    elseif b_m_wiggle then
        set.cl(i_m_cl_wig)
        work.flow("wb", true)
        work.flow("ws", true)
        work.flow("wa", true)
        set.cl(1)
        work.flow("wb", true)
        work.flow("ws", true)
        work.flow("wa", true)
    end
    local sc_mut2 = get.score()
    if not more then
        get.increase(sc_mut1, sc_mut2, overall)
    end
end -- function

local function _mut(i, more)
    for ii = 1, #amino.segs do
        do_.mutate(i, ii, more)
        if i + 1 < #mutable then
            do_.mut(i + 1, true)
        end
    end
end

do_ =
{   freeze      = _freeze,
    mutate      = _mutate,
    mut         = _mut,
    -- renaming
    shake       = do_shake,
    rebuild     = do_local_rebuild,
    snap        = do_sidechain_snap,
    unfreeze    = do_unfreeze_all
}
--Doers#

--#Fuzing
local function _loss(option, cl1, cl2)
    p("cl1 ", cl1, ", cl2 ", cl2)
    reset.score()
    if option == 1 then
        p("Wiggle Out cl1-wa-cl=1-wa-s-cl1-wa")
        work.step(false, "s", 1, cl1)
        work.step(false, "wa", 1, cl2)
        work.step(false, "wa", 2, 1)
        work.step(false, "s", 1, 1)
        work.step(false, "wa", 1, cl2)
        work.gain("wa", 1)
    elseif option == 2 then
        p("qStab cl1-s-cl2-wa-cl=1-s")
        work.step(false, "s", 1, cl1)
        work.step(false, "wa", 1, cl2)
        work.step(false, "s", 1, 1)
        work.gain("wa", 1)
        reset.recent()
    else
        p("Blue Fuse cl1-s; cl2-s; (cl1 - 0.02)-s")
        work.step(false, "s", 1, cl1)
        work.gain("wa", 1)
        reset.score()
        work.step(false, "s", 1, cl2)
        work.gain("wa", 1)
        reset.recent()
        work.step(false, "s", 1, cl1 - 0.02)
        work.gain("wa", 1)
    end -- if option
    reset.recent()
end -- function

local function _part(option, cl1, cl2)
    local s_f1 = get.score()
    fuze.loss(option, cl1, cl2)
    local s_f2 = get.score()
    get.increase(s_f1, s_f2, sl_f)
end -- function

local function _start(slot, fast)
    p("Fuzing")
    sl_f = sl.request()
    local s_f1 = get.score()
    sl.save(sl_f)
    if b_fuze_bf then
        repeat
            local qs1 = get.score()
            fuze.part(3, 0.05, 0.07)
            local qs2 = get.score()
        until qs2 - qs1 < i_score_step
    else
        fuze.part(1, 0.1, 0.6)
        if not b_fast_fuze and not fast then
            repeat
                local qs1 = get.score()
                fuze.part(3, 0.05, 0.07)
                fuze.part(2, 0.1, 0.4)
                local qs2 = get.score()
            until qs2 - qs1 < i_score_step
        end
    end
    sl.load(sl_f)
    local s_f2 = get.score()
    sl.release(sl_f)
    p("++ Fuzing gained ++")
    get.increase(s_f1, s_f2, slot)
end -- function

fuze =
{   loss    =   _loss,
    part    =   _part,
    start   =   _start
}
--Fuzing#

--#Universal select
local function _segs(sphered, start, _end, more)
    if not more then
        deselect.all()
    end -- if more
    if start then
        if sphered then
            local list1
            if _end then
                if start ~= _end then
                    list1 = get.sphere(_end, 12)
                    select.list(list1)
                end -- if ~= end
                if  start > _end then
                    start, _end = _end, start
                end -- if > end
                select.range(start, _end)
            end
            list1 = get.sphere(start, 12)
            select.list(list1)
        elseif _end and start ~= _end then
            if start > _end then
                start, _end = _end, start
            end -- if > end
            select.range(start, _end)
        else -- if sphered
            select.index(start)
        end -- if sphered
    else -- if start
        select.all()
    end -- if start
end -- function

local function _list(list)
    if list then
        for i = 1, #list do
            select.index(list[i])
        end -- for
    end -- if list
end -- function

select =
{   segs    = _segs,
    list    = _list,
    index   = select_index,
    range   = select_index_range,
    all     = select_all
}
--Universal select#

--#working
local function _gain(g, cl)
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = get.score()
            if iter <= i_maxiter then
                work.step(false, g, iter, cl)
            end -- if
            local s2_f = get.score()
        until s2_f - s1_f < i_score_step
        local s3_f = get.score()
        work.step(false, "s")
        if b_fuze_mut then
            select.all()
            do_mutate(1)
        end
        local s4_f = get.score()
    until s4_f - s3_f < i_score_step
end

local function _step(sphered, _g, iter, cl)
    if cl then
        set.cl(cl)
    end -- if
    if rebuilding and _g == "s" or snapping and _g == "s" or sphered then
        select.segs(true, seg, r)
    else -- if rebuilding
        select.segs()
    end -- if rebuilding
    if _g == "wa" then
        wiggle.all(iter)
    elseif _g == "s" then
        do_.shake(2)
    elseif _g == "wb" then
        wiggle.backbone(iter)
    elseif _g == "ws" then
        wiggle.sidechains(iter)
    elseif _g == "wl" then
        select.segs(false, seg, r)
        reset.score()
        for i = iter, iter + 5 do
            local s_s1 = get.score()
            wiggle._local(i)
            local s_s2 = get.score()
            if s_s2 < s_s1 then
                reset.recent()
                break
            end -- if >
        end -- for
    end -- if _g
end -- function

local function _flow(g, more)
    local ws_1 = get.score()
    local iter = 0
    if rebuilding then
        slot = sl_re
    elseif snapping then -- if
        slot = snapwork
    elseif b_mutating then -- if
        slot = sl_mut
    else
        slot = overall
    end -- if
    work_sl = sl.request()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            sl.save(work_sl)
        end -- if iter
        s1 = get.score()
        if iter < i_maxiter then
            if b_sphered then
                work.step(true, g, iter)
            else -- if b_sphered
                work.step(false, g, iter)
            end -- if b_sphered
        end -- <
        s2 = get.score()
    until s2 - s1 < (i_score_step * iter)
    if s2 < s1 then
        sl.load(work_sl)
    else -- if <
        s1 = s2
    end -- if <
    sl.release(work_sl)
    if not more then
        get.increase(ws_1, s1, slot, i_score_gain)
    end
    if s1 - ws_1 > i_score_gain then
        sc_changed = true
    end -- if
end -- function

function _quake(ii)
    local s3 = math.floor(get.score() / 50 * i_pp_loss, 4)
    if s3 < 0 then
        band.disable()
        fuze.start()
        band.enable()
        local s3 = math.floor(get.score() / 50 * i_pp_loss, 4)
    end
    local strength = 0.075 + 0.125 * i_pp_loss
    local bands = get.bandcount()
    local quake = sl.request()
    local quake2 = sl.request()
    if seg or r then
        select.segs(false, seg, r)
    else
        select.segs()
    end
    if b_solo_quake then
        band.disable()
        band.enable(ii)
        s3 = math.floor(s3 / bands * 10, 4)
        strength = math.floor(strength * bands / 4, 4)
    elseif b_pp_pre_local then
        s3 = math.floor(s3 / bands, 4)
        strength = math.floor(strength * bands / 8, 4)
    end -- if
    if b_cu then
        s3 = math.floor(s3 / 10, 4)
    end
    p("Pulling until a loss of more than ", s3, " points")
    sl.save(quake2)
    repeat
        sl.load(quake2)
        p("Band strength: ", strength)
        local s1 = get.score()
        if b_solo_quake then
            band.strength(ii, strength)
        else -- if b_solo
            for i = 1, bands do
                band.strength(i, strength)
            end -- for
        end -- if b_solo
        reset.score()
        set.cl(0.9)
        wiggle.backbone(1)
        sl.save(quake)
        reset.recent()
        local s2 = get.score()
        if s2 > s1 then
            reset.recent()
            sl.save(quake2)
        end -- if >
        sl.load(quake)
        local s2 = get.score()
        strength = math.floor(strength * 2 - strength * 10 / 11, 4)
        if b_pp_pre_local or b_cu or b_solo_quake then
            strength = math.floor(strength * 2 - strength * 6 / 7, 4)
        end -- if b_solo
        if strength > 10 then
            break
        end -- if strength
    until s1 - s2 > s3
    sl.release(quake)
    sl.release(quake2)
end -- function

local function _dist()
    p("Quaker")
    select.segs()
    local ps_1 = get.score()
    sl.save(overall)
    dist = sl.request()
    local bandcount = get.bandcount()
    if b_solo_quake then
        p("Solo quaking enabled")
        rebuilding = true
        for ii = 1, bandcount do
            ps_1 = get.score()
            sl.save(dist)
            work.quake(ii)
            if b_pp_mutate then
                select.all()
                do_mutate(1)
            end
            band.delete(ii)
            fuze.start(dist)
            ps_2 = get.score()
            get.increase(ps_1, ps_2, overall)
        end -- for ii
        rebuilding = false
    else -- if b_solo_quake
        sl.save(dist)
        work.quake()
        band.delete()
        fuze.start(dist)
        ps_2 = get.score()
        get.increase(ps_1, ps_2, overall)
    end -- if b_solo_quake
    sl.release(dist)
end -- function

local function _rebuild(trys, str)
    local iter = 1
    for i = 1, trys do
        p("Try ", i, "/", trys)
        local re1 = get.score()
        local re2 = re1
        while re1 == re2 do
            do_.rebuild(iter * str)
            if iter > i_maxiter then
                iter = i_maxiter
                return
            end -- if iter
            iter = iter + 1
            re2 = get.score()
        end -- while
        iter = 1
    end -- for i
end -- function

work =
{   gain    = _gain,
    step    = _step,
    flow    = _flow,
    quake   = _quake,
    dist    = _dist,
    rebuild = _rebuild
}
--Working#

--#Bonding
--#Center
local function _cpl(_local)
    local indexCenter = get.center()
    get.segs(_local)
    for i = start, _end do
        if i ~= indexCenter then
            local x = i
            local y = indexCenter
            if x > y then x, y = y, x end
            if hydro[i] then
                band.add(x, y)
                if b_pp_soft then
                    local cband = get.bandcount()
                    band.length(cband, distances[x][y] - i_pp_soft_len)
                end
            end -- if hydro
        end -- if ~=
    end -- for
end -- function

local function _cps(_local)
    local indexCenter = get.center()
    get.segs(_local)
    get.dists()
    for i = start, _end do
        if i ~= indexCenter then
            local x = i
            local y = indexCenter
            if x > y then x, y = y, x end
            if not hydro[i] then
                if distances[x][y] <= (20 - i_pp_expand) then
                    band.add(x, y)
                    local cband = get.bandcount()
                    band.length(cband, distances[x][y] + i_pp_expand)
                end
            end -- if hydro
        end -- if ~=
    end -- for
end -- function

local function _ps(_local, bandsp)
    get.segs(_local)
    get.dists()
    for x = start, _end - 2 do
        if not hydro[x] then
            for y = x + 2, _end do
                math.randomseed(distances[x][y])
                if not hydro[y] and math.random() <= bandsp then
                    if distances[x][y] <= (20 - i_pp_expand) then
                        band.add(x, y)
                        local cband = get.bandcount()
                        band.length(cband, distances[x][y] + i_pp_expand)
                    end
                end
            end
        end
    end
end
--Center#

--#Pull
local function _pl(_local, bandsp)
    get.segs(_local)
    get.dists()
    if b_pp_fixed then
        for x = start, _end do
            if hydro[x] then
                for y = i_pp_fix_start, i_pp_fix_end do
                    math.randomseed(distances[x][y])
                    if hydro[y] and math.random() < bandsp * 4 then
                        band.add(x, y)
                        if b_pp_soft then
                            local cband = get.bandcount()
                            band.length(cband, distances[x][y] - i_pp_soft_len)
                        end
                    end
                end
            end
        end
    end -- if b_pp_fixed
    for x = start, _end - 2 do
        if hydro[x] then
            for y = x + 2, numsegs do
                math.randomseed(distances[x][y])
                if hydro[y] and math.random() < bandsp then
                    band.add(x, y)
                    if b_pp_soft then
                        local cband = get.bandcount()
                        band.length(cband, distances[x][y] - i_pp_soft_len)
                    end
                end -- hydro y
            end -- for y
        end -- if hydro x
    end -- for x
end -- function
--Pull#

--#BandMaxDist
local function _maxdist(_local)
    get.segs(_local)
    get.dists()
    local maxdistance = 0
    for i = start, _end do
        for j = start, _end do
            if i ~= j then
                local x = i
                local y = j
                if x > y then
                    x, y = y, x
                end -- >
                if distances[x][y] > maxdistance then
                    maxdistance = distances[x][y]
                    maxx = i
                    maxy = j
                end -- if distances
            end -- if ~=
        end -- for j
    end -- for i
    band.add(maxx, maxy)
    if b_pp_soft then
        local cband = get.bandcount()
        band.length(cband, distances[i][ii] - i_pp_soft_len)
    end
end -- function
--BandMaxDist#

local function _strong(_local)
    get.dists()
    get.segs(_local)
    for i = start, _end do
        local max_str = 0
        local min_dist = 999
        for ii = i + 2, numsegs - 2 do
            if max_str <= strength[i][ii] then
                if max_str ~= strength[i][ii] then
                    min_dist = 999
                end -- if max_str ~=
                max_str = strength[i][ii]
                if min_dist > distances[i][ii] then
                    min_dist = distances[i][ii]
                end -- if min_dist
            end -- if max_str <=
        end -- for ii
        for ii = i + 2, numsegs - 2 do
            if strength[i][ii] == max_str and min_dist == distances[i][ii] then
                band.add(i , ii)
                if b_pp_soft then
                    local cband = get.bandcount()
                    band.length(cband, distances[i][ii] - i_pp_soft_len)
                end
            end -- if strength
        end -- for ii
    end -- for i
end -- function

local function _one(_seg)
    get.dists()
    for i = 1, numsegs do
        if _seg == i then
        local max_str = 0
        for ii = i + 2, numsegs - 2 do
            if max_str <= strength[i][ii] then
                max_str = strength[i][ii]
            end -- if max_str <=
        end -- for ii
        for ii = i + 2, numsegs - 2 do
            if strength[i][ii] == max_str then
                band.add(i , ii)
                if b_pp_soft then
                    local cband = get.bandcount()
                    band.length(cband, distances[i][ii] - i_pp_soft_len)
                end
            end -- if strength
        end -- for ii
        end
    end -- for i
end -- function

local function _helix(_he)
    if _he then
        for ii = he[_he][1], he[_he][#he[_he]] - 4 do
            band.add(ii, ii + 4)
        end -- for ii
    else
        for i = 1, #he do
        for ii = he[i][1], he[i][#he[i]] - 4 do
            band.add(ii, ii + 4)
        end -- for ii
    end -- for i
    end
end -- function

local function _sheet(_sh)
    if _sh then
        for ii = 1, #sh[_sh] - 1 do
            band.add(sh[_sh][ii] - 1, sh[_sh][ii] + 2)
            local cbands = get.bandcount()
            band.strength(cbands, 10)
            band.length(cbands, 20)
        end -- for ii
    else
        for i = 1, #sh do
        for ii = 1, #sh[i] - 1 do
            band.add(sh[i][ii] - 1, sh[i][ii] + 2)
            local cbands = get.bandcount()
            band.strength(cbands, 10)
            band.length(cbands, 20)
        end -- for ii
    end -- for i
    end
end -- function

local function _comp_sheet()
    for i = 1, #sh - 1 do
        band.add(sh[i][1], sh[i + 1][#sh[i + 1]])
        local cbands = get.bandcount()
        band.strength(cbands, 10)
        band.add(sh[i][#sh[i]], sh[i + 1][1])
        local cbands = get.bandcount()
        band.strength(cbands, 10)
    end -- for i
end -- function

local function _rndband()
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

bonding =
{   centerpull  = _cpl,
    centerpush  = _cps,
    push        = _ps,
    pull        = _pl,
    maxdist     = _maxdist,
    helix       = _helix,
    sheet       = _sheet,
    comp_sheet  = _comp_sheet,
    rnd         = _rndband,
    matrix      =
    {   strong  = _strong,
        one     = _one
    }
}
--Bonding#
--Header#

--#Snapping
function snap()
    snapping = true
    snaps = sl.request()
    cs = get.score()
    c_snap = get.score()
    local s_1
    local s_2
    local c_s
    local c_s2
    sl.save(snaps)
    iii = get.snapcount(seg)
    p("Snapcount: ", iii, " - Segment ", seg)
    if iii > 1 then
        snapwork = sl.request()
        ii = 0
        while ii < iii do
            sl.load(snaps)
            c_s = get.score()
            c_s2 = get.score()
            while c_s2 == c_s do
                ii = ii + 1
                p("Snap ", ii, "/ ", iii)
                do_.snap(seg, ii)
                c_s2 = get.score()
                p(c_s2 - c_s)
                if ii > iii then
                    break
                end
            end
            if ii > iii then
                break
            end
            if c_s - c_s2 > 1 then
            sl.save(snapwork)
            select.segs(false, seg)
            do_.freeze("s")
            fuze.start(snapwork)
            do_.unfreeze()
            work.gain("wa")
            sl.save(snapwork)
            if c_snap < get.score() then
                c_snap = get.score()
            end
            end
        end
        sl.load(snapwork)
        sl.release(snapwork)
        if cs < c_snap then
            sl.save(snaps)
            c_snap = get.score()
        else
            sl.load(snaps)
        end
    else
        p("Skipping...")
    end
    snapping = false
    sl.release(snaps)
    if mutated then
        s_snap = get.score()
        if s_mut < s_snap then
            sl.save(overall)
        else
            sl.load(sl_mut)
        end
    else
        sl.save(overall)
    end
end
--Snapping#

--#Rebuilding
function rebuild()
    local iter = 1
    rebuilding = true
    sl_re = sl.request()
    sl.load(overall)
    select.segs()
    replace_ss("L")
    sl.save(overall)
    sl.save(sl_re)
    select.segs(false, seg, r)
    if r == seg then
        p("Rebuilding Segment ", seg)
    else -- if r
        p("Rebuilding Segment ", seg, "-", r)
    end -- if r
    rs_0 = get.score()
    work.rebuild(i_max_rebuilds, i_rebuild_str)
    set.cl(1)
    rs_1 = get.score()
    if b_re_mutate then
        select.all()
        do_mutate(1)
    end
    p(rs_1 - rs_0)
    fuze.start(sl_re)
    rs_2 = get.score()
    sl.release(sl_re)
    get.increase(rs_0, rs_2, overall)
    rebuilding = false
end -- function
--Rebuilding#

--#Pull
function dists()
    sl.save(overall)
    dist_score = get.score()
    if b_comp then
        band.delete()
        bonding.maxdist()
        work.dist()
    end -- if b_comp
    band.delete()
    if b_pp_pre_strong then
        bonding.matrix.strong()
        work.dist()
        band.delete()
    end -- if b_pp_predicted
    if b_pp_pre_local then
        for i = i_start_seg, i_end_seg do
            bonding.matrix.one(i)
            work.dist()
            band.delete()
        end
    end -- if b_pp_predicted
    if b_pp_pull then
        bonding.pull(b_pp_local, i_pp_bandperc)
        work.dist()
        band.delete()
    end -- if b_pp_pull
    if b_pp_push then
        bonding.push(b_pp_local, i_pp_bandperc * 2)
        work.dist()
        band.delete()
    end -- if b_pp_push
    if b_pp_centerpull then
        bonding.centerpull(b_pp_local)
        work.dist()
        band.delete()
    end -- if b_pp_centerpull
    if b_pp_centerpush then
        bonding.centerpush(b_pp_local)
        work.dist()
        band.delete()
    end -- if b_pp_centerpull
end -- function
--Pull#

--#Predict ss
local function _getdata()
    local p_he = {}
    local p_sh = {}
    local helix
    local sheet
    local loop
    local i = 1
    local ui
    while i < numsegs do
        ui = i
        loop = false
        if hydro[i] then
            if hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if aa[i] ~= "p" then
                    if not helix then
                    helix = true
                    p_he[#p_he + 1] = {}
                    end
                else
                    loop = true
                    helix = false
                end -- if helix
            elseif not hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] then
                if not sheet then
                    sheet = true
                    p_sh[#p_sh + 1] = {}
                end -- if sheet
            else -- hydro i +
                loop = true
            end -- hydro i +
        elseif not hydro[i] then
            if hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and hydro[i + 2] and hydro[i + 3] then
                if aa[i] ~= "p" then
                    if not helix then
                    helix = true
                    p_he[#p_he + 1] = {}
                    end
                else
                    loop = true
                    helix = false
                end -- if helix
            elseif hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if not sheet then
                    sheet = true
                    p_sh[#p_sh + 1] = {}
                end -- if sheet
            else -- if hydro +
                loop = true
            end -- if hydro +
        end -- hydro[i]
        if helix then
            p_he[#p_he][#p_he[#p_he] + 1] = i
            if loop or sheet then
                helix = false
                if i + 1 < numsegs then
                    if aa[i + 1] ~= "p" then
                        p_he[#p_he][#p_he[#p_he] + 1] = i + 1
                        if i + 2 < numsegs then
                            if aa[i + 2] ~= "p" then
                                p_he[#p_he][#p_he[#p_he] + 1] = i + 2
                                i = i + 1
                            end -- if aa i + 2
                        end -- if i + 2
                        i = i + 1
                    end -- if aa i + 1
                end -- if i + 1
                ui = i
                i = i + 2
            end -- if loop | sheet
        elseif sheet then
            p_sh[#p_sh][#p_sh[#p_sh] + 1] = i
            if loop then
                sheet = false
                if i + 1 < numsegs then
                    p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 1
                end -- if i + 1
                if i + 2 < numsegs then
                    p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 2
                end -- if i + 2
                ui = i + 2
                i = i + 4
            end -- if loop
        end -- if sheet
        if b_predict_full then
            i = ui + 1
        else -- if b_predict_full
            i = i + 1
        end -- if b_predict_full    
    end -- while
    p("Found ", #p_he, " Helix and ", #p_sh, " Sheet parts... Combining...")
    select.segs()
    set.ss("L")
    deselect.all()
    for i = 1, #p_he do
        select.list(p_he[i])
    end -- for
    set.ss("H")
    deselect.all()
    for i = 1, #p_sh do
        select.list(p_sh[i])
    end -- for
    set.ss("E")
    sl.save(overall)
    predict.combine()
end

local function _combine()
    for i = 1, numsegs - 1 do
        get.struct()
        deselect.all()
        if ss[i] == "L" then
            if aa[i] ~= "p" then
                for ii = 1, #he - 1 do
                    if b_pre_combine_structs then
                        for iii = he[ii][1], he[ii][#he[ii]] do
                            if iii + 1 == i and he[ii + 1][1] == i + 1 then
                                select.index(i)
                            end -- if iii
                        end -- for iii
                    end -- if b_pre
                end
                for ii = 1, #he do
                    if b_pre_add_pref then
                        for iii = he[ii][1] - 1, he[ii][#he[ii]] + 1, he[ii][#he[ii]] - he[ii][1] + 1 do
                            if amino.preffered(iii) == "H" then
                                select.index(iii)
                            end -- if iii
                        end -- for iii
                    end -- if b_pre
                end -- for ii
                set.ss("H")
                deselect.all()
            end -- if aa
            if b_pre_combine_structs then
                for ii = 1, #sh - 1 do
                    for iii = sh[ii][1], sh[ii][#sh[ii]] do
                        if iii + 1 == i and sh[ii + 1][1] == i + 1 then
                            select.index(i)
                        end -- if iii
                    end -- for iii
                end -- for ii
            end -- if b_pre
            if b_pre_add_pref then
                for ii = 1, #sh do
                    for iii = sh[ii][1] - 1, sh[ii][#sh[ii]] + 1, sh[ii][#sh[ii]] - sh[ii][1] + 1 do
                        if amino.preffered(iii) == "E" then
                            select.index(iii)
                        end -- if iii
                    end -- for iii
                end -- for ii
            end -- if b_pre
            set.ss("E")
        end -- if ss
    end -- for i
end

predict =
{   getdata = _getdata,
    combine = _combine
}
--predictss#

function struct_curler()
    str_re_best = sl.request()
    get.struct()
    p("Found ", #he, " Helixes ", #sh, " Sheets and ", #lo, " Loops")
    if b_cu_he then
        for i = 1, #he do
            p("Working on Helix ", i)
            seg = he[i][1]
            r = he[i][#he[i]]
            deselect.all()
            select.segs(false, seg, r)
            bonding.helix(i)
            work.dist()
            band.delete()
            sl.save(str_re_best)
            rebuilding = true
            fuze.start(str_re_best)
            sl.load(str_re_best)
            rebuilding = false
        end -- for i
    end -- if b_cu_he
    if b_cu_sh then
        for i = 1, #sh do
            p("Working on Sheet ", i)
            seg = sh[i][1]
            r = sh[i][#sh[i]]
            bonding.sheet(i)
            select.segs(false, seg, r)
            work.dist()
            band.delete()
            sl.save(str_re_best)
            rebuilding = true
            fuze.start(str_re_best)
            sl.load(str_re_best)
            rebuilding = false
        end -- for i
    end -- if b_cu_sh
    sl.release(str_re_best)
    sl.save(overall)   
end

function struct_rebuild()
    local str_rs
    local str_rs2
    str_re_best = sl.request()
    get.struct()
    p("Found ", #he, " Helixes ", #sh, " Sheets and ", #lo, " Loops")
    if b_re_he then
        deselect.all()
        for i = 1, #sh do
            select.list(sh[i])
        end -- for i
        set.ss("L")
        for i = 1, #he do
            p("Working on Helix ", i)
            seg = he[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = he[i][#he[i]] + 2
            if r > numsegs then
                r = numsegs
            end -- if r
            bonding.helix()
            deselect.all()
            select.range(seg, r)
            set.cl(0.4)
            wiggle.backbone(1)
            seg = he[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = he[i][#he[i]] + 2
            if r > numsegs then
                r = numsegs
            end -- if r
            select.range(seg, r)
            set.cl(0)
            work.rebuild(i_str_re_max_re, i_str_re_re_str)
            set.cl(1)
            work.rebuild(i_str_re_max_re, i_str_re_re_str)
            seg = he[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = he[i][#he[i]] + 2
            if r > numsegs then
                r = numsegs
            end -- if r
            band.delete()
            if b_str_re_fuze then
                rebuilding = true
                fuze.start(str_re_best)
                sl.load(str_re_best)
                rebuilding = false
            end -- if b_str_re_fuze
            str_sc = nil
            str_rs = nil
        end -- for i
        deselect.all()
        for i = 1, #sh do
            select.list(sh[i])
        end -- for i
        set.ss("E")
    end -- if b_re_he
    if b_re_sh then
        deselect.all()
        for i = 1, #he do
            select.list(he[i])
        end -- for i
        set.ss("L")
        for i = 1, #sh do
            p("Working on Sheet ", i)
            seg = sh[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = sh[i][#sh[i]] + 2
            if r > numsegs then
                r = numsegs
            end -- if r
            bonding.sheet(i)
            deselect.all()
            select.range(seg, r)
            set.cl(0.4)
            wiggle.backbone(1)
            band.delete()
            if b_str_re_fuze then
                rebuilding = true
                fuze.start(str_re_best)
                sl.load(str_re_best)
                rebuilding = false
            end -- if b_str_re_fuze
        end -- for i
        deselect.all()
        for i = 1, #he do
            select.list(he[i])
        end -- for i
        set.ss("H")
        bonding.comp_sheet()
    end -- if b_re_sh
    sl.save(overall)
    sl.release(str_re_best)
end

--#Mutate function
function mutate()
    b_mutating = true
    local mut_1
    local i
    local ii
    get.dists()
    mutating = true
    if b_m_new then
        select.list(mutable)
        sc_mut = get.score()
        for i = 1, #amino.segs do
            sl_mut = sl.request()
            sl.save(sl_mut)
            set.aa(amino.segs[i])
            get.aacid()
            p(#amino.segs - i, " Mutations left")
            p("Mutating all segments to ", amino.long(mutable[1]))
            fuze.start(sl_mut, true)
            repeat
                repeat
                    mut_1 = get.score()
                    do_mutate(1)
                until get.score() - mut_1 < 0.01
                mut_1 = get.score()
                fuze.start(sl_mut, true)
            until get.score() - mut_1 < 0.01
            if get.score() > sc_mut then
                sc_mut = get.score()
                sl.save(overall)
            end
            sl.load(overall)
            sl.release(sl_mut)
        end
    end
    if b_m_through then
        sl_mut = sl.request()
        sl.save(sl_mut)
        for i = 1, #mutable do
            for ii = 1, #amino.segs do
                sl.load(sl_mut)
                do_.mutate(i, ii)
                for iii = 1, #mutable do
                    if iii ~= i then
                        for iiii = 1, #amino.segs do
                        do_.mutate(iii, iiii)
                        end
                    end
                end
            end
            sl.release(sl_mut)
        end
    end
    if b_m_testall then
    for i = 1, #mutable do
        p("Mutating segment ", i)
        sl.save(overall)
        sc_mut = get.score()
        for ii = i, #mutable do
            do_.mut(ii, true)
        end
        sl.load(overall)
    end
    end
    for i = 1, #mutable do
        p("Mutating segment ", i)
        sl.save(overall)
        sc_mut = get.score()
        for ii = 1, #amino.segs do
            do_.mutate(i, ii)
        end
        sl.load(overall)
    end
    b_mutating = false
end
--Mutate#

s_0 = get.score()
p("v", Version)
p("Starting Score: ", s_0)
overall = sl.request()
sl.save(overall)
get.ligand()
get.aacid()
get.hydro()
get.mutated()
if b_predict then
    predict.getdata()
end -- if b_predict
if b_str_re then
    struct_rebuild()
end -- if b_str_re
if b_cu then
    struct_curler()
end
if b_pp then
    for i = 1, i_pp_trys do
        if b_pp_pre_strong or b_pp_pre_local then
            calc.run()
        end
        dists()
    end -- for i
end -- if b_pp
if b_mutate then
    mutate()
end
for i = i_start_seg, i_end_seg do
    seg = i
    if b_snap then
        snap()
    end
    for ii = i_start_walk, i_end_walk do
        r = i + ii
        if r > numsegs then
            r = numsegs
            break
        end -- if r
        if b_rebuild then
            --[[if b_worst_rebuild then         NEW FUNCTION FOR WORST SEGMENT DETECT
                local worst = 1000
                for iii = 1, numsegs do
                    local s = get.seg_score(iii)
                    if s < worst then
                        seg = iii
                        worst = s
                    end -- if s
                end
                r = seg + ii
            end]]
            rebuild()
        end -- if b_rebuild
        if b_lws then
            p(seg, "-", r)
            work.flow("wl")
            if sc_changed then
                work.flow("wb")
                work.flow("ws")
                work.flow("wa")
                work.flow("s")
                sc_changed = false
            end -- if sc_changed
        end -- if b_lws
    end -- for ii
end -- for i
if b_fuze then
    fuze.start(overall)
end -- if b_fuze
sl.load(overall)
sl.release(overall)
s_1 = get.score()
p("+++ Overall gain +++")
p("+++", s_1 - s_0, "+++")