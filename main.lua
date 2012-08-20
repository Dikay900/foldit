--[[#Header
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions and ideas goes to Seagat, Rav3n_pl, Tlaloc, Gary Forbis and BitSpawn
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
i_vers          = 1229
i_segcount      = structure.GetCount()
--#Release
b_release       = false
i_release_date  = "2012"
i_release_vers  = 5
--Release#
--Game vars#

--#Settings: default
--#Main
b_lws           = false         -- false        do local wiggle and rewiggle
b_rebuild       = false         -- false        rebuild | see #Rebuilding
b_pp            = false         -- false        pull hydrophobic amino acids in different modes then fuze | see #Pull
b_str_re        = false         -- false        rebuild the protein based on the secondary structures | see #Structed rebuilding
b_cu            = false         -- false        Do bond the structures and curl it, try to improve it and get some points
b_snap          = false         -- false        should we snap every sidechain to different positions
b_fuze          = false         -- false        should we fuze | see #Fuzing
b_mutate        = true         -- false        it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
b_predict       = false         -- false        reset and predict then the secondary structure based on the amino acids of the protein
b_sphered       = false         -- false        work with a sphere always, can be used on lws and rebuilding walker
b_explore       = true          -- false        if true then the overall score will be taken if a exploration puzzle, if false then just the stability score is used for the methods
--Main#

--#Working                      default         description
i_start_seg     = 1             -- 1            the first segment to work with
i_end_seg       = i_segcount    -- i_segcount   the last segment to work with
i_start_walk    = 1             -- 1            with how many segs shall we work - Walker
i_end_walk      = 2             -- 3            starting at the current seg + i_start_walk to seg + i_end_walk
i_score_change  = 0.01          -- 0.01         an action tries to get this score, then it will repeat itself | adjust a lower value to get the lws script working on high evo- / solos, higher values are probably better rebuilding the protein
--Working#

--#Mutating
b_m_re          = false
b_m_opt            = true
b_m_after       = false
i_m_cl_mut      = 0.75          -- 0.75         cl for mutating
i_m_cl_wig      = 1             -- 1            cl for wiggling after mutating
--Mutating#

--#Pull
i_pp_trys       = 1             -- 1            how often should the pull start over?
i_pp_loss       = 0.1            -- 1            the score / 100 * i_pp_loss is the general formula for calculating the points we must lose till we fuze
b_pp_mutate     = false
b_pp_struct     = true          -- true         don't band segs of same structure together if segs are in one struct (between one helix or sheet)
i_pp_bandperc   = 0.1          -- 0.08
i_pp_len        = 4
b_pp_fixed      = false         -- false
i_pp_fix_start  = 54             -- 0
i_pp_fix_end    = 57             -- 0
b_pp_soft       = false
b_pp_fuze       = true
b_solo_quake    = false         -- false        just one seg is used on every method and all segs are tested
b_pp_local      = false         -- false
b_pp_pre_strong = false          -- true         bands are created which pull segs together based on the size, charge and isoelectric point of the amino acids
b_pp_pre_local  = false         -- false
b_pp_evo        = false          -- true
i_pp_evos       = 10
b_pp_push_pull  = false          -- true
b_pp_pull       = false         -- true         hydrophobic segs are pulled together
b_pp_c_pushpull = false         -- true
b_pp_centerpull = false         -- true          hydrophobic segs are pulled to the center segment
b_pp_vibrator   = false          -- false
b_pp_bonds      = true          -- false        pulls already bonded segments to maybe strengthen them
b_pp_area        = false
i_pp_area_range = 20
--Pull

--#Fuzing
b_fuze_pf       = false          -- true         Use Pink Fuze / Wiggle out
b_fuze_bf       = true          -- true         Use Bluefuse
--Fuzing#

--#Snapping
--Snapping#

--#Rebuilding
b_worst_rebuild = false         -- false        rebuild worst scored parts of the protein | NOT READY YET
b_worst_len     = 6
i_re_trys       = 10
b_re_str        = false
b_re_walk       = true          -- true
i_max_rebuilds  = 1             -- 2            max rebuilds till best rebuild will be chosen
i_rebuild_str   = 1             -- 1            the iterations a rebuild will do at default, automatically increased if no change in score
b_re_m_ignore_struct = false
b_m_re_deep_rebuild = true
b_re_extreme_tweak = true
--Rebuilding#

--#Predicting
b_predict_full  = true         -- try to detect the secondary structure between every segment, there can be less loops but the protein become difficult to rebuild
b_pre_add_pref  = true
b_pre_comb_str  = false
--Predicting#

--#Curler
b_cu_he         = true          -- true
b_cu_sh         = true          -- true
--Curler#

--#Structed rebuilding
i_str_re_max_re = 2             -- 2            same as i_max_rebuilds at #Rebuilding
i_str_re_re_str = 1             -- 1            same as i_rebuild_str at #Rebuilding
b_re_he         = true          -- true         should we rebuild helices
b_re_sh         = true          -- true         should we rebuild sheets
b_str_re_fuze   = false         -- false        should we fuze after one rebuild
--Structed rebuilding#
--Settings#

--#Constants | Game vars
t_sls             = {}
for _i = 1, 100 do
    t_sls[#t_sls + 1] = _i
end
b_sphering      = false
startTime       = os.time()
time_used       = 0
time_mod        = 1
b_mutating      = false
b_tweaking      = false
i_pp_bandperc   = i_pp_bandperc / i_segcount * 100
t_selected      = {}
b_changed       = true
b_ss_changed    = true
b_evo           = false
if current.GetExplorationMultiplier() == 0 then
    isExploringPuzzle = false
else
    isExploringPuzzle = true
end
math.randomseed(recipe.GetRandomSeed())
--Constants | Game vars#

--#Optimizing
p   = print

reset =
{   -- renaming
    puzzle  = puzzle.StartOver
}

local function _addToSegs(seg1, seg2)
    local count = band.AddBetweenSegments(seg1, seg2 --[[integer atomIndex1], [integer atomIndex2]])
    if count ~= nil then
        bands.info[count] = {3.5, 1, seg1, seg2, true}
        return true
    else
        return false
    end
end

local function _addToArea(seg, x, y , length, theta, phi)
    local count = band.Add(seg, x, y, length, theta, phi)
    if count ~= nil then
        bands.info[count] = {3.5, 1, x, y, true}
        return true
    else
        return false
    end
end

local function _length(_band, len)
    band.SetGoalLength(_band, len)
    bands.info[_band][bands.part.length] = len
end

local function _strength(_band, str)
    band.SetStrength(_band, str)
    bands.info[_band][bands.part.strength] = str
end

local function _disable(_band)
    if not _band then
        band.DisableAll()
        local count = get.bandcount()
        for i = 1, count do
            bands.info[i][bands.part.enabled] = false
        end
    else
        band.Disable(_band)
        bands.info[_band][bands.part.enabled] = false
    end
end

local function _enable(_band)
    if not _band then
        band.EnableAll()
        local bandcount = get.bandcount()
        for i = 1, bandcount do
            bands.info[i][bands.part.enabled] = true
        end
    else
        band.Enable(_band)
        bands.info[_band][bands.part.enabled] = true
    end
end

local function _delete(_band)
    if not _band then
        band.DeleteAll()
        bands.info = {}
    else
        band.Delete(_band)
        bands.info[_band] = {}
    end
end

local function _enabled(_band)
    return bands.info[_band][bands.part.enabled]
end

local function _endseg(_band)
    return bands.info[_band][bands.part._end]
end

local function _startseg(_band)
    return bands.info[_band][bands.part.start]
end

local function _getstrength(_band)
    return bands.info[_band][bands.part.strength]
end

local function _getlength(_band)
    return bands.info[_band][bands.part.strength]
end

bands =
{   -- Band Mod
    addToSegs   = _addToSegs,
    addToArea   = _addToArea,
    length      = _length,
    strength    = _strength,
    disable     = _disable,
    enable      = _enable,
    delete      = _delete,
    get         = {
        length  = _getlength,
        strength= _getstrength,
        start   = _startseg,
        _end    = _endseg,
        enabled = _enabled
    },
    info        = {},
    part        = {length = 1, strength = 2, start = 3, _end = 4, enabled = 5}
}

local function _l_all(a)
    structure.LocalWiggleAll(a, true, true)
end
local function _l_all_b(a)
    structure.LocalWiggleAll(a, true, false)
end
local function _l_all_s(a)
    structure.LocalWiggleAll(a, false, true)
end
local function _l_sel(a)
    structure.LocalWiggleSelected(a, true, true)
end
local function _l_sel_b(a)
    structure.LocalWiggleSelected(a, true, false)
end
local function _l_sel_s(a)
    structure.LocalWiggleSelected(a, false, true)
end
local function _all(a)
    structure.WiggleAll(a, true, true)
end
local function _all_sel(a)
    structure.WiggleSelected(a, true, true)
end
local function _side(a)
    structure.WiggleAll(a, false, true)
end
local function _side_sel(a)
    structure.WiggleSelected(a, false, true)
end
local function _back(a)
    structure.WiggleAll(a, true, false)
end
local function _back_sel(a)
    structure.WiggleSelected(a, true, false)
end

wiggle =
{   -- renaming
    shake       = structure.ShakeSidechainsAll,
    shake_sel   = structure.ShakeSidechainsSelected,
    l_all       = _l_all,
    l_all_b     = _l_all_b,
    l_all_s     = _l_all_s,
    l_sel       = _l_sel,
    l_sel_b     = _l_sel_b,
    l_sel_s     = _l_sel_s,
    all         = _all,
    all_sel     = _all_sel,
    side        = _side,
    side_sel    = _side_sel,
    back        = _back,
    back_sel    = _back_sel
}

local function _deindex(seg)
    if t_selected[seg] then
        selection.Deselect(seg)
        t_selected[seg] = false
    end
end

local function _deall()
    selection.DeselectAll()
    t_selected = {}
end

deselect =
{   -- Selection Mod
    index   = _deindex,
    all     = _deall
}

set =
{   -- Selection Mod
    _ss             = structure.SetSecondaryStructure,
    ss              = structure.SetSecondaryStructureSelected,
    _aa             = structure.SetAminoAcid,
    aa              = structure.SetAminoAcidSelected,
    clashImportance = behavior.SetClashImportance,
    wiggleAccuracy  = behavior.SetWiggleAccuracy,
    shakeAccuracy   = behavior.SetShakeAccuracy
}

score =
{   -- renaming
    current =
    {
        energyScore         = current.GetEnergyScore,
        rankedScore         = current.GetScore,
        multiplier          = current.GetExplorationMultiplier,
        segmentScore        = current.GetSegmentEnergyScore,
        segmentScorePart    = current.GetSegmentEnergySubscore,
        conditions          = current.AreConditionsMet,
        restore             = current.Restore
    },
    recent =
    {
        energyScore         = recentbest.GetEnergyScore,
        rankedScore         = recentbest.GetScore,
        multiplier          = recentbest.GetExplorationMultiplier,
        segmentScore        = recentbest.GetSegmentEnergyScore,
        segmentScorePart    = recentbest.GetSegmentEnergySubscore,
        conditions          = recentbest.AreConditionsMet,
        restore             = recentbest.Restore,
        save                = recentbest.Save
    },
    absolutebest =
    {
        energyScore         = absolutebest.GetEnergyScore,
        rankedScore         = absolutebest.GetScore,
        multiplier          = absolutebest.GetExplorationMultiplier,
        segmentScore        = absolutebest.GetSegmentEnergyScore,
        segmentScorePart    = absolutebest.GetSegmentEnergySubscore,
        conditions          = absolutebest.AreConditionsMet,
        restore             = absolutebest.Restore
    },
    creditbest =
    {
        energyScore         = creditbest.GetEnergyScore,
        rankedScore         = creditbest.GetScore,
        multiplier          = creditbest.GetExplorationMultiplier,
        segmentScore        = creditbest.GetSegmentEnergyScore,
        segmentScorePart    = creditbest.GetSegmentEnergySubscore,
        conditions          = creditbest.AreConditionsMet,
        restore             = creditbest.Restore
    },
}
--Optimizing#

--#Math
math.floor = nil
function math.floor(value, _n)
    local n = 1
    if _n then
        n = 1 * 10 ^ (-_n)
    end -- if
    return value - (value % n)
end -- function
--Math#

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
    -- short,  {abbrev,longname,           hydrophobic,scale,  pref,   mol,        pl,     vdw }
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

--#Precalculated Table
t_precalcStrength = {}
for _i = 1, #amino.segs do
    t_precalcStrength[amino.segs[_i]] = {}
end
t_precalcStrength['a']['a'] = 32.372856210914;t_precalcStrength['a']['c'] = 27.185248498021;t_precalcStrength['a']['d'] = 27.775347149814;t_precalcStrength['a']['e'] = 50.456350961466;t_precalcStrength['a']['f'] = 20.353692652058;t_precalcStrength['a']['g'] = 51.672531784327;t_precalcStrength['a']['h'] = 49.478695919409;t_precalcStrength['a']['i'] = 27.775347149814;t_precalcStrength['a']['k'] = 8.3750653242535;t_precalcStrength['a']['l'] = 51.672531784327;t_precalcStrength['a']['m'] = 51.672531784327;t_precalcStrength['a']['n'] = 20.353692652058;t_precalcStrength['a']['p'] = 20.353692652058;t_precalcStrength['a']['q'] = 34.639588682129;t_precalcStrength['a']['r'] = 27.775347149814;t_precalcStrength['a']['s'] = 50.24328334011;t_precalcStrength['a']['t'] = -7.5041917681561;t_precalcStrength['a']['v'] = -11.191528474216;t_precalcStrength['a']['w'] = 20.353692652058;t_precalcStrength['a']['y'] = 51.672531784327;t_precalcStrength['c']['a'] = 27.185248498021;t_precalcStrength['c']['c'] = 48.875204881745;t_precalcStrength['c']['d'] = 41.855546099553;t_precalcStrength['c']['e'] = 26.635693125618;t_precalcStrength['c']['f'] = 43.066057732232;t_precalcStrength['c']['g'] = 29.856824872338;t_precalcStrength['c']['h'] = 36.564715193754;t_precalcStrength['c']['i'] = 41.855546099553;t_precalcStrength['c']['k'] = 31.049563415669;t_precalcStrength['c']['l'] = 29.856824872338;t_precalcStrength['c']['m'] = 29.856824872338;t_precalcStrength['c']['n'] = 43.066057732232;t_precalcStrength['c']['p'] = 43.066057732232;t_precalcStrength['c']['q'] = 53.951399737082;t_precalcStrength['c']['r'] = 41.855546099553;t_precalcStrength['c']['s'] = 31.24966683069;t_precalcStrength['c']['t'] = 13.807094727994;t_precalcStrength['c']['v'] = 17.541687818383;t_precalcStrength['c']['w'] = 43.066057732232;t_precalcStrength['c']['y'] = 29.856824872338;t_precalcStrength['d']['a'] = 27.775347149814;t_precalcStrength['d']['c'] = 41.855546099553;t_precalcStrength['d']['d'] = 45.823199111111;t_precalcStrength['d']['e'] = 42.104501069128;t_precalcStrength['d']['f'] = 35.260244055958;t_precalcStrength['d']['g'] = 52.604844798097;t_precalcStrength['d']['h'] = 60.186240557383;t_precalcStrength['d']['i'] = 45.823199111111;t_precalcStrength['d']['k'] = 23.272866587324;t_precalcStrength['d']['l'] = 52.604844798097;t_precalcStrength['d']['m'] = 52.604844798097;t_precalcStrength['d']['n'] = 35.260244055958;t_precalcStrength['d']['p'] = 35.260244055958;t_precalcStrength['d']['q'] = 49.257385438694;t_precalcStrength['d']['r'] = 45.823199111111;t_precalcStrength['d']['s'] = 47.417279124496;t_precalcStrength['d']['t'] = 7.0786044250923;t_precalcStrength['d']['v'] = 5.1062953213999;t_precalcStrength['d']['w'] = 35.260244055958;t_precalcStrength['d']['y'] = 52.604844798097;t_precalcStrength['e']['a'] = 50.456350961466;t_precalcStrength['e']['c'] = 26.635693125618;t_precalcStrength['e']['d'] = 42.104501069128;t_precalcStrength['e']['e'] = 49.559882678117;t_precalcStrength['e']['f'] = 20.844876012496;t_precalcStrength['e']['g'] = 41.139593752458;t_precalcStrength['e']['h'] = 37.789381517717;t_precalcStrength['e']['i'] = 42.104501069128;t_precalcStrength['e']['k'] = 8.8277028056971;t_precalcStrength['e']['l'] = 41.139593752458;t_precalcStrength['e']['m'] = 41.139593752458;t_precalcStrength['e']['n'] = 20.844876012496;t_precalcStrength['e']['p'] = 20.844876012496;t_precalcStrength['e']['q'] = 33.858758035763;t_precalcStrength['e']['r'] = 42.104501069128;t_precalcStrength['e']['s'] = 48.421713960905;t_precalcStrength['e']['t'] = -8.4392059304994;t_precalcStrength['e']['v'] = -4.5715503537188;t_precalcStrength['e']['w'] = 20.844876012496;t_precalcStrength['e']['y'] = 41.139593752458;t_precalcStrength['f']['a'] = 20.353692652058;t_precalcStrength['f']['c'] = 43.066057732232;t_precalcStrength['f']['d'] = 35.260244055958;t_precalcStrength['f']['e'] = 20.844876012496;t_precalcStrength['f']['f'] = 54.40946764336;t_precalcStrength['f']['g'] = 24.575175436732;t_precalcStrength['f']['h'] = 31.34416587945;t_precalcStrength['f']['i'] = 35.260244055958;t_precalcStrength['f']['k'] = 42.395009997506;t_precalcStrength['f']['l'] = 24.575175436732;t_precalcStrength['f']['m'] = 24.575175436732;t_precalcStrength['f']['n'] = 54.40946764336;t_precalcStrength['f']['p'] = 54.40946764336;t_precalcStrength['f']['q'] = 48.154472611832;t_precalcStrength['f']['r'] = 35.260244055958;t_precalcStrength['f']['s'] = 25.50772981461;t_precalcStrength['f']['t'] = 25.225861455393;t_precalcStrength['f']['v'] = 28.561267086612;t_precalcStrength['f']['w'] = 54.40946764336;t_precalcStrength['f']['y'] = 24.575175436732;t_precalcStrength['g']['a'] = 51.672531784327;t_precalcStrength['g']['c'] = 29.856824872338;t_precalcStrength['g']['d'] = 52.604844798097;t_precalcStrength['g']['e'] = 41.139593752458;t_precalcStrength['g']['f'] = 24.575175436732;t_precalcStrength['g']['g'] = 39.476487407462;t_precalcStrength['g']['h'] = 35.560533308816;t_precalcStrength['g']['i'] = 52.604844798097;t_precalcStrength['g']['k'] = 12.539144167802;t_precalcStrength['g']['l'] = 39.476487407462;t_precalcStrength['g']['m'] = 39.476487407462;t_precalcStrength['g']['n'] = 24.575175436732;t_precalcStrength['g']['p'] = 24.575175436732;t_precalcStrength['g']['q'] = 36.966741409703;t_precalcStrength['g']['r'] = 52.604844798097;t_precalcStrength['g']['s'] = 45.284680600725;t_precalcStrength['g']['t'] = -5.4066548050812;t_precalcStrength['g']['v'] = 2.157180949214;t_precalcStrength['g']['w'] = 24.575175436732;t_precalcStrength['g']['y'] = 39.476487407462;t_precalcStrength['h']['a'] = 49.478695919409;t_precalcStrength['h']['c'] = 36.564715193754;t_precalcStrength['h']['d'] = 60.186240557383;t_precalcStrength['h']['e'] = 37.789381517717;t_precalcStrength['h']['f'] = 31.34416587945;t_precalcStrength['h']['g'] = 35.560533308816;t_precalcStrength['h']['h'] = 41.614426035558;t_precalcStrength['h']['i'] = 60.186240557383;t_precalcStrength['h']['k'] = 19.305871643064;t_precalcStrength['h']['l'] = 35.560533308816;t_precalcStrength['h']['m'] = 35.560533308816;t_precalcStrength['h']['n'] = 31.34416587945;t_precalcStrength['h']['p'] = 31.34416587945;t_precalcStrength['h']['q'] = 43.661053926385;t_precalcStrength['h']['r'] = 60.186240557383;t_precalcStrength['h']['s'] = 41.880157147049;t_precalcStrength['h']['t'] = 1.278605841779;t_precalcStrength['h']['v'] = 9.2859832173762;t_precalcStrength['h']['w'] = 31.34416587945;t_precalcStrength['h']['y'] = 35.560533308816;t_precalcStrength['i']['a'] = 27.775347149814;t_precalcStrength['i']['c'] = 41.855546099553;t_precalcStrength['i']['d'] = 45.823199111111;t_precalcStrength['i']['e'] = 42.104501069128;t_precalcStrength['i']['f'] = 35.260244055958;t_precalcStrength['i']['g'] = 52.604844798097;t_precalcStrength['i']['h'] = 60.186240557383;t_precalcStrength['i']['i'] = 45.823199111111;t_precalcStrength['i']['k'] = 23.272866587324;t_precalcStrength['i']['l'] = 52.604844798097;t_precalcStrength['i']['m'] = 52.604844798097;t_precalcStrength['i']['n'] = 35.260244055958;t_precalcStrength['i']['p'] = 35.260244055958;t_precalcStrength['i']['q'] = 49.257385438694;t_precalcStrength['i']['r'] = 45.823199111111;t_precalcStrength['i']['s'] = 47.417279124496;t_precalcStrength['i']['t'] = 7.0786044250923;t_precalcStrength['i']['v'] = 5.1062953213999;t_precalcStrength['i']['w'] = 35.260244055958;t_precalcStrength['i']['y'] = 52.604844798097;t_precalcStrength['k']['a'] = 8.3750653242535;t_precalcStrength['k']['c'] = 31.049563415669;t_precalcStrength['k']['d'] = 23.272866587324;t_precalcStrength['k']['e'] = 8.8277028056971;t_precalcStrength['k']['f'] = 42.395009997506;t_precalcStrength['k']['g'] = 12.539144167802;t_precalcStrength['k']['h'] = 19.305871643064;t_precalcStrength['k']['i'] = 23.272866587324;t_precalcStrength['k']['k'] = 58.342741070348;t_precalcStrength['k']['l'] = 12.539144167802;t_precalcStrength['k']['m'] = 12.539144167802;t_precalcStrength['k']['n'] = 42.395009997506;t_precalcStrength['k']['p'] = 42.395009997506;t_precalcStrength['k']['q'] = 36.137525701776;t_precalcStrength['k']['r'] = 23.272866587324;t_precalcStrength['k']['s'] = 13.488746233845;t_precalcStrength['k']['t'] = 41.170876967289;t_precalcStrength['k']['v'] = 44.521067319218;t_precalcStrength['k']['w'] = 42.395009997506;t_precalcStrength['k']['y'] = 12.539144167802;t_precalcStrength['l']['a'] = 51.672531784327;t_precalcStrength['l']['c'] = 29.856824872338;t_precalcStrength['l']['d'] = 52.604844798097;t_precalcStrength['l']['e'] = 41.139593752458;t_precalcStrength['l']['f'] = 24.575175436732;t_precalcStrength['l']['g'] = 39.476487407462;t_precalcStrength['l']['h'] = 35.560533308816;t_precalcStrength['l']['i'] = 52.604844798097;t_precalcStrength['l']['k'] = 12.539144167802;t_precalcStrength['l']['l'] = 39.476487407462;t_precalcStrength['l']['m'] = 39.476487407462;t_precalcStrength['l']['n'] = 24.575175436732;t_precalcStrength['l']['p'] = 24.575175436732;t_precalcStrength['l']['q'] = 36.966741409703;t_precalcStrength['l']['r'] = 52.604844798097;t_precalcStrength['l']['s'] = 45.284680600725;t_precalcStrength['l']['t'] = -5.4066548050812;t_precalcStrength['l']['v'] = 2.157180949214;t_precalcStrength['l']['w'] = 24.575175436732;t_precalcStrength['l']['y'] = 39.476487407462;t_precalcStrength['m']['a'] = 51.672531784327;t_precalcStrength['m']['c'] = 29.856824872338;t_precalcStrength['m']['d'] = 52.604844798097;t_precalcStrength['m']['e'] = 41.139593752458;t_precalcStrength['m']['f'] = 24.575175436732;t_precalcStrength['m']['g'] = 39.476487407462;t_precalcStrength['m']['h'] = 35.560533308816;t_precalcStrength['m']['i'] = 52.604844798097;t_precalcStrength['m']['k'] = 12.539144167802;t_precalcStrength['m']['l'] = 39.476487407462;t_precalcStrength['m']['m'] = 39.476487407462;t_precalcStrength['m']['n'] = 24.575175436732;t_precalcStrength['m']['p'] = 24.575175436732;t_precalcStrength['m']['q'] = 36.966741409703;t_precalcStrength['m']['r'] = 52.604844798097;t_precalcStrength['m']['s'] = 45.284680600725;t_precalcStrength['m']['t'] = -5.4066548050812;t_precalcStrength['m']['v'] = 2.157180949214;t_precalcStrength['m']['w'] = 24.575175436732;t_precalcStrength['m']['y'] = 39.476487407462;t_precalcStrength['n']['a'] = 20.353692652058;t_precalcStrength['n']['c'] = 43.066057732232;t_precalcStrength['n']['d'] = 35.260244055958;t_precalcStrength['n']['e'] = 20.844876012496;t_precalcStrength['n']['f'] = 54.40946764336;t_precalcStrength['n']['g'] = 24.575175436732;t_precalcStrength['n']['h'] = 31.34416587945;t_precalcStrength['n']['i'] = 35.260244055958;t_precalcStrength['n']['k'] = 42.395009997506;t_precalcStrength['n']['l'] = 24.575175436732;t_precalcStrength['n']['m'] = 24.575175436732;t_precalcStrength['n']['n'] = 54.40946764336;t_precalcStrength['n']['p'] = 54.40946764336;t_precalcStrength['n']['q'] = 48.154472611832;t_precalcStrength['n']['r'] = 35.260244055958;t_precalcStrength['n']['s'] = 25.50772981461;t_precalcStrength['n']['t'] = 25.225861455393;t_precalcStrength['n']['v'] = 28.561267086612;t_precalcStrength['n']['w'] = 54.40946764336;t_precalcStrength['n']['y'] = 24.575175436732;t_precalcStrength['p']['a'] = 20.353692652058;t_precalcStrength['p']['c'] = 43.066057732232;t_precalcStrength['p']['d'] = 35.260244055958;t_precalcStrength['p']['e'] = 20.844876012496;t_precalcStrength['p']['f'] = 54.40946764336;t_precalcStrength['p']['g'] = 24.575175436732;t_precalcStrength['p']['h'] = 31.34416587945;t_precalcStrength['p']['i'] = 35.260244055958;t_precalcStrength['p']['k'] = 42.395009997506;t_precalcStrength['p']['l'] = 24.575175436732;t_precalcStrength['p']['m'] = 24.575175436732;t_precalcStrength['p']['n'] = 54.40946764336;t_precalcStrength['p']['p'] = 54.40946764336;t_precalcStrength['p']['q'] = 48.154472611832;t_precalcStrength['p']['r'] = 35.260244055958;t_precalcStrength['p']['s'] = 25.50772981461;t_precalcStrength['p']['t'] = 25.225861455393;t_precalcStrength['p']['v'] = 28.561267086612;t_precalcStrength['p']['w'] = 54.40946764336;t_precalcStrength['p']['y'] = 24.575175436732;t_precalcStrength['q']['a'] = 34.639588682129;t_precalcStrength['q']['c'] = 53.951399737082;t_precalcStrength['q']['d'] = 49.257385438694;t_precalcStrength['q']['e'] = 33.858758035763;t_precalcStrength['q']['f'] = 48.154472611832;t_precalcStrength['q']['g'] = 36.966741409703;t_precalcStrength['q']['h'] = 43.661053926385;t_precalcStrength['q']['i'] = 49.257385438694;t_precalcStrength['q']['k'] = 36.137525701776;t_precalcStrength['q']['l'] = 36.966741409703;t_precalcStrength['q']['m'] = 36.966741409703;t_precalcStrength['q']['n'] = 48.154472611832;t_precalcStrength['q']['p'] = 48.154472611832;t_precalcStrength['q']['q'] = 61.175822427701;t_precalcStrength['q']['r'] = 49.257385438694;t_precalcStrength['q']['s'] = 38.461869497048;t_precalcStrength['q']['t'] = 18.878763648421;t_precalcStrength['q']['v'] = 22.702065063071;t_precalcStrength['q']['w'] = 48.154472611832;t_precalcStrength['q']['y'] = 36.966741409703;t_precalcStrength['r']['a'] = 27.775347149814;t_precalcStrength['r']['c'] = 41.855546099553;t_precalcStrength['r']['d'] = 45.823199111111;t_precalcStrength['r']['e'] = 42.104501069128;t_precalcStrength['r']['f'] = 35.260244055958;t_precalcStrength['r']['g'] = 52.604844798097;t_precalcStrength['r']['h'] = 60.186240557383;t_precalcStrength['r']['i'] = 45.823199111111;t_precalcStrength['r']['k'] = 23.272866587324;t_precalcStrength['r']['l'] = 52.604844798097;t_precalcStrength['r']['m'] = 52.604844798097;t_precalcStrength['r']['n'] = 35.260244055958;t_precalcStrength['r']['p'] = 35.260244055958;t_precalcStrength['r']['q'] = 49.257385438694;t_precalcStrength['r']['r'] = 45.823199111111;t_precalcStrength['r']['s'] = 47.417279124496;t_precalcStrength['r']['t'] = 7.0786044250923;t_precalcStrength['r']['v'] = 5.1062953213999;t_precalcStrength['r']['w'] = 35.260244055958;t_precalcStrength['r']['y'] = 52.604844798097;t_precalcStrength['s']['a'] = 50.24328334011;t_precalcStrength['s']['c'] = 31.24966683069;t_precalcStrength['s']['d'] = 47.417279124496;t_precalcStrength['s']['e'] = 48.421713960905;t_precalcStrength['s']['f'] = 25.50772981461;t_precalcStrength['s']['g'] = 45.284680600725;t_precalcStrength['s']['h'] = 41.880157147049;t_precalcStrength['s']['i'] = 47.417279124496;t_precalcStrength['s']['k'] = 13.488746233845;t_precalcStrength['s']['l'] = 45.284680600725;t_precalcStrength['s']['m'] = 45.284680600725;t_precalcStrength['s']['n'] = 25.50772981461;t_precalcStrength['s']['p'] = 25.50772981461;t_precalcStrength['s']['q'] = 38.461869497048;t_precalcStrength['s']['r'] = 47.417279124496;t_precalcStrength['s']['s'] = 52.975945325148;t_precalcStrength['s']['t'] = -3.8433359650727;t_precalcStrength['s']['v'] = 0.37915290874912;t_precalcStrength['s']['w'] = 25.50772981461;t_precalcStrength['s']['y'] = 45.284680600725;t_precalcStrength['t']['a'] = -7.5041917681561;t_precalcStrength['t']['c'] = 13.807094727994;t_precalcStrength['t']['d'] = 7.0786044250923;t_precalcStrength['t']['e'] = -8.4392059304994;t_precalcStrength['t']['f'] = 25.225861455393;t_precalcStrength['t']['g'] = -5.4066548050812;t_precalcStrength['t']['h'] = 1.278605841779;t_precalcStrength['t']['i'] = 7.0786044250923;t_precalcStrength['t']['k'] = 41.170876967289;t_precalcStrength['t']['l'] = -5.4066548050812;t_precalcStrength['t']['m'] = -5.4066548050812;t_precalcStrength['t']['n'] = 25.225861455393;t_precalcStrength['t']['p'] = 25.225861455393;t_precalcStrength['t']['q'] = 18.878763648421;t_precalcStrength['t']['r'] = 7.0786044250923;t_precalcStrength['t']['s'] = -3.8433359650727;t_precalcStrength['t']['t'] = 39.674837575805;t_precalcStrength['t']['v'] = 43.557277873297;t_precalcStrength['t']['w'] = 25.225861455393;t_precalcStrength['t']['y'] = -5.4066548050812;t_precalcStrength['v']['a'] = -11.191528474216;t_precalcStrength['v']['c'] = 17.541687818383;t_precalcStrength['v']['d'] = 5.1062953213999;t_precalcStrength['v']['e'] = -4.5715503537188;t_precalcStrength['v']['f'] = 28.561267086612;t_precalcStrength['v']['g'] = 2.157180949214;t_precalcStrength['v']['h'] = 9.2859832173762;t_precalcStrength['v']['i'] = 5.1062953213999;t_precalcStrength['v']['k'] = 44.521067319218;t_precalcStrength['v']['l'] = 2.157180949214;t_precalcStrength['v']['m'] = 2.157180949214;t_precalcStrength['v']['n'] = 28.561267086612;t_precalcStrength['v']['p'] = 28.561267086612;t_precalcStrength['v']['q'] = 22.702065063071;t_precalcStrength['v']['r'] = 5.1062953213999;t_precalcStrength['v']['s'] = 0.37915290874912;t_precalcStrength['v']['t'] = 43.557277873297;t_precalcStrength['v']['v'] = 48.126818571993;t_precalcStrength['v']['w'] = 28.561267086612;t_precalcStrength['v']['y'] = 2.157180949214;t_precalcStrength['w']['a'] = 20.353692652058;t_precalcStrength['w']['c'] = 43.066057732232;t_precalcStrength['w']['d'] = 35.260244055958;t_precalcStrength['w']['e'] = 20.844876012496;t_precalcStrength['w']['f'] = 54.40946764336;t_precalcStrength['w']['g'] = 24.575175436732;t_precalcStrength['w']['h'] = 31.34416587945;t_precalcStrength['w']['i'] = 35.260244055958;t_precalcStrength['w']['k'] = 42.395009997506;t_precalcStrength['w']['l'] = 24.575175436732;t_precalcStrength['w']['m'] = 24.575175436732;t_precalcStrength['w']['n'] = 54.40946764336;t_precalcStrength['w']['p'] = 54.40946764336;t_precalcStrength['w']['q'] = 48.154472611832;t_precalcStrength['w']['r'] = 35.260244055958;t_precalcStrength['w']['s'] = 25.50772981461;t_precalcStrength['w']['t'] = 25.225861455393;t_precalcStrength['w']['v'] = 28.561267086612;t_precalcStrength['w']['w'] = 54.40946764336;t_precalcStrength['w']['y'] = 24.575175436732;t_precalcStrength['y']['a'] = 51.672531784327;t_precalcStrength['y']['c'] = 29.856824872338;t_precalcStrength['y']['d'] = 52.604844798097;t_precalcStrength['y']['e'] = 41.139593752458;t_precalcStrength['y']['f'] = 24.575175436732;t_precalcStrength['y']['g'] = 39.476487407462;t_precalcStrength['y']['h'] = 35.560533308816;t_precalcStrength['y']['i'] = 52.604844798097;t_precalcStrength['y']['k'] = 12.539144167802;t_precalcStrength['y']['l'] = 39.476487407462;t_precalcStrength['y']['m'] = 39.476487407462;t_precalcStrength['y']['n'] = 24.575175436732;t_precalcStrength['y']['p'] = 24.575175436732;t_precalcStrength['y']['q'] = 36.966741409703;t_precalcStrength['y']['r'] = 52.604844798097;t_precalcStrength['y']['s'] = 45.284680600725;t_precalcStrength['y']['t'] = -5.4066548050812;t_precalcStrength['y']['v'] = 2.157180949214;t_precalcStrength['y']['w'] = 24.575175436732;t_precalcStrength['y']['y'] = 39.476487407462
--Precalculated Table#

--#Calculations
local function _calc()
    local i
    local ii
    p("Getting Segment Score out of the Matrix")
    t_predictedStrength = {}
    for i = 1, i_segcount do
        t_predictedStrength[i] = {}
        for ii = i + 2, i_segcount - 2 do
            t_predictedStrength[i][ii] = t_precalcStrength[aa[i]][aa[ii]]
        end -- for ii
    end -- for i
end -- function

calc =
{   run = _calc
}
--Calculations#
--Amino#

--#External functions

report =
{
    status  = recipe.ReportStatus,
    start   = recipe.SectionStart,
    stop    = recipe.SectionEnd
}

--#Saveslot manager
local function _release(slot)
    t_sls[#t_sls + 1] = slot
end -- function

local function _request()
    assert(#t_sls > 0, "Out of save slots")
    local slot = t_sls[#t_sls]
    t_sls[#t_sls] = nil
    return slot
end -- function

sl =
{   release = _release,
    request = _request,
    -- renaming
    save    = save.Quicksave,
    load    = save.Quickload
}
--Saveslot manager#
--External functions#

--#Internal functions
--#Getters
local function _dists()
    local i
    local j
    if b_changed then
        distances = {}
        for i = 1, i_segcount - 1 do
            distances[i] = {}
            for j = i + 1, i_segcount do
                distances[i][j] = get.distance(i, j)
            end -- for j
        end -- for i
        b_changed = false
    end -- if b_changed
end -- function

local function _sphere(seg, radius)
    local sphere = {}
    get.dists()
    local i
    local _i
    local _seg
    for i = 1, i_segcount do
        if seg ~= i then
            _seg = seg
            _i = i
            if _i > seg then
                _i, _seg = seg, i
            end
            if distances[_i][_seg] <= radius and not t_selected[i] then
                sphere[#sphere + 1] = i
            end -- if get
        end -- if seg
    end -- for i
    return sphere
end -- function

local function _center()
    local minDistance = 10000
    local distance
    local indexCenter
    get.dists()
    for i = 1, i_segcount do
        distance = 0
        for j = 1, i_segcount do
            if i ~= j then
                local x = i
                local y = j
                if x > y then
                    x, y = y, x
                end
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
    local sc
    if step then
        if sc2 - sc1 < step then
            sl.load(slot)
            return
        end
    end
    if sc2 > sc1 then
        sc = sc2 - sc1
        if slot == sl_overall then
            if sc2 > sc_max then
                sl.save(slot)
                p("Gain: " .. sc)
                sc_max = get.score()
                p("==NEW=MAX=" .. sc_max .. "==")
            else
                sl.load(slot)
            end
        else
            sl.save(slot)
        end
        return true
    else -- if
        sl.load(slot)
        return false
    end -- if
end

local function _mutable()
    sl_before_mut = sl.request()
    sl.save(sl_before_mut)
    mutable = {}
    local isA = {}
    local i
    local j
    select.all()
    set.aa("a")
    get.aacid()
    for i = 1, i_segcount do
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
    p(#mutable .. " mutables found")
    if #mutable > 0 then
        b_mutable  = true
    end
    get.aacid()
    deselect.all()
    sl.load(sl_before_mut)
end -- function

local function _score()
    local s = 0
    if b_explore then
        s = score.current.rankedScore()
    else -- if
        s = score.current.energyScore()
    end -- if
    return s
end -- function

--#Hydrocheck
local function _hydro(s)
    if s then
        hydro[s] = get.hydrophobic(s)
    else -- if
        hydro = {}
        for i = 1, i_segcount do
            hydro[i] = get.hydrophobic(i)
        end -- for i
    end -- if
end -- function
--Hydrocheck#

--#Ligand Check
local function _ligand()
    if ss[i_segcount] == 'M' then
        i_segcount = i_segcount - 1
        if i_end_seg == i_segcount + 1 then
            i_end_seg = i_segcount
        end -- if i_end_seg
    end -- if get.ss
end -- function
--Ligand Check#

--#Structurecheck
local function _ss(s)
    if s then
        ss[s] = get.aa(s)
    else -- if
        ss = {}
        for i = 1, i_segcount do
            ss[i] = get.ss(i)
        end -- for i
    end
end -- function

local function _aa(s)
    if s then
        aa[s] = get.aa(s)
    else -- if
        aa = {}
        for i = 1, i_segcount do
            aa[i] = get.aa(i)
        end -- for i
    end -- if
end -- function

local function _struct()
    if b_ss_changed then
        get.secstr()
        local helix
        local sheet
        local loop
        he = {}
        sh = {}
        lo = {}
        for i = 1, i_segcount do
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
    b_ss_changed = false
    end -- if b_ss_changed
end -- function

local function _same(a, b)
    get.struct()
    local bool
    local a_s
    local b_s
    if ss[a] == "H" and ss[b] == "H" then
        for i = 1, #he do
            for ii = he[i][1], he[i][#he[i]] do
                if a == ii then
                    a_s = i
                end
                if b == ii then
                    b_s = i
                end
                if a_s == b_s and a_s and b_s then
                    return false
                end
            end
        end
    elseif ss[a] == "E" and ss[b] == "E" then
        for i = 1, #sh do
            for ii = sh[i][1], sh[i][#sh[i]] do
                if a == ii then
                    a_s = sh[i][1]
                end
                if b == ii then
                    b_s = sh[i][1]
                end
                if b_s == a_s and a_s and b_s then
                    return false
                end
            end
        end
    else
        return true
    end
end -- function

local function _checksame(a, b)
    if b_pp_struct then
        return get.samestruct(a, b)
    end
    return true
end
--Structurecheck#

local function _segscores()
    segs = {}
    local i
    for i = 1, i_segcount do
        segs[i] = score.current.segmentScore(i)
    end
end

local function _worst(len)
    local worst = 9999999
    get.segscores()
    for ii = 1, i_segcount - len + 1 do
        for i = 1, len - 1 do
            segs[ii] = segs[ii] + segs[ii + i]
        end
    end
    for i = 1, i_segcount - len + 1 do
        if segs[i] < worst then
            seg = i
            worst = segs[i]
        end -- if s
    end
    r = seg + len - 1
end

local function timeline(disp_time)
local disp_time_min = 0
    local disp_time_hour = 0
    while disp_time > 59 do
    disp_time_min = disp_time_min + 1
    disp_time = disp_time - 60
    if disp_time_min > 59 then
    disp_time_hour = disp_time_hour + 1
    disp_time_min = disp_time_min - 60
    end
    end
    if disp_time_hour < 10 then
    disp_time_hour = "0"..disp_time_hour
    end
    if disp_time_min < 10 then
    disp_time_min = "0"..disp_time_min
    end
    if disp_time < 10 then
    disp_time = "0"..disp_time
    end
    return (disp_time_hour..":" .. disp_time_min .. ":" .. disp_time)
end

local function _time()
    currentTimeUsed = os.time()
    --[[if currentTimeUsed - startTime > (60 + time_used*60) then
    time_used = time_used + 1]]
    local disp_time = currentTimeUsed - startTime
    estimated_time = math.floor(disp_time * time_mod + 0.5) - disp_time
    p("Time elapsed: " .. timeline(disp_time) .. "; Recipe finished ".. progress .. "%")
    if estimated_time > 0 then
        p("approx. time till that recipe is finished: " .. timeline(estimated_time))
        p(os.date("Recipe will be approx. finished: %a, %c", estimated_time + currentTimeUsed))
    else
        p("calculating approx. finish of this recipe")
    end
    p("==MAX SCORE=" .. sc_max .. "==")
    --end
end

local function _report(start1, end1, iter1, vari1, start2, end2, iter2, vari2)
    if start2 == nil then
        if iter1 == 1 then
            time_mod = (end1 - vari1) / vari1
            progress = math.floor(vari1 / end1, 3)
            get.checkTime()
        end
    else
        if iter1 == -1 then
            local start = (vari2 +(start1 - vari1) *end2)--progress.getStart(i_will_be, 1, -1, i, 1, #amino.segs, 1, ii)
            local stop = (end2 - vari2+ end2 * vari1)
            time_mod = stop / start
            progress = math.floor(start / (start1 * end2), 3)
            get.checkTime()
        end
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
    samestruct  = _same,
    checkTime   = _time,
    checksame   = _checksame,
    segscores   = _segscores,
    worst       = _worst,
    report        = _report,
    -- renaming
    distance        = structure.GetDistance,
    ss              = structure.GetSecondaryStructure,
    aa              = structure.GetAminoAcid,
    segcount        = structure.GetCount,
    bandcount       = band.GetCount,
    hydrophobic     = structure.IsHydrophobic,
    snapcount       = rotamer.GetCount,
    clashImportance = behavior.GetClashImportance,
    wiggleAccuracy  = behavior.GetWiggleAccuracy,
    shakeAccuracy   = behavior.GetShakeAccuracy
}
--Getters#

--#Doers
local function _freeze(f)
    if f == "b" then
        freeze.FreezeSelected(true, false)
    elseif f == "s" then
        freeze.FreezeSelected(false, true)
    else -- if
        freeze.FreezeSelected(true, true)
    end -- if
end -- function

local function _mutate(mut, aa, more)
    local sc_mut1 = get.score()
    local i
    select.segs(mutable[mut])
    set.aa(amino.segs[aa])
    sl.save(sl_mut)
    get.aacid()
    p(#amino.segs - aa .. " Mutations left")
    p("Mutating seg " .. mutable[mut] .. " to " .. amino.long(mutable[mut]))
    if b_m_after then
        select.list(mutable)
        deselect.index(mutable[mut])
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
                    deselect.index(mutable[i])
                end
            end
        end
        set.clashImportance(i_m_cl_mut)
        structure.MutateSidechainsSelected(1)
    end
    if b_m_re then
        if b_m_re_deep_rebuild then
            seg = mutable[mut] - 2
            r = seg + 4
            if not b_re_m_ignore_struct then
                if ss[mutable[mut]] == "L" then
                    rebuild(mutable[mut])
                end
            else
                rebuild(mutable[mut])
            end
            seg = mutable[mut] - 2
            r = seg + 3
            if not b_re_m_ignore_struct then
                if ss[mutable[mut]] == "L" then
                    rebuild(mutable[mut])
                end
            else
                rebuild(mutable[mut])
            end
        else
            seg = mutable[mut] - 1
            r = seg + 2
            if not b_re_m_ignore_struct then
                if ss[mutable[mut]] == "L" then
                    rebuild(mutable[mut])
                end
            else
                rebuild(mutable[mut])
            end
        end
    elseif b_m_opt then
        if not sidechain_tweak(mutable[mut]) then
			b_tweaking = true
			fuze.start(sl_mut)
			b_tweaking = false
		end
	end
    local sc_mut2 = get.score()
    if not more then
        if get.increase(sc_mut1, sc_mut2, sl_overall) then
        end
    end
end -- function

do_ =
{   freeze      = _freeze,
    mutate      = _mutate,
    -- renaming
    rebuild     = structure.RebuildSelected,
    snap        = rotamer.SetRotamer,
    unfreeze    = freeze.UnfreezeAll
}
--Doers#

--#Fuzing
local function _loss(option, cl1, cl2)
    if option == 1 then
        if not b_tweaking then work.step("s", 1, cl1) end
        work.step("wa", 2, cl2)
        work.step("wa", 1, 1)
        work.step("s", 1, 1)
        work.step("wa", 1, cl2)
        work.step("wa", 2, 1)
    elseif option == 2 then
        work.step("s", 1, 1)
        work.step("wa", 2, 1)
    else
	score.recent.save()
        if b_tweaking then work.step("wa", 2, 1) end
        if work.step("s", 1, cl1) then work.step("wa", 2, 1) end
        if work.step("s", 1, cl2) then work.step("wa", 2, 1) end
        if work.step("s", 1, cl1 - 0.02) then work.step("wa", 2, 1) end
        if work.step("s", 1, 1) then work.step("wa", 2, 1) end
    score.recent.restore()
    end -- if option
end -- function

local function _part(option, cl1, cl2)
    local s_f1 = get.score()
    fuze.loss(option, cl1, cl2)
    local s_f2 = get.score()
    get.increase(s_f1, s_f2, sl_f)
end -- function

local function _start(slot)
    sl_f = sl.request()
    local s_f1 = get.score()
    sl.save(sl_f)
    if b_fuze_pf and 1 > 0.8 or b_tweaking then
        fuze.part(1, 0.1, 0.6)
    elseif b_fuze_bf and 1 > 0.8 then
        fuze.part(3, 0.05, 0.07)
    else
        fuze.part(2)
    end
    sl.load(sl_f)
    local s_f2 = get.score()
    sl.release(sl_f)
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
    local i
    if sphered ~= false and sphered ~= true then
        local temp = start
        start = sphered
        sphered = nil
        if start then
            _end, temp = temp, _end
            if _end then
                more = temp
            end
        end
    end
    if not more then
        deselect.all()
    end -- if more
    if start then
        if sphered or b_sphered then
            local list1
            if _end then
                if start ~= _end then
                    if start > _end then
                        start, _end = _end, start
                    end -- if > end
                    select.range(start, _end)
                    for i = start, _end do
                        list1 = get.sphere(i, 10)
                        select.list(list1)
                    end -- for i
                end -- if ~= end
            end -- if _end
            list1 = get.sphere(start, 10)
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

local function _list(_list)
    local i
    if _list then
        for i = 1, #_list do
            select.index(_list[i])
        end -- for
    end -- if _list
end -- function

local function _range(a, b)
    local i
    local bool
    for i = a, b do
        if not t_selected[i] then
            bool = true
        end
    end
    if bool then
        selection.SelectRange(a, b)
        for i = a, b do
            t_selected[i] = true
        end
    end
end

local function _index(a)
    if not t_selected[a] then
        selection.Select(a)
        t_selected[a] = true
    end
end

local function _all()
    for i = 1, i_segcount do
        t_selected[i] = true
    end
    selection.SelectAll()
end

select =
{   segs    = _segs,
    list    = _list,
    index   = _index,
    range   = _range,
    all     = _all
}
--Universal select#

--#working
local function _step(a, iter, cl, more)
    local s1
    local s2
    if more ~= false then
    if a == "s" then
        if b_sphering or b_mutating then
            select.segs(true, seg, r)
        else -- if b_sphering
            select.segs()
        end -- if b_sphering
    else -- if a
        if b_sphered or b_mutating then
            select.segs(true, seg, r)
        end
        b_changed = true
    end -- if a
    end -- if
    if cl then
        set.clashImportance(cl)
    end
    local _s1 = get.score()
    if a == "wa" then
        wiggle.all_sel(iter)
    elseif a == "s" then
        wiggle.shake_sel(2)
    elseif a == "wb" then
        wiggle.back_sel(iter)
    elseif a == "ws" then
        wiggle.side_sel(iter)
    elseif a == "wl" then
        select.segs(seg, r)
        score.recent.save()
        s1 = get.score()
        wiggle.l_sel(iter)
        s2 = get.score()
        if s2 < s1 then
            score.recent.restore()
        end
    end -- if a
    local _s2 = get.score()
    if _s1 - _s2 < -0.15 or _s1-_s2 > 0.15 then
        return true
    else
        return false
    end
end -- function

local function _flow(a, more)
    local ws_1 = get.score()
    local iter = 0
    if b_sphering then
        slot = sl_re
    elseif b_mutating then -- if
        slot = sl_mut
    else
        slot = sl_overall
    end -- if
    work_sl = sl.request()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            sl.save(work_sl)
        end -- if iter
        s1 = get.score()
        work.step(a, iter)
        s2 = get.score()
    until s2 - s1 < (0.01 * iter)
    if s2 < s1 then
        sl.load(work_sl)
    else -- if <
        s1 = s2
    end -- if <
    sl.release(work_sl)
    if not more then
        get.increase(ws_1, s1, slot, i_score_change)
    end -- if not more
end -- function

function _quake(ii)
    if get.score() < 0 then
        bands.disable()
        fuze.start(sl_overall)
        bands.enable()
    end -- if s3 < 0
    local s3 = math.floor(get.score() / 50 * i_pp_loss, 4)
    local t_predictedStrength = 0.1 + 0.1 * i_pp_loss
    local cbands = get.bandcount()
    local quake = sl.request()
    if seg or r then
        select.segs(seg, r)
    else -- if seg
        select.segs()
    end -- if seg
    if b_pp then
        if b_pp_pre_local then
            s3 = math.floor(s3 * 4 / cbands, 4)
            t_predictedStrength = math.floor(t_predictedStrength * 4 / cbands, 4)
        end -- if
        if b_solo_quake then
            bands.disable()
            bands.enable(ii)
            s3 = math.floor(s3 * 2, 4)
            t_predictedStrength = math.floor(t_predictedStrength * 2, 4)
        end -- if b_solo_quake
    end -- if b_pp
    if b_cu then
        s3 = math.floor(s3 / 10, 4)
    end -- if b_cu
    if s3 > 200 * i_pp_loss then
        s3 = 200 * i_pp_loss
    end -- if s3
    if t_predictedStrength > 0.2 * i_pp_loss then
        t_predictedStrength = 0.2 * i_pp_loss
    end -- if t_predictedStrength
    p("Pulling until a loss of more than " .. s3 .. " points")
    local s1 = get.score()
    repeat
        p("Band strength: " .. t_predictedStrength)
        if b_solo_quake then
            bands.strength(ii, t_predictedStrength)
        else -- if b_solo
            for i = 1, cbands do
                if bands.info[i][bands.part.enabled] then
                    bands.strength(i, t_predictedStrength)
                end
            end -- for
        end -- if b_solo
        score.recent.save()
        set.clashImportance(1)
        wiggle.back_sel(1)
        sl.save(quake)
        score.recent.restore()
        local s2 = get.score()
        if s2 > s1 then
            score.recent.restore()
            sl.save(sl_overall)
        end -- if >
        sl.load(quake)
        local s2 = get.score()
        t_predictedStrength = math.floor(t_predictedStrength * 2 - t_predictedStrength * 10 / 11, 4)
        if b_pp_pre_local or b_cu or b_solo_quake then
            t_predictedStrength = math.floor(t_predictedStrength * 2 - t_predictedStrength * 6 / 7, 4)
        end -- if b_solo
        if t_predictedStrength > 10 then
            break
        end -- if t_predictedStrength
    until s1 - s2 > s3
    sl.release(quake)
end -- function

local function _dist()
    select.segs()
    local ps_1 = get.score()
    sl.save(sl_overall)
    dist = sl.request()
    local bandcount = get.bandcount()
    if b_solo_quake then
        p("Solo quaking enabled")
        b_sphering = true
        for ii = 1, bandcount do
            ps_1 = get.score()
            sl.save(dist)
            work.quake(ii)
            if b_pp_mutate then
                select.all()
                structure.MutateSidechainsSelected(1)
            end -- if b_pp_mutate
            bands.delete(ii)
            if b_pp_fuze then
                fuze.start(dist)
            else
                work.step("wa", 3)
            end
            ps_2 = get.score()
            get.increase(ps_1, ps_2, sl_overall)
        end -- for ii
        b_sphering = false
    else -- if b_solo_quake
        sl.save(dist)
        work.quake()
        bands.disable()
        if b_pp_fuze then
            fuze.start(dist)
        else
            work.step("wa", 3)
        end
        ps_2 = get.score()
        if not b_evo then
            get.increase(ps_1, ps_2, sl_overall)
        end
    end -- if b_solo_quake
    sl.release(dist)
end -- function

local function _rebuild(trys, str)
    local iter = 1
    for i = 1, trys do
        local re1 = get.score()
        local re2 = re1
        while re1 == re2 do
            do_.rebuild(iter * str)
            work.step("s", 1, 0, false)
            iter = iter + 1
            re2 = get.score()
            if iter > 10 then
            p("Rebuilding aborted! Backbone unrebuildable")
            return false
            end
        end -- while
        iter = 1
    end -- for i
    b_changed = true
    return true
end -- function

work =
{   flow    = _flow,
    step    = _step,
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
            if x > y then
                x, y = y, x
            end -- if x
            if hydro[i] then
                if get.checksame(x, y) then
                    bands.addToSegs(x, y)
                    if b_pp_soft then
                        local cband = get.bandcount()
                        bands.length(cband, distances[x][y] - i_pp_len)
                    end -- if b_pp_soft
                end -- if checksame
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
            if x > y then
                x, y = y, x
            end -- if x
            if not hydro[i] then
                if distances[x][y] <= (20 - i_pp_len) then
                    if get.checksame(x, y) then
                        bands.addToSegs(x, y)
                        local cband = get.bandcount()
                        bands.length(cband, distances[x][y] + i_pp_len)
                    end -- if checksame
                end -- if distances
            end -- if hydro
        end -- if ~=
    end -- for
end -- function
--Center#

local function _ps(_local, bandsp)
    local c_temp
    get.segs(_local)
    get.dists()
    for x = start, _end - 2 do
        if not hydro[x] then
            for y = x + 2, _end do
                if not hydro[y] then
                    if b_pp_area then
                        if distances[x][y] < i_pp_area_range then
                                if distances[x][y] <= (20 - i_pp_len) then
                                    if get.checksame(x, y) then
                                        bands.add(x, y)
                                        local cband = get.bandcount()
                                        bands.length(cband, distances[x][y] + i_pp_len)
                                    end
                                end
                        end
                    else
                        if math.random() <= bandsp then
                            if distances[x][y] <= (20 - i_pp_len) then
                                if get.checksame(x, y) then
                                    bands.add(x, y)
                                    local cband = get.bandcount()
                                    bands.length(cband, distances[x][y] + i_pp_len)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function _pl(_local, bandsp)
    get.segs(_local)
    get.dists()
    if b_pp_fixed then
        for x = start, _end do
            if hydro[x] then
                for y = i_pp_fix_start, i_pp_fix_end do
                    if hydro[y] then
                        if math.random() < bandsp then
                            if get.checksame(x, y) then
                                bands.addToSegs(x, y)
                                if b_pp_soft then
                                    local cband = get.bandcount()
                                    bands.length(cband, distances[x][y] - i_pp_len)
                                end -- b_pp_soft
                            end -- if checksame
                        end -- if random
                    end -- if hydro[y]
                end -- for y
            end -- if hydro[x]
        end -- for x
    end -- if b_pp_fixed
    for x = start, _end - 2 do
        if hydro[x] then
            for y = x + 2, i_segcount do
                if hydro[y] then
                    if b_pp_area then
                        if distances[x][y] < i_pp_area_range then
                            if get.checksame(x, y) then
                                bands.add(x, y)
                                if b_pp_soft then
                                    local cband = get.bandcount()
                                    bands.length(cband, distances[x][y] - i_pp_len)
                                end -- if b_pp_soft
                            end -- if checksame
                        end -- distances < 5
                    else -- if b_pp_area
                        if math.random() < bandsp then
                            if get.checksame(x, y) then
                                bands.addToSegs(x, y)
                                if b_pp_soft then
                                    local cband = get.bandcount()
                                    bands.length(cband, distances[x][y] - i_pp_len)
                                end -- if b_pp_soft
                            end -- if checksame
                        end -- if random
                    end -- if b_pp_area
                end -- hydro y
            end -- for y
        end -- if hydro x
    end -- for x
end -- function

local function _strong(_local)
    get.segs(_local)
    get.dists()
    for i = start, _end do
        local max_str = 0
        local min_dist = 999
        for ii = i + 2, i_segcount - 2 do
            if max_str <= t_predictedStrength[i][ii] then
                if max_str ~= t_predictedStrength[i][ii] then
                    min_dist = 999
                end -- if max_str ~=
                max_str = t_predictedStrength[i][ii]
                if min_dist > distances[i][ii] then
                    min_dist = distances[i][ii]
                end -- if min_dist
            end -- if max_str <=
        end -- for ii
        for ii = i + 2, i_segcount - 2 do
            if t_predictedStrength[i][ii] == max_str and min_dist == distances[i][ii] then
                if get.checksame(i, ii) then
                    bands.addToSegs(i , ii)
                    if b_pp_soft then
                        local cband = get.bandcount()
                        bands.length(cband, distances[i][ii] - i_pp_len)
                    end -- if pp_soft
                end -- if get.checksame
            end -- if t_predictedStrength
        end -- for ii
    end -- for i
end -- function

local function _one(_seg)
    get.dists()
    local max_str = 0
    for ii = _seg + 2, i_segcount - 2 do
        if max_str <= t_predictedStrength[_seg][ii] then
            max_str = t_predictedStrength[_seg][ii]
        end -- if max_str <=
    end -- for ii
    for ii = _seg + 2, i_segcount - 2 do
        if t_predictedStrength[_seg][ii] == max_str then
            if get.checksame(_seg, ii) then
                bands.addToSegs(_seg , ii)
                if b_pp_soft then
                    local cband = get.bandcount()
                    bands.length(cband, distances[_seg][ii] - i_pp_len)
                end
            end
        end -- if t_predictedStrength
    end -- for ii
end -- function

local function _helix(_he)
    local i
    local ii
    if _he then
        for i = he[_he][1], he[_he][#he[_he]] - 4 do
            bands.addToSegs(i, i + 4)
        end -- for i
        for i = he[_he][1], he[_he][#he[_he]] - 3 do
            bands.addToSegs(i, i + 3)
        end -- for i
    else
        for i = 1, #he do
            for ii = he[i][1], he[i][#he[i]] - 4 do
                bands.addToSegs(ii, ii + 4)
            end -- for ii
            for ii = he[i][1], he[i][#he[i]] - 3 do
                bands.addToSegs(ii, ii + 3)
            end -- for ii
        end -- for i
    end -- if _he
end -- function

local function _sheet(_sh)
    if _sh then
        for ii = sh[_sh][1], sh[_sh][#sh[_sh]] - 1 do
            bands.addToSegs(ii - 1, ii + 2)
            local cbands = get.bandcount()
            bands.strength(cbands, 10)
            bands.length(cbands, 100)
        end -- for ii
    else
        for i = 1, #sh do
            for ii = 1, #sh[i] - 1 do
                bands.addToSegs(sh[i][ii] - 1, sh[i][ii] + 2)
                local cbands = get.bandcount()
                bands.strength(cbands, 10)
                bands.length(cbands, 100)
            end -- for ii
        end -- for i
    end
end -- function

local function _comp_sheet()
    for i = 1, #sh - 1 do
        bands.addToSegs(sh[i][1], sh[i + 1][#sh[i + 1]])
        local cbands = get.bandcount()
        bands.strength(cbands, 10)
        bands.addToSegs(sh[i][#sh[i]], sh[i + 1][1])
        local cbands = get.bandcount()
        bands.strength(cbands, 10)
    end -- for i
end -- function

local function _rndband(vib)
    get.dists()
    local start  = math.floor(math.random() * (i_segcount - 1)) + 1
    local finish = math.floor(math.random() * (i_segcount - 1)) + 1
    if start > finish then
        start, finish = finish, start
    end
    if b_pp_area then
    if start ~= finish and math.abs(start - finish) >= 5 and distances[start][finish] < i_pp_area_range then
        bands.addToSegs(start, finish)
        local n = get.bandcount()
        local length = 3 + (math.random() * (distances[start][finish] + 2))
        if hydro[start] and hydro[finish] then
            length = 2 + (math.random() * (get.distance(start, finish) / 2))
        end
        if length < 0 then length = 0 end
        if n > 0 then bands.length(n, length) end
    else
        bonding.rnd()
    end
    else
    if start ~= finish and math.abs(start - finish) >= 5 then
        bands.addToSegs(start, finish)
        local n = get.bandcount()
        local length = 3 + (math.random() * (distances[start][finish] + 2))
        if hydro[start] and hydro[finish] then
            length = 2 + (math.random() * (get.distance(start, finish) / 2))
        end
        if length < 0 then length = 0 end
        if n > 0 then bands.length(n, length) end
    else
        bonding.rnd()
    end
    end
end

local function _vib()
    get.dists()
    local i
    local _i
    local ii
    local iii
    local list
    local bandcount
    for i = 1, i_segcount do
        list = get.sphere(i, 15)
        for ii = 1, #list do
            _i = i
            bandcount = get.bandcount()
            bool = true
            for iii = 1, bandcount do
                if (bands.info[iii][start] == i and bands.info[iii][_end] == list[ii]) or (bands.info[iii][_end] == i and bands.info[iii][start] == list[ii]) then
                    bool = false
                end
            end
            if bool then
                bands.addToSegs(i, list[ii])
                if list[ii] < i then
                    list[ii], _i = i, list[ii]
                end
                bandcount = get.bandcount()
                bands.length(bandcount, distances[_i][list[ii]] + math.random(-0.1, 0.1))
            end
        end
    end
end

local function _bonds(range, pts)
    local i
    local _i
    local ii
    local list
    local bandcount
    local iii
    local bool
    get.dists()
    for i = 1, i_segcount do
        list = get.sphere(i, range)
        for ii = 1, #list do
            if list[ii] ~= i and list[ii] + 1 ~= i and list[ii] - 1 ~= i then
                if list[ii] < i then
                    _i, list[ii] = list[ii], i
                else
                    _i = i
                end
                if score.current.segmentScorePart(_i, "bonding") == score.current.segmentScorePart(list[ii], "bonding") and score.current.segmentScorePart(list[ii], "bonding") ~= 0 then
                    bands.addToSegs(_i, list[ii])
                end
            end
        end
    end
end

local function _void(a)
    p("Banding segment " .. a)
    get.dists()
    local t = {}
    for b = 1, i_segcount do
        if a > b then
           a, b = b, a
        end -- if x
        local ab = distances[a][b]
        if ab > 3 then
            local void = true
            for c = 1, i_segcount do
            if a > c then
           a, c = c, a
        end -- if x
        if b > c then
           b, c = c, b
        end -- if x
                local ac = distances[a][c]
                local bc = distances[b][c]
                if ac ~= 0 and bc ~= 0 and ac < ab and bc < ab and ac > 4 and bc > 4 then
                    if ac + bc < ab + 1.5 then
                        void = false
                        break
                    end
                end
            end
            if void then
                if math.abs(a - b) >= 3 then
                    t[#t + 1] = {a, b}
                end
            end
        end
    end
    if #t > 0 then
        p("Found " .. #t .. " possible bands across voids")
        for i = 1, #t do
            band.addToSegs(t[i][1], t[i][2])
        end
        return true
    else
        p("No voids found")
        return false
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
    vib         = _vib,
    bonds       = _bonds,
    void        = _void,
    matrix      =
    {   strong  = _strong,
        one     = _one
    }
}
--Bonding#
--Header#

--#Snapping
function snap()
    b_tweaking = true
    b_sphering = true
    sl_snaps = sl.request()
    cs = get.score()
    c_snap = cs
    local s_1
    local s_2
    local c_s
    local c_s2
    sl.save(sl_snaps)
    sidechain_tweak(seg)
    get.increase(cs, get.score(), sl_snaps)
    iii = get.snapcount(seg)
    p("Snapcount: " .. iii .. " - segment " .. seg)
    if iii > 1 then
        snapwork = sl.request()
        ii = 1
        while ii <= iii do
            sl.load(sl_snaps)
            c_s = get.score()
            c_s2 = c_s
            do_.snap(seg, ii)
            c_s2 = get.score()
            sl.save(snapwork)
            select.segs(true, seg)
            fuze.start(snapwork)
            if c_snap < get.score() then
                c_snap = get.score()
                sl.save(sl_snaps)
            end
            ii = ii + 1
        end
        sl.load(snapwork)
        sl.release(snapwork)
        if cs < c_snap then
            sl.save(sl_snaps)
            c_snap = get.score()
        else
            sl.load(sl_snaps)
        end
    else
        p("Skipping...")
    end
    if cs < get.score() then
    sl.load(sl_snaps)
    else
    sl.save(sl_snaps)
    cs = get.score()
    end
    b_sphering = false
    b_tweaking = false
    sl.release(sl_snaps)
    if mutated then
        s_snap = get.score()
        if s_mut < s_snap then
            sl.save(sl_overall)
        else
            sl.load(sl_mut)
        end
    else
        sl.save(sl_overall)
    end
end
--Snapping#

--#Rebuilding
function rebuild(tweaking_seg)
    local iter = 1
    b_sphering = true
    sl_re = sl.request()
    sl.save(sl_re)
    while seg < 1 do
        seg = seg + 1
    end
    while r > i_segcount do
    r = r - 1
    end
    if b_sphered then
        select.segs(true, seg, r)
    else
        select.segs(seg, r)
    end
    if r == seg then
        p("Rebuilding Segment " .. seg)
    else -- if r
        p("Rebuilding Segment " .. seg .. "-" .. r)
    end -- if r
    rs_0 = get.score()
    local sl_r = {}
    local ii
    for ii = 1, i_re_trys do
        if not work.rebuild(i_max_rebuilds, i_rebuild_str) then
            sl.load(sl_re)
            sl.release(sl_re)
            b_sphering = false
            if math.abs(seg - r) == 2 then
                p("Detected rebuild length of 3; splitting to 2x2")
                seg = seg + 1
                rebuild()
                seg = seg - 1
                r = r - 1
                rebuild()
            end
            sl_r = nil
            return
        end
        sl_r[ii] = sl.request()
        sl.save(sl_r[ii])
    end
    set.clashImportance(1)
    local slot
    if b_mutating then
        slot = sl_mut
    else
        slot = sl_overall
    end
    for ii = 1, #sl_r do
        sl.load(sl_r[ii])
        sl.release(sl_r[ii])
        sl_r[ii] = nil
        if rs_1 ~= get.score() then
            rs_1 = get.score()
            if rs_1 ~= rs_0 then
                p("Stabilize try "..ii)
                fuze.start(sl_re)
                rs_2 = get.score()
                if (sc_max - rs_2 ) < 30 then
                    if b_re_extreme_tweak then
                        for i = seg, r do
                            sidechain_tweak(i)
                        end
                    else
                    sidechain_tweak(tweaking_seg)
                    end
                end
                if get.increase(rs_0, rs_2, slot) then
                    rs_0 = get.score()
                end
            end
        end
    end
    sl.load(slot)
    sl_r = nil
    sl.release(sl_re)
    b_sphering = false
end -- function
--Rebuilding#

function evolution()
    b_evo = true
    local i
    for i = 1, 50 do
        bonding.rnd()
    end
    bands.disable()
    for i = 1, i_pp_evos do
        local bandcount = get.bandcount()
        local rnd = math.floor(math.random() * 5) + 2
        for ii = 1, rnd do
            local cband = math.floor(math.random() * (bandcount - 1)) + 1
            if bands.info[cband][bands.part.enabled] == true then
                ii = ii - 1
            end
            bands.enable(cband)
        end
        work.dist()
    end
    b_evo = false
end

--#Pull
function dists()
    sl.save(sl_overall)
    dist_score = get.score()
    bands.delete()
    if b_pp_vibrator then
    for i = 1, 1 do
for iiiii = 0, 180, 45 do
for iiii = 0, 360, 45 do
bands.addToArea(i, i + 1, i + 2, 5, math.rad(iiiii),math.rad(iiii))
end
end
end
work.dist()
        bands.delete()
end
    if b_pp_pre_strong then
        bonding.matrix.strong()
        work.dist()
        bands.delete()
    end -- if b_pp_predicted
    if b_pp_pre_local then
        for i = i_start_seg, i_end_seg do
            bonding.matrix.one(i)
            work.dist()
            bands.delete()
        end
    end -- if b_pp_predicted
    if b_pp_push_pull then
        bonding.pull(b_pp_local, i_pp_bandperc / 2)
        p(i_pp_bandperc)
        bonding.push(b_pp_local, i_pp_bandperc)
        work.dist()
        bands.delete()
    end -- if b_pp_combined
    if b_pp_evo then
        evolution()
    end -- if b_pp_rnd
    if b_pp_pull then
        bonding.pull(b_pp_local, i_pp_bandperc)
        work.dist()
        bands.delete()
    end -- if b_pp_pull
    if b_pp_centerpull then
        bonding.centerpull(b_pp_local)
        work.dist()
        bands.delete()
    end -- if b_pp_centerpull
    if b_pp_c_push_pull then
        bonding.centerpush(b_pp_local)
        bonding.centerpull(b_pp_local)
        work.dist()
        bands.delete()
    end -- if b_pp_centerpull
    --[[if b_pp_vibrator then
        bonding.vib()
        work.dist()
        bands.delete()
    end]]--
    if b_pp_bonds then
        bonding.bonds(12, 10)
        bonding.bonds(5, 2)
        work.dist()
        bands.delete()
    end
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
    while i < i_segcount do
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
                if i + 1 < i_segcount then
                    if aa[i + 1] ~= "p" then
                        p_he[#p_he][#p_he[#p_he] + 1] = i + 1
                        if i + 2 < i_segcount then
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
                if i + 1 < i_segcount then
                    p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 1
                end -- if i + 1
                if i + 2 < i_segcount then
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
    p("Found " .. #p_he .. " Helix and " .. #p_sh .. " Sheet parts... Combining...")
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
    predict.combine()
    b_ss_changed = true
    sl.save(sl_overall)
end

local function _combine()
    for i = 1, i_segcount - 1 do
        get.struct()
        deselect.all()
        if ss[i] == "L" then
            if aa[i] ~= "p" then
                for ii = 1, #he - 1 do
                    if b_pre_comb_str then
                        for iii = he[ii][1], he[ii][#he[ii]] do
                            if iii + 1 == i and he[ii + 1][1] == i + 1 then
                                select.segs(i)
                            end -- if iii
                        end -- for iii
                    end -- if b_pre
                end
                for ii = 1, #he do
                    if b_pre_add_pref then
                        for iii = he[ii][1] - 1, he[ii][#he[ii]] + 1, he[ii][#he[ii]] - he[ii][1] + 1 do
                            if iii > 0 and iii <= i_segcount then
                                if amino.preffered(iii) == "H" then
                                    select.segs(iii)
                                end -- if iii
                            end -- if iii
                        end -- for iii
                    end -- if b_pre
                end -- for ii
                set.ss("H")
                deselect.all()
            end -- if aa
            if b_pre_comb_str then
                for ii = 1, #sh - 1 do
                    for iii = sh[ii][1], sh[ii][#sh[ii]] do
                        if iii + 1 == i and sh[ii + 1][1] == i + 1 then
                            select.segs(i)
                        end -- if iii
                    end -- for iii
                end -- for ii
            end -- if b_pre
            if b_pre_add_pref then
                for ii = 1, #sh do
                    for iii = sh[ii][1] - 1, sh[ii][#sh[ii]] + 1, sh[ii][#sh[ii]] - sh[ii][1] + 1 do
                        if iii > 0 and iii <= i_segcount then
                            if amino.preffered(iii) == "E" then
                                select.segs(iii)
                            end -- if iii
                        end
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
    local i
    str_re_best = sl.request()
    get.struct()
    p("Found " .. #he .. " Helixes " .. #sh .. " Sheets and " .. #lo .. " Loops")
    if b_cu_he then
        for i = 1, #he do
            if #he[i] > 3 then
                p("Working on Helix " .. i)
                seg = he[i][1] - 2
                if seg < 1 then
                    seg = 1
                end -- if seg
                r = he[i][#he[i]] + 2
                if r > i_segcount then
                    r = i_segcount
                end -- if r
                select.segs(seg, r)
                bonding.helix(i)
                b_sphering = true
                work.dist()
                bands.delete()
                b_sphering = false
            end
        end -- for i
    end -- if b_cu_he
    if b_cu_sh then
        for i = 1, #sh do
            if #sh[i] > 2 then
                p("Working on Sheet " .. i)
                seg = sh[i][1] - 2
                if seg < 1 then
                    seg = 1
                end -- if seg
                r = sh[i][#sh[i]] + 2
                if r > i_segcount then
                    r = i_segcount
                end -- if r
                bonding.sheet(i)
                select.segs(seg, r)
                b_sphering = true
                work.dist()
                bands.delete()
                b_sphering = false
            end
        end -- for i
    end -- if b_cu_sh
    sl.release(str_re_best)
    sl.save(sl_overall)
end

function struct_rebuild()
    local str_rs
    local str_rs2
    str_re_best = sl.request()
    get.struct()
    p("Found " .. #he .. " Helixes " .. #sh .. " Sheets and " .. #lo .. " Loops")
    if b_re_he then
        deselect.all()
        for i = 1, #sh do
            select.list(sh[i])
        end -- for i
        set.ss("L")
        for i = 1, #he do
            p("Working on Helix " .. i)
            seg = he[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = he[i][#he[i]] + 2
            if r > i_segcount then
                r = i_segcount
            end -- if r
            bonding.helix(i)
            deselect.all()
            select.range(seg, r)
            set.clashImportance(0.4)
            wiggle.back_sel(1)
            set.clashImportance(0)
            work.rebuild(i_str_re_max_re, i_str_re_re_str)
            set.clashImportance(0.4)
            wiggle.back_sel(1)
            set.clashImportance(1)
            work.rebuild(i_str_re_max_re, i_str_re_re_str)
            set.clashImportance(0.4)
            wiggle.back_sel(1)
            bands.delete()
            if b_str_re_fuze then
                b_sphering = true
                fuze.start(str_re_best)
                sl.load(str_re_best)
                b_sphering = false
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
            p("Working on Sheet " .. i)
            seg = sh[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = sh[i][#sh[i]] + 2
            if r > i_segcount then
                r = i_segcount
            end -- if r
            bonding.sheet(i)
            deselect.all()
            select.range(seg, r)
            set.clashImportance(0.1)
            wiggle.back_sel(1)
            set.clashImportance(0.4)
            wiggle.back_sel(1)
            bands.delete()
            if b_str_re_fuze then
                b_sphering = true
                fuze.start(str_re_best)
                sl.load(str_re_best)
                b_sphering = false
            end -- if b_str_re_fuze
        end -- for i
        deselect.all()
        for i = 1, #he do
            select.list(he[i])
        end -- for i
        set.ss("H")
        bonding.comp_sheet()
    end -- if b_re_sh
    sl.save(sl_overall)
    sl.release(str_re_best)
end

--#Mutate function
function mutate()
    b_mutating = true
    local i
    local ii
    get.dists()
    local i_will_be = #mutable - 5
    for i = i_will_be, 1, -1 do
        p("Mutating segment " .. mutable[i])
        sl.save(sl_overall)
        sc_mut = get.score()
        local ii
        for ii = 1, #amino.segs do
            do_.mutate(i, ii)
            get.report(i_will_be, 1, -1, i, 1, #amino.segs, 1, ii)
        end
        sl.load(sl_overall)
    end
    b_mutating = false
end
--Mutate#

function getNear(seg)
    if(get.score() < g_total_score-1000) then
        deselect.index(seg)
        work.step("s", 1, 0.75, false)
        work.step("ws", 1, false)
        select.index(seg)
        set.clashImportance(1)
    end
    if(get.score() < g_total_score-1000) then
        return false
    end
    return true
end

function sidechain_tweak(seg)
    if aa[seg] ~= "a" or aa[seg] ~= "g" then
		score.recent.save()
        b_tweaking = true
        sl_reset = sl.request()
        sl.save(sl_reset)
        deselect.all()  
        select.segs(seg)
        local ss = get.score()
        g_total_score = get.score()
        if work.step("s", 2, 0, false) then
            p("AT: Sidechain tweak")
            sl_tweak_work = sl.request()
            sl.save(sl_tweak_work)
            select.segs(true, seg)
            if getNear(seg) then
                sl_tweak = sl.request()
                fuze.start(sl_tweak)
                sl.release(sl_tweak)
            end
            if ss < get.score() then
                sl.save(sl_reset)
                deselect.all()  
                select.segs(seg)
                local ss = get.score()
                g_total_score = get.score()
                work.step("s", 2, 0, false)
                sl.save(sl_tweak_work)
            else
                sl.load(sl_tweak_work)
            end
            deselect.all()  
            select.segs(seg)
            local ss=get.score()
            g_total_score = get.score()
            if get.score() > g_total_score - 30 then
                p("AT: Sidechain tweak around")
                select.segs(true, seg)
                deselect.index(seg)
                work.step("s", 1, 0.1, false)
                select.index(seg)
                if getNear(i) then
                    sl_tweak = sl.request()
                    fuze.start(sl_tweak)
                    sl.release(sl_tweak)
                end
                if ss > get.score() then
                    sl.load(sl_reset)
                end
            end
        else
			bool = false
		end		-- if work.step
        sl.release(sl_reset)
        sl.release(sl_tweak_work)
        b_tweaking = false
    else
		bool = false
	end
	score.recent.restore()
	return bool
end

i_s0 = get.score()
sc_max = get.score()
sl_overall = 1
p("v" .. i_vers)
if b_release then
    p("Release Version " .. i_release_vers)
    p("Released on " .. i_release_date)
else -- if b_release
    p("No Released script so it's probably unsafe!")
    p("Last version released on " .. i_release_date)
    p("It was release version " .. i_release_vers)
end -- if b_release
p("Starting Score: " .. i_s0)
sl.save(sl_overall)
get.secstr()
get.ligand()
get.aacid()
get.hydro()
get.mutated()
if b_predict then
    predict.getdata()
    save.SaveSecondaryStructure()
elseif b_str_re then
    struct_rebuild()
elseif b_cu then
    struct_curler()
elseif b_pp then
    if i_s0 < 0 then
        fuze.start(sl_overall)
    end
    for i = 1, i_pp_trys do
        if b_pp_pre_strong or b_pp_pre_local then
            calc.run()
        end
        dists()
    end -- for i
elseif b_mutate then
    sl_mut = sl.request()
    mutate()
    sl.release(sl_mut)
elseif b_rebuild then
    if b_worst_rebuild then
        get.worst(b_worst_len)
        p(seg .. " - " .. r)
        select.segs(seg, r)
        set.ss("L")
        rebuild()
    end
    if b_re_str then
        get.struct()
        for i = 1, #lo do
            seg = lo[i][1]
            r = lo[i][#lo[i]]
            p(seg .. " - " .. r)
            rebuild()
        end
    end
elseif b_fuze then
    p("Fuzing")
    fuze.start(sl_overall)
end -- if b_fuze
if b_rebuild or b_lws or b_snap then
    for i = i_start_seg, i_end_seg do
        seg = i
        if b_snap then
            snap()
        end
        for ii = i_start_walk, i_end_walk do
            r = i + ii
            if r > i_segcount then
                r = i_segcount
                break
            end -- if r
            if b_rebuild then
                if b_re_walk then
                    select.segs()
                    set.ss("L")
                    rebuild()
                end
            elseif b_lws then
                p(seg .. "-" .. r)
                work.flow("wl")
            end -- if b_lws
        end -- for ii
        get.report(i_start_seg, i_end_seg, 1, i)
    end -- for i
end

if b_test then
    scoie=0
    for ii=1,70 do
        behavior.SetWiggleAccuracy(ii*0.1)
        p("Wiggle: " .. behavior.GetWiggleAccuracy())
        for iii=1,4 do
            reset.puzzle()
            sl.save(sl_overall)
            behavior.SetShakeAccuracy(iii)
            p("Shake: " .. behavior.GetShakeAccuracy())
            fuze.start(overall)
            sl.load(sl_overall)
            s_1 = get.score()
            if (s_1 - i_s0) > scoie then
                scoie = s_1 - i_s0
                bestw=ii*0.01
                bests=iii*0.01
            end
            p("Best: W:"..bestw.." S:"..bests.." Scores:"..scoie)
        end
    end
end
sl.load(sl_overall)
save.LoadSecondaryStructure()
sl.release(sl_overall)
s_1 = get.score()
p("+++ overall gain +++")
p("+++" .. s_1 - i_s0 .. "+++")

--old/unused function
--[[local function _HCI(a, b) -- hydropathy
    return 20 - math.abs((amino.hydroscale(a) - amino.hydroscale(b)) * 19 / 10.6)
end

local function _SCI(a, b) -- size
    return 20 - math.abs((amino.size(a) + amino.size(b) - 123) * 19 / 135)
end

local function _CCI(a, b) -- charge
    return 11 - (amino.charge(a) - 7) * (amino.charge(b) - 7) * 19 / 33.8
end]]

--[[
local ask = dialog.CreateDialog("Primary Settings")
ask.lws = dialog.AddButton("local wiggle", 1)
ask.rebuild = dialog.AddButton("rebuild", 2)
ask.bonding = dialog.AddButton("compressing/pull/push", 3)
ask.structuredRebuild = dialog.AddButton("structure based rebuild", 4)
ask.curler = dialog.AddButton("structure curler", 5)
ask.snap = dialog.AddButton("sidechain snap", 6)
ask.fuze = dialog.AddButton("fuze", 7)
ask.mutate = dialog.AddButton("mutate", 8)
ask.predict = dialog.AddButton("predict", 9)

dialog.AddLabel("Additional options:")
dialog.AddLabel("most of the work can be done in a sphere")
ask.sphere = dialog.AddCheckbox("sphered work", false)
dialog.AddLabel("Action tries to get this score then it will save the score")
ask.scoreChange = dialog.AddSlider("score change", 0.01, 0, 10, 0.001)

if isExploringPuzzle then
    dialog.AddLabel("Use the Energy Score or the Exploration Score?")
    ask.useExploreMultiplier = dialog.AddCheckbox("Use Exploration Score", false)
end
dialog.AddButton("Cancel", 0)

dialog.result = dialog.Show(ask)

if dialog.result > 0 then
local sec_dialog
if dialog.result == 1 or dialog.result == 2 then
if dialog.result == 1 then
    sec_dialog = dialog.CreateDialog("Local Wiggle Settings")
    b_lws = true
    else
    sec_dialog = dialog.CreateDialog("Rebuilding Settings")
    b_rebuild = true
    sec_dialog.worstlen = dialog.AddSlider("Trys", 5, 1, 20, 1)
    dialog.AddLabel("Select a rebuilding mode:")
    sec_dialog.worst = dialog.AddCheckbox("Worst Rebuild", false)
    sec_dialog.worstlen = dialog.AddSlider("Worst Length", 3, 1, 20, 1)
    sec_dialog.loops = dialog.AddCheckbox("Rebuild Loops", false)
    sec_dialog.max_rebuilds = dialog.AddSlider("Rebuilds calls till rebuild will be chosen:", 1, 0, 10, 1)
    sec_dialog.rebuild_iters = dialog.AddSlider("Rebuild iteration:", 1, 0, 10, 1)
    if b_mutable then
        sec_dialog.re_mutating = dialog.AddCheckbox("Try some mutating after rebuilds", false)
    end
    sec_dialog.walking_re = dialog.AddCheckbox("Walking Rebuilder", false)
    dialog.AddLabel("Only for Walking Rebuilder:")
    end
    sec_dialog.startseg = dialog.AddSlider("Start Segment", 1, 1, i_segcount, 1)
    sec_dialog.endseg = dialog.AddSlider("End Segment", i_segcount, 1, i_segcount, 1)
    sec_dialog.startwalk = dialog.AddSlider("Walking Area Start", 1, 0, i_segcount, 1)
    sec_dialog.endwalk = dialog.AddSlider("Walking Area End", 3, 0, i_segcount, 1)
    elseif dialog.result == 3 then
    sec_dialog.bondingpercentage = dialog.AddSlider("Bonding Percentage in %", 1, 1, 100, 1)
    sec_dialog.bandlength = dialog.AddSlider("Band length", 4, 1, 20, 1)

    sec_dialog.walking_re = dialog.AddCheckbox("Fixxed Work", false)
    sec_dialog.startseg_fixxed = dialog.AddSlider("Fixxed start Segment", 1, 1, i_segcount, 1)
    sec_dialog.endseg_fixxed = dialog.AddSlider("Fixxed end Segment", i_segcount, 1, i_segcount, 1)
    
    sec_dialog.Iterations = dialog.AddLabel("Iterations="..ask.Iterations.value)
    sec_dialog.BandStrength = dialog.AddLabel("Band Strength="..ask.BandStrength.value)
    sec_dialog.Comment = dialog.AddLabel("Comment="..ask.Comment.value)
    sec_dialog.OK = dialog.AddButton("OK", 1)
    sec_dialog.OK = dialog.AddButton("Cancel", 0)
else
    print("Dialog cancelled")
end
if isExploringPuzzle & ask.useExploreMultiplier.value then
        b_explore = true
    end
    if (ask.sphere.value) then
        b_sphered = true
    end
    
    if not (dialog.Show(lws_dialog) == 1) then
        return showConfigDialog()
    end]]--