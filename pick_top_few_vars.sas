
%macro pick_top_few_vars(_ds_pick_ptfv, _f_pick_ptfv, _o_pick_ptfv, _var_pick_ptfv, _ds_out_ptfv);

	data _shortlist1_ptfv;
		set _null_;
	run;

	data _shortlist1_ptfv;
		set &_ds_pick_ptfv. (keep = &_var_pick_ptfv. firstobs = &_f_pick_ptfv. obs = &_o_pick_ptfv.);
		id1 = 1;
		col1 = 1;
	run;	

	data &_ds_out_ptfv.;
		set _null_;
	run;

	proc transpose data = _shortlist1_ptfv out = &_ds_out_ptfv. (drop = _name_ id1);
		by id1;
		id &_var_pick_ptfv.;
		var col1;
	run;

%mend;

