function [symb_cnt symb_err_cnt rate] = ser(x_init, x_final)

symb_cnt = length(x_init(:));
diff_arr = x_init~=x_final;
symb_err_cnt = sum(diff_arr(:));
rate = symb_err_cnt/symb_cnt;
