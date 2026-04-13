Merp is an acceptance tester for [Gurp](https://github.com/snltd/gurp).

You can read about the reasoning behind it
[here](https://tech.id264.net/post/2025-07-30-gurp-tests).

## Requirements

- A Gurp executable. By default looks for `../gurp/target/debug/gurp`.
- Privileges to create, destroy, and clone zones, and to `zlogin` to those
  zones.
- Merp will only work in an OmniOS global zone.
  [Here's how to set one up in AWS](https://omnios.org/setup/aws).

## Running Tests

Merp has two actions: small self-contained doer tests, and a big test which
builds a reasonably complex system using most of Gurp's features.

### 1. Doer Tests

Merp tests each of
[Gurp's doers](https://github.com/snltd/gurp/tree/main/doc/doers) more-or-less
in isolation. Different doers require different zone types. For instance, you
can only set the kernel scheduler class in the global zone; you can only install
APK packages in an Apline LX zone, and so-on.

### 1.1 Running Doer Tests Which do not Require a Global Zone

Merp uses Gurp to create a sandbox zone and execute the appropriate class of
tests inside it.

From an OmniOS global zone:

```sh
$ PATH=/path/to/gurp:$PATH
# Test everything which is testable in a non-global zone. This also creates a
# "gold zone" from which the test zone is cloned.
$ gurp apply zones/ngz-doer-tests.janet
# Test APK doer in an Alpine zone
$ gurp apply zones/lx-doer-tests.janet
# Tests the pkgin doer
$ gurp apply zones/pkgsrc-doer-tests.janet
```

All these create the zone, run the tests, then remove the zone. If you want to
keep the zone around for further debugging, comment out the `(zone/remove)`
entry. Should anything get stuck and you want to clean up, run the same commands
but with the `--destroy-everything-you-touch` flag.

### 1.1 Running Doer Tests Which Require a Global Zone

The tests are as safe and non-invasive as I could make them, and I am happy
enough to run them in the global zone of my development machine.

### BELOW IS FOR EDIT

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

## Credits

This project bundles, in `vendor/`, the following third-party components:

- [Janet](https://github.com/janet-lang/janet) - MIT License, (c) Calvin Rose
  and contributors
- [janet-sh](https://github.com/andrewchambers/janet-sh) - (c) Andrew Chambers
- [judge](https://github.com/ianthehenry/judge) - MIT License, (c) Ian Henry

See THIRD_PARTY_LICENSES/ for details.

## Update the Dependencies

Copy in a new Janet binary and regenerate the `jpm_tree`.

```sh
$ cp `which janet` gold-zone/files/
$ cd gold-zone/files
$ jpm install --local
```

## Run the NGZ Doer Tests

```sh
$ gurp apply  ./gold-zone/ngz-doer-tests.janet
```

Clean up:

```sh
$ gurp apply --destroy-everything-you-touch ./gold-zone/ngz-doer-tests.janet
```

## Install vendor dir

Make sure the `merp` directory is symlinked to root, so `cd /merp` puts you
inside it.

Download and unpack the Janet source code somewhere, and from inside it:

```sh
$ PREFIX=/merp/vendor gmake install
```

Make sure you don't have any `JANET_` env vars set.

Clone the `jpm` source, and from inside it

```sh
$ /merp/vendor/bin/janet bootstrap.janet
$ /merp/vendor/bin/jpm install sh judge
```
