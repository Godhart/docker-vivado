# Run Xilinx Vivado inside Docker

## Build instructions

1. Download full Vivado distributive

2. Put distributive into the `Distribs` folder (or another name you like) in the root of this working tree

> As an alternative to steps 1 and 2 you can mount a folder with already downloaded data into `Distribs` folder since Vivado distributives are really huge

3. Change values in `make_env-default` file as required

> You may start with specifying only corresponding Vivado `version` and distributive data relative location path as `distr_data`, but
> take a NOTE: different Vivado versions may require different base images, libs for the installer and target software to work
> Base image is selected with variables `base` and `base_ver`
> Libs required for installer are specified in `distr_libs` variable
> Libs required for target software are specified in `add_apps` variable.
> You may also specify in `add_apps` additional software that is involved in your build process like `git` etc.

> Also to make it easier to fiddle with settings for different versions build process is split into few stages to save rebuild times.

4. Make sure docker image size limit is greater than 90GB for Vivado 2020.1 and you have enough free space where docker data folder is located (I suggest you 150+GB). The final image is around 40GB, depending on config

5. Do if you don't have yet `install_config.txt` for your Vivado version:
  * run `make distr config`
  * update `install_config.txt` in `vivado-<version>-default` as necessary

6. Do if you already have `install_config.txt` file:
  * make folder with name `vivado-<version>-default`
  * copy configuration file into it
  * run `make distr`

7. Run `make image` to make final image. It would be named as `<repo>/vivado-default:<version>`

8. To save space on your drive run `make tar prune import` which would leave you with just final image

## Export image to share it over lan / via portable hdd etc.

1. Build image 
2. Export it to tar with `make tar`. Tar for image would be located in `vivado-<version>-default`
3. Copy it over lan along with `make_env-default` file

## Import image over lan / via portable hdd etc.

1. Clone this repo on target machine
2. Get `make_env-default` for imported image and put it into root of working tree (replacing original)
3. Make folder named `vivado-default:<version>` where `<version>` is value from `make_env-default`
4. Put tar file into that folder. Take a Note - file's name before '.tar' should be same as folder's name
5. Run `make import`. After import is completed tar file would be removed

## Making multiple images for different Vivado versions and/or configurations

It's possible to make multiple images for different Vivado versions and/or configurations and preserve settings for each of them

For this:

1. Make copy of `make_env-default`, with name like `make_env-<suffix>`
2. Change necessary values in the new file
3. Build as always providing an additional option to each make command like `make ... env=<suffix>` where `<suffix>` is part of you new make_env file
4. By default images and folder names suffix `-default` mentioned in doc above would be replaced with `-<suffix>`
5. You may override suffix for images and folders by adding value `suffix` to your make_env file
6. You may change default environment with `make default_env env=<suffix>`

## Tested

* Xilinx_Unified_2020.1_0602_1208
* Manjaro Linux 21.0.7 with Docker Docker version 20.10.8, build 3967b7d28e

## Run Vivado and Tests

### Printing Vivado version

```bash
make version
```

### Starting Vivado in TCL mode

```bash
make tcl
```

> Make sure you save data to `/home/vivado/workspace`. It'll be available from `vivado-<version>-default` folder in this working tree.
> Otherwise you'll lose you data

### Starting Vivado in GUI mode

```bash
make gui
```

> Make sure you save data to `/home/vivado/workspace`. It'll be available from `vivado-<version>-default` folder in this working tree.
> Otherwise you'll lose you data

### Running test simulation

```bash
make test_sim
```

### Running test synthesis

```bash
make test_synth
```

then cleanup test artifacts with 
```bash
make test_clean
```

### Run bash

```bash
make bash
```

## More info about make commands

```bash
make help
```

## More info about installing Vivado in batch mode

More information about installing Vivado in batch mode can be found in the following [guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_1/ug973-vivado-release-notes-install-license.pdf).
