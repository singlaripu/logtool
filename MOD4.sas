
%MACRO MOD4(_var_m, _ds_m, _outds_m, _bad_m, _good_m, _ind_m);

	/* TITLE3 "LGOODBAD VS &_var_m"; */

	%wgt_ranks(&_ds_m., &_var_m, &_bad_m., &_good_m., &_ind_m., 20, _TEMP2_m);
			
	%global _TOTBAD_m _TOTGOOD_m _TOTIND_m _sumswt_m  _infoval_m;

	PROC MEANS DATA=_TEMP2_m NOPRINT;
		VAR &_bad_m. &_good_m. &_ind_m. ;
		WEIGHT &wgt.;
		OUTPUT OUT = _OUT1_m SUM= TOTBAD1 TOTGOOD1 TOTIND1 sum&wgt.=sumwt ; 
	
	DATA _OUT1_m; 
		SET _OUT1_m;
		CALL SYMPUT('_TOTBAD_m',TOTBAD1);
		CALL SYMPUT('_TOTGOOD_m', TOTGOOD1);
		CALL SYMPUT('_TOTIND_m', TOTIND1);  
		CALL SYMPUT('_sumswt_m', sumwt);

	 
    PROC MEANS DATA=_temp2_m  VARDEF=WDF N MEAN MIN MAX SUM NOPRINT;
		 VAR &_bad_m. testvar   &_good_m. &_ind_m. /* boutcrewclose amount frdamt*/;
		  BY RTESTVAR;
		  WEIGHT &wgt.;
		  OUTPUT OUT=_TEMP_m 
		  MEAN   = MBAD MTESTVAR /*a b*/
		  MIN    = MINGOODB MIN /*c d*/
		  MAX    = MAXGOODB MAX /*e f*/
		  Sum= 
		  SUM&wgt. = SWT
		  N      = NOBS             
		  ;

	DATA &_outds_m.;
		SET _TEMP_m;

		PER_GOOD=100*(&_good_m./SWT);
		/* PER_IND=100*(IND/SWT); */
		PER_ALL=&_good_m.+&_ind_m.;
		/* PER_GOOD_IND=100*(PER_ALL/SWT); */
		per_swt=100*(swt/&_sumswt_m.);
		nbad=&_bad_m.;
		ngood=&_good_m.; 
		mbad=mbad*100;
		swt=int(swt); 

		/* per_boutcrewclose=100*(boutcrewclose/swt);  */

		LABEL MTESTVAR = "M&_var_m";

		IF &_good_m. =0 OR &_bad_m.=0 THEN LGOODBAD=.;
		ELSE LGOODBAD=LOG(&_good_m. / &_bad_m.); 

		IF &_good_m. =0 OR &_bad_m.=0 THEN LGOODBAD2=.;
		ELSE LGOODBAD2= LOG(&_bad_m/ &_TOTBAD_m.)- LOG(&_good_m. / &_TOTGOOD_m.);  

		INFVAL1=LGOODBAD*((&_good_m./&_TOTGOOD_m.) - (&_bad_m./&_TOTBAD_m.)); 
		 /* PAUL MANNI */ 
		INFVAL2=LGOODBAD2*((&_good_m./&_TOTGOOD_m.) - (&_bad_m./&_TOTBAD_m.)); 
	/* MY MACRO */ 


	proc summary missing data=&_outds_m.;
		var infval2 infval1;
		output out=_infor_m sum=;


	DATA _OUT2_m; 
		set _infor_m;
		CALL SYMPUT('_infoval_m',INFVAL1);
	run;
	quit;

%mend;
