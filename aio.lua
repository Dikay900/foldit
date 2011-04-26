--[[#Header
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions and ideas goes to Rav3n_pl, Tlaloc and Gary Forbis
Special thanks goes to Seagat2011
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
Version     = "1097"
Release     = false         -- if true this script is probably safe ;)
numsegs     = get_segment_count()
--Game vars#

--#Settings: default
--#Working                  default     description
i_maxiter       = 5         -- 5        max. iterations an action will do | use higher number for a better gain but script needs a longer time
i_start_seg     = 1         -- 1        the first segment to work with
i_end_seg       = numsegs   -- numsegs  the last segment to work with
i_start_walk    = 0         -- 0        with how many segs shall we work - Walker
i_end_walk      = 3         -- 3        starting at the current seg + i_start_walk to seg + i_end_walk
b_lws           = false     -- false    do local wiggle and rewiggle
b_rebuild       = false     -- false    rebuild | see #Rebuilding
--
b_pp            = false     -- false    pull hydrophobic sideshains in different modes together then fuze | see #Pull
b_fuze          = false     -- false    should we fuze | see #Fuzing
b_predict       = true
b_str_re        = true
b_sphered       = false
b_explore       = false     -- false    Exploration Puzzle
--Working#

--#Scoring | adjust a lower value to get the lws script working on high evo- / solos, higher values are probably better rebuilding the protein
i_score_step    = 0.01     -- 0.001    an action tries to get this score, then it will repeat itself
i_score_gain    = 0.01     -- 0.002    Score will get applied after the score changed this value
--Scoring#

--#Pull
b_comp          = false     -- false    try a pull of the two segments which have the biggest distance in between
i_pp_trys       = 1         -- 2        how often should the pull start over?
i_pp_loss       = 0.05
b_solo_quake    = true
--Pull

--#Fuzing
b_fuze_deep     = false     -- false    fuze till no gain is possible
b_fast_fuze     = false
--Fuzing#

--#Rebuilding
b_worst_rebuild = false     -- false    rebuild worst scored parts of the protein
i_max_rebuilds  = 2         -- 2        max rebuilds till best rebuild will be chosen 
i_rebuild_str   = 4         -- 1        the iterations a rebuild will do at default, automatically increased if no change in score
b_r_dist        = false     -- false    start pull see #Pull after a rebuild
--Rebuilding#

--#Structed rebuilding      default     description
i_str_re_max_re = 3         -- 2        same as i_max_rebuilds at #Rebuilding
i_str_re_re_str = 2         -- 2        same as i_rebuild_str at #Rebuilding
b_str_re_dist   = false     -- false    same as b_r_dist at #Rebuilding
b_re_he         = true      -- true     should we rebuild helices
b_re_sh         = true      -- true     should we rebuild sheets
b_str_re_fuze   = false      -- true     should we fuze after one rebuild
--Structed rebuilding#
--Settings#

--#Constants
saveSlots       = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
fuzing          = false
rebuilding      = false
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

local _get =
{   distance        = get_segment_distance,
    score           = get_score,
    expscore        = get_exploration_score,
    seg_score       = get_segment_score,
    seg_score_part  = get_segment_score_part,
    ss              = get_ss,
    aa              = get_aa,
    seg_count       = get_segment_count,
    band_count      = get_band_count,
    hydrophobic     = is_hydrophobic
}

local _reset =
{   best    = restore_abs_best,
    score   = reset_recent_best,
    recent  = restore_recent_best,
    puzzle  = reset_puzzle,
}

local _band =
{   add         = band_add_segment_segment,
    length      = band_set_length,
    strength    = band_set_strength,
    disable     = band_disable,
    enable      = band_enable,
    delete      = band_delete
}

local _do =
{   shake       = do_shake,
    wiggle      =
    {   _local      = do_local_wiggle,
        all         = do_global_wiggle_all,
        sidechains  = do_global_wiggle_sidechains,
        backbone    = do_global_wiggle_backbone
    },
    rebuild     = do_local_rebuild,
    mutate      = do_mutate,
    freeze      = do_freeze,
    unfreeze    = do_unfreeze_all,
    cl          = set_behavior_clash_importance,
    deselect    =
    {   index   = deselect_index,
        all     = deselect_all
    },
    select      =
    {   index   = select_index,
        range   = select_index_range,
        all     = select_all
    },
    replace_ss  = replace_ss
}
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
        s = get.score(true) * get.expscore()
    else -- if
        s = get.score(true)
    end -- if
    return s
end -- function

debug =
{   assert  = _assert,
    score   = _score
}
--Debug#

--#Amino
amino_segs      = {'a', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'y'}
amino_part      = { short = 0, abbrev = 1, longname = 2, hydro = 3, scale = 4, pref = 5, mol = 6, pl = 7, vdw_vol = 8}
amino_table     = {
  -- short, {abbrev,longname,           hydrophobic,scale,  pref,   mol,        pl,     vdw vol }
    ['a'] = {'Ala', 'Alanine',          true,       -1.6,   'H',    89.09404,   6.01,   67      },
    ['c'] = {'Cys', 'Cysteine',         true,       -17,    'E',    121.15404,  5.05,   86      },
    ['d'] = {'Asp', 'Aspartic acid',    false,      6.7,    'L',    133.10384,  2.85,   91      },
    ['e'] = {'Glu', 'Glutamic acid',    false,      8.1,    'H',    147.13074,  3.15,   109     },
    ['f'] = {'Phe', 'Phenylalanine',    true,       -6.3,   'E',    165.19184,  5.49,   135     },
    ['g'] = {'Gly', 'Glycine',          true,       1.7,    'L',    75.06714,   6.06,   48      },
    ['h'] = {'His', 'Histidine',        false,      -5.6,   nil,    155.15634,  7.60,   118     },
    ['i'] = {'Ile', 'Isoleucine',       true,       -2.4,   'E',    131.17464,  6.05,   124     },
    ['k'] = {'Lys', 'Lysine',           false,      6.5,    'H',    146.18934,  9.60,   135     },
    ['l'] = {'Leu', 'Leucine',          true,       1,      'H',    131.17464,  6.01,   124     },
    ['m'] = {'Met', 'Methionine',       true,       3.4,    'H',    149.20784,  5.74,   124     },
    ['n'] = {'Asn', 'Asparagine',       false,      8.9,    'L',    132.11904,  5.41,   96      },
    ['p'] = {'Pro', 'Proline',          true,       -0.2,   'L',    115.13194,  6.30,   90      },
    ['q'] = {'Gln', 'Glutamine',        false,      9.7,    'H',    146.14594,  5.65,   114     },
    ['r'] = {'Arg', 'Arginine',         false,      9.8,    'H',    174.20274,  10.76,  148     },
    ['s'] = {'Ser', 'Serine',           false,      3.7,    'L',    105.09344,  5.68,   73      },
    ['t'] = {'Thr', 'Threonine',        false,      2.7,    'E',    119.12034,  5.60,   93      },
    ['v'] = {'Val', 'Valine',           true,       -2.9,   'E',    117.14784,  6.00,   105     },
    ['w'] = {'Trp', 'Tryptophan',       true,       -9.1,   'E',    204.22844,  5.89,   163     },
    ['y'] = {'Tyr', 'Tyrosine',         true,       -5.1,   'E',    181.19124,  5.64,   141     },
--[[['b'] = {'Asx', 'Asparagine or Aspartic acid'},
    ['j'] = {'Xle', 'Leucine or Isoleucine'},
    ['o'] = {'Pyl', 'Pyrrolysine'},
    ['u'] = {'Sec', 'Selenocysteine'},
    ['x'] = {'Xaa', 'Unspecified or unknown amino acid'},
    ['z'] = {'Glx', 'Glutamine or glutamic acid'}
  ]]}

local function _short(seg)
    return amino_table[aa[seg]][amino_part.short]
end

local function _abbrev(seg)
    return amino_table[aa[seg]][amino_part.abbrev]
end

local function _long(seg)
    return amino_table[aa[seg]][amino_part.longname]
end

local function _h(seg)
    return amino_table[aa[seg]][amino_part.hydro]
end

local function _hscale(seg)
    return amino_table[aa[seg]][amino_part.scale]
end

local function _pref(seg)
    return amino_table[aa[seg]][amino_part.pref]
end

local function _mol(seg)
    return amino_table[aa[seg]][amino_part.mol]
end

local function _pl(seg)
    return amino_table[aa[seg]][amino_part.pl]
end

local function _vdw_radius (seg)
    local vol
    local radius
    vol = amino_table[seg][amino_part.vdw_vol]
    radius = ((vol * 3 / 4) / 3.14159) ^ (1 / 3)
    return radius
end

amino =
{   short       = _short,
    abbrev      = _abbrev,
    longname    = _long,
    hydro       = _h,
    hydroscale  = _hscale,
    preffered   = _pref,
    size        = _mol,
    charge      = _pl,
    vdw_radius  = _vdw_radius
}

--#Calculations
local function _HCI(seg_a, seg_b) -- hydropathy
    return 20 - math.abs((amino.hydroscale(seg_a) - amino.hydroscale(seg_b)) * 19/10.6)
end

local function _SCI(seg_a, seg_b) -- size
    return 20 - math.abs((amino.size(seg_a) + amino.size(seg_b) - 123) * 19/135)
end

local function _CCI(seg_a, seg_b) -- charge
    return 11 - (amino.charge(seg_a) - 7) * (amino.charge(seg_b) - 7) * 19/33.8
end

local function _calc()
    p("Calculating Scoring Matrix")
    hci_table = {}
    cci_table = {}
    sci_table = {}
    for i = 1, #amino_segs do
        hci_table[amino_segs[i]] = {}
        cci_table[amino_segs[i]] = {}
        sci_table[amino_segs[i]] = {}
        for ii = 1, #amino_segs do
            hci_table[amino_segs[i]][amino_segs[ii]] = calc.hci(i, ii)
            cci_table[amino_segs[i]][amino_segs[ii]] = calc.cci(i, ii)
            sci_table[amino_segs[i]][amino_segs[ii]] = calc.sci(i, ii)
        end -- for ii
    end -- for i
    p("Getting Segment Score out of the Matrix")
    strength = {}
    for i = 1, numsegs do
        strength[i] = {}
        for ii = i + 2, numsegs - 2 do
            strength[i][ii] = (hci_table[aa[i]][aa[ii]] * 2) + (cci_table[aa[i]][aa[ii]] * 1.26 * 1.065) + (sci_table[aa[i]][aa[ii]] * 2)
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
local function _dists()
    distances = {}
    for i = 1, numsegs - 1 do
        distances[i] = {}
        for j = i + 1, numsegs do
            distances[i][j] = get.distance(i, j)
        end -- for j
    end -- for i
end -- function

local function _sphere(seg, radius)
    sphere = {}
    for i = 1, numsegs do
        if get.distance(seg, i) <= radius then
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
    center  = _center,
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
    request = _request,
    save    = quicksave,
    load    = quickload
}
--Saveslot manager#
--External functions#

