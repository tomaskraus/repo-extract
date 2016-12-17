repo-extract
------------

```
<<< repo-extract - Git project isolation tool >>>
Isolates a subdirectory from a repository cloned from a remote and creates a new repository with that subdirectory content, with its history preserved.
That new repository is then pushed to the destination remote.

  usage: repo-extract.sh <source-remote> <dir-to-isolate> <new-repo-name> [<destination-remote>]

    if <destination-remote> is not specified, uses a local, temporary remote as a destination. This is a safe, non-destructive option for testing purposes.

  At the end, clones a temporary repository from the updated destination-remote, to see the fresh result.

  note: provide an absolute path (or URL) for <source-remote> and <destination-remote> parameters
  note: if <destination-remote> is specified, that destination-remote must already exists


  example: repo-extract.sh "https://github.com/user/all-project" project1 project-1 "https://github.com/user/project-1"
```

### tip

When extracting multiple directories from one source-remote repository, speed-up the cloning process by clone that remote repository to your machine first, and then use that cloned one as a local source-remote.