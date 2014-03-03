
%MACRO ks_format(_ds_kf, _wgt_kf, _depvar_kf, _rnk_kf, _scr_kf, _ds_out_kf);

	proc sql noprint;
		create table _z_kf as
		select 
			&_rnk_kf.,
			sum(&_wgt_kf.) as total,
			sum(case when &_depvar_kf. = 1 then &_wgt_kf. else 0 end) as resp,
			sum(case when &_depvar_kf. = 0 then &_wgt_kf. else 0 end) as nonresp,
			min(&_scr_kf.) as min_score,
			max(&_scr_kf.) as max_score,
			sum(&_scr_kf.*&_wgt_kf.)/sum(&_wgt_kf.) as mean_score
		from &_ds_kf.
		group by 1;
	quit;
	

	DATA _z1_kf;
	SET _z_kf END = FINAL;
	t_resp + resp;
	t_nonresp + nonresp;
	IF FINAL THEN CALL SYMPUT('_s_resp_kf',t_resp);
	IF FINAL THEN CALL SYMPUT('s_nonresp_kf',t_nonresp);
	RUN;

	
	data &_ds_out_kf.;
	set _z1_kf;
	cum_respr = (t_resp/&_s_resp_kf.);
	cum_non_respr = (t_nonresp/&s_nonresp_kf.);
	KS = abs(cum_respr - cum_non_respr);
	respr = (resp/total);
	non_respr = (nonresp/total);
	run;
	

%mend;