--#Internal functions
--#Checks
--#Hydrocheck
local function _hydro()
    p("UNIQUE: Detecting hydrophobicy and store it")
    hydro = {}
    for i = 1, numsegs do
        hydro[i] = get.hydrophobic(i)
    end -- for i
end -- function
--Hydrocheck#

--#Ligand Check
local function _ligand()
    if get.ss(numsegs) == 'M' then
        numsegs = numsegs - 1
        p("UNIQUE: Detected a ligand puzzle")
    end -- if get.ss
end -- function
--Ligand Check#

--#Structurecheck
local function _ss()
    p("Detecting current secondary structure and store it")
    ss = {}
    for i = 1, numsegs do
        ss[i] = get.ss(i)
    end -- for i
end -- function

local function _aa()
    p("UNIQUE: Detecting amino acids and store it")
    aa = {}
    for i = 1, numsegs do
        aa[i] = get.aa(i)
    end -- for i
end -- function

local function _struct()
    check.secstr()
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
--Structurecheck#

check =
{   secstr = _ss,
    aacid   = _aa,
    ligand  = _ligand,
    hydro   = _hydro,
    struct  = _struct
}
--Checks#

--#Fuzing
local function _loss(option, cl1, cl2)
    p("Fuzing Method ", option)
    p("cl1 ", cl1, ", cl2 ", cl2)
    reset.score()
    if option == 1 then
        local qs1 = debug.score()
        p("qStab cl1-s-cl2-wa-cl=1-s")
        work.step(false, "s", 1, cl1)
        work.step(false, "wa", 1, cl2)
        work.step(false, "s", 1, 1)
        work.gain("wa", 1)
        local qs2 = debug.score()
        reset.recent()
        if qs2 > qs1 then
            fuze.loss(1, cl1, cl2)
        end -- if
    elseif option == 2 then
        p("Blue Fuse cl1-s; cl2-s;")
        work.step(false, "s", 1, cl1)
        work.gain("wa", 1)
        work.step(false, "s", 1, cl2)
        work.gain("wa", 1)
        reset.recent()
        work.step(false, "s", 1, cl1 - 0.02)
        work.gain("wa", 1)
        reset.recent()
    elseif option == 3 then
        p("Pink Fuse cl1-s-cl2-wa")
        work.step(false, "s", 1, cl1)
        work.step(false, "wa", 1, cl2)
    elseif option == 4 then
        p("Pink Fuse cl1-wa-cl=1-wa-cl2-wa")
        work.step(false, "wa", 1, cl1)
        work.step(false, "wa", 1, 1)
        work.step(false, "wa", 1, cl2)
    end -- if option
    reset.recent()
