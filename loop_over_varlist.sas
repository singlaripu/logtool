
%macro loop_over_varlist(_vl_lov, _mn_lov);

		%let _cnt_lov = 1;
		%let _var_lov = %scan(&_vl_lov., &_cnt_lov., %str( ));

		%do %while (&_var_lov. ne %str( ));	

			%if %lowcase(&_var_lov.) ^= &wgt. and %lowcase(&_var_lov.) ^= %lowcase(&depvar.) and %lowcase(&_var_lov.) ^= %lowcase(&cust_id.) %then %do;

				%&_mn_lov.;

				%let _cnt_lov = %eval(&_cnt_lov. + 1);
				%let _var_lov = %scan(&_vl_lov., &_cnt_lov., %str( ));

			%end;

		%end;
		
%mend;

