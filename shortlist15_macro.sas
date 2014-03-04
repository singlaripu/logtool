

%macro shortlist15_macro(_ds_in_dev_s15m, _ds_in_val_s15m, _excel_sum_s15m, _excel_sum_short_s15m, _trnsfrm_macro_s15m);


	%let _existing_s15m = ;
	%let _existing_transform_s15m = ;
	%let _newvar_transform_s15m = ;

	%let last = 0;
	%let _vl_gvfd = ;
	%get_varlist_from_dataset(&_ds_in_dev_s15m., );
	%let _newvar_s15m = &_vl_gvfd.;

	%let _final_selected_s15m = ;
	%let _tot_shortlisted_s15m = 1;

	%let _var_identifier_s15m = variable;
	%let _variable_score_s15m = variable_score;

	data _mod_iter_sum_glob_s15m;
		set _null_;
	run;

	data _mod_iter_sum_shrt_glob_s15m;
		set _null_;
	run;	



	%do _i_s15m=1 %to 5;

		%if %sysevalf(&_tot_shortlisted_s15m. gt 0) %then %do;

			%model_autoiter(&_ds_in_dev_s15m., &_ds_in_val_s15m., &_existing_s15m., &_existing_transform_s15m., &_newvar_s15m., &_newvar_transform_s15m., _mod_iter_sum_s15m, &_trnsfrm_macro_s15m., &_var_identifier_s15m.);
			%post_autoiter_macro(_mod_iter_sum_s15m, &_i_s15m., _mod_iter_sum_glob_s15m, _mod_iter_sum_shrt_s15m, _mod_iter_sum_shrt_glob_s15m, &_var_identifier_s15m., &_variable_score_s15m.);


			proc sql noprint; 
				select count(*)  into: _tot_shortlisted_s15m from _mod_iter_sum_shrt_s15m; 
			quit;


			%pick_top_few_vars(_mod_iter_sum_shrt_s15m, 1, 3, &_var_identifier_s15m., _shortlist1_save_s15m, _shortlist1_save_t_s15m);
			%let last = 0;
			%let _vl_gvfd = ;
			%get_varlist_from_dataset(_shortlist1_save_t_s15m, );
			
			%put "short_summary_top3", &_vl_gvfd.;

			%let _final_selected_s15m = &_final_selected_s15m. &_vl_gvfd.;

			%pick_top_few_vars(_mod_iter_sum_shrt_s15m, 1, 1, &_var_identifier_s15m., _shortlist1_s15m_junk, _shortlist1_t_s15m);
			%let last = 0;
			%let _vl_gvfd = ;
			%get_varlist_from_dataset(_shortlist1_t_s15m, );
			
			%put "short_summary_top1", &_vl_gvfd.;

			%let _existing_s15m = &_existing_s15m. &_vl_gvfd.;

			proc sql noprint; 
				select count(*)  into: _tot_vars_s15m from _mod_iter_sum_s15m; 
			quit;


			proc sort data = _mod_iter_sum_s15m (keep = &_var_identifier_s15m. &_variable_score_s15m.);
				by descending &_variable_score_s15m. ;
			run;

			%let obs_need = %sysevalf(0.85*&_tot_vars_s15m., ceil);


			data _shortlist1_s15m;
				set _null_;
			run;

			data _shortlist1_s15m (keep = &_var_identifier_s15m. id1 col1);
				set _mod_iter_sum_s15m (firstobs = 1 obs = &obs_need.);
				id1 = 1;
				col1 = 1;
			run;

			proc sort data = _shortlist1_s15m;
			by &_var_identifier_s15m.;
			run;

			proc sort data = _shortlist1_save_s15m;
			by &_var_identifier_s15m.;
			run;

			data _shortlist2_s15m;
				set _null_;
			run;

			data _shortlist2_s15m;
				merge _shortlist1_s15m (in=a) _shortlist1_save_s15m (in=b);
				by &_var_identifier_s15m.;
				if a and not b;
			run;


			proc transpose data = _shortlist2_s15m out = _shortlist2_s15m (drop = _name_ id1);
				by id1;
				id &_var_identifier_s15m.;
				var col1;
			run;


			%let last = 0;
			%let _vl_gvfd = ;
			%get_varlist_from_dataset(_shortlist2_s15m, );

			%put "full_summary_merged", &_vl_gvfd.;

			%let _newvar_s15m = &_vl_gvfd.;

			%put "existing", &_existing_s15m.;
			%put "newvar", &_newvar_s15m.;
			%put "final_selected", &_final_selected_s15m.;

		%end;

	%end;

	ods html file = &_excel_sum_s15m.;

	proc print data = _mod_iter_sum_glob_s15m;
	run;

	ods html close;

	ods html file = &_excel_sum_short_s15m.;

	proc print data = _mod_iter_sum_shrt_glob_s15m;
	run;

	ods html close;


	
%mend;
