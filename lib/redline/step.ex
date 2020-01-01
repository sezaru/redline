defmodule Redline.Step do
  @type options :: [name: atom, input: atom] | [name: atom, inputs: [atom]]

  @type state :: any
  @type input :: any
  @type output :: any | :stop | {:error, reason :: any}

  @callback options() :: options

  @callback new() :: state

  @callback run(input, state) :: {output, state}
end
