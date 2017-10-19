This repository contains so far only one utility to work with device trees.

Here is how to use it:

1. Your linux src goes to $ROOT/linux
2. This script goes to $ROOT/scripts
3. Run:
```
	cd $ROOT/linux
	# linux:
	find arch/arm/boot/dts/ \( -name '*\.dts' -o -name '*\.dtsi' \)  -printf "%f\n" > ../scripts/list.txt
	# Mac:
	find arch/arm/boot/dts/ \( -name '*\.dts' -o -name '*\.dtsi' \) -print | xargs basename > ../scripts/list.txt
```
4. Run:
```
 	cd $ROOT/scripts
 	./dts-tree.pl
```

If your setup is different, adjust the "$path" variable in the script.

This script prints two trees. For example;

|----imx6qdl-wandboard.dtsi
|    |----imx6qdl-wandboard-revb1.dtsi
|    |    |----imx6dl-wandboard-revb1.dts
|    |    |----imx6q-wandboard-revb1.dts


imx6qdl-wandboard.dtsi is included by imx6qdl-wandboard-revb1.dtsi which is
included by both imx6dl-wandboard-revb1.dts and imx6q-wandboard-revb1.dts.

On the other hand;

>----imx6dl-wandboard-revb1.dts
>    >----imx6dl.dtsi
>    >    >----imx6qdl.dtsi
>    >----imx6qdl-wandboard-revb1.dtsi
>    >    >----imx6qdl-wandboard.dtsi

imx6dl-wandboard-revb1.dts includes imx6qdl-wandboard-revb1.dtsi which includes
imx6qdl-wandboard.dtsi.
