--#Game vars
Version     = "3"
numsegs     = get_segment_count()
--Game vars#

amino           = {
                 -- {seg, short, longname,          hydro,      -scale, pref,   mol,        pl      }
                    {'a', 'Ala', 'Alanine',         "phobic",   -1.6,   "H",    89.09404,   6.01    },
                    {'c', 'Cys', 'Cysteine',        "phobic",   -17,    "E",    121.15404,  5.05    },
                    {'d', 'Asp', 'Aspartic acid',   "philic",   6.7,    "L",    133.10384,  2.85    },
                    {'e', 'Glu', 'Glutamic acid',   "philic",   8.1,    "H",    147.13074,  3.15    },
                    {'f', 'Phe', 'Phenylalanine',   "phobic",   -6.3,   "E",    165.19184,  5.49    },
                    {'g', 'Gly', 'Glycine',         "phobic",   1.7,    "L",    75.06714,   6.06    },
                    {'h', 'His', 'Histidine',       "philic",   -5.6,   nil,    155.15634,  7.60    },
                    {'i', 'Ile', 'Isoleucine',      "phobic",   -2.4,   "E",    131.17464,  6.05    },
                    {'k', 'Lys', 'Lysine',          "philic",   6.5,    "H",    146.18934,  9.60    },
                    {'l', 'Leu', 'Leucine',         "phobic",   1,      "H",    131.17464,  6.01    },
                    {'m', 'Met', 'Methionine',      "phobic",   3.4,    "H",    149.20784,  5.74    },
                    {'n', 'Asn', 'Asparagine',      "philic",   8.9,    "L",    132.11904,  5.41    },
                    {'p', 'Pro', 'Proline',         "phobic",   -0.2,   "L",    115.13194,  6.30    },
                    {'q', 'Gln', 'Glutamine',       "philic",   9.7,    "H",    146.14594,  5.65    },
                    {'r', 'Arg', 'Arginine',        "philic",   9.8,    "H",    174.20274,  10.76   },
                    {'s', 'Ser', 'Serine',          "philic",   3.7,    "L",    105.09344,  5.68    },
                    {'t', 'Thr', 'Threonine',       "philic",   2.7,    "E",    119.12034,  5.60    },
                    {'v', 'Val', 'Valine',          "phobic",   -2.9,   "E",    117.14784,  6.00    },
                    {'w', 'Trp', 'Tryptophan',      "phobic",   -9.1,   "E",    204.22844,  5.89    },
                    {'y', 'Tyr', 'Tyrosine',        "phobic",   -5.1,   "E",    181.19124,  5.64    },
              --[[  {'b', 'Asx', 'Asparagine or Aspartic acid'},
                    {'j', 'Xle', 'Leucine or Isoleucine'},
                    {'o', 'Pyl', 'Pyrrolysine'},
                    {'u', 'Sec', 'Selenocysteine'},
                    {'x', 'Xaa', 'Unspecified or unknown amino acid'},
                    {'z', 'Glx', 'Glutamine or glutamic acid'}
                ]]}

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
    local s
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

check.hydro()
check.aa()
check.ligand()

--#predictss
function predict_ss()
    local p_he = {}
    p_sh = {}
    local p_lo = {}
    local helix
    local sheet
    local loop
    local i = 1
    while i < numsegs - 2 do
        loop = false
        if hydro[i] then
            if hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if not helix then
                    helix = true
                    p_he[#p_he + 1] = {}
                end
            elseif not hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] then
                if not sheet then
                    sheet = true
                    p_sh[#p_sh + 1] = {}
                end
            else
                p_lo[#p_lo + 1] = {}
                loop = true
            end
        elseif not hydro[i] then
            if hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and hydro[i + 2] and hydro[i + 3] then
                if not helix then
                    helix = true
                    p_he[#p_he + 1] = {}
                end
            elseif hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if not sheet then
                    sheet = true
                    p_sh[#p_sh + 1] = {}
                end
            else
                if not sheet and not helix then
                    p_lo[#p_lo + 1] = {}
                end
                loop = true
            end
        end
        if helix then
            p_he[#p_he][#p_he[#p_he] + 1] = i
            if loop or sheet then
                helix = false
                p_he[#p_he][#p_he[#p_he] + 1] = i + 1
                p_he[#p_he][#p_he[#p_he] + 1] = i + 2
                i = i + 2
            end
        elseif sheet then
            p_sh[#p_sh][#p_sh[#p_sh] + 1] = i
            if loop then
                sheet = false
                p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 1
                p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 2
                i = i + 2
            end
        else
            p_lo[#p_lo][#p_lo[#p_lo] + 1] = i
        end
        i = i + 1
    end
    p("Found ", #p_he, " Helix ", #p_sh, " Sheet and ", #p_lo, " Loop parts... Combining...")
    select_all()
    replace_ss("L")
    deselect_all()
    for i = 1, #p_he do
        for ii = p_he[i][1], p_he[i][#p_he[i]] do
            select_index(ii)
        end
    end
    replace_ss("H")
    deselect_all()
    for i = 1, #p_sh do
        for ii = p_sh[i][1], p_sh[i][#p_sh[i]] do
            select_index(ii)
        end
    end
    replace_ss("E")
    quicksave(10)
    quicksave(1)
end
--predictss#

predict_ss()