
%macro variable_drop_p1p99_macro(_ds_flr_vdpm, _ds_cap_vdpm, _ds_dev_vdpm, _ds_val_vdpm, _vl_vdpm);

	%merge_ds_dummy_id(&_ds_flr_vdpm., &_ds_cap_vdpm., merged_vdpm, id1);

	%macro dummy_macro; %mend dummy_macro;

	%macro p99_le_p1;
		if var&_cnt_lov._p99_ le  var&_cnt_lov._p1_ then &_var_lov. = 1;
		else &_var_lov. = 0;
		drop var&_cnt_lov._p99_ var&_cnt_lov._p1_;
	%mend;

	%loop_over_varlist_in_ds(merged_vdpm, , &_vl_vdpm., p99_le_p1, dummy_macro);	

	proc transpose data = merged_vdpm out = merged_vdpm;
		by id1;
	run;

	data merged_vdpm;
		set merged_vdpm;
		where col1 = 1;
	run;

	proc transpose data = merged_vdpm out = merged_vdpm (drop = _name_ id1);
		by id1;
		id _name_;
		var col1;
	run;

	%let last = 0;
	%let _vl_gvfd = ;
	%get_varlist_from_dataset(merged_vdpm, );

	data &_ds_dev_vdpm.;
		set &_ds_dev_vdpm. (drop = &_vl_gvfd.);
	run;

	data &_ds_val_vdpm.;
		set &_ds_val_vdpm. (drop = &_vl_gvfd.);
	run;

%mend;
