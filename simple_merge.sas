
%macro simple_merge(_ds1_sm, _ds2_sm, _ds3_sm, _id_sm);

	proc sort data = &_ds1_sm. nodupkey;
		by &_id_sm.;
	run;


	proc sort data = &_ds2_sm. nodupkey;
		by &_id_sm.;
	run;

	data &_ds3_sm.;
		merge  &_ds1_sm. (in=_ds1_) &_ds2_sm. (in=_ds2_);
		by &_id_sm.;
		if _ds1_ and _ds2_;
	run;

%mend;


