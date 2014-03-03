

%macro get_varlist_from_dataset(_ds_gvfd, _dl_gvfd);

	proc contents noprint data = &_ds_gvfd. (drop = &_dl_gvfd.)
		out = _data_dict_gvfd (keep = name type) noprint ;
	run;

	data _data_dict_gvfd_num;
		set _data_dict_gvfd;
		where type = 1;
	run;

	%let last = 0;

	data _null_;
		set _data_dict_gvfd_num end=lastobs;
		call symput('var'||left(_n_),  name);
		if lastobs then call symput('last',_n_);
	run;

	%let _vl_gvfd = ;

	%do i=1 %to &last;

		%if %lowcase(&&var&i.) ^= &wgt. and %lowcase(&&var&i.) ^= %lowcase(&depvar.) and %lowcase(&&var&i.) ^= %lowcase(&cust_id.) %then %do;

		%let _vl_gvfd = &_vl_gvfd. &&var&i.;

		%end;

	%end;

%mend;

