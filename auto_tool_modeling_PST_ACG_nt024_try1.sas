options obs = max compress = yes nosource nonotes;


/* options mstored sasmstore=maclib nofmterr label errors=2 ls=100 ps=50 compress=yes obs=max ; */
/* options symbolgen mlogic mprint mfile; */

libname dev "/gdm/apac/reg_pricing/train/ripu";
libname val "/gdm/apac/reg_pricing/train/ripu";
libname curr "/gdm/apac/reg_pricing/train/ripu/macros";

/* %let macro_location = /gdm/apac/reg_pricing/train/ripu/macros;
 */

/******************************** DEFINE MACRO VARIABLES **********************************/

%let dev_data = dev.hk_nt_drv_024 ; /* Input Development Dataset */
%let val_data = val.hk_nt_drv_024_otv ; /* Input Validation Dataset1 */
%let auto_treat = true;
%let depvar = resp;
%let cust_id = CLNT_PRIM_DOC_ID;
%let wgt = wgt;

%let apr = nt_024;
%let min_rr_diff_woe = 0.6; /* usually equals to 1/4th of the segment response rate */
%let min_popln_bin_size_woe = 3;



/******************************** END DEFINE MACRO VARIABLES **********************************/


%let raw_variables =

	BUR_UTIL
	CURR_BAL_UNSEC

;

/****************************** Prepare the modeling dataset ******************************/
data dev_data; 
	set &dev_data. (keep = &raw_variables. &depvar. &cust_id. &wgt.);

	/* &wgt. = 1; */

run ;

data val_data; 
	set &val_data. (keep = &raw_variables. &depvar. &cust_id. &wgt.);

	/* &wgt. = 1; */

run ;
/****************************** END Prepare the modeling dataset ******************************/

%include '/gdm/apac/reg_pricing/train/ripu/macros/wgt_ranks.sas';
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
%include '/gdm/apac/reg_pricing/train/ripu/macros/shortlist15_macro.sas';
%include "/gdm/apac/reg_pricing/train/ripu/macros/auto_model_start.sas"; 

%auto_model_start(
				&depvar.,
				&wgt.,
				&cust_id.,
				&apr.,
				dev_data,
				val_data,				
				&auto_treat.,				
				&min_rr_diff_woe.,
				&min_popln_bin_size_woe.,
				curr
			);








