# Users making accounts

Usernames should be 12 chars or less
Passwords should match (2 fields)

1. Provide fields for username and two fields for passwords (type and retype)
2. Validate username - not already used and not too long
3. Validate password - both fields are strings with same value
4. Convert password to bcrypt password
5. Store new username and bcrypted password in `users.yml`
6. Redirect to login page, display flash success message
