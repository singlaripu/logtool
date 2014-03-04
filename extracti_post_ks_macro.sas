

%macro extracti_post_ks_macro(
				_z2_epkm, 
				_z4_epkm, 
				_var_epkm, 
				_suff_epkm, 
				_z4_v1_epkm, 
				_z4_v2_epkm, 
				_z5_epkm, 
				_vif_ds_epkm, 
				_per_ds_epkm, 
				_pvalue_ds_epkm, 
				_min_p_epkm, 
				_aa_ds_epkm, 
				_aa_srt_ds_epkm,
				_var_identifier_epkm
			);


	TITLE " ";

	proc sql noprint; 
		select sum(total) into: _s_total_epkm from &_z2_epkm.;
	quit;


	data _z3_epkm;
	set &_z2_epkm. ;
	ro_brk = -1*dif(respr) ;
	bin_num + 1;
	per_swt = total/&_s_total_epkm.;
	run;

	proc sql;
	create table &_z4_epkm. as
	select 
		"&_var_epkm." as &_var_identifier_epkm.  format $32.,
		sum(case when ro_brk < 0 then 1 else 0 end) - 1 as num_ro_brk_&_suff_epkm.,
		sum(case when per_swt < 0.08 then 1 else 0 end) as num_bin_size_lt8_&_suff_epkm.,
		sum(case when per_swt > 0.12 then 1 else 0 end) as num_bin_size_gt12_&_suff_epkm.,
		count(*) as ks_bins_&_suff_epkm.
	from 
		_z3_epkm 
	quit;


	data _z4_v3_epkm;
		set _z3_epkm (keep = ro_brk bin_num);
		if ro_brk >= 0 or missing(ro_brk) then do;
			bin_num = 11;
			ro_brk = 0;
		end;
	run;


	proc sql; 
	create table &_z4_v1_epkm. as 
	select 
		"&_var_epkm." as &_var_identifier_epkm.  format $32.,
		bin_num as first_ro_brk_&_suff_epkm.,
		-100.0*ro_brk as first_ro_brk_size_&_suff_epkm.
	from
		_z4_v3_epkm
	having 
		bin_num = min(bin_num)
	order by
		2;
	quit;


	proc sql; 
	create table &_z4_v2_epkm.  as 
	select 
		"&_var_epkm." as &_var_identifier_epkm.  format $32.,
		bin_num as largest_ro_brk_&_suff_epkm.,
		-100.0*ro_brk as largest_ro_brk_size_&_suff_epkm.
	from
		_z4_v3_epkm
	having 
		ro_brk = min(ro_brk)
	order by 
		2;
	quit;


	proc sql;
	create table &_z5_epkm. as 
	select 
		"&_var_epkm." as &_var_identifier_epkm.  format $32.,
		ROUND(100*max(KS),.01) as KS_&_suff_epkm.
	from &_z2_epkm.;
	QUIT;	

	proc sql;
		create table &_vif_ds_epkm. as
		select 
			"&_var_epkm." as &_var_identifier_epkm. format $32.,
			max(VarianceInflation) as max_vif_&_suff_epkm.,
			sum(case when VarianceInflation >= 2 then 1 else 0 end) as vif_gt2_count_&_suff_epkm.
		from 
			&_per_ds_epkm.;
	quit;


	%let _p_suff_epkm = %sysevalf(100*&_min_p_epkm.);

	proc sql;
		create table &_pvalue_ds_epkm. as
		select 
			"&_var_epkm." as &_var_identifier_epkm. format $32.,
			max(ProbChiSq) as max_pvalue_&_suff_epkm. format PVALUE6.4,
			sum(case when ProbChiSq > &_min_p_epkm. then 1 else 0 end) as pvalue_gt&_p_suff_epkm._cnt_&_suff_epkm.
		from 
			&_aa_ds_epkm.;
	quit;



	proc sort data = &_aa_ds_epkm. (keep = &_var_identifier_epkm. Estimate) out = &_aa_srt_ds_epkm. (rename = (Estimate = est_&_suff_epkm.));
		by &_var_identifier_epkm.;
	run;


%mend;