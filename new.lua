local function _DCI( r,idx,idx2 ) -- disulfides

	-- test for ligand to prevent crash
	if ( is_ligand (idx,idx2) == false ) then

		local seg
		local seg2

		seg = get_aa (idx)
		seg2 = get_aa (idx2)

		-- disulfide linkages - cysteine/methionine/selenocysteine
		if ((( seg == 'c' ) or ( seg == 'm' ) or ( seg == 'u' )) and ( get_segment_score_part ( "disulfides",idx ) ~= 0 )) then

			r.num_disulfide_contacts = r.num_disulfide_contacts + 1

			if ((( seg2 == 'c' ) or ( seg2 == 'm' ) or ( seg2 == 'u' )) and ( get_segment_score_part ( "disulfides",idx2 ) ~= 0 )) then

				r.num_disulfide_contacts_made = r.num_disulfide_contacts_made + 1 -- (forming cystine)

			end

		elseif ((( seg2 == 'c' ) or ( seg2 == 'm' ) or ( seg2 == 'u' )) and ( get_segment_score_part ( "disulfides",idx2 ) ~= 0 )) then

			-- at this point, we know that only half the disulfide linkage was found
			r.num_disulfide_contacts = r.num_disulfide_contacts + 1

		end -- disulfide linkages 

	end -- test for ligand

	return r

end -- function _DCI

local function find_contacts ( r )

	local k
	local mindist

	k 	= r.k
	mindist 	= r.mindist

	-- locate contacts
	for j = 1,k do

		local b
		local seg
		local seg2

		b 	= 1e2
		seg 	= j
		seg2 	= 1

		for i = 1,k do

			local a

			a = get_segment_distance ( i,j )

			if ((a < b) and ((i > j + mindist) or (i < j - mindist))) then -- get shortest distance, but dont form contacts with self

				b = a
				seg2 = i

			end

		end

		if (r.contact_matrix [ seg ] ~= seg2) and (r.contact_matrix [ seg2 ] ~= seg) then -- no (L to R), (R to L) duplicate contacts

			-- include a distance bonus ?
			if ( math.abs ( b ) <= r.segment_distance ) then
			r.distance_bonus = r.distance_bonus + 1
			end

			-- note new contacts
			r.num_contacts = r.num_contacts + 1

			-- save location
			r.contact_matrix [ seg ] = seg2
			r.contact_matrix [ seg2 ] = seg

			if ( is_ligand ( seg,seg2 ) == false ) then

				local aa
				local aa2

				aa = get_aa ( seg )	
				aa2 = get_aa ( seg2 )

				-- score compatibility index terms
				r.max_hci = r.max_hci + calc.hci ( aa,aa2 ) 
				r.max_sci = r.max_sci + calc.sci ( aa,aa2 ) 
				r.max_cci = r.max_cci + calc.cci ( aa,aa2 ) 

				-- note disulfide linkages - cysteine/methionine/selenocysteine
				r = calc.dci ( r,seg,seg2 ) 

				-- show contacting segments ?
				if ( r.show_contacting_segments == true ) then
				band_add_segment_segment ( seg,seg2 ) 
				end

			end -- test for ligand

		end

	end -- for j = 1,k do

	if ( r.show_contacting_segments == true ) then
	band_disable () -- bands are for aesthetic purpose only. they indicate contacting segments
	end

	-- score packing terms
	r.max_packing = r.distance_bonus * r.theoretical_multiplier

	-- score disulfide linkages - cysteine/methionine/selenocysteine
	r.max_disulfides = r.num_disulfide_contacts_made * r.theoretical_multiplier 

	return r

end -- function find_contacts