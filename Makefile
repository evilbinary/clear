CL=sbcl
TARGET=build/linker

all: $(TARGET)

$(TARGET):game.lisp init.lisp make.lisp
	$(CL) --load make.lisp
	mv linker build/
run:$(TARGET)
	build/linker 
clean:
	rm -rf build/linker
