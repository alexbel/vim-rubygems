# Vim Rubygems

The vim-rubygems plugin provides ability to work with rubygems.org inside Vim.

Currenty the following features are provided by the plugin:

* general information for selected gem (version, authors, summary, built date, downloads, description)
* versions list for selected gem (version, built date)
* last version for selected gem (version, built date)
* append a version for a gem under cursor

## Requirements

* Vim 7.3+
* [webapi-vim](https://github.com/mattn/webapi-vim)
* `curl` or `wget` commands

## Installation
The plugin is compatible with Vundle/Pathogen.  

An example for Vundle:

```
Bundle 'alexbel/vim-rubygems'
```

Then run `:BundleInstall` to install the plugin.

## Usage

The plugin provides the following commands:  

* :RubygemsGemInfo
* :RubygemsVersions
* :RubygemsRecentVersion
* :RubygemsAppendVersion

It parses current line under the cursor, extracts the name of the gem and shows information for it.

## Set mappings (optional):
```
nnoremap <leader><leader>g :RubygemsRecentVersion<cr>
```

## TODO
* ✔ Syntax highlighting
* ✔ Show a list of versions for a gem
* ✔ Append gem version for a gem
* Check Gemfile for outdated gems
