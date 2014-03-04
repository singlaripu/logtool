
%macro auto_treat_macro(_ds_dev_atm, _ds_val_atm);

	proc means  noprint data = &_ds_dev_atm. n nmiss min max  P1 P99 ;
		weight &wgt.;
		output out = _p1_out_atm p1=;
		output out = _p99_out_atm p99=;
	run;

	%auto_treat_missing(&_ds_dev_atm.);
	%auto_treat_missing(&_ds_val_atm.);

	%let last = 0;
	%let _vl_gvfd = ;
	%get_varlist_from_dataset(_p1_out_atm, _TYPE_ _FREQ_ &depvar.);
	

	%macro rename1(_suff);
		rename 	&_var_lov_l. = var&_cnt_lov_l._&_suff.;
	%mend rename1;

	%macro dummy_macro; 
	%mend dummy_macro;

	%loop_over_varlist_in_ds(_p1_out_atm, _TYPE_ _FREQ_ &depvar., &_vl_gvfd., rename1(p1_), dummy_macro);
	%loop_over_varlist_in_ds(_p99_out_atm, _TYPE_ _FREQ_ &depvar., &_vl_gvfd., rename1(p99_), dummy_macro);

	%macro capfloor(_suff);
		&_var_lov_l. = max(min(&_var_lov_l., var&_cnt_lov_l._p99_), var&_cnt_lov_l._p1_);
		drop var&_cnt_lov_l._p99_ var&_cnt_lov_l._p1_;
	%mend capfloor;

	%macro set_data;
		if (_n_ eq 1) then set _p1_out_atm;
		if (_n_ eq 1) then set _p99_out_atm;
	%mend set_data;

	%loop_over_varlist_in_ds(&_ds_dev_atm., , &_vl_gvfd., capfloor, set_data);
	%loop_over_varlist_in_ds(&_ds_val_atm., , &_vl_gvfd., capfloor, set_data);

%mend;

