

%macro proc_reg_macro(_ds_prm, _wgt_prm, _depvar_prm, _vl_prm, _per_prm);

	proc reg data = &_ds_prm. ;
		weight &_wgt_prm.;
		model &_depvar_prm. = &_vl_prm. /vif collinoint;
		ods output ParameterEstimates = &_per_prm.;
	run;

%mend;
