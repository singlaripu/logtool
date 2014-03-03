
%macro post_autoiter_macro(
		_ds_pam, 
		_iter_set_num_pam, 
		_ds_glob_agg_pam, 
		_ds_short_pam, 
		_ds_glob_agg_short_pam, 
		_var_identifier_pam, 
		_variable_score_pam
	);

	data &_ds_pam. /* (drop = concordance) */;
		retain 
			iteration_seq
			&_var_identifier_pam.
			max_vif_dev
			vif_gt2_count_dev
			max_vif_val
			vif_gt2_count_val
			max_pvalue_dev
			pvalue_gt5_cnt_dev
			max_pvalue_val
			pvalue_gt30_cnt_val
			est_sign_mismatch_cnt
			ks_bins_dev
			num_bin_size_lt8_dev
			num_bin_size_gt12_dev
			num_ro_brk_dev
			first_ro_brk_dev
			first_ro_brk_size_dev
			largest_ro_brk_dev
			largest_ro_brk_size_dev
			KS_dev
			ks_bins_val
			num_bin_size_lt8_val
			num_bin_size_gt12_val
			num_ro_brk_val
			first_ro_brk_val
			first_ro_brk_size_val
			largest_ro_brk_val
			largest_ro_brk_size_val
			KS_val
			/* sign_new_var */
			concordance1
			ks_diff
			&_variable_score_pam.
		;
		set &_ds_pam.;

		concordance1 = 1.0*concordance;

		if max_pvalue_dev < 0.0001 then max_pvalue_dev = 0;
		if max_pvalue_val < 0.0001 then max_pvalue_val = 0;

		&_variable_score_pam. = 
			(0.05 - max_pvalue_dev) * 400 +
			(0.6 - max_pvalue_val) * 35 + 
			(2 * ks_bins_dev) +
			(10 - num_bin_size_lt8_dev) + 
			(10 - num_bin_size_gt12_dev) + 
			(5 - num_ro_brk_dev) * 4 + 
			first_ro_brk_dev +
			(5 - first_ro_brk_size_dev) * 4 + 
			largest_ro_brk_dev + 
			(5 - largest_ro_brk_size_dev) * 4 + 
			(KS_dev / 4) + 
			(2 * ks_bins_val) +
			(10 - num_bin_size_lt8_val) + 
			(10 - num_bin_size_gt12_val) + 
			(5 - num_ro_brk_val) * 4 + 
			first_ro_brk_val +
			(5 - first_ro_brk_size_val) * 4 + 
			largest_ro_brk_val + 
			(5 - largest_ro_brk_size_val) * 4 + 
			(KS_val / 4) + 
			(concordance1 / 10) + 
			(7 - ks_diff) * 0.5
		;

		iteration_seq = &_iter_set_num_pam.;

	run;


	data &_ds_glob_agg_pam.;
		set &_ds_glob_agg_pam. &_ds_pam.;
	run;


	proc sql;
		create table &_ds_short_pam. as
		select 
			&_iter_set_num_pam. as iteration_seq,
			&_var_identifier_pam.,
			max_pvalue_dev,
			max_pvalue_val,
			pvalue_gt30_cnt_val,
			ks_bins_dev,
			num_bin_size_lt8_dev,
			num_bin_size_gt12_dev,
			num_ro_brk_dev,
			first_ro_brk_dev,
			first_ro_brk_size_dev,
			largest_ro_brk_dev,
			largest_ro_brk_size_dev,
			KS_dev,
			ks_bins_val,
			num_bin_size_lt8_val,
			num_bin_size_gt12_val,
			num_ro_brk_val,
			first_ro_brk_val,
			first_ro_brk_size_val,
			largest_ro_brk_val,
			largest_ro_brk_size_val,
			KS_val,
			/* sign_new_var, */
			concordance1,
			ks_diff,
			&_variable_score_pam.
		from
			&_ds_pam.
		where
			vif_gt2_count_dev = 0 and
			vif_gt2_count_val = 0 and
			pvalue_gt5_cnt_dev = 0 and
			max_pvalue_val < 0.6 and
			est_sign_mismatch_cnt = 0 and
			ks_bins_dev > 3 and 
			ks_bins_val > 3 and 
			num_ro_brk_dev < 6 and 
			num_ro_brk_val < 6 and 
			ks_diff < 7 and
			largest_ro_brk_size_dev < 5 and
			largest_ro_brk_size_val < 5			
		order by
			-&_variable_score_pam.;
	quit;

	data &_ds_glob_agg_short_pam.;
		set &_ds_glob_agg_short_pam. &_ds_short_pam.;
	run;

%mend;
