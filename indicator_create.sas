
%macro create_and_merge_ind(_sample_cami);

	data _iter_ind_ds_ic_&_sample_cami. (drop = &_var_ic. );
		set &&_ds_&_sample_cami._ic. (keep = &cust_id. &_var_ic.);
		if &_var_ic. <= &_max0_ic. then &_var_woe_ic. = 0;
		else &_var_woe_ic. = 1;
	run;

	data &&_out_ds_&_sample_cami._ind_ic.;
		merge &&_out_ds_&_sample_cami._ind_ic. (in=a) _iter_ind_ds_ic_&_sample_cami. (in=b);
		by &cust_id.;
		if a and b;
	run;

%mend;

%macro indicator_create(
		_min_rr_diff_ic, 
		_ds_dev_ic, 
		_min_pp_diff_ic, 
		_ds_val_ic, 
		_logg_b_ic, 
		_var_ic, 
		_cnt_ic, 
		_ol_ds_ic, 
		_out_ds_dev_ind_ic, 
		_out_ds_val_ind_ic
	);

	data _base1_ic;
		set &_logg_b_ic. (keep = MIN MAX nbad ngood per_swt);
		bin_num + 1;
		cum_nbad + nbad;
		cum_ngood + ngood;
	run;

	proc sql noprint;
		select sum(nbad), sum(ngood), count(*) into :_tot_nbad_ic, :_tot_ngood_ic, :_tot_bins_ic from _base1_ic;
	quit;

	%if %sysevalf(&_tot_bins_ic. gt 2) %then %do;	

		data _base1_ic;
			set _base1_ic;
			cum_resp_r = cum_nbad/&_tot_nbad_ic.;
			cum_nonresp_r = cum_ngood/&_tot_ngood_ic.;
			ks = abs(cum_resp_r - cum_nonresp_r);
		run;

		proc sql noprint;
			select bin_num into :_max_ks_bin_ic from _base1_ic having ks = max(ks);
		quit;

		%let _var_woe_ic = %trim(&_var_ic.)_i;

		%if %sysevalf(%length(&_var_woe_ic) ge 32) %then %do;
			%let _var_woe_ic = var&_cnt_ic._i;
		%end;

		data _base1_ic;			
			set _base1_ic;
			if bin_num <= &_max_ks_bin_ic. then woe = 0;
			else woe = 1;			
		run;

		proc sql noprint;
			create table _base2_ic as
			select 
				(100.0*sum(nbad))/sum(sum(nbad), sum(ngood)) as mbad,
				min(min) as min, 
				max(max) as max,
				sum(nbad) as nbad,
				sum(ngood) as ngood,
				woe, 
				sum(per_swt) as per_swt
			from
				_base1_ic
			group by 
				woe;
		quit;

		data _base2_ic;
			/* format varname $32.; */
			set _base2_ic;
			ro_brk = -1*dif(MBAD) ;
			id1 = 1;
			/* varname = "&_var_woe_ic."; */
		run;

		proc sql noprint;
			select sum(case when ^missing(ro_brk) then ro_brk else 0 end), min(per_swt) into :_ro_brk_ic, :_min_per_swt_ic from _base2_ic;
		quit;

		%if %sysevalf(%sysfunc(abs(&_ro_brk_ic.)) gt %sysfunc(abs(&_min_rr_diff_ic.)) and &_min_per_swt_ic. gt &_min_pp_diff_ic.) %then %do;	

			proc sql noprint; 
				select max format best18. into: _max0_ic from _base2_ic where woe = 0; 
			quit;

			title "&_var_ic. : &_var_woe_ic";

			proc print data = _base2_ic; 
			var MBAD MIN MAX nbad ngood woe per_swt;
			run;

			data _base3_ic;
				format var_der $32.;
				format var_orig $32.;
				/* set _null_; */
				var_der = "&_var_woe_ic.";
				var_orig = "&_var_ic.";
				max0 = &_max0_ic.;
			run;



			data &_ol_ds_ic.;
				set &_ol_ds_ic. _base3_ic ;
			run; 

			%create_and_merge_ind(dev);
			/* VALIDATION */

			%if %sysfunc(exist(&_ds_val_ic.)) %then %do;
				%create_and_merge_ind(val);
			%end;

		%end;

	%end;

%mend;
