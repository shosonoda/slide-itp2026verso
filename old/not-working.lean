```leanLibCode Verso.Code.External (package := verso) (decl := Verso.Code.External.withNl)
/--
Adds a newline to a string if it doesn't already end with one.
-/
public meta def withNl (s : String) : String := if s.endsWith "\n" then s else s ++ "\n"
```

Or a specific line range:

```leanLibCode Verso.Code.External (package := verso) (startLine := 77) (endLine := 77) -stretch
public meta def withNl (s : String) : String := if s.endsWith "\n" then s else s ++ "\n"
```
