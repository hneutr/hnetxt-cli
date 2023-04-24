#-------------------------------------------------------------------------------
# [architecture]()
#-------------------------------------------------------------------------------
- project commands should:
  - accept a project name
  - infer the project name if in a project directory

=-----------------------------------------------------------
= [commands]()
=-----------------------------------------------------------
- `project`:
  - `create`: create a new project
    ~ [type](project type): to implement
  - `root`: print project's root
- `journal`: print the project's journal or the default journal (create if it doesn't exist)
- TO IMPLEMENT:
  - `goals`: print the path to the current goals file (create if it doesn't exist)

=-----------------------------------------------------------
= [existing]()
=-----------------------------------------------------------

----------------------------------------
> [hnetext.py]()
----------------------------------------
- cli:
  - `project`:
    - `start`: begin a project
    ⨉ `print_root`: print the root directory of a given project
    - `set_metadata`: set a project's metadata field to a value
    - `set_status`: set a project's status
    - `show_by_status`: show projects by their status
    - `flags`: list items with a particular flag
  - `words`:
    - `unknown`: print an unknown word
  - `catalyze`: print catalysts
  - `session`:
    - `start`: print the session startup content
