function [bit_cnt bit_err_cnt rate] = ber(x_init, x_final)

bit_cnt = length(x_init(:));
diff_arr = x_init~=x_final;
bit_err_cnt = sum(diff_arr(:));
rate = bit_err_cnt/bit_cnt;
