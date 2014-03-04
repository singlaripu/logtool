
%macro loop_over_varlist(_vl_lov, _mn_lov, _suff_lov);

		%let _cnt_lov_&_suff_lov. = 1;
		%let _var_lov_&_suff_lov. = %scan(&_vl_lov., &&_cnt_lov_&_suff_lov.., %str( ));

		%do %while (&&_var_lov_&_suff_lov.. ne %str( ));	

			%if %lowcase(&&_var_lov_&_suff_lov..) ^= &wgt. and %lowcase(&&_var_lov_&_suff_lov..) ^= %lowcase(&depvar.) and %lowcase(&&_var_lov_&_suff_lov..) ^= %lowcase(&cust_id.) %then %do;
				%&_mn_lov.;
			%end;

			%let _cnt_lov_&_suff_lov. = %eval(&&_cnt_lov_&_suff_lov.. + 1);
			%let _var_lov_&_suff_lov. = %scan(&_vl_lov., &&_cnt_lov_&_suff_lov.., %str( ));

		%end;
		
%mend;

