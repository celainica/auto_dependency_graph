import Lake
open Lake DSL


@[default_target]
lean_exe «readinfotree» where
  -- Enables the use of the Lean interpreter by the executable (e.g.,
  -- `runFrontend`) at the expense of increased binary size on Linux.
  -- Remove this line if you do not need such functionality.
  supportInterpreter := true


require mathlib from git "https://github.com/leanprover-community/mathlib4" @ "v4.11.0"
