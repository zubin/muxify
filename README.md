# Muxify

Sets up consistent tmux development environment for projects.

Why?

- Saves time and effort switching projects.
- Ensures consistent layout which is faster to navigate via muscle memory.
- Avoids visual and mental overhead of maintaining numerous tabs.

## Dependencies

- MacOS (may work on Linux)
- Ruby
- Tmux (`which tmux || brew install tmux`)

## Installation

```sh
gem install muxify
```

## Usage

```sh
$ muxify help
Commands:
  muxify add             # Adds tmuxinator config for current (or supplied) path
  muxify debug           # Prints tmuxinator config of current (or supplied) path to stdout
  muxify help [COMMAND]  # Describe available commands or one specific command
  muxify stop            # Kills tmux session
  muxify version         # Print current version
```

### Example

```sh
# Add a new project (do this once)
muxify add path/to/myproject

# Load the project
mux myproject
```

## How it works

Depending on its type, this will create the following tmux windows for a project:

- Standard (applies to all projects)
  - shell (performs `git fetch` when `.git` is present)
  - editor (invokes terminal editor, defaulting to `vim` when `$EDITOR` is unset)
  - logs (when present, truncates then tails `log/*.log`)
- Rails (identified by presence of `bin/rails`)
  - db (`rails db`)
  - console (`rails console`)
  - server (configures puma-dev then `rails server`; see [code](./bin/rails_server_with_puma_dev))
- NodeJS (identified by presence of `package.json` when non-Rails)
  - console (`node`)
- Elixir (identified by presence of `mix.exs` when non-Phoenix)
  - console (`iex -S mix`)
  - server (`mix`)
- Elixir/Phoenix (identified by presence of `deps/phoenix`)
  - console (`iex -S mix phoenix.server`)
  - server (`mix phoenix.server`)
- Django (identified by `requirements.txt` containing `django`)
  - db (`python manage.py dbshell`)
  - console (`python manage.py shell`)
  - server (`python manage.py runserver`)

## Customising projects

For custom configuration, add a `.muxify.yml` file to the top level of the project directory.

For example, to start Docker in a project, the following could be added to its `.muxify.yml`:

```yaml
windows:
  docker: docker compose up
```

## Thanks

- https://github.com/tmuxinator/tmuxinator

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zubin/muxify.
