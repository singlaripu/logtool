
%macro auto_treat_missing(_ds_atm);

	data &_ds_atm.;
		set &_ds_atm.;

		ARRAY ZERO _NUMERIC_;
		DO OVER ZERO;
			IF ZERO IN (-99999996, -99999995) THEN ZERO = 0;
			ELSE IF missing(ZERO) THEN ZERO = 0;

		END;
		
	run;

%mend;
