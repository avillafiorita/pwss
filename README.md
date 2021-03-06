Pwss
====

A multi-platform password manager in the spirit of
[pws](https://github.com/janlelis/pws) and
[pass](https://www.passwordstore.org/).

Different from pws and pass, PWSS manages password **files**.  Each file can
contain multiple entries, possibly of different types (e.g., Entry,
CreditCard, BankAccount).

Entries in a file are structured.  For instance, Entry (the default type)
stores the following fields:

    -   title
    -   username
    -   password
    -   url
    -   description

PWSS uses the YAML format to store files: thus, they are thus human-readable
and editable.  Users can add their own fields to entries, if they wish to do
so.

Password files can be encrypted and commands allow to operate directly on
them.

`pwss` has been reported to work on OSX and Linux; it should also work
on Windows.  **If you are working on Linux, you need to install `xclip`,
to be able to use the clipboard.**


Installation
------------

Type from the command line:

    $ gem install pwss

PWSS depends upon the following gems: [encryptor](https://rubygems.org/gems/encryptor), [slop](https://rubygems.org/gems/slop), [clipboard](https://rubygems.org/gems/clipboard), and, starting from version 0.6.0, [gpgme](https://rubygems.org/gems/gpgme).

Password generation can use the `pwgen` utility, if available.


Quick Start
-----------

Try the following:

    $ pwss init -f pwss.yaml.enc
    $ pwss add -f pwss.yaml.enc First Entry
    $ pwss get -f pwss.yaml.enc First
    
If you do not specify a filename, `pwss` will initialize a `.pwss.yaml.enc` file in your home directory.

More information with:

    $ pwss
    $ pwss man
    $ pwss help


Detailed Instructions
---------------------

### Environment Setup: Generate a Keypair for PWSS

By default `pwss` uses GPG public-key/private-key encryption.  If you want to
stick to the default, the first step is setting up a key-pair with GPG.

Type the following commands from the command line:

    $ gpg --gen-key
    Real name: pwss-agent
    Email address: pwss-agent@example.com

If everything goes as expected, `gpg` generates a key-pair associated to the
(fake) `pwss-agent@example.com` email, which is used by `pwss` to encrypt
files with GPG.

Note.  If you prefer, you can also store files in plain-text or symmetrically
encrypted with OpenSSL.  In these cases, you need to use the `-f` option to
specify the file format for password files.

### Create a new Password file

`pwss init` creates a new password file, `.pwss.yaml.gpg` in your
home directory.

If you want to create multiple password files or store a password file in a
location of your choice, use the `-f` (`--filename`) option:

1.  `pwss init -f MYFILE`
2.  `pwss add -f MYFILE`
3.  `pwss get -f MYFILE`

The file extension determines whether the file is in plain-text or encrypted.
More in details, if the file ends in:

- ".gpg", `pwss` creates an asymetrically encrypted password file (public-key,
  private-key).  This is the default and it has some advantages: it does not
  require a password when adding an entry, it uses GPG mechanism for entering
  passwords (when decrypting the file), it allows you to store the password in
  the system keychain (at least on OSX).
- ".enc", `pwss` creates a symmetrically encrypted password file.  The library
  used is OpenSSL and the algorithm is (AES-256-CBC).
- any other extension creates a plain text file.  This is the simplest and
  less secure scenario.  There are situations, however, in which this is
  reasonable. The internal format used by `pwss` is YAML.  The password files
  are thus easily editable, when they are in plain text.

You can also start from an existing file, as long as it is an array of YAML
records, each containing, at least, a `title` and, possibly, a `password`
field.  (See section "Under the Hood" for more details.)

In this scenario, if can use the following commands, if you want to move to an
encrypted file:

1.  `pwss -f YOURFILE encrypt` to encrypt your existing password file
2.  `mv YOURFILE.gpg ~/.pwss.yaml.gpg` to move the encrypted file to the
    default location (not necessary, but it simplifies the workflow)


### Adding Entries

`pwss add` adds a new entry, possibly generating a random password.

If you prefer to operate on the file using a text editor, you can also `pwss
decrypt` the file, add the entry by hand, and `pwss encrypt` the file again or
just edit the file, if you don't care about encrypting your password file.

`pwss` supports different types of record, storing different information sets.
You can use the `-t` option to specify the type of an entry.  **Use the command
`describe` to describe the fields stored by a specific type.**

By default `pwss` automatically generates a completely random password for new
entries.  No attempt is made to make password readable or simpler to
remember. You can use the `-a` option to limit the generator to use only
digits and letters (\[0-9a-zA-Z\]): this is useful, for instance, for websites
and applications which accept only certain classes of characters.  The option
`-l` controls the password length.

You can also enter the password yourself, using the `--ask` option.

After adding an entry, **its password is made available in the clipboard, so
that it can be used as needed**.

Example

    pwss add
    
adds an entry with a random password of 16 chars.  Fields such as title,
username, etc., will be asked from the console.

    pwss add -t CreditCard --ask MasterCard
    
adds an entry of type `CreditCard`, whose title is "MasterCard".  All the other
fields, including the password will be asked from the console.


### Getting Entries

`pwss get string`:

1. shows a recap of all entries whose **title** contains `string`
2. lets the user choose an entry
3. prints the chosen full entry (optionally hiding the sensitive fields)
4. makes the password of the chosen entry available in the clipboard for 45
   seconds

Use the `-w` option to control how long the password is available in the
clipboard.  At the end of the waiting period `pwss` clears the clipboard.
**Remark: clipboards with history are not supported. In such cases the
password will be "pushed" in the clipboard history.  You might want to take
this into account.** Use `0` to keep the password in the clipboard till a key
is pressed.

Use the `--stdout` option to output the password to the console.

Example

    $ pwss get my_email -w 3

will retrieve a user selected entry whose title is `my_email` and make
the password available in the clipboard for `3` seconds.


### Updating Entries

`pwss update --field field string`:

1. shows a recap of all entries whose **title** contains `string`
2. lets the user choose an entry
3. asks the value for the new chosen `field`
4. updates the password file
5. if the field is a password, it makes the password available in the
   clipboard

Note. `pwss` always asks the user to select or confirm the entry to be
updated.

For instance:

    $ pwss update my_email -p --method alpha -l 10 -w 20

will update a user-chosen (or confirmed) entry whose title matches `my_email`,
by replacing the existing password with one of length `10` automatically
generated by `pwss`; the password contains only alphabetic characters and
digits. The new password is made available in the clipboard for `20` seconds.

### Deleting Entries

`pwss destroy string` deletes an entry from a password file matching `string`.

Similar to update, the command requires the user to select (multiple matches)
or confirm (single match) which entry has to be deleted.

### Moving from plain text to encrypted files (and viceversa)

You can use the `encrypt` and `decrypt` commands at any time to move from the
plain to the encrypted format.

    $ pwss encrypt -f YOURFILE

will encrypt `YOURFILE`, while `decrypt` will perform the opposite operation.
By default password files are encrypted with GPG.  You can use the option
`--symmetric` to change to a symmetric encryption using OpenSSL.

If you are using `gpg`, you need to create a gpg key `pwss-agent
<pwss-agent@example.com>`, as described above (See "Environment Setup:
Generate a Keypair for PWSS").

### The default safe

By default `pwss` operates on `~/.pwss.yaml.enc`.  If this file is not
found, `pwss` will try with `~/.pwss.yaml.gpg` and, if the previous
two files are not found, with `~/.pwss.yaml`.  This allows one to keep
the file encrypted or in plain text without having to specify `-f`
every time.

If you are not sure which file `pwss` is operating on, use the
`default` command.


### The Console

Starting from version 0.6.0, `pwss` comes with a console.  The main advantage
is that the file you operate on is cached in memory and the master password
does not need to be entered any time you perform a query. 

Note. The advantage is more evident when using symmetric encryption, since GPG
does not require a password for adding entries and it also already implement a
caching mechanism, which allows to perform multiple reading operations on a
password file without entering the password at every command.

To start the console, use the command `console`, optionally specifying a file.
The file is opened and used as the default file for all subsequent commands,
unless a command is given the `-f` option, in which case the command operates
on the file specified with `-f`.

To change the default file from an open console, use the `open -f` command.

Example

        $ pwss console -f a.yaml.enc
        Enter master password: ....

        pwss:000> get an entry
        ... (search in a.yaml.enc)
        pwss:001> get another entry
        ... (search in a.yaml.enc, no password asked)
        pwss:002> open -f another_file.yaml
        pwss:003> get another entry
        ... (search in another_file.yaml)
        pwss:004> get -f old.yaml another entry
        ... (search in old.yaml)
        pwss:005> get another entry
        ... (search in the default file, i.e., another_file.yaml)

The syntax of the commands available in the console is the same you have
available from the shell.  Type `help` if in doubt.


### Under the Hood/Editing your file by hand

`pwss` adopts a human-readable format for storing passwords, when the file is
not encrypted, of course! (Unless you have mathematical super-powers and can
read encrypted text.)

The password file store data as an array of YAML records.  By default, a
record contains:

- title
- username
- password
- url
- description

Notice that only `title` and `password` are required and 

Example

    - title: A webservice
      username: username@example.com
      password: 1234567890
      url: http://www.example.com
      description: |-
        with a password like the one above, who needs a password file?

    - title: My email
      username: username@example.com
      password: 1234567890
      url: http://www.example.com
      description: >
        Also available via email client, with the following connection parameters
        smtp.example.com
        imap.example.com

### Getting Help and Support

If in doubt, type `pwss` to get the list of available commands.

    $ pwss

will show all command options.

    $ pwss help cmd1 ... cmdN

will show the syntax of `cmd1`, ..., `cmdN`.

    $ pwss man

will show the man page.


Changelog
---------

See [Change Log](ChangeLog)

License
-------

Licensed under the terms of the MIT License.

Contributing
------------

1. Fork it (http://github.com/<my-github-username>/pwss/fork )\
2. Create your feature branch (`git checkout -b my-new-feature`)\
3. Commit your changes (`git commit -am 'Add some feature'`)\
4. Push to the branch (`git push origin my-new-feature`)\
5. Create new Pull Request
