export_local_without_parens = [
  step: 1,
  step: 2
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  local_without_parens: export_local_without_parens,
  export: [local_without_parens: export_local_without_parens]
]
