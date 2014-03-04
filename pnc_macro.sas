
%macro pnc_macro(
		_ds_in_dev_pm, 
		_ds_in_val_pm, 
		_excel_steps_pm, 
		_excel_summary_pm, 
		_excel_summary_short_pm, 
		_transform_macro_pm,
		_pnc_vars_pm
		);

	%let _var_identifier_pm = variable;
	%let _variable_score_pm = variable_score;

	data _mod_iter_summ_g_pm;
		set _null_;
	run;

	data _mod_iter_summ_short_g_pm;
		set _null_;
	run;	

	data _x_dev_pm ;
		set &_ds_in_dev_pm. (keep = &_pnc_vars_pm. &depvar. &wgt. /* &cust_id. */) ;
		%&_transform_macro_pm.;
	run;

	data _x_val_pm ;
		set &_ds_in_val_pm. (keep = &_pnc_vars_pm. &depvar. &wgt. /* &cust_id. */) ;
		%&_transform_macro_pm.;
	run;
		
	data _mod_iter_summ_pm;
		set _null_;
	run;

	%let _len_glmv = 0;
	%get_len_macro_var(&_pnc_vars_pm.);

	%let _max_vars_pm = &_len_glmv.;
	%let _iteration_count_pm = 0;

	%do _i_pm = 1 %to &_max_vars_pm.;

		%do _j_pm = %sysevalf(&_i_pm.+1) %to &_max_vars_pm.;

			%do _k_pm = %sysevalf(&_j_pm.+1) %to &_max_vars_pm.;

				%let _iteration_count_pm = %sysevalf(&_iteration_count_pm. + 1);
/* 				%put %scan(&_pnc_vars_pm., &_i_pm, %str( )), %scan(&_pnc_vars_pm., &_j_pm, %str( )), %scan(&_pnc_vars_pm., &_k_pm, %str( ));
				%put &_i_pm., &_j_pm., &_k_pm.;
				%put &_iteration_count_pm.; */

				%let _var_list_pm = %scan(&_pnc_vars_pm., &_i_pm, %str( )) %scan(&_pnc_vars_pm., &_j_pm, %str( )) %scan(&_pnc_vars_pm., &_k_pm, %str( ));
				%let _var_combination_pm = %cmpres(&_i_pm.-&_j_pm.-&_k_pm.);

				%model_input_autoiter(_x_dev_pm, _x_val_pm, &_var_list_pm., &_var_combination_pm., _stats_summary_pm, &_var_identifier_pm.);

				data _mod_iter_summ_pm;	
					format &_var_identifier_pm. $32.;			
					set _mod_iter_summ_pm _stats_summary_pm;
				run;

				/* proc print data = _stats_summary_pm; run;	 */


				%do _l_pm = %sysevalf(&_k_pm.+1) %to &_max_vars_pm.;

					%let _iteration_count_pm = %sysevalf(&_iteration_count_pm. + 1);
/* 					%put %scan(&_pnc_vars_pm., &_i_pm, %str( )), %scan(&_pnc_vars_pm., &_j_pm, %str( )), %scan(&_pnc_vars_pm., &_k_pm, %str( )), %scan(&_pnc_vars_pm., &_l_pm, %str( ));
					%put &_i_pm., &_j_pm., &_k_pm., &_l_pm;
					%put &_iteration_count_pm.; */

					%let _var_list_pm = %scan(&_pnc_vars_pm., &_i_pm, %str( )) %scan(&_pnc_vars_pm., &_j_pm, %str( )) %scan(&_pnc_vars_pm., &_k_pm, %str( )) %scan(&_pnc_vars_pm., &_l_pm, %str( ));
					%let _var_combination_pm = %cmpres(&_i_pm.-&_j_pm.-&_k_pm.-&_l_pm.);

					%model_input_autoiter(_x_dev_pm, _x_val_pm, &_var_list_pm., &_var_combination_pm., _stats_summary_pm, &_var_identifier_pm.);	

					data _mod_iter_summ_pm;	
						format &_var_identifier_pm. $32.;			
						set _mod_iter_summ_pm _stats_summary_pm;
					run;

					/* proc print data = _stats_summary_pm; run; */


					%do _m_pm = %sysevalf(&_l_pm.+1) %to &_max_vars_pm.;

						%let _iteration_count_pm = %sysevalf(&_iteration_count_pm. + 1);
/* 						%put %scan(&_pnc_vars_pm., &_i_pm, %str( )), %scan(&_pnc_vars_pm., &_j_pm, %str( )), %scan(&_pnc_vars_pm., &_k_pm, %str( )), %scan(&_pnc_vars_pm., &_l_pm, %str( )), %scan(&_pnc_vars_pm., &_m_pm, %str( ));
						%put &_i_pm., &_j_pm., &_k_pm., &_l_pm, &_m_pm;
						%put &_iteration_count_pm.; */

						%let _var_list_pm = %scan(&_pnc_vars_pm., &_i_pm, %str( )) %scan(&_pnc_vars_pm., &_j_pm, %str( )) %scan(&_pnc_vars_pm., &_k_pm, %str( )) %scan(&_pnc_vars_pm., &_l_pm, %str( )) %scan(&_pnc_vars_pm., &_m_pm, %str( ));
						%let _var_combination_pm = %cmpres(&_i_pm.-&_j_pm.-&_k_pm.-&_l_pm.-&_m_pm.);

						%model_input_autoiter(_x_dev_pm, _x_val_pm, &_var_list_pm., &_var_combination_pm., _stats_summary_pm, &_var_identifier_pm.);

						data _mod_iter_summ_pm;	
							format &_var_identifier_pm. $32.;			
							set _mod_iter_summ_pm _stats_summary_pm;
						run;

						/* proc print data = _stats_summary_pm; run; */	
						
					%end;

				%end;
			

			%end;			

		%end; 
	
	%end;

	%post_autoiter_macro(_mod_iter_summ_pm, 1, _mod_iter_summ_g_pm, _mod_iter_summ_short_pm, _mod_iter_summ_short_g_pm, &_var_identifier_pm., &_variable_score_pm.);

	%put "iteration_count", &_iteration_count_pm.;

	proc export data=_mod_iter_summ_g_pm outfile=&_excel_summary_pm. dbms=csv replace; run; 
	proc export data=_mod_iter_summ_short_g_pm outfile=&_excel_summary_short_pm. dbms=csv replace; run; 


%mend;
