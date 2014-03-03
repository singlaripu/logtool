

%macro get_len_macro_var(_varlist_glmv);

	%let _len_glmv = 1;
	%let _var_glmv = %scan(&_varlist_glmv., &_len_glmv., %str( ));

	%do %while (&_var_glmv. ne %str( ));	

		/* %put &_var_glmv.; */
		%let _len_glmv = %eval(&_len_glmv. + 1);
		%let _var_glmv = %scan(&_varlist_glmv., &_len_glmv., %str( ));

	%end;

	%let _len_glmv = %eval(&_len_glmv. - 1);

%mend;
