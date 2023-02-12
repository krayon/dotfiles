## External vim plugins

The directory `.vim/EXTERNAL/` stores externally sourced vim plugins. They are
included as
[subtrees](https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt)
within the repository.

These plugins are then symlinked into the appropriate place for use.

### Adding a new plugin

The following is an example of the command used to add a new plugin:

```bash
git subtree add \
    --prefix .vim/EXTERNAL/diffchar.vim--github--rickhowe \
    https://github.com/rickhowe/diffchar.vim.git \
    006a03473ccf39e23eabdffca6a923156046d0c4 \
    --squash --message='Add diffchar (8.7) plugin subtree'
```

  - `.vim/EXTERNAL/diffchar.vim--github--rickhowe`
    - The directory to install to
  - `https://github.com/rickhowe/diffchar.vim.git`
    - The repository location
  - `006a03473ccf39e23eabdffca6a923156046d0c4`
    - The commit, this can be a branch, a tag or commit sha (as it is here)
  - `'Add diffchar (8.7) plugin subtree'`
    - The message to put in the commit log

### Enabling the plugin

The following is an example of the command used to enable the new plugin:

```bash
ln -s ../EXTERNAL/diffchar.vim--github--rickhowe/autoload/diffchar.vim .vim/autoload/
ln -s ../EXTERNAL/diffchar.vim--github--rickhowe/plugin/diffchar.vim   .vim/plugin/
```

### Updating the plugin

The following is an exammple of the command used to update the plugin from
upstream:

```bash
git subtree pull \
    --prefix .vim/EXTERNAL/diffchar.vim--github--rickhowe \
    https://github.com/rickhowe/diffchar.vim.git \
    8.8 \
    --squash --message='Update diffchar plugin subtree to 8.8'
```

  - `.vim/EXTERNAL/diffchar.vim--github--rickhowe`
    - The directory to install to
  - `https://github.com/rickhowe/diffchar.vim.git`
    - The repository location
  - `8.8`
    - The commit, this can be a branch, a tag or commit sha (as it is here)
  - `'Update diffchar plugin subtree to 8.8'`
    - The message to put in the commit log

----
[//]: # ( vim: set ts=4 sw=4 et cindent tw=80 ai si syn=markdown ft=markdown: )
