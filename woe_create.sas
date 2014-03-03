

%macro woe_create(
		_min_rr_diff_wcn, 
		_ds_dev_wcn, 
		_min_pp_diff_wcn, 
		_ds_val_wcn, 
		_logg_b_wcn, 
		_var_wcn, 
		_cnt_wcn, 
		_ol_ds_wcn, 
		_out_ds_dev_woe_wcn, 
		_out_ds_val_woe_wcn
		);

	data _base1_wcn;
		set &_logg_b_wcn. (keep = MBAD MIN	MAX nbad ngood per_swt);
		ro_brk = -1*dif(MBAD) ;
		bin_num + 1;
	run;

	%if %sysevalf(&_min_rr_diff_wcn. gt 0) %then %do;

		proc sql noprint;
			select sum(case when (ro_brk < &_min_rr_diff_wcn. and ^missing(ro_brk)) or per_swt < &_min_pp_diff_wcn. then 1 else 0 end) into :_num_ro_brk_wcn from _base1_wcn;
		quit;

	%end;

	%else %do;

		proc sql noprint;
			select sum(case when ro_brk > &_min_rr_diff_wcn. or per_swt < &_min_pp_diff_wcn. then 1 else 0 end) into :_num_ro_brk_wcn from _base1_wcn;
		quit;

	%end;


	%if %sysevalf(&_num_ro_brk_wcn. gt 0) %then %do;

		%do %while (%sysevalf(&_num_ro_brk_wcn. gt 0));

			%if %sysevalf(&_min_rr_diff_wcn. gt 0) %then %do;

				proc sql noprint; 
					select bin_num, max format best18., nbad, ngood, per_swt into :_bin_num_wcn, :_max_wcn, :_nbad_wcn, :_ngood_wcn, :_per_swt_wcn from 
					(select bin_num, max format best18., nbad, ngood, per_swt from _base1_wcn where (ro_brk < &_min_rr_diff_wcn. and ^missing(ro_brk)) or per_swt < &_min_pp_diff_wcn.)  having bin_num=min(bin_num); 
				quit;

			%end;

			%else %do;

				proc sql noprint; 
					select bin_num, max format best18., nbad, ngood, per_swt into :_bin_num_wcn, :_max_wcn, :_nbad_wcn, :_ngood_wcn, :_per_swt_wcn from 
					(select bin_num, max format best18., nbad, ngood, per_swt from _base1_wcn where (ro_brk > &_min_rr_diff_wcn. and ^missing(ro_brk)) or  per_swt < &_min_pp_diff_wcn.) having bin_num=min(bin_num); 
				quit;

			%end;

			data _base1_wcn;
				set _base1_wcn ;
				if bin_num = &_bin_num_wcn. - 1 then do;
					max = &_max_wcn.;
					nbad = nbad + &_nbad_wcn.;
					ngood = ngood + &_ngood_wcn.;
					per_swt = per_swt + &_per_swt_wcn.;
				end;

				else if bin_num = &_bin_num_wcn. then delete;

				mbad = (100.0*nbad)/sum(nbad, ngood);

			run;


			data _base1_wcn;
				set _base1_wcn (drop = ro_brk bin_num);
				ro_brk = -1*dif(MBAD) ;
				bin_num + 1;
			run;

			/* proc print data = _base1_wcn; run; */

			%if %sysevalf(&_min_rr_diff_wcn. gt 0) %then %do;

				proc sql noprint;
					select sum(case when (ro_brk < &_min_rr_diff_wcn. and ^missing(ro_brk)) or per_swt < &_min_pp_diff_wcn. then 1 else 0 end) into :_num_ro_brk_wcn from _base1_wcn;
				quit;

			%end;

			%else %do;

				proc sql noprint;
					select sum(case when ro_brk > &_min_rr_diff_wcn. or per_swt < &_min_pp_diff_wcn. then 1 else 0 end) into :_num_ro_brk_wcn from _base1_wcn;
				quit;			

			%end;

		%end;

		%post_woe_create(
			_base1_wcn, 
			&_var_wcn., 
			&_cnt_wcn., 
			&_ol_ds_wcn., 
			&_ds_dev_wcn., 
			&_ds_val_wcn., 
			&_out_ds_dev_woe_wcn., 
			&_out_ds_val_woe_wcn.
		);

	%end;

%mend;

