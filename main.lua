--[[#Header
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions and ideas goes to Seagat, Rav3n_pl, Tlaloc, Gary Forbis and BitSpawn
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
iVersion            = 1247
iSegmentCount       = structure.GetCount()
--#Release
isReleaseVersion    = true
strReleaseDate      = "29th August, 2012"
iReleaseVersion     = 5
--Release#
--Game vars#

--#Settings: default
--#Main                                     default         description
bDontUseDialog              = false         -- false        If you dont want to use the dialog everytime set the settings like you wish and set this to true to get no Dialog shown at start
isLocalWiggleEnabled        = false         -- false        do local wiggle and rewiggle
isRebuildingEnabled         = false         -- false        rebuild | see #Rebuilding
isCompressingEnabled        = false         -- false        pull hydrophobic amino acids in different modes then fuze | see #Pull
isStructureRebuildEnabled   = false         -- false        rebuild the protein based on the secondary structures | see #Structed rebuilding
isCurlingEnabled            = false         -- false        Do bond the structures and curl it, try to improve it and get some points
isSnappingEnabled           = false         -- false        should we snap every sidechain to different positions
isFuzingEnabled             = false         -- false        should we fuze | see #Fuzing
isMutatingEnabled           = false         -- false        it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
isPredictingEnabled         = false         -- false        reset and predict then the secondary structure based on the amino acids of the protein
--isEvolutionEnabled                                        TODO: IDEA to fully automatic random methods -- rebuilding/pushing/pulling
bExploringWork              = false         -- false        if true then the overall score will be taken if a exploration puzzle, if false then just the stability score is used for the methods
--Main#

--#Working                      default             description
iStartSegment   = 1             -- 1                the first segment to work with
iEndSegment     = iSegmentCount -- iSegmentCount    the last segment to work with
iStartingWalk   = 1             -- 1                with how many segs shall we work - Walker
iEndWalk        = 3             -- 3                starting at the current segment + iStartingWalk to segment + iEndWalk
--Working#

--#LocalWiggle
fScoreMustChange = 0.001        -- 0.001            an action tries to get this score, then it will repeat itself | adjust a lower value to get the lws script working on high evo- / solos
--LocalWiggle#

--#Rebuilding
bRebuildWorst                       = false         -- false        rebuild worst scored parts of the protein | TODO: Do it some times with table of worst segments from worst to best
iWorstSegmentLength                 = 4
iRebuildTrys                        = 10            -- 10           how many different shapes we try to get
bRebuildLoops                       = false         -- false        rebuild whole loops | TODO: implement max length of loop rebuild max 5 would be good i think then walk through the structure
bRebuildWalking                     = false         -- false        walk through the protein rebuilding every segment with different lengths of rebuilds
iRebuildsTillSave                   = 1             -- 2            max rebuilds till best rebuild will be chosen
iRebuildStrength                    = 1             -- 1            the iterations a rebuild will do at default, automatically increased if no change in score
--Rebuilding#

--#Pull                                         default     description
iCompressingTrys                    = 1         -- 1        how often should the pull start over?
fCompressingLoss                    = 1         -- 1        the score / 100 * fCompressingLoss is the general formula for calculating the points we must lose till we fuze
bCompressingConsiderStructure       = true      -- true     don't band segs of same structure together if segs are in one struct (between one helix or sheet)
fCompressingBondingPercentage       = 8         -- 8
iCompressingBondingLength           = 4
bCompressingFixxedBonding           = false     -- false
iCompressingFixxedStartSegment      = 1         -- 1
iCompressingFixxedEndSegment        = 1         -- 1
bCompressingSoftBonding             = true
bCompressingFuze                    = true
bCompressingSoloBonding             = false     -- false    just one segment is used on every method and all segs are tested
bCompressingLocalBonding            = false     -- false
--Methods
bCompressingPredictedBonding        = true      -- true     bands are created which pull segs together based on the size, charge and isoelectric point of the amino acids
bCompressingPredictedLocalBonding   = false     -- false    TODO: check if there are bands
bCompressingEvolutionBonding        = false     -- true
iCompressingEvolutionRounds         = 10
bCompressingEvolutionOnlyBetter     = true
bCompressingPushPull                = true      -- true
bCompressingPull                    = true      -- true     hydrophobic segs are pulled together
-- TODO: First Push out then pull in -- test vs combined push,pull
-- TODO: Band Sheets togehter then work, make Helices stable with inner bonding
bCompressingCenterPushPull          = true      -- true
bCompressingCenterPull              = true      -- true     hydrophobic segs are pulled to the center segment
-- TODO: IDEA (ErichVanSterich: 'alternate(pictorial) work') creating herds for 'center' like working
--Pull

--#Structed rebuilding
iStructuredRebuildTillSave  = 2             -- 2            same as iRebuildsTillSave at #Rebuilding
iStructuredRebuildStrength  = 1             -- 1            same as iRebuildStrength at #Rebuilding
bStructuredRebuildHelix     = true          -- true         should we rebuild helices
bStructuredRebuildSheet     = true          -- true         should we rebuild sheets
bStructuredRebuildFuze      = false         -- false        should we fuze after one rebuild | better let it rebuild then handwork it yourself and then fuze!
--Structed rebuilding#

--#Curler
bCurlingHelix   = true          -- true
bCurlingSheet   = true          -- true
--Curler#

--#Snapping
-- TODO: Rework Snapping :/ make use of AT implemention | just sidechain snapping with rotamers need new code
--Snapping#

--#Fuzing
bFuzingBlueFuze = true          -- true         Use Bluefuse else wiggle out with pink fuze
--Fuzing#

--#Mutating
-- TODO: all mutating things into the mutating category and method
bOptimizeSidechain                  = true
bRebuildAfterMutating               = true
bRebuildInMutatingIgnoreStructures  = true          -- true         TODO: implement completly in rebuilding / combine with loop rebuild
bRebuildInMutatingDeepRebuild       = true          -- true         rebuild length 3,4,5 else just 3
bRebuildTweakWholeRebuild           = true          -- true       All Sidechains get tweaked after rebuild not just the one focusing in the rebuild
bMutateAfterCompressing             = false
bMutateSurroundingAfter             = true          -- true
fClashingForMutating                = 0.75          -- 0.75         cl for mutating
--Mutating#

--#Predicting
bPredictingFull                 = false     -- false        try to detect the secondary structure between every segment, there can be less loops but the protein become difficult to rebuild
bPredictingAddPrefferedSegments = true      -- true
bPredictingCombine              = false     -- false        TODO: Doesn't work at all
bPredictingOtherMethod          = true
--Predicting#

--#General
iTimeSecsBetweenReports = 30
iTimeMaxHoursToUse      = 0
iTimeMaxMinsToUse      	= 5
iTimeMaxSecsToUse      	= 0
bUseTimeOptimization    = true
--General#
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
bChanged            = true
bStructureChanged   = true
bSurroundMutatingCurrently = false
fCompressingBondingPercentageWork   = iSegmentCount / 100 * fCompressingBondingPercentage
if current.GetExplorationMultiplier() == 0 then
    bIsExploringPuzzle = false
else
    bIsExploringPuzzle = true
end
math.randomseed(recipe.GetRandomSeed()*os.time())
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

amino =
{   short       = _short,
    abbrev      = _abbrev,
    long        = _long,
    hydro       = _h,
    hydroscale  = _hscale,
    preffered   = _pref,
    size        = _mol,
    charge      = _pl,
    part        = {short = 0, abbrev = 1, longname = 2, hydro = 3, scale = 4, pref = 5, mol = 6, pl = 7},
    segs        = {'a', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'y'},
    table       = {
  --short = {abbrev,longname,       hydrophobic,scale,  pref,   mol,        pl
    ['a'] = {'Ala', 'Alanine',          true,   -1.6,   'H',    89.094,     6.01},
    ['c'] = {'Cys', 'Cysteine',         true,   -17,    'E',    121.154,    5.05},
    ['d'] = {'Asp', 'Aspartic acid',    false,  6.7,    'L',    133.1038,   2.85},
    ['e'] = {'Glu', 'Glutamic acid',    false,  8.1,    'H',    147.1307,   3.15},
    ['f'] = {'Phe', 'Phenylalanine',    true,   -6.3,   'E',    165.1918,   5.49},
    ['g'] = {'Gly', 'Glycine',          true,   1.7,    'L',    75.0671,    6.06},
    ['h'] = {'His', 'Histidine',        false,  -5.6,   nil,    155.1563,   7.60},
    ['i'] = {'Ile', 'Isoleucine',       true,   -2.4,   'E',    131.1746,   6.05},
    ['k'] = {'Lys', 'Lysine',           false,  6.5,    'H',    146.1893,   9.60},
    ['l'] = {'Leu', 'Leucine',          true,   1,      'H',    131.1746,   6.01},
    ['m'] = {'Met', 'Methionine',       true,   3.4,    'H',    149.2078,   5.74},
    ['n'] = {'Asn', 'Asparagine',       false,  8.9,    'L',    132.119,    5.41},
    ['p'] = {'Pro', 'Proline',          true,   -0.2,   'L',    115.1319,   6.30},
    ['q'] = {'Gln', 'Glutamine',        false,  9.7,    'H',    146.1459,   5.65},
    ['r'] = {'Arg', 'Arginine',         false,  9.8,    'H',    174.2027,   10.76},
    ['s'] = {'Ser', 'Serine',           false,  3.7,    'L',    105.0934,   5.68},
    ['t'] = {'Thr', 'Threonine',        false,  2.7,    'E',    119.1203,   5.60},
    ['v'] = {'Val', 'Valine',           true,   -2.9,   'E',    117.1478,   6.00},
    ['w'] = {'Trp', 'Tryptophan',       true,   -9.1,   'E',    204.2284,   5.89},
    ['y'] = {'Tyr', 'Tyrosine',         true,   -5.1,   'E',    181.1912,   5.64}
    }
}

--#Calculations
local function _calc()
    local tCalculatedStrength = {}
    local i
    for i = 1, #amino.segs do
        tCalculatedStrength[amino.segs[i]] = {}
    end
    tCalculatedStrength['a']['a'] = 32.37285621091;tCalculatedStrength['a']['c'] = 27.1852;tCalculatedStrength['a']['d'] = 27.7753;tCalculatedStrength['a']['e'] = 50.4563;tCalculatedStrength['a']['f'] = 20.3536;tCalculatedStrength['a']['g'] = 51.6725;tCalculatedStrength['a']['h'] = 49.4786;tCalculatedStrength['a']['i'] = 27.7753;tCalculatedStrength['a']['k'] = 8.37506;tCalculatedStrength['a']['l'] = 51.6725;tCalculatedStrength['a']['m'] = 51.6725;tCalculatedStrength['a']['n'] = 20.3536;tCalculatedStrength['a']['p'] = 20.3536;tCalculatedStrength['a']['q'] = 34.6395;tCalculatedStrength['a']['r'] = 27.7753;tCalculatedStrength['a']['s'] = 50.243;tCalculatedStrength['a']['t'] = -7.50419;tCalculatedStrength['a']['v'] = -11.1915;tCalculatedStrength['a']['w'] = 20.3536;tCalculatedStrength['a']['y'] = 51.6725;tCalculatedStrength['c']['a'] = 27.1852;tCalculatedStrength['c']['c'] = 48.8752;tCalculatedStrength['c']['d'] = 41.8555;tCalculatedStrength['c']['e'] = 26.6356;tCalculatedStrength['c']['f'] = 43.066;tCalculatedStrength['c']['g'] = 29.8568;tCalculatedStrength['c']['h'] = 36.5647;tCalculatedStrength['c']['i'] = 41.8555;tCalculatedStrength['c']['k'] = 31.0495;tCalculatedStrength['c']['l'] = 29.8568;tCalculatedStrength['c']['m'] = 29.8568;tCalculatedStrength['c']['n'] = 43.066;tCalculatedStrength['c']['p'] = 43.066;tCalculatedStrength['c']['q'] = 53.9513;tCalculatedStrength['c']['r'] = 41.8555;tCalculatedStrength['c']['s'] = 31.249;tCalculatedStrength['c']['t'] = 13.807;tCalculatedStrength['c']['v'] = 17.5416;tCalculatedStrength['c']['w'] = 43.066;tCalculatedStrength['c']['y'] = 29.8568;tCalculatedStrength['d']['a'] = 27.7753;tCalculatedStrength['d']['c'] = 41.8555;tCalculatedStrength['d']['d'] = 45.8231;tCalculatedStrength['d']['e'] = 42.1045;tCalculatedStrength['d']['f'] = 35.2602;tCalculatedStrength['d']['g'] = 52.6048;tCalculatedStrength['d']['h'] = 60.1862;tCalculatedStrength['d']['i'] = 45.8231;tCalculatedStrength['d']['k'] = 23.2728;tCalculatedStrength['d']['l'] = 52.6048;tCalculatedStrength['d']['m'] = 52.6048;tCalculatedStrength['d']['n'] = 35.2602;tCalculatedStrength['d']['p'] = 35.2602;tCalculatedStrength['d']['q'] = 49.2573;tCalculatedStrength['d']['r'] = 45.8231;tCalculatedStrength['d']['s'] = 47.4172;tCalculatedStrength['d']['t'] = 7.0786;tCalculatedStrength['d']['v'] = 5.10629;tCalculatedStrength['d']['w'] = 35.2602;tCalculatedStrength['d']['y'] = 52.6048;tCalculatedStrength['e']['a'] = 50.4563;tCalculatedStrength['e']['c'] = 26.6356;tCalculatedStrength['e']['d'] = 42.1045;tCalculatedStrength['e']['e'] = 49.5598;tCalculatedStrength['e']['f'] = 20.8448;tCalculatedStrength['e']['g'] = 41.1395;tCalculatedStrength['e']['h'] = 37.7893;tCalculatedStrength['e']['i'] = 42.1045;tCalculatedStrength['e']['k'] = 8.8277;tCalculatedStrength['e']['l'] = 41.1395;tCalculatedStrength['e']['m'] = 41.1395;tCalculatedStrength['e']['n'] = 20.8448;tCalculatedStrength['e']['p'] = 20.8448;tCalculatedStrength['e']['q'] = 33.8587;tCalculatedStrength['e']['r'] = 42.1045;tCalculatedStrength['e']['s'] = 48.4217;tCalculatedStrength['e']['t'] = -8.4392;tCalculatedStrength['e']['v'] = -4.57155;tCalculatedStrength['e']['w'] = 20.8448;tCalculatedStrength['e']['y'] = 41.1395;tCalculatedStrength['f']['a'] = 20.3536;tCalculatedStrength['f']['c'] = 43.066;tCalculatedStrength['f']['d'] = 35.2602;tCalculatedStrength['f']['e'] = 20.8448;tCalculatedStrength['f']['f'] = 54.409;tCalculatedStrength['f']['g'] = 24.5751;tCalculatedStrength['f']['h'] = 31.344;tCalculatedStrength['f']['i'] = 35.2602;tCalculatedStrength['f']['k'] = 42.395;tCalculatedStrength['f']['l'] = 24.5751;tCalculatedStrength['f']['m'] = 24.5751;tCalculatedStrength['f']['n'] = 54.409;tCalculatedStrength['f']['p'] = 54.409;tCalculatedStrength['f']['q'] = 48.1544;tCalculatedStrength['f']['r'] = 35.2602;tCalculatedStrength['f']['s'] = 25.507;tCalculatedStrength['f']['t'] = 25.2258;tCalculatedStrength['f']['v'] = 28.5612;tCalculatedStrength['f']['w'] = 54.409;tCalculatedStrength['f']['y'] = 24.5751;tCalculatedStrength['g']['a'] = 51.6725;tCalculatedStrength['g']['c'] = 29.8568;tCalculatedStrength['g']['d'] = 52.6048;tCalculatedStrength['g']['e'] = 41.1395;tCalculatedStrength['g']['f'] = 24.5751;tCalculatedStrength['g']['g'] = 39.4764;tCalculatedStrength['g']['h'] = 35.5605;tCalculatedStrength['g']['i'] = 52.6048;tCalculatedStrength['g']['k'] = 12.5391;tCalculatedStrength['g']['l'] = 39.4764;tCalculatedStrength['g']['m'] = 39.4764;tCalculatedStrength['g']['n'] = 24.5751;tCalculatedStrength['g']['p'] = 24.5751;tCalculatedStrength['g']['q'] = 36.9667;tCalculatedStrength['g']['r'] = 52.6048;tCalculatedStrength['g']['s'] = 45.2846;tCalculatedStrength['g']['t'] = -5.40665;tCalculatedStrength['g']['v'] = 2.1571;tCalculatedStrength['g']['w'] = 24.5751;tCalculatedStrength['g']['y'] = 39.4764;tCalculatedStrength['h']['a'] = 49.4786;tCalculatedStrength['h']['c'] = 36.5647;tCalculatedStrength['h']['d'] = 60.1862;tCalculatedStrength['h']['e'] = 37.7893;tCalculatedStrength['h']['f'] = 31.344;tCalculatedStrength['h']['g'] = 35.5605;tCalculatedStrength['h']['h'] = 41.6144;tCalculatedStrength['h']['i'] = 60.1862;tCalculatedStrength['h']['k'] = 19.3058;tCalculatedStrength['h']['l'] = 35.5605;tCalculatedStrength['h']['m'] = 35.5605;tCalculatedStrength['h']['n'] = 31.344;tCalculatedStrength['h']['p'] = 31.344;tCalculatedStrength['h']['q'] = 43.661;tCalculatedStrength['h']['r'] = 60.1862;tCalculatedStrength['h']['s'] = 41.8801;tCalculatedStrength['h']['t'] = 1.2786;tCalculatedStrength['h']['v'] = 9.28598;tCalculatedStrength['h']['w'] = 31.344;tCalculatedStrength['h']['y'] = 35.5605;tCalculatedStrength['i']['a'] = 27.7753;tCalculatedStrength['i']['c'] = 41.8555;tCalculatedStrength['i']['d'] = 45.8231;tCalculatedStrength['i']['e'] = 42.1045;tCalculatedStrength['i']['f'] = 35.2602;tCalculatedStrength['i']['g'] = 52.6048;tCalculatedStrength['i']['h'] = 60.1862;tCalculatedStrength['i']['i'] = 45.8231;tCalculatedStrength['i']['k'] = 23.2728;tCalculatedStrength['i']['l'] = 52.6048;tCalculatedStrength['i']['m'] = 52.6048;tCalculatedStrength['i']['n'] = 35.2602;tCalculatedStrength['i']['p'] = 35.2602;tCalculatedStrength['i']['q'] = 49.2573;tCalculatedStrength['i']['r'] = 45.8231;tCalculatedStrength['i']['s'] = 47.4172;tCalculatedStrength['i']['t'] = 7.0786;tCalculatedStrength['i']['v'] = 5.10629;tCalculatedStrength['i']['w'] = 35.2602;tCalculatedStrength['i']['y'] = 52.6048;tCalculatedStrength['k']['a'] = 8.37506;tCalculatedStrength['k']['c'] = 31.0495;tCalculatedStrength['k']['d'] = 23.2728;tCalculatedStrength['k']['e'] = 8.8277;tCalculatedStrength['k']['f'] = 42.395;tCalculatedStrength['k']['g'] = 12.5391;tCalculatedStrength['k']['h'] = 19.3058;tCalculatedStrength['k']['i'] = 23.2728;tCalculatedStrength['k']['k'] = 58.3427;tCalculatedStrength['k']['l'] = 12.5391;tCalculatedStrength['k']['m'] = 12.5391;tCalculatedStrength['k']['n'] = 42.395;tCalculatedStrength['k']['p'] = 42.395;tCalculatedStrength['k']['q'] = 36.1375;tCalculatedStrength['k']['r'] = 23.2728;tCalculatedStrength['k']['s'] = 13.4887;tCalculatedStrength['k']['t'] = 41.1708;tCalculatedStrength['k']['v'] = 44.521;tCalculatedStrength['k']['w'] = 42.395;tCalculatedStrength['k']['y'] = 12.5391;tCalculatedStrength['l']['a'] = 51.6725;tCalculatedStrength['l']['c'] = 29.8568;tCalculatedStrength['l']['d'] = 52.6048;tCalculatedStrength['l']['e'] = 41.1395;tCalculatedStrength['l']['f'] = 24.5751;tCalculatedStrength['l']['g'] = 39.4764;tCalculatedStrength['l']['h'] = 35.5605;tCalculatedStrength['l']['i'] = 52.6048;tCalculatedStrength['l']['k'] = 12.5391;tCalculatedStrength['l']['l'] = 39.4764;tCalculatedStrength['l']['m'] = 39.4764;tCalculatedStrength['l']['n'] = 24.5751;tCalculatedStrength['l']['p'] = 24.5751;tCalculatedStrength['l']['q'] = 36.9667;tCalculatedStrength['l']['r'] = 52.6048;tCalculatedStrength['l']['s'] = 45.2846;tCalculatedStrength['l']['t'] = -5.40665;tCalculatedStrength['l']['v'] = 2.1571;tCalculatedStrength['l']['w'] = 24.5751;tCalculatedStrength['l']['y'] = 39.4764;tCalculatedStrength['m']['a'] = 51.6725;tCalculatedStrength['m']['c'] = 29.8568;tCalculatedStrength['m']['d'] = 52.6048;tCalculatedStrength['m']['e'] = 41.1395;tCalculatedStrength['m']['f'] = 24.5751;tCalculatedStrength['m']['g'] = 39.4764;tCalculatedStrength['m']['h'] = 35.5605;tCalculatedStrength['m']['i'] = 52.6048;tCalculatedStrength['m']['k'] = 12.5391;tCalculatedStrength['m']['l'] = 39.4764;tCalculatedStrength['m']['m'] = 39.4764;tCalculatedStrength['m']['n'] = 24.5751;tCalculatedStrength['m']['p'] = 24.5751;tCalculatedStrength['m']['q'] = 36.9667;tCalculatedStrength['m']['r'] = 52.6048;tCalculatedStrength['m']['s'] = 45.2846;tCalculatedStrength['m']['t'] = -5.40665;tCalculatedStrength['m']['v'] = 2.1571;tCalculatedStrength['m']['w'] = 24.5751;tCalculatedStrength['m']['y'] = 39.4764;tCalculatedStrength['n']['a'] = 20.3536;tCalculatedStrength['n']['c'] = 43.066;tCalculatedStrength['n']['d'] = 35.2602;tCalculatedStrength['n']['e'] = 20.8448;tCalculatedStrength['n']['f'] = 54.409;tCalculatedStrength['n']['g'] = 24.5751;tCalculatedStrength['n']['h'] = 31.344;tCalculatedStrength['n']['i'] = 35.2602;tCalculatedStrength['n']['k'] = 42.395;tCalculatedStrength['n']['l'] = 24.5751;tCalculatedStrength['n']['m'] = 24.5751;tCalculatedStrength['n']['n'] = 54.409;tCalculatedStrength['n']['p'] = 54.409;tCalculatedStrength['n']['q'] = 48.1544;tCalculatedStrength['n']['r'] = 35.2602;tCalculatedStrength['n']['s'] = 25.507;tCalculatedStrength['n']['t'] = 25.2258;tCalculatedStrength['n']['v'] = 28.5612;tCalculatedStrength['n']['w'] = 54.409;tCalculatedStrength['n']['y'] = 24.5751;tCalculatedStrength['p']['a'] = 20.3536;tCalculatedStrength['p']['c'] = 43.066;tCalculatedStrength['p']['d'] = 35.2602;tCalculatedStrength['p']['e'] = 20.8448;tCalculatedStrength['p']['f'] = 54.409;tCalculatedStrength['p']['g'] = 24.5751;tCalculatedStrength['p']['h'] = 31.344;tCalculatedStrength['p']['i'] = 35.2602;tCalculatedStrength['p']['k'] = 42.395;tCalculatedStrength['p']['l'] = 24.5751;tCalculatedStrength['p']['m'] = 24.5751;tCalculatedStrength['p']['n'] = 54.409;tCalculatedStrength['p']['p'] = 54.409;tCalculatedStrength['p']['q'] = 48.1544;tCalculatedStrength['p']['r'] = 35.2602;tCalculatedStrength['p']['s'] = 25.507;tCalculatedStrength['p']['t'] = 25.2258;tCalculatedStrength['p']['v'] = 28.5612;tCalculatedStrength['p']['w'] = 54.409;tCalculatedStrength['p']['y'] = 24.5751;tCalculatedStrength['q']['a'] = 34.6395;tCalculatedStrength['q']['c'] = 53.9513;tCalculatedStrength['q']['d'] = 49.2573;tCalculatedStrength['q']['e'] = 33.8587;tCalculatedStrength['q']['f'] = 48.1544;tCalculatedStrength['q']['g'] = 36.9667;tCalculatedStrength['q']['h'] = 43.661;tCalculatedStrength['q']['i'] = 49.2573;tCalculatedStrength['q']['k'] = 36.1375;tCalculatedStrength['q']['l'] = 36.9667;tCalculatedStrength['q']['m'] = 36.9667;tCalculatedStrength['q']['n'] = 48.1544;tCalculatedStrength['q']['p'] = 48.1544;tCalculatedStrength['q']['q'] = 61.1758;tCalculatedStrength['q']['r'] = 49.2573;tCalculatedStrength['q']['s'] = 38.4618;tCalculatedStrength['q']['t'] = 18.8787;tCalculatedStrength['q']['v'] = 22.702;tCalculatedStrength['q']['w'] = 48.1544;tCalculatedStrength['q']['y'] = 36.9667;tCalculatedStrength['r']['a'] = 27.7753;tCalculatedStrength['r']['c'] = 41.8555;tCalculatedStrength['r']['d'] = 45.8231;tCalculatedStrength['r']['e'] = 42.1045;tCalculatedStrength['r']['f'] = 35.2602;tCalculatedStrength['r']['g'] = 52.6048;tCalculatedStrength['r']['h'] = 60.1862;tCalculatedStrength['r']['i'] = 45.8231;tCalculatedStrength['r']['k'] = 23.2728;tCalculatedStrength['r']['l'] = 52.6048;tCalculatedStrength['r']['m'] = 52.6048;tCalculatedStrength['r']['n'] = 35.2602;tCalculatedStrength['r']['p'] = 35.2602;tCalculatedStrength['r']['q'] = 49.2573;tCalculatedStrength['r']['r'] = 45.8231;tCalculatedStrength['r']['s'] = 47.4172;tCalculatedStrength['r']['t'] = 7.0786;tCalculatedStrength['r']['v'] = 5.10629;tCalculatedStrength['r']['w'] = 35.2602;tCalculatedStrength['r']['y'] = 52.6048;tCalculatedStrength['s']['a'] = 50.243;tCalculatedStrength['s']['c'] = 31.249;tCalculatedStrength['s']['d'] = 47.4172;tCalculatedStrength['s']['e'] = 48.4217;tCalculatedStrength['s']['f'] = 25.507;tCalculatedStrength['s']['g'] = 45.2846;tCalculatedStrength['s']['h'] = 41.8801;tCalculatedStrength['s']['i'] = 47.4172;tCalculatedStrength['s']['k'] = 13.4887;tCalculatedStrength['s']['l'] = 45.2846;tCalculatedStrength['s']['m'] = 45.2846;tCalculatedStrength['s']['n'] = 25.507;tCalculatedStrength['s']['p'] = 25.507;tCalculatedStrength['s']['q'] = 38.4618;tCalculatedStrength['s']['r'] = 47.4172;tCalculatedStrength['s']['s'] = 52.9759;tCalculatedStrength['s']['t'] = -3.84333;tCalculatedStrength['s']['v'] = 0.379152;tCalculatedStrength['s']['w'] = 25.507;tCalculatedStrength['s']['y'] = 45.2846;tCalculatedStrength['t']['a'] = -7.50419;tCalculatedStrength['t']['c'] = 13.807;tCalculatedStrength['t']['d'] = 7.0786;tCalculatedStrength['t']['e'] = -8.4392;tCalculatedStrength['t']['f'] = 25.2258;tCalculatedStrength['t']['g'] = -5.40665;tCalculatedStrength['t']['h'] = 1.2786;tCalculatedStrength['t']['i'] = 7.0786;tCalculatedStrength['t']['k'] = 41.1708;tCalculatedStrength['t']['l'] = -5.40665;tCalculatedStrength['t']['m'] = -5.40665;tCalculatedStrength['t']['n'] = 25.2258;tCalculatedStrength['t']['p'] = 25.2258;tCalculatedStrength['t']['q'] = 18.8787;tCalculatedStrength['t']['r'] = 7.0786;tCalculatedStrength['t']['s'] = -3.84333;tCalculatedStrength['t']['t'] = 39.6748;tCalculatedStrength['t']['v'] = 43.5572;tCalculatedStrength['t']['w'] = 25.2258;tCalculatedStrength['t']['y'] = -5.40665;tCalculatedStrength['v']['a'] = -11.1915;tCalculatedStrength['v']['c'] = 17.5416;tCalculatedStrength['v']['d'] = 5.10629;tCalculatedStrength['v']['e'] = -4.57155;tCalculatedStrength['v']['f'] = 28.5612;tCalculatedStrength['v']['g'] = 2.1571;tCalculatedStrength['v']['h'] = 9.28598;tCalculatedStrength['v']['i'] = 5.10629;tCalculatedStrength['v']['k'] = 44.521;tCalculatedStrength['v']['l'] = 2.1571;tCalculatedStrength['v']['m'] = 2.1571;tCalculatedStrength['v']['n'] = 28.5612;tCalculatedStrength['v']['p'] = 28.5612;tCalculatedStrength['v']['q'] = 22.702;tCalculatedStrength['v']['r'] = 5.10629;tCalculatedStrength['v']['s'] = 0.379152;tCalculatedStrength['v']['t'] = 43.5572;tCalculatedStrength['v']['v'] = 48.1268;tCalculatedStrength['v']['w'] = 28.5612;tCalculatedStrength['v']['y'] = 2.1571;tCalculatedStrength['w']['a'] = 20.3536;tCalculatedStrength['w']['c'] = 43.066;tCalculatedStrength['w']['d'] = 35.2602;tCalculatedStrength['w']['e'] = 20.8448;tCalculatedStrength['w']['f'] = 54.409;tCalculatedStrength['w']['g'] = 24.5751;tCalculatedStrength['w']['h'] = 31.344;tCalculatedStrength['w']['i'] = 35.2602;tCalculatedStrength['w']['k'] = 42.395;tCalculatedStrength['w']['l'] = 24.5751;tCalculatedStrength['w']['m'] = 24.5751;tCalculatedStrength['w']['n'] = 54.409;tCalculatedStrength['w']['p'] = 54.409;tCalculatedStrength['w']['q'] = 48.1544;tCalculatedStrength['w']['r'] = 35.2602;tCalculatedStrength['w']['s'] = 25.507;tCalculatedStrength['w']['t'] = 25.2258;tCalculatedStrength['w']['v'] = 28.5612;tCalculatedStrength['w']['w'] = 54.409;tCalculatedStrength['w']['y'] = 24.5751;tCalculatedStrength['y']['a'] = 51.6725;tCalculatedStrength['y']['c'] = 29.8568;tCalculatedStrength['y']['d'] = 52.6048;tCalculatedStrength['y']['e'] = 41.1395;tCalculatedStrength['y']['f'] = 24.5751;tCalculatedStrength['y']['g'] = 39.4764;tCalculatedStrength['y']['h'] = 35.5605;tCalculatedStrength['y']['i'] = 52.6048;tCalculatedStrength['y']['k'] = 12.5391;tCalculatedStrength['y']['l'] = 39.4764;tCalculatedStrength['y']['m'] = 39.4764;tCalculatedStrength['y']['n'] = 24.5751;tCalculatedStrength['y']['p'] = 24.5751;tCalculatedStrength['y']['q'] = 36.9667;tCalculatedStrength['y']['r'] = 52.6048;tCalculatedStrength['y']['s'] = 45.2846;tCalculatedStrength['y']['t'] = -5.40665;tCalculatedStrength['y']['v'] = 2.1571;tCalculatedStrength['y']['w'] = 24.5751;tCalculatedStrength['y']['y'] = 39.4764
    --Precalculated Table#
    local ii
    tPredictedStrength = {}
    for i = 1, iSegmentCount do
        tPredictedStrength[i] = {}
        for ii = i + 1, iSegmentCount do
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
{   status  = recipe.ReportStatus,
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

QuickSave = save.Quicksave
QuickLoad = save.Quickload
saveSlot =
{   release = _release,
    request = _request,
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
            if tDistances[temp][temp2] <= radius and not selection.IsSelected(i) then
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
            QuickLoad(slot)
            return
        end -- if sc2
    end -- if step
    if sectionEnd > 0 then
        if slot == saveSlotOverall then
            local currentScore = get.score()
            if currentScore > fMaxScore then
                QuickSave(slot)
                p("Gain: " .. currentScore - fMaxScore)
                fMaxScore = currentScore
                p("==NEW=MAX=" .. fMaxScore .. "==")
            else -- if sc2
                QuickLoad(slot)
            end -- if sc2
        else
            QuickSave(slot)
        end -- if slot
        return true
    else -- if sc2 >
        QuickLoad(slot)
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
        check.aa()
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
        hydro = {}
        for i = 1, iSegmentCount do
            aa[i] = get.aa(i)
            hydro[i] = amino.hydro(i)
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
    local currentTime = os.time()
    if currentTime - timeStart > (iTimeSecsBetweenReports + iTimeChecked * iTimeSecsBetweenReports) then
        iTimeChecked = iTimeChecked + 1
        local elapsedSecs = currentTime - timeStart
        estimatedTime = math.floor(elapsedSecs * fEstimatedTimeMod + 0.5)
        p("Time elapsed: " .. get.formattedTime(elapsedSecs) .. "; Recipe finished ".. fProgress .. "%")
        if estimatedTime ~= elapsedSecs then
            p("approx. time till that recipe is finished: " .. get.formattedTime(estimatedTime))
            p(os.date("Recipe will be approx. finished: %a, %c", estimatedTime + currentTime))
            if bUseTimeOptimization then
                iTimeMax = 0
                if not bUseTimeMaxDate then
                    iTimeMax = iTimeMaxHoursToUse * 60 * 60 + iTimeMaxMinsToUse * 60 + iTimeMaxSecsToUse
                else
                    iTimeMax = os.time{year = iTimeMaxDateYear, month = iTimeMaxDateMonth, day = iTimeMaxDateDay, hour = iTimeMaxDateHour, min = iTimeMaxDateMin ,sec = iTimeMaxDateSec}
                end
                if iTimeMax ~= 0 then
                    if estimatedTime > iTimeMax then
                        if isLocalWiggleEnabled then
                            if iStartingWalk < iEndWalk then
                                iEndWalk = iEndWalk - 1
                                p("Reduced end walking range")
                            elseif iStartingWalk >= iEndWalk and iStartingWalk > 0 then
                                iStartingWalk = iStartingWalk - 1
                                p("Reduced start walking range")
                            elseif iStartingWalk == iEndWalk and iStartingWalk == 1 then
                                if iStartSegment < iEndSegment then
                                    iEndSegment = iEndSegment - 1
                                    p("Reduced end seg")
                                end
                            end
                        end
                    end
                end
            end
        else
            p("calculating approx. finish of this recipe")
        end
        p("==MAX SCORE=" .. fMaxScore .. "==")
    end
end

local function _progress(start1, end1, iter1, vari1, start2, end2, iter2, vari2)
    if start2 then
        if iter1 == -1 then
            local start = (vari2 + (start1 - vari1) * end2)
            local stop = (end2 - vari2 - 1 + (end2 - 1) * vari1)
            fEstimatedTimeMod = stop / start
            fProgress = round(start / (start1 * end2) * 100, 3)
        elseif iter1 == 1 then
            if iter2 == 1 then
                local start = (vari1 - start1) * (end2 - start2) + vari2 - start2 + 1
                --local stop = (end2 - vari2) * (end1 - ) + vari2
                fEstimatedTimeMod = stop / start
                fProgress = start / (end1 - start1) * (end2 - start2)
                get.progress(iStartSegment, iEndSegment, 1, i, iStartingWalk, iEndWalk, 1, ii)
            end
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
{   distances   = _distances,
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
{   midTable        = _midTable,
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
end

do_ =
{   freeze      = _freeze,
    rebuild     = structure.RebuildSelected,
    snap        = rotamer.SetRotamer,
    unfreeze    = freeze.UnfreezeAll
}
--Doers#

--#Fuzing
local function _loss(option, cl1, cl2)
    if not bTweaking then score.recent.save() end
    if option == 1 then
        if not bTweaking then work.step("s", 1, cl1, bSpheredFuzing) end
        work.step("wa", 2, cl2, bSpheredFuzing)
        work.step("wa", 1, 1, bSpheredFuzing)
        work.step("s", 1, 1, bSpheredFuzing)
        work.step("wa", 1, cl2, bSpheredFuzing)
        work.step("wa", 2, 1, bSpheredFuzing)
    else -- if option
        if bTweaking then work.step("wa", 2, 1, bSpheredFuzing) end
        work.step("s", 1, cl1, bSpheredFuzing)
        work.step("wa", 2, 1, bSpheredFuzing)
        if work.step("s", 1, cl2, bSpheredFuzing) then work.step("wa", 2, 1, bSpheredFuzing) end
        if work.step("s", 1, cl1 - 0.02, bSpheredFuzing) then work.step("wa", 2, 1, bSpheredFuzing) end
        if work.step("s", 1, 1, bSpheredFuzing) then work.step("wa", 2, 1, bSpheredFuzing) end
    end -- if option
    score.recent.restore()
end

local function _releases(slot)
    sl_fuzing_compressing = saveSlot.request()
    QuickSave(sl_fuzing_compressing)
    fuze.start(slot)
    QuickLoad(sl_fuzing_compressing)
    fuze.start(slot, true)
    saveSlot.release(sl_fuzing_compressing)
end

local function _start(slot, pink)
    sl_f = saveSlot.request()
    report.start("Fuzing Complete")
    QuickSave(sl_f)
    if not pink then
        if bFuzingBlueFuze and not bTweaking then
            fuze.loss(2, 0.05, 0.07)
        else
            fuze.loss(1, 0.1, 0.6)
        end
    else
        fuze.loss(1, 0.1, 0.6)
    end
    saveSlot.release(sl_f)
    check.increase(report.stop(), slot)
end

fuze =
{   loss        = _loss,
    start       = _start,
    releases    = _releases
}
--Fuzing#

--#Universal select
function selection.segs(sphered, startSegment, endSegment, more)
    local i
    if sphered ~= false and sphered ~= true then
        local temp = startSegment
        startSegment = sphered
        sphered = nil
        if startSegment then
            endSegment, temp = temp, endSegment
            if endSegment then
                more = temp
            end -- if endSegment
        end -- if startSegment
    end -- if sphered
    if not more then
        selection.DeselectAll()
    end -- if not more
    if startSegment then
        if sphered then
            local list1
            if endSegment then
                if startSegment ~= endSegment then
                    if startSegment > endSegment then
                        startSegment, endSegment = endSegment, startSegment
                    end -- if > end
                    selection.SelectRange(startSegment, endSegment)
                    for i = startSegment, endSegment do
                        list1 = get.sphere(i, 10)
                        selection.list(list1)
                    end -- for i
                end -- if ~= end
            end -- if endSegment
            list1 = get.sphere(startSegment, 10)
            selection.list(list1)
            selection.Select(startSegment)
        elseif endSegment and startSegment ~= endSegment then
            if startSegment > endSegment then
                startSegment, endSegment = endSegment, startSegment
            end -- if > end
            selection.SelectRange(startSegment, endSegment)
        else -- if sphered
            selection.Select(startSegment)
        end -- if sphered
    else -- if startSegment
        selection.SelectAll()
    end -- if startSegment
end -- function

function selection.list(_list, sphered)
    local i
    local list1
    if _list then
        for i = 1, #_list do
            if sphered then
                list1 = get.sphere(_list[i], 10)
                selection.list(list1)
            end -- for i
            selection.Select(_list[i])
        end -- for
    end -- if _list
end -- function

function selection.deselectList(list)
    local i
    for i = 1, #list do
        selection.Deselect(list[i])
    end
end
--Universal select#

--#working
local function _step(a, iter, cl, sphered)
    if (cl == true or cl == false) and sphered == nil then
        sphered = cl
        cl = nil
    end
    if sphered == nil then
        selection.segs()
    elseif sphered ~= 0 then
        if sphered then
            selection.segs(true, workingSegmentLeft, workingSegmentRight)
        else -- if sphered
            selection.segs(workingSegmentLeft, workingSegmentRight)
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
    elseif a == "wla" or a == "wlb" then
        selection.segs(workingSegmentLeft, workingSegmentRight)
        score.recent.save()
        local s1 = get.score()
        if a == "wla" then
            wiggle.localSelected(iter)
        elseif a == "wlb" then
            wiggle.localSelectedBackbone(iter)
        end
        local s2 = get.score()
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
            QuickSave(work_sl)
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
        QuickLoad(work_sl)
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
        selection.segs(workingSegmentLeft, workingSegmentRight)
    else -- if workingSegmentLeft
        selection.segs()
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
        QuickSave(quake)
        score.recent.restore()
        local s2 = get.score()
        if s2 > s1 then
            score.recent.restore()
            QuickSave(saveSlotOverall)
        end -- if >
        QuickLoad(quake)
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
    selection.segs()
    QuickSave(saveSlotOverall)
    dist = saveSlot.request()
    local bandcount = get.bandcount()
    if bCompressingSoloBonding then
        p("Solo quaking enabled")
        bSpheredFuzing = true
        for ii = 1, bandcount do
            report.start("Solo Work")
            QuickSave(dist)
            work.quake(ii)
            if bMutateAfterCompressing then
                selection.SelectAll()
                structure.MutateSidechainsSelected(1)
            end -- if bMutateAfterCompressing
            bands.delete(ii)
            if bCompressingFuze then
                fuze.releases(dist)
            else
                work.step("wa", 3)
            end
            check.increase(report.stop(), saveSlotOverall)
        end -- for ii
        bSpheredFuzing = false
    else -- if bCompressingSoloBonding
        report.start("Compressing Work")
        QuickSave(dist)
        work.quake()
        bands.disable()
        if bCompressingFuze then
            fuze.releases(dist)
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
            end -- if iter
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
    local i
    for i = 1, iSegmentCount do
        if i ~= _seg then
            local otherSegment = i
            local segment = _seg
            if otherSegment < segment then
                otherSegment, segment = segment , otherSegment
            end -- if otherSegment
            if max_str <= tPredictedStrength[segment][otherSegment] then
                max_str = tPredictedStrength[segment][otherSegment]
            end -- if max_str <=
        end -- if i ~=
    end -- for otherSegment
    for i = 1, iSegmentCount do
        if i ~= _seg then
            local segment = _seg
            local otherSegment = i
            if otherSegment < segment then
                otherSegment, segment = segment , otherSegment
            end -- if otherSegment
            if tPredictedStrength[segment][otherSegment] == max_str then
                if check.same(segment, otherSegment) then
                    if not bands.addToSegs(segment , otherSegment) then
                        return false
                    end -- if not bands.
                    if bCompressingSoftBonding then
                        local cband = get.bandcount()
                        bands.length(cband, tDistances[segment][otherSegment] - iCompressingBondingLength)
                    end -- if bCompressingSoftBonding
                end -- if check.same
            end -- if tPredictedStrength
        end -- if i ~=
    end -- for otherSegment
    return true
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
    else -- if _he
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
    QuickSave(saveSlotOverall)
    dist_score = get.score()
    bands.delete()
    if bCompressingPredictedBonding then
        bonding.matrix.strong()
        work.dist()
        bands.delete()
    end -- if isCompressingEnabled_predicted
    if bCompressingPredictedLocalBonding then
        for i = iStartSegment, iEndSegment do
            if bonding.matrix.one(i) then
                work.dist()
                bands.delete()
            end
        end
    end -- if isCompressingEnabled_predicted
    if bCompressingPushPull then
        bonding.pull(bCompressingLocalBonding, fCompressingBondingPercentageWork / 2)
        bonding.push(bCompressingLocalBonding, fCompressingBondingPercentageWork)
        work.dist()
        bands.delete()
    end -- if isCompressingEnabled_combined
    if bCompressingEvolutionBonding then
        evolution()
    end -- if isCompressingEnabled_rnd
    if bCompressingPull then
        bonding.pull(bCompressingLocalBonding, fCompressingBondingPercentageWork)
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
                if bPredictingOtherMethod then
                    i = i + 5
                else
                    i = i + 4
                end
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
    selection.segs()
    set.ss("L")
    selection.DeselectAll()
    for i = 1, #p_he do
        selection.list(p_he[i])
    end -- for
    set.ss("H")
    selection.DeselectAll()
    for i = 1, #p_sh do
        selection.list(p_sh[i])
    end -- for
    set.ss("E")
    predict.combine()
    bStructureChanged = true
    QuickSave(saveSlotOverall)
end

local function _combine()
    for i = 1, iSegmentCount - 1 do
        check.struct()
        selection.DeselectAll()
        if ss[i] == "L" then
            if aa[i] ~= "p" then
                for ii = 1, #he - 1 do
                    if bPredictingCombine then
                        for iii = he[ii][1], he[ii][#he[ii]] do
                            if iii + 1 == i and he[ii + 1][1] == i + 1 then
                                selection.segs(i)
                            end -- if iii
                        end -- for iii
                    end -- if b_pre
                end
                for ii = 1, #he do
                    if bPredictingAddPrefferedSegments then
                        for iii = he[ii][1] - 1, he[ii][#he[ii]] + 1, he[ii][#he[ii]] - he[ii][1] + 1 do
                            if iii > 0 and iii <= iSegmentCount then
                                if amino.preffered(iii) == "H" then
                                    selection.segs(iii)
                                end -- if iii
                            end -- if iii
                        end -- for iii
                    end -- if b_pre
                end -- for ii
                set.ss("H")
                selection.DeselectAll()
            end -- if aa
            if bPredictingCombine then
                for ii = 1, #sh - 1 do
                    for iii = sh[ii][1], sh[ii][#sh[ii]] do
                        if iii + 1 == i and sh[ii + 1][1] == i + 1 then
                            selection.segs(i)
                        end -- if iii
                    end -- for iii
                end -- for ii
            end -- if b_pre
            if bPredictingAddPrefferedSegments then
                for ii = 1, #sh do
                    for iii = sh[ii][1] - 1, sh[ii][#sh[ii]] + 1, sh[ii][#sh[ii]] - sh[ii][1] + 1 do
                        if iii > 0 and iii <= iSegmentCount then
                            if amino.preffered(iii) == "E" then
                                selection.segs(iii)
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
                selection.segs(workingSegmentLeft, workingSegmentRight)
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
                selection.segs(workingSegmentLeft, workingSegmentRight)
                bSpheredFuzing = true
                work.dist()
                bands.delete()
                bSpheredFuzing = false
            end
        end -- for i
    end -- if bCurlingSheet
    saveSlot.release(str_re_best)
    QuickSave(saveSlotOverall)
end

function struct_rebuild()
    local str_rs
    local str_rs2
    str_re_best = saveSlot.request()
    check.struct()
    p("Found " .. #he .. " Helixes " .. #sh .. " Sheets and " .. #lo .. " Loops")
    if bStructuredRebuildHelix then
        selection.DeselectAll()
        for i = 1, #sh do
            selection.list(sh[i])
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
            selection.DeselectAll()
            selection.SelectRange(workingSegmentLeft, workingSegmentRight)
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
                QuickLoad(str_re_best)
                bSpheredFuzing = false
            end -- if bStructuredRebuildFuze
            str_sc = nil
            str_rs = nil
        end -- for i
        selection.DeselectAll()
        for i = 1, #sh do
            selection.list(sh[i])
        end -- for i
        set.ss("E")
    end -- if bStructuredRebuildHelix
    if bStructuredRebuildSheet then
        selection.DeselectAll()
        for i = 1, #he do
            selection.list(he[i])
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
            selection.DeselectAll()
            selection.SelectRange(workingSegmentLeft, workingSegmentRight)
            set.clashImportance(0.1)
            wiggle.selectedBackbone(1)
            set.clashImportance(0.4)
            wiggle.selectedBackbone(1)
            bands.delete()
            if bStructuredRebuildFuze then
                bSpheredFuzing = true
                fuze.start(str_re_best)
                QuickLoad(str_re_best)
                bSpheredFuzing = false
            end -- if bStructuredRebuildFuze
        end -- for i
        selection.DeselectAll()
        for i = 1, #he do
            selection.list(he[i])
        end -- for i
        set.ss("H")
        bonding.comp_sheet()
    end -- if bStructuredRebuildSheet
    QuickSave(saveSlotOverall)
    saveSlot.release(str_re_best)
end

--#Mutate function
function mutate()
    sl_mut = saveSlot.request()
    bMutating = true
    local i
    local ii
    check.distances()
    local i_will_be = #mutable
    for i = i_will_be, 1, -1 do
        p("Mutating segment " .. mutable[i])
        QuickSave(saveSlotOverall)
        sc_mut = get.score()
        local ii
        for ii = 1, #amino.segs do
            mutate2(i, ii)
            get.progress(i_will_be, 1, -1, i, 1, #amino.segs, 1, ii)
        end
        QuickLoad(saveSlotOverall)
    end
    bMutating = false
    saveSlot.release(sl_mut)
end

function mutate2(mut, aa, more)
    report.start("Mutating Work")
    local i
    selection.segs(mutable[mut])
    set.aa(amino.segs[aa])
    QuickSave(sl_mut)
    check.aa()
    p(#amino.segs - aa .. " Mutations left")
    p("Mutating segment " .. mutable[mut] .. " to " .. amino.long(mutable[mut]))
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
        if not snap.tweak(mutable[mut]) then
            bSpheredFuzing = true
            fuze.start(sl_mut)
            bSpheredFuzing = false
        end
    end
    if not bSurroundMutatingCurrently and bMutateSurroundingAfter then
        sl_temp_mut = saveSlot.request()
        QuickSave(sl_temp_mut)
    end
    if not more then
        if check.increase(report.stop(), saveSlotOverall) then
        end
    end
    if not bSurroundMutatingCurrently and bMutateSurroundingAfter then
        QuickLoad(sl_temp_mut)
        saveSlot.release(sl_temp_mut)
        report.start("Surrounding mutating")
        bSurroundMutatingCurrently = true
        selection.list(mutable)
        selection.Deselect(mutable[mut])
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
                    selection.Deselect(mutable[i])
                end
            end
        end
        set.clashImportance(fClashingForMutating)
        structure.MutateSidechainsSelected(2)
        local result = math.abs(report.stop())
        if result > 0.01 then
            while result > 0.01 do
                report.start("Mutate while score changes")
                structure.MutateSidechainsSelected(1)
                result = math.abs(report.stop())
            end
            return mutate2(mut, aa, more)
        end
    end
    if not more then
        if check.increase(report.stop(), saveSlotOverall) then
        end
    end
    if bSurroundMutatingCurrently and bMutateSurroundingAfter then
        bSurroundMutatingCurrently = false
    end
end -- function
--Mutate#

--#Snapping
local function _run()
    bTweaking = true
    bSpheredFuzing = true
    report.start("Snap")
    --[[sl_snaps = saveSlot.request()
    cs = get.score()
    c_snap = cs
    local s_1
    local s_2
    local c_s
    local c_s2
    QuickSave(sl_snaps)]]
    snap.tweak(workingSegmentLeft)
    check.increase(report.stop(), saveSlotOverall)
    --[[iii = get.snapcount(workingSegmentLeft)
    p("Snapcount: " .. iii .. " - segment " .. workingSegmentLeft)
    if iii > 1 then
        snapwork = saveSlot.request()
        ii = 1
        while ii <= iii do
            QuickLoad(sl_snaps)
            c_s = get.score()
            c_s2 = c_s
            do_.snap(workingSegmentLeft, ii)
            c_s2 = get.score()
            QuickSave(snapwork)
            selection.segs(true, workingSegmentLeft)
            fuze.start(snapwork)
            if c_snap < get.score() then
                c_snap = get.score()
                QuickSave(sl_snaps)
            end
            ii = ii + 1
        end
        QuickLoad(snapwork)
        saveSlot.release(snapwork)
        if cs < c_snap then
            QuickSave(sl_snaps)
            c_snap = get.score()
        else
            QuickLoad(sl_snaps)
        end
    else
        p("Skipping...")
    end
    if cs < get.score() then
    QuickLoad(sl_snaps)
    else
    QuickSave(sl_snaps)
    cs = get.score()
    end]]
    bSpheredFuzing = false
    bTweaking = false
    --saveSlot.release(sl_snaps)
    --[[if mutated then
        s_snap = get.score()
        if s_mut < s_snap then
            QuickSave(saveSlotOverall)
        else
            QuickLoad(sl_mut)
        end
    else
        QuickSave(saveSlotOverall)
    end]]--
end

function _near(segment)
    if(get.score() < g_total_score-1000) then
        selection.Deselect(segment)
        work.step("s", 1, 0.75, 0)
        work.step("ws", 1, 0)
        selection.Select(segment)
        set.clashImportance(1)
    end
    if(get.score() < g_total_score-1000) then
        return false
    end
    return true
end

local function _tweak(tweak_seg)
    if tweak_seg == nil then
        tweak_seg = tWorkingMiddleSegs[1]
    end
    score.recent.save()
    if aa[tweak_seg] ~= "a" or aa[tweak_seg] ~= "g" then
        bool = true
        bTweaking = true
        sl_reset = saveSlot.request()
        QuickSave(sl_reset)
        selection.DeselectAll()
        selection.segs(false,tweak_seg)
        local ss = get.score()
        g_total_score = get.score()
        if work.step("s", 2, 0, 0) then
            p("AT: Sidechain tweak")
            sl_tweak_work = saveSlot.request()
            QuickSave(sl_tweak_work)
            selection.segs(true, tweak_seg)
            if snap.near(tweak_seg) then
                sl_tweak = saveSlot.request()
                fuze.start(sl_tweak)
                saveSlot.release(sl_tweak)
            end
            if ss < get.score() then
                QuickSave(sl_reset)
                selection.DeselectAll()
                selection.segs(false,tweak_seg)
                local ss = get.score()
                g_total_score = get.score()
                work.step("s", 2, 0, 0)
                QuickSave(sl_tweak_work)
            else
                QuickLoad(sl_tweak_work)
            end
            selection.DeselectAll()
            selection.segs(tweak_seg)
            local ss=get.score()
            g_total_score = get.score()
            if get.score() > g_total_score - 30 then
                p("AT: Sidechain tweak around")
                selection.segs(true, tweak_seg)
                selection.Deselect(tweak_seg)
                work.step("s", 1, 0.1, 0)
                selection.Select(tweak_seg)
                if snap.near(i) then
                    sl_tweak = saveSlot.request()
                    fuze.start(sl_tweak)
                    saveSlot.release(sl_tweak)
                end
                if ss > get.score() then
                    QuickLoad(sl_reset)
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
--Snapping#

snap =
{
    run     = _run,
    tweak   = _tweak,
    near    = _near
}

--#Rebuilding
function rebuild(tweaking_seg)
    bSpheredFuzing = true
    sl_re = saveSlot.request()
    QuickSave(sl_re)
    selection.segs(workingSegmentLeft, workingSegmentRight)
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
            QuickLoad(sl_re)
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
        else
            sl_r[ii] = saveSlot.request()
            QuickSave(sl_r[ii])
        end
    end
    set.clashImportance(1)
    local slot
    if bMutating then
        slot = sl_mut
    else
        slot = saveSlotOverall
    end
    for ii = 1, #sl_r do
        QuickLoad(sl_r[ii])
        report.start("Rebuild" .. ii)
        saveSlot.release(sl_r[ii])
        QuickSave(sl_re)
        if rs_1 ~= get.score() then
            rs_1 = get.score()
            if rs_1 ~= rs_0 then
                p("Stabilize try "..ii)
                fuze.start(sl_re)
                rs_2 = get.score()
                if (fMaxScore - rs_2 ) < 30 then
                    if bRebuildTweakWholeRebuild or bRebuildWorst or bRebuildLoops or bRebuildWalking then
                        for i = workingSegmentLeft, workingSegmentRight do
                            snap.tweak(i)
                        end
                    else
                        snap.tweak(tweaking_seg)
                    end
                end
                if rs_2 > get.score() then
                    QuickLoad(sl_re)
                end
                if check.increase(report.stop(), slot) then
                    rs_0 = get.score()
                end
            else
                report.stop()
            end
        else
            report.stop()
        end
    end
    report.stop()
    QuickLoad(slot)
    sl_r = nil
    saveSlot.release(sl_re)
    bSpheredFuzing = false
end -- function
--Rebuilding#

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
    QuickSave(saveSlotOverall)
    check.ss()
    check.ligand()
    check.aa()
    check.mutable()
    save.SaveSecondaryStructure()
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
            selection.segs(workingSegmentLeft, workingSegmentRight)
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
                snap.run()
            end -- if isSnappingEnabled
            local ii
            for ii = iStartingWalk, iEndWalk do
                if i + ii > iSegmentCount then
                    break
                end -- if workingSegmentRight
                set.segs(i,i + ii)
                if isRebuildingEnabled then
                    if bRebuildWalking then
                        selection.segs()
                        set.ss("L")
                        rebuild()
                    end -- if bRebuildWalking
                elseif isLocalWiggleEnabled then
                    p(workingSegmentLeft .. "-" .. workingSegmentRight)
                    work.flow("wla")
                    work.flow("wlb")
                    work.flow("wla")
                    work.flow("wlb")
                end -- if isLocalWiggleEnabled
                get.progress(iStartSegment, iEndSegment, 1, i, iStartingWalk, iEndWalk, 1, ii)
            end -- for ii
        end -- for i
    end -- if (isRebuildingEnabled
    QuickLoad(saveSlotOverall)
    save.LoadSecondaryStructure()
    saveSlot.release(saveSlotOverall)
    p("+++ overall gain +++")
    p("+++" .. report.stop() .. "+++")
end

function showConfigDialog()
    local primaryDialog = dialog.CreateDialog("Darkknights All-in-One-Recipe v"..iVersion)
    primaryDialog.bLws = dialog.AddButton("lws", 1)
    primaryDialog.bRebuild = dialog.AddButton("rebuild", 2)
    primaryDialog.bBonding = dialog.AddButton("compress", 3)
    primaryDialog.bStructuredRebuild = dialog.AddButton("structure rebuild", 4)
    primaryDialog.bCurler = dialog.AddButton("curler", 5)
    primaryDialog.bSnap = dialog.AddButton("sidechain", 6)
    primaryDialog.bFuze = dialog.AddButton("fuze", 7)
    primaryDialog.bMutate = dialog.AddButton("mutate", 8)
    primaryDialog.bPredict = dialog.AddButton("predict", 9)
    primaryDialog.generalSettings = dialog.AddLabel("General Settings:")
    primaryDialog.iTimeSecsBetweenReportsTooltip = dialog.AddLabel("")
    primaryDialog.iTimeSecsBetweenReports = dialog.AddSlider([[Seconds between
a report:]], iTimeSecsBetweenReports, 1, 600, 0)
    if bIsExploringPuzzle then
        primaryDialog.explore = dialog.AddLabel([[Use the Energy Score
or the Exploration Score?]])
        primaryDialog.useExploreMultiplier = dialog.AddCheckbox("Use Exploration Score", bExploringWork)
    end
    primaryDialog.addOpt = dialog.AddLabel("What to do:")
    primaryDialog.cancel = dialog.AddButton("Cancel", 0)
    local result = dialog.Show(primaryDialog)
    if result > 0 then
        local secondaryDialog
        iTimeSecsBetweenReports = primaryDialog.iTimeSecsBetweenReports.value
        if result == 1 or result == 2 then
            if result == 1 then
                isLocalWiggleEnabled = true
                secondaryDialog = dialog.CreateDialog("Local Wiggle Settings")
                secondaryDialog.scoreChangeTooltip = dialog.AddLabel("Local Wiggle tries to get this score then it will save the score and rewiggle")
                secondaryDialog.fScoreMustChange = dialog.AddSlider("Score change", fScoreMustChange, 0, 1, 4)
            else
                isRebuildingEnabled = true
                secondaryDialog = dialog.CreateDialog("Rebuilding Settings")
                secondaryDialog.iRebuildTrys = dialog.AddSlider("Trys", iRebuildTrys, 1, 20, 0)
                secondaryDialog.iRebuildsTillSave = dialog.AddSlider([[Rebuilds call till
rebuild will be chosen:]], iRebuildsTillSave, 1, 10, 0)
                secondaryDialog.iRebuildStrength = dialog.AddSlider("Rebuild iteration:", iRebuildStrength, 1, 10, 0)
                secondaryDialog.iRebuildTrysTooltip = dialog.AddLabel("Select a rebuilding mode:")
                secondaryDialog.bRebuildLoops = dialog.AddCheckbox("Rebuild Loops", bRebuildLoops)
                secondaryDialog.bRebuildWorst = dialog.AddCheckbox("Worst Rebuild", bRebuildWorst)
                secondaryDialog.iWorstSegmentLength = dialog.AddSlider("Worst Length", iWorstSegmentLength, 1, 20, 0)
                secondaryDialog.bRebuildWalking = dialog.AddCheckbox("Walking Rebuilder", bRebuildWalking)
                secondaryDialog.bRebuildWalkingTooltip = dialog.AddLabel("Only for Walking Rebuilder:")
            end
            secondaryDialog.iStartSegment = dialog.AddSlider("Start Segment", iStartSegment, 1, iSegmentCount, 0)
            secondaryDialog.iEndSegment = dialog.AddSlider("End Segment", iEndSegment, 1, iSegmentCount, 0)
            secondaryDialog.walkTooltip = dialog.AddLabel("Walking from Segment + walking start to Segment + walking end")
            secondaryDialog.iStartingWalk = dialog.AddSlider("Walking Start", iStartingWalk, 0, iSegmentCount, 0)
            secondaryDialog.iEndWalk = dialog.AddSlider("Walking End", iEndWalk, 0, iSegmentCount, 0)
            secondaryDialog.dummy1 = dialog.AddButton("", 0)
            secondaryDialog.dummy2 = dialog.AddButton("", 0)
            secondaryDialog.dummy3 = dialog.AddButton("", 0)
            secondaryDialog.start = dialog.AddButton("Start", result)
            secondaryDialog.back = dialog.AddButton("Back", 0)
            secondaryDialog.dummy5 = dialog.AddButton("", 0)
            secondaryDialog.dummy6 = dialog.AddButton("", 0)
            secondaryDialog.dummy7 = dialog.AddButton("", 0)
        elseif result == 3 then
            isCompressingEnabled = true
            secondaryDialog = dialog.CreateDialog("Compressing Settings")
            secondaryDialog.iCompressingTrys = dialog.AddSlider([[How often should
the compressing
be tried]], 1, 1, iSegmentCount, 0)
            secondaryDialog.fCompressingLoss = dialog.AddSlider([[Score loss till
accepting work
in %]], 1, 0.1, 100, 1)
            secondaryDialog.fCompressingBondingPercentage = dialog.AddSlider("Bonding percentage", fCompressingBondingPercentage, 0.01, 100, 2)
            secondaryDialog.iCompressingBondingLength = dialog.AddSlider("Band length", iCompressingBondingLength, 0, 20, 2)
            secondaryDialog.bCompressingConsiderStructure = dialog.AddCheckbox("Do not band same structure within itself", bCompressingConsiderStructure)
            secondaryDialog.bCompressingSoftBonding = dialog.AddCheckbox("Create 'softer' bands normalizing the bands reducing the force of them", bCompressingSoftBonding)
            secondaryDialog.bCompressingFuze = dialog.AddCheckbox("Do a fuze after the work is done (if not ticked it will just wiggle)", bCompressingFuze)
            secondaryDialog.bCompressingSoloBonding = dialog.AddCheckbox("Use every single band created for working", bCompressingSoloBonding)
            secondaryDialog.bCompressingLocalBonding = dialog.AddCheckbox("Iterate through segments generate work for every single segment! [Alpha]", bCompressingLocalBonding)
            secondaryDialog.bCompressingFixxedBonding = dialog.AddCheckbox("Fixxed Work [ALPHA]", bCompressingFixxedBonding)
            secondaryDialog.iCompressingFixxedStartSegment = dialog.AddSlider("Fixxed start", iCompressingFixxedStartSegment, 1, iSegmentCount, 0)
            secondaryDialog.iCompressingFixxedEndSegment = dialog.AddSlider("Fixxed end", iCompressingFixxedEndSegment, 1, iSegmentCount, 0)
            secondaryDialog.methodTooltip = dialog.AddLabel("Which methods: ")
            secondaryDialog.bCompressingPredictedBonding = dialog.AddCheckbox("Bonding between segments with predicted 'friendly' amino acids", bCompressingPredictedBonding)
            secondaryDialog.bCompressingPredictedLocalBonding = dialog.AddCheckbox("Every single segment will get bonded with predicted bands", bCompressingPredictedLocalBonding)
            secondaryDialog.bCompressingPull = dialog.AddCheckbox("Bonding between hydrophobic segments (Pull)", bCompressingPull)
            secondaryDialog.bCompressingPushPull = dialog.AddCheckbox("Bonding between both hydrophilic and hydrophobic segments in one (Push & Pull)", bCompressingPushPull)
            secondaryDialog.bCompressingCenterPull = dialog.AddCheckbox("Bonding between hydrophobic segments and the centersegment (Pull)", bCompressingCenterPull)
            secondaryDialog.bCompressingCenterPushPull = dialog.AddCheckbox("Bonding between both hydrophilic and hydrophobic segments and the centersegment in one (Push & Pull)", bCompressingCenterPushPull)
            secondaryDialog.bCompressingEvolutionBonding = dialog.AddCheckbox("Random bands", bCompressingEvolutionBonding)
            secondaryDialog.bCompressingEvolutionOnlyBetter = dialog.AddCheckbox("Save just gains else it will just evo through and save if there is a score gain accidently", bCompressingEvolutionOnlyBetter)
            secondaryDialog.iCompressingEvolutionRounds = dialog.AddSlider("How many rounds", iCompressingEvolutionRounds, 1, 100, 0)
            secondaryDialog.dummy1 = dialog.AddButton("", 0)
            secondaryDialog.dummy2 = dialog.AddButton("", 0)
            secondaryDialog.dummy3 = dialog.AddButton("", 0)
            secondaryDialog.dummy4 = dialog.AddButton("", 0)
            secondaryDialog.dummy5 = dialog.AddButton("", 0)
            secondaryDialog.dummy6 = dialog.AddButton("", 0)
            secondaryDialog.start = dialog.AddButton("Start", result)
            secondaryDialog.back = dialog.AddButton("Back", 0)
            secondaryDialog.dummy7 = dialog.AddButton("", 0)
            secondaryDialog.dummy8 = dialog.AddButton("", 0)
            secondaryDialog.dummy9 = dialog.AddButton("", 0)
            secondaryDialog.dummy10 = dialog.AddButton("", 0)
            secondaryDialog.dummy11 = dialog.AddButton("", 0)
            secondaryDialog.dummy12 = dialog.AddButton("", 0)
        elseif result == 4 then
            isStructureRebuildEnabled = true
            secondaryDialog = dialog.CreateDialog("Structure Rebuilder Settings")
            secondaryDialog.bStructuredRebuildHelix = dialog.AddCheckbox("Rebuild Helices", bStructuredRebuildHelix)
            secondaryDialog.bStructuredRebuildSheet = dialog.AddCheckbox("Rebuild Sheets", bStructuredRebuildSheet)
            secondaryDialog.bStructuredRebuildFuze = dialog.AddCheckbox("Fuze after rebuild", bStructuredRebuildSheet)
            secondaryDialog.iStructuredRebuildTillSave = dialog.AddSlider([[Rebuild calls till
rebuild will be chosen:]], iStructuredRebuildTillSave, 1, 10, 0)
            secondaryDialog.iStructuredRebuildStrength = dialog.AddSlider("Rebuild iteration:", iStructuredRebuildStrength, 1, 10, 0)
            secondaryDialog.start = dialog.AddButton("Start", result)
            secondaryDialog.back = dialog.AddButton("Back", 0)
        elseif result == 5 then
            isCurlingEnabled = true
            secondaryDialog = dialog.CreateDialog("Structure Curler Settings")
            secondaryDialog.bCurlingHelix = dialog.AddCheckbox("Curl Helices", bCurlingHelix)
            secondaryDialog.bCurlingSheet = dialog.AddCheckbox("Curl Sheets", bCurlingSheet)
            secondaryDialog.start = dialog.AddButton("Start", result)
            secondaryDialog.back = dialog.AddButton("Back", 0)
        elseif result == 6 then
            isSnappingEnabled = true
            secondaryDialog = dialog.CreateDialog("Snapping Settings")
            secondaryDialog.snapSettings = dialog.AddLabel("No Settings available")
            secondaryDialog.start = dialog.AddButton("Start", result)
            secondaryDialog.back = dialog.AddButton("Back", 0)
        elseif result == 7 then
            isFuzingEnabled = true
            secondaryDialog = dialog.CreateDialog("Fuzing Settings")
            secondaryDialog.bFuzingBlueFuze = dialog.AddCheckbox("Blue fuse (if not ticked then Pink fuse)", bFuzingBlueFuze)
            secondaryDialog.start = dialog.AddButton("Start", result)
            secondaryDialog.back = dialog.AddButton("Back", 0)
        elseif result == 8 then
            isMutatingEnabled = true
            secondaryDialog = dialog.CreateDialog("Mutating Settings")
            secondaryDialog.bOptimizeSidechain = dialog.AddCheckbox("Optimize Sideshains", bOptimizeSidechain)
            secondaryDialog.bRebuildAfterMutating = dialog.AddCheckbox("Rebuild after each mutation", bRebuildAfterMutating)
            secondaryDialog.bRebuildInMutatingIgnoreStructures = dialog.AddCheckbox("ignore structures while rebuilding", bRebuildInMutatingIgnoreStructures)
            secondaryDialog.bRebuildInMutatingDeepRebuild = dialog.AddCheckbox("Try different rebuild lengths", bRebuildInMutatingDeepRebuild)
            secondaryDialog.bRebuildTweakWholeRebuild = dialog.AddCheckbox("Tweak every segment after rebuild else just the mutating one will be tweaked", bRebuildTweakWholeRebuild)
            secondaryDialog.bMutateSurroundingAfter = dialog.AddCheckbox("Try mutating surround Segments after first work [ALPHA]", bMutateSurroundingAfter)
            secondaryDialog.fClashingForMutating = dialog.AddSlider("Clash importance for mutating:", fClashingForMutating, 0, 1, 2)
            secondaryDialog.dummy3 = dialog.AddButton("", 0)
            secondaryDialog.dummy4 = dialog.AddButton("", 0)
            secondaryDialog.dummy5 = dialog.AddButton("", 0)
            secondaryDialog.dummy6 = dialog.AddButton("", 0)
            secondaryDialog.start = dialog.AddButton("Start", result)
            secondaryDialog.back = dialog.AddButton("Back", 0)
            secondaryDialog.dummy7 = dialog.AddButton("", 0)
            secondaryDialog.dummy8 = dialog.AddButton("", 0)
            secondaryDialog.dummy9 = dialog.AddButton("", 0)
            secondaryDialog.dummy10 = dialog.AddButton("", 0)
        elseif result == 9 then
            isPredictingEnabled = true
            secondaryDialog = dialog.CreateDialog("Predicting Settings")
            secondaryDialog.bPredictingFull = dialog.AddCheckbox("Predict structure for every single seg (less loops)", bPredictingFull)
            secondaryDialog.bPredictingAddPrefferedSegments = dialog.AddCheckbox("Add preffered amino acids after predicting to start and end of structures", bPredictingAddPrefferedSegments)
            secondaryDialog.bPredictingCombine = dialog.AddCheckbox("Combine predicted structures if possible", bPredictingCombine)
            secondaryDialog.bPredictingOtherMethod = dialog.AddCheckbox("Try different method", bPredictingOtherMethod)
            secondaryDialog.dummy3 = dialog.AddButton("", 0)
            secondaryDialog.dummy4 = dialog.AddButton("", 0)
            secondaryDialog.dummy5 = dialog.AddButton("", 0)
            secondaryDialog.dummy6 = dialog.AddButton("", 0)
            secondaryDialog.start = dialog.AddButton("Start", result)
            secondaryDialog.back = dialog.AddButton("Back", 0)
            secondaryDialog.dummy7 = dialog.AddButton("", 0)
            secondaryDialog.dummy8 = dialog.AddButton("", 0)
            secondaryDialog.dummy9 = dialog.AddButton("", 0)
            secondaryDialog.dummy10 = dialog.AddButton("", 0)
        else
            p("Unknown dialog option. Something is wrong here...")
        end
        if bIsExploringPuzzle and primaryDialog.useExploreMultiplier.value then
                bExploringWork = true
        end
        result = dialog.Show(secondaryDialog)
        if result > 0 then
            if result == 1 or result == 2 then
                if result == 1 then
                    fScoreMustChange = secondaryDialog.fScoreMustChange.value
                elseif result == 2 then
                    iRebuildTrys = secondaryDialog.iRebuildTrys.value
                    bRebuildWorst = secondaryDialog.bRebuildWorst.value
                    iWorstSegmentLength = secondaryDialog.iWorstSegmentLength.value
                    bRebuildLoops = secondaryDialog.bRebuildLoops.value
                    iRebuildsTillSave = secondaryDialog.iRebuildsTillSave.value
                    iRebuildStrength = secondaryDialog.iRebuildStrength.value
                    bRebuildWalking = secondaryDialog.bRebuildWalking.value
                end
                iStartSegment = secondaryDialog.iStartSegment.value
                iEndSegment = secondaryDialog.iEndSegment.value
                iStartingWalk = secondaryDialog.iStartingWalk.value
                iEndWalk = secondaryDialog.iEndWalk.value
            elseif result == 3 then
                iCompressingTrys = secondaryDialog.iCompressingTrys.value
                fCompressingLoss = secondaryDialog.fCompressingLoss.value
                fCompressingBondingPercentage = secondaryDialog.fCompressingBondingPercentage.value
                iCompressingBondingLength = secondaryDialog.iCompressingBondingLength.value
                bCompressingConsiderStructure = secondaryDialog.bCompressingConsiderStructure.value
                bCompressingSoftBonding = secondaryDialog.bCompressingSoftBonding.value
                bCompressingFuze = secondaryDialog.bCompressingFuze.value
                bCompressingSoloBonding = secondaryDialog.bCompressingSoloBonding.value
                bCompressingLocalBonding = secondaryDialog.bCompressingLocalBonding.value
                bCompressingFixxedBonding = secondaryDialog.bCompressingFixxedBonding.value
                iCompressingFixxedStartSegment = secondaryDialog.iCompressingFixxedStartSegment.value
                iCompressingFixxedEndSegment = secondaryDialog.iCompressingFixxedEndSegment.value
                bCompressingPredictedBonding = secondaryDialog.bCompressingPredictedBonding.value
                bCompressingPredictedLocalBonding = secondaryDialog.bCompressingPredictedLocalBonding.value
                bCompressingPull = secondaryDialog.bCompressingPull.value
                bCompressingPushPull = secondaryDialog.bCompressingPushPull.value
                bCompressingCenterPull = secondaryDialog.bCompressingCenterPull.value
                bCompressingCenterPushPull = secondaryDialog.bCompressingCenterPushPull.value
                bCompressingEvolutionBonding = secondaryDialog.bCompressingEvolutionBonding.value
                bCompressingEvolutionOnlyBetter = secondaryDialog.bCompressingEvolutionOnlyBetter.value
                iCompressingEvolutionRounds = secondaryDialog.iCompressingEvolutionRounds.value
            elseif result == 4 then
                bStructuredRebuildHelix = secondaryDialog.bStructuredRebuildHelix.value
                bStructuredRebuildSheet = secondaryDialog.bStructuredRebuildSheet.value
                bStructuredRebuildFuze = secondaryDialog.bStructuredRebuildFuze.value
                iStructuredRebuildTillSave = secondaryDialog.iStructuredRebuildTillSave.value
                iStructuredRebuildStrength = secondaryDialog.iStructuredRebuildStrength.value
            elseif result == 5 then
                bCurlingHelix = secondaryDialog.bCurlingHelix.value
                bCurlingSheet = secondaryDialog.bCurlingSheet.value
            elseif resutl == 6 then
            elseif result == 7 then
                bFuzingBlueFuze = secondaryDialog.bFuzingBlueFuze.value
            elseif result == 8 then
                bOptimizeSidechain = secondaryDialog.bOptimizeSidechain.value
                bRebuildAfterMutating = secondaryDialog.bRebuildAfterMutating.value
                bRebuildInMutatingIgnoreStructures = secondaryDialog.bRebuildInMutatingIgnoreStructures.value
                bRebuildInMutatingDeepRebuild = secondaryDialog.bRebuildInMutatingDeepRebuild.value
                bRebuildTweakWholeRebuild = secondaryDialog.bRebuildTweakWholeRebuild.value
                bMutateSurroundingAfter = secondaryDialog.bMutateSurroundingAfter.value
                fClashingForMutating = secondaryDialog.fClashingForMutating.value
            elseif result == 9 then
                bPredictingFull = secondaryDialog.bPredictingFull.value
                bPredictingAddPrefferedSegments = secondaryDialog.bPredictingAddPrefferedSegments.value
                bPredictingCombine = secondaryDialog.bPredictingCombine.value
                bPredictingOtherMethod = secondaryDialog.bPredictingOtherMethod.value
            else
                p("Unknown dialog option. Something is wrong here...")
            end
            run()
        else
            isLocalWiggleEnabled, isRebuildingEnabled, isCompressingEnabled, isStructureRebuildEnabled, isCurlingEnabled, isSnappingEnabled, isFuzingEnabled, isMutatingEnabled, isPredictingEnabled = false, false, false, false, false, false, false, false, false
            return showConfigDialog()
        end
    else
        print("Dialog cancelled")
    end
end

if not bDontUseDialog then
    showConfigDialog()
else
    run()
end

--[[old/unused function
if b_test then
    scoie=0
    for ii=1,70 do
        behavior.SetWiggleAccuracy(ii*0.1)
        p("Wiggle: " .. behavior.GetWiggleAccuracy())
        for iii=1,4 do
            reset.puzzle()
            QuickSave(saveSlotOverall)
            behavior.SetShakeAccuracy(iii)
            p("Shake: " .. behavior.GetShakeAccuracy())
            fuze.start(overall)
            QuickLoad(saveSlotOverall)
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


]]