# Hello build
This image is designed to automate the process of building RPM packages and source RPMs from spec files using the Mock tool. It takes several command-line options to customize its behavior.

## Build Image
```bash
docker build --add-host server:127.0.0.1 -t hello/build .
```
## Usage

```bash
docker run --cap-add=SYS_ADMIN -it --rm \
         -v /project:/mnt \
         -w /mnt \
         hello/build \
         -r epel-8-x86_64 \
         -o /mnt/rpm \
         -s /mnt/srpm \
         --repo-host 'http://172.17.0.1' \
         '/mnt/spec/*.spec'
```
### Options

* `-r <mock_config>` Specify the Mock configuration to use. Default is **epel-8-x86_64**.
* `-o <rpm_folder>` Set the output folder for generated RPM files. Default is **./rpm**.
* `-s <srpm_folder>` Set the output folder for generated source RPM (SRPM) files. Default is **./srpm**.
* `--repo-host <repo_host>` Specify the repository host URL for custom packages. Default is **http://server**.
* `<spec_file1.spec> [spec_file2.spec ...]` List of spec files to build RPMs for.