
%macro wgt_ranks(_ds_wr, _var_wr, _dvar_wr, _var1_wr, _var2_wr, _nogrps_wr, _outset_wr);


	proc sort data=&_ds_wr (keep=&_var_wr &wgt. &_dvar_wr. &_var1_wr &_var2_wr. ) out=_temps_wr;
	by &_var_wr;

	data 
		_tempb_wr (keep=rank   &_var_wr  common c&wgt.)
		_tempc_wr (keep=sum&wgt. &_var_wr  common     );

	set _temps_wr   end=eof;
	by &_var_wr;
	common            =  1;
	if &_var_wr          ne  . then do;
	   if first.&_var_wr       then do;
	      c&wgt.        =  0;
	      end;
	   sum&wgt. + &wgt.;
	   c&wgt.   + &wgt.;
	   rank   + &wgt.;
	   if last.&_var_wr        then output _tempb_wr;
	   if eof              then output _tempc_wr;
	   end;

	data _tempd_wr;
	merge _tempc_wr _tempb_wr;
	  by common;
	drop common;

	data &_outset_wr (rename=(&_var_wr=testvar));
	merge _tempd_wr _temps_wr;
	by &_var_wr;
	retain oldvar rtestvar;
	keep rtestvar  &_var_wr  &wgt. &_dvar_wr. &_var1_wr &_var2_wr /* &_var_wr3 amount frdamt*/;
	if &_var_wr        ne  .      then do;
	   if &_var_wr      >  oldvar then do;
	      rtestvar  = (2*rank*&_nogrps_wr+(1-c&wgt.)*&_nogrps_wr)/(2*(sum&wgt.+1));
	      rtestvar  = floor(rtestvar);
	      end;
	   oldvar = &_var_wr;
	   end;

	run;

%mend;

