	*! version 1.0.0, Francisco Ceron, 23Sept2024
	*! version 1.0.1, Francisco Ceron, 15Aug2025
	
	*! ehutchens: extended hutchens 'square root' segregation index (additively decomposable), with supergroup option, stored matrices, save new dataset and bootstrap options
	*! This is an extension of -hutchens-, version 1.0.0,  Stephen Jenkins, 17aug2005.


	
	
/// ehutchens program: extended hutchens 'square root' segregation index (additively decomposable), with supergroup, stored matrices, save new dataset and bootstrap options	
			
				program define ehutchens, rclass 
					version 15.1
					syntax varlist(min=2 max=2) [fw aw/] [if] [in] [, ///
					   Missing Format(passthru) BYgroup(varname)  SUpergroup(varname) Save(string) Clear] [Bootstrap Reps(integer 400) SEed(integer 12345) CLuster(varname)]

		
		************************************************************************
		
		*** Option supergroup with dynamic results construction 
			
		  if "`supergroup'" != "" {
				
				matrix Z = J(1, 12, .)  

				levelsof `supergroup', local(supergroups)
				
				
				foreach group of local supergroups {
					di "Processing supergroup: `group'"
					
					preserve  

					qui keep	 if `supergroup' == `group' 

					
					tokenize `varlist'

			
					if "`missing'" != "" {
							if "`bygroup'" == "" {
									di as err "cannot specify missing option without bygroup option"
									exit 198
							}
							marksample touse
							markout `touse', strok
					}
					else {
							marksample touse  
							markout `touse' `bygroup', strok
					}

			
					qui count if `touse' 
					if r(N) == 0 { 
							di as error "no valid observations"
							error 2000
					}

			
					capt assert `2'==0 | `2'==1 if `touse'
					if _rc {
							di as err "groupvar not 0/1"
							exit 198
					}

			
				 if "`exp'" == "" {
					local exp "`touse'"
					}
				else {
		
				capture confirm variable `exp'
					if _rc {
        
					local exp "`touse'"
					}
				}

			********************************************************************
				
					
					if ("`save'" != "" & "`bootstrap'" != "") {
					display as 9error "Save and Bootstrap options cannot be combined."
					exit 198
					}
		
					local reps = cond("`reps'" == "", 400, `reps')
					local seed = cond("`seed'" == "", 12345, `seed')
		
		
			********* Aggregate index ******************************************

					sort `touse' `1'

					tempvar cell0 cell1 iid
					qui by `touse' `1': gen byte `iid' = _n==_N & `touse'
					qui by `touse' `1': gen `cell0' = sum(`exp'*(1-`2')) if `touse'
					qui by `touse' `1': replace `cell0' = `cell0'[_N] if `touse'
					qui by `touse' `1': gen `cell1' = sum(`exp'*`2') if `touse'
					qui by `touse' `1': replace `cell1' = `cell1'[_N] if `touse'

					tempvar col0 col1 id Ncat Nobs
					qui by `touse' : gen byte `id' = _n==_N & `touse'
					qui by `touse' : gen `col0' = sum(`exp'*(1-`2')) if `touse'
					qui by `touse' : replace `col0' = `col0'[_N] if `touse'
					qui by `touse' : gen `col1' = sum(`exp'*`2') if `touse'
					qui by `touse' : replace `col1' = `col1'[_N] if `touse'
					qui by `touse' : gen `Ncat' = sum(`iid') if `touse'
					qui by `touse' : replace `Ncat' = `Ncat'[_N] if `touse'
					if "`weight'"=="fweight" {
							qui gen `Nobs' = `col0' + `col1' if `touse'
					}
					else {
							qui by `touse' : gen `Nobs' = _N if `touse'
					}

					tempvar sum2 s3 S
					qui gen `sum2' = sqrt( (`cell0'/`col0') * (`cell1'/`col1') )
					qui gen `s3' = .

					qui by `touse' : gen `S' = sum(`sum2') if `iid'
					qui by `touse' : replace `S' = 1 - `S'[_N] if `iid'
					qui by `touse' : replace `s3' = 100*( `col1' / (`col0' + `col1') ) if `iid'


					lab var `Ncat' "# units"
					lab var `Nobs' "# obs (raw)"
					lab var `S' "S"
					lab var `s3' "% `2'=1"

					local labl: var l `2'
					if `"`labl'"'=="" local labl "`2'"
					tempvar touse2
					ge byte `touse2' = `touse'
					lab var `touse2' `"`labl'"'
					qui tostring `touse2', replace
					qui replace `touse2' = "0/1"

					noi di " "
					noi di as txt "Hutchens 'square root' segregation index (S)"
					noi di as txt _dup(44) "_"
					noi di " "
					noi di as txt "Social unit var: " as res "`1'" as txt ". Segregation (social group) var: " as res "`2'" as txt"."
					noi di " "
					noi di as txt "Aggregate statistics"
					
					tabdisp `touse2' if `id', cell(`S' `s3' `Ncat' `Nobs') `format'  // only 5 vars allowed in cell()

					qui su `S', meanonly    
					local SS =  r(mean)
					
					
			******* Decomposition: (a) subgroup index values, by subgroup ******

		if "`bygroup'" != "" {

			
						sort `touse' `bygroup' `1'

						tempvar gcell0 gcell1 giid
						qui by `touse' `bygroup' `1': gen byte `giid' = _n==_N & `touse'
						qui by `touse' `bygroup' `1': gen `gcell0' = sum(`exp'*(1-`2')) if `touse'
						qui by `touse' `bygroup' `1': replace `gcell0' = `gcell0'[_N] if `touse'
						qui by `touse' `bygroup' `1': gen `gcell1' = sum(`exp'*`2') if `touse'
						qui by `touse' `bygroup' `1': replace `gcell1' = `gcell1'[_N] if `touse'

						tempvar gcol0 gcol1 gid gNcat gNobs gNpc
						qui by `touse' `bygroup': gen byte `gid' = _n==_N & `touse'
						qui by `touse' `bygroup': gen `gcol0' = sum(`exp'*(1-`2')) if `touse'
						qui by `touse' `bygroup': replace `gcol0' = `gcol0'[_N] if `touse'
						qui by `touse' `bygroup': gen `gcol1' = sum(`exp'*`2') if `touse'
						qui by `touse' `bygroup': replace `gcol1' = `gcol1'[_N] if `touse'
						qui by `touse' `bygroup': gen `gNcat' = sum(`giid') if `touse'
						qui by `touse' `bygroup': replace `gNcat' = `gNcat'[_N] if `touse'
						if "`weight'"=="fweight" {
								qui gen `gNobs' = `gcol0' + `gcol1' if `touse'
						}
						else {
								qui by `touse' `bygroup': gen `gNobs' = _N if `touse'
						}
						qui by `touse' `bygroup': gen `gNpc' = 100*(`gcol0' + `gcol1')/(`col0' + `col1') if `touse'


						tempvar gsum2 gs3 gS gw scont
						qui gen `gsum2' = sqrt( (`gcell0'/`gcol0') * (`gcell1'/`gcol1') )
						qui gen `gs3' = .
						qui gen `gw' = sqrt( (`gcol0'/`col0') * (`gcol1'/`col1') )
						qui gen `scont' = (`gcell1'/`col1') - sqrt( (`gcell0'/`col0')*(`gcell1'/`col1')  )


						qui by `touse' `bygroup' : gen `gS' = sum(`gsum2') if `giid'
						qui by `touse' `bygroup' : replace `gS' = 1 - `gS'[_N] if `giid'
						qui by `touse' `bygroup' : replace `gs3' = 100*( `gcol1' / (`gcol0' + `gcol1') ) if `giid'
						qui by `touse' `bygroup' : replace `scont' = sum(`scont') if `giid'
						qui by `touse' `bygroup' : replace `scont' = `scont'[_N]  if `giid'

			
					 su `bygroup', meanonly
						local min = r(min)
						local max = r(max)


						matrix BG = J( `max' - `min' + 1,1, .)
						matrix SG = J( `max' - `min' + 1,1, .)
						matrix SS = J( `max' - `min' + 1,1, .)
						matrix S =  J( `max' - `min' + 1,1, .)
						matrix W =  J( `max' - `min' + 1,1, .)
						matrix P =  J( `max' - `min' + 1,1, .)
						matrix X =  J( `max' - `min' + 1,1, .)
						matrix C =  J( `max' - `min' + 1,1, .)
						
						forvalues i = `min'/`max' {
						qui summ `bygroup' if `bygroup' == `i'
						matrix BG[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `supergroup' if `bygroup' == `i'
						matrix SG[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `gS' if `bygroup' == `i' 
						matrix S[ `i' - `min' + 1,1] = r(mean)

						qui summ `gw' if `bygroup' == `i'
						matrix W[ `i' - `min' + 1,1] = r(mean)

						qui summ `gs3' if `bygroup' == `i'
						matrix P[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `gNpc' if `bygroup' == `i'
						matrix X[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `scont' if `bygroup' == `i' & `giid'
						matrix C[ `i' - `min' + 1,1] = r(max) 

						
						qui summ `S' if `bygroup'==`i'   
						matrix SS[ `i' - `min' + 1,1] = r(mean)
						
						
		}


			lab var `gNcat' "# units"
			lab var `gNobs' "# obs (raw)"
			lab var `gS' "S"
			lab var `gw' "Weight"           
			lab var `gs3' "% `2'=1"
			lab var `scont' "Contribution"
			lab var `gNpc' "% obs (wgted)"

			noi di " "
			noi di as txt "Statistics for each subgroup defined by " as res "`bygroup'"
			
			tabdisp `bygroup' if `gid', cell(`gs3' `gNcat' `gNobs' `gNpc') `format'
			tabdisp `bygroup' if `gid', cell(`gS' `gw' `scont') `format'

			
			******* Decomposition: (b) within- and betweeen-group breakdown  *********

							tempvar SW SB 
							qui ge `SW' = sum( `gw' * `gS') if `gid'
							qui replace `SW' = `SW'[_N]  if `gid'
							qui ge `SB' = sum( `gw' ) if `gid'
							qui replace `SB' = 1 - `SB'[_N] if `gid' 

							su `SW', meanonly
							local SW = r(mean)
							su `SB', meanonly
							local SB = r(mean)
							local SWpc = 100*`SW'/ `SS'
							local SBpc = 100*`SB'/ `SS' 

							noi di " "
							tempvar decomp
							qui ge byte `decomp' = 0 in 1
							qui replace `decomp' = 1 in 2
							lab var `decomp' "Decomposition"
							local dlabel declabel
							capture lab drop l____
							lab def l____  0 "Within-group segregation" 1 "Between-group segregation"
							lab val `decomp' l____
							tempvar ds dspc
							qui ge `ds' = `SW' if `decomp' == 0
							qui replace `ds' = `SB' if `decomp' == 1
							qui ge `dspc' = `SWpc' if `decomp' == 0
							qui replace `dspc' = `SBpc' if `decomp' == 1
							lab var `ds' "Value"
							lab var `dspc' "As percent"

							tabdisp `decomp' if `decomp' < 2, cell(`ds' `dspc') `format'
							noi di " "

						
							tempvar SW_ SB_ SWpc_ SBpc_	
						
							qui ge `SW_' = sum( `gw' * `gS') if `gid'
							qui replace `SW_' = `SW_'[_N]  if `gid'
							qui ge `SB_' = sum( `gw' ) if `gid'
							qui replace `SB_' = 1 - `SB_'[_N] if `gid' 
							qui ge `SWpc_' = 100*`SW_'/ `SS' if `gid'
							qui replace `SWpc_' = `SWpc_'[_N] if `gid'
							qui ge `SBpc_' = 100*`SB_'/ `SS' if `gid'
							qui replace `SBpc_' = `SBpc_'[_N] if `gid'
							
		
				  su `bygroup', meanonly
						local min = r(min)
						local max = r(max)
 
						
						matrix SW = J( `max' - `min' + 1,1, .)
						matrix SB = J( `max' - `min' + 1,1, .)
						matrix SWP = J( `max' - `min' + 1,1, .)
						matrix SBP = J( `max' - `min' + 1,1, .)

			 
			 forvalues i= `r(min)'/`r(max)' {    
						
						qui summ `SW_' if `bygroup'==`i'   
						matrix SW[ `i' - `min' + 1,1] = r(mean)
		   
						qui summ `SB_' if `bygroup'==`i' 
						matrix SB[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `SWpc_' if `bygroup'==`i' 
						matrix SWP[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `SBpc_' if `bygroup'==`i' 
						matrix SBP[ `i' - `min' + 1,1] = r(mean)
						
						}
								
				matrix  Y = SG, BG, SS, S,  W, C, P, X,  SW, SB, SWP, SBP
				matrix coln Y = SG BG S local_S weight contrib soc_g_% demo_%  SW SB SW_% SB_%
				
							
				}
					
					matrix Y_`group' = Y
					
					matrix Z = Z \ Y_`group'
					
					matrix drop Y_`group' 
					
					restore  
			
				}
				
				
				matrix drop Y SS SG BG S W P X C SW SB SWP SBP
				matrix coln Z =SG BG S local_S weight contrib soc_g_% demo_%  SW SB SW_% SB_%
				
				matrix Z = Z[2..., .]
				
			********************************************************************	
		
			if "`save'" != "" {
			
			
				if "`clear'" != "clear" {
				preserve
				}
				
				
				svmat Z
				
				local colnames "SG BG S local_S weight contrib soc_group_pct demo_pct  SW SB SW_pct SB_pct"  

				forvalues i = 1/12 {
				local name : word `i' of `colnames'
				rename Z`i' `name'
				}
				
			   keep SG BG S local_S weight contrib soc_group_pct demo_pct  SW SB SW_pct SB_pct
			   
			   order SG BG S local_S weight contrib soc_group_pct demo_pct  SW SB SW_pct SB_pct
			   
			   
			   save "`save'", replace
				
				if "`clear'" == "clear" {
				use "`save'", clear
				} 
				else {
				
				restore
				}
			}
			 
			return matrix M = Z
			
			********************************************************************		
			
			
			 if "`bootstrap'" != "" {
			 
				di "Running bootstrap with reps(`reps'), seed(`seed'), cluster(`cluster')"
        
				
				count
				matrix Z = J(1, 10, .) 
				
				levelsof `supergroup', local(supergroups)
        
				foreach group of local supergroups {
				
				preserve  
				
				di "Processing supergroup (bootstrap): `group'"
				qui keep if `supergroup' == `group'
				count
				****************************************************************
				
				local weight_option ""
				if "`exp'" != "" & "`weight'" != "" {
				local weight_option "[`weight'=`exp']"
				}

				
				local bygroup_option ""
				if "`bygroup'" != "" {
				local bygroup_option "bygroup(`bygroup')"
				}

				
				local missing_option ""
				if "`missing'" != "" {
				local missing_option "missing"
				}
				
				*****************************************************************
				
						qui summ `supergroup' 
						matrix SG`group' = r(mean)
	
				****************************************************************
				
				bootstrap r(S) r(SW) r(SB)  , reps(`reps') seed(`seed') cluster(`cluster') nowarn force: hu_int `varlist' `weight_option' `missing_option', `bygroup_option'
				
				
				estat bootstrap, all
				matrix A`group' = e(b)
				matrix B`group' = e(ci_bc)
				matrix Y`group' = J(1, 9, .)
				matrix Y`group' = SG`group', A`group'[1,1], B`group'[1,1], B`group'[2,1], A`group'[1,2], B`group'[1,2], B`group'[2,2], A`group'[1,3], B`group'[1,3], B`group'[2,3]
				
				
				matrix Z = Z \ Y`group'
				
				
				
				restore  
				
				matrix drop  A`group'  B`group'  Y`group' SG`group'
				
				
				}
				
				matrix Z = Z[2..., .]
				
				matrix coln Z =SG S S_ll S_ul SW SW_ll SW_ul SB SB_ll SB_ul
				
				return matrix M_B = Z
				
				}
				
			************************************************************************
			
			}
			
			************************************************************************
			************************************************************************
			************************************************************************
			************************************************************************
			
			
			else {
						
					tokenize `varlist'

			
					if "`missing'" != "" {
							if "`bygroup'" == "" {
									di as err "cannot specify missing option without bygroup option"
									exit 198
							}
							marksample touse
							markout `touse', strok
					}
					else {
							marksample touse  
							markout `touse' `bygroup', strok
					}

			
					qui count if `touse' 
					if r(N) == 0 { 
							di as error "no valid observations"
							error 2000
					}

			
					capt assert `2'==0 | `2'==1 if `touse'
					if _rc {
							di as err "groupvar not 0/1"
							exit 198
					}

			
					 if "`exp'" == "" {
					local exp "`touse'"
					}
				else {
		
				capture confirm variable `exp'
					if _rc {
        
					local exp "`touse'"
					}
				}


			******************** Aggregate index *******************************

			
					sort `touse' `1'

			
					tempvar cell0 cell1 iid
					qui by `touse' `1': gen byte `iid' = _n==_N & `touse'
					qui by `touse' `1': gen `cell0' = sum(`exp'*(1-`2')) if `touse'
					qui by `touse' `1': replace `cell0' = `cell0'[_N] if `touse'
					qui by `touse' `1': gen `cell1' = sum(`exp'*`2') if `touse'
					qui by `touse' `1': replace `cell1' = `cell1'[_N] if `touse'

			
					tempvar col0 col1 id Ncat Nobs
					qui by `touse' : gen byte `id' = _n==_N & `touse'
					qui by `touse' : gen `col0' = sum(`exp'*(1-`2')) if `touse'
					qui by `touse' : replace `col0' = `col0'[_N] if `touse'
					qui by `touse' : gen `col1' = sum(`exp'*`2') if `touse'
					qui by `touse' : replace `col1' = `col1'[_N] if `touse'
					qui by `touse' : gen `Ncat' = sum(`iid') if `touse'
					qui by `touse' : replace `Ncat' = `Ncat'[_N] if `touse'
					if "`weight'"=="fweight" {
							qui gen `Nobs' = `col0' + `col1' if `touse'
					}
					else {
							qui by `touse' : gen `Nobs' = _N if `touse'
					}


					tempvar sum2 s3 S
					qui gen `sum2' = sqrt( (`cell0'/`col0') * (`cell1'/`col1') )
					qui gen `s3' = .

					qui by `touse' : gen `S' = sum(`sum2') if `iid'
					qui by `touse' : replace `S' = 1 - `S'[_N] if `iid'
					qui by `touse' : replace `s3' = 100*( `col1' / (`col0' + `col1') ) if `iid'

					lab var `Ncat' "# units"
					lab var `Nobs' "# obs (raw)"
					lab var `S' "S"
					lab var `s3' "% `2'=1"

					local labl: var l `2'
					if `"`labl'"'=="" local labl "`2'"
					tempvar touse2
					ge byte `touse2' = `touse'
					lab var `touse2' `"`labl'"'
					qui tostring `touse2', replace
					qui replace `touse2' = "0/1"

					noi di " "
					noi di as txt "Hutchens 'square root' segregation index (S)"
					noi di as txt _dup(44) "_"
					noi di " "
					noi di as txt "Social unit var: " as res "`1'" as txt ". Segregation (social group) var: " as res "`2'" as txt"."
					noi di " "
					noi di as txt "Aggregate statistics"
					
					tabdisp `touse2' if `id', cell(`S' `s3' `Ncat' `Nobs') `format'  

					qui su `S', meanonly    
					local SS =  r(mean)


			******* Decomposition: (a) subgroup index values, by subgroup ******

		if "`bygroup'" != "" {

						sort `touse' `bygroup' `1'

						tempvar gcell0 gcell1 giid
						qui by `touse' `bygroup' `1': gen byte `giid' = _n==_N & `touse'
						qui by `touse' `bygroup' `1': gen `gcell0' = sum(`exp'*(1-`2')) if `touse'
						qui by `touse' `bygroup' `1': replace `gcell0' = `gcell0'[_N] if `touse'
						qui by `touse' `bygroup' `1': gen `gcell1' = sum(`exp'*`2') if `touse'
						qui by `touse' `bygroup' `1': replace `gcell1' = `gcell1'[_N] if `touse'

						tempvar gcol0 gcol1 gid gNcat gNobs gNpc
						qui by `touse' `bygroup': gen byte `gid' = _n==_N & `touse'
						qui by `touse' `bygroup': gen `gcol0' = sum(`exp'*(1-`2')) if `touse'
						qui by `touse' `bygroup': replace `gcol0' = `gcol0'[_N] if `touse'
						qui by `touse' `bygroup': gen `gcol1' = sum(`exp'*`2') if `touse'
						qui by `touse' `bygroup': replace `gcol1' = `gcol1'[_N] if `touse'
						qui by `touse' `bygroup': gen `gNcat' = sum(`giid') if `touse'
						qui by `touse' `bygroup': replace `gNcat' = `gNcat'[_N] if `touse'
						if "`weight'"=="fweight" {
								qui gen `gNobs' = `gcol0' + `gcol1' if `touse'
						}
						else {
								qui by `touse' `bygroup': gen `gNobs' = _N if `touse'
						}
						qui by `touse' `bygroup': gen `gNpc' = 100*(`gcol0' + `gcol1')/(`col0' + `col1') if `touse'


						tempvar gsum2 gs3 gS gw scont
						qui gen `gsum2' = sqrt( (`gcell0'/`gcol0') * (`gcell1'/`gcol1') )
						qui gen `gs3' = .
						qui gen `gw' = sqrt( (`gcol0'/`col0') * (`gcol1'/`col1') )
						qui gen `scont' = (`gcell1'/`col1') - sqrt( (`gcell0'/`col0')*(`gcell1'/`col1')  )


						qui by `touse' `bygroup' : gen `gS' = sum(`gsum2') if `giid'
						qui by `touse' `bygroup' : replace `gS' = 1 - `gS'[_N] if `giid'
						qui by `touse' `bygroup' : replace `gs3' = 100*( `gcol1' / (`gcol0' + `gcol1') ) if `giid'
						qui by `touse' `bygroup' : replace `scont' = sum(`scont') if `giid'
						qui by `touse' `bygroup' : replace `scont' = `scont'[_N]  if `giid'
	
				
					 su `bygroup', meanonly
						local min = r(min)
						local max = r(max)

						matrix BG = J( `max' - `min' + 1,1, .)
						matrix SS = J( `max' - `min' + 1,1, .)
						matrix S =  J( `max' - `min' + 1,1, .)
						matrix W =  J( `max' - `min' + 1,1, .)
						matrix P =  J( `max' - `min' + 1,1, .)
						matrix X =  J( `max' - `min' + 1,1, .)
						matrix C =  J( `max' - `min' + 1,1, .)
						

						forvalues i = `min'/`max' {
						
						qui summ `bygroup' if `bygroup' == `i'
						matrix BG[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `gS' if `bygroup' == `i' 
						matrix S[ `i' - `min' + 1,1] = r(mean)

						qui summ `gw' if `bygroup' == `i'
						matrix W[ `i' - `min' + 1,1] = r(mean)

						qui summ `gs3' if `bygroup' == `i'
						matrix P[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `gNpc' if `bygroup' == `i'
						matrix X[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `scont' if `bygroup' == `i' & `giid'  
						matrix C[ `i' - `min' + 1,1] = r(max)
					
						
						qui summ `S' if `bygroup'==`i'   
						matrix SS[ `i' - `min' + 1,1] = r(mean)		
						
		}		

			
			lab var `gNcat' "# units"
			lab var `gNobs' "# obs (raw)"
			lab var `gS' "S"
			lab var `gw' "Weight"           
			lab var `gs3' "% `2'=1"
			lab var `scont' "Contribution"
			lab var `gNpc' "% obs (wgted)"

			noi di " "
			noi di as txt "Statistics for each subgroup defined by " as res "`bygroup'"
			
			tabdisp `bygroup' if `gid', cell(`gs3' `gNcat' `gNobs' `gNpc') `format'
			tabdisp `bygroup' if `gid', cell(`gS' `gw' `scont') `format'

	
			******* Decomposition: (b) within- and betweeen-group breakdown*****

							tempvar SW SB 
							qui ge `SW' = sum( `gw' * `gS') if `gid'
							qui replace `SW' = `SW'[_N]  if `gid'
							qui ge `SB' = sum( `gw' ) if `gid'
							qui replace `SB' = 1 - `SB'[_N] if `gid' 

							su `SW', meanonly
							local SW = r(mean)
							su `SB', meanonly
							local SB = r(mean)
							local SWpc = 100*`SW'/ `SS'
							local SBpc = 100*`SB'/ `SS' 

							noi di " "
							tempvar decomp
							qui ge byte `decomp' = 0 in 1
							qui replace `decomp' = 1 in 2
							lab var `decomp' "Decomposition"
							local dlabel declabel
							capture lab drop l____
							lab def l____  0 "Within-group segregation" 1 "Between-group segregation"
							lab val `decomp' l____
							tempvar ds dspc
							qui ge `ds' = `SW' if `decomp' == 0
							qui replace `ds' = `SB' if `decomp' == 1
							qui ge `dspc' = `SWpc' if `decomp' == 0
							qui replace `dspc' = `SBpc' if `decomp' == 1
							lab var `ds' "Value"
							lab var `dspc' "As percent"

							tabdisp `decomp' if `decomp' < 2, cell(`ds' `dspc') `format'
							noi di " "

						
							tempvar SW_ SB_ SWpc_ SBpc_	
						
							qui ge `SW_' = sum( `gw' * `gS') if `gid'
							qui replace `SW_' = `SW_'[_N]  if `gid'
							qui ge `SB_' = sum( `gw' ) if `gid'
							qui replace `SB_' = 1 - `SB_'[_N] if `gid' 
							qui ge `SWpc_' = 100*`SW_'/ `SS' if `gid'
							qui replace `SWpc_' = `SWpc_'[_N] if `gid'
							qui ge `SBpc_' = 100*`SB_'/ `SS' if `gid'
							qui replace `SBpc_' = `SBpc_'[_N] if `gid'
							
				
				  su `bygroup', meanonly
						local min = r(min)
						local max = r(max)
						
						matrix SW = J( `max' - `min' + 1,1, .)
						matrix SB = J( `max' - `min' + 1,1, .)
						matrix SWP = J( `max' - `min' + 1,1, .)
						matrix SBP = J( `max' - `min' + 1,1, .)
						
			 
			 forvalues i= `r(min)'/`r(max)' {    		
		   
						qui summ `SW_' if `bygroup'==`i'   
						matrix SW[ `i' - `min' + 1,1] = r(mean)
		   
						qui summ `SB_' if `bygroup'==`i' 
						matrix SB[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `SWpc_' if `bygroup'==`i' 
						matrix SWP[ `i' - `min' + 1,1] = r(mean)
						
						qui summ `SBpc_' if `bygroup'==`i' 
						matrix SBP[ `i' - `min' + 1,1] = r(mean)
						
						}
						
				matrix  Z = BG, SS, S,  W, C, P, X,  SW, SB, SWP, SBP
				matrix coln Z = BG S local_S  weight contrib soc_g_% demo_% SW SB SW_% SB_%
			
			********************************************************************	
				
			
			if "`save'" != "" {
			
			
			
				if "`clear'" != "clear" {
				preserve
				}
				
			
				
				svmat Z
				
				local colnames " BG  S local_S weight contrib soc_group_pct demo_pct  SW SB SW_pct SB_pct"

				
			
				forvalues i = 1/11 {
				local name : word `i' of `colnames'
				rename Z`i' `name'
				}
				
			   keep S BG local_S weight soc_group_pct demo_pct contrib SW SB SW_pct SB_pct
			   
			   order BG S local_S weight contrib  soc_group_pct demo_pct SW SB SW_pct SB_pct
			   sort BG
			   
			   
				save "`save'", replace
				

				if "`clear'" == "clear" {
				use "`save'", clear
				} 
				else {
			
				restore
				}
			 }
		
			
			return matrix M = Z
		

			matrix drop SS BG S W P X C SW SB SWP SBP
			}
		
		}


		end
