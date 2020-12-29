# G-code Snippets, Config and Scripts for Using PrusaSlicer (Slic3r) with the Replicator 2x

Based on the excellent work by dr-lex for the Flashforge Creator Pro - [See his website](https://www.dr-lex.be/software/ffcp-slic3r-profiles.html#config) for instructions on installing and using these files.

TL;DR instructions to use the scripted, custom config bundle generation:

- In the configuration menu, choose "Take configuration snapshot" to back up your existing configs
- Remove the existing profiles from your PrusaSlicer install, if you imported an earlier version of this bundle.
- Copy `config.sample.mk` to `config.mk` and edit it to point to the right `make_fcp_x3g` script location (and optionally octoprint server)
- Run `make`
- Import `Slic3r-configBundles/custom.ini` into PrusaSlicer.

## Dependencies

For config bundle generation on Windows, use [scoop](https://scoop.sh) to
install the packages `busybox` `make` and `python`.

If you want to use `make_fcp_x3g` on Windows without WSL (not fully tested),
you'll also need `perl`, `gpx`, and `unxutils` installed. You may need to run
`scoop reset make` and `scoop reset busybox` after installing `unxutils` for
this to work.

On Linux, you will need bash, make, python3, perl, bc, and gpx. You're likely to
already have all these installed except for gpx.

## Contents

This repository contains three things:

### G-code snippets

Use in combination with the profiles. The makefile will automatically inject them into the config snippets, so don't modify GCode in the config snippets!

### PrusaSlicer config bundles

The actual configuration bundles that can be imported into PrusaSlicer.
Now with the script and makefile, the G-code snippets are automatically inserted into the configs.

These configs and G-code are made specifically for PrusaSlicer. They might work in the original Slic3r from which PrusaSlicer was forked, but I give no guarantees.

### The *make_fcp_x3g* script

This script can be configured as a post-processing script in PrusaSlicer to run specific post-processing scripts and finally generate an X3G file by invoking [GPX](https://github.com/markwal/GPX).

This is a Bash script that will work in Linux and Mac OS X. It can also be used with the WSL Linux environment in recent versions of **Windows.** To do this: create a BAT file, named for instance `slic3r_postprocess.bat`, that contains the following:

```cmd
set fpath=%~1
set fpath=%fpath:'='"'"'%
bash /your/linux/path/to/make_fcp_x3g -w '%fpath%'
```

Replace “`/your/linux/path/to`” with the path to the actual location inside the Linux environment where you placed the *make_fcp_x3g* script (and make sure it is executable). Finally in PrusaSlicer, configure the Windows path to the .BAT file in all your *Print Settings* → *Output options* → *Post-processing scripts*.\
For instance if your Windows account name is *Foobar* and you named the file `slic3r_postprocess.bat` and placed it in your documents folder, then the path in PrusaSlicer should be: “`C:\Users\Foobar\Documents\slic3r_postprocess.bat`”.

For this to work, inside your WSL environment you must have a command `wslpath` that converts Windows paths to their Linux equivalent. This is automatically the case if you have Windows 10 version 1803 or newer with a standard WSL image. If not, follow the instructions in the file `poor_mans_wslpath.txt``.

As a fallback for those Windows users who cannot use WSL, there is an alternative BAT script `simple_ffcp_postproc.bat` that can be used as post-processing script. It performs the two most essential functions of the `make_fcp_x3g` script, namely the tool temperature workaround and invoking GPX. It requires Perl to be installed, instructions are inside the file. This is only the bare minimum to use PrusaSlicer with the FFCP, it is much recommended to use the Bash script instead if you can.

## Dev notes

- Slic3r/PrusaSlicer placeholder reference:
  - <http://mauk.cc/mediawiki/index.php/Slic3r_placeholders>
  - <https://github.com/slic3r/Slic3r/wiki/FAQ#what-placeholders-can-i-use-in-custom-g-code>

## License

These files are released under a Creative Commons Attribution 4.0 International license.
