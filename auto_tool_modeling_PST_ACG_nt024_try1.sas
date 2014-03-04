options obs = max compress = yes nosource nosource2 nonotes;

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