end -- function

local function _part(option, cl1, cl2)
    local s1_f = debug.score()
    fuze.loss(option, cl1, cl2)
    if option ~= 1 then
        work.gain("wa", 1)
    end -- if
    local s2_f = debug.score()
    if s2_f > s1_f then
        sl.save(sl_f)
        p("+", s2_f - s1_f, "+")
    end -- if
    sl.load(sl_f)
end -- function

local function _start(slot)
    p("Started Fuzing")
    fuzing = true
    select.segs()
    sl_f = sl.request()
    c_s = debug.score()
    sl.save(sl_f)
    if b_fast_fuze then
        fuze.part(3, 0.1, 1)
    else
        fuze.part(1, 0.1, 0.4)
        fuze.part(3, 0.1, 0.7)
        if b_fuze_deep then
            p("Deep fuzing...")
            fuze.part(2, 0.05, 0.07)
            fuze.part(4, 0.5, 0.7)
            fuze.part(4, 0.7, 0.5)
        end
    end
    sl.load(sl_f)
    local s_f = debug.score()
    sl.release(sl_f)
    fuzing = false
    if s_f > c_s then
        sl.save(slot)
        local s_fg = s_f - c_s
        p("+", s_fg, "+")
        c_s = s_f
        p("++", c_s, "++")
        if b_f_deep and s_fg > i_score_gain then
            fuze.start(slot)
        end -- if deep
    else -- if s_f
        sl.load(slot)
    end -- if s_f
    fuzing = false
    p("Fuzing ended")
