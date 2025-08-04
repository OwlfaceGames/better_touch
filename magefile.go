//go:build mage
// +build mage

package main

import (
	"fmt"
	"os"
	// "runtime"
	"github.com/magefile/mage/sh"
)

var Default = Build

func Build() error {
	fmt.Println("Building...")

	args := []string {
		"-std=c99",
		"main.c",
		"-o",
		"btouch",
	}

	return sh.Run("gcc", args...)
}

func Run() error {
	fmt.Println("Running...")
	return sh.RunV("./btouch")
}

func Clean() {
	fmt.Println("Cleaning...")
	os.RemoveAll("btouch")
}
