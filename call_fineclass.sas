
	
%macro call_fineclass(_depvar_cf, _xl_out_cf, _ds_dev_cf, _out_ds_dev_cf, _woe_rr_diff_cf, _woe_pp_diff_cf, _ol_ds_cf, _ds_val_cf, _out_ds_val_cf, _corr_vl_cf);
	
	data _subset_cf;
		set &_ds_dev_cf;
		goodbad = &_depvar_cf;
		if &_depvar_cf = 1 then bad = 1; else bad = 0;
		if &_depvar_cf = 0 then good = 1; else good = 0;
		if &_depvar_cf = -1 then ind = 1; else ind = 0;
	run;

	proc sort data = &_ds_val_cf. out = _subset_cf_val nodupkey;
		by &cust_id.;
	run;

	data &_out_ds_val_cf.;
		set _subset_cf_val (keep = &cust_id. &_depvar_cf. &wgt.);
	run;


	proc sort data = _subset_cf nodupkey;
		by &cust_id.;
	run;


	data &_ol_ds_cf.;
		format var_der $32.;
		format var_orig $32.;
		set _null_ ;
	run;
	
	data &_out_ds_dev_cf.;
		set _subset_cf (keep = &cust_id. &_depvar_cf. &wgt.);
	run;


 	%let last = 0;
	%let _vl_gvfd = ;
	%get_varlist_from_dataset(&_ds_dev_cf., );


	PROC CORR DATA=_subset_cf OUTP=_corr_cov_cf noprint;
	  VAR &_corr_vl_cf. ;
	  with &_depvar_cf.;
	RUN;


	data _corr_cov_cf; 
	  set _corr_cov_cf;
	  where _type_ = 'CORR'; 
	run;

		
	ods html file = &_xl_out_cf ;

	%macro woe_create_calls_macro_cf;

		%MOD4(&_var_lov., _subset_cf, _LOGG_B_cf, bad, good, ind);

		data _null_;
			set _corr_cov_cf (keep = &_var_lov.);
			call symput('_var_sign_cf',  &_var_lov.);
		run;

		%let _woe_rr_diff_cf1 = %sysevalf(-1.0*&_woe_rr_diff_cf.);

		%if %sysevalf(&_var_sign_cf. gt 0) %then %do;
			%woe_create(&_woe_rr_diff_cf1., _subset_cf, &_woe_pp_diff_cf., _subset_cf_val, _LOGG_B_cf, &_var_lov., &_cnt_lov., &_ol_ds_cf., &_out_ds_dev_cf., &_out_ds_val_cf.);
		%end;

		%else %if %sysevalf(&_var_sign_cf. lt 0) %then %do;
			%woe_create(&_woe_rr_diff_cf., _subset_cf, &_woe_pp_diff_cf., _subset_cf_val, _LOGG_B_cf, &_var_lov., &_cnt_lov., &_ol_ds_cf., &_out_ds_dev_cf., &_out_ds_val_cf.);
		%end;	
			
		%indicator_create(&_woe_rr_diff_cf., _subset_cf, &_woe_pp_diff_cf., _subset_cf_val, _LOGG_B_cf, &_var_lov., &_cnt_lov., &_ol_ds_cf., &_out_ds_dev_cf., &_out_ds_val_cf.);

	%mend woe_create_calls_macro_cf;

	%loop_over_varlist(&_vl_gvfd., woe_create_calls_macro_cf);
	
	ods html close;
	
%mend;
