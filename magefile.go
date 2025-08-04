//go:build mage
// +build mage

package main

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"github.com/magefile/mage/sh"
)

var Default = Build

// Platform represents a target platform
type Platform struct {
	OS     string
	Arch   string
	CC     string
	CFLAGS []string
}

// Supported platforms for release builds
var platforms = []Platform{
	{"linux", "x86_64", "gcc", []string{"-std=c99"}},
	{"linux", "arm64", "aarch64-linux-gnu-gcc", []string{"-std=c99", "-static"}},
	{"macos", "x86_64", "clang", []string{"-std=c99"}},
	{"macos", "arm64", "clang", []string{"-std=c99", "-target", "arm64-apple-macos11"}},
}

func Build() error {
	fmt.Println("Building for current platform...")

	args := []string{
		"-std=c99",
		"main.c",
		"-o",
		"btouch",
	}

	return sh.Run("gcc", args...)
}

func Release() error {
	fmt.Println("Building release binaries for all platforms...")

	// Create releases directory
	if err := os.MkdirAll("releases", 0755); err != nil {
		return fmt.Errorf("failed to create releases directory: %v", err)
	}

	for _, platform := range platforms {
		if err := buildForPlatform(platform); err != nil {
			fmt.Printf("Warning: Failed to build for %s-%s: %v\n", platform.OS, platform.Arch, err)
			continue
		}
		fmt.Printf("✓ Built btouch-%s-%s\n", platform.OS, platform.Arch)
	}

	fmt.Println("\nRelease binaries built successfully!")
	fmt.Println("Upload the files in the 'releases' directory to your GitHub release.")
	return nil
}

func buildForPlatform(platform Platform) error {
	outputName := fmt.Sprintf("btouch-%s-%s", platform.OS, platform.Arch)
	outputPath := filepath.Join("releases", outputName)

	// Skip if we can't cross-compile on this system
	if platform.OS != runtime.GOOS && !canCrossCompile(platform) {
		return fmt.Errorf("cross-compilation not available for %s-%s on %s", platform.OS, platform.Arch, runtime.GOOS)
	}

	args := append(platform.CFLAGS, "main.c", "-o", outputPath)

	return sh.Run(platform.CC, args...)
}

func canCrossCompile(platform Platform) bool {
	// Check if the required cross-compiler is available
	return sh.Run(platform.CC, "--version") == nil
}

func Run() error {
	fmt.Println("Running...")
	return sh.RunV("./btouch")
}

func Clean() error {
	fmt.Println("Cleaning...")
	if err := os.RemoveAll("btouch"); err != nil {
		return err
	}
	return os.RemoveAll("releases")
}

func CleanReleases() error {
	fmt.Println("Cleaning release binaries...")
	return os.RemoveAll("releases")
}
