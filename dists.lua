numsegs=get_segment_count()
saveSlots   = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
p=print
maxiter=5
step = 0.01
gain = 2*step
--#Saveslot manager
function ReleaseSaveSlot(slot)
    saveSlots[#saveSlots + 1] = slot
end

function RequestSaveSlot()
    local saveSlot = saveSlots[#saveSlots]
    saveSlots[#saveSlots] = nil
    return saveSlot
end
--Saveslot manager#

function getdistances()
	distances={}
    for i=1,numsegs-1 do
		distances[i]={}
        for j=i+1,numsegs do
            distances[i][j]=get_segment_distance(i,j)
        end
    end
	return distances
end

function _CreateHydrophobeBands()
   for x=1, numsegs do
       if hydro[x] then
           for y=x+2, numsegs do
               if hydro[y] then
                   band_add_segment_segment(x, y)
				   local length=get_segment_distance(x,y)
				   repeat
				   length=length*3/4
				   until length<=20
				   band_set_length(get_band_count(),0)
				   band_set_strength(get_band_count(),length/15)
               end
           end
       end
   end
end

function check_hydro()
hydro={}
for i=1,numsegs do
hydro[i]=is_hydrophobic(i)
end
end

function bandmaxdist()
	distances={}
	distances=getdistances()
    local maxdistance=0
	for i=1,numsegs do
        for j=1,numsegs do
			if i~=j then
			    local x=i
				local y=j
				if x>y then x,y=y,x end
				if distances[x][y]>maxdistance then
				maxdistance=distances[x][y]
				maxx=i
				maxy=j
				end
			end
        end
    end
	band_add_segment_segment(maxx,maxy)
	repeat
	maxdistance=maxdistance*3/4
	until maxdistance<=20
	band_set_strength(get_band_count(),maxdistance/15)
	band_set_length(get_band_count(),maxdistance)
end

function push()
for x=1, numsegs - 2 do
        if not hydro[x] then
            for y = x + 2, numsegs do
                if (not hydro[y]) then
				maxdistance = distances[x][y]
                band_add_segment_segment(x, y)
				repeat
				maxdistance=maxdistance*3/4
				until maxdistance<=20
				local band = get_band_count()
				band_set_strength(band,maxdistance/15)
				band_set_length(band,maxdistance)
                end
            end
        end
    end
    distances={}
	distances=getdistances()
    for x=1, numsegs - 2 do
        if not hydro[x] then
            for y = x + 2, numsegs do
                if (not hydro[y])then
                    local distance = distances[x][y]
                    if  distance <= 15 then
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

function FastCenter() --by Rav3n_pl based on Tlaloc`s
	distances={}
	distances=getdistances()
    local minDistance = 100000.0
    local distance
    local indexCenter
	for i=1,numsegs do
        distance = 0
        for j=1,numsegs do
			if i~=j then
				local x=i
				local y=j
				if x>y then x,y=y,x end
				distance = distance + distances[x][y]
			end
        end
        if(distance < minDistance) then
             minDistance = distance
             indexCenter =  i
        end
    end
    return indexCenter
end

function CreateBandsToCenter()
   local indexCenter = FastCenter()
   for i=1,numsegs do
       if(i ~= indexCenter) then
           if hydro[i] then
               band_add_segment_segment(i,indexCenter)
           end
       end
   end
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
        p("Blue Fuse cl1-s; cl2-s;")
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

--#Ligand Check
if get_ss(numsegs) == 'M' then
    numsegs = numsegs - 1
end
--Ligand Check#

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

function s_fuze(option, cl1, cl2)
    local s1_f = get_score(true)
    floss(option, cl1, cl2)
    fgain()
    local s2_f = get_score(true)
    if s2_f > s1_f then
        if fastfuze then
            quicksave(sl_f[1])
        else
            sl_f[#sl_f + 1] = RequestSaveSlot()
            quicksave(sl_f[#sl_f])
        end
        p("+", s2_f - s1_f, "+")
    end
    quickload(sl_f[1])
end

function fuze(sl)
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
        local s_f = get_score()
        if not fastfuze then
            for i = 2, #sl_f do
                quickload(sl_f[i])
                s_f1 = get_score(true)
                if s_f1 > s_f then
                    quicksave(sl_f[1])
                    s_f = s_f1
                end
            end
        end
        quickload(sl_f[1])
                ReleaseSaveSlot(sl_f[i])
end
--Fuzing#

check_hydro()
overall=RequestSaveSlot()
for i=0,numsegs do
deselect_all()
bandmaxdist()
select_all()
set_behavior_clash_importance(0.7)
do_global_wiggle_backbone(1)
band_delete()
cs=get_score(true)
quicksave(overall)
fuze(overall)
sc2=get_score(true)
if cs<sc2 then quickload(overall) end
set_behavior_clash_importance(0.01)
do_shake(1)
CreateBandsToCenter()
set_behavior_clash_importance(0.5)
do_global_wiggle_backbone(1)
band_delete()
cs=get_score(true)
quicksave(overall)
fuze(overall)
sc2=get_score(true)
if cs<sc2 then quickload(overall) end
deselect_all()
end