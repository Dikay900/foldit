p("Compressing Segment ",seg)
sphere={}
range=0
repeat
count=0
range=range+2
sphere=fsl.GetSphere(seg,range)
for n=1,#sphere-1 do
if sphere[n]>seg+range/4 and sphere[n]+1~=sphere[n+1] or sphere[n]<seg-range/4 and sphere[n]+1~=sphere[n+1] then
count=count+1
end
end
until count>4
for n=1,#sphere-1 do
if sphere[n]>seg+range/4 and sphere[n]+1~=sphere[n+1] or sphere[n]<seg-range/4 and sphere[n]+1~=sphere[n+1] then
band_add_segment_segment(seg,sphere[n])
local length=get_segment_distance(seg,sphere[n])
repeat
length=length*7/8
until length<=5
band_set_length(get_band_count(),length)
band_set_strength(get_band_count(),length/5)
end
end
do_global_wiggle_backbone(1)
band_delete()
else
p("Compressing Segment ",seg,"-",r)
sphere1={}
sphere2={}
range=0
end