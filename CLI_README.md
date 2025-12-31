# Miago CLI

A command-line interface tool for managing Miago AI sessions.

## Installation

Build the CLI from source:

```bash
go build -o miago main.go
```

## Usage

### Logout Command

The logout command removes the current user session.

```bash
miago logout
```

This will:
- Remove the session file stored at `~/.miago/session`
- Display a success message when logout is complete
- Return an error if no active session is found

## Development

### Running Tests

```bash
go test ./commands/... -v
```

### Project Structure

```
.
├── main.go              # CLI entry point
├── commands/            # Command implementations
│   ├── logout.go        # Logout command
│   └── logout_test.go   # Logout command tests
└── go.mod               # Go module file
```

## Session Management

The CLI manages sessions using a file stored at `~/.miago/session`. This file contains the authentication token for the current session.

When you run `miago logout`, the session file is removed, effectively logging you out.