end -- function

fuze =
{   loss    =   _loss,
    part    =   _part,
    start   =   _start
}
--Fuzing#

--#Universal select
local function _segs(sphered, start, _end, more)
    local list1
    if not more then
        _do.deselect.all()
    end -- if more
    if start then
        if sphered then
            if _end then
                if start ~= _end then
                    list1 = get.sphere(_end, 10)
                    select.list(list1)
                end -- if ~= end
                if  start > _end then
                    local _start = _end
                    _end = start
                    start = _start
                end -- if > end
                _do.select.range(start, _end)
            else
                _do.select.index(start)
            end
            list1 = get.sphere(start, 10)
            select.list(list1)
        elseif _end and start ~= _end then
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end -- if > end
            _do.select.range(start, _end)
        else -- if sphered
            _do.select.index(start)
        end -- if sphered
    else -- if start
        _do.select.all()
    end -- if start
end -- function

local function _list(list)
    if list then
        for i = 1, #list do
            _do.select.index(list[i])
        end -- for
    end -- if list
end -- function

select =
{   segs    = _segs,
    list    = _list
}
--Universal select#

--#Scoring
function score(g, slot)
    local more = s1 - c_s
    if more > i_score_gain then
        p("+", more, "+")
        p("++", s1, "++")
        c_s = s1
        sl.save(slot)
    else -- if
        sl.load(slot)
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
                work.step(false, g, iter, cl)
            end -- if
            local s2_f = debug.score()
        until s2_f - s1_f < i_score_step
        local s3_f = debug.score()
        work.step(false, "s")
        local s4_f = debug.score()
    until s4_f - s3_f < i_score_step
