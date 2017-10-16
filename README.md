This repository contains so far only one utility to work with device trees.

Here is how to use it:

1. Your linux src goes to $ROOT/linux
2. This script goes to $ROOT/scripts
3. Run:
```
	cd $ROOT/linux
	find arch/arm/boot/dts/ \( -name '*\.dts' -o -name '*\.dtsi' \)  -printf "%f\n" > ../scripts/list.txt
```
4. Run:
```
 	cd $ROOT/scripts
 	./dts-tree.pl
```

 If your setup is different, adjust the "$path" variable in the script.
