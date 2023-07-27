# `output(.exe)`

Simple executable that prints `--stdout` and `--stderr` arguments to `stdout` or `stderr` respectively, in the order that the arguments are given, and exits with the exit code specified by the `--exit` argument.

```bash
> ./output --stdout 1 --stderr 2 --stdout 3 --exit 4
1
2
3
> echo $?
4
```

## Build

```
GOOS=darwin GOARCH=amd64 go build -o darwin/amd64/output .
GOOS=darwin GOARCH=arm64 go build -o darwin/arm64/output .
GOOS=linux GOARCH=amd64 go build -o linux/amd64/output .
GOOS=windows GOARCH=amd64 go build -o windows/amd64/output.exe .
GOOS=windows GOARCH=arm64 go build -o windows/arm64/output.exe .
```