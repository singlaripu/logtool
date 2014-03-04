
%macro loop_over_varlist_in_ds(_ds_lovid, _dl_lovid, _vl_lovid, _mn_lovid, _flat_macro_lovid);

	data &_ds_lovid.;
		set &_ds_lovid. (drop = &_dl_lovid.);

		%&_flat_macro_lovid.;

		%loop_over_varlist(&_vl_lovid., &_mn_lovid., l);

	run;

%mend;
