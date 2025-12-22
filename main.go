package main

import (
	"fmt"
	"os"

	"github.com/SumnersMetaverse/Miago.AI/commands"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "miago",
	Short: "Miago AI CLI tool",
	Long:  `Miago AI is a command-line interface tool for managing authentication and sessions.`,
}

func init() {
	// Add commands to root
	rootCmd.AddCommand(commands.LogoutCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