end

local function _step(sphered, _g, iter, cl)
    if cl then
        _do.cl(cl)
    end -- if
    if rebuilding and _g == "s" or sphered then
        select.segs(true, seg, r)
    else -- if rebuiling
        select.segs()
    end -- if rebuilding
    if _g == "wa" then
        _do.wiggle.all(iter)
    elseif _g == "s" then
        _do.shake(1)
    elseif _g == "wb" then
        _do.wiggle.backbone(iter)
    elseif _g == "ws" then
        _do.wiggle.sidechains(iter)
    elseif _g == "wl" then
        select.segs(false, seg, r)
        reset.score()
        for i = iter, iter + 5 do
            local s_s1 = debug.score()
            _do.wiggle._local(i)
            local s_s2 = debug.score()
            if s_s2 > s_s1 then
                reset.score()
            else
                reset.recent()
                break
            end -- if >
        end -- for
    end -- if _g
end -- function

local function _flow(g)
    local iter = 0
    if rebuilding then
        slot = sl_re
    else -- if
        slot = overall
    end -- if
    work_sl = sl.request()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            sl.save(work_sl)
        end -- if iter
        s1 = debug.score()
        if iter < i_maxiter then
            if b_sphered then
                work.step(true, g, iter)
            else -- if b_sphered
                work.step(false, g, iter)
            end -- if b_sphered
        end -- <
        s2 = debug.score()
    until s2 - s1 < (i_score_step * iter)
    if s2 < s1 then
        sl.load(work_sl)
    else -- if <
        s1 = s2
    end -- if <
    sl.release(work_sl)
    _do.deselect.all()
    score(g, slot)
end -- function

function _quake(ii)
    local s3 = math.abs(debug.score() / 100 * i_pp_loss * 0.75)
    p("Pulling until a loss of more than ", s3)
    local strength = 0.05 + 0.06 * i_pp_loss
    local bands = get.bandcount()
    select.segs()
    if b_solo_quake then
        band.enable(ii)
        strength = strength * 6
    end
    reset.score()
    repeat
        p("Band strength: ", strength)
        reset.recent()
        local s1 = debug.score()
        if b_solo_quake then
            band.strength(ii, strength)
        else
        for i = 1, bands do
            band.strength(i, strength)
        end -- for
        end
        _do.wiggle.backbone(1)
        local s2 = debug.score()
        if s2 > s1 then
            reset.recent()
            reset.score()
            s1 = s2
        end -- if >
        strength = math.floor(strength * 2 - strength * 29 / 30, 3)
        if b_solo_quake then
            strength = math.floor(strength * 2 - strength * 14 / 15, 3)
        end
        if strength > 10 then
            break
        end
    until s1 - s2 > s3
    sl.save(pp)
end -- function

local function _dist()
    p("Quaker")
    select.segs()
    sl.save(overall)
    local bandcount = get.bandcount()
    if b_solo_quake then
        p("Solo quaking enabled")
        rebuilding = true
        for ii = 1, bandcount do
            band.disable(ii)
        end
        seg = 1
        for ii = 1, bandcount do
        sl.save(overall)
        work.quake(ii)
        band.delete(ii)
        fuze.start(pp)
        if debug.score() > dist_score then
            sl.save(overall)
            dist_score = debug.score()
        else
            sl.load(overall)
            band.delete(ii)
        end
        end
        rebuilding = false
    else
        work.quake()
        band.delete()
        fuze.start(pp)
        if debug.score() > dist_score then
            sl.save(overall)
            dist_score = debug.score()
        else
            sl.load(overall)
        end
    end
end

work =
{   gain    = _gain,
    step    = _step,
    flow    = _flow,
    quake   = _quake,
    dist    = _dist
}
--Working#

--#Bonding
--#Center
local function _cp(locally)
    local indexCenter = get.center()
    local start
    local _end
    if locally then
        start = seg
        _end = r
    else -- if
        start = i_start_seg
        _end = i_end_seg
    end -- if
    for i = start, _end do
        if i ~= indexCenter then
            if hydro[i] then
                band.add(i, indexCenter)
            end -- if hydro
        end -- if ~=
    end -- for
end -- function
--Center#

