# Practice Problems

## For each of the following filetypes, indicate whether that filetype is considered server-side or client-side and why.

**Gemfile** - Server-side
**Ruby files (`.rb`)** - Server-side
**Stylesheets (`.css`)** - Client-side
**JavaScript files (`.js`)** - Client-side

!!!
**View Templates (`.erb`)** - Client-side <- NO!
!!!

Templates like the erb files we've been working with contain both server and
client side code. These files must be processed first on the server side to take
care of the ruby code, and are thus considered server-side.
