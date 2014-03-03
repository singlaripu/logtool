
%macro normalize_validation(_vl_nv, _ds_dev_nv, _ds_val_nv);
	
	%macro normalize_nv;
		%normalize(&_var_lov., &_ds_dev_nv., &_ds_val_nv.);
	%mend normalize_nv;

	%loop_over_varlist(&_vl_nv., normalize_nv);

%mend;