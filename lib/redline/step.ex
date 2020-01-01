defmodule Redline.Step do
  @type state :: any | (() -> any)
  @type input :: any
  @type output :: any | :stop | {:error, reason :: any}

  @type opt :: {:name, atom} | {:input, atom} | {:inputs, [atom]} | {:state, state}
  @type opts :: [opt]

  @callback options() :: opts

  @callback new() :: state

  @callback run(input, state) :: {output, state}

  defmacro __using__(opts) do
    {state, opts} = Keyword.pop(opts, :state, quote(do: %{}))

    quote do
      import Redline.Step

      alias Redline.Step

      @behaviour Step

      @impl Step
      def options, do: unquote(opts)

      @impl Step
      def new do
        case is_function(unquote(state)) do
          true -> unquote(state).()
          false -> unquote(state)
        end
      end
    end
  end
end
