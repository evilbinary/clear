CL=sbcl
TARGET=./linker

all: $(TARGET)

$(TARGET):game.lisp init.lisp make.lisp
	$(CL) --load make.lisp
run:$(TARGET)
	$(TARGET) 
test:init.lisp game.lisp run.lisp
	$(CL) --load run.lisp
clean:
	rm -rf $(TARGET) 
