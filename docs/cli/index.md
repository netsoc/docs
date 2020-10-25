# Netsoc CLI

Manage our services from the command line!

!!! tip
    You can skip installing the CLI on your own machine with SSH! See
    [here](../shh/) for more info.

## Getting started

To get started with the CLI, you'll need to download the
[latest release]({{ github_org }}/cli/releases/latest) from GitHub.

!!! note
    Unless your're on an old 32-bit system, always choose the `amd64` variant
    of the binary (even if you have an Intel CPU!). If you're on a Raspberry Pi,
    pick the `linux-arm-7` variant.

=== "Arch Linux"

    1. Use your favourite AUR helper to install the `netsoc` package. For
       example with [`yay`](https://github.com/Jguer/yay):

       ```bash
       yay -S netsoc
       ```

=== "Other Linux"

    1. Download `cli-linux-<arch>` (almost certainly `amd64`)
    2. Make the binary executable:
        ```bash
        chmod +x Downloads/cli-linux-amd64
        ```

    3. Move and rename the program into somewhere on your `$PATH` (so you can run it
       directly!), for example:
       ```bash
       sudo mv Downloads/cli-linux-amd64 /usr/local/bin/netsoc
       ```

=== "macOS"

    1. Download `cli-darwin-10.6-amd64`
    2. Make the binary executable:
        ```bash
        chmod +x Downloads/cli-darwin-10.6-amd64
        ```

    3. Move and rename the program into somewhere on your `$PATH` (so you can run it
       directly!), for example:
       ```bash
       sudo mv Downloads/cli-darwin-10.16-amd64 /usr/local/bin/netsoc
       ```

=== "Windows"

    1. Download `cli-windows-4.0-<arch>.exe` (almost certainly `amd64`)
    2. Rename the file to `netsoc.exe` (exclude the `.exe` if you don't see it
       on the downloaded file)
    3. Move the file to somewhere you'll remember, e.g. `C:\tools\netsoc.exe`
    4. Open a PowerShell terminal and `cd` to where you copied the file, for
       example:

       ```powershell
       cd C:\tools
       ```

You should now be able to run the CLI from your terminal as `netsoc` (on
Windows make sure you're in the directory you copied the `.exe` to and use
`.\netsoc.exe` instead).

## Using the CLI

Once installed, you need to log in to your account. To do this, run the
following:

```bash
# Replace `myusername` with your Netsoc username!
netsoc account login myusername
```

Now that you're logged in, you should be able to use the CLI! To make sure
everything is working, run:

```bash
$ netsoc account info
╭────┬───────────┬───────────────────┬────────────┬───────────────────────╮
│ ID │ USERNAME │ EMAIL           │ NAME      │ RENEWED             │
├────┼───────────┼───────────────────┼────────────┼───────────────────────┤
│ 1  │ bro      │ brodude@tcd.ie  │ Bro Dude  │ 2020-09-27 20:47:14 │
╰────┴───────────┴───────────────────┴────────────┴───────────────────────╯
$
```

See [the command reference](reference/netsoc/) for more details on commands
provided by the CLI.

*[CLI]: Command Line Interface
