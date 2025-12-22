package commands

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestLogout_Execute_NoSession(t *testing.T) {
	// Create a temporary directory for testing
	tempDir := t.TempDir()

	logout := &Logout{
		sessionFile: filepath.Join(tempDir, "session"),
	}

	err := logout.Execute()
	if err == nil {
		t.Fatal("Expected error when no session exists, got nil")
	}

	expectedMsg := "no active session found"
	if err.Error() != expectedMsg {
		t.Errorf("Expected error message '%s', got '%s'", expectedMsg, err.Error())
	}
}

func TestLogout_Execute_Success(t *testing.T) {
	// Create a temporary directory for testing
	tempDir := t.TempDir()
	sessionFile := filepath.Join(tempDir, "session")

	// Create a session file
	if err := os.WriteFile(sessionFile, []byte("test-session"), 0644); err != nil {
		t.Fatalf("Failed to create test session file: %v", err)
	}

	logout := &Logout{
		sessionFile: sessionFile,
	}

	err := logout.Execute()
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	// Verify session file was removed
	if _, err := os.Stat(sessionFile); !os.IsNotExist(err) {
		t.Error("Session file should have been removed")
	}
}

func TestLogout_Execute_RemoveError(t *testing.T) {
	// Create a temporary directory for testing
	tempDir := t.TempDir()
	sessionFile := filepath.Join(tempDir, "session")

	// Create a session file
	if err := os.WriteFile(sessionFile, []byte("test-session"), 0644); err != nil {
		t.Fatalf("Failed to create test session file: %v", err)
	}

	// Make the file read-only to simulate remove error
	if err := os.Chmod(sessionFile, 0444); err != nil {
		t.Fatalf("Failed to change file permissions: %v", err)
	}

	// Make the directory read-only to prevent file removal
	if err := os.Chmod(tempDir, 0555); err != nil {
		t.Fatalf("Failed to change directory permissions: %v", err)
	}

	// Restore permissions after test
	defer func() {
		os.Chmod(tempDir, 0755)
		os.Chmod(sessionFile, 0644)
	}()

	logout := &Logout{
		sessionFile: sessionFile,
	}

	err := logout.Execute()
	if err == nil {
		t.Error("Expected error when unable to remove session file, got nil")
	}
}

func TestNewLogout(t *testing.T) {
	logout := NewLogout()
	if logout == nil {
		t.Fatal("NewLogout should not return nil")
	}

	if logout.sessionFile == "" {
		t.Error("sessionFile should not be empty")
	}

	// Verify the session file path contains .miago/session
	expectedSuffix := filepath.Join(".miago", "session")
	if !strings.HasSuffix(logout.sessionFile, expectedSuffix) {
		t.Errorf("sessionFile should end with .miago/session, got: %s", logout.sessionFile)
	}
}

func TestRun(t *testing.T) {
	// Create a temporary directory for testing
	tempDir := t.TempDir()
	sessionFile := filepath.Join(tempDir, "session")

	// Create a session file
	if err := os.WriteFile(sessionFile, []byte("test-session"), 0644); err != nil {
		t.Fatalf("Failed to create test session file: %v", err)
	}

	// Temporarily override the home directory
	originalHome := os.Getenv("HOME")
	defer os.Setenv("HOME", originalHome)

	// Set HOME to temp directory, but we need to create .miago subdirectory
	testHome := t.TempDir()
	os.Setenv("HOME", testHome)

	miagoDir := filepath.Join(testHome, ".miago")
	if err := os.MkdirAll(miagoDir, 0755); err != nil {
		t.Fatalf("Failed to create .miago directory: %v", err)
	}

	testSessionFile := filepath.Join(miagoDir, "session")
	if err := os.WriteFile(testSessionFile, []byte("test-session"), 0644); err != nil {
		t.Fatalf("Failed to create test session file: %v", err)
	}

	err := Run()
	if err != nil {
		t.Fatalf("Expected no error from Run(), got: %v", err)
	}

	// Verify session file was removed
	if _, err := os.Stat(testSessionFile); !os.IsNotExist(err) {
		t.Error("Session file should have been removed by Run()")
	}
}
