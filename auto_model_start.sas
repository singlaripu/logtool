


/* %include '/gdm/apac/reg_pricing/train/ripu/macros/wgt_ranks.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/simple_merge.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/proc_reg_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/proc_logistic_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/post_woe_create.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/post_autoiter_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/pick_top_few_vars.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/normalize.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/merge_ds_dummy_id.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/loop_over_varlist.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/ks_format.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/indicator_create.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/grp_bands.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/get_varlist_from_dataset.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/get_len_macro_var.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/get_corr_coeff.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/extracti_post_ks_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/auto_treat_missing.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/MOD4.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/woe_create.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/loop_over_varlist_in_ds.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/my_ks_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/normalize_validation.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/auto_corr_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/auto_treat_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/variable_drop_p1p99_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/call_fineclass.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/model_input_autoiter.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/pnc_macro.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/model_autoiter.sas';
%include '/gdm/apac/reg_pricing/train/ripu/macros/shortlist15_macro.sas'; */



%macro auto_model_start(
				depvar,
				wgt,
				cust_id,
				apr,
				_dev_data_ams,
				_val_data_ams,				
				_auto_treat_flag_ams,				
				_min_rr_diff_woe_ams,
				_min_popln_bin_size_woe_ams,
				_libname_curr_ams
			);

	%MACRO TRANSFORM;

	%mend TRANSFORM;

	/* options obs = max compress = yes nosource nonotes; */

	%let _actual_time_ams = %sysfunc(putn(%sysfunc(datetime()),datetime22.));
	%let _excel_woe_ams = "woe_cs_ts_&apr..xls" ;
	%let _excel_steps_ams = "model_iter_steps_&apr..xls";
	%let _excel_summary_ams  = "model_iter_summary_&apr..xls";
	%let _excel_summary_short_ams  = "model_iter_summary_short_&apr..xls";
	%let _excel_pnc_steps_ams = "pnc_steps_&apr..xls";
	%let _excel_pnc_summary_ams = "pnc_summary_&apr..xls";
	%let _excel_pnc_summary_short_ams = "pnc_summary_short_&apr..xls";

	%if &_auto_treat_flag_ams. = true %then %do;

		%let _vl_gvfd = ;		
		%auto_treat_macro(&_dev_data_ams., &_val_data_ams.);
		%let _var_list_return_ams = &_vl_gvfd.;

		%variable_drop_p1p99_macro(_p1_out_atm, _p99_out_atm, &_dev_data_ams., &_val_data_ams., &_var_list_return_ams.);
	%end;

	%auto_corr_macro(&_dev_data_ams., &_val_data_ams.);


	%let last = 0;
	%let _vl_gvfd = ;
	%get_varlist_from_dataset(&_dev_data_ams., );
	%let _corr_list_ams = &_vl_gvfd.;

	%call_fineclass(&depvar., &_excel_woe_ams., &_dev_data_ams., &apr._devt_woe, &_min_rr_diff_woe_ams., &_min_popln_bin_size_woe_ams., &apr._devt_woe_logic, &_val_data_ams., &apr._val_woe, &_corr_list_ams.);

	data &_libname_curr_ams..&apr._devt_woe_logic; 
		set &apr._devt_woe_logic; 
	run;

	%simple_merge(&apr._devt_woe, &_dev_data_ams., &apr._dev_extra, &cust_id.);
	%simple_merge(&apr._val_woe, &_val_data_ams., &apr._val_extra, &cust_id.);

	%let _final_selected_s15m = ;
	%shortlist15_macro(&apr._dev_extra, &apr._val_extra, &_excel_summary_ams., &_excel_summary_short_ams., TRANSFORM);

	data &_libname_curr_ams..&apr._dev_extra;
		set  &apr._dev_extra;
	run;

	data &_libname_curr_ams..&apr._val_extra;
		set  &apr._val_extra;
	run;


	%pnc_macro(
		&apr._dev_extra, 
		&apr._val_extra, 
		&_excel_pnc_steps_ams., 
		&_excel_pnc_summary_ams.,
		&_excel_pnc_summary_short_ams.,
		TRANSFORM,
		&_final_selected_s15m.,
		);

%mend;

