package main

import (
	"fmt"
	"os"

	"github.com/SumnersMetaverse/Miago.AI/commands"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: miago <command>")
		fmt.Println("Available commands:")
		fmt.Println("  logout - Log out of the current session")
		os.Exit(1)
	}

	command := os.Args[1]

	switch command {
	case "logout":
		if err := commands.Run(); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	default:
		fmt.Fprintf(os.Stderr, "Unknown command: %s\n", command)
		os.Exit(1)
	}
}