--#Pull
local function _p(locally, bandsp)
    if locally then
        start = seg
        _end = r
    else -- if
        start = i_start_seg
        _end = i_end_seg
    end -- if
    get.dists()
    for x = start, _end - 2 do
        if hydro[x] then
            for y = x + 2, numsegs do
                math.randomseed(distances[x][y])
                if hydro[y] and math.random() < bandsp then
                    band.add(x, y)
                end -- hydro y
            end -- for y
        end -- if hydro x
    end -- for x
end -- function
--Pull#

--#BandMaxDist
local function _maxdist()
    get.dists()
    local maxdistance = 0
    for i = i_start_seg, i_end_seg do
        for j = i_start_seg, i_end_seg do
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
end -- function
--BandMaxDist#

local function _matrix()
    calc.run()
    get.dists()
    for i = 1, numsegs do
        local max_str = 0
        local min_dist = 999
        for ii = i + 2, numsegs - 2 do
            if max_str <= strength[i][ii] then
                if max_str ~= strength[i][ii] then
                    min_dist = 999
                end
                max_str = strength[i][ii]
                if min_dist > distances[i][ii] then
                    min_dist = distances[i][ii]
                end
            end
        end
        for ii = i + 2, numsegs - 2 do
            if strength[i][ii] == max_str and min_dist == distances[i][ii] then
                band.add(i , ii)
            end
        end
    end
end

