package main

import (
	"flag"
	"fmt"
	"os"
	"strings"
)

type stderr []string
func (e *stderr) String() string {
	return strings.Join(*e, ";")
}
func (e *stderr) Set(value string) error {
	fmt.Fprintln(os.Stderr, value)
	*e = append(*e, value)
	return nil
}

type stdout []string
func (o *stdout) String() string {
	return strings.Join(*o, ";")
}
func (o *stdout) Set(value string) error {
	fmt.Fprintln(os.Stdout, value)
	*o = append(*o, value)
	return nil
}

var stderrFlag stderr
var stdoutFlag stdout

func init() {
	const stderrHelp = "Prints the argument, followed by a newline, to stderr"
	flag.Var(&stderrFlag, "e", stderrHelp)
	flag.Var(&stderrFlag, "stderr", stderrHelp)
	const stdoutHelp = "Prints the argument, followed by a newline, to stdout"
	flag.Var(&stdoutFlag, "o", stdoutHelp)
	flag.Var(&stdoutFlag, "stdout", stdoutHelp)
}

func main() {
	var exit = flag.Int("exit", 0, "Sets the exit code")
	flag.Parse()
	os.Exit(*exit)
}
