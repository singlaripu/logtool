%macro create_and_merge(_sample_cam);

	data _iter_woe_ds_&_sample_cam._pwc (drop = max1-max&_tot_bins_pwc. woe1-woe&_tot_bins_pwc. &_var_pwc. k);
		set &&_ds_&_sample_cam._pwc. (keep = &cust_id. &_var_pwc.);

		if (_n_ eq 1) then set _base2_pwc;

		array maxi{*} max1-max&_tot_bins_pwc.;
		array woe{*} woe1-woe&_tot_bins_pwc.;
		
		do k=1 to &_tot_bins_pwc.;
			if &_var_pwc. <= maxi{k} then do;
			 	&_var_woe_pwc. = woe{k};
				leave;
			end;
			else if &_var_pwc. > maxi{&_tot_bins_pwc.} then &_var_woe_pwc. = woe{&_tot_bins_pwc.};
		end;	
	run;

	data &&_out_ds_&_sample_cam._woe_pwc.;
		merge &&_out_ds_&_sample_cam._woe_pwc. (in=a) _iter_woe_ds_&_sample_cam._pwc(in=b);
		by &cust_id.;
		if a and b;
	run;

%mend;

%macro transpose_woe(_var_tw);

	proc transpose data = &_base1_pwc. out = _bin_&_var_tw._ds_pwc (drop = _name_)  prefix=&_var_tw.;
	by id1;
	id bin_num;
	var &_var_tw.;	
	run;	

%mend;




%macro post_woe_create(
		_base1_pwc, 
		_var_pwc, 
		_cnt_pwc, 
		_ol_ds_pwc, 
		_ds_dev_pwc, 
		_ds_val_pwc, 
		_out_ds_dev_woe_pwc, 
		_out_ds_val_woe_pwc
		);


	proc sql noprint;
		select sum(nbad), sum(ngood), count(*) into :_tot_nbad_pwc, :_tot_ngood_pwc, :_tot_bins_pwc from &_base1_pwc.;
	quit;

	%if %sysevalf(&_tot_bins_pwc. gt 2) %then %do;	

		%let _tot_bins_pwc = %eval(&_tot_bins_pwc.);
		%let _var_woe_pwc = %trim(&_var_pwc.)_w;

		%if %sysevalf(%length(&_var_woe_pwc) ge 32) %then %do;
			%let _var_woe_pwc = var&_cnt_pwc._w;
		%end;

		data &_base1_pwc. /* (keep = max woe bin_num id1) */; 
			/* format varname $32.; */
			set &_base1_pwc. ;
			woe = log((nbad/&_tot_nbad_pwc.)/(ngood/&_tot_ngood_pwc.));
			id1 = 1;
			/* varname = "&_var_woe_pwc."; */
		run;
		
		%transpose_woe(max);
		%transpose_woe(woe);


		data _base2_pwc (drop = id1);
			format var_der $32.;
			format var_orig $32.;
			merge _bin_max_ds_pwc _bin_woe_ds_pwc;
			by id1;
			var_der = "&_var_woe_pwc.";
			var_orig = "&_var_pwc.";
		run;
		
		/* proc print data = _base2_pwc; run; */

		title "&_var_pwc. : &_var_woe_pwc";

		proc print data = &_base1_pwc.; 
		var MBAD MIN MAX nbad ngood woe per_swt;
		run;

		data &_ol_ds_pwc.;
			set &_ol_ds_pwc. _base2_pwc;
		run;

		%create_and_merge(dev);

		%if %sysfunc(exist(&_ds_val_pwc.)) %then %do;
			%create_and_merge(val);
		%end;

	%end;

%mend;

