# `input(.exe)`

Simple executable that prints the entire command line, and every argument separately, in the order that the arguments are given.

```bash
> ./input 1 2 3
input 1 2 3
/path/to/input
1
2
3
```

## Build

```
GOOS=darwin GOARCH=amd64 go build -o darwin/amd64/input .
GOOS=darwin GOARCH=arm64 go build -o darwin/arm64/input .
GOOS=linux GOARCH=amd64 go build -o linux/amd64/input .
GOOS=linux GOARCH=arm64 go build -o linux/arm64/input .
GOOS=windows GOARCH=amd64 go build -o windows/amd64/input.exe .
GOOS=windows GOARCH=arm64 go build -o windows/arm64/input.exe .
```