# Miago AI CLI

A command-line interface tool for managing authentication and sessions with Miago AI.

## Installation

### Build from source

```bash
go build -o miago
```

### Install globally

```bash
go install
```

## Usage

### Logout Command

The `logout` command removes stored credentials and session tokens, effectively logging you out of your current session.

```bash
miago logout
```

#### Behavior

- If a session is active (credentials file exists), it will be removed and you'll be logged out successfully
- If no session is active, the command will display an error message
- Credentials are stored in `~/.miago/credentials`

#### Examples

Successful logout:
```bash
$ miago logout
Successfully logged out
```

No active session:
```bash
$ miago logout
Error during logout: no active session found
```

## Development

### Running Tests

```bash
go test ./... -v
```

### Project Structure

```
.
├── main.go                 # CLI entry point
├── commands/
│   ├── logout.go          # Logout command implementation
│   └── logout_test.go     # Tests for logout command
├── go.mod                 # Go module file
└── go.sum                 # Go dependencies
```

## Contributing

Contributions are welcome! Please ensure all tests pass before submitting a pull request.

## License

See LICENSE files for details.
