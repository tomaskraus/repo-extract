repo-extract
------------

```
<<< repo-extract - Git project isolation tool >>>
Isolates a subdirectory from a repository and creates a new repository with a subdirectory content, with its history preserved.

  usage: repo-extract.sh <original-git-remote> <dir-to-isolate> <new-repo-name> [<new-remote-origin-location>]

   if <new-remote-origin-location> is not specified, uses a temporary origin - this is a safe, non-destructive option for testing

  note: provide an absolute path (or URL) for <original-git-remote> and <new-remote-origin-location> parameters

```