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
$ gem install muxify
```

## Usage

```sh
$ muxify -h

Commands:
  muxify add             # Adds tmuxinator config for current (or supplied) path
  muxify debug           # Prints tmuxinator config of current (or supplied) path to stdout
  muxify help [COMMAND]  # Describe available commands or one specific command
  muxify stop            # Kills tmux session
```

For example, add a project like so:

```sh
$ muxify add /path/to/my_app
$ mux my_app
```

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

Each project may have custom windows via a `.muxifyrc` file.

### Using a .muxifyrc in your home directory

1. Create a file called `~/.muxifyrc`.
1. Edit it in YAML format; eg to add a tmux window to `my_app` project which is named `server` and invokes `yarn dev`:

```yaml
my_app:
  windows:
    server: yarn dev
```

If you want a custom window for all projects:

```yaml
windows:
  echo_all_projects: "echo 'this will apply to all projects'"
```

### Using a .muxifyrc in your project directory

1. Create a file called `my_app/.muxifyrc` (given your project is in `my_app`).
1. Edit it in YAML format; eg to add a tmux window to `my_app` project which is named `server` and invokes `yarn dev`:

```yaml
windows:
  server: yarn dev
```

## Thanks

- https://github.com/tmuxinator/tmuxinator

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zubin/muxify.