local function _helix()
    for i = 1, #he do
        for ii = he[i][1], he[i][#he[i]] - 4, 4 do
            band.add(ii, ii + 4)
        end -- for ii
        for ii = he[i][1] + 1, he[i][#he[i]] - 4, 4 do
            band.add(ii, ii + 4)
        end -- for ii
        for ii = he[i][1] + 2, he[i][#he[i]] - 4, 4 do
            band.add(ii, ii + 4)
        end -- for ii
        for ii = he[i][1] + 3, he[i][#he[i]] - 4, 4 do
            band.add(ii, ii + 4)
        end -- for ii
    end -- for i
end -- function

local function _comp_sheets()
    for i = 1, #sh - 1 do
        seg = sh[i][1]
        r = sh[i + 1][1]
        band.add(seg, r)
        seg = sh[i][#sh[i]]
        r = sh[i + 1][#sh[i + 1]]
        band.add(seg, r)
    end
end

local function _sheets()
    for i = 1, #sh do
        for ii = 1, #sh[i] - 2 do
            band.add(sh[i][ii], sh[i][ii] + 2)
            local band = get.bandcount()
            band.strength(band, 2)
            band.length(band, 15)
        end
    end
end

bonding =
{   centerpull  = _cp,
    pull        = _p,
    maxdist     = _maxdist,
    helix       = _helix,
    sheet       = _sheet,
    comp.helix  = _comp_helix,
    comp.sheet  = _comp_sheet,
    matrix      = _matrix
}
--Bonding#
--Header#

--#Rebuilding
function rebuild()
    local iter = 1
    rebuilding = true
    sl_re = sl.request()
    local saved = false
    sl.load(overall)
    sl.save(sl_re)
    select.segs(false, seg, r)
    if r == seg then
        p("Rebuilding Segment ", seg)
    else
        p("Rebuilding Segment ", seg, "-", r)
    end
    cs0 = debug.score()
    for i = 1, i_max_rebuilds do
        p("Try ", i, "/", i_max_rebuilds)
        cs_0 = debug.score()
        _do.cl(1)
        while debug.score() == cs_0 do
            _do.rebuild(iter * i_rebuild_str)
            iter = iter + 1
            if iter > i_maxiter then
                iter = i_maxiter
            end
        end
        iter = 1
        str_rs = debug.score()
        if saved then
            if cs_0 < str_rs then
                cs_0 = str_rs - math.abs(str_rs)/10
                sl.save(sl_re)
            end
        else
            sl.save(sl_re)
            cs_0 = str_rs
            saved = true
        end
    end
    sl.load(sl_re)
    _do.cl(1)
    p(debug.score() - cs0)
    c_s = debug.score()
    if b_r_dist then
        dists()
    end
    fuze.start(sl_re)
    sl.load(sl_re)
    p("+", c_s - cs0, "+")
    sl.release(sl_re)
    if c_s < cs0 then
        sl.load(overall)
    else
        sl.save(overall)
    end
    rebuilding = false
end
--Rebuilding#

--#Pull
function dists()
    pp = sl.request()
    sl.save(overall)
    dist_score = debug.score()
    if b_comp then
        band.delete()
        bonding.maxdist()
        work.dist()
    end -- if b_comp
    band.delete()
    bonding.matrix()
    work.dist()
    band.delete()
    bonding.pull(false, 0.05)
    work.dist()
    band.delete()
    bonding.centerpull()
    work.dist()
    sl.release(pp)
end
--Pull#

--#Predict ss
local function _getdata()
    local p_he = {}
    local p_sh = {}
    local p_lo = {}
    local helix
    local sheet
    local loop
    local i = 1
    while i < numsegs do
        loop = false
        if hydro[i] then
            if hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if not helix and aa[i] ~= "p" then
                    helix = true
                    p_he[#p_he + 1] = {}
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
                if not helix and aa[i] ~= "p" then
                    helix = true
                    p_he[#p_he + 1] = {}
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
                                if i + 3 < numsegs then
                                    if aa[i + 3] ~= "p" then
                                        p_he[#p_he][#p_he[#p_he] + 1] = i + 3
                                    end -- if aa i + 3
                                end -- if i + 3
                            end -- if aa i + 2
                        end -- if i + 2
                    end -- if aa i + 1
                end -- if i + 1
                i = i + 4
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
                if i + 3 < numsegs then
                    p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 3
                end -- if i + 3
                i = i + 4
            end -- if loop
        end -- if sheet
        i = i + 1
    end -- while
    p("Found ", #p_he, " Helix and ", #p_sh, " Sheet parts... Combining...")
    select.segs()
    _do.replace_ss("L")
    _do.deselect.all()
    for i = 1, #p_he do
        select.list(p_he[i])
    end -- for
    _do.replace_ss("H")
    _do.deselect.all()
    for i = 1, #p_sh do
        select.list(p_sh[i])
    end -- for
    _do.replace_ss("E")
    for i = 1, 3 do
        predict.combine()
    end
    sl.save(overall)
end

local function _combine()
    check.struct()
    for i = 1, numsegs do
        if ss[i] == "L" then
            if aa[i] ~= "p" then
                for ii = 1, #he - 1 do
                    for iii = he[ii][1], he[ii][#he[ii]] do
                        if iii + 1 == i and he[ii + 1][1] == i + 1 then
                            _do.deselect.all()
                            _do.select.index(i)
                            _do.replace_ss("H")
                        end -- if iii
                    end -- for iii
                end -- for ii
            end -- if aa
            for ii = 1, #sh - 1 do
                for iii = sh[ii][1], sh[ii][#sh[ii]] do
                    if iii + 1 == i and sh[ii + 1][1] == i + 1 then
                        _do.deselect.all()
                        _do.select.index(i)
                        _do.replace_ss("E")
                    end -- if iii
                end -- for iii
            end -- for ii
        end -- if ss
    end -- for i
end

predict =
{   getdata = _getdata,
    combine = _combine
}
--predictss#

function struct_rebuild()
    local str_rs
    local str_rs2
    check.struct()
    p("Found ", #he, " Helixes ", #sh, " Sheets and ", #lo, " Loops")
    local iter = 1
    if b_re_he then
        for i = 1, #sh do
            _do.deselect.all()
            select.list(sh[i])
            _do.replace_ss("L")
        end
        for i = 1, #he do
            p("Working on Helix ", i)
            _do.deselect.all()
            seg = he[i][1] - 3
            if seg < 1 then
                seg = 1
            end
            r = he[i][#he[i]] + 3
            if r > numsegs then
                r = numsegs
            end
            bonding.helix()
            _do.deselect.all()
            _do.select.range(seg, r)
            _do.cl(0.4)
            _do.wiggle.backbone(1)
            _do.cl(0)
            for i = 1, i_str_re_max_re do
                str_rs = debug.score()
                str_rs2 = str_rs
                while str_rs == str_rs2 do
                    _do.rebuild(iter * i_str_re_re_str)
                    iter = iter + 1
                    if iter > i_maxiter then
                        iter = i_maxiter
                    end
                    str_rs2 = debug.score()
                end
                iter = 1
            end
            band.delete()
            seg = he[i][1] - 1
            if seg < 1 then
                seg = 1
            end
            r = he[i][#he[i]] + 1
            if r > numsegs then
                r = numsegs
            end
            _do.deselect.all()
            _do.select.range(seg, r)
            for i = 1, i_str_re_max_re do
                str_rs = debug.score()
                str_rs2 = str_rs
                while str_rs == str_rs2 do
                    _do.rebuild(iter * i_str_re_re_str)
                    iter = iter + 1
                    if iter > i_maxiter then
                        iter = i_maxiter
                    end
                    str_rs2 = debug.score()
                end
                iter = 1
            end
            seg = he[i][1] - 2
            if seg < 1 then
                seg = 1
            end
            r = he[i][#he[i]] + 2
            if r > numsegs then
                r = numsegs
            end
            if b_str_re_fuze then
                rebuilding = true
                fuze.start(best)
                rebuilding = false
            end
            str_sc = nil
            str_rs = nil
        end
        for i = 1, #sh do
            _do.deselect.all()
            select.list(sh[i])
            _do.replace_ss("E")
        end
    end
    if b_re_sh then
        for i = 1, #he do
            _do.deselect.all()
            select.list(he[i])
            _do.replace_ss("L")
        end
        for i = 1, #sh do
            p("Working on Sheet ", i)
            seg = sh[i][1] - 3
            if seg < 1 then
                seg = 1
            end
            r = sh[i][#sh[i]] + 3
            if r > numsegs then
                r = numsegs
            end
            _do.deselect.all()
            _do.select.range(seg, r)
            _do.cl(0)
            for i = 1, i_str_re_max_re do
                str_rs = debug.score()
                str_rs2 = str_rs
                while str_rs == str_rs2 do
                    _do.rebuild(iter * i_str_re_re_str)
                    iter = iter + 1
                    if iter > i_maxiter then
                        iter = i_maxiter
                    end
                    str_rs2 = debug.score()
                end
                iter = 1
            end
            band.delete()
            seg = sh[i][1] - 1
            if seg < 1 then
                seg = 1
            end
            r = sh[i][#sh[i]] + 1
            if r > numsegs then
                r = numsegs
            end
            _do.deselect.all()
            _do.select.range(seg, r)
            for i = 1, i_str_re_max_re do
                str_rs = debug.score()
                str_rs2 = str_rs
                while str_rs == str_rs2 do
                    _do.rebuild(iter * i_str_re_re_str)
                    iter = iter + 1
                    if iter > i_maxiter then
                        iter = i_maxiter
                    end
                    str_rs2 = debug.score()
                end
                iter = 1
            end
            seg = sh[i][1] - 2
            if seg < 1 then
                seg = 1
            end
            r = sh[i][#sh[i]] + 2
            if r > numsegs then
                r = numsegs
            end
            _do.cl(1)
            if b_str_re_fuze then
                rebuilding = true
                fuze.start(best)
                rebuilding = false
            end
        end
        for i = 1, #he do
            _do.deselect.all()
            select.list(he[i])
            _do.replace_ss("H")
        end
    end
    sl.save(overall)
end

s_0 = debug.score()
c_s = s_0
check.aacid()
check.ligand()
check.hydro()
p("Starting Score: ", c_s)
overall = sl.request()
sl.save(overall)
p("v", Version)
if b_predict then
    predict.getdata()
end
if b_str_re then
    struct_rebuild()
end
if b_pp then
    for i = 1, i_pp_trys do
        dists()
    end
end
for i = i_start_seg, i_end_seg do
    seg = i
    c_s = debug.score()
    for ii = i_start_walk, i_end_walk do
        r = i + ii
        if r > numsegs then
            r = numsegs
            break
        end
        if b_rebuild then
            if b_worst_rebuild then
                local worst = 1000
                for iii = 1, numsegs do
                    local s = get.seg_score(iii)
                    if s < worst then
                        seg = iii
                        worst = s
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
                work.flow("s")
                sc_changed = false
            end
        end
    end
end
if b_fuze then
    fuze.start(overall)
end
sl.load(overall)
sl.release(overall)
s_1 = debug.score()
p("+++ Overall gain +++")
p("+++", s_1 - s_0, "+++")