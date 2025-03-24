GLB_DEFINE_PATH = "../rtl/glb_def"
RTL_PATH = "../rtl/common_module"
CLASS_LIB = "../sim/class_dir"
SIM_DEFINE = "../sim/sim_def_dir"
TB_PATH = "../sim/tb_dir"


#选择仿真顶层模块名,先预留，后面在写
TOP_NAME = tb_top 

#该选项用于调试systemverilog的仿真文件，比如说断点调试 1:开启 0：关闭
DEBUG_MODE = 1

#在Makefile中，符号$用于在Makefle中调用自己的变量，如果是$$则是将makefile中的变量传递给shell进行使用
#Makefile 默认使用 /bin/sh 来执行每一行命令，因此你可以直接在 Makefile 中写入 Bash Shell 的命令。
#在每个命令前加上 @ 符号，表示执行该命令时只显示命令的输出。如果不加 @，Makefile 会先输出命令本身，然后再执行命令。
#在 Makefile 中，反斜杠 \ 用于表示行继续符。它告诉 Makefile 解析器，将当前行与下一行连接在一起，作为同一条命令来处理。

#生成rtl_list_file
# >表示覆盖， >>才表示附加

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
		verdi -f rtl_list_file \
		-top $(TOP_NAME) \
		-ssf tb_top.fsdb ;\
	fi
	
			
