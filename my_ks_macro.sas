

%macro my_ks_macro(_ds_mkm, _scr_mkm, _wgt_mkm, _depvar_mkm, _ds_out_mkm, _uni_rnk_ds_mkm);
	
	proc univariate data = &_ds_mkm. noprint;
		var &_scr_mkm.;
		output out = &_uni_rnk_ds_mkm. pctlpre=P pctlpts=10 TO 100 BY 10 pctlname = PCT1-PCT10;
		weight &_wgt_mkm.;
	run;

	%grp_bands(&_ds_mkm., _ks_scored_mkm, &_uni_rnk_ds_mkm., &_scr_mkm., GRPNAME);
	
	%ks_format(_ks_scored_mkm, &_wgt_mkm., &_depvar_mkm., GRPNAME, &_scr_mkm., &_ds_out_mkm.);

%mend;
