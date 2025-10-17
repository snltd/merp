Merp is an acceptance tester for [Gurp](https://github.com/snltd/gurp).

You can read about the reasoning behind it
[here](https://tech.id264.net/post/2025-07-30-gurp-tests).

## Requirements

- A Gurp executable. By default looks for `../gurp/target/debug/gurp`.
- Privileges to create, destroy, and clone zones, and to `zlogin` to those
  zones.
- Merp will only work in an OmniOS global zone.
  [Here's how to set one up in AWS](https://omnios.org/setup/aws).

## Set Things Up

Edit the network config in `template/functional-test-template.janet` and
`tests/helpers.janet` to suit your environment.

Then in the global zone:

```
# ./setup-template-zone.sh
```

This installs a zone which will be cloned by the tests.

## Run The Tests

Note that this will create a ZFS dataset `rpool/test-zone-dataset`, which Gurp
will destroy after use.

```sh
$ ./run-tests.sh
```

Expect each zone to take 30s to a couple of minutes, depending on the packages
it adds.

You can pass `--debug` as the first argument. This will set `RUST_LOG=debug` and
pass `--dump-config` to Gurp. It produces a lot of output.

You can also specify one or more tests to run. Pass `tests/<host>-wrapper.janet`
as args.

## Note

`files/` contains a modified `judge` binary. If judge ever changes, we'll have
to change this to match.

## Credits

This project bundles the following third-party components:

- [Janet](https://github.com/janet-lang/janet) - MIT License, (c) Calvin Rose
  and contributors
- [janet-sh](https://github.com/andrewchambers/janet-sh) - (c) Andrew Chambers
- [judge](https://github.com/ianthehenry/judge) - MIT License, (c) Ian Henry

See THIRD_PARTY_LICENSES/ for details.
