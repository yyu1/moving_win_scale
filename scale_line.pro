;in_line is (xdim+2) x 3 line centered around the line being scaled
;hv_line is high-res ALOS HV line, and should be (dimx+2) by 3  also centered around line being scaled

;calling function should take care of the 2 x-dimension edge pixels by adding them to the input arrays

Function scale_pix, in_win, hv_win, rfdi_win
	;Scales the middle pixel given a 3x3 window
	;corresponds to method 5 in agb_scale's scale_h_pixel
	hv_thresh = 0.015

	coef_hv =  hv_win[1,1] / mean(hv_win) - 1
	coef_rfdi = 1.3 * rfdi_win[1,1] / mean(rfdi_win) - 1

	if (abs(coef_hv) lt abs(coef_rfdi)) then begin
		if (hv_win[1,1] lt hv_thresh) then return, 0.
	
		mean_in = mean(in_win)
		return, mean_in + mean_in * coef_hv	
		
	endif else begin

		mean_in = mean(in_win)
		return, mean_in + mean_in * coef_rfdi
		
	endelse


End



PRO scale_line, in_line, hv_line, rfdi_line, out_line

	dims = size(in_line, /dimensions)
	xdim = dims[0]

	hv_water_thresh = 0.015

	;out_line = fltarr(xdim-2)

	index = where((in_line[1:xdim] eq -1) and (hv_line[1:xdim] lt hv_water_thresh), count, complement = index_comp, ncomplement=comp_count)

	if (count gt 0) then out_line[index] = -1

	if (comp_count gt 0) then begin

		for i=0ULL, comp_count-1 do begin
			cur_i = index_comp[i]	
			in_win = in_line[cur_i:cur_i+2,*]
			hv_win = hv_line[cur_i:cur_i+2,*]
			rfdi_win = rfdi_line[cur_i:cur_i+2,*]

			out_line[cur_i] = scale_pix(in_win, hv_win, rfdi_win)
		endfor

	endif

End
