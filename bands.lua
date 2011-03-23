P=print
_numsegs=get_segment_count()
P(_numsegs)
i=1
select_all()
replace_ss("L")
deselect_all()
function Round(x)--cut all afer 3-rd place
	return x-x%1.
end
numsegs=Round(_numsegs/2)
P(numsegs)
while i<numsegs do
band_add_segment_segment(numsegs-i,numsegs+i)
band_set_strength(i,10)
band_set_length(i,0)
i=i+1
end
band_add_segment_segment(numsegs,_numsegs)
band_add_segment_segment(numsegs,1)
bands=get_band_count()
for i=bands-1,bands do
band_set_strength(i,10)
band_set_length(i,0)
end
band_add_segment_segment(numsegs/2,_numsegs)
band_add_segment_segment(numsegs+numsegs/2,_numsegs)
band_add_segment_segment(numsegs/2,1)
band_add_segment_segment(numsegs+numsegs/2,1)
band_add_segment_segment(numsegs/4,numsegs+numsegs/4)
band_add_segment_segment(numsegs/4,numsegs-numsegs/4)
band_add_segment_segment(numsegs+numsegs*3/4,numsegs+numsegs/4)
band_add_segment_segment(numsegs+numsegs*3/4,numsegs-numsegs/4)
for i=bands+1,bands+8 do
band_set_strength(i,0.01)
band_set_length(i,20)
end
bands=get_band_count()
select_all()
do_global_wiggle_all(1)
do_shake(1)
for i=1,bands do
band_set_strength(i,5)
band_set_length(i,5)
end
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
for i=1,bands do
band_set_strength(i,2)
band_set_length(i,5)
end
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
for i=1,bands do
band_set_strength(i,1)
band_set_length(i,4)
end
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
for i=1,bands do
band_set_strength(i,0.01)
end
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)
band_delete()
do_global_wiggle_backbone(1)
do_shake(1)
do_global_wiggle_sidechains(1)