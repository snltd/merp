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

Merp uses Gurp to create a sandbox zone and execute the appropriate class of
tests inside it.

Put the `gurp` binary you want to test at the start of your `$PATH`.

```sh
$ PATH=/path/to/gurp:$PATH
```

And then you can run tests in a sandbox zone of the appropriate type.

```sh
$ gurp apply zones/native-doer-tests.janet  # lipkg zone
$ gurp apply zones/lx-doer-tests.janet      # lx zone
$ gurp apply zones/pkgsrc-doer-tests.janet  # pkgin zone
$ gurp apply zones/global-doer-tests.janet  # bhyve zone
```

All these create the zone, run the tests, then remove the zone. If you want to
keep the zone around for further debugging, comment out the `(zone/remove)`
entry. Should anything get stuck and you want to clean up, run the same commands
but with the `--destroy-everything-you-touch` flag.

Note that the native zone is cloned, so repeat tests can be run quickly, but Gurp must first create the gold zone. This might take a while depending on your connection to the OmniOS packages servers, or whether you have a local mirror. The gold zone is NOT cleaned up automatically.

## 2. Infrastructure Test

## Credits

This project bundles, in `vendor/`, the following third-party components:

- [Janet](https://github.com/janet-lang/janet) - MIT License, (c) Calvin Rose
  and contributors
- [janet-sh](https://github.com/andrewchambers/janet-sh) - (c) Andrew Chambers
- [judge](https://github.com/ianthehenry/judge) - MIT License, (c) Ian Henry

See THIRD_PARTY_LICENSES/ for details.
