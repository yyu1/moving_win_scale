;Scales floating point image using hv, and rfdi
;in_image should be exactly 1/3 dimension of the hv and rfdi files
;xdim and ydim refer to dimensions of in_file

PRO expand_line_small, in_line_small, out_line
;expand an input line to an outputline that's 3xdim + 2
	n_pix = n_elements(in_line_small)
	n_pix_out = n_pix*3+2

	out_line[0] = in_line_small[0]
	out_line[n_pix_out-1] = in_line_small[n_pix-1]
	for i=0ULL, n_pix-1 do begin
		out_line[(i*3)+1:(i*3)+2] = in_line_small[i]
	endfor

End


PRO scale_image, in_file, hv_file, rfdi_file, out_file, xdim, ydim
	print, 'Starting image scaling with moving window', systime()
	print, 'in_file', in_file
	print, 'hv_file', hv_file
	print, 'rfdi_file', rfdi_file
	print, 'out_file', out_file
	print, 'xdim, ydim', xdim, ydim
	out_xdim = ulong(xdim) * 3
	out_ydim = ulong(ydim) * 3

	openr, in_lun, in_file, /get_lun
	openr, hv_lun, hv_file, /get_lun
	openr, rfdi_lun, rfdi_file, /get_lun

	openw, out_lun, out_file, /get_lun


	;prev_in = fltarr(out_xdim+2)
	;cur_in = fltarr(out_xdim+2)
	;next_in	= fltarr(out_xdim+2)
	block_in = fltarr(out_xdim+2,3)

	;prev_hv = fltarr(out_xdim+2)
	;cur_hv = fltarr(out_xdim+2)
	;next_hv = fltarr(out_xdim+2)
	block_hv = fltarr(out_xdim+2,3)

	;prev_rfdi = fltarr(out_xdim+2)
	;cur_rfdi = fltarr(out_xdim+2)
	;next_rfdi = fltarr(out_xdim+2)
	block_rfdi = fltarr(out_xdim+2,3)

	tmp_flt_line = fltarr(out_xdim)
	tmp_flt_line_in = fltarr(xdim)
	tmp_flt_line_exp = fltarr(out_xdim+2)
	out_line = fltarr(out_xdim)


	;set up first line

	readu, in_lun, tmp_flt_line_in
	expand_line_small, tmp_flt_line_in, tmp_flt_line_exp
	block_in[*,0] = tmp_flt_line_exp
	block_in[*,1] = tmp_flt_line_exp
	block_in[*,2] = tmp_flt_line_exp

	readu, hv_lun, tmp_flt_line
	tmp_flt_line_exp[1:out_xdim] = tmp_flt_line
	tmp_flt_line_exp[0] = tmp_flt_line_exp[1]
	tmp_flt_line_exp[out_xdim+1] = tmp_flt_line_exp[out_xdim]
	block_hv[*,0] = tmp_flt_line_exp
	block_hv[*,1] = tmp_flt_line_exp
	readu, hv_lun, tmp_flt_line
	tmp_flt_line_exp[1:out_xdim] = tmp_flt_line
	tmp_flt_line_exp[0] = tmp_flt_line_exp[1]
	tmp_flt_line_exp[out_xdim+1] = tmp_flt_line_exp[out_xdim]
	block_hv[*,2] = tmp_flt_line_exp

	readu, rfdi_lun, tmp_flt_line
	tmp_flt_line_exp[1:out_xdim] = tmp_flt_line
	tmp_flt_line_exp[0] = tmp_flt_line_exp[1]
	tmp_flt_line_exp[out_xdim+1] = tmp_flt_line_exp[out_xdim]
	block_rfdi[*,0] = tmp_flt_line_exp
	block_rfdi[*,1] = tmp_flt_line_exp
	readu, rfdi_lun, tmp_flt_line
	tmp_flt_line_exp[1:out_xdim] = tmp_flt_line
	tmp_flt_line_exp[0] = tmp_flt_line_exp[1]
	tmp_flt_line_exp[out_xdim+1] = tmp_flt_line_exp[out_xdim]
	block_rfdi[*,2] = tmp_flt_line_exp

	scale_line, block_in, block_hv, block_rfdi, out_line

	writeu, out_lun, out_line	


	for j=2ULL, out_ydim-1 do begin
		if (j mod (out_ydim/100) eq 0) then print, j
		if ((j mod 3) eq 0) then begin
			readu, in_lun, tmp_flt_line_in
			expand_line_small, tmp_flt_line_in, tmp_flt_line_exp
			block_in[*,0] = block_in[*,1]
			block_in[*,1] = block_in[*,2]
			block_in[*,2] = tmp_flt_line_exp
		endif else begin
			block_in[*,0] = block_in[*,1]
			block_in[*,1] = block_in[*,2]
		endelse

		readu, hv_lun, tmp_flt_line
		tmp_flt_line_exp[1:out_xdim] = tmp_flt_line
		tmp_flt_line_exp[0] = tmp_flt_line_exp[1]
		tmp_flt_line_exp[out_xdim+1] = tmp_flt_line_exp[out_xdim]
		block_hv[*,0] = block_hv[*,1]
		block_hv[*,1] = block_hv[*,2]
		block_hv[*,2] = tmp_flt_line_exp

		readu, rfdi_lun, tmp_flt_line
		tmp_flt_line_exp[1:out_xdim] = tmp_flt_line
		tmp_flt_line_exp[0] = tmp_flt_line_exp[1]
		tmp_flt_line_exp[out_xdim+1] = tmp_flt_line_exp[out_xdim]
		block_rfdi[*,0] = block_rfdi[*,1]
		block_rfdi[*,1] = block_rfdi[*,2]
		block_rfdi[*,2] = tmp_flt_line_exp

		scale_line, block_in, block_hv, block_rfdi, out_line

		writeu, out_lun, out_line

	endfor

	;handle last line
	block_in[*,0] = block_in[*,1]
	block_in[*,1] = block_in[*,2]	

	block_hv[*,0] = block_hv[*,1]
	block_hv[*,1] = block_hv[*,2]

	block_rfdi[*,0] = block_rfdi[*,1]
	block_rfdi[*,1] = block_rfdi[*,2]

	scale_line, block_in, block_hv, block_rfdi, out_line
	writeu, out_lun, out_line


	free_lun, in_lun, hv_lun, rfdi_lun, out_lun	
	print, 'done!', systime()
End
