
%macro auto_corr_macro(_ds_dev_acm, _ds_val_acm);

	%let last = 0;
	%let _vl_gvfd = ;
	%get_varlist_from_dataset(&_ds_dev_acm., );

	%get_corr_coeff(&_ds_dev_acm., corr_outp_dev, &_vl_gvfd., dev, id1);
	%get_corr_coeff(&_ds_val_acm., corr_outp_val, &_vl_gvfd., val, id1);

	data corr_merged_acm;
		merge corr_outp_dev (in=a) corr_outp_val (in=b);
		by _name_;
		if a and b;
		sign1 = col1_dev*col1_val;
	run;

	data corr_merged_acm;
		set corr_merged_acm;
		where sign1 > 0;
		id1 = 1;
	run;

	proc transpose data = corr_merged_acm out = corr_merged_acm (drop = _name_ id1);
		by id1;
		id _name_;
		var sign1;
	run;	

	%let last = 0;
	%let _vl_gvfd = ;
	%get_varlist_from_dataset(corr_merged_acm, );

	data &_ds_dev_acm.;
		set &_ds_dev_acm. (keep = &cust_id. &depvar. &wgt. &_vl_gvfd.);
	run;

	data &_ds_val_acm.;
		set &_ds_val_acm. (keep = &cust_id. &depvar. &wgt. &_vl_gvfd.);
	run;	

%mend;