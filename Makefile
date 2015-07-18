CL=sbcl
ECL=ecl
TARGET=./linker

all: $(TARGET)

$(TARGET):game.lisp init.lisp make.lisp
	$(CL) --load make.lisp
run:$(TARGET)
	$(TARGET) 
test:init.lisp game.lisp run.lisp
	$(CL) --load run.lisp
ecl:init.lisp game.lisp run.lisp
	$(ECL) -load make.lisp
test1:init.lisp game.lisp run.lisp
	$(ECL) -load run.lisp
clean:
	rm -rf $(TARGET)  *.o *.fasl
