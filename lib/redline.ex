defmodule Redline do
  alias Redline.Step

  @type opts :: Step.options()

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Redline

      alias Redline.{Impl, Step, State}

      @behaviour Step

      Module.register_attribute(__MODULE__, :steps, accumulate: true)
      @before_compile Redline

      @impl Step
      def options, do: unquote(opts)

      @impl Step
      def new, do: State.new()

      @impl Step
      def run(input, state), do: Impl.run(input, state, steps())

      def run(input), do: Impl.run(input, steps())
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def steps, do: @steps |> Enum.reverse()
    end
  end

  defmacro step(inner_steps) when is_list(inner_steps) do
    quote do
      @steps {:step,
              Enum.map(unquote(inner_steps), fn
                {name, opts} -> {name, Map.new(name.options() ++ opts)}
                name -> {name, Map.new(name.options())}
              end)}
    end
  end

  defmacro step(name, opts \\ []) do
    quote do
      @steps {:step, unquote(name), Map.new(unquote(name).options() ++ unquote(opts))}
    end
  end
end
