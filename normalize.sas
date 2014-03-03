
%macro normalize(_var_n, _ds_dev_n, _ds_val_n);
	
	proc univariate data = &_ds_dev_n. noprint;
		weight &wgt.;
		var &_var_n.;
		output out=_devt_out_n mean=m std=s;
	run;

	data &_ds_val_n. (drop = m s);
		set &_ds_val_n.;
		if (_n_ eq 1) then set _devt_out_n (keep = m s);
		&_var_n. = (&_var_n. - m)/s;
	run;
	
%mend;
