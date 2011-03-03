numsegs=get_segment_count()
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

function bandmaxdist() --by Rav3n_pl based on Tlaloc`s
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

	for x=1, numsegs - 2 do
        if not hydro[x] then
            for y = x + 2, numsegs do
                if (not hydro[y]) and (math.random() <= 0.003) then
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
end

function push()
    distances={}
	distances=getdistances()
    for x=1, numsegs - 2 do
        if not hydro[x] then
            for y = x + 2, numsegs do
                if (not hydro[y]) and (math.random() <= ((numsegs/(get_band_count()+1))*0.01)) then
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

function fgain()
    set_behavior_clash_importance(1)
    repeat
        local iter = 0
        repeat
            iter = iter + 1
            local s1 = get_score(true)
            do_global_wiggle_all(iter)
            local s2 = get_score(true)
        until s2 - s1 < 0.01
        local s3 = get_score(true)
        do_shake(1)
        local s4 = get_score(true)
    until s4 - s3 < 0.001
end

function floss(option, cl1, cl2)
    print("Fuzing Method ", option)
    if option == 1 then
        print("Pink Fuse cl1-s-cl2-wa: cl1 ", cl1, ", cl2 ", cl2)
        set_behavior_clash_importance(cl1)
        do_shake(1)
        set_behavior_clash_importance(cl2)
        do_global_wiggle_all(1)
    elseif option == 2 then
        print("Pink Fuse cl1-wa-cl=1-wa-cl2-wa: cl1 ", cl1, ", cl2 ", cl2)
        set_behavior_clash_importance(cl1)
        do_global_wiggle_all(1)
        set_behavior_clash_importance(1)
        do_global_wiggle_all(1)
        set_behavior_clash_importance(cl2)
        do_global_wiggle_all(1)
    elseif option == 3 then
        print("cl1-s; cl2-s;: cl1 ", cl1, ", cl2 ", cl2)
        set_behavior_clash_importance(cl1)
        do_shake(1)
        fgain()
        set_behavior_clash_importance(cl2)
        do_shake(1)
    elseif option == 4 then
        print("cl1-wa[-cl2-wa]: cl1 ", cl1, "[, cl2 ", cl2, "]")
        set_behavior_clash_importance(cl1)
        do_global_wiggle_all(1)
        set_behavior_clash_importance(cl2)
        do_global_wiggle_all(1)
    elseif option == 5 then
        print("qStab cl1-s-cl2-wa-cl=1-s: cl1 ", cl1, ", cl2 ", cl2)
        set_behavior_clash_importance(cl1)
        do_shake(1)
        set_behavior_clash_importance(cl2)
        do_global_wiggle_all(1)
        set_behavior_clash_importance(1)
        do_shake(1)
    end
end

function s_fuze(option, cl1, cl2)
    local s1 = get_score(true)
    floss(option, cl1, cl2)
    fgain()
    local s2 = get_score(true)
    if s2 > s1 then
        reset_recent_best()
        print("+", s2 - s1)
    end
    restore_recent_best()
end

function fuze(sl)
    select_all()
    reset_recent_best()
    s_fuze(1, 0.1, 0.7)
    s_fuze(1, 0.3, 0.6)
    s_fuze(2, 0.5, 0.7)
    s_fuze(2, 0.7, 0.5)
    s_fuze(3, 0.05, 0.07)
    s_fuze(4, 0.3, 0.3)
    s_fuze(5, 0.1, 0.4)
end

check_hydro()
for i=0,numsegs do
deselect_all()
bandmaxdist()
select_all()
set_behavior_clash_importance(0.7)
do_global_wiggle_backbone(1)
band_delete()
cs=get_score(true)
fuze()
sc2=get_score(true)
if cs<sc2 then reset_recent_best() end
set_behavior_clash_importance(0.01)
do_shake(1)
_CreateHydrophobeBands()
set_behavior_clash_importance(0.5)
do_global_wiggle_backbone(1)
band_delete()
cs=get_score(true)
fuze()
sc2=get_score(true)
if cs<sc2 then reset_recent_best() end
set_behavior_clash_importance(0.01)
do_shake(1)
push()
set_behavior_clash_importance(0.5)
do_global_wiggle_backbone(1)
band_delete()
cs=get_score(true)
fuze()
sc2=get_score(true)
if cs<sc2 then reset_recent_best() end
CreateBandsToCenter()
set_behavior_clash_importance(0.5)
do_global_wiggle_backbone(1)
band_delete()
cs=get_score(true)
fuze()
sc2=get_score(true)
if cs<sc2 then reset_recent_best() end
deselect_all()
end