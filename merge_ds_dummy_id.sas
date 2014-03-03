
%macro merge_ds_dummy_id(_ds1_mddi, _ds2_mddi, _ds3_mddi, _id_mddi);

	data &_ds1_mddi._n;
		set &_ds1_mddi.;
		&_id_mddi. = 1;
	run;

	data &_ds2_mddi._n;
		set &_ds2_mddi.;
		&_id_mddi. = 1;
	run;

	data &_ds3_mddi.;
		merge &_ds1_mddi._n (in=a) &_ds2_mddi._n (in=b);
		if a and b;
		by &_id_mddi.;
	run;

%mend;

