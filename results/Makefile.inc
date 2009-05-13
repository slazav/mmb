src = $(wildcard data_in/*)

all: $(addprefix data_out/, $(dst))
$(addprefix data_out/, $(dst)): $(src)
	./mk_res
