package commands

import (
	"os"
	"path/filepath"
	"testing"
)

func TestLogout(t *testing.T) {
	// Create a temporary directory for testing
	tempDir := t.TempDir()
	
	// Create a temporary credentials file
	credentialsPath := filepath.Join(tempDir, ".miago", "credentials")
	err := os.MkdirAll(filepath.Dir(credentialsPath), 0755)
	if err != nil {
		t.Fatalf("Failed to create test directory: %v", err)
	}
	
	err = os.WriteFile(credentialsPath, []byte("test_token"), 0644)
	if err != nil {
		t.Fatalf("Failed to create test credentials file: %v", err)
	}
	
	// Override the home directory for testing
	originalHome := os.Getenv("HOME")
	os.Setenv("HOME", tempDir)
	defer os.Setenv("HOME", originalHome)
	
	// Test successful logout
	err = logout()
	if err != nil {
		t.Errorf("Expected successful logout, got error: %v", err)
	}
	
	// Verify the credentials file was removed
	if _, err := os.Stat(credentialsPath); !os.IsNotExist(err) {
		t.Error("Expected credentials file to be removed")
	}
	
	// Test logout when no session exists
	err = logout()
	if err == nil {
		t.Error("Expected error when no session exists")
	}
}
