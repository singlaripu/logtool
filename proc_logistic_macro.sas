

%macro proc_logistic_macro(_ds_plm, _out_model_plm, _wgt_plm, _depvar_plm, _vl_plm, _ds_to_score_plm, _ds_scored_plm, _aa_ds_plm, _concord_ds_plm);

	proc logistic data = &_ds_plm. descending desc outmodel = &_out_model_plm. namelen=32;
		weight &_wgt_plm.;
		model &_depvar_plm. = &_vl_plm.;
		score data = &_ds_to_score_plm. out = &_ds_scored_plm.;
		ods output ParameterEstimates = &_aa_ds_plm. Association=&_concord_ds_plm.;
	run;

	%if ^%sysfunc(exist(&_concord_ds_plm.)) %then %do;

		data &_concord_ds_plm.;
			Label1 = "Percent Concordant";
			cValue1 = "0";
		run;

	%end;

%mend;
