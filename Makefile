CL=sbcl
TARGET=./linker

all: $(TARGET)

$(TARGET):game.lisp init.lisp make.lisp
	$(CL) --load make.lisp
run:$(TARGET)
	$(TARGET) 
clean:
	rm -rf $(TARGET) 
