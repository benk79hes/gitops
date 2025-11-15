# Contributing to GitOps Multi-Web Hosting Platform

Thank you for considering contributing to this project! This document provides guidelines for contributing.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (OS, Docker version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please open an issue with:
- Clear description of the enhancement
- Use case or problem it solves
- Possible implementation approach

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Guidelines

### Code Style

- Use clear, descriptive variable names
- Comment complex logic
- Follow existing code patterns
- Keep scripts POSIX-compliant when possible

### Docker Compose Files

- Use version 3.8 or later
- Include restart policies
- Use named networks
- Document environment variables
- Include labels for Traefik routing

### Scripts

- Include usage instructions
- Validate input parameters
- Provide helpful error messages
- Use `set -e` for safety
- Make scripts executable

### Documentation

- Update README.md for significant changes
- Document new features
- Include examples
- Keep documentation current

## Testing

Before submitting:

1. Test on a clean environment
2. Verify scripts work as expected
3. Check Docker Compose files syntax
4. Test with different configurations
5. Ensure documentation is accurate

## Security

- Never commit secrets or passwords
- Review security implications
- Follow Docker security best practices
- Document security considerations

## Adding New Site Templates

When adding a new site template:

1. Create directory in `sites/example-newtype/`
2. Include:
   - `docker-compose.yml`
   - `.env.example`
   - `README.md` with setup instructions
3. Update main README.md
4. Test deployment script compatibility

## Questions?

Feel free to open an issue for questions or join the discussion.

Thank you for contributing!
