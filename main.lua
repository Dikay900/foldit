--[[#Header
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions and ideas goes to Seagat, Rav3n_pl, Tlaloc, Gary Forbis and BitSpawn
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
iVersion            = 1237
iSegmentCount       = structure.GetCount()
--#Release
isReleaseVersion    = true
strReleaseDate      = "2012"
iReleaseVersion     = 5
--Release#
--Game vars#

--#Settings: default
--#Main                                     default         description
isLocalWiggleEnabled        = false         -- false        do local wiggle and rewiggle
isRebuildingEnabled         = false         -- false        rebuild | see #Rebuilding
isCompressingEnabled        = false         -- false        pull hydrophobic amino acids in different modes then fuze | see #Pull
isStructureRebuildEnabled   = false         -- false        rebuild the protein based on the secondary structures | see #Structed rebuilding
isCurlingEnabled            = false         -- false        Do bond the structures and curl it, try to improve it and get some points
isSnappingEnabled           = false         -- false        should we snap every sidechain to different positions
isFuzingEnabled             = true         -- false        should we fuze | see #Fuzing
isMutatingEnabled           = false         -- false        it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
isPredictingEnabled         = false         -- false        reset and predict then the secondary structure based on the amino acids of the protein
--isEvolutionEnabled                                        TODO: IDEA to fully automatic random methods -- rebuilding/pushing/pulling
bExploringWork              = false         -- false        if true then the overall score will be taken if a exploration puzzle, if false then just the stability score is used for the methods
--Main#

--#Working                      default             description
iStartSegment   = 1             -- 1                the first segment to work with
iEndSegment     = iSegmentCount -- iSegmentCount    the last segment to work with
iStartingWalk   = 2             -- 1                with how many segs shall we work - Walker
iEndWalk        = 2             -- 3                starting at the current segment + iStartingWalk to segment + iEndWalk
--Working#

--#LocalWiggle
fScoreMustChange = 0.0001         -- 0.01         an action tries to get this score, then it will repeat itself | adjust a lower value to get the lws script working on high evo- / solos
--LocalWiggle#

--#Mutating
-- TODO: all mutating things into the mutating category and method
bRebuildAfterMutating   = true
bOptimizeSidechain      = true
bMutateSurroundingAfter = false
fClashingForMutating    = 0.75  -- 0.75         cl for mutating
--Mutating#

--#Pull                                         default     description
iCompressingTrys                    = 1         -- 1        how often should the pull start over?
fCompressingLoss                    = 1         -- 1        the score / 100 * fCompressingLoss is the general formula for calculating the points we must lose till we fuze
bMutateAfterCompressing             = false
bCompressingConsiderStructure       = true      -- true     don't band segs of same structure together if segs are in one struct (between one helix or sheet)
fCompressingBondingPercentage       = 0.08      -- 0.08
iCompressingBondingLength           = 4
bCompressingFixxedBonding           = false     -- false
iCompressingFixxedStartSegment      = 54        -- 0
iCompressingFixxedEndSegment        = 57        -- 0
bCompressingSoftBonding             = false
bCompressingFuze                    = true
bCompressingSoloBonding             = false     -- false    just one segment is used on every method and all segs are tested
bCompressingLocalBonding            = false     -- false
--Methods
bCompressingPredictedBonding        = false     -- true     bands are created which pull segs together based on the size, charge and isoelectric point of the amino acids
bCompressingPredictedLocalBonding   = false     -- false    TODO: check if there are bands
bCompressingEvolutionBonding        = true     -- true
iCompressingEvolutionRounds         = 10
bCompressingEvolutionOnlyBetter     = true
bCompressingPushPull                = false     -- true
bCompressingPull                    = false     -- true     hydrophobic segs are pulled together
-- TODO: First Push out then pull in -- test vs combined push,pull
bCompressingCenterPushPull          = false     -- true
bCompressingCenterPull              = false     -- true     hydrophobic segs are pulled to the center segment
-- TODO: IDEA (ErichVanSterich: 'alternate(pictorial) work') creating herds for 'center' like working
bCompressingVibrator                = false     -- false
bCompressingRefineBonds             = false      -- false    pulls already bonded segments to maybe strengthen them | TODO: Maybe put into curler
--Pull

--#Fuzing
bFuzingPinkFuze = false         -- false        Use Pink Fuze / Wiggle out used exclusively in some cases
bFuzingBlueFuze = true          -- true         Use Bluefuse
--Fuzing#

--#Snapping
-- TODO: Rework Snapping :/ make use of AT implemention | just sidechain snapping with rotamers need new code
--Snapping#

--#Rebuilding
bRebuildWorst                       = false         -- false        rebuild worst scored parts of the protein | TODO: Do it some times with table of worst segments from worst to best
iWorstSegmentLength                 = 4
iRebuildTrys                        = 10            -- 10           how many different shapes we try to get
bRebuildLoops                       = false         -- false        rebuild whole loops | TODO: implement max length of loop rebuild max 5 would be good i think then walk through the structure
bRebuildWalking                     = true         -- true         walk through the protein rebuilding every segment with different lengths of rebuilds
iRebuildsTillSave                   = 1             -- 2            max rebuilds till best rebuild will be chosen
iRebuildStrength                    = 1             -- 1            the iterations a rebuild will do at default, automatically increased if no change in score
bRebuildInMutatingIgnoreStructures  = false         -- true         TODO: implement completly in rebuilding / combine with loop rebuild
bRebuildInMutatingDeepRebuild       = true          -- true         rebuild length 3,4,5 else just 3
bRebuildTweakWholeRebuild           = false          -- false       All Sidechains get tweaked after rebuild not just the one focusing in the rebuild
--Rebuilding#

--#Predicting
bPredictingFull                 = false      -- false        try to detect the secondary structure between every segment, there can be less loops but the protein become difficult to rebuild
bPredictingAddPrefferedSegments = true      -- true
bPredictingCombine              = false     -- false        TODO: Doesn't work at all
bPredictingOtherMethod          = true
--Predicting#

--#Curler
bCurlingHelix         = true          -- true
bCurlingSheet         = true          -- true
--Curler#

--#Structed rebuilding
iStructuredRebuildTillSave  = 2             -- 2            same as iRebuildsTillSave at #Rebuilding
iStructuredRebuildStrength  = 1             -- 1            same as iRebuildStrength at #Rebuilding
bStructuredRebuildHelix     = true          -- true         should we rebuild helices
bStructuredRebuildSheet     = true          -- true         should we rebuild sheets
bStructuredRebuildFuze      = false         -- false        should we fuze after one rebuild | better let it rebuild then handwork it yourself and then fuze!
--Structed rebuilding#
--Settings#

--#Constants | Game vars
tSaveSlots             = {}
for _i = 1, 100 do
    tSaveSlots[#tSaveSlots + 1] = _i
end
timeStart           = os.time()
iTimeChecked        = 0
fEstimatedTimeMod   = 1
fProgress           = 0
bSpheredFuzing      = false
bMutating           = false
bTweaking           = false
tSelectedSegments   = {}
bChanged            = true
bStructureChanged   = true
fCompressingBondingPercentage   = fCompressingBondingPercentage / iSegmentCount * 100
if current.GetExplorationMultiplier() == 0 then
    bIsExploringPuzzle = false
else
    bIsExploringPuzzle = true
end
math.randomseed(recipe.GetRandomSeed())
--Constants | Game vars#

--#Optimizing
--#General
p   = print

reset =
{
    puzzle  = puzzle.StartOver
}
--General#

--#Bonding
local function _addToSegs(segment1, segment2)
    local count = band.AddBetweenSegments(segment1, segment2 --[[integer atomIndex1], [integer atomIndex2]])
    if count ~= nil then
        bands.info[count] = {3.5, 1, segment1, segment2, true}
        return true
    else
        return false
    end
end

local function _addToArea(segment, x, y , length, theta, phi)
    local count = band.Add(segment, x, y, length, theta, phi)
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

local function _getStrength(_band)
    return bands.info[_band][bands.part.strength]
end

local function _getLength(_band)
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
        length  = _getLength,
        strength= _getStrength,
        start   = _startseg,
        _end    = _endseg,
        enabled = _enabled
    },
    info        = {},
    part        = {length = 1, strength = 2, start = 3, _end = 4, enabled = 5}
}
--Bonding#

--#Wiggle
local function _localAll(a)
    structure.LocalWiggleAll(a, true, true)
end
local function _localAllBackbone(a)
    structure.LocalWiggleAll(a, true, false)
end
local function _localAllSidechains(a)
    structure.LocalWiggleAll(a, false, true)
end
local function _localSelected(a)
    structure.LocalWiggleSelected(a, true, true)
end
local function _localSelectedBackbone(a)
    structure.LocalWiggleSelected(a, true, false)
end
local function _localSelectedSidechains(a)
    structure.LocalWiggleSelected(a, false, true)
end
local function _all(a)
    structure.WiggleAll(a, true, true)
end
local function _selected(a)
    structure.WiggleSelected(a, true, true)
end
local function _allSidechains(a)
    structure.WiggleAll(a, false, true)
end
local function _selectedSidechains(a)
    structure.WiggleSelected(a, false, true)
end
local function _allBackbone(a)
    structure.WiggleAll(a, true, false)
end
local function _selectedBackbone(a)
    structure.WiggleSelected(a, true, false)
end

wiggle =
{
    shake                   = structure.ShakeSidechainsAll,
    shakeSelected           = structure.ShakeSidechainsSelected,
    localAll                = _localAll,
    localAllBackbone        = _localAllBackbone,
    localAllSidechains      = _localAllSidechains,
    localSelected           = _localSelected,
    localSelectedBackbone   = _localSelectedBackbone,
    localSelectedSidechains = _localSelectedSidechains,
    all                     = _all,
    selected                = _selected,
    allSidechains           = _allSidechains,
    selectedSidechains      = _selectedSidechains,
    allBackbone             = _allBackbone,
    selectedBackbone        = _selectedBackbone
}
--Wiggle#

local function _segs(left, right)
    if left < 1 then
        left = 1
    end
    workingSegmentLeft = left
    if right ~= nil then
        if right > iSegmentCount then
            right = iSegmentCount
        end
        workingSegmentRight = right
    else
        workingSegmentRight = left
    end
    get.midTable(left, right)
--    get.rangeTable(left, right)
end

set =
{
    segs            = _segs,
    _ss             = structure.SetSecondaryStructure,
    ss              = structure.SetSecondaryStructureSelected,
    _aa             = structure.SetAminoAcid,
    aa              = structure.SetAminoAcidSelected,
    clashImportance = behavior.SetClashImportance,
    wiggleAccuracy  = behavior.SetWiggleAccuracy,
    shakeAccuracy   = behavior.SetShakeAccuracy
}

score =
{
    current =
    {
        energyScore         = current.GetEnergyScore,
        rankedScore         = current.GetScore,
        multiplier          = current.GetExplorationMultiplier,
        segmentScore        = current.GetSegmentEnergyScore,
        segmentScorePart    = current.GetSegmentEnergySubscore,
        conditions          = current.AreConditionsMet
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

--#Math
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
--Math#
--Optimizing#

--#Amino
local function _short(segment)
    return amino.table[aa[segment]][amino.part.short]
end

local function _abbrev(segment)
    return amino.table[aa[segment]][amino.part.abbrev]
end

local function _long(segment)
    return amino.table[aa[segment]][amino.part.longname]
end

local function _h(segment)
    return amino.table[aa[segment]][amino.part.hydro]
end

local function _hscale(segment)
    return amino.table[aa[segment]][amino.part.scale]
end

local function _pref(segment)
    return amino.table[aa[segment]][amino.part.pref]
end

local function _mol(segment)
    return amino.table[aa[segment]][amino.part.mol]
end

local function _pl(segment)
    return amino.table[aa[segment]][amino.part.pl]
end

local function _vdw_radius(segment)
    return (amino.table[aa[segment]][amino.part.vdw_vol] * 3 / 4 / 3.14159) ^ (1 / 3)
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
tCalculatedStrength = {}
function _setIt()
    local i
    for i = 1, #amino.segs do
        tCalculatedStrength[amino.segs[i]] = {}
    end
end
_setIt()
tCalculatedStrength['a']['a'] = 32.372856210914;tCalculatedStrength['a']['c'] = 27.185248498021;tCalculatedStrength['a']['d'] = 27.775347149814;tCalculatedStrength['a']['e'] = 50.456350961466;tCalculatedStrength['a']['f'] = 20.353692652058;tCalculatedStrength['a']['g'] = 51.672531784327;tCalculatedStrength['a']['h'] = 49.478695919409;tCalculatedStrength['a']['i'] = 27.775347149814;tCalculatedStrength['a']['k'] = 8.3750653242535;tCalculatedStrength['a']['l'] = 51.672531784327;tCalculatedStrength['a']['m'] = 51.672531784327;tCalculatedStrength['a']['n'] = 20.353692652058;tCalculatedStrength['a']['p'] = 20.353692652058;tCalculatedStrength['a']['q'] = 34.639588682129;tCalculatedStrength['a']['r'] = 27.775347149814;tCalculatedStrength['a']['s'] = 50.24328334011;tCalculatedStrength['a']['t'] = -7.5041917681561;tCalculatedStrength['a']['v'] = -11.191528474216;tCalculatedStrength['a']['w'] = 20.353692652058;tCalculatedStrength['a']['y'] = 51.672531784327;tCalculatedStrength['c']['a'] = 27.185248498021;tCalculatedStrength['c']['c'] = 48.875204881745;tCalculatedStrength['c']['d'] = 41.855546099553;tCalculatedStrength['c']['e'] = 26.635693125618;tCalculatedStrength['c']['f'] = 43.066057732232;tCalculatedStrength['c']['g'] = 29.856824872338;tCalculatedStrength['c']['h'] = 36.564715193754;tCalculatedStrength['c']['i'] = 41.855546099553;tCalculatedStrength['c']['k'] = 31.049563415669;tCalculatedStrength['c']['l'] = 29.856824872338;tCalculatedStrength['c']['m'] = 29.856824872338;tCalculatedStrength['c']['n'] = 43.066057732232;tCalculatedStrength['c']['p'] = 43.066057732232;tCalculatedStrength['c']['q'] = 53.951399737082;tCalculatedStrength['c']['r'] = 41.855546099553;tCalculatedStrength['c']['s'] = 31.24966683069;tCalculatedStrength['c']['t'] = 13.807094727994;tCalculatedStrength['c']['v'] = 17.541687818383;tCalculatedStrength['c']['w'] = 43.066057732232;tCalculatedStrength['c']['y'] = 29.856824872338;tCalculatedStrength['d']['a'] = 27.775347149814;tCalculatedStrength['d']['c'] = 41.855546099553;tCalculatedStrength['d']['d'] = 45.823199111111;tCalculatedStrength['d']['e'] = 42.104501069128;tCalculatedStrength['d']['f'] = 35.260244055958;tCalculatedStrength['d']['g'] = 52.604844798097;tCalculatedStrength['d']['h'] = 60.186240557383;tCalculatedStrength['d']['i'] = 45.823199111111;tCalculatedStrength['d']['k'] = 23.272866587324;tCalculatedStrength['d']['l'] = 52.604844798097;tCalculatedStrength['d']['m'] = 52.604844798097;tCalculatedStrength['d']['n'] = 35.260244055958;tCalculatedStrength['d']['p'] = 35.260244055958;tCalculatedStrength['d']['q'] = 49.257385438694;tCalculatedStrength['d']['r'] = 45.823199111111;tCalculatedStrength['d']['s'] = 47.417279124496;tCalculatedStrength['d']['t'] = 7.0786044250923;tCalculatedStrength['d']['v'] = 5.1062953213999;tCalculatedStrength['d']['w'] = 35.260244055958;tCalculatedStrength['d']['y'] = 52.604844798097;tCalculatedStrength['e']['a'] = 50.456350961466;tCalculatedStrength['e']['c'] = 26.635693125618;tCalculatedStrength['e']['d'] = 42.104501069128;tCalculatedStrength['e']['e'] = 49.559882678117;tCalculatedStrength['e']['f'] = 20.844876012496;tCalculatedStrength['e']['g'] = 41.139593752458;tCalculatedStrength['e']['h'] = 37.789381517717;tCalculatedStrength['e']['i'] = 42.104501069128;tCalculatedStrength['e']['k'] = 8.8277028056971;tCalculatedStrength['e']['l'] = 41.139593752458;tCalculatedStrength['e']['m'] = 41.139593752458;tCalculatedStrength['e']['n'] = 20.844876012496;tCalculatedStrength['e']['p'] = 20.844876012496;tCalculatedStrength['e']['q'] = 33.858758035763;tCalculatedStrength['e']['r'] = 42.104501069128;tCalculatedStrength['e']['s'] = 48.421713960905;tCalculatedStrength['e']['t'] = -8.4392059304994;tCalculatedStrength['e']['v'] = -4.5715503537188;tCalculatedStrength['e']['w'] = 20.844876012496;tCalculatedStrength['e']['y'] = 41.139593752458;tCalculatedStrength['f']['a'] = 20.353692652058;tCalculatedStrength['f']['c'] = 43.066057732232;tCalculatedStrength['f']['d'] = 35.260244055958;tCalculatedStrength['f']['e'] = 20.844876012496;tCalculatedStrength['f']['f'] = 54.40946764336;tCalculatedStrength['f']['g'] = 24.575175436732;tCalculatedStrength['f']['h'] = 31.34416587945;tCalculatedStrength['f']['i'] = 35.260244055958;tCalculatedStrength['f']['k'] = 42.395009997506;tCalculatedStrength['f']['l'] = 24.575175436732;tCalculatedStrength['f']['m'] = 24.575175436732;tCalculatedStrength['f']['n'] = 54.40946764336;tCalculatedStrength['f']['p'] = 54.40946764336;tCalculatedStrength['f']['q'] = 48.154472611832;tCalculatedStrength['f']['r'] = 35.260244055958;tCalculatedStrength['f']['s'] = 25.50772981461;tCalculatedStrength['f']['t'] = 25.225861455393;tCalculatedStrength['f']['v'] = 28.561267086612;tCalculatedStrength['f']['w'] = 54.40946764336;tCalculatedStrength['f']['y'] = 24.575175436732;tCalculatedStrength['g']['a'] = 51.672531784327;tCalculatedStrength['g']['c'] = 29.856824872338;tCalculatedStrength['g']['d'] = 52.604844798097;tCalculatedStrength['g']['e'] = 41.139593752458;tCalculatedStrength['g']['f'] = 24.575175436732;tCalculatedStrength['g']['g'] = 39.476487407462;tCalculatedStrength['g']['h'] = 35.560533308816;tCalculatedStrength['g']['i'] = 52.604844798097;tCalculatedStrength['g']['k'] = 12.539144167802;tCalculatedStrength['g']['l'] = 39.476487407462;tCalculatedStrength['g']['m'] = 39.476487407462;tCalculatedStrength['g']['n'] = 24.575175436732;tCalculatedStrength['g']['p'] = 24.575175436732;tCalculatedStrength['g']['q'] = 36.966741409703;tCalculatedStrength['g']['r'] = 52.604844798097;tCalculatedStrength['g']['s'] = 45.284680600725;tCalculatedStrength['g']['t'] = -5.4066548050812;tCalculatedStrength['g']['v'] = 2.157180949214;tCalculatedStrength['g']['w'] = 24.575175436732;tCalculatedStrength['g']['y'] = 39.476487407462;tCalculatedStrength['h']['a'] = 49.478695919409;tCalculatedStrength['h']['c'] = 36.564715193754;tCalculatedStrength['h']['d'] = 60.186240557383;tCalculatedStrength['h']['e'] = 37.789381517717;tCalculatedStrength['h']['f'] = 31.34416587945;tCalculatedStrength['h']['g'] = 35.560533308816;tCalculatedStrength['h']['h'] = 41.614426035558;tCalculatedStrength['h']['i'] = 60.186240557383;tCalculatedStrength['h']['k'] = 19.305871643064;tCalculatedStrength['h']['l'] = 35.560533308816;tCalculatedStrength['h']['m'] = 35.560533308816;tCalculatedStrength['h']['n'] = 31.34416587945;tCalculatedStrength['h']['p'] = 31.34416587945;tCalculatedStrength['h']['q'] = 43.661053926385;tCalculatedStrength['h']['r'] = 60.186240557383;tCalculatedStrength['h']['s'] = 41.880157147049;tCalculatedStrength['h']['t'] = 1.278605841779;tCalculatedStrength['h']['v'] = 9.2859832173762;tCalculatedStrength['h']['w'] = 31.34416587945;tCalculatedStrength['h']['y'] = 35.560533308816;tCalculatedStrength['i']['a'] = 27.775347149814;tCalculatedStrength['i']['c'] = 41.855546099553;tCalculatedStrength['i']['d'] = 45.823199111111;tCalculatedStrength['i']['e'] = 42.104501069128;tCalculatedStrength['i']['f'] = 35.260244055958;tCalculatedStrength['i']['g'] = 52.604844798097;tCalculatedStrength['i']['h'] = 60.186240557383;tCalculatedStrength['i']['i'] = 45.823199111111;tCalculatedStrength['i']['k'] = 23.272866587324;tCalculatedStrength['i']['l'] = 52.604844798097;tCalculatedStrength['i']['m'] = 52.604844798097;tCalculatedStrength['i']['n'] = 35.260244055958;tCalculatedStrength['i']['p'] = 35.260244055958;tCalculatedStrength['i']['q'] = 49.257385438694;tCalculatedStrength['i']['r'] = 45.823199111111;tCalculatedStrength['i']['s'] = 47.417279124496;tCalculatedStrength['i']['t'] = 7.0786044250923;tCalculatedStrength['i']['v'] = 5.1062953213999;tCalculatedStrength['i']['w'] = 35.260244055958;tCalculatedStrength['i']['y'] = 52.604844798097;tCalculatedStrength['k']['a'] = 8.3750653242535;tCalculatedStrength['k']['c'] = 31.049563415669;tCalculatedStrength['k']['d'] = 23.272866587324;tCalculatedStrength['k']['e'] = 8.8277028056971;tCalculatedStrength['k']['f'] = 42.395009997506;tCalculatedStrength['k']['g'] = 12.539144167802;tCalculatedStrength['k']['h'] = 19.305871643064;tCalculatedStrength['k']['i'] = 23.272866587324;tCalculatedStrength['k']['k'] = 58.342741070348;tCalculatedStrength['k']['l'] = 12.539144167802;tCalculatedStrength['k']['m'] = 12.539144167802;tCalculatedStrength['k']['n'] = 42.395009997506;tCalculatedStrength['k']['p'] = 42.395009997506;tCalculatedStrength['k']['q'] = 36.137525701776;tCalculatedStrength['k']['r'] = 23.272866587324;tCalculatedStrength['k']['s'] = 13.488746233845;tCalculatedStrength['k']['t'] = 41.170876967289;tCalculatedStrength['k']['v'] = 44.521067319218;tCalculatedStrength['k']['w'] = 42.395009997506;tCalculatedStrength['k']['y'] = 12.539144167802;tCalculatedStrength['l']['a'] = 51.672531784327;tCalculatedStrength['l']['c'] = 29.856824872338;tCalculatedStrength['l']['d'] = 52.604844798097;tCalculatedStrength['l']['e'] = 41.139593752458;tCalculatedStrength['l']['f'] = 24.575175436732;tCalculatedStrength['l']['g'] = 39.476487407462;tCalculatedStrength['l']['h'] = 35.560533308816;tCalculatedStrength['l']['i'] = 52.604844798097;tCalculatedStrength['l']['k'] = 12.539144167802;tCalculatedStrength['l']['l'] = 39.476487407462;tCalculatedStrength['l']['m'] = 39.476487407462;tCalculatedStrength['l']['n'] = 24.575175436732;tCalculatedStrength['l']['p'] = 24.575175436732;tCalculatedStrength['l']['q'] = 36.966741409703;tCalculatedStrength['l']['r'] = 52.604844798097;tCalculatedStrength['l']['s'] = 45.284680600725;tCalculatedStrength['l']['t'] = -5.4066548050812;tCalculatedStrength['l']['v'] = 2.157180949214;tCalculatedStrength['l']['w'] = 24.575175436732;tCalculatedStrength['l']['y'] = 39.476487407462;tCalculatedStrength['m']['a'] = 51.672531784327;tCalculatedStrength['m']['c'] = 29.856824872338;tCalculatedStrength['m']['d'] = 52.604844798097;tCalculatedStrength['m']['e'] = 41.139593752458;tCalculatedStrength['m']['f'] = 24.575175436732;tCalculatedStrength['m']['g'] = 39.476487407462;tCalculatedStrength['m']['h'] = 35.560533308816;tCalculatedStrength['m']['i'] = 52.604844798097;tCalculatedStrength['m']['k'] = 12.539144167802;tCalculatedStrength['m']['l'] = 39.476487407462;tCalculatedStrength['m']['m'] = 39.476487407462;tCalculatedStrength['m']['n'] = 24.575175436732;tCalculatedStrength['m']['p'] = 24.575175436732;tCalculatedStrength['m']['q'] = 36.966741409703;tCalculatedStrength['m']['r'] = 52.604844798097;tCalculatedStrength['m']['s'] = 45.284680600725;tCalculatedStrength['m']['t'] = -5.4066548050812;tCalculatedStrength['m']['v'] = 2.157180949214;tCalculatedStrength['m']['w'] = 24.575175436732;tCalculatedStrength['m']['y'] = 39.476487407462;tCalculatedStrength['n']['a'] = 20.353692652058;tCalculatedStrength['n']['c'] = 43.066057732232;tCalculatedStrength['n']['d'] = 35.260244055958;tCalculatedStrength['n']['e'] = 20.844876012496;tCalculatedStrength['n']['f'] = 54.40946764336;tCalculatedStrength['n']['g'] = 24.575175436732;tCalculatedStrength['n']['h'] = 31.34416587945;tCalculatedStrength['n']['i'] = 35.260244055958;tCalculatedStrength['n']['k'] = 42.395009997506;tCalculatedStrength['n']['l'] = 24.575175436732;tCalculatedStrength['n']['m'] = 24.575175436732;tCalculatedStrength['n']['n'] = 54.40946764336;tCalculatedStrength['n']['p'] = 54.40946764336;tCalculatedStrength['n']['q'] = 48.154472611832;tCalculatedStrength['n']['r'] = 35.260244055958;tCalculatedStrength['n']['s'] = 25.50772981461;tCalculatedStrength['n']['t'] = 25.225861455393;tCalculatedStrength['n']['v'] = 28.561267086612;tCalculatedStrength['n']['w'] = 54.40946764336;tCalculatedStrength['n']['y'] = 24.575175436732;tCalculatedStrength['p']['a'] = 20.353692652058;tCalculatedStrength['p']['c'] = 43.066057732232;tCalculatedStrength['p']['d'] = 35.260244055958;tCalculatedStrength['p']['e'] = 20.844876012496;tCalculatedStrength['p']['f'] = 54.40946764336;tCalculatedStrength['p']['g'] = 24.575175436732;tCalculatedStrength['p']['h'] = 31.34416587945;tCalculatedStrength['p']['i'] = 35.260244055958;tCalculatedStrength['p']['k'] = 42.395009997506;tCalculatedStrength['p']['l'] = 24.575175436732;tCalculatedStrength['p']['m'] = 24.575175436732;tCalculatedStrength['p']['n'] = 54.40946764336;tCalculatedStrength['p']['p'] = 54.40946764336;tCalculatedStrength['p']['q'] = 48.154472611832;tCalculatedStrength['p']['r'] = 35.260244055958;tCalculatedStrength['p']['s'] = 25.50772981461;tCalculatedStrength['p']['t'] = 25.225861455393;tCalculatedStrength['p']['v'] = 28.561267086612;tCalculatedStrength['p']['w'] = 54.40946764336;tCalculatedStrength['p']['y'] = 24.575175436732;tCalculatedStrength['q']['a'] = 34.639588682129;tCalculatedStrength['q']['c'] = 53.951399737082;tCalculatedStrength['q']['d'] = 49.257385438694;tCalculatedStrength['q']['e'] = 33.858758035763;tCalculatedStrength['q']['f'] = 48.154472611832;tCalculatedStrength['q']['g'] = 36.966741409703;tCalculatedStrength['q']['h'] = 43.661053926385;tCalculatedStrength['q']['i'] = 49.257385438694;tCalculatedStrength['q']['k'] = 36.137525701776;tCalculatedStrength['q']['l'] = 36.966741409703;tCalculatedStrength['q']['m'] = 36.966741409703;tCalculatedStrength['q']['n'] = 48.154472611832;tCalculatedStrength['q']['p'] = 48.154472611832;tCalculatedStrength['q']['q'] = 61.175822427701;tCalculatedStrength['q']['r'] = 49.257385438694;tCalculatedStrength['q']['s'] = 38.461869497048;tCalculatedStrength['q']['t'] = 18.878763648421;tCalculatedStrength['q']['v'] = 22.702065063071;tCalculatedStrength['q']['w'] = 48.154472611832;tCalculatedStrength['q']['y'] = 36.966741409703;tCalculatedStrength['r']['a'] = 27.775347149814;tCalculatedStrength['r']['c'] = 41.855546099553;tCalculatedStrength['r']['d'] = 45.823199111111;tCalculatedStrength['r']['e'] = 42.104501069128;tCalculatedStrength['r']['f'] = 35.260244055958;tCalculatedStrength['r']['g'] = 52.604844798097;tCalculatedStrength['r']['h'] = 60.186240557383;tCalculatedStrength['r']['i'] = 45.823199111111;tCalculatedStrength['r']['k'] = 23.272866587324;tCalculatedStrength['r']['l'] = 52.604844798097;tCalculatedStrength['r']['m'] = 52.604844798097;tCalculatedStrength['r']['n'] = 35.260244055958;tCalculatedStrength['r']['p'] = 35.260244055958;tCalculatedStrength['r']['q'] = 49.257385438694;tCalculatedStrength['r']['r'] = 45.823199111111;tCalculatedStrength['r']['s'] = 47.417279124496;tCalculatedStrength['r']['t'] = 7.0786044250923;tCalculatedStrength['r']['v'] = 5.1062953213999;tCalculatedStrength['r']['w'] = 35.260244055958;tCalculatedStrength['r']['y'] = 52.604844798097;tCalculatedStrength['s']['a'] = 50.24328334011;tCalculatedStrength['s']['c'] = 31.24966683069;tCalculatedStrength['s']['d'] = 47.417279124496;tCalculatedStrength['s']['e'] = 48.421713960905;tCalculatedStrength['s']['f'] = 25.50772981461;tCalculatedStrength['s']['g'] = 45.284680600725;tCalculatedStrength['s']['h'] = 41.880157147049;tCalculatedStrength['s']['i'] = 47.417279124496;tCalculatedStrength['s']['k'] = 13.488746233845;tCalculatedStrength['s']['l'] = 45.284680600725;tCalculatedStrength['s']['m'] = 45.284680600725;tCalculatedStrength['s']['n'] = 25.50772981461;tCalculatedStrength['s']['p'] = 25.50772981461;tCalculatedStrength['s']['q'] = 38.461869497048;tCalculatedStrength['s']['r'] = 47.417279124496;tCalculatedStrength['s']['s'] = 52.975945325148;tCalculatedStrength['s']['t'] = -3.8433359650727;tCalculatedStrength['s']['v'] = 0.37915290874912;tCalculatedStrength['s']['w'] = 25.50772981461;tCalculatedStrength['s']['y'] = 45.284680600725;tCalculatedStrength['t']['a'] = -7.5041917681561;tCalculatedStrength['t']['c'] = 13.807094727994;tCalculatedStrength['t']['d'] = 7.0786044250923;tCalculatedStrength['t']['e'] = -8.4392059304994;tCalculatedStrength['t']['f'] = 25.225861455393;tCalculatedStrength['t']['g'] = -5.4066548050812;tCalculatedStrength['t']['h'] = 1.278605841779;tCalculatedStrength['t']['i'] = 7.0786044250923;tCalculatedStrength['t']['k'] = 41.170876967289;tCalculatedStrength['t']['l'] = -5.4066548050812;tCalculatedStrength['t']['m'] = -5.4066548050812;tCalculatedStrength['t']['n'] = 25.225861455393;tCalculatedStrength['t']['p'] = 25.225861455393;tCalculatedStrength['t']['q'] = 18.878763648421;tCalculatedStrength['t']['r'] = 7.0786044250923;tCalculatedStrength['t']['s'] = -3.8433359650727;tCalculatedStrength['t']['t'] = 39.674837575805;tCalculatedStrength['t']['v'] = 43.557277873297;tCalculatedStrength['t']['w'] = 25.225861455393;tCalculatedStrength['t']['y'] = -5.4066548050812;tCalculatedStrength['v']['a'] = -11.191528474216;tCalculatedStrength['v']['c'] = 17.541687818383;tCalculatedStrength['v']['d'] = 5.1062953213999;tCalculatedStrength['v']['e'] = -4.5715503537188;tCalculatedStrength['v']['f'] = 28.561267086612;tCalculatedStrength['v']['g'] = 2.157180949214;tCalculatedStrength['v']['h'] = 9.2859832173762;tCalculatedStrength['v']['i'] = 5.1062953213999;tCalculatedStrength['v']['k'] = 44.521067319218;tCalculatedStrength['v']['l'] = 2.157180949214;tCalculatedStrength['v']['m'] = 2.157180949214;tCalculatedStrength['v']['n'] = 28.561267086612;tCalculatedStrength['v']['p'] = 28.561267086612;tCalculatedStrength['v']['q'] = 22.702065063071;tCalculatedStrength['v']['r'] = 5.1062953213999;tCalculatedStrength['v']['s'] = 0.37915290874912;tCalculatedStrength['v']['t'] = 43.557277873297;tCalculatedStrength['v']['v'] = 48.126818571993;tCalculatedStrength['v']['w'] = 28.561267086612;tCalculatedStrength['v']['y'] = 2.157180949214;tCalculatedStrength['w']['a'] = 20.353692652058;tCalculatedStrength['w']['c'] = 43.066057732232;tCalculatedStrength['w']['d'] = 35.260244055958;tCalculatedStrength['w']['e'] = 20.844876012496;tCalculatedStrength['w']['f'] = 54.40946764336;tCalculatedStrength['w']['g'] = 24.575175436732;tCalculatedStrength['w']['h'] = 31.34416587945;tCalculatedStrength['w']['i'] = 35.260244055958;tCalculatedStrength['w']['k'] = 42.395009997506;tCalculatedStrength['w']['l'] = 24.575175436732;tCalculatedStrength['w']['m'] = 24.575175436732;tCalculatedStrength['w']['n'] = 54.40946764336;tCalculatedStrength['w']['p'] = 54.40946764336;tCalculatedStrength['w']['q'] = 48.154472611832;tCalculatedStrength['w']['r'] = 35.260244055958;tCalculatedStrength['w']['s'] = 25.50772981461;tCalculatedStrength['w']['t'] = 25.225861455393;tCalculatedStrength['w']['v'] = 28.561267086612;tCalculatedStrength['w']['w'] = 54.40946764336;tCalculatedStrength['w']['y'] = 24.575175436732;tCalculatedStrength['y']['a'] = 51.672531784327;tCalculatedStrength['y']['c'] = 29.856824872338;tCalculatedStrength['y']['d'] = 52.604844798097;tCalculatedStrength['y']['e'] = 41.139593752458;tCalculatedStrength['y']['f'] = 24.575175436732;tCalculatedStrength['y']['g'] = 39.476487407462;tCalculatedStrength['y']['h'] = 35.560533308816;tCalculatedStrength['y']['i'] = 52.604844798097;tCalculatedStrength['y']['k'] = 12.539144167802;tCalculatedStrength['y']['l'] = 39.476487407462;tCalculatedStrength['y']['m'] = 39.476487407462;tCalculatedStrength['y']['n'] = 24.575175436732;tCalculatedStrength['y']['p'] = 24.575175436732;tCalculatedStrength['y']['q'] = 36.966741409703;tCalculatedStrength['y']['r'] = 52.604844798097;tCalculatedStrength['y']['s'] = 45.284680600725;tCalculatedStrength['y']['t'] = -5.4066548050812;tCalculatedStrength['y']['v'] = 2.157180949214;tCalculatedStrength['y']['w'] = 24.575175436732;tCalculatedStrength['y']['y'] = 39.476487407462
--Precalculated Table#

--#Calculations
local function _calc()
    local i
    local ii
    tPredictedStrength = {}
    for i = 1, iSegmentCount do
        tPredictedStrength[i] = {}
        for ii = i + 2, iSegmentCount - 2 do
            tPredictedStrength[i][ii] = tCalculatedStrength[aa[i]][aa[ii]]
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

--#Saveslot manager -- Credits to Tlaloc
local function _release(slot)
    tSaveSlots[#tSaveSlots + 1] = slot
end

local function _request()
    local slot = tSaveSlots[#tSaveSlots]
    tSaveSlots[#tSaveSlots] = nil
    return slot
end

saveSlot =
{   release = _release,
    request = _request,
    save    = save.Quicksave,
    load    = save.Quickload
}
--Saveslot manager#
--External functions#

--#Internal functions
--#Getters
local function _distances()
    local i
    local j
    if bChanged then
        tDistances = {}
        for i = 1, iSegmentCount - 1 do
            tDistances[i] = {}
            for j = i + 1, iSegmentCount do
                tDistances[i][j] = get.distance(i, j)
            end -- for j
        end -- for i
        bChanged = false
    end -- if bChanged
end -- function

local function _sphere(segment, radius)
    local tSphere = {}
    check.distances()
    local i
    local temp
    local temp2
    for i = 1, iSegmentCount do
        if segment ~= i then
            temp2 = segment
            temp = i
            if temp > segment then
                temp, temp2 = segment, i
            end -- if temp
            if tDistances[temp][temp2] <= radius and not tSelectedSegments[i] then
                tSphere[#tSphere + 1] = i
            end -- if tDistances
        end -- if segment
    end -- for i
    return tSphere
end -- function

local function _center()
    local minDistance = 10000
    local distance
    local indexCenter
    check.distances()
    for i = 1, iSegmentCount do
        distance = 0
        for j = 1, iSegmentCount do
            if i ~= j then
                local x = i
                local y = j
                if x > y then
                    x, y = y, x
                end -- if x
                distance = distance + tDistances[x][y]
            end -- if i ~= j
        end -- for j
        if distance < minDistance then
            minDistance = distance
            indexCenter =  i
        end -- if distance
    end -- for i
    return indexCenter
end -- function

local function _increase(sectionEnd, slot, step)
    if step then
        if sectionEnd < step then
            saveSlot.load(slot)
            return
        end -- if sc2
    end -- if step
    if sectionEnd > 0 then
        if slot == saveSlotOverall then
            local currentScore = get.score()
            if currentScore > fMaxScore then
                saveSlot.save(slot)
                p("Gain: " .. sectionEnd)
                fMaxScore = currentScore
                p("==NEW=MAX=" .. fMaxScore .. "==")
            else -- if sc2
                saveSlot.load(slot)
            end -- if sc2
        else
            saveSlot.save(slot)
        end -- if slot
        return true
    else -- if sc2 >
        saveSlot.load(slot)
        return false
    end -- if sc2 >
end -- function

local function _mutable()
    mutable={}
    for i = 1, get.segcount() do
        if structure.IsMutable(i) then
            mutable[#mutable+1]=i
        end
    end
end

local function _score()
    local s = 0
    if not bExploringWork then
        s = score.current.rankedScore()
    else -- if
        s = score.current.energyScore()
    end -- if
    return s
end -- function

--#Hydrocheck
local function _hydro(s)
    if s then
        hydro[s] = get.hydro(s)
    else -- if
        hydro = {}
        for i = 1, iSegmentCount do
            hydro[i] = get.hydro(i)
        end -- for i
    end -- if
end -- function
--Hydrocheck#

--#Ligand Check
local function _ligand()
    if ss[iSegmentCount] == 'M' then
        iSegmentCount = iSegmentCount - 1
        if iEndSegment == iSegmentCount + 1 then
            iEndSegment = iSegmentCount
        end -- if iEndSegment
    end -- if get.ss
end -- function
--Ligand Check#

--#Structurecheck
local function _ss(s)
    if s then
        ss[s] = get.aa(s)
    else -- if
        ss = {}
        for i = 1, iSegmentCount do
            ss[i] = get.ss(i)
        end -- for i
    end -- if s
end -- function

local function _aa(s)
    if s then
        aa[s] = get.aa(s)
    else -- if
        aa = {}
        for i = 1, iSegmentCount do
            aa[i] = get.aa(i)
        end -- for i
    end -- if
end -- function

local function _struct()
    if bStructureChanged then
        check.ss()
        local helix
        local sheet
        local loop
        he = {}
        sh = {}
        lo = {}
        for i = 1, iSegmentCount do
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
    bStructureChanged = false
    end -- if bStructureChanged
end -- function

local function _same(a, b)
    check.struct()
    local bool
    local a_s
    local b_s
    if ss[a] == "H" and ss[b] == "H" then
        for i = 1, #he do
            for ii = he[i][1], he[i][#he[i]] do
                if a == ii then
                    a_s = i
                end -- if a
                if b == ii then
                    b_s = i
                end -- if b
                if a_s == b_s and a_s and b_s then
                    return false
                end -- if a_s
            end -- for ii
        end -- for i
    elseif ss[a] == "E" and ss[b] == "E" then
        for i = 1, #sh do
            for ii = sh[i][1], sh[i][#sh[i]] do
                if a == ii then
                    a_s = sh[i][1]
                end -- if a
                if b == ii then
                    b_s = sh[i][1]
                end -- if b
                if b_s == a_s and a_s and b_s then
                    return false
                end -- if b_s
            end -- for ii
        end -- for i
    else -- if / elseif
        return true
    end -- if ss[a]
end -- function

local function _checksame(a, b)
    if bCompressingConsiderStructure then
        return check.sameStruct(a, b)
    end
    return true
end
--Structurecheck#

local function _segscores()
    segs = {}
    local i
    for i = 1, iSegmentCount do
        segs[i] = score.current.segmentScore(i)
    end
end

local function _worst(len)
    local worst = 9999999
    local i
    local ii
    get.segscores()
    for ii = 1, iSegmentCount - len + 1 do
        for i = 1, len - 1 do
            segs[ii] = segs[ii] + segs[ii + i]
        end -- for i
    end -- for ii
    for i = 1, iSegmentCount - len + 1 do
        if segs[i] < worst then
            worstSegment = i
            worst = segs[i]
        end -- if s
    end -- for i
    set.segs(worstSegment, worstSegment + len - 1)
end

local function _formatTime(secs)
    local mins = 0
    local hours = 0
    while secs > 59 do
        mins = mins + 1
        secs = secs - 60
        if mins > 59 then
            hours = hours + 1
            mins = mins - 60
        end -- if secs
    end -- while secs
    if hours < 10 then
        hours = "0"..hours
    end -- if hours
    if mins < 10 then
        mins = "0"..mins
    end -- if mins
    if secs < 10 then
        secs = "0"..secs
    end -- if secs
    return (hours..":" .. mins .. ":" .. secs)
end -- function

local function _time()
    currentTime = os.time()
    if currentTime - timeStart > (60 + iTimeChecked*60) then
        iTimeChecked = iTimeChecked + 1
        local elapsedSecs = currentTime - timeStart
        estimatedTime = math.floor(elapsedSecs * fEstimatedTimeMod + 0.5)
        p("Time elapsed: " .. get.formattedTime(elapsedSecs) .. "; Recipe finished ".. fProgress .. "%")
        if estimatedTime ~= elapsedSecs then
            p("approx. time till that recipe is finished: " .. get.formattedTime(estimatedTime))
            p(os.date("Recipe will be approx. finished: %a, %c", estimatedTime + currentTime))
        else
            p("calculating approx. finish of this recipe")
        end
        p("==MAX SCORE=" .. fMaxScore .. "==")
    end
end

local function _progress(start1, end1, iter1, vari1, start2, end2, iter2, vari2)
    if start2 then
        if iter1 == -1 then
            local start = (vari2 +(start1 - vari1) *end2)
            local stop = (end2 - vari2 - 1+ (end2 - 1) * vari1)
            fEstimatedTimeMod = stop / start
            fProgress = round(start / (start1 * end2) * 100, 3)
        end -- if iter1
    else -- if start2
        if iter1 == 1 then
            fEstimatedTimeMod = (end1 - vari1) / vari1
            fProgress = round(vari1 / end1 * 100, 3)
        end -- if iter1
    end -- if start2
    check.time()
end -- function

local function _midTable(left, right)
    while right > left do
        right = right - 1
        left = left + 1
    end
    tWorkingMiddleSegs = {}
    if right == left then
        tWorkingMiddleSegs[1] = right 
    end
end

local function _rangeTable(left, right)
    local i
    tWorkingSegs = {}
    for i = left, right do
        tWorkingSegs[#tWorkingSegs+1] = i
    end
end

check =
{
    distances   = _distances,
    increase    = _increase,
    mutable     = _mutable,
    ss          = _ss,
    aa          = _aa,
    ligand      = _ligand,
    hydro       = _hydro,
    struct      = _struct,
    sameStruct  = _same,
    time        = _time,
    same        = _checksame
}

get =
{
    midTable        = _midTable,
    rangeTable      = _rangeTable,
    mid             = _mid,
    formattedTime   = _formatTime,
    sphere          = _sphere,
    center          = _center,
    segs            = _segs,
    score           = _score,
    segscores       = _segscores,
    worst           = _worst,
    progress        = _progress,
    distance        = structure.GetDistance,
    ss              = structure.GetSecondaryStructure,
    aa              = structure.GetAminoAcid,
    segcount        = structure.GetCount,
    bandcount       = band.GetCount,
    hydro           = structure.IsHydrophobic,
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

do_ =
{   freeze      = _freeze,
    rebuild     = structure.RebuildSelected,
    snap        = rotamer.SetRotamer,
    unfreeze    = freeze.UnfreezeAll
}
--Doers#

--#Fuzing
local function _loss(option, cl1, cl2)
    if option == 1 then
        if not bTweaking then work.step("s", 1, cl1, bSpheredFuzing) end
        work.step("wa", 2, cl2, bSpheredFuzing)
        work.step("wa", 1, 1, bSpheredFuzing)
        work.step("s", 1, 1, bSpheredFuzing)
        work.step("wa", 1, cl2, bSpheredFuzing)
        work.step("wa", 2, 1, bSpheredFuzing)
    elseif option == 2 then
        work.step("s", 1, 1, bSpheredFuzing)
        work.step("wa", 2, 1, bSpheredFuzing)
    else
        if bTweaking then work.step("wa", 2, 1, bSpheredFuzing) end
        if work.step("s", 1, cl1, bSpheredFuzing) then work.step("wa", 2, 1, bSpheredFuzing) end
        if work.step("s", 1, cl2, bSpheredFuzing) then work.step("wa", 2, 1, bSpheredFuzing) end
        if work.step("s", 1, cl1 - 0.02, bSpheredFuzing) then work.step("wa", 2, 1, bSpheredFuzing) end
        if work.step("s", 1, 1, bSpheredFuzing) then work.step("wa", 2, 1, bSpheredFuzing) end
    end
end

local function _part(option, cl1, cl2)
    report.start("Fuzing Part") 
    fuze.loss(option, cl1, cl2)
    check.increase(report.stop(), sl_f)
end

local function _start(slot)
    sl_f = saveSlot.request()
    report.start("Fuzing Complete")
    saveSlot.save(sl_f)
    if bFuzingPinkFuze or bTweaking then
        fuze.part(1, 0.1, 0.6)
    elseif bFuzingBlueFuze then
        fuze.part(3, 0.05, 0.07)
    else
        fuze.part(2)
    end
    saveSlot.load(sl_f)
    saveSlot.release(sl_f)
    check.increase(report.stop(), slot)
end

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
        if sphered then
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
            select.index(start)
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

local function _list(_list, sphered)
    local i
    local list1
    if _list then
        for i = 1, #_list do
            if sphered then
                list1 = get.sphere(_list[i], 10)
                select.list(list1)
            end -- for i
            select.index(_list[i])
        end -- for
    end -- if _list
end -- function

local function _range(a, b)
    local i
    local bool
    for i = a, b do
        if not tSelectedSegments[i] then
            bool = true
        end
    end
    if bool then
        selection.SelectRange(a, b)
        for i = a, b do
            tSelectedSegments[i] = true
        end
    end
end

local function _index(a)
    if not tSelectedSegments[a] then
        selection.Select(a)
        tSelectedSegments[a] = true
    end
end

local function _all()
    for i = 1, iSegmentCount do
        tSelectedSegments[i] = true
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

local function _deindex(segment)
    if tSelectedSegments[segment] then
        selection.Deselect(segment)
        tSelectedSegments[segment] = false
    end
end

local function _deall()
    selection.DeselectAll()
    tSelectedSegments = {}
end

local function _delist(list)
    local i
    for i = 1, #list do
        tSelectedSegments[list[i]] = false
        selection.Deselect(list[i])
    end
end

deselect =
{
    index   = _deindex,
    all     = _deall,
    list    = _delist
}
--Universal select#

--#working
local function _step(a, iter, cl, sphered)
    local s1
    local s2
    if (cl == true or cl == false) and sphered == nil then
        sphered = cl
        cl = nil
    end
    if sphered == nil then
        select.segs()
    elseif sphered ~= 0 then
        if sphered then
            select.segs(true, workingSegmentLeft, workingSegmentRight)
        else -- if sphered
            select.segs(workingSegmentLeft, workingSegmentRight)
        end -- if sphered
    end -- if
    if a ~= "s" then
        bChanged = true
    end
    if cl then
        set.clashImportance(cl)
    end
    local _s1 = get.score()
    if a == "wa" then
        wiggle.selected(iter)
    elseif a == "s" then
        wiggle.shakeSelected(2)
    elseif a == "wb" then
        wiggle.selectedBackbone(iter)
    elseif a == "ws" then
        wiggle.selectedSidechains(iter)
    elseif a == "wl" then
        select.segs(workingSegmentLeft, workingSegmentRight)
        score.recent.save()
        s1 = get.score()
        wiggle.localSelected(iter)
        s2 = get.score()
        if s2 < s1 then
            score.recent.restore()
        end
    end -- if a
    local _s2 = get.score()
    if math.abs(_s2 - _s1) > 0.05 then
        return true
    else
        return false
    end
end -- function

local function _flow(a, more)
    report.start("WorkFlow")
    local iter = 0
    slot = saveSlotOverall
    work_sl = saveSlot.request()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            saveSlot.save(work_sl)
        end -- if iter
        s1 = get.score()
        work.step(a, iter)
        s2 = get.score()
        if iter > 1 and s2 - s1 < (0.01 * iter) then
            iter = iter - 1
            s1 = get.score()
        end
    until s2 - s1 < (0.01 * iter)
    if s2 < s1 then
        saveSlot.load(work_sl)
    else -- if <
        s1 = s2
    end -- if <
    saveSlot.release(work_sl)
    if not more then
        check.increase(report.stop(), slot, fScoreMustChange)
    end -- if not more
end -- function

function _quake(ii)
    if get.score() < 0 then
        bands.disable()
        fuze.start(saveSlotOverall)
        bands.enable()
    end -- if s3 < 0
    local s3 = round(get.score() / 50 * fCompressingLoss, 4)
    local tPredictedStrength = 0.1 + 0.1 * fCompressingLoss
    local cbands = get.bandcount()
    local quake = saveSlot.request()
    if workingSegmentLeft or workingSegmentRight then
        select.segs(workingSegmentLeft, workingSegmentRight)
    else -- if workingSegmentLeft
        select.segs()
    end -- if workingSegmentLeft
    if isCompressingEnabled then
        if bCompressingPredictedLocalBonding then
            s3 = round(s3 * 4 / cbands, 4)
            tPredictedStrength = round(tPredictedStrength * 4 / cbands, 4)
        end -- if
        if bCompressingSoloBonding then
            bands.disable()
            bands.enable(ii)
            s3 = round(s3 * 2, 4)
            tPredictedStrength = round(tPredictedStrength * 2, 4)
        end -- if bCompressingSoloBonding
    end -- if isCompressingEnabled
    if isCurlingEnabled then
        s3 = round(s3 / 10, 4)
    end -- if isCurlingEnabled
    if s3 > 200 * fCompressingLoss then
        s3 = 200 * fCompressingLoss
    end -- if s3
    if tPredictedStrength > 0.2 * fCompressingLoss then
        tPredictedStrength = 0.2 * fCompressingLoss
    end -- if tPredictedStrength
    p("Pulling until a loss of more than " .. s3 .. " points")
    local s1 = get.score()
    repeat
        p("Band strength: " .. tPredictedStrength)
        if bCompressingSoloBonding then
            bands.strength(ii, tPredictedStrength)
        else -- if b_solo
            for i = 1, cbands do
                if bands.info[i][bands.part.enabled] then
                    bands.strength(i, tPredictedStrength)
                end
            end -- for
        end -- if b_solo
        score.recent.save()
        set.clashImportance(1)
        wiggle.selectedBackbone(1)
        saveSlot.save(quake)
        score.recent.restore()
        local s2 = get.score()
        if s2 > s1 then
            score.recent.restore()
            saveSlot.save(saveSlotOverall)
        end -- if >
        saveSlot.load(quake)
        local s2 = get.score()
        tPredictedStrength = round(tPredictedStrength * 2 - tPredictedStrength * 10 / 11, 4)
        if bCompressingPredictedLocalBonding or isCurlingEnabled or bCompressingSoloBonding then
            tPredictedStrength = round(tPredictedStrength * 2 - tPredictedStrength * 6 / 7, 4)
        end -- if b_solo
        if tPredictedStrength > 10 then
            break
        end -- if tPredictedStrength
    until s1 - s2 > s3
    saveSlot.release(quake)
end -- function

local function _dist()
    select.segs()
    saveSlot.save(saveSlotOverall)
    dist = saveSlot.request()
    local bandcount = get.bandcount()
    if bCompressingSoloBonding then
        p("Solo quaking enabled")
        bSpheredFuzing = true
        for ii = 1, bandcount do
            report.start("Solo Work")
            saveSlot.save(dist)
            work.quake(ii)
            if bMutateAfterCompressing then
                select.all()
                structure.MutateSidechainsSelected(1)
            end -- if bMutateAfterCompressing
            bands.delete(ii)
            if bCompressingFuze then
                fuze.start(dist)
            else
                work.step("wa", 3)
            end
            check.increase(report.stop(), saveSlotOverall)
        end -- for ii
        bSpheredFuzing = false
    else -- if bCompressingSoloBonding
        report.start("Compressing Work")
        saveSlot.save(dist)
        work.quake()
        bands.disable()
        if bCompressingFuze then
            fuze.start(dist)
        else
            work.step("wa", 3)
        end
        if bCompressingEvolutionOnlyBetter then
            check.increase(report.stop(), saveSlotOverall)
        end
    end -- if bCompressingSoloBonding
    saveSlot.release(dist)
end -- function

local function _rebuild(trys, str)
    local iter = 1
    for i = 1, trys do
        local re1 = get.score()
        local re2 = re1
        while math.abs(re2 - re1) < 1 do
            do_.rebuild(iter * str)
            re2 = get.score()
            work.step("s", 1, 1, 0)
            set.clashImportance(0)
            iter = iter + 1
            if iter > 10 then
            p("Rebuilding aborted! Backbone unrebuildable")
            return false
            end
        end -- while
        iter = 1
    end -- for i
    bChanged = true
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
    for i = 1, iSegmentCount do
        if i ~= indexCenter then
            local x = i
            local y = indexCenter
            if x > y then
                x, y = y, x
            end -- if x
            if hydro[i] then
                if check.same(x, y) then
                    bands.addToSegs(x, y)
                    if bCompressingSoftBonding then
                        local cband = get.bandcount()
                        bands.length(cband, tDistances[x][y] - iCompressingBondingLength)
                    end -- if bCompressingSoftBonding
                end -- if checksame
            end -- if hydro
        end -- if ~=
    end -- for
end -- function

local function _cps(_local)
    local indexCenter = get.center()
    check.distances()
    for i = 1, iSegmentCount do
        if i ~= indexCenter then
            local x = i
            local y = indexCenter
            if x > y then
                x, y = y, x
            end -- if x
            if not hydro[i] then
                if tDistances[x][y] <= (20 - iCompressingBondingLength) then
                    if check.same(x, y) then
                        bands.addToSegs(x, y)
                        local cband = get.bandcount()
                        bands.length(cband, tDistances[x][y] + iCompressingBondingLength)
                    end -- if checksame
                end -- if tDistances
            end -- if hydro
        end -- if ~=
    end -- for
end -- function
--Center#

local function _ps(_local, bandsp)
    local c_temp
    check.distances()
    for x = 1, iSegmentCount - 2 do
        if not hydro[x] then
            for y = x + 2, iSegmentCount do
                if not hydro[y] then
                    if math.random() <= bandsp then
                        if tDistances[x][y] <= (20 - iCompressingBondingLength) then
                            if check.same(x, y) then
                                bands.addToSegs(x, y)
                                local cband = get.bandcount()
                                bands.length(cband, tDistances[x][y] + iCompressingBondingLength)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function _pl(_local, bandsp)
    check.distances()
    if bCompressingFixxedBonding then
        for x = 1, iSegmentCount do
            if hydro[x] then
                for y = iCompressingFixxedStartSegment, iCompressingFixxedEndSegment do
                    if hydro[y] then
                        if math.random() < bandsp then
                            if check.same(x, y) then
                                bands.addToSegs(x, y)
                                if bCompressingSoftBonding then
                                    local cband = get.bandcount()
                                    bands.length(cband, tDistances[x][y] - iCompressingBondingLength)
                                end -- bCompressingSoftBonding
                            end -- if checksame
                        end -- if random
                    end -- if hydro[y]
                end -- for y
            end -- if hydro[x]
        end -- for x
    end -- if bCompressingFixxedBonding
    for x = 1, iSegmentCount - 2 do
        if hydro[x] then
            for y = x + 2, iSegmentCount do
                if hydro[y] then
                    if math.random() < bandsp then
                        if check.same(x, y) then
                            bands.addToSegs(x, y)
                            if bCompressingSoftBonding then
                                local cband = get.bandcount()
                                bands.length(cband, tDistances[x][y] - iCompressingBondingLength)
                            end -- if bCompressingSoftBonding
                        end -- if checksame
                    end -- if random
                end -- hydro y
            end -- for y
        end -- if hydro x
    end -- for x
end -- function

local function _strong(_local)
    check.distances()
    for i = 1, iSegmentCount do
        local max_str = 0
        local min_dist = 999
        for ii = i + 2, iSegmentCount - 2 do
            if max_str <= tPredictedStrength[i][ii] then
                if max_str ~= tPredictedStrength[i][ii] then
                    min_dist = 999
                end -- if max_str ~=
                max_str = tPredictedStrength[i][ii]
                if min_dist > tDistances[i][ii] then
                    min_dist = tDistances[i][ii]
                end -- if min_dist
            end -- if max_str <=
        end -- for ii
        for ii = i + 2, iSegmentCount - 2 do
            if tPredictedStrength[i][ii] == max_str and min_dist == tDistances[i][ii] then
                if check.same(i, ii) then
                    bands.addToSegs(i , ii)
                    if bCompressingSoftBonding then
                        local cband = get.bandcount()
                        bands.length(cband, tDistances[i][ii] - iCompressingBondingLength)
                    end -- if pp_soft
                end -- if check.same
            end -- if tPredictedStrength
        end -- for ii
    end -- for i
end -- function

local function _one(_seg)
    check.distances()
    local max_str = 0
    for ii = _seg + 2, iSegmentCount - 2 do
        if max_str <= tPredictedStrength[_seg][ii] then
            max_str = tPredictedStrength[_seg][ii]
        end -- if max_str <=
    end -- for ii
    for ii = _seg + 2, iSegmentCount - 2 do
        if tPredictedStrength[_seg][ii] == max_str then
            if check.same(_seg, ii) then
                bands.addToSegs(_seg , ii)
                if bCompressingSoftBonding then
                    local cband = get.bandcount()
                    bands.length(cband, tDistances[_seg][ii] - iCompressingBondingLength)
                end
            end
        end -- if tPredictedStrength
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
            if ii - 1 < 1 then
                ii = 2
            elseif ii > iSegmentCount then
                ii = iSegmentCount - 2
            end
            bands.addToSegs(ii - 1, ii + 2)
            local cbands = get.bandcount()
            bands.strength(cbands, 10)
            bands.length(cbands, 100)
        end -- for ii
    else
        for i = 1, #sh do
            for ii = 1, #sh[i] - 1 do
                if ii - 1 < 1 then
                    ii = 2
                elseif ii + 2 > iSegmentCount then
                    ii = iSegmentCount - 2
                end
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
    check.distances()
    local start  = round(math.random() * (iSegmentCount - 1)) + 1
    local finish = round(math.random() * (iSegmentCount - 1)) + 1
    if start > finish then
        start, finish = finish, start
    end
    if start ~= finish and math.abs(start - finish) >= 5 then
        bands.addToSegs(start, finish)
        local n = get.bandcount()
        local length = 3 + (math.random() * (tDistances[start][finish] + 2))
        if hydro[start] and hydro[finish] then
            length = 2 + (math.random() * (get.distance(start, finish) / 2))
        end
        if length < 0 then length = 0 end
        if n > 0 then bands.length(n, length) end
    else
        bonding.rnd()
    end
end

local function _vib()
    check.distances()
    local i
    local _i
    local ii
    local iii
    local list
    local bandcount
    for i = 1, iSegmentCount do
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
                bands.length(bandcount, tDistances[_i][list[ii]] + math.random(-0.1, 0.1))
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
    check.distances()
    for i = 1, iSegmentCount do
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
    check.distances()
    local t = {}
    for b = 1, iSegmentCount do
        if a > b then
           a, b = b, a
        end -- if x
        local ab = tDistances[a][b]
        if ab > 3 then
            local void = true
            for c = 1, iSegmentCount do
            if a > c then
           a, c = c, a
        end -- if x
        if b > c then
           b, c = c, b
        end -- if x
                local ac = tDistances[a][c]
                local bc = tDistances[b][c]
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
    bTweaking = true
    bSpheredFuzing = true
    sl_snaps = saveSlot.request()
    cs = get.score()
    c_snap = cs
    local s_1
    local s_2
    local c_s
    local c_s2
    saveSlot.save(sl_snaps)
    sidechain_tweak(workingSegmentLeft)
    check.increase(cs, get.score(), sl_snaps)
    --[[iii = get.snapcount(workingSegmentLeft)
    p("Snapcount: " .. iii .. " - segment " .. workingSegmentLeft)
    if iii > 1 then
        snapwork = saveSlot.request()
        ii = 1
        while ii <= iii do
            saveSlot.load(sl_snaps)
            c_s = get.score()
            c_s2 = c_s
            do_.snap(workingSegmentLeft, ii)
            c_s2 = get.score()
            saveSlot.save(snapwork)
            select.segs(true, workingSegmentLeft)
            fuze.start(snapwork)
            if c_snap < get.score() then
                c_snap = get.score()
                saveSlot.save(sl_snaps)
            end
            ii = ii + 1
        end
        saveSlot.load(snapwork)
        saveSlot.release(snapwork)
        if cs < c_snap then
            saveSlot.save(sl_snaps)
            c_snap = get.score()
        else
            saveSlot.load(sl_snaps)
        end
    else
        p("Skipping...")
    end
    if cs < get.score() then
    saveSlot.load(sl_snaps)
    else
    saveSlot.save(sl_snaps)
    cs = get.score()
    end]]
    bSpheredFuzing = false
    bTweaking = false
    saveSlot.release(sl_snaps)
    --[[if mutated then
        s_snap = get.score()
        if s_mut < s_snap then
            saveSlot.save(saveSlotOverall)
        else
            saveSlot.load(sl_mut)
        end
    else
        saveSlot.save(saveSlotOverall)
    end]]--
end
--Snapping#

--#Rebuilding
function rebuild(tweaking_seg)
    bSpheredFuzing = true
    sl_re = saveSlot.request()
    saveSlot.save(sl_re)
    select.segs(workingSegmentLeft, workingSegmentRight)
    if workingSegmentRight == workingSegmentLeft then
        p("Rebuilding Segment " .. workingSegmentLeft)
    else -- if workingSegmentRight
        p("Rebuilding Segment " .. workingSegmentLeft .. "-" .. workingSegmentRight)
    end -- if workingSegmentRight
    report.start("Rebuilding")
    rs_0 = get.score()
    local sl_r = {}
    local i
    local ii
    for ii = 1, iRebuildTrys do
        if not work.rebuild(iRebuildsTillSave, iRebuildStrength) then
            saveSlot.load(sl_re)
            saveSlot.release(sl_re)
            bSpheredFuzing = false
            sl_r = nil
            if math.abs(workingSegmentLeft - workingSegmentRight) == 2 then
                p("Detected rebuild length of 3; splitting to 2x2")
                set.segs(workingSegmentLeft + 1, workingSegmentRight)
                rebuild(tweaking_seg)
                set.segs(workingSegmentLeft - 1, workingSegmentRight - 1)
                rebuild(tweaking_seg)
            end
            return
        end
        sl_r[ii] = saveSlot.request()
        saveSlot.save(sl_r[ii])
    end
    set.clashImportance(1)
    local slot
    if bMutating then
        slot = sl_mut
    else
        slot = saveSlotOverall
    end
    for ii = 1, #sl_r do
        saveSlot.load(sl_r[ii])
        saveSlot.release(sl_r[ii])
        sl_r[ii] = nil
        saveSlot.save(sl_re)
        if rs_1 ~= get.score() then
            rs_1 = get.score()
            if rs_1 ~= rs_0 then
                p("Stabilize try "..ii)
                fuze.start(sl_re)
                rs_2 = get.score()
                if (fMaxScore - rs_2 ) < 30 then
                    if bRebuildTweakWholeRebuild or bRebuildWorst or bRebuildLoops or bRebuildWalking then
                        for i = workingSegmentLeft, workingSegmentRight do
                            sidechain_tweak(i)
                        end
                    else
                        sidechain_tweak(tweaking_seg)
                    end
                end
                if check.increase(report.stop(), slot) then
                    rs_0 = get.score()
                end
            end
        end
    end
    saveSlot.load(slot)
    sl_r = nil
    saveSlot.release(sl_re)
    bSpheredFuzing = false
end -- function
--Rebuilding#

function evolution()
    local i
    for i = 1, 5*iCompressingEvolutionRounds do
        bonding.rnd()
    end
    bands.disable()
    for i = 1, iCompressingEvolutionRounds do
        local bandcount = get.bandcount()
        local rnd = round(math.random() * 5) + 2
        for ii = 1, rnd do
            local cband = round(math.random() * (bandcount - 1)) + 1
            if bands.info[cband][bands.part.enabled] == true then
                ii = ii - 1
            end
            bands.enable(cband)
        end
        work.dist()
    end
end

--#Pull
function compress()
    saveSlot.save(saveSlotOverall)
    dist_score = get.score()
    bands.delete()
    if bCompressingVibrator then
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
    if bCompressingPredictedBonding then
        bonding.matrix.strong()
        work.dist()
        bands.delete()
    end -- if isCompressingEnabled_predicted
    if bCompressingPredictedLocalBonding then
        for i = iStartSegment, iEndSegment do
            bonding.matrix.one(i)
            work.dist()
            bands.delete()
        end
    end -- if isCompressingEnabled_predicted
    if bCompressingPushPull then
        bonding.pull(bCompressingLocalBonding, fCompressingBondingPercentage / 2)
        p(fCompressingBondingPercentage)
        bonding.push(bCompressingLocalBonding, fCompressingBondingPercentage)
        work.dist()
        bands.delete()
    end -- if isCompressingEnabled_combined
    if bCompressingEvolutionBonding then
        evolution()
    end -- if isCompressingEnabled_rnd
    if bCompressingPull then
        bonding.pull(bCompressingLocalBonding, fCompressingBondingPercentage)
        work.dist()
        bands.delete()
    end -- if bCompressingPull
    if bCompressingCenterPull then
        bonding.centerpull(bCompressingLocalBonding)
        work.dist()
        bands.delete()
    end -- if bCompressingCenterPull
    if isCompressingEnabled_c_push_pull then
        bonding.centerpush(bCompressingLocalBonding)
        bonding.centerpull(bCompressingLocalBonding)
        work.dist()
        bands.delete()
    end -- if bCompressingCenterPull
    --[[if bCompressingVibrator then
        bonding.vib()
        work.dist()
        bands.delete()
    end]]--
    if bCompressingRefineBonds then
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
    while i < iSegmentCount do
        ui = i
        loop = false
        if bPredictingOtherMethod then
            if hydro[i] then
                if hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] and not hydro[i + 4] or hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] and not hydro[i + 4] or not hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] and hydro[i + 4] then
                    if aa[i] ~= "p" then
                        if not helix then
                            helix = true
                            p_he[#p_he + 1] = {}
                        end -- if not helix
                    else -- if aa[i]
                        loop = true
                        helix = false
                    end -- if helix
                elseif not hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] or hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] then
                    if not sheet then
                        sheet = true
                        p_sh[#p_sh + 1] = {}
                    end -- if sheet
                else -- hydro i +
                    loop = true
                end -- hydro i +
            elseif not hydro[i] then
                if not hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] and hydro[i + 4] or not hydro[i + 1] and hydro[i + 2] and hydro[i + 3] and hydro[i + 4] or hydro[i + 1] and hydro[i + 2] and hydro[i + 3] and not hydro[i + 4] then
                    if aa[i] ~= "p" then
                        if not helix then
                            helix = true
                            p_he[#p_he + 1] = {}
                        end -- if not helix
                    else -- if aa[i]
                        loop = true
                        helix = false
                    end -- if helix
                elseif hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and hydro[i + 2] and hydro[i + 3] then
                    if not sheet then
                        sheet = true
                        p_sh[#p_sh + 1] = {}
                    end -- if sheet
                else -- if hydro +
                    loop = true
                end -- if hydro +
            end -- hydro[i]
        else -- if bPredictingOtherMethod
            if hydro[i] then
                if hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                    if aa[i] ~= "p" then
                        if not helix then
                            helix = true
                            p_he[#p_he + 1] = {}
                        end -- if not helix
                    else -- if aa[i]
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
                        end -- if not helix
                    else -- if aa[i]
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
        end -- if bPredictingOtherMethod
        if helix then
            p_he[#p_he][#p_he[#p_he] + 1] = i
            if loop or sheet then
                helix = false
                if i + 1 < iSegmentCount then
                    if aa[i + 1] ~= "p" then
                        p_he[#p_he][#p_he[#p_he] + 1] = i + 1
                        if i + 2 < iSegmentCount then
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
                if i + 1 < iSegmentCount then
                    p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 1
                end -- if i + 1
                if i + 2 < iSegmentCount then
                    p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 2
                end -- if i + 2
                ui = i + 2
                i = i + 4
            end -- if loop
        end -- if sheet
        if bPredictingFull then
            i = ui + 1
        else -- if bPredictingFull
            i = i + 1
        end -- if bPredictingFull
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
    bStructureChanged = true
    saveSlot.save(saveSlotOverall)
end

local function _combine()
    for i = 1, iSegmentCount - 1 do
        check.struct()
        deselect.all()
        if ss[i] == "L" then
            if aa[i] ~= "p" then
                for ii = 1, #he - 1 do
                    if bPredictingCombine then
                        for iii = he[ii][1], he[ii][#he[ii]] do
                            if iii + 1 == i and he[ii + 1][1] == i + 1 then
                                select.segs(i)
                            end -- if iii
                        end -- for iii
                    end -- if b_pre
                end
                for ii = 1, #he do
                    if bPredictingAddPrefferedSegments then
                        for iii = he[ii][1] - 1, he[ii][#he[ii]] + 1, he[ii][#he[ii]] - he[ii][1] + 1 do
                            if iii > 0 and iii <= iSegmentCount then
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
            if bPredictingCombine then
                for ii = 1, #sh - 1 do
                    for iii = sh[ii][1], sh[ii][#sh[ii]] do
                        if iii + 1 == i and sh[ii + 1][1] == i + 1 then
                            select.segs(i)
                        end -- if iii
                    end -- for iii
                end -- for ii
            end -- if b_pre
            if bPredictingAddPrefferedSegments then
                for ii = 1, #sh do
                    for iii = sh[ii][1] - 1, sh[ii][#sh[ii]] + 1, sh[ii][#sh[ii]] - sh[ii][1] + 1 do
                        if iii > 0 and iii <= iSegmentCount then
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
    str_re_best = saveSlot.request()
    check.struct()
    p("Found " .. #he .. " Helixes " .. #sh .. " Sheets and " .. #lo .. " Loops")
    if bCurlingHelix then
        for i = 1, #he do
            if #he[i] > 3 then
                p("Working on Helix " .. i)
                local left = he[i][1] - 2
                local right = he[i][#he[i]] + 2
                if left < 1 then
                    left = 1
                end -- if left
                if right > iSegmentCount then
                    right = iSegmentCount
                end -- if right
                set.segs(left, right)
                select.segs(workingSegmentLeft, workingSegmentRight)
                bonding.helix(i)
                bSpheredFuzing = true
                work.dist()
                bands.delete()
                bSpheredFuzing = false
            end
        end -- for i
    end -- if bCurlingHelix
    if bCurlingSheet then
        for i = 1, #sh do
            if #sh[i] > 2 then
                p("Working on Sheet " .. i)
                local left = sh[i][1] - 2
                local right = sh[i][#sh[i]] + 2
                if left < 1 then
                    left = 1
                end -- if left
                if right > iSegmentCount then
                    right = iSegmentCount
                end -- if right
                set.segs(left, right)
                bonding.sheet(i)
                select.segs(workingSegmentLeft, workingSegmentRight)
                bSpheredFuzing = true
                work.dist()
                bands.delete()
                bSpheredFuzing = false
            end
        end -- for i
    end -- if bCurlingSheet
    saveSlot.release(str_re_best)
    saveSlot.save(saveSlotOverall)
end

function struct_rebuild()
    local str_rs
    local str_rs2
    str_re_best = saveSlot.request()
    check.struct()
    p("Found " .. #he .. " Helixes " .. #sh .. " Sheets and " .. #lo .. " Loops")
    if bStructuredRebuildHelix then
        deselect.all()
        for i = 1, #sh do
            select.list(sh[i])
        end -- for i
        set.ss("L")
        for i = 1, #he do
            p("Working on Helix " .. i)
            local left = he[i][1] - 2
            local right = he[i][#he[i]] + 2
            if left < 1 then
                left = 1
            end -- if left
            if right > iSegmentCount then
                right = iSegmentCount
            end -- if right
            set.segs(left, right)
            bonding.helix(i)
            deselect.all()
            select.range(workingSegmentLeft, workingSegmentRight)
            set.clashImportance(0.4)
            wiggle.selectedBackbone(1)
            set.clashImportance(0)
            work.rebuild(iStructuredRebuildTillSave, iStructuredRebuildStrength)
            set.clashImportance(0.4)
            wiggle.selectedBackbone(1)
            set.clashImportance(1)
            work.rebuild(iStructuredRebuildTillSave, iStructuredRebuildStrength)
            set.clashImportance(0.4)
            wiggle.selectedBackbone(1)
            bands.delete()
            if bStructuredRebuildFuze then
                bSpheredFuzing = true
                fuze.start(str_re_best)
                saveSlot.load(str_re_best)
                bSpheredFuzing = false
            end -- if bStructuredRebuildFuze
            str_sc = nil
            str_rs = nil
        end -- for i
        deselect.all()
        for i = 1, #sh do
            select.list(sh[i])
        end -- for i
        set.ss("E")
    end -- if bStructuredRebuildHelix
    if bStructuredRebuildSheet then
        deselect.all()
        for i = 1, #he do
            select.list(he[i])
        end -- for i
        set.ss("L")
        for i = 1, #sh do
            p("Working on Sheet " .. i)
            local left = sh[i][1] - 2
            local right = sh[i][#sh[i]] + 2
            if left < 1 then
                left = 1
            end -- if left
            if right > iSegmentCount then
                right = iSegmentCount
            end -- if right
            set.segs(left, right)
            bonding.sheet(i)
            deselect.all()
            select.range(workingSegmentLeft, workingSegmentRight)
            set.clashImportance(0.1)
            wiggle.selectedBackbone(1)
            set.clashImportance(0.4)
            wiggle.selectedBackbone(1)
            bands.delete()
            if bStructuredRebuildFuze then
                bSpheredFuzing = true
                fuze.start(str_re_best)
                saveSlot.load(str_re_best)
                bSpheredFuzing = false
            end -- if bStructuredRebuildFuze
        end -- for i
        deselect.all()
        for i = 1, #he do
            select.list(he[i])
        end -- for i
        set.ss("H")
        bonding.comp_sheet()
    end -- if bStructuredRebuildSheet
    saveSlot.save(saveSlotOverall)
    saveSlot.release(str_re_best)
end

--#Mutate function
function mutate()
    sl_mut = saveSlot.request()
    bMutating = true
    local i
    local ii
    check.distances()
    local i_will_be = #mutable - 3
    for i = i_will_be, 1, -1 do
        p("Mutating segment " .. mutable[i])
        saveSlot.save(saveSlotOverall)
        sc_mut = get.score()
        local ii
        for ii = 1, #amino.segs do
            mutate2(i, ii)
            get.progress(i_will_be, 1, -1, i, 1, #amino.segs, 1, ii)
        end
        saveSlot.load(saveSlotOverall)
    end
    bMutating = false
    saveSlot.release(sl_mut)
end

function mutate2(mut, aa, more)
    report.start("Mutating Work")
    local i
    select.segs(mutable[mut])
    set.aa(amino.segs[aa])
    saveSlot.save(sl_mut)
    check.aa()
    p(#amino.segs - aa .. " Mutations left")
    p("Mutating segment " .. mutable[mut] .. " to " .. amino.long(mutable[mut]))
    if bMutateSurroundingAfter then
        select.list(mutable)
        deselect.index(mutable[mut])
        for i = 1, #mutable do
            local temp = false
            if i ~= mut then
                if tDistances[mutable[i]][mutable[mut]] then
                    if tDistances[mutable[i]][mutable[mut]] > 10 then
                        temp = true
                    end
                elseif tDistances[mutable[mut]][mutable[i]] > 10 then
                    temp = true
                end
                if temp then
                    deselect.index(mutable[i])
                end
            end
        end
        set.clashImportance(fClashingForMutating)
        structure.MutateSidechainsSelected(1)
    end
    if bRebuildAfterMutating then
        if bRebuildInMutatingDeepRebuild then
            set.segs(mutable[mut] - 2, mutable[mut] + 2)
            tWorkingMiddleSegs[1] = mutable[mut]
            if not bRebuildInMutatingIgnoreStructures then
                if ss[mutable[mut]] == "L" then
                    rebuild(mutable[mut])
                end
            else
                rebuild(mutable[mut])
            end
            set.segs(mutable[mut] - 2, mutable[mut] + 1)
            tWorkingMiddleSegs[1] = mutable[mut]
            if not bRebuildInMutatingIgnoreStructures then
                if ss[mutable[mut]] == "L" then
                    rebuild(mutable[mut])
                end
            else
                rebuild(mutable[mut])
            end            
        end
        set.segs(mutable[mut] - 1, mutable[mut] + 1)
        if not bRebuildInMutatingIgnoreStructures then
            if ss[mutable[mut]] == "L" then
                rebuild(mutable[mut])
            end
        else
            rebuild(mutable[mut])
        end
    elseif bOptimizeSidechain then
        set.segs(mutable[mut], mutable[mut])
        if not sidechain_tweak(mutable[mut]) then
            bSpheredFuzing = true
            fuze.start(sl_mut)
            bSpheredFuzing = false
        end
    end
    if not more then
        if check.increase(report.stop(), saveSlotOverall) then
        end
    end
end -- function

--Mutate#

function getNear(segment)
    if(get.score() < g_total_score-1000) then
        deselect.index(segment)
        work.step("s", 1, 0.75, 0)
        work.step("ws", 1, 0)
        select.index(segment)
        set.clashImportance(1)
    end
    if(get.score() < g_total_score-1000) then
        return false
    end
    return true
end

function sidechain_tweak(tweak_seg)
    if tweak_seg == nil then
        tweak_seg = tWorkingMiddleSegs[1]
    end
    score.recent.save()
    if aa[tweak_seg] ~= "a" or aa[tweak_seg] ~= "g" then
        bool = true
        bTweaking = true
        sl_reset = saveSlot.request()
        saveSlot.save(sl_reset)
        deselect.all()
        select.segs(false,tweak_seg)
        local ss = get.score()
        g_total_score = get.score()
        if work.step("s", 2, 0, 0) then
            p("AT: Sidechain tweak")
            sl_tweak_work = saveSlot.request()
            saveSlot.save(sl_tweak_work)
            select.segs(true, tweak_seg)
            if getNear(tweak_seg) then
                sl_tweak = saveSlot.request()
                fuze.start(sl_tweak)
                saveSlot.release(sl_tweak)
            end
            if ss < get.score() then
                saveSlot.save(sl_reset)
                deselect.all()  
                select.segs(false,tweak_seg)
                local ss = get.score()
                g_total_score = get.score()
                work.step("s", 2, 0, 0)
                saveSlot.save(sl_tweak_work)
            else
                saveSlot.load(sl_tweak_work)
            end
            deselect.all()
            select.segs(tweak_seg)
            local ss=get.score()
            g_total_score = get.score()
            if get.score() > g_total_score - 30 then
                p("AT: Sidechain tweak around")
                select.segs(true, tweak_seg)
                deselect.index(tweak_seg)
                work.step("s", 1, 0.1, 0)
                select.index(tweak_seg)
                if getNear(i) then
                    sl_tweak = saveSlot.request()
                    fuze.start(sl_tweak)
                    saveSlot.release(sl_tweak)
                end
                if ss > get.score() then
                    saveSlot.load(sl_reset)
                end
            end
        else
            bool = false
        end        -- if work.step
        saveSlot.release(sl_reset)
        saveSlot.release(sl_tweak_work)
        bTweaking = false
    else
        bool = false
    end
    score.recent.restore()
    return bool
end

function run()
    p("v" .. iVersion)
    if isReleaseVersion then
        p("Release Version " .. iReleaseVersion)
        p("Released on " .. strReleaseDate)
    else -- if isReleaseVersion
        p("No Released script so it's probably unsafe!")
        p("Last version released on " .. strReleaseDate)
        p("It was release version " .. iReleaseVersion)
    end -- if isReleaseVersion
    fMaxScore = get.score()
    p("Starting Score: " .. fMaxScore)
    report.start("Overall Gain")
    saveSlotOverall = 1
    saveSlot.save(saveSlotOverall)
    check.ss()
    check.ligand()
    check.aa()
    check.hydro()
    check.mutable()
    if isPredictingEnabled then
        predict.getdata()
        save.SaveSecondaryStructure()
    elseif isStructureRebuildEnabled then
        struct_rebuild()
    elseif isCurlingEnabled then
        struct_curler()
    elseif isCompressingEnabled then
        for i = 1, iCompressingTrys do
            if bCompressingPredictedBonding or bCompressingPredictedLocalBonding then
                calc.run()
            end -- if bCompressingPredictedBonding
            compress()
        end -- for i
    elseif isMutatingEnabled then
        mutate()
    elseif isRebuildingEnabled then
        if bRebuildWorst then
            get.worst(iWorstSegmentLength)
            select.segs(workingSegmentLeft, workingSegmentRight)
            set.ss("L")
            rebuild()
        end -- if bRebuildWorst
        if bRebuildLoops then
            check.struct()
            local i
            for i = 1, #lo do
                set.segs(lo[i][1], lo[i][#lo[i]])
                rebuild()
                get.progress(1, #lo, 1, i)
            end -- for i
        end -- if RebuildLoops
    elseif isFuzingEnabled then
        p("Fuzing")
        fuze.start(saveSlotOverall)
    end -- if isFuzingEnabled
    if (isRebuildingEnabled and not bRebuildWorst and not bRebuildLoops) or isLocalWiggleEnabled or isSnappingEnabled then
        local i
        for i = iStartSegment, iEndSegment do
            set.segs(i,i)
            if isSnappingEnabled then
                snap()
            end -- if isSnappingEnabled
            local ii
            for ii = iStartingWalk, iEndWalk do
                if i + ii > iSegmentCount then
                    break
                end -- if workingSegmentRight
                set.segs(i,i + ii)
                if isRebuildingEnabled then
                    if bRebuildWalking then
                        select.segs()
                        set.ss("L")
                        rebuild()
                    end -- if bRebuildWalking
                elseif isLocalWiggleEnabled then
                    p(workingSegmentLeft .. "-" .. workingSegmentRight)
                    work.flow("wl")
                end -- if isLocalWiggleEnabled
            end -- for ii
            get.progress(iStartSegment, iEndSegment, 1, i)
        end -- for i
    end -- if (isRebuildingEnabled
    saveSlot.load(saveSlotOverall)
    save.LoadSecondaryStructure()
    saveSlot.release(saveSlotOverall)
    p("+++ overall gain +++")
    p("+++" .. report.stop() .. "+++")
end

run()

--[[old/unused function
if b_test then
    scoie=0
    for ii=1,70 do
        behavior.SetWiggleAccuracy(ii*0.1)
        p("Wiggle: " .. behavior.GetWiggleAccuracy())
        for iii=1,4 do
            reset.puzzle()
            saveSlot.save(saveSlotOverall)
            behavior.SetShakeAccuracy(iii)
            p("Shake: " .. behavior.GetShakeAccuracy())
            fuze.start(overall)
            saveSlot.load(saveSlotOverall)
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

local function _HCI(a, b) -- hydropathy
    return 20 - math.abs((amino.hydroscale(a) - amino.hydroscale(b)) * 19 / 10.6)
end

local function _SCI(a, b) -- size
    return 20 - math.abs((amino.size(a) + amino.size(b) - 123) * 19 / 135)
end

local function _CCI(a, b) -- charge
    return 11 - (amino.charge(a) - 7) * (amino.charge(b) - 7) * 19 / 33.8
end

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

if bIsExploringPuzzle then
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
    isLocalWiggleEnabled = true
    else
    sec_dialog = dialog.CreateDialog("Rebuilding Settings")
    isRebuildingEnabled = true
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
    sec_dialog.startseg = dialog.AddSlider("Start Segment", 1, 1, iSegmentCount, 1)
    sec_dialog.endseg = dialog.AddSlider("End Segment", iSegmentCount, 1, iSegmentCount, 1)
    sec_dialog.startwalk = dialog.AddSlider("Walking Area Start", 1, 0, iSegmentCount, 1)
    sec_dialog.endwalk = dialog.AddSlider("Walking Area End", 3, 0, iSegmentCount, 1)
    elseif dialog.result == 3 then
    sec_dialog.bondingpercentage = dialog.AddSlider("Bonding Percentage in %", 1, 1, 100, 1)
    sec_dialog.bandlength = dialog.AddSlider("Band length", 4, 1, 20, 1)

    sec_dialog.walking_re = dialog.AddCheckbox("Fixxed Work", false)
    sec_dialog.startseg_fixxed = dialog.AddSlider("Fixxed start Segment", 1, 1, iSegmentCount, 1)
    sec_dialog.endseg_fixxed = dialog.AddSlider("Fixxed end Segment", iSegmentCount, 1, iSegmentCount, 1)
    
    sec_dialog.Iterations = dialog.AddLabel("Iterations="..ask.Iterations.value)
    sec_dialog.BandStrength = dialog.AddLabel("Band Strength="..ask.BandStrength.value)
    sec_dialog.Comment = dialog.AddLabel("Comment="..ask.Comment.value)
    sec_dialog.OK = dialog.AddButton("OK", 1)
    sec_dialog.OK = dialog.AddButton("Cancel", 0)
else
    print("Dialog cancelled")
end
if bIsExploringPuzzle & ask.useExploreMultiplier.value then
        bExploringWork = true
    end
    if (ask.sphere.value) then
        bSpheredFuzing = true
    end
    
    if not (dialog.Show(lws_dialog) == 1) then
        return showConfigDialog()
    end
]]