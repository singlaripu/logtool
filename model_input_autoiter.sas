

%macro model_input_autoiter(_ds_dev_mia, _ds_val_mia, _vl_mia, _var_mia, _stats_summary_mia, _var_identifier_mia);

	title " ";
	data _transformed1_mia ;
		set &_ds_dev_mia. (keep = &_vl_mia. &depvar. &wgt. );

	run;

	proc standard data = _transformed1_mia mean=0 std=1 out=_transformed_mia;
		var &_vl_mia.;
		weight &wgt.;
	run;

	%proc_reg_macro(_transformed_mia, &wgt., &depvar., &_vl_mia., _PEr_dev_mia);

	%proc_logistic_macro(_transformed_mia, _model_devt_mia, &wgt., &depvar., &_vl_mia., _transformed_mia, _scored_mia, _aa_dev_mia, _concord_ds_mia);

	TITLE "KS TABLE -- DEVELOPMENT";
	%my_ks_macro(_scored_mia, P_1, &wgt., &depvar., _z2_mia, _uni_rank_data_mia);



	%extracti_post_ks_macro(_z2_mia, _z4_dev_mia, &_var_mia., dev, _z4_dev_v1_mia, _z4_dev_v2_mia, _z5_dev_mia, _vif_ds_dev_mia, _PEr_dev_mia, _pvalue_ds_dev_mia, 0.05, _aa_dev_mia, _aa_dev_srt_mia, &_var_identifier_mia.);


	title "VALIDATION";

	data _val_mia  ;
		set &_ds_val_mia. (keep = &_vl_mia. &depvar. &wgt. );

	run;

	%normalize_validation(&_vl_mia., _transformed1_mia, _val_mia);

	%proc_reg_macro(_val_mia, &wgt., &depvar., &_vl_mia., _PEr_val_mia);


	proc logistic data = _val_mia descending desc namelen=32 ;
		weight &wgt.;
		model &depvar. = &_vl_mia.;
		ods output ParameterEstimates = _aa_val_mia;
	run;


	proc logistic inmodel = _model_devt_mia;
		weight &wgt.;
		score data = _val_mia out=_scored_mia ;
	run;


	%grp_bands(_scored_mia, _scored_mia, _uni_rank_data_mia, P_1, rnk_val);

	TITLE "KS TABLE with same bining as development -- VALIDATION";
	%ks_format(_scored_mia, &wgt., &depvar., rnk_val, P_1, _z2_mia);



 	%extracti_post_ks_macro(_z2_mia, _z4_val_mia, &_var_mia., val, _z4_val_v1_mia, _z4_val_v2_mia, _z5_val_mia, _vif_ds_val_mia, _per_val_mia, _pvalue_ds_val_mia, 0.3, _aa_val_mia, _aa_val_srt_mia, &_var_identifier_mia.);


	proc sql;
		create table _concordance_ds1_mia as
		select 
			"&_var_mia." as &_var_identifier_mia. format $32.,
			cValue1 as concordance
		from 
			_concord_ds_mia
		where 
			Label1 = "Percent Concordant";
	quit;



	data _aa_merged_mia (keep = sign_check);
		merge _aa_dev_srt_mia (in=a) _aa_val_srt_mia (in=b);
		by &_var_identifier_mia.;
		if a and b;
		sign_check = est_dev *est_val;
	run;


	proc sql;
		create table _est_sign_check_mia as
		select 
			/* "&_var_mia." as &_var_identifier_mia., */
			count(*) as est_sign_mismatch_cnt
		from 
			_aa_merged_mia
		where
			sign_check <= 0;
	quit;


	data _est_sign_check_mia;
		format &_var_identifier_mia. $32.;
		set _est_sign_check_mia;
		&_var_identifier_mia. = "&_var_mia.";
	run;


	data &_stats_summary_mia.;
		merge 
			_vif_ds_dev_mia (in=a) 
			_vif_ds_val_mia (in=b) 
			_pvalue_ds_dev_mia (in=c) 
			_pvalue_ds_val_mia (in=d) 
			_est_sign_check_mia (in=e) 
			_z4_dev_mia (in=f)
			_z4_dev_v1_mia (obs=1 in=m) 
			_z4_dev_v2_mia (obs=1 in=o)
			_z5_dev_mia (in=g) 
			_z4_val_mia (in=h) 
			_z4_val_v1_mia (obs=1 in=p) 
			_z4_val_v2_mia (obs=1 in=q)
			_z5_val_mia (in=j) 
			/* sign_new_var_ds (in=k) */
			_concordance_ds1_mia (in=l);
		by &_var_identifier_mia.;
		if a and b and c and d and e and f and g and j /* and k */ and l and m and o and p and q;
		ks_diff = abs(KS_dev - KS_val);
	run;


%mend;
