;sample input line [1, 2, 2, 5, 3]


in_line = fltarr(17,3)
in_line[*,0] =  [1., 1, 1, 1, 2, 2, 2, 2, 2, 2, 5, 5, 5, 3, 3, 3, 3]
in_line[*,1] = in_line[*,0]
in_line[*,2] = in_line[*,0]

hv_line = fltarr(17,3)

hv_line[*,0] = [0., 0., 1, 2, 5, 4, 5, 6, 3, 5, 10, 7, 5, 23, 5, 10, 10]
hv_line[*,1] = [1., 1., 2, 3, 5, 7, 6, 4, 4, 5, 8, 8, 6, 15, 10, 23, 23]
hv_line[*,2] = [5., 5., 1, 2, 3, 4, 4, 5, 3, 7, 6, 9, 10, 10, 12, 13, 13]

scale_line, in_line, hv_line, out_line

print, out_line

end
