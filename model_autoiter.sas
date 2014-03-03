
%macro model_autoiter(_ds_dev_in_ma, _ds_val_in_ma, _existing_ma, _existing_transform_ma, _newvar_ma, _newvar_transform_ma, _ds_sum_ma, _macro_transform_ma, _var_identifier_ma);

	data _x_dev_ma ;
		set &_ds_dev_in_ma. (keep = &_existing_ma. &_newvar_ma. &depvar. &wgt. /* &cust_id. */) ;
		%&_macro_transform_ma.;
	run;

	data _x_val_ma ;
		set &_ds_val_in_ma. (keep = &_existing_ma. &_newvar_ma. &depvar. &wgt. /* &cust_id. */) ;
		%&_macro_transform_ma.;
	run;


	%let _newvar_comb_ma = &_newvar_ma. &_newvar_transform_ma.;

	data &_ds_sum_ma.;
		set _null_;
	run;

	%macro call_mia_macro;

		title "&_var_lov.";	
		%let _var_list_ma = &_existing_ma. &_existing_transform_ma. &_var_lov.;
		%model_input_autoiter(_x_dev_ma, _x_val_ma, &_var_list_ma., &_var_lov., _stats_summary_ma, &_var_identifier_ma.);

		data &_ds_sum_ma.;	
			format &_var_identifier_ma. $32.;			
			set &_ds_sum_ma. _stats_summary_ma;
		run;

		proc print data = _stats_summary_ma; run;	

	%mend call_mia_macro;

	%loop_over_varlist(&_newvar_comb_ma., call_mia_macro);

%mend;

