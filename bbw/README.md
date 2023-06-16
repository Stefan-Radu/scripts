# BBW

A minimal `bitwarden-cli` wrapper.

Inspired by [this](https://www.drumm.sh/blog/2021/08/25/bw-cli/) article and [shellsec](https://github.com/Costinteo/shellsec).

## Requirements

* [bitwarden-cli](https://bitwarden.com/help/cli/)
* jq (for parsing json)
* xsel (for copying to clipboard)

## Usage

    bbw.sh [options] <search_term>

    Wrapper for bw(bitwarden-cli). Use to search for a login info, and to
    copy credentials to clipboard. Use options to generate passwords.

    arguments:
        search_term    A string corresponding to what login info you want to search for

    options:
        -g             Generate a password [default 15 characters]; overriden by -l
        -n             Don't use special characters
        -p             Generate a passphrase [default 3 words]; overriden by -l
        -c             Copy output (from generation) to clipboard
        -l <len>       Override length for password and passphrase with <len>
        -h             Show this help text

## Usage examples

To get credentials:

    $ bbw <search-term>
    ? Master password: [hidden]

    Multiple matches:
    0) option-one
    1) option-two
    2) option-three
    Choose only one: 1
    Username in clipboard
    Press any key to copy password...
    Password copied!

To generate a password:

    $ bbw -gl 15
    Generated password:
    *9j@%opq&N8BQyX

To generate a pass-phrase:

    $ bbw -pl 5
    Generated password:
    Bobsled-Scrawny-Rockiness-Fang1-Shorthand

Use the `-c` option to copy to clipboard

    $ bbw -pl 5 -c
    Password copied to your clipboard


## Notes on behaviour

As stated, this script is just a `bitwarden-cli` wrapper. It offers minimal flexibility to simplify usage and maximize security. Thus, for password generation, uppercase, lowercase, numbers and symbols are used by default. You can opt-in to not use symbols. Also, for passphrases all words are capitalized and one number is included. For both, the length can customized, but by default a password will be 15 characters in length and a passphrase whill span 3 words.

By default you have to input your account password for every use (excluding generation). However, there are multiple login options that you can read about in the [official documentation](https://bitwarden.com/help/cli/)
