

%macro grp_bands(_ds_in_gb, _ds_out_gb, _ds_set1_gb, _scr_gb, _new_var_gb);
	
	data &_ds_out_gb. (drop = Ppct1-Ppct10);
		set &_ds_in_gb.;
		if (_n_ eq 1) then set &_ds_set1_gb.;
		
		if &_scr_gb. <= Ppct1 then &_new_var_gb. = 9;
		else if &_scr_gb. <= Ppct2 then &_new_var_gb. = 8;
		else if &_scr_gb. <= Ppct3 then &_new_var_gb. = 7;
		else if &_scr_gb. <= Ppct4 then &_new_var_gb. = 6;
		else if &_scr_gb. <= Ppct5 then &_new_var_gb. = 5;
		else if &_scr_gb. <= Ppct6 then &_new_var_gb. = 4;
		else if &_scr_gb. <= Ppct7 then &_new_var_gb. = 3;
		else if &_scr_gb. <= Ppct8 then &_new_var_gb. = 2;
		else if &_scr_gb. <= Ppct9 then &_new_var_gb. = 1;
		else &_new_var_gb. = 0;
	
	run;

%mend;
