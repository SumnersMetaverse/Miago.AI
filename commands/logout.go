package commands

import (
	"fmt"
	"os"
	"path/filepath"
)

// Logout represents the logout command
type Logout struct {
	sessionFile string
}

// NewLogout creates a new Logout command instance
func NewLogout() *Logout {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		homeDir = "."
	}
	return &Logout{
		sessionFile: filepath.Join(homeDir, ".miago", "session"),
	}
}

// Execute performs the logout operation
func (l *Logout) Execute() error {
	// Check if session file exists
	if _, err := os.Stat(l.sessionFile); os.IsNotExist(err) {
		return fmt.Errorf("no active session found")
	}

	// Remove the session file
	if err := os.Remove(l.sessionFile); err != nil {
		return fmt.Errorf("failed to remove session: %w", err)
	}

	fmt.Println("Successfully logged out")
	return nil
}

// Run is a convenience method that creates and executes the logout command
func Run() error {
	logout := NewLogout()
	return logout.Execute()
}
