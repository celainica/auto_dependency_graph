import Lean
import Lean.Data.Json.FromToJson
import Lean.Elab.Frontend
import Lean.Data.Json

open Lean.Elab

structure Config where
  file_path : System.FilePath := "."
  const_name : Lean.Name := `Unknown
  min_match_len : Nat := 2
  nonmatchers : String := ""

def parseArgs (args : Array String) : IO Config := do
  if args.size < 2 then
    throw <| IO.userError "readinfotree FILE_PATH CONST_NAME"
  let mut cfg : Config := {}
  cfg := { cfg with file_path := ⟨args[0]!⟩ }
  cfg := { cfg with const_name := args[1]!.toName }
  let mut idx := 2
  while idx < args.size do
    match args[idx]! with
    | "--args" =>
      IO.println ("WIP, argument")
    | s => throw <| IO.userError s!"unknown argument {s}"
    idx := idx + 1

  return cfg

unsafe def processCommands : Frontend.FrontendM (List (Lean.Environment × InfoState)) := do
  let done ← Lean.Elab.Frontend.processCommand
  let st := ← get
  let infoState := st.commandState.infoState
  let env' := st.commandState.env

  -- clear the infostate
  set {st with commandState := {st.commandState with infoState := {}}}
  if done
  then return [(env', infoState)]
  else
    return (env', infoState) :: (←processCommands)


unsafe def main (args : List String) : IO Unit := do
  let config ← parseArgs args.toArray
  IO.println (config.file_path)
  Lean.searchPathRef.set compile_time_search_path%
  let mut input ← IO.FS.readFile config.file_path
  Lean.enableInitializersExecution
  let inputCtx := Lean.Parser.mkInputContext input config.file_path.toString
  let (header, parserState, messages) ← Lean.Parser.parseHeader inputCtx
  let (env, messages) ← Lean.Elab.processHeader header {} messages inputCtx


  if messages.hasErrors then
    for msg in messages.toList do
      if msg.severity == .error then
        println! "ERROR: {← msg.toString}"
    throw <| IO.userError "Errors during import; aborting"


  let env := env.setMainModule (← Lean.moduleNameOfFileName config.file_path none)

  if env.contains config.const_name then
    throw <| IO.userError s!"constant of name {config.const_name} is already in environment"

  let commandState := { Lean.Elab.Command.mkState env messages {} with infoState.enabled := true }

  let (steps, _frontendState) ← (processCommands.run { inputCtx := inputCtx }).run
    { commandState := commandState, parserState := parserState, cmdPos := parserState.pos }

  -----
  for ⟨env, s⟩ in steps do
    if env.contains config.const_name then
      for tree in s.trees do
        /-if config.print_infotree then-/
        IO.println (Std.Format.pretty (←tree.format))
