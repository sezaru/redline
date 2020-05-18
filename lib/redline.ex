defmodule Redline do
  alias Redline.{Step, StepsChecker}

  @type opt :: {:name, atom} | {:input, atom} | {:inputs, [atom]}
  @type opts :: [opt]

  defmacro __using__(opts) do
    inputs_names = opts[:input] || opts[:inputs] || :initial_input

    opts = opts ++ [state: &Redline.State.new/0]

    quote do
      alias Redline.{Impl, Step, State}

      import Redline

      use Step, unquote(opts)

      @inputs_names unquote(inputs_names)

      Module.register_attribute(__MODULE__, :steps, accumulate: true)
      @before_compile Redline

      @impl Step
      def run(inputs, state), do: Impl.run({inputs, @inputs_names}, state, steps())

      @impl Step
      def run(inputs), do: Impl.run({inputs, @inputs_names}, steps())
    end
  end

  defmacro __before_compile__(_) do
    quote do
      @reversed_steps @steps |> Enum.reverse() |> StepsChecker.check(@inputs_names, __MODULE__)

      def steps, do: @reversed_steps
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
