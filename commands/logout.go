package commands

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

// LogoutCmd represents the logout command
var LogoutCmd = &cobra.Command{
	Use:   "logout",
	Short: "Logout from the current session",
	Long: `Logout from the current session by removing stored credentials
and session tokens. This will clear all authentication data.`,
	Run: func(cmd *cobra.Command, args []string) {
		if err := logout(); err != nil {
			fmt.Fprintf(os.Stderr, "Error during logout: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("Successfully logged out")
	},
}

// logout performs the logout operation
func logout() error {
	// Get user's home directory
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to get home directory: %w", err)
	}

	// Define the credentials file path
	credentialsPath := filepath.Join(homeDir, ".miago", "credentials")

	// Check if credentials file exists
	if _, err := os.Stat(credentialsPath); os.IsNotExist(err) {
		return fmt.Errorf("no active session found")
	}

	// Remove the credentials file
	if err := os.Remove(credentialsPath); err != nil {
		return fmt.Errorf("failed to remove credentials: %w", err)
	}

	return nil
}
