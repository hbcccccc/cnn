GLB_DEFINE_PATH = "../rtl/glb_def"
RTL_PATH = "../rtl/rgb_ctrl"
CLASS_LIB = "../sim/class_dir"
SIM_DEFINE = "../sim/sim_def_dir"
TB_PATH = "../sim/tb_rgb"

TOP_NAME = tb_rgb 
FSDB_NAME = tb_rgb.fsdb

#该选项用于调试systemverilog的仿真文件，比如说断点调试 1:开启 0：关闭
DEBUG_MODE = 1


#生成rtl_list_file

gen:
	@> rtl_list_file
	@for dir in	$(SIM_DEFINE) $(CLASS_LIB) $(GLB_DEFINE_PATH) $(TB_PATH) $(RTL_PATH);do\
			echo "+incdir$$dir" >> rtl_list_file; \
			find $$dir -mindepth 1 -type d > directories_list;\
			while read directories_list;do\
				echo "+incdir$$directories_list" >> rtl_list_file;\
			done < directories_list;\
			rm -f directories_list;\
	done
	@for dir in	$(SIM_DEFINE) $(CLASS_LIB) $(GLB_DEFINE_PATH) $(TB_PATH) $(RTL_PATH);do\
			find $$dir -mindepth 0 -type f \( -name "*.v" -o -name "*.sv" \)  >> file_list_buffer;\
			while read file_list_buffer;do\
				echo "$$file_list_buffer" >> rtl_list_file;\
			done < file_list_buffer;\
			rm -f file_list_buffer;\
	done
		
#编译选项
comp:
	vcs -full64 +v2k -sverilog -debug_access+all -f rtl_list_file

sim:
	./simv

verdi:
	@if [ $(DEBUG_MODE) -eq 1 ]; then \
		verdi -f rtl_list_file -sv\
		-top $(TOP_NAME) \
		-ssf $(FSDB_NAME) ;\
	fi
	
			
