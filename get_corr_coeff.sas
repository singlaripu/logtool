

%macro get_corr_coeff(_ds_gcc, _ds_out_gcc, _vl_gcc, _suff_gcc, _id_gcc);

	proc corr noprint data = &_ds_gcc. outp = &_ds_out_gcc.;
		var &_vl_gcc.;
		with &depvar.;
	run;

	data &_ds_out_gcc. (drop = _TYPE_ _NAME_);
		set &_ds_out_gcc.;
		where _TYPE_ = 'CORR';
		&_id_gcc. = 1;
	run;

	proc transpose data = &_ds_out_gcc. out = &_ds_out_gcc. (drop = &_id_gcc. rename=(col1=col1_&_suff_gcc.));
		by &_id_gcc.;
	run;

	proc sort data = &_ds_out_gcc.;
		by _name_;
	run;

%mend;
