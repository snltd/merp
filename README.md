Merp is an acceptance tester for [Gurp](https://github.com/snltd/gurp).

## Requirements

- Merp will only work in an OmniOS global zone.
- The user it runs as must have privileges to create, destroy, and clone zones,
  and to `zlogin` to the zones it creates.
- This repo must be augmented with native binaries of
  [Janet](https://janet-lang.org/) and
  [JPM](https://janet-lang.org/docs/jpm.html).

## Install

```sh
$ ./setup.sh
```

## Run Tests

```sh
$ ./run-tests.sh
```

## Note

`files/` contains a modified `judge` binary. If judge ever changes, we'll have
to change this to match.
