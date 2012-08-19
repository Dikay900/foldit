--[[#Header
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions and ideas goes to Seagat, Rav3n_pl, Tlaloc and Gary Forbis
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
i_vers          = 1222
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
b_pp            = true         -- false        pull hydrophobic amino acids in different modes then fuze | see #Pull
b_str_re        = false         -- false        rebuild the protein based on the secondary structures | see #Structed rebuilding
b_cu            = false         -- false        Do bond the structures and curl it, try to improve it and get some points
b_snap          = false         -- false        should we snap every sidechain to different positions
b_fuze          = false         -- false        should we fuze | see #Fuzing
b_mutate        = false         -- false        it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
b_predict       = false         -- false        reset and predict then the secondary structure based on the amino acids of the protein
b_sphered       = false         -- false        work with a sphere always, can be used on lws and rebuilding walker
b_explore       = true         -- false        if true then the overall score will be taken if a exploration puzzle, if false then just the stability score is used for the methods
--Main#

--#Working                      default         description
i_start_seg     = 1             -- 1            the first segment to work with
i_end_seg       = i_segcount    -- i_segcount   the last segment to work with
i_start_walk    = 1             -- 1            with how many segs shall we work - Walker
i_end_walk      = 3             -- 3            starting at the current seg + i_start_walk to seg + i_end_walk
--Working#

--#Scoring | adjust a lower value to get the lws script working on high evo- / solos, higher values are probably better rebuilding the protein
i_score_change  = 0.01          -- 0.01         an action tries to get this score, then it will repeat itself
--Scoring#

--#Mutating
b_m_normal      = true         -- false
b_m_tweak_AT    = true
b_m_re          = true
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
b_re_str        = true
b_re_walk       = false          -- true
i_max_rebuilds  = 1             -- 2            max rebuilds till best rebuild will be chosen
i_rebuild_str   = 1             -- 1            the iterations a rebuild will do at default, automatically increased if no change in score
b_re_mutate     = false
b_re_m_ignore_struct = false
b_m_re_deep_rebuild = true
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
startTime    = os.time()
time_used       = 0
time_mod		= 1
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
    ss              = structure.SetSecondaryStructure,
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
        save                = recentbest.Save,
        restore             = recentbest.Restore
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
hci_table = {}
cci_table = {}
sci_table = {}
for _i = 1, #amino.segs do
    hci_table[amino.segs[_i]] = {}
    cci_table[amino.segs[_i]] = {}
    sci_table[amino.segs[_i]] = {}
end
hci_table['a']['a']=20;hci_table['a']['c']=8.5283018867925;hci_table['a']['d']=14.084905660377;hci_table['a']['e']=19.820754716981;hci_table['a']['f']=4.2264150943396;hci_table['a']['g']=16.952830188679;hci_table['a']['h']=14.443396226415;hci_table['a']['i']=14.084905660377;hci_table['a']['k']=-2.7641509433962;hci_table['a']['l']=16.952830188679;hci_table['a']['m']=16.952830188679;hci_table['a']['n']=4.2264150943396;hci_table['a']['p']=4.2264150943396;hci_table['a']['q']=9.0660377358491;hci_table['a']['r']=14.084905660377;hci_table['a']['s']=18.38679245283;hci_table['a']['t']=-6.7075471698113;hci_table['a']['v']=-7.6037735849057;hci_table['a']['w']=4.2264150943396;hci_table['a']['y']=16.952830188679;hci_table['c']['a']=8.5283018867925;hci_table['c']['c']=20;hci_table['c']['d']=14.443396226415;hci_table['c']['e']=8.7075471698113;hci_table['c']['f']=15.698113207547;hci_table['c']['g']=11.575471698113;hci_table['c']['h']=14.084905660377;hci_table['c']['i']=14.443396226415;hci_table['c']['k']=8.7075471698113;hci_table['c']['l']=11.575471698113;hci_table['c']['m']=11.575471698113;hci_table['c']['n']=15.698113207547;hci_table['c']['p']=15.698113207547;hci_table['c']['q']=19.462264150943;hci_table['c']['r']=14.443396226415;hci_table['c']['s']=10.141509433962;hci_table['c']['t']=4.7641509433962;hci_table['c']['v']=3.8679245283019;hci_table['c']['w']=15.698113207547;hci_table['c']['y']=11.575471698113;hci_table['d']['a']=14.084905660377;hci_table['d']['c']=14.443396226415;hci_table['d']['d']=20;hci_table['d']['e']=14.264150943396;hci_table['d']['f']=10.141509433962;hci_table['d']['g']=17.132075471698;hci_table['d']['h']=19.641509433962;hci_table['d']['i']=20;hci_table['d']['k']=3.1509433962264;hci_table['d']['l']=17.132075471698;hci_table['d']['m']=17.132075471698;hci_table['d']['n']=10.141509433962;hci_table['d']['p']=10.141509433962;hci_table['d']['q']=14.981132075472;hci_table['d']['r']=20;hci_table['d']['s']=15.698113207547;hci_table['d']['t']=-0.79245283018868;hci_table['d']['v']=-1.688679245283;hci_table['d']['w']=10.141509433962;hci_table['d']['y']=17.132075471698;hci_table['e']['a']=19.820754716981;hci_table['e']['c']=8.7075471698113;hci_table['e']['d']=14.264150943396;hci_table['e']['e']=20;hci_table['e']['f']=4.4056603773585;hci_table['e']['g']=17.132075471698;hci_table['e']['h']=14.622641509434;hci_table['e']['i']=14.264150943396;hci_table['e']['k']=-2.5849056603774;hci_table['e']['l']=17.132075471698;hci_table['e']['m']=17.132075471698;hci_table['e']['n']=4.4056603773585;hci_table['e']['p']=4.4056603773585;hci_table['e']['q']=9.2452830188679;hci_table['e']['r']=14.264150943396;hci_table['e']['s']=18.566037735849;hci_table['e']['t']=-6.5283018867925;hci_table['e']['v']=-7.4245283018868;hci_table['e']['w']=4.4056603773585;hci_table['e']['y']=17.132075471698;hci_table['f']['a']=4.2264150943396;hci_table['f']['c']=15.698113207547;hci_table['f']['d']=10.141509433962;hci_table['f']['e']=4.4056603773585;hci_table['f']['f']=20;hci_table['f']['g']=7.2735849056604;hci_table['f']['h']=9.7830188679245;hci_table['f']['i']=10.141509433962;hci_table['f']['k']=13.009433962264;hci_table['f']['l']=7.2735849056604;hci_table['f']['m']=7.2735849056604;hci_table['f']['n']=20;hci_table['f']['p']=20;hci_table['f']['q']=15.160377358491;hci_table['f']['r']=10.141509433962;hci_table['f']['s']=5.8396226415094;hci_table['f']['t']=9.0660377358491;hci_table['f']['v']=8.1698113207547;hci_table['f']['w']=20;hci_table['f']['y']=7.2735849056604;hci_table['g']['a']=16.952830188679;hci_table['g']['c']=11.575471698113;hci_table['g']['d']=17.132075471698;hci_table['g']['e']=17.132075471698;hci_table['g']['f']=7.2735849056604;hci_table['g']['g']=20;hci_table['g']['h']=17.490566037736;hci_table['g']['i']=17.132075471698;hci_table['g']['k']=0.28301886792453;hci_table['g']['l']=20;hci_table['g']['m']=20;hci_table['g']['n']=7.2735849056604;hci_table['g']['p']=7.2735849056604;hci_table['g']['q']=12.11320754717;hci_table['g']['r']=17.132075471698;hci_table['g']['s']=18.566037735849;hci_table['g']['t']=-3.6603773584906;hci_table['g']['v']=-4.5566037735849;hci_table['g']['w']=7.2735849056604;hci_table['g']['y']=20;hci_table['h']['a']=14.443396226415;hci_table['h']['c']=14.084905660377;hci_table['h']['d']=19.641509433962;hci_table['h']['e']=14.622641509434;hci_table['h']['f']=9.7830188679245;hci_table['h']['g']=17.490566037736;hci_table['h']['h']=20;hci_table['h']['i']=19.641509433962;hci_table['h']['k']=2.7924528301887;hci_table['h']['l']=17.490566037736;hci_table['h']['m']=17.490566037736;hci_table['h']['n']=9.7830188679245;hci_table['h']['p']=9.7830188679245;hci_table['h']['q']=14.622641509434;hci_table['h']['r']=19.641509433962;hci_table['h']['s']=16.056603773585;hci_table['h']['t']=-1.1509433962264;hci_table['h']['v']=-2.0471698113208;hci_table['h']['w']=9.7830188679245;hci_table['h']['y']=17.490566037736;hci_table['i']['a']=14.084905660377;hci_table['i']['c']=14.443396226415;hci_table['i']['d']=20;hci_table['i']['e']=14.264150943396;hci_table['i']['f']=10.141509433962;hci_table['i']['g']=17.132075471698;hci_table['i']['h']=19.641509433962;hci_table['i']['i']=20;hci_table['i']['k']=3.1509433962264;hci_table['i']['l']=17.132075471698;hci_table['i']['m']=17.132075471698;hci_table['i']['n']=10.141509433962;hci_table['i']['p']=10.141509433962;hci_table['i']['q']=14.981132075472;hci_table['i']['r']=20;hci_table['i']['s']=15.698113207547;hci_table['i']['t']=-0.79245283018868;hci_table['i']['v']=-1.688679245283;hci_table['i']['w']=10.141509433962;hci_table['i']['y']=17.132075471698;hci_table['k']['a']=-2.7641509433962;hci_table['k']['c']=8.7075471698113;hci_table['k']['d']=3.1509433962264;hci_table['k']['e']=-2.5849056603774;hci_table['k']['f']=13.009433962264;hci_table['k']['g']=0.28301886792453;hci_table['k']['h']=2.7924528301887;hci_table['k']['i']=3.1509433962264;hci_table['k']['k']=20;hci_table['k']['l']=0.28301886792453;hci_table['k']['m']=0.28301886792453;hci_table['k']['n']=13.009433962264;hci_table['k']['p']=13.009433962264;hci_table['k']['q']=8.1698113207547;hci_table['k']['r']=3.1509433962264;hci_table['k']['s']=-1.1509433962264;hci_table['k']['t']=16.056603773585;hci_table['k']['v']=15.160377358491;hci_table['k']['w']=13.009433962264;hci_table['k']['y']=0.28301886792453;hci_table['l']['a']=16.952830188679;hci_table['l']['c']=11.575471698113;hci_table['l']['d']=17.132075471698;hci_table['l']['e']=17.132075471698;hci_table['l']['f']=7.2735849056604;hci_table['l']['g']=20;hci_table['l']['h']=17.490566037736;hci_table['l']['i']=17.132075471698;hci_table['l']['k']=0.28301886792453;hci_table['l']['l']=20;hci_table['l']['m']=20;hci_table['l']['n']=7.2735849056604;hci_table['l']['p']=7.2735849056604;hci_table['l']['q']=12.11320754717;hci_table['l']['r']=17.132075471698;hci_table['l']['s']=18.566037735849;hci_table['l']['t']=-3.6603773584906;hci_table['l']['v']=-4.5566037735849;hci_table['l']['w']=7.2735849056604;hci_table['l']['y']=20;hci_table['m']['a']=16.952830188679;hci_table['m']['c']=11.575471698113;hci_table['m']['d']=17.132075471698;hci_table['m']['e']=17.132075471698;hci_table['m']['f']=7.2735849056604;hci_table['m']['g']=20;hci_table['m']['h']=17.490566037736;hci_table['m']['i']=17.132075471698;hci_table['m']['k']=0.28301886792453;hci_table['m']['l']=20;hci_table['m']['m']=20;hci_table['m']['n']=7.2735849056604;hci_table['m']['p']=7.2735849056604;hci_table['m']['q']=12.11320754717;hci_table['m']['r']=17.132075471698;hci_table['m']['s']=18.566037735849;hci_table['m']['t']=-3.6603773584906;hci_table['m']['v']=-4.5566037735849;hci_table['m']['w']=7.2735849056604;hci_table['m']['y']=20;hci_table['n']['a']=4.2264150943396;hci_table['n']['c']=15.698113207547;hci_table['n']['d']=10.141509433962;hci_table['n']['e']=4.4056603773585;hci_table['n']['f']=20;hci_table['n']['g']=7.2735849056604;hci_table['n']['h']=9.7830188679245;hci_table['n']['i']=10.141509433962;hci_table['n']['k']=13.009433962264;hci_table['n']['l']=7.2735849056604;hci_table['n']['m']=7.2735849056604;hci_table['n']['n']=20;hci_table['n']['p']=20;hci_table['n']['q']=15.160377358491;hci_table['n']['r']=10.141509433962;hci_table['n']['s']=5.8396226415094;hci_table['n']['t']=9.0660377358491;hci_table['n']['v']=8.1698113207547;hci_table['n']['w']=20;hci_table['n']['y']=7.2735849056604;hci_table['p']['a']=4.2264150943396;hci_table['p']['c']=15.698113207547;hci_table['p']['d']=10.141509433962;hci_table['p']['e']=4.4056603773585;hci_table['p']['f']=20;hci_table['p']['g']=7.2735849056604;hci_table['p']['h']=9.7830188679245;hci_table['p']['i']=10.141509433962;hci_table['p']['k']=13.009433962264;hci_table['p']['l']=7.2735849056604;hci_table['p']['m']=7.2735849056604;hci_table['p']['n']=20;hci_table['p']['p']=20;hci_table['p']['q']=15.160377358491;hci_table['p']['r']=10.141509433962;hci_table['p']['s']=5.8396226415094;hci_table['p']['t']=9.0660377358491;hci_table['p']['v']=8.1698113207547;hci_table['p']['w']=20;hci_table['p']['y']=7.2735849056604;hci_table['q']['a']=9.0660377358491;hci_table['q']['c']=19.462264150943;hci_table['q']['d']=14.981132075472;hci_table['q']['e']=9.2452830188679;hci_table['q']['f']=15.160377358491;hci_table['q']['g']=12.11320754717;hci_table['q']['h']=14.622641509434;hci_table['q']['i']=14.981132075472;hci_table['q']['k']=8.1698113207547;hci_table['q']['l']=12.11320754717;hci_table['q']['m']=12.11320754717;hci_table['q']['n']=15.160377358491;hci_table['q']['p']=15.160377358491;hci_table['q']['q']=20;hci_table['q']['r']=14.981132075472;hci_table['q']['s']=10.679245283019;hci_table['q']['t']=4.2264150943396;hci_table['q']['v']=3.3301886792453;hci_table['q']['w']=15.160377358491;hci_table['q']['y']=12.11320754717;hci_table['r']['a']=14.084905660377;hci_table['r']['c']=14.443396226415;hci_table['r']['d']=20;hci_table['r']['e']=14.264150943396;hci_table['r']['f']=10.141509433962;hci_table['r']['g']=17.132075471698;hci_table['r']['h']=19.641509433962;hci_table['r']['i']=20;hci_table['r']['k']=3.1509433962264;hci_table['r']['l']=17.132075471698;hci_table['r']['m']=17.132075471698;hci_table['r']['n']=10.141509433962;hci_table['r']['p']=10.141509433962;hci_table['r']['q']=14.981132075472;hci_table['r']['r']=20;hci_table['r']['s']=15.698113207547;hci_table['r']['t']=-0.79245283018868;hci_table['r']['v']=-1.688679245283;hci_table['r']['w']=10.141509433962;hci_table['r']['y']=17.132075471698;hci_table['s']['a']=18.38679245283;hci_table['s']['c']=10.141509433962;hci_table['s']['d']=15.698113207547;hci_table['s']['e']=18.566037735849;hci_table['s']['f']=5.8396226415094;hci_table['s']['g']=18.566037735849;hci_table['s']['h']=16.056603773585;hci_table['s']['i']=15.698113207547;hci_table['s']['k']=-1.1509433962264;hci_table['s']['l']=18.566037735849;hci_table['s']['m']=18.566037735849;hci_table['s']['n']=5.8396226415094;hci_table['s']['p']=5.8396226415094;hci_table['s']['q']=10.679245283019;hci_table['s']['r']=15.698113207547;hci_table['s']['s']=20;hci_table['s']['t']=-5.0943396226415;hci_table['s']['v']=-5.9905660377358;hci_table['s']['w']=5.8396226415094;hci_table['s']['y']=18.566037735849;hci_table['t']['a']=-6.7075471698113;hci_table['t']['c']=4.7641509433962;hci_table['t']['d']=-0.79245283018868;hci_table['t']['e']=-6.5283018867925;hci_table['t']['f']=9.0660377358491;hci_table['t']['g']=-3.6603773584906;hci_table['t']['h']=-1.1509433962264;hci_table['t']['i']=-0.79245283018868;hci_table['t']['k']=16.056603773585;hci_table['t']['l']=-3.6603773584906;hci_table['t']['m']=-3.6603773584906;hci_table['t']['n']=9.0660377358491;hci_table['t']['p']=9.0660377358491;hci_table['t']['q']=4.2264150943396;hci_table['t']['r']=-0.79245283018868;hci_table['t']['s']=-5.0943396226415;hci_table['t']['t']=20;hci_table['t']['v']=19.103773584906;hci_table['t']['w']=9.0660377358491;hci_table['t']['y']=-3.6603773584906;hci_table['v']['a']=-7.6037735849057;hci_table['v']['c']=3.8679245283019;hci_table['v']['d']=-1.688679245283;hci_table['v']['e']=-7.4245283018868;hci_table['v']['f']=8.1698113207547;hci_table['v']['g']=-4.5566037735849;hci_table['v']['h']=-2.0471698113208;hci_table['v']['i']=-1.688679245283;hci_table['v']['k']=15.160377358491;hci_table['v']['l']=-4.5566037735849;hci_table['v']['m']=-4.5566037735849;hci_table['v']['n']=8.1698113207547;hci_table['v']['p']=8.1698113207547;hci_table['v']['q']=3.3301886792453;hci_table['v']['r']=-1.688679245283;hci_table['v']['s']=-5.9905660377358;hci_table['v']['t']=19.103773584906;hci_table['v']['v']=20;hci_table['v']['w']=8.1698113207547;hci_table['v']['y']=-4.5566037735849;hci_table['w']['a']=4.2264150943396;hci_table['w']['c']=15.698113207547;hci_table['w']['d']=10.141509433962;hci_table['w']['e']=4.4056603773585;hci_table['w']['f']=20;hci_table['w']['g']=7.2735849056604;hci_table['w']['h']=9.7830188679245;hci_table['w']['i']=10.141509433962;hci_table['w']['k']=13.009433962264;hci_table['w']['l']=7.2735849056604;hci_table['w']['m']=7.2735849056604;hci_table['w']['n']=20;hci_table['w']['p']=20;hci_table['w']['q']=15.160377358491;hci_table['w']['r']=10.141509433962;hci_table['w']['s']=5.8396226415094;hci_table['w']['t']=9.0660377358491;hci_table['w']['v']=8.1698113207547;hci_table['w']['w']=20;hci_table['w']['y']=7.2735849056604;hci_table['y']['a']=16.952830188679;hci_table['y']['c']=11.575471698113;hci_table['y']['d']=17.132075471698;hci_table['y']['e']=17.132075471698;hci_table['y']['f']=7.2735849056604;hci_table['y']['g']=20;hci_table['y']['h']=17.490566037736;hci_table['y']['i']=17.132075471698;hci_table['y']['k']=0.28301886792453;hci_table['y']['l']=20;hci_table['y']['m']=20;hci_table['y']['n']=7.2735849056604;hci_table['y']['p']=7.2735849056604;hci_table['y']['q']=12.11320754717;hci_table['y']['r']=17.132075471698;hci_table['y']['s']=18.566037735849;hci_table['y']['t']=-3.6603773584906;hci_table['y']['v']=-4.5566037735849;hci_table['y']['w']=7.2735849056604;hci_table['y']['y']=20;sci_table['a']['a']=-11.723734222222;sci_table['a']['c']=-8.2059334814815;sci_table['a']['d']=-7.7811075555556;sci_table['a']['e']=-7.7749994074074;sci_table['a']['f']=-5.6679275555556;sci_table['a']['g']=-7.9136008888889;sci_table['a']['h']=-5.9394445925926;sci_table['a']['i']=-7.7811075555556;sci_table['a']['k']=-3.6937853333333;sci_table['a']['l']=-7.9136008888889;sci_table['a']['m']=-7.9136008888889;sci_table['a']['n']=-5.6679275555556;sci_table['a']['p']=-5.6679275555556;sci_table['a']['q']=-1.9972401481481;sci_table['a']['r']=-7.7811075555556;sci_table['a']['s']=-5.8008431111111;sci_table['a']['t']=-12.707300888889;sci_table['a']['v']=-9.0431297777778;sci_table['a']['w']=-5.6679275555556;sci_table['a']['y']=-7.9136008888889;sci_table['c']['a']=-8.2059334814815;sci_table['c']['c']=-4.6881327407407;sci_table['c']['d']=-4.2633068148148;sci_table['c']['e']=-4.2571986666667;sci_table['c']['f']=-2.1501268148148;sci_table['c']['g']=-4.3958001481481;sci_table['c']['h']=-2.4216438518519;sci_table['c']['i']=-4.2633068148148;sci_table['c']['k']=-0.17598459259259;sci_table['c']['l']=-4.3958001481481;sci_table['c']['m']=-4.3958001481481;sci_table['c']['n']=-2.1501268148148;sci_table['c']['p']=-2.1501268148148;sci_table['c']['q']=1.5205605925926;sci_table['c']['r']=-4.2633068148148;sci_table['c']['s']=-2.2830423703704;sci_table['c']['t']=-9.1895001481482;sci_table['c']['v']=-5.525329037037;sci_table['c']['w']=-2.1501268148148;sci_table['c']['y']=-4.3958001481481;sci_table['d']['a']=-7.7811075555556;sci_table['d']['c']=-4.2633068148148;sci_table['d']['d']=-3.8384808888889;sci_table['d']['e']=-3.8323727407407;sci_table['d']['f']=-1.7253008888889;sci_table['d']['g']=-3.9709742222222;sci_table['d']['h']=-1.9968179259259;sci_table['d']['i']=-3.8384808888889;sci_table['d']['k']=0.24884133333333;sci_table['d']['l']=-3.9709742222222;sci_table['d']['m']=-3.9709742222222;sci_table['d']['n']=-1.7253008888889;sci_table['d']['p']=-1.7253008888889;sci_table['d']['q']=1.9453865185185;sci_table['d']['r']=-3.8384808888889;sci_table['d']['s']=-1.8582164444444;sci_table['d']['t']=-8.7646742222222;sci_table['d']['v']=-5.1005031111111;sci_table['d']['w']=-1.7253008888889;sci_table['d']['y']=-3.9709742222222;sci_table['e']['a']=-7.7749994074074;sci_table['e']['c']=-4.2571986666667;sci_table['e']['d']=-3.8323727407407;sci_table['e']['e']=-3.8262645925926;sci_table['e']['f']=-1.7191927407407;sci_table['e']['g']=-3.9648660740741;sci_table['e']['h']=-1.9907097777778;sci_table['e']['i']=-3.8323727407407;sci_table['e']['k']=0.25494948148149;sci_table['e']['l']=-3.9648660740741;sci_table['e']['m']=-3.9648660740741;sci_table['e']['n']=-1.7191927407407;sci_table['e']['p']=-1.7191927407407;sci_table['e']['q']=1.9514946666667;sci_table['e']['r']=-3.8323727407407;sci_table['e']['s']=-1.8521082962963;sci_table['e']['t']=-8.7585660740741;sci_table['e']['v']=-5.094394962963;sci_table['e']['w']=-1.7191927407407;sci_table['e']['y']=-3.9648660740741;sci_table['f']['a']=-5.6679275555556;sci_table['f']['c']=-2.1501268148148;sci_table['f']['d']=-1.7253008888889;sci_table['f']['e']=-1.7191927407407;sci_table['f']['f']=0.38787911111111;sci_table['f']['g']=-1.8577942222222;sci_table['f']['h']=0.11636207407408;sci_table['f']['i']=-1.7253008888889;sci_table['f']['k']=2.3620213333333;sci_table['f']['l']=-1.8577942222222;sci_table['f']['m']=-1.8577942222222;sci_table['f']['n']=0.38787911111111;sci_table['f']['p']=0.38787911111111;sci_table['f']['q']=4.0585665185185;sci_table['f']['r']=-1.7253008888889;sci_table['f']['s']=0.25496355555556;sci_table['f']['t']=-6.6514942222222;sci_table['f']['v']=-2.9873231111111;sci_table['f']['w']=0.38787911111111;sci_table['f']['y']=-1.8577942222222;sci_table['g']['a']=-7.9136008888889;sci_table['g']['c']=-4.3958001481481;sci_table['g']['d']=-3.9709742222222;sci_table['g']['e']=-3.9648660740741;sci_table['g']['f']=-1.8577942222222;sci_table['g']['g']=-4.1034675555556;sci_table['g']['h']=-2.1293112592593;sci_table['g']['i']=-3.9709742222222;sci_table['g']['k']=0.116348;sci_table['g']['l']=-4.1034675555556;sci_table['g']['m']=-4.1034675555556;sci_table['g']['n']=-1.8577942222222;sci_table['g']['p']=-1.8577942222222;sci_table['g']['q']=1.8128931851852;sci_table['g']['r']=-3.9709742222222;sci_table['g']['s']=-1.9907097777778;sci_table['g']['t']=-8.8971675555556;sci_table['g']['v']=-5.2329964444444;sci_table['g']['w']=-1.8577942222222;sci_table['g']['y']=-4.1034675555556;sci_table['h']['a']=-5.9394445925926;sci_table['h']['c']=-2.4216438518519;sci_table['h']['d']=-1.9968179259259;sci_table['h']['e']=-1.9907097777778;sci_table['h']['f']=0.11636207407408;sci_table['h']['g']=-2.1293112592593;sci_table['h']['h']=-0.15515496296296;sci_table['h']['i']=-1.9968179259259;sci_table['h']['k']=2.0905042962963;sci_table['h']['l']=-2.1293112592593;sci_table['h']['m']=-2.1293112592593;sci_table['h']['n']=0.11636207407408;sci_table['h']['p']=0.11636207407408;sci_table['h']['q']=3.7870494814815;sci_table['h']['r']=-1.9968179259259;sci_table['h']['s']=-0.016553481481484;sci_table['h']['t']=-6.9230112592593;sci_table['h']['v']=-3.2588401481481;sci_table['h']['w']=0.11636207407408;sci_table['h']['y']=-2.1293112592593;sci_table['i']['a']=-7.7811075555556;sci_table['i']['c']=-4.2633068148148;sci_table['i']['d']=-3.8384808888889;sci_table['i']['e']=-3.8323727407407;sci_table['i']['f']=-1.7253008888889;sci_table['i']['g']=-3.9709742222222;sci_table['i']['h']=-1.9968179259259;sci_table['i']['i']=-3.8384808888889;sci_table['i']['k']=0.24884133333333;sci_table['i']['l']=-3.9709742222222;sci_table['i']['m']=-3.9709742222222;sci_table['i']['n']=-1.7253008888889;sci_table['i']['p']=-1.7253008888889;sci_table['i']['q']=1.9453865185185;sci_table['i']['r']=-3.8384808888889;sci_table['i']['s']=-1.8582164444444;sci_table['i']['t']=-8.7646742222222;sci_table['i']['v']=-5.1005031111111;sci_table['i']['w']=-1.7253008888889;sci_table['i']['y']=-3.9709742222222;sci_table['k']['a']=-3.6937853333333;sci_table['k']['c']=-0.17598459259259;sci_table['k']['d']=0.24884133333333;sci_table['k']['e']=0.25494948148149;sci_table['k']['f']=2.3620213333333;sci_table['k']['g']=0.116348;sci_table['k']['h']=2.0905042962963;sci_table['k']['i']=0.24884133333333;sci_table['k']['k']=4.3361635555556;sci_table['k']['l']=0.116348;sci_table['k']['m']=0.116348;sci_table['k']['n']=2.3620213333333;sci_table['k']['p']=2.3620213333333;sci_table['k']['q']=6.0327087407407;sci_table['k']['r']=0.24884133333333;sci_table['k']['s']=2.2291057777778;sci_table['k']['t']=-4.677352;sci_table['k']['v']=-1.0131808888889;sci_table['k']['w']=2.3620213333333;sci_table['k']['y']=0.116348;sci_table['l']['a']=-7.9136008888889;sci_table['l']['c']=-4.3958001481481;sci_table['l']['d']=-3.9709742222222;sci_table['l']['e']=-3.9648660740741;sci_table['l']['f']=-1.8577942222222;sci_table['l']['g']=-4.1034675555556;sci_table['l']['h']=-2.1293112592593;sci_table['l']['i']=-3.9709742222222;sci_table['l']['k']=0.116348;sci_table['l']['l']=-4.1034675555556;sci_table['l']['m']=-4.1034675555556;sci_table['l']['n']=-1.8577942222222;sci_table['l']['p']=-1.8577942222222;sci_table['l']['q']=1.8128931851852;sci_table['l']['r']=-3.9709742222222;sci_table['l']['s']=-1.9907097777778;sci_table['l']['t']=-8.8971675555556;sci_table['l']['v']=-5.2329964444444;sci_table['l']['w']=-1.8577942222222;sci_table['l']['y']=-4.1034675555556;sci_table['m']['a']=-7.9136008888889;sci_table['m']['c']=-4.3958001481481;sci_table['m']['d']=-3.9709742222222;sci_table['m']['e']=-3.9648660740741;sci_table['m']['f']=-1.8577942222222;sci_table['m']['g']=-4.1034675555556;sci_table['m']['h']=-2.1293112592593;sci_table['m']['i']=-3.9709742222222;sci_table['m']['k']=0.116348;sci_table['m']['l']=-4.1034675555556;sci_table['m']['m']=-4.1034675555556;sci_table['m']['n']=-1.8577942222222;sci_table['m']['p']=-1.8577942222222;sci_table['m']['q']=1.8128931851852;sci_table['m']['r']=-3.9709742222222;sci_table['m']['s']=-1.9907097777778;sci_table['m']['t']=-8.8971675555556;sci_table['m']['v']=-5.2329964444444;sci_table['m']['w']=-1.8577942222222;sci_table['m']['y']=-4.1034675555556;sci_table['n']['a']=-5.6679275555556;sci_table['n']['c']=-2.1501268148148;sci_table['n']['d']=-1.7253008888889;sci_table['n']['e']=-1.7191927407407;sci_table['n']['f']=0.38787911111111;sci_table['n']['g']=-1.8577942222222;sci_table['n']['h']=0.11636207407408;sci_table['n']['i']=-1.7253008888889;sci_table['n']['k']=2.3620213333333;sci_table['n']['l']=-1.8577942222222;sci_table['n']['m']=-1.8577942222222;sci_table['n']['n']=0.38787911111111;sci_table['n']['p']=0.38787911111111;sci_table['n']['q']=4.0585665185185;sci_table['n']['r']=-1.7253008888889;sci_table['n']['s']=0.25496355555556;sci_table['n']['t']=-6.6514942222222;sci_table['n']['v']=-2.9873231111111;sci_table['n']['w']=0.38787911111111;sci_table['n']['y']=-1.8577942222222;sci_table['p']['a']=-5.6679275555556;sci_table['p']['c']=-2.1501268148148;sci_table['p']['d']=-1.7253008888889;sci_table['p']['e']=-1.7191927407407;sci_table['p']['f']=0.38787911111111;sci_table['p']['g']=-1.8577942222222;sci_table['p']['h']=0.11636207407408;sci_table['p']['i']=-1.7253008888889;sci_table['p']['k']=2.3620213333333;sci_table['p']['l']=-1.8577942222222;sci_table['p']['m']=-1.8577942222222;sci_table['p']['n']=0.38787911111111;sci_table['p']['p']=0.38787911111111;sci_table['p']['q']=4.0585665185185;sci_table['p']['r']=-1.7253008888889;sci_table['p']['s']=0.25496355555556;sci_table['p']['t']=-6.6514942222222;sci_table['p']['v']=-2.9873231111111;sci_table['p']['w']=0.38787911111111;sci_table['p']['y']=-1.8577942222222;sci_table['q']['a']=-1.9972401481481;sci_table['q']['c']=1.5205605925926;sci_table['q']['d']=1.9453865185185;sci_table['q']['e']=1.9514946666667;sci_table['q']['f']=4.0585665185185;sci_table['q']['g']=1.8128931851852;sci_table['q']['h']=3.7870494814815;sci_table['q']['i']=1.9453865185185;sci_table['q']['k']=6.0327087407407;sci_table['q']['l']=1.8128931851852;sci_table['q']['m']=1.8128931851852;sci_table['q']['n']=4.0585665185185;sci_table['q']['p']=4.0585665185185;sci_table['q']['q']=7.7292539259259;sci_table['q']['r']=1.9453865185185;sci_table['q']['s']=3.925650962963;sci_table['q']['t']=-2.9808068148148;sci_table['q']['v']=0.6833642962963;sci_table['q']['w']=4.0585665185185;sci_table['q']['y']=1.8128931851852;sci_table['r']['a']=-7.7811075555556;sci_table['r']['c']=-4.2633068148148;sci_table['r']['d']=-3.8384808888889;sci_table['r']['e']=-3.8323727407407;sci_table['r']['f']=-1.7253008888889;sci_table['r']['g']=-3.9709742222222;sci_table['r']['h']=-1.9968179259259;sci_table['r']['i']=-3.8384808888889;sci_table['r']['k']=0.24884133333333;sci_table['r']['l']=-3.9709742222222;sci_table['r']['m']=-3.9709742222222;sci_table['r']['n']=-1.7253008888889;sci_table['r']['p']=-1.7253008888889;sci_table['r']['q']=1.9453865185185;sci_table['r']['r']=-3.8384808888889;sci_table['r']['s']=-1.8582164444444;sci_table['r']['t']=-8.7646742222222;sci_table['r']['v']=-5.1005031111111;sci_table['r']['w']=-1.7253008888889;sci_table['r']['y']=-3.9709742222222;sci_table['s']['a']=-5.8008431111111;sci_table['s']['c']=-2.2830423703704;sci_table['s']['d']=-1.8582164444444;sci_table['s']['e']=-1.8521082962963;sci_table['s']['f']=0.25496355555556;sci_table['s']['g']=-1.9907097777778;sci_table['s']['h']=-0.016553481481484;sci_table['s']['i']=-1.8582164444444;sci_table['s']['k']=2.2291057777778;sci_table['s']['l']=-1.9907097777778;sci_table['s']['m']=-1.9907097777778;sci_table['s']['n']=0.25496355555556;sci_table['s']['p']=0.25496355555556;sci_table['s']['q']=3.925650962963;sci_table['s']['r']=-1.8582164444444;sci_table['s']['s']=0.122048;sci_table['s']['t']=-6.7844097777778;sci_table['s']['v']=-3.1202386666667;sci_table['s']['w']=0.25496355555556;sci_table['s']['y']=-1.9907097777778;sci_table['t']['a']=-12.707300888889;sci_table['t']['c']=-9.1895001481482;sci_table['t']['d']=-8.7646742222222;sci_table['t']['e']=-8.7585660740741;sci_table['t']['f']=-6.6514942222222;sci_table['t']['g']=-8.8971675555556;sci_table['t']['h']=-6.9230112592593;sci_table['t']['i']=-8.7646742222222;sci_table['t']['k']=-4.677352;sci_table['t']['l']=-8.8971675555556;sci_table['t']['m']=-8.8971675555556;sci_table['t']['n']=-6.6514942222222;sci_table['t']['p']=-6.6514942222222;sci_table['t']['q']=-2.9808068148148;sci_table['t']['r']=-8.7646742222222;sci_table['t']['s']=-6.7844097777778;sci_table['t']['t']=-13.690867555556;sci_table['t']['v']=-10.026696444444;sci_table['t']['w']=-6.6514942222222;sci_table['t']['y']=-8.8971675555556;sci_table['v']['a']=-9.0431297777778;sci_table['v']['c']=-5.525329037037;sci_table['v']['d']=-5.1005031111111;sci_table['v']['e']=-5.094394962963;sci_table['v']['f']=-2.9873231111111;sci_table['v']['g']=-5.2329964444444;sci_table['v']['h']=-3.2588401481481;sci_table['v']['i']=-5.1005031111111;sci_table['v']['k']=-1.0131808888889;sci_table['v']['l']=-5.2329964444444;sci_table['v']['m']=-5.2329964444444;sci_table['v']['n']=-2.9873231111111;sci_table['v']['p']=-2.9873231111111;sci_table['v']['q']=0.6833642962963;sci_table['v']['r']=-5.1005031111111;sci_table['v']['s']=-3.1202386666667;sci_table['v']['t']=-10.026696444444;sci_table['v']['v']=-6.3625253333333;sci_table['v']['w']=-2.9873231111111;sci_table['v']['y']=-5.2329964444444;sci_table['w']['a']=-5.6679275555556;sci_table['w']['c']=-2.1501268148148;sci_table['w']['d']=-1.7253008888889;sci_table['w']['e']=-1.7191927407407;sci_table['w']['f']=0.38787911111111;sci_table['w']['g']=-1.8577942222222;sci_table['w']['h']=0.11636207407408;sci_table['w']['i']=-1.7253008888889;sci_table['w']['k']=2.3620213333333;sci_table['w']['l']=-1.8577942222222;sci_table['w']['m']=-1.8577942222222;sci_table['w']['n']=0.38787911111111;sci_table['w']['p']=0.38787911111111;sci_table['w']['q']=4.0585665185185;sci_table['w']['r']=-1.7253008888889;sci_table['w']['s']=0.25496355555556;sci_table['w']['t']=-6.6514942222222;sci_table['w']['v']=-2.9873231111111;sci_table['w']['w']=0.38787911111111;sci_table['w']['y']=-1.8577942222222;sci_table['y']['a']=-7.9136008888889;sci_table['y']['c']=-4.3958001481481;sci_table['y']['d']=-3.9709742222222;sci_table['y']['e']=-3.9648660740741;sci_table['y']['f']=-1.8577942222222;sci_table['y']['g']=-4.1034675555556;sci_table['y']['h']=-2.1293112592593;sci_table['y']['i']=-3.9709742222222;sci_table['y']['k']=0.116348;sci_table['y']['l']=-4.1034675555556;sci_table['y']['m']=-4.1034675555556;sci_table['y']['n']=-1.8577942222222;sci_table['y']['p']=-1.8577942222222;sci_table['y']['q']=1.8128931851852;sci_table['y']['r']=-3.9709742222222;sci_table['y']['s']=-1.9907097777778;sci_table['y']['t']=-8.8971675555556;sci_table['y']['v']=-5.2329964444444;sci_table['y']['w']=-1.8577942222222;sci_table['y']['y']=-4.1034675555556;cci_table['a']['a']=3.0528284023669;cci_table['a']['c']=13.663147928994;cci_table['a']['d']=5.5046153846154;cci_table['a']['e']=13.853372781065;cci_table['a']['f']=13.092473372781;cci_table['a']['g']=19.137396449704;cci_table['a']['h']=19.771479289941;cci_table['a']['i']=5.5046153846154;cci_table['a']['k']=13.113609467456;cci_table['a']['l']=19.137396449704;cci_table['a']['m']=19.137396449704;cci_table['a']['n']=13.092473372781;cci_table['a']['p']=13.092473372781;cci_table['a']['q']=13.789964497041;cci_table['a']['r']=5.5046153846154;cci_table['a']['s']=14.360639053254;cci_table['a']['t']=13.87450887574;cci_table['a']['v']=9.7318343195266;cci_table['a']['w']=13.092473372781;cci_table['a']['y']=19.137396449704;cci_table['c']['a']=13.663147928994;cci_table['c']['c']=10.107562130178;cci_table['c']['d']=12.841538461538;cci_table['c']['e']=10.043816568047;cci_table['c']['f']=10.298798816568;cci_table['c']['g']=8.2731065088757;cci_table['c']['h']=8.0606213017751;cci_table['c']['i']=12.841538461538;cci_table['c']['k']=10.291715976331;cci_table['c']['l']=8.2731065088757;cci_table['c']['m']=8.2731065088757;cci_table['c']['n']=10.298798816568;cci_table['c']['p']=10.298798816568;cci_table['c']['q']=10.065065088757;cci_table['c']['r']=12.841538461538;cci_table['c']['s']=9.8738284023669;cci_table['c']['t']=10.036733727811;cci_table['c']['v']=11.424970414201;cci_table['c']['w']=10.298798816568;cci_table['c']['y']=8.2731065088757;cci_table['d']['a']=5.5046153846154;cci_table['d']['c']=12.841538461538;cci_table['d']['d']=7.2;cci_table['d']['e']=12.973076923077;cci_table['d']['f']=12.446923076923;cci_table['d']['g']=16.626923076923;cci_table['d']['h']=17.065384615385;cci_table['d']['i']=7.2;cci_table['d']['k']=12.461538461538;cci_table['d']['l']=16.626923076923;cci_table['d']['m']=16.626923076923;cci_table['d']['n']=12.446923076923;cci_table['d']['p']=12.446923076923;cci_table['d']['q']=12.929230769231;cci_table['d']['r']=7.2;cci_table['d']['s']=13.323846153846;cci_table['d']['t']=12.987692307692;cci_table['d']['v']=10.123076923077;cci_table['d']['w']=12.446923076923;cci_table['d']['y']=16.626923076923;cci_table['e']['a']=13.853372781065;cci_table['e']['c']=10.043816568047;cci_table['e']['d']=12.973076923077;cci_table['e']['e']=9.9755177514793;cci_table['e']['f']=10.248713017751;cci_table['e']['g']=8.0783284023669;cci_table['e']['h']=7.8506656804734;cci_table['e']['i']=12.973076923077;cci_table['e']['k']=10.241124260355;cci_table['e']['l']=8.0783284023669;cci_table['e']['m']=8.0783284023669;cci_table['e']['n']=10.248713017751;cci_table['e']['p']=10.248713017751;cci_table['e']['q']=9.9982840236686;cci_table['e']['r']=12.973076923077;cci_table['e']['s']=9.7933875739645;cci_table['e']['t']=9.9679289940828;cci_table['e']['v']=11.455325443787;cci_table['e']['w']=10.248713017751;cci_table['e']['y']=8.0783284023669;cci_table['f']['a']=13.092473372781;cci_table['f']['c']=10.298798816568;cci_table['f']['d']=12.446923076923;cci_table['f']['e']=10.248713017751;cci_table['f']['f']=10.449056213018;cci_table['f']['g']=8.8574408284024;cci_table['f']['h']=8.6904881656805;cci_table['f']['i']=12.446923076923;cci_table['f']['k']=10.44349112426;cci_table['f']['l']=8.8574408284024;cci_table['f']['m']=8.8574408284024;cci_table['f']['n']=10.449056213018;cci_table['f']['p']=10.449056213018;cci_table['f']['q']=10.265408284024;cci_table['f']['r']=12.446923076923;cci_table['f']['s']=10.115150887574;cci_table['f']['t']=10.243147928994;cci_table['f']['v']=11.333905325444;cci_table['f']['w']=10.449056213018;cci_table['f']['y']=8.8574408284024;cci_table['g']['a']=19.137396449704;cci_table['g']['c']=8.2731065088757;cci_table['g']['d']=16.626923076923;cci_table['g']['e']=8.0783284023669;cci_table['g']['f']=8.8574408284024;cci_table['g']['g']=2.667825443787;cci_table['g']['h']=2.0185650887574;cci_table['g']['i']=16.626923076923;cci_table['g']['k']=8.835798816568;cci_table['g']['l']=2.667825443787;cci_table['g']['m']=2.667825443787;cci_table['g']['n']=8.8574408284024;cci_table['g']['p']=8.8574408284024;cci_table['g']['q']=8.1432544378698;cci_table['g']['r']=16.626923076923;cci_table['g']['s']=7.5589201183432;cci_table['g']['t']=8.0566863905325;cci_table['g']['v']=12.298520710059;cci_table['g']['w']=8.8574408284024;cci_table['g']['y']=2.667825443787;cci_table['h']['a']=19.771479289941;cci_table['h']['c']=8.0606213017751;cci_table['h']['d']=17.065384615385;cci_table['h']['e']=7.8506656804734;cci_table['h']['f']=8.6904881656805;cci_table['h']['g']=2.0185650887574;cci_table['h']['h']=1.3187130177515;cci_table['h']['i']=17.065384615385;cci_table['h']['k']=8.6671597633136;cci_table['h']['l']=2.0185650887574;cci_table['h']['m']=2.0185650887574;cci_table['h']['n']=8.6904881656805;cci_table['h']['p']=8.6904881656805;cci_table['h']['q']=7.920650887574;cci_table['h']['r']=17.065384615385;cci_table['h']['s']=7.2907840236686;cci_table['h']['t']=7.8273372781065;cci_table['h']['v']=12.399704142012;cci_table['h']['w']=8.6904881656805;cci_table['h']['y']=2.0185650887574;cci_table['i']['a']=5.5046153846154;cci_table['i']['c']=12.841538461538;cci_table['i']['d']=7.2;cci_table['i']['e']=12.973076923077;cci_table['i']['f']=12.446923076923;cci_table['i']['g']=16.626923076923;cci_table['i']['h']=17.065384615385;cci_table['i']['i']=7.2;cci_table['i']['k']=12.461538461538;cci_table['i']['l']=16.626923076923;cci_table['i']['m']=16.626923076923;cci_table['i']['n']=12.446923076923;cci_table['i']['p']=12.446923076923;cci_table['i']['q']=12.929230769231;cci_table['i']['r']=7.2;cci_table['i']['s']=13.323846153846;cci_table['i']['t']=12.987692307692;cci_table['i']['v']=10.123076923077;cci_table['i']['w']=12.446923076923;cci_table['i']['y']=16.626923076923;cci_table['k']['a']=13.113609467456;cci_table['k']['c']=10.291715976331;cci_table['k']['d']=12.461538461538;cci_table['k']['e']=10.241124260355;cci_table['k']['f']=10.44349112426;cci_table['k']['g']=8.835798816568;cci_table['k']['h']=8.6671597633136;cci_table['k']['i']=12.461538461538;cci_table['k']['k']=10.437869822485;cci_table['k']['l']=8.835798816568;cci_table['k']['m']=8.835798816568;cci_table['k']['n']=10.44349112426;cci_table['k']['p']=10.44349112426;cci_table['k']['q']=10.25798816568;cci_table['k']['r']=12.461538461538;cci_table['k']['s']=10.106213017751;cci_table['k']['t']=10.23550295858;cci_table['k']['v']=11.337278106509;cci_table['k']['w']=10.44349112426;cci_table['k']['y']=8.835798816568;cci_table['l']['a']=19.137396449704;cci_table['l']['c']=8.2731065088757;cci_table['l']['d']=16.626923076923;cci_table['l']['e']=8.0783284023669;cci_table['l']['f']=8.8574408284024;cci_table['l']['g']=2.667825443787;cci_table['l']['h']=2.0185650887574;cci_table['l']['i']=16.626923076923;cci_table['l']['k']=8.835798816568;cci_table['l']['l']=2.667825443787;cci_table['l']['m']=2.667825443787;cci_table['l']['n']=8.8574408284024;cci_table['l']['p']=8.8574408284024;cci_table['l']['q']=8.1432544378698;cci_table['l']['r']=16.626923076923;cci_table['l']['s']=7.5589201183432;cci_table['l']['t']=8.0566863905325;cci_table['l']['v']=12.298520710059;cci_table['l']['w']=8.8574408284024;cci_table['l']['y']=2.667825443787;cci_table['m']['a']=19.137396449704;cci_table['m']['c']=8.2731065088757;cci_table['m']['d']=16.626923076923;cci_table['m']['e']=8.0783284023669;cci_table['m']['f']=8.8574408284024;cci_table['m']['g']=2.667825443787;cci_table['m']['h']=2.0185650887574;cci_table['m']['i']=16.626923076923;cci_table['m']['k']=8.835798816568;cci_table['m']['l']=2.667825443787;cci_table['m']['m']=2.667825443787;cci_table['m']['n']=8.8574408284024;cci_table['m']['p']=8.8574408284024;cci_table['m']['q']=8.1432544378698;cci_table['m']['r']=16.626923076923;cci_table['m']['s']=7.5589201183432;cci_table['m']['t']=8.0566863905325;cci_table['m']['v']=12.298520710059;cci_table['m']['w']=8.8574408284024;cci_table['m']['y']=2.667825443787;cci_table['n']['a']=13.092473372781;cci_table['n']['c']=10.298798816568;cci_table['n']['d']=12.446923076923;cci_table['n']['e']=10.248713017751;cci_table['n']['f']=10.449056213018;cci_table['n']['g']=8.8574408284024;cci_table['n']['h']=8.6904881656805;cci_table['n']['i']=12.446923076923;cci_table['n']['k']=10.44349112426;cci_table['n']['l']=8.8574408284024;cci_table['n']['m']=8.8574408284024;cci_table['n']['n']=10.449056213018;cci_table['n']['p']=10.449056213018;cci_table['n']['q']=10.265408284024;cci_table['n']['r']=12.446923076923;cci_table['n']['s']=10.115150887574;cci_table['n']['t']=10.243147928994;cci_table['n']['v']=11.333905325444;cci_table['n']['w']=10.449056213018;cci_table['n']['y']=8.8574408284024;cci_table['p']['a']=13.092473372781;cci_table['p']['c']=10.298798816568;cci_table['p']['d']=12.446923076923;cci_table['p']['e']=10.248713017751;cci_table['p']['f']=10.449056213018;cci_table['p']['g']=8.8574408284024;cci_table['p']['h']=8.6904881656805;cci_table['p']['i']=12.446923076923;cci_table['p']['k']=10.44349112426;cci_table['p']['l']=8.8574408284024;cci_table['p']['m']=8.8574408284024;cci_table['p']['n']=10.449056213018;cci_table['p']['p']=10.449056213018;cci_table['p']['q']=10.265408284024;cci_table['p']['r']=12.446923076923;cci_table['p']['s']=10.115150887574;cci_table['p']['t']=10.243147928994;cci_table['p']['v']=11.333905325444;cci_table['p']['w']=10.449056213018;cci_table['p']['y']=8.8574408284024;cci_table['q']['a']=13.789964497041;cci_table['q']['c']=10.065065088757;cci_table['q']['d']=12.929230769231;cci_table['q']['e']=9.9982840236686;cci_table['q']['f']=10.265408284024;cci_table['q']['g']=8.1432544378698;cci_table['q']['h']=7.920650887574;cci_table['q']['i']=12.929230769231;cci_table['q']['k']=10.25798816568;cci_table['q']['l']=8.1432544378698;cci_table['q']['m']=8.1432544378698;cci_table['q']['n']=10.265408284024;cci_table['q']['p']=10.265408284024;cci_table['q']['q']=10.020544378698;cci_table['q']['r']=12.929230769231;cci_table['q']['s']=9.820201183432;cci_table['q']['t']=9.9908639053254;cci_table['q']['v']=11.445207100592;cci_table['q']['w']=10.265408284024;cci_table['q']['y']=8.1432544378698;cci_table['r']['a']=5.5046153846154;cci_table['r']['c']=12.841538461538;cci_table['r']['d']=7.2;cci_table['r']['e']=12.973076923077;cci_table['r']['f']=12.446923076923;cci_table['r']['g']=16.626923076923;cci_table['r']['h']=17.065384615385;cci_table['r']['i']=7.2;cci_table['r']['k']=12.461538461538;cci_table['r']['l']=16.626923076923;cci_table['r']['m']=16.626923076923;cci_table['r']['n']=12.446923076923;cci_table['r']['p']=12.446923076923;cci_table['r']['q']=12.929230769231;cci_table['r']['r']=7.2;cci_table['r']['s']=13.323846153846;cci_table['r']['t']=12.987692307692;cci_table['r']['v']=10.123076923077;cci_table['r']['w']=12.446923076923;cci_table['r']['y']=16.626923076923;cci_table['s']['a']=14.360639053254;cci_table['s']['c']=9.8738284023669;cci_table['s']['d']=13.323846153846;cci_table['s']['e']=9.7933875739645;cci_table['s']['f']=10.115150887574;cci_table['s']['g']=7.5589201183432;cci_table['s']['h']=7.2907840236686;cci_table['s']['i']=13.323846153846;cci_table['s']['k']=10.106213017751;cci_table['s']['l']=7.5589201183432;cci_table['s']['m']=7.5589201183432;cci_table['s']['n']=10.115150887574;cci_table['s']['p']=10.115150887574;cci_table['s']['q']=9.820201183432;cci_table['s']['r']=13.323846153846;cci_table['s']['s']=9.5788786982249;cci_table['s']['t']=9.784449704142;cci_table['s']['v']=11.536272189349;cci_table['s']['w']=10.115150887574;cci_table['s']['y']=7.5589201183432;cci_table['t']['a']=13.87450887574;cci_table['t']['c']=10.036733727811;cci_table['t']['d']=12.987692307692;cci_table['t']['e']=9.9679289940828;cci_table['t']['f']=10.243147928994;cci_table['t']['g']=8.0566863905325;cci_table['t']['h']=7.8273372781065;cci_table['t']['i']=12.987692307692;cci_table['t']['k']=10.23550295858;cci_table['t']['l']=8.0566863905325;cci_table['t']['m']=8.0566863905325;cci_table['t']['n']=10.243147928994;cci_table['t']['p']=10.243147928994;cci_table['t']['q']=9.9908639053254;cci_table['t']['r']=12.987692307692;cci_table['t']['s']=9.784449704142;cci_table['t']['t']=9.9602840236686;cci_table['t']['v']=11.458698224852;cci_table['t']['w']=10.243147928994;cci_table['t']['y']=8.0566863905325;cci_table['v']['a']=9.7318343195266;cci_table['v']['c']=11.424970414201;cci_table['v']['d']=10.123076923077;cci_table['v']['e']=11.455325443787;cci_table['v']['f']=11.333905325444;cci_table['v']['g']=12.298520710059;cci_table['v']['h']=12.399704142012;cci_table['v']['i']=10.123076923077;cci_table['v']['k']=11.337278106509;cci_table['v']['l']=12.298520710059;cci_table['v']['m']=12.298520710059;cci_table['v']['n']=11.333905325444;cci_table['v']['p']=11.333905325444;cci_table['v']['q']=11.445207100592;cci_table['v']['r']=10.123076923077;cci_table['v']['s']=11.536272189349;cci_table['v']['t']=11.458698224852;cci_table['v']['v']=10.797633136095;cci_table['v']['w']=11.333905325444;cci_table['v']['y']=12.298520710059;cci_table['w']['a']=13.092473372781;cci_table['w']['c']=10.298798816568;cci_table['w']['d']=12.446923076923;cci_table['w']['e']=10.248713017751;cci_table['w']['f']=10.449056213018;cci_table['w']['g']=8.8574408284024;cci_table['w']['h']=8.6904881656805;cci_table['w']['i']=12.446923076923;cci_table['w']['k']=10.44349112426;cci_table['w']['l']=8.8574408284024;cci_table['w']['m']=8.8574408284024;cci_table['w']['n']=10.449056213018;cci_table['w']['p']=10.449056213018;cci_table['w']['q']=10.265408284024;cci_table['w']['r']=12.446923076923;cci_table['w']['s']=10.115150887574;cci_table['w']['t']=10.243147928994;cci_table['w']['v']=11.333905325444;cci_table['w']['w']=10.449056213018;cci_table['w']['y']=8.8574408284024;cci_table['y']['a']=19.137396449704;cci_table['y']['c']=8.2731065088757;cci_table['y']['d']=16.626923076923;cci_table['y']['e']=8.0783284023669;cci_table['y']['f']=8.8574408284024;cci_table['y']['g']=2.667825443787;cci_table['y']['h']=2.0185650887574;cci_table['y']['i']=16.626923076923;cci_table['y']['k']=8.835798816568;cci_table['y']['l']=2.667825443787;cci_table['y']['m']=2.667825443787;cci_table['y']['n']=8.8574408284024;cci_table['y']['p']=8.8574408284024;cci_table['y']['q']=8.1432544378698;cci_table['y']['r']=16.626923076923;cci_table['y']['s']=7.5589201183432;cci_table['y']['t']=8.0566863905325;cci_table['y']['v']=12.298520710059;cci_table['y']['w']=8.8574408284024;cci_table['y']['y']=2.667825443787
--Precalculated Table#

--#Calculations
local function _calc()
    local i
    local ii
    p("Getting Segment Score out of the Matrix")
    c_strength = {}
    for i = 1, i_segcount do
        c_strength[i] = {}
        for ii = i + 2, i_segcount - 2 do
            c_strength[i][ii] = (hci_table[aa[i]][aa[ii]] * 2) + (cci_table[aa[i]][aa[ii]] * 1.26 * 1.065) + (sci_table[aa[i]][aa[ii]])
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
	p("approx. time till that recipe is finished: " .. timeline(estimated_time))
	p(os.date("Recipe will be approx. finished: %a, %c", estimated_time + currentTimeUsed))
    p("==MAX SCORE=" .. sc_max .. "==")
    --end
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
				rebuild()
			end
		else
			rebuild()
		end
		seg = mutable[mut] - 2
		r = seg + 3
		if not b_re_m_ignore_struct then
			if ss[mutable[mut]] == "L" then
				rebuild()
			end
		else
			rebuild()
		end
		seg = mutable[mut] - 1
		seg_mut = mutable[mut]
		r = seg + 2
		if not b_re_m_ignore_struct then
			if ss[mutable[mut]] == "L" then
				rebuild()
			end
		else
			rebuild()
		end
	end
	end
    if b_m_tweak_AT then
    sidechain_tweak(mutable[mut])
    end
--    select.segs()
  --  fuze.start(sl_mut)
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
    score.recent.save()
    if option == 1 then
        work.step("s", 1, cl1)
        work.step("wa", 2, cl2)
        work.step("wa", 1, 1)
        work.step("s", 1, 1)
        work.step("wa", 1, cl2)
        work.step("wa", 2, 1)
    elseif option == 2 then
        work.step("s", 1, cl1)
        work.step("wa", 2, cl2)
        work.step("s", 1, 1)
        work.step("wa", 3, 1)
        score.recent.restore()
    elseif option == 4 then
        work.step("s", 1, cl_1)
        work.step("wa", 2, 1)
        work.step("s", 1, cl_2)
        work.step("wa", 2, 1)
        if cl_3 ~= 0 then
        work.step("s", 1, cl_3)
        work.step("wa", 2, 1)
        end
        if cl_4 ~= 0 then
        work.step("s", 1, cl_4)
        work.step("wa", 2, 1)
        end
    else
        if b_tweaking then work.step("wa", 2, 1) end
        work.step("s", 1, cl1)
        work.step("wa", 2, 1)
        if work.step("s", 1, cl2) then work.step("wa", 2, 1) end
        if work.step("s", 1, cl1 - 0.02) then work.step("wa", 2, 1) end
        if work.step("s", 1, 1) then work.step("wa", 2, 1) end
    end -- if option
    score.recent.restore()
end -- function

local function _part(option, cl1, cl2)
    local s_f1 = get.score()
    fuze.loss(option, cl1, cl2)
    local s_f2 = get.score()
    get.increase(s_f1, s_f2, sl_f)
end -- function

local function _start(slot)
    p("Fuzing")
    sl_f = sl.request()
    local s_f1 = get.score()
    sl.save(sl_f)
    if b_fuze_pf then
        fuze.part(1, 0.1, 0.6)
    end
    if b_fuze_bf then
        fuze.part(3, 0.05, 0.07)
    end
    if b_fuze_qstab then
        fuze.part(2, 0.1, 0.4)
    end
    if b_test2 then
    fuze.part(4,0,0)
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
    if math.abs(_s1 - _s2) > 0.15 then
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
    local c_strength = 0.1 + 0.1 * i_pp_loss
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
            c_strength = math.floor(c_strength * 4 / cbands, 4)
        end -- if
        if b_solo_quake then
            bands.disable()
            bands.enable(ii)
            s3 = math.floor(s3 * 2, 4)
            c_strength = math.floor(c_strength * 2, 4)
        end -- if b_solo_quake
    end -- if b_pp
    if b_cu then
        s3 = math.floor(s3 / 10, 4)
    end -- if b_cu
    if s3 > 200 * i_pp_loss then
        s3 = 200 * i_pp_loss
    end -- if s3
    if c_strength > 0.2 * i_pp_loss then
        c_strength = 0.2 * i_pp_loss
    end -- if c_strength
    p("Pulling until a loss of more than " .. s3 .. " points")
    local s1 = get.score()
    repeat
        p("Band strength: " .. c_strength)
        if b_solo_quake then
            bands.strength(ii, c_strength)
        else -- if b_solo
            for i = 1, cbands do
                if bands.info[i][bands.part.enabled] then
                    bands.strength(i, c_strength)
                end
            end -- for
        end -- if b_solo
        score.recent.save()
        set.clashImportance(0.9)
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
        c_strength = math.floor(c_strength * 2 - c_strength * 10 / 11, 4)
        if b_pp_pre_local or b_cu or b_solo_quake then
            c_strength = math.floor(c_strength * 2 - c_strength * 6 / 7, 4)
        end -- if b_solo
        if c_strength > 10 then
            break
        end -- if c_strength
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
            if max_str <= c_strength[i][ii] then
                if max_str ~= c_strength[i][ii] then
                    min_dist = 999
                end -- if max_str ~=
                max_str = c_strength[i][ii]
                if min_dist > distances[i][ii] then
                    min_dist = distances[i][ii]
                end -- if min_dist
            end -- if max_str <=
        end -- for ii
        for ii = i + 2, i_segcount - 2 do
            if c_strength[i][ii] == max_str and min_dist == distances[i][ii] then
                if get.checksame(i, ii) then
                    bands.addToSegs(i , ii)
                    if b_pp_soft then
                        local cband = get.bandcount()
                        bands.length(cband, distances[i][ii] - i_pp_len)
                    end -- if pp_soft
                end -- if get.checksame
            end -- if c_strength
        end -- for ii
    end -- for i
end -- function

local function _one(_seg)
    get.dists()
    local max_str = 0
    for ii = _seg + 2, i_segcount - 2 do
        if max_str <= c_strength[_seg][ii] then
            max_str = c_strength[_seg][ii]
        end -- if max_str <=
    end -- for ii
    for ii = _seg + 2, i_segcount - 2 do
        if c_strength[_seg][ii] == max_str then
            if get.checksame(_seg, ii) then
                bands.addToSegs(_seg , ii)
                if b_pp_soft then
                    local cband = get.bandcount()
                    bands.length(cband, distances[_seg][ii] - i_pp_len)
                end
            end
        end -- if c_strength
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
    b_sphering = true
    snaps = sl.request()
    cs = get.score()
    c_snap = cs
    local s_1
    local s_2
    local c_s
    local c_s2
    sl.save(snaps)
    iii = get.snapcount(seg)
    p("Snapcount: " .. iii .. " - segment " .. seg)
    if iii > 1 then
        snapwork = sl.request()
        ii = 1
        while ii <= iii do
            sl.load(snaps)
            c_s = get.score()
            c_s2 = c_s
            p("Snap " .. ii .. "/ " .. iii)
            do_.snap(seg, ii)
            c_s2 = get.score()
            sl.save(snapwork)
            select.segs(seg)
            do_.freeze("s")
            fuze.start(snapwork)
            do_.unfreeze()
            select.segs(seg)
            fuze.start(snapwork)
            if get.score ~= c_s2 then
            work.step("wa", 1, 0.7)
            work.step("wa", 2, 1)
            end
            sl.save(snapwork)
            if c_snap < get.score() then
                c_snap = get.score()
                sl.save(snaps)
            end
            ii = ii + 1
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
    b_sphering = false
    sl.release(snaps)
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
function rebuild()
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
    for ii = 1, #sl_r do
        sl.load(sl_r[ii])
        sl.release(sl_r[ii])
		sl_r[ii] = nil
		if rs_1 ~= get.score() then
        rs_1 = get.score()
		if rs_1 ~= rs_0 then
        p("Stabilize try "..ii)
        bands.delete()
        fuze.start(sl_re)
        rs_2 = get.score()
        if b_mutating then
        if (sc_max - rs_2 ) < 30 then
        sidechain_tweak(seg_mut)
        end
        if get.increase(rs_0, rs_2, sl_mut) then
            rs_0 = get.score()
        end
        else
        if get.increase(rs_0, rs_2, sl_overall) then
            rs_0 = get.score()
        end
        end
		end
		end
    end
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
	local i_will_be = #mutable - 4
    for i = i_will_be, 1, -1 do
        p("Mutating segment " .. mutable[i])
        sl.save(sl_overall)
        sc_mut = get.score()
		local ii
        for ii = 1, #amino.segs do
			local start = (ii - 1 +(i_will_be - i) *#amino.segs)
			local stop = (#amino.segs - ii+ #amino.segs * (i - 1))
			time_mod = stop / start
			progress = math.floor(start / (i_will_be * #amino.segs), 3)
			get.checkTime()
            do_.mutate(i, ii)
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
b_tweaking = true
    p("AT: Sidechain tweak")
    sl_reset = sl.request()
    sl.save(sl_reset)
            deselect.all()  
            select.segs(seg)
            local ss=get.score()
            g_total_score = get.score()
            if work.step("s", 2, 0, false) then
    sl_tweak_work = sl.request()
    sl.save(sl_tweak_work)
            p("Try sgmnt ", seg)
            select.segs(true, seg)
            if (getNear(seg)==true) then
    sl_tweak = sl.request()
                fuze.start(sl_tweak)
            sl.release(sl_tweak)
            end
            if ss < get.score() then
            sl.save(sl_reset)
            deselect.all()  
            select.segs(seg)
            local ss=get.score()
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
            if(get.score() > g_total_score - 30) then
            
    p("AT: Sidechain tweak around")
            select.segs(true, seg)
            deselect.index(seg)
            work.step("s", 1, 0.1, false)
            select.index(seg)
            if (getNear(i)==true) then
    sl_tweak = sl.request()
                fuze.start(sl_tweak)
            sl.release(sl_tweak)
            end
            if ss > get.score() then
            sl.load(sl_reset)
            end
            end
            else
            getNear(i)
            sl_tweak = sl.request()
            fuze.start(sl_tweak)
            sl.release(sl_tweak)
            if ss > get.score() then
            sl.load(sl_reset)
            end
            end -- if work.step
            sl.release(sl_reset)
            sl.release(sl_tweak_work)
            b_tweaking = false
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
end -- if b_predict
save.SaveSecondaryStructure()
if b_str_re then
    struct_rebuild()
end -- if b_str_re
if b_cu then
    struct_curler()
end -- if b_cu
if b_pp then
    if i_s0 < 0 then
        fuze.start(sl_overall)
    end
    for i = 1, i_pp_trys do
        if b_pp_pre_strong or b_pp_pre_local then
            calc.run()
        end
        dists()
    end -- for i
end -- if b_pp
if b_mutate then
    sl_mut = sl.request()
    mutate()
    sl.release(sl_mut)
end
if b_rebuild then
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
end
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
        end -- if b_rebuild
        if b_lws then
            p(seg .. "-" .. r)
            work.flow("wl")
        end -- if b_lws
    end -- for ii
end -- for i
if b_fuze then
    fuze.start(sl_overall)
end -- if b_fuze
if b_test then
if b_test1 then
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
b_test2 = true
if b_test2 then
scoie=0
for i=1,50 do
if i < 10 then
mod1 = 1
elseif i < 30 then
mod1 = 2
else
mod1 = 5
end
cl_1 = i*0.01*mod1
for ii=1,50 do
if ii < 10 then
mod2 = 1
elseif ii < 30 then
mod2 = 2
else
mod2 = 5
end
cl_2 = ii*0.01*mod2
for iii=1,100 do
if iii < 10 then
mod3 = 1
elseif iii < 30 then
mod3 = 2
else
mod3 = 5
end
cl_3 = iii*0.01*mod3
while cl_4 < 1 do
if iiii < 10 then
mod4 = 1
elseif iiii < 30 then
mod4 = 2
else
mod4 = 5
end
cl_4 = iiii*0.01*mod4
for x=0,2 do
reset.puzzle()
sl.save(sl_overall)
p("1:"..cl_1.." 2:"..cl_2.." 3:"..cl_3.." 4:"..cl_4)
fuze.start(sl_overall)
sl.load(sl_overall)
s_1 = get.score()
if (s_1 - i_s0) > scoie then
scoie = s_1 - i_s0
bcl_1=cl_1
bcl_2=cl_2
bcl_3=cl_3
bcl_4=cl_4
end
p("Best: cl1:"..bcl_1.." cl2:"..bcl_2.." cl3:"..bcl_3.." cl4:"..bcl_4.." Scores:"..scoie)
end
end
end
end
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
local function _HCI(a, b) -- hydropathy
    return 20 - math.abs((amino.hydroscale(a) - amino.hydroscale(b)) * 19 / 10.6)
end

local function _SCI(a, b) -- size
    return 20 - math.abs((amino.size(a) + amino.size(b) - 123) * 19 / 135)
end

local function _CCI(a, b) -- charge
    return 11 - (amino.charge(a) - 7) * (amino.charge(b) - 7) * 19 / 33.8
end

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